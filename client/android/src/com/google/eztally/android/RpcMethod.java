package com.google.eztally.android;

import org.xmlrpc.android.XMLRPCClient;

import android.os.Handler;

public class RpcMethod extends Thread {

	interface Callback {
		void callRes(Object result, int resCode, String resInfo);
	}

	private XMLRPCClient client;
	private String method;
	private Object[] params;
	private Handler handler;
	private Callback callback;

	public static String sessionKey;
	public static String serviceUrl = SettingActivity.DEFAULT_SVC_URL;

	public RpcMethod(XMLRPCClient client, String method, Callback callback) {
		this.client = client;
		this.method = method;
		this.callback = callback;
		handler = new Handler();
		serviceUrl = client.getUrl();
	}

	public void callReq(Object[] params) {
		this.params = params;
		start();
	}

	public void callReq() {
		callReq(null);
	}

	@Override
	public void run() {
		try {
			final Object result = client.callEx(method, params);
			handler.post(new Runnable() {
				public void run() {
					try {
						callback.callRes(result, 0, "RpcMethod done.");
					} catch (final Exception e) {
						//Do nothing!
					}
				}
			});
		} catch (final Exception e) {
			handler.post(new Runnable() {
				public void run() {
					callback.callRes(null, 1, e.toString());
				}
			});
		}
	}
}
