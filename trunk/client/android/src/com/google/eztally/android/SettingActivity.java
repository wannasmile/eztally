package com.google.eztally.android;

import android.os.Bundle;
import android.preference.PreferenceActivity;

public class SettingActivity extends PreferenceActivity {

	public static final int SETTING_ACTION_SET = 301;

	public static final String DEFAULT_SVC_URL = "http://eztally.appspot.com";
	public static final String KEY_SERVICE_URL = "setting_service_url";
	public static final String KEY_PREF_USERID = "setting_pref_userid";
	public static final String KEY_PREF_PASSWD = "setting_pref_passwd";
	public static final String KEY_AUTO_LOGIN  = "setting_auto_login";
	
	@Override
	protected void onCreate(Bundle icicle) {
		super.onCreate(icicle);
		addPreferencesFromResource(R.xml.setting);
	}
	
}
