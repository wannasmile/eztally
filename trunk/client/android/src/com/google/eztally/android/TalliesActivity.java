package com.google.eztally.android;

import java.util.Date;

import org.xmlrpc.android.Base64;
import org.xmlrpc.android.XMLRPCClient;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.text.format.DateFormat;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.ImageView;
import android.widget.AdapterView.OnItemClickListener;
import android.graphics.BitmapFactory;
import android.graphics.Bitmap;
import com.google.eztally.android.R;

public class TalliesActivity extends Activity {
	private static final String TAG = "TalliesActivity";

	private static final int  DIALOG_ABOUT_KEY = 100;
	private static final int  DIALOG_LOGIN_PROGRESS_KEY = 201;
	private static final int  DIALOG_TALLIES_PROGRESS_KEY = 202;
	private static final int  DIALOG_LOGIN_FAILED_KEY = 301;
	private static final int  DIALOG_TALLIES_FAILED_KEY = 302;
	
	private static final int  COUNT_FIRST_TIME = 15;
	private static final int  COUNT_REQ_MORE = 15;
	
	protected static final int MENU_LOGIN = Menu.FIRST;
	protected static final int MENU_SETTING = Menu.FIRST + 1;
	protected static final int MENU_ABOUT = Menu.FIRST + 2;
	protected static final int MENU_QUIT = Menu.FIRST + 3;
	
	private ListView lvList;
	private TextView tvMonTotal;
	private TextView tvInfo;

