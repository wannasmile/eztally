package com.google.eztally.android;

import org.xmlrpc.android.XMLRPCClient;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;

public class LoginActivity extends Activity {
	private static final String TAG = "LoginActivity";

	public static final String LOGIN_ACTION_KEY = "LOGIN_ACTION";
	public static final int  LOGIN_ACTION_LOGIN = 101;
	public static final int  LOGIN_ACTION_RELOGIN = 102;
	private static final int  DIALOG_LOGIN_PROGRESS_KEY = 1;

	private XMLRPCClient client;
	private SharedPreferences setting;
	private int userId;
	private String password;
	private boolean isAutoLogin;

	private TextView tvSvcUrl;
	private Spinner spUser;
	private EditText etPassword;
	private CheckBox cbRemember;
	private TextView tvInfo;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.login);

		tvSvcUrl = (TextView) findViewById(R.id.login_svcurl_tv);
		spUser = (Spinner) findViewById(R.id.login_user_sp);
		etPassword = (EditText) findViewById(R.id.login_password_et);
		cbRemember = (CheckBox) findViewById(R.id.login_rememberme_cb);
		tvInfo = (TextView) findViewById(R.id.login_info_tv);
		tvInfo.setVisibility(View.INVISIBLE);

		setting = PreferenceManager.getDefaultSharedPreferences(this);

		userId = setting.getInt(SettingActivity.KEY_PREF_USERID, 0);
		password = setting.getString(SettingActivity.KEY_PREF_PASSWD, "");
		isAutoLogin = setting.getBoolean(SettingActivity.KEY_AUTO_LOGIN, false);
		String svcUrl = setting.getString(SettingActivity.KEY_SERVICE_URL,	SettingActivity.DEFAULT_SVC_URL);
		
		spUser.setSelection(userId);
		etPassword.setText(password);
		cbRemember.setChecked(isAutoLogin);
		tvSvcUrl.setText("[" + svcUrl + "]");
		client = new XMLRPCClient(svcUrl);

		Bundle bundle = getIntent().getExtras();
		int action = bundle.getInt(LOGIN_ACTION_KEY);
		switch (action) {
			case LOGIN_ACTION_LOGIN: {
				break;
			}
			case LOGIN_ACTION_RELOGIN: {
				tvInfo.setText(R.string.login_login_failed);
				tvInfo.setVisibility(View.VISIBLE);
				break;
			}
		}

		ArrayAdapter<CharSequence> usersAdapter = ArrayAdapter
				.createFromResource(this, R.array.users_arr, android.R.layout.simple_spinner_item);
		usersAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spUser.setAdapter(usersAdapter);
		spUser.setOnItemSelectedListener(new Spinner.OnItemSelectedListener() {
			@Override
			public void onItemSelected(AdapterView<?> parent, View view,
					int position, long id) {
				userId = parent.getSelectedItemPosition();
			}

			@Override
			public void onNothingSelected(AdapterView<?> parent) {
			}

		});

		Button btnLogin = (Button) findViewById(R.id.login_login_btn);
		btnLogin.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				login();
			}
		});

		Button btnSetting = (Button) findViewById(R.id.login_setting_btn);
		btnSetting.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				startSettingForResult();
			}
		});

	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		switch (requestCode) {
			case SettingActivity.SETTING_ACTION_SET: {
		        String svcUrl = setting.getString(SettingActivity.KEY_SERVICE_URL, SettingActivity.DEFAULT_SVC_URL);
		        if (svcUrl.compareToIgnoreCase(RpcMethod.serviceUrl) != 0) {
					tvSvcUrl.setText("[" + svcUrl + "]");
			    	client = new XMLRPCClient(svcUrl);
		        }
				tvInfo.setVisibility(View.INVISIBLE);
				break;
			}
		}
	}
		
    @Override
    protected Dialog onCreateDialog(int id) {
    	ProgressDialog dialog = new ProgressDialog(this);
        dialog.setIndeterminate(true);
        dialog.setCancelable(false);
        switch (id) {
	        case DIALOG_LOGIN_PROGRESS_KEY: {
	            dialog.setMessage(getResources().getText(R.string.login_login_progress));
	            break;
	        }
        }
        return dialog;
    }

	private void login() {
		RpcMethod.sessionKey = null;
		tvInfo.setVisibility(View.INVISIBLE);
		showDialog(DIALOG_LOGIN_PROGRESS_KEY);
		
		RpcMethod rpc = new RpcMethod(client, "user_login",	new RpcMethod.Callback() {
			public void callRes(Object result, int resCode,	String resInfo) {
				dismissDialog(DIALOG_LOGIN_PROGRESS_KEY);
				if ((result != null) && (resCode == 0)) {
					RpcMethod.sessionKey = (String) result;
					//tvInfo.setText(R.string.login_success_str);

					if (isAutoLogin) {
						setting.edit().putInt(SettingActivity.KEY_PREF_USERID, userId).commit();
						setting.edit().putString(SettingActivity.KEY_PREF_PASSWD, password).commit();
						setting.edit().putBoolean(SettingActivity.KEY_AUTO_LOGIN, true).commit();
					} else {
						setting.edit().putInt(SettingActivity.KEY_PREF_USERID, userId).commit();
						setting.edit().putString(SettingActivity.KEY_PREF_PASSWD, "").commit();
						setting.edit().putBoolean(SettingActivity.KEY_AUTO_LOGIN, false).commit();
					}
					setResult(RESULT_OK);
					finish();
				} else {
					String errMsg = "RpcError[user_login]: " + resInfo;
					Log.e(TAG, errMsg);
					//tvInfo.setText(errMsg);
					tvInfo.setText(R.string.login_login_failed);
					tvInfo.setVisibility(View.VISIBLE);
				}
			}
		});

		password = etPassword.getText().toString();
		isAutoLogin = cbRemember.isChecked();

		Object[] params = { userId, password, };
		rpc.callReq(params);
	}

    private void startSettingForResult() {
		Intent intent = new Intent(this, SettingActivity.class);
		startActivityForResult(intent, SettingActivity.SETTING_ACTION_SET);
    }

}
