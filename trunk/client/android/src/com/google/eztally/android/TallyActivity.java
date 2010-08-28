package com.google.eztally.android;

import java.util.Calendar;
import java.util.Date;

import org.xmlrpc.android.Base64;
import org.xmlrpc.android.XMLRPCClient;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.text.format.DateFormat;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.TextView;

public class TallyActivity extends Activity {
	private static final String TAG = "TallyActivity";

	public static final String TALLY_ACTION_KEY = "TALLY_ACTION";
	public static final int  TALLY_ACTION_ADD = 201;
	public static final int  TALLY_ACTION_EDIT = 202;

	public static final String TALLY_ID_KEY = "TALLY_ID";
	public static final String TALLY_TYPEID_KEY = "TALLY_TYPEID";
	public static final String TALLY_SUBTYPEID_KEY = "TALLY_SUBTYPEID";
	public static final String TALLY_AMOUNT_KEY = "TALLY_AMOUNT";
	public static final String TALLY_USERID_KEY = "TALLY_USERID";
	public static final String TALLY_DATE_KEY = "TALLY_DATE";
	public static final String TALLY_MEMO_KEY = "TALLY_MEMO";

	private static final int  DIALOG_SAVE_PROGRESS_KEY = 1;
	private static final int  DIALOG_DELETE_PROGRESS_KEY = 2;
	private static final int  DIALOG_SAVE_FAILED_KEY = 3;
	private static final int  DIALOG_DELETE_FAILED_KEY = 4;
	private static final int  DIALOG_DATEPICK_KEY = 5;
	
	private TextView tvInfo;
	private RadioGroup rgType;
	private Spinner spT0SubType, spT1SubType;
	private EditText etAmount;
	private Spinner spUser;
	private EditText etDate;
	private EditText etMemo;
	private Button btnSave;
	private Button btnDelete;