	private SharedPreferences setting;
	private XMLRPCClient client;
	private TalliesAdapter tallies;
	private boolean isFirstTally = false;
	private String totalStr;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tallies);
        
		lvList = (ListView) findViewById(R.id.tallies_list_lv);
		tvMonTotal = (TextView) findViewById(R.id.tallies_montotal_tv);
		totalStr = String.valueOf(getResources().getText(R.string.tallies_montotal_tv));
		tvMonTotal.setText(String.format(totalStr, 0, 0));
		tvInfo = (TextView) findViewById(R.id.tallies_info_tv);
		tvInfo.setVisibility(View.GONE);
        
		tallies = new TalliesAdapter(this);
		lvList.setAdapter(tallies);
		lvList.setOnItemClickListener(new OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				TallyHolder tally = (TallyHolder) view.getTag();
				startTallyForResult(TallyActivity.TALLY_ACTION_EDIT, tally);
			}	
		});

		setting = PreferenceManager.getDefaultSharedPreferences(this);
        String svcUrl = setting.getString(SettingActivity.KEY_SERVICE_URL, SettingActivity.DEFAULT_SVC_URL);
    	client = new XMLRPCClient(svcUrl);
    	loginWithReqTallies();

		Button btnAdd = (Button) findViewById(R.id.tallies_add_btn);
        btnAdd.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		startTallyForResult(TallyActivity.TALLY_ACTION_ADD, null);
        	}
        });
        
        Button btnReport = (Button) findViewById(R.id.tallies_report_btn);
        btnReport.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		startReportForResult();
        	}
        });
    }

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		super.onCreateOptionsMenu(menu);
		menu.add(0, MENU_LOGIN, 0, R.string.tallies_menu_login);
		menu.add(0, MENU_SETTING, 0, R.string.tallies_menu_setting);
		menu.add(0, MENU_ABOUT, 0, R.string.tallies_menu_about);
		menu.add(0, MENU_QUIT, 0, R.string.tallies_menu_quit);
		return true;
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		super.onOptionsItemSelected(item);
		switch (item.getItemId()) {
			case MENU_LOGIN: {
				startLoginForResult(LoginActivity.LOGIN_ACTION_LOGIN);
				break;
			}
			case MENU_SETTING: {
				startSettingForResult();
				break;
			}
			case MENU_ABOUT: {
				showDialog(DIALOG_ABOUT_KEY);
				break;
			}
			case MENU_QUIT: {
				finish();
				break;
			}
		}
		return true;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		switch (requestCode) {
			case LoginActivity.LOGIN_ACTION_LOGIN: 
			case LoginActivity.LOGIN_ACTION_RELOGIN: {
		        if (client.getUrl().compareToIgnoreCase(RpcMethod.serviceUrl) != 0) {
			    	client = new XMLRPCClient(RpcMethod.serviceUrl);
		        }
				switch (resultCode) {
					case RESULT_OK: {
						reqLastTallies(COUNT_FIRST_TIME, 0);
						break;
					} 
					case RESULT_CANCELED: {
						if (RpcMethod.sessionKey == null) finish();
						break;
					}
				}
				break;
			}
			case TallyActivity.TALLY_ACTION_ADD: 
			case TallyActivity.TALLY_ACTION_EDIT: {
				switch (resultCode) {
					case RESULT_OK: {
						reqLastTallies(COUNT_FIRST_TIME, 0);
						break;
					} 
					case RESULT_CANCELED: {
						break;
					}
				}
				break;
			}
			case ReportActivity.REPORT_ACTION_REPORT: {
				break;
			}
			case SettingActivity.SETTING_ACTION_SET: {
		        String svcUrl = setting.getString(SettingActivity.KEY_SERVICE_URL, SettingActivity.DEFAULT_SVC_URL);
		        if (svcUrl.compareToIgnoreCase(RpcMethod.serviceUrl) != 0) {
			    	client = new XMLRPCClient(svcUrl);
		        	loginWithReqTallies();
		        }
				break;
			}
		}
	}
		
    @Override
    protected Dialog onCreateDialog(int id) {
        switch (id) {
	        case DIALOG_ABOUT_KEY: {
	    		AlertDialog dialog = new AlertDialog.Builder(this)
	    			.setTitle(R.string.tallies_about_title)
        			.setMessage(R.string.tallies_about_message).create();
	    		return dialog;
	        }
	        case DIALOG_LOGIN_PROGRESS_KEY: {
	        	ProgressDialog dialog = new ProgressDialog(this);
	            dialog.setIndeterminate(true);
	            dialog.setCancelable(true);
	            dialog.setMessage(getResources().getText(R.string.login_login_progress));
	            return dialog;
	        }
	        case DIALOG_TALLIES_PROGRESS_KEY: {
	        	ProgressDialog dialog = new ProgressDialog(this);
	            dialog.setIndeterminate(true);
	            dialog.setCancelable(true);
	            dialog.setMessage(getResources().getText(R.string.tallies_getdata_progress));
	            return dialog;
	        }
	        case DIALOG_LOGIN_FAILED_KEY: {
	    		AlertDialog dialog = new AlertDialog.Builder(this)
        			.setMessage(R.string.login_login_failed).create();
	    		return dialog;
	        }
	        case DIALOG_TALLIES_FAILED_KEY: {
	    		AlertDialog dialog = new AlertDialog.Builder(this)
        			.setMessage(R.string.tallies_getdata_failed).create();
	    		return dialog;
	        }
	        default : return null;
        }
    }

    private void loginWithReqTallies() {
		RpcMethod.sessionKey = null;

		if (setting.getBoolean(SettingActivity.KEY_AUTO_LOGIN, false)) {
			showDialog(DIALOG_LOGIN_PROGRESS_KEY);

			RpcMethod rpc = new RpcMethod(client, "user_login",	new RpcMethod.Callback() {
				public void callRes(Object result, int resCode,	String resInfo) {
					dismissDialog(DIALOG_LOGIN_PROGRESS_KEY);
					
					if ((result != null) && (resCode == 0)) {
						RpcMethod.sessionKey = (String) result;
						reqLastTallies(COUNT_FIRST_TIME, 0);
					} else {
						Log.e(TAG, "RpcError[user_login]: " + resInfo);
						startLoginForResult(LoginActivity.LOGIN_ACTION_RELOGIN);
					}
				}
			});
	
			int userId = setting.getInt(SettingActivity.KEY_PREF_USERID, 0);
			String password = setting.getString(SettingActivity.KEY_PREF_PASSWD, "");
			Object[] params = { userId, password, };
			rpc.callReq(params);
		} else {
			startLoginForResult(LoginActivity.LOGIN_ACTION_LOGIN);
		}
	}

    private void reqLastTallies(final int count, final int offset){
		if (RpcMethod.sessionKey == null) return;

		if (offset == 0) {
			tallies.clear();
			isFirstTally = false;
		}
		showDialog(DIALOG_TALLIES_PROGRESS_KEY);
		RpcMethod rpc = new RpcMethod(client, "get_last_tallies", new RpcMethod.Callback() {
			public void callRes(Object result, int resCode, String resInfo) {
				if (offset == 0) reqMonTotal();
				dismissDialog(DIALOG_TALLIES_PROGRESS_KEY);
				if ((result != null) && (resCode == 0)){
					Object[] rawTallies = (Object[]) result;
					for (int i = 0; i < rawTallies.length; i++){
						tallies.add(rawTallies[i]);
					}
					if (rawTallies.length < count) isFirstTally = true;
					tvInfo.setText(String.valueOf(rawTallies.length));
				} else {
					String errMsg = "RpcError[get_last_tallies]: " + resInfo;
					Log.e(TAG, errMsg);
					tvInfo.setText(errMsg);
					showDialog(DIALOG_TALLIES_FAILED_KEY);
				}
			}
		});
		
		Object[] params = { RpcMethod.sessionKey, count, offset, };
		rpc.callReq(params);
    }

    private void reqMonTotal(){
		if (RpcMethod.sessionKey == null) return;

		RpcMethod rpc = new RpcMethod(client, "get_month_total", new RpcMethod.Callback() {
			public void callRes(Object result, int resCode, String resInfo) {
				if ((result != null) && (resCode == 0)){
					Object[] values = (Object[]) result;
					int t0Total = Integer.parseInt(values[0].toString());
					int t1Total = Integer.parseInt(values[1].toString());
					tvMonTotal.setText(String.format(totalStr, t0Total, t1Total));
				}else{
					String errMsg = "RpcError[get_month_total]: " + resInfo;
					Log.e(TAG, errMsg);
					tvInfo.setText(errMsg);
				}
			}
		});
		
		String month = (String) DateFormat.format("yyyy-MM", new Date());
		Object[] params = { RpcMethod.sessionKey, month, };
		rpc.callReq(params);
    }

    private void startLoginForResult(int action) {
		Intent intent = new Intent(this, LoginActivity.class);
    	Bundle bundle = new Bundle();
	    bundle.putInt(LoginActivity.LOGIN_ACTION_KEY, action);
	    intent.putExtras(bundle);
		startActivityForResult(intent, action);
    }

    private void startTallyForResult(int action, TallyHolder tally) {
		Intent intent = new Intent(this, TallyActivity.class);
    	Bundle bundle = new Bundle();
		switch (action) {
			case TallyActivity.TALLY_ACTION_ADD: {
		    	bundle.putInt(TallyActivity.TALLY_ACTION_KEY, TallyActivity.TALLY_ACTION_ADD);
				int userId = setting.getInt(SettingActivity.KEY_PREF_USERID, 0);
		    	bundle.putInt(TallyActivity.TALLY_USERID_KEY, userId);
				break;
			}
			case TallyActivity.TALLY_ACTION_EDIT: {
		    	bundle.putInt(TallyActivity.TALLY_ACTION_KEY, TallyActivity.TALLY_ACTION_EDIT);
		    	bundle.putInt(TallyActivity.TALLY_ID_KEY, tally.id);
		    	bundle.putInt(TallyActivity.TALLY_TYPEID_KEY, tally.typeId);
		    	bundle.putInt(TallyActivity.TALLY_SUBTYPEID_KEY, tally.subTypeId);
		    	bundle.putInt(TallyActivity.TALLY_AMOUNT_KEY, tally.amount);
		    	bundle.putInt(TallyActivity.TALLY_USERID_KEY, tally.userId);
		    	bundle.putString(TallyActivity.TALLY_DATE_KEY, tally.dateStr);
		    	bundle.putString(TallyActivity.TALLY_MEMO_KEY, tally.memo);
				break;
			}
		}
		intent.putExtras(bundle);
		startActivityForResult(intent, action);
    }

    private void startReportForResult() {
		Intent intent = new Intent();
		intent.setClass(this, ReportActivity.class);
		startActivityForResult(intent, ReportActivity.REPORT_ACTION_REPORT);
    }

    private void startSettingForResult() {
		Intent intent = new Intent();
		intent.setClass(this, SettingActivity.class);
		startActivityForResult(intent, SettingActivity.SETTING_ACTION_SET);
    }

    class TalliesAdapter extends ArrayAdapter<Object> {
		private LayoutInflater inflater;
        private Bitmap iconT0;
        private Bitmap iconT1;
		
		public TalliesAdapter(Context context) {
			super(context, 0);
			inflater = LayoutInflater.from(context);
            iconT0 = BitmapFactory.decodeResource(context.getResources(), R.drawable.t0);
            iconT1 = BitmapFactory.decodeResource(context.getResources(), R.drawable.t1);
		}
		
		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
            
			if ((position == tallies.getCount() - 1) && (isFirstTally == false)){
           		reqLastTallies(COUNT_REQ_MORE, tallies.getCount());
            }
			
			TallyHolder holder;
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.tally_item, null);

                holder = new TallyHolder();
                holder.ivType = (ImageView) convertView.findViewById(R.id.iv_icon_id);
                holder.tvSubType = (TextView) convertView.findViewById(R.id.tv_subtype_id);
                holder.tvAmount = (TextView) convertView.findViewById(R.id.tv_amount_id);
                holder.tvUser = (TextView) convertView.findViewById(R.id.tv_user_id);
                holder.tvDate = (TextView) convertView.findViewById(R.id.tv_date_id);
                holder.tvMemo = (TextView) convertView.findViewById(R.id.tv_memo_id);

                convertView.setTag(holder);
            } else {
                holder = (TallyHolder) convertView.getTag();
            }

        	Resources resources = getResources();
            String[] t0SubTypes = resources.getStringArray(R.array.t0_subtypes_arr);
        	String[] t1SubTypes = resources.getStringArray(R.array.t1_subtypes_arr);
        	String[] users = resources.getStringArray(R.array.users_arr);

        	Object[] item = (Object[]) (getItem(position));
        	holder.id = Integer.parseInt(item[0].toString());
        	holder.typeId = Integer.parseInt(item[1].toString());
        	holder.subTypeId = Integer.parseInt(item[2].toString());
        	holder.amount = Integer.parseInt(item[3].toString());
        	holder.userId = Integer.parseInt(item[4].toString());
        	holder.dateStr = item[5].toString();
        	holder.memo = Base64.decodeString(item[6].toString());

        	holder.ivType.setImageBitmap(holder.typeId == 0 ? iconT0 : iconT1);
        	holder.tvSubType.setText(holder.typeId == 0 ? t0SubTypes[holder.subTypeId] : t1SubTypes[holder.subTypeId]);
        	holder.tvAmount.setText(String.valueOf(holder.amount));
        	holder.tvUser.setText(users[holder.userId]);
        	holder.tvDate.setText(holder.dateStr);
        	holder.tvMemo.setText(holder.memo);

        	return convertView;
		}

	}
    
	class TallyHolder {
        int id;
		int typeId;
        int subTypeId;
        int amount;
        int userId;
        String dateStr;
        String memo;
        
		ImageView ivType;
        TextView tvSubType;
        TextView tvAmount;
        TextView tvUser;
        TextView tvDate;
        TextView tvMemo;
    }

}