	private Bundle bundle;
	private int action;
	private XMLRPCClient client;
	

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tally);
        
		rgType = (RadioGroup) findViewById(R.id.tally_type_rg);
		spT0SubType = (Spinner) findViewById(R.id.tally_t0subtype_sp);
		spT1SubType = (Spinner) findViewById(R.id.tally_t1subtype_sp);
		etAmount = (EditText) findViewById(R.id.tally_amount_et);
		spUser = (Spinner) findViewById(R.id.tally_user_sp);
		etDate = (EditText) findViewById(R.id.tally_date_et);
		etMemo = (EditText) findViewById(R.id.tally_memo_et);
		
		tvInfo = (TextView) findViewById(R.id.tally_info_tv);
		tvInfo.setVisibility(View.GONE);

		btnSave = (Button) findViewById(R.id.tally_save_btn);
        btnDelete = (Button) findViewById(R.id.tally_delete_btn);

		ArrayAdapter<CharSequence> usersAdapter = 
			ArrayAdapter.createFromResource(this, 
					R.array.users_arr, android.R.layout.simple_spinner_item);
		usersAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spUser.setAdapter(usersAdapter);

		ArrayAdapter<CharSequence> t0SubTypesAdapter = 
			ArrayAdapter.createFromResource(this, 
					R.array.t0_subtypes_arr, android.R.layout.simple_spinner_item);
		t0SubTypesAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spT0SubType.setAdapter(t0SubTypesAdapter);

		ArrayAdapter<CharSequence> t1SubTypesAdapter = 
			ArrayAdapter.createFromResource(this, 
					R.array.t1_subtypes_arr, android.R.layout.simple_spinner_item);
		t1SubTypesAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spT1SubType.setAdapter(t1SubTypesAdapter);
		
		rgType.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
		    public void onCheckedChanged(RadioGroup group, int checkedId) {
		    	switch (checkedId) {
		    		case R.id.tally_t0_rb: {
		    			spT0SubType.setVisibility(View.VISIBLE);
		    			spT1SubType.setVisibility(View.GONE);
			    		break;
		    		}
		    		case R.id.tally_t1_rb: {
		    			spT0SubType.setVisibility(View.GONE);
		    			spT1SubType.setVisibility(View.VISIBLE);
			    		break;
		    		}
		    		default: {
		    			group.check(R.id.tally_t1_rb);
		    		}
		    	}
		    }
		});
				
		bundle = getIntent().getExtras();
		action = bundle.getInt(TALLY_ACTION_KEY);
		switch (action) {
			case TALLY_ACTION_ADD: {
				rgType.check(R.id.tally_t1_rb);
				spT1SubType.setSelection(0);
				etAmount.setText("");
				spUser.setSelection(bundle.getInt(TALLY_USERID_KEY));
				etDate.setText(DateFormat.format("yyyy-MM-dd", new Date()));
				etMemo.setText("");
				btnDelete.setVisibility(View.GONE);
				break;
			}
			case TALLY_ACTION_EDIT: {
				int typeId = bundle.getInt(TALLY_TYPEID_KEY);
				int subTypeId = bundle.getInt(TALLY_SUBTYPEID_KEY);
				if (typeId == 0) {
					rgType.check(R.id.tally_t0_rb);
					spT0SubType.setSelection(subTypeId);
				} else {
					rgType.check(R.id.tally_t1_rb);
					spT1SubType.setSelection(subTypeId);
				}
				etAmount.setText(String.valueOf(bundle.getInt(TALLY_AMOUNT_KEY)));
				spUser.setSelection(bundle.getInt(TALLY_USERID_KEY));
				etDate.setText(bundle.getString(TALLY_DATE_KEY));
				etMemo.setText(bundle.getString(TALLY_MEMO_KEY));
				btnDelete.setVisibility(View.VISIBLE);
				break;
			}
		}
		
        SharedPreferences setting = PreferenceManager.getDefaultSharedPreferences(this);
        String svcUrl = setting.getString(SettingActivity.KEY_SERVICE_URL, SettingActivity.DEFAULT_SVC_URL);
    	client = new XMLRPCClient(svcUrl);
        
        etDate.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		showDialog(DIALOG_DATEPICK_KEY);
        	}
        });
        
		btnSave.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		switch (action) {
	    			case TALLY_ACTION_ADD: {
	    				addTally();
	    				break;
	    			}
	    			case TALLY_ACTION_EDIT: {
	            		saveTally();
	    				break;
	    			}
    			}
        	}
        });
        
        btnDelete.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		if (action == TALLY_ACTION_EDIT) deleteTally();
        	}
        });
    }
    
    @Override
    protected Dialog onCreateDialog(int id) {
    	switch (id) {
	    	case DIALOG_SAVE_PROGRESS_KEY: {
		    	ProgressDialog dialog = new ProgressDialog(this);
		    	dialog.setIndeterminate(true);
	    		dialog.setCancelable(false);
	    		dialog.setMessage(getResources().getText(R.string.tally_save_progress));
	    		return dialog;
	    	}
	    	case DIALOG_DELETE_PROGRESS_KEY: {
		    	ProgressDialog dialog = new ProgressDialog(this);
		        dialog.setIndeterminate(true);
		        dialog.setCancelable(false);
			    dialog.setMessage(getResources().getText(R.string.tally_delete_progress));
		        return dialog;
	    	}
	    	case DIALOG_SAVE_FAILED_KEY: {
	    		AlertDialog dialog = new AlertDialog.Builder(this)
            		.setMessage(R.string.tally_save_failed).create();
		        return dialog;
	    	}
	    	case DIALOG_DELETE_FAILED_KEY: {
	    		AlertDialog dialog = new AlertDialog.Builder(this)
	            	.setMessage(R.string.tally_delete_failed).create();
		        return dialog;
	    	}
            case DIALOG_DATEPICK_KEY: {
           		String dateStr = etDate.getText().toString();
           		int year = Integer.parseInt(dateStr.substring(0, 4));
           		int month = Integer.parseInt(dateStr.substring(5, 7)) - 1;
           		int day = Integer.parseInt(dateStr.substring(8, 10));
                return new DatePickerDialog(this,
                	new DatePickerDialog.OnDateSetListener() {
                		public void onDateSet(DatePicker view, int year, int month, int day) {
                        	final Calendar c = Calendar.getInstance();
                			c.set(year, month, day);
                			etDate.setText(DateFormat.format("yyyy-MM-dd", c.getTime()));
                		}
                	}, year, month, day);
            }
	    	default: return null;
    	}
    }

    private void addTally() {
		showDialog(DIALOG_SAVE_PROGRESS_KEY);

		RpcMethod rpc = new RpcMethod(client, "add_tally", new RpcMethod.Callback() {
			public void callRes(Object result, int resCode, String resInfo) {
				dismissDialog(DIALOG_SAVE_PROGRESS_KEY);
				
				if (resCode == 0) {
					setResult(RESULT_OK);
					finish();
				} else {
					String errMsg = "RpcError[add_tally]: " + resInfo;
					Log.e(TAG, errMsg);
					tvInfo.setText(errMsg);
					showDialog(DIALOG_SAVE_FAILED_KEY);
				}
			}
		});
		
		int typeId = (rgType.getCheckedRadioButtonId() == R.id.tally_t0_rb) ? 0 : 1;
		int subTypeId = (typeId == 0) ? spT0SubType.getSelectedItemPosition() : spT1SubType.getSelectedItemPosition();
		int amount = 0;
		if (etAmount.getText().length() > 0) {
			amount = Integer.parseInt( etAmount.getText().toString());
		}
		int userId = spUser.getSelectedItemPosition();
		String dateStr = etDate.getText().toString();
		String memo = etMemo.getText().toString();
		
		Object[] params = { RpcMethod.sessionKey, 
				typeId, subTypeId, amount, userId, dateStr, Base64.encodeString(memo), };
		rpc.callReq(params);
    }
    
    private void saveTally() {
		showDialog(DIALOG_SAVE_PROGRESS_KEY);

		RpcMethod rpc = new RpcMethod(client, "save_tally", new RpcMethod.Callback() {
			public void callRes(Object result, int resCode, String resInfo) {
				dismissDialog(DIALOG_SAVE_PROGRESS_KEY);
				
				if (resCode == 0) {
					setResult(RESULT_OK);
					finish();
				} else {
					String errMsg = "RpcError[save_tally]: " + resInfo;
					Log.e(TAG, errMsg);
					tvInfo.setText(errMsg);
					showDialog(DIALOG_SAVE_FAILED_KEY);
				}
			}
		});
		
		int id = bundle.getInt(TALLY_ID_KEY);
		int typeId = (rgType.getCheckedRadioButtonId() == R.id.tally_t0_rb) ? 0 : 1;
		int subTypeId = (typeId == 0) ? spT0SubType.getSelectedItemPosition() : spT1SubType.getSelectedItemPosition();
		int amount = 0;
		if (etAmount.getText().length() > 0) {
			amount = Integer.parseInt( etAmount.getText().toString());
		}
		int userId = spUser.getSelectedItemPosition();
		String dateStr = etDate.getText().toString();
		String memo = etMemo.getText().toString();
		
		Object[] params = { RpcMethod.sessionKey, id,
				typeId, subTypeId, amount, userId, dateStr, Base64.encodeString(memo), };
		rpc.callReq(params);
    }
    
    private void deleteTally() {
		showDialog(DIALOG_DELETE_PROGRESS_KEY);

		RpcMethod rpc = new RpcMethod(client, "del_tally", new RpcMethod.Callback() {
			public void callRes(Object result, int resCode, String resInfo) {
				dismissDialog(DIALOG_DELETE_PROGRESS_KEY);
				
				if (resCode == 0) {
					setResult(RESULT_OK);
					finish();
				} else {
					String errMsg = "RpcError[del_tally]: " + resInfo;
					Log.e(TAG, errMsg);
					tvInfo.setText(errMsg);
					showDialog(DIALOG_DELETE_FAILED_KEY);
				}
			}
		});
		
		Object[] params = { RpcMethod.sessionKey, bundle.getInt(TALLY_ID_KEY), };
		rpc.callReq(params);
    }
    
}