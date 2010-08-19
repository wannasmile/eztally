package com.google.eztally.android;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

import org.achartengine.ChartFactory;
import org.achartengine.chart.BarChart.Type;
import org.achartengine.model.CategorySeries;
import org.achartengine.model.XYMultipleSeriesDataset;
import org.achartengine.renderer.DefaultRenderer;
import org.achartengine.renderer.SimpleSeriesRenderer;
import org.achartengine.renderer.XYMultipleSeriesRenderer;
import org.xmlrpc.android.XMLRPCClient;

import com.commonsware.cwac.merge.MergeAdapter;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.graphics.Color;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.text.format.DateFormat;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Spinner;
import android.widget.TextView;

public class ReportActivity extends Activity {
	private static final String TAG = "ReportActivity";

	public static final int  REPORT_ACTION_REPORT = 401;

	private static final int  DIALOG_REPORT_PROGRESS_KEY = 1;
	private static final int  DIALOG_QUERY_FAILED_KEY = 2;

	private static final int  REPORT_T0CAT_KEY = 0;
	private static final int  REPORT_T1CAT_KEY = 1;
	private static final int  REPORT_MONTH_KEY = 2;

	private Spinner spPeriod;
	private ListView lvReports;
	private TextView tvTotal;
	
	private SharedPreferences setting;
	private XMLRPCClient client;
	private TextView tvT0Cat, tvT1Cat, tvMonth; 
	private ReportAdapter t0CatReport, t1CatReport, monthReport;
	private int t0Amount, t1Amount, balance;
	private String totalStr;
	private int minAmount, maxAmount;
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.report);
        
		spPeriod = (Spinner) findViewById(R.id.report_period_sp);
		lvReports = (ListView) findViewById(R.id.report_reports_lv);
		tvTotal = (TextView) findViewById(R.id.report_total_tv);
		totalStr = String.valueOf(getResources().getText(R.string.report_total_tv));
		tvTotal.setText(String.format(totalStr, 0, 0, 0));
        
		tvT0Cat = new TextView(this);
		tvT0Cat.setText(R.string.report_t0cat_tv);
		tvT0Cat.setBackgroundColor(Color.GRAY);
		tvT1Cat = new TextView(this);
		tvT1Cat.setText(R.string.report_t1cat_tv);
		tvT1Cat.setBackgroundColor(Color.GRAY);
		tvMonth = new TextView(this);
		tvMonth.setText(R.string.report_month_tv);
		tvMonth.setBackgroundColor(Color.GRAY);
		
		t0CatReport = new ReportAdapter(this, REPORT_T0CAT_KEY);
		t1CatReport = new ReportAdapter(this, REPORT_T1CAT_KEY);
		monthReport = new ReportAdapter(this, REPORT_MONTH_KEY);

		setting = PreferenceManager.getDefaultSharedPreferences(this);
        String svcUrl = setting.getString(SettingActivity.KEY_SERVICE_URL, SettingActivity.DEFAULT_SVC_URL);
    	client = new XMLRPCClient(svcUrl);
    	
		ArrayAdapter<CharSequence> periodAdapter = ArrayAdapter
			.createFromResource(this, R.array.report_period_arr, android.R.layout.simple_spinner_item);
		periodAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spPeriod.setAdapter(periodAdapter);
		spPeriod.setOnItemSelectedListener(new Spinner.OnItemSelectedListener() {
			@Override
			public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
            	final Calendar c = Calendar.getInstance();
		    	switch (position) {
		    		case 0: { //本月
		    			String fromMonth = (String) DateFormat.format("yyyy-MM", c.getTime());
		    			String toMonth = fromMonth;
						reqReport(fromMonth, toMonth);
		    			break;
		    		}
		    		case 1: { //今年
		    			String toMonth = (String) DateFormat.format("yyyy-MM", c.getTime());
		    			c.set(Calendar.MONTH, 0);
		    			String fromMonth = (String) DateFormat.format("yyyy-MM", c.getTime());
						reqReport(fromMonth, toMonth);
		    			break;
		    		}
		    		case 2: { //上月
		    			c.add(Calendar.MONTH, -1);
		    			String fromMonth = (String) DateFormat.format("yyyy-MM", c.getTime());
		    			String toMonth = fromMonth;
						reqReport(fromMonth, toMonth);
		    			break;
		    		}
		    		case 3: { //去年
		    			c.add(Calendar.YEAR, -1);
		    			c.set(Calendar.MONTH, 0);
		    			String fromMonth = (String) DateFormat.format("yyyy-MM", c.getTime());
		    			c.set(Calendar.MONTH, 11);
		    			String toMonth = (String) DateFormat.format("yyyy-MM", c.getTime());
						reqReport(fromMonth, toMonth);
		    			break;
		    		}
		    	}
			}
			@Override
			public void onNothingSelected(AdapterView<?> parent) {
			}
		});
	
		Button btnT0Cat = (Button) findViewById(R.id.report_t0cat_btn);
		btnT0Cat.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		DefaultRenderer renderer = new DefaultRenderer();
        	    for (int i = 0; i < t0CatReport.getCount(); i++) {
            		SimpleSeriesRenderer r = new SimpleSeriesRenderer();
            	    r.setColor(RandomColor());
            	    renderer.addSeriesRenderer(r);
        	    }
        	    Intent intent = ChartFactory.getPieChartIntent(ReportActivity.this, getT0CatReportDataset(), renderer);
        		startActivity(intent);
        	}
        });
        
		Button btnT1Cat = (Button) findViewById(R.id.report_t1cat_btn);
		btnT1Cat.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		DefaultRenderer renderer = new DefaultRenderer();
        	    for (int i = 0; i < t1CatReport.getCount(); i++) {
            		SimpleSeriesRenderer r = new SimpleSeriesRenderer();
            	    r.setColor(RandomColor());
            	    renderer.addSeriesRenderer(r);
        	    }
        	    Intent intent = ChartFactory.getPieChartIntent(ReportActivity.this, getT1CatReportDataset(), renderer);
        		startActivity(intent);
        	}
        });
        
		Button btnMonth = (Button) findViewById(R.id.report_month_btn);
		btnMonth.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        	    XYMultipleSeriesRenderer renderer = new XYMultipleSeriesRenderer();
        	    SimpleSeriesRenderer r = new SimpleSeriesRenderer();
        	    r.setColor(Color.RED);
        	    renderer.addSeriesRenderer(r);
        	    r = new SimpleSeriesRenderer();
        	    r.setColor(Color.GREEN);
        	    renderer.addSeriesRenderer(r);
        	    r = new SimpleSeriesRenderer();
        	    r.setColor(Color.YELLOW);
        	    renderer.addSeriesRenderer(r);

            	Resources resources = getResources();
        	    renderer.setChartTitle(resources.getString(R.string.report_month_chart_title));
        	    renderer.setXTitle(resources.getString(R.string.report_month_chart_x));
        	    renderer.setYTitle(resources.getString(R.string.report_month_chart_y));
        	    renderer.setDisplayChartValues(true);
        	    int count = monthReport.getCount();
        	    renderer.setXLabels(count);
        	    renderer.setXAxisMin(0.5);
        	    renderer.setXAxisMax(count + 0.5);
        	    //renderer.setYAxisMin(minAmount);
        	    //renderer.setYAxisMax(maxAmount);
        	    for (int i = 0; i < monthReport.getCount(); i++) {
                	ReportItem item = (ReportItem) monthReport.getItem(i);
        	    	renderer.addTextLabel(i+1, item.month);
        	    }

        	    Intent intent = ChartFactory.getBarChartIntent(ReportActivity.this, getMonthReportDataset(), renderer, Type.DEFAULT);
        		startActivity(intent);
        	}
        });
        
    }

    @Override
    protected Dialog onCreateDialog(int id) {
    	switch (id) {
	    	case DIALOG_REPORT_PROGRESS_KEY: {
		    	ProgressDialog dialog = new ProgressDialog(this);
		    	dialog.setIndeterminate(true);
	    		dialog.setCancelable(false);
	    		dialog.setMessage(getResources().getText(R.string.report_query_progress));
	    		return dialog;
	    	}
	    	case DIALOG_QUERY_FAILED_KEY: {
	    		AlertDialog dialog = new AlertDialog.Builder(this)
            		.setMessage(R.string.report_query_failed).create();
		        return dialog;
	    	}
	        default: return null;
    	}
    }

    private int RandomColor() {
    	Random random = new Random();
    	int r = random.nextInt(255) + 1;
    	int g = random.nextInt(255) + 1;
    	int b = random.nextInt(255) + 1;
    	return Color.rgb(r, g, b);
    }
    
    private CategorySeries getT0CatReportDataset() {
    	Resources resources = getResources();
        CategorySeries t0CatSeries = new CategorySeries(resources.getString(R.string.report_t0cat_chart_t0));
        String[] t0SubTypes = resources.getStringArray(R.array.t0_subtypes_arr);
        for (int i = 0; i < t0CatReport.getCount(); i++) {
        	Object[] item = (Object[]) t0CatReport.getItem(i);
        	String subType = t0SubTypes[Integer.parseInt(item[0].toString())];
        	int amount = Integer.parseInt(item[1].toString());
        	t0CatSeries.add(subType, amount);
        }
        return t0CatSeries;
    }

    private CategorySeries getT1CatReportDataset() {
    	Resources resources = getResources();
        CategorySeries t1CatSeries = new CategorySeries(resources.getString(R.string.report_t1cat_chart_t1));
        String[] t1SubTypes = resources.getStringArray(R.array.t1_subtypes_arr);
        for (int i = 0; i < t1CatReport.getCount(); i++) {
        	Object[] item = (Object[]) t1CatReport.getItem(i);
        	String subType = t1SubTypes[Integer.parseInt(item[0].toString())];
        	int amount = Integer.parseInt(item[1].toString());
        	t1CatSeries.add(subType, amount);
        }
        return t1CatSeries;
    }

    private XYMultipleSeriesDataset getMonthReportDataset() {
    	minAmount = 0;
    	maxAmount = 0;
    	XYMultipleSeriesDataset dataset = new XYMultipleSeriesDataset();
    	Resources resources = getResources();
        CategorySeries t0Series = new CategorySeries(resources.getString(R.string.report_month_chart_t0));
        CategorySeries t1Series = new CategorySeries(resources.getString(R.string.report_month_chart_t1));
        CategorySeries balanceSeries = new CategorySeries(resources.getString(R.string.report_month_chart_balance));
        for (int i = 0; i < monthReport.getCount(); i++) {
        	ReportItem item = (ReportItem) monthReport.getItem(i);
        	t0Series.add(item.t0Amount);
        	t1Series.add(item.t1Amount);
        	int balance = item.t0Amount - item.t1Amount;
        	balanceSeries.add(balance);
        	maxAmount =  (item.t0Amount > maxAmount) ? item.t0Amount : maxAmount; 
        	maxAmount =  (item.t1Amount > maxAmount) ? item.t1Amount : maxAmount; 
        	minAmount =  (balance < minAmount) ? balance : minAmount; 
        }
        dataset.addSeries(t0Series.toXYSeries());
        dataset.addSeries(t1Series.toXYSeries());
        dataset.addSeries(balanceSeries.toXYSeries());

        return dataset;
    }

    private void reqReport(String fromMonth, String toMonth) {
		if (RpcMethod.sessionKey == null) return;
		showDialog(DIALOG_REPORT_PROGRESS_KEY);
		t0CatReport.clear();
		t1CatReport.clear();
		monthReport.clear();
		
		RpcMethod rpc = new RpcMethod(client, "get_stat_report", new RpcMethod.Callback() {
			public void callRes(Object result, int resCode,	String resInfo) {
				dismissDialog(DIALOG_REPORT_PROGRESS_KEY);
				
				if ((result != null) && (resCode == 0)){
					Object[] reports = (Object[]) result;
					Object[] report0 = (Object[]) reports[0];
					Object[] report1 = (Object[]) reports[1];
					Object[] report2 = (Object[]) reports[2];
					Object[] report3 = (Object[]) reports[3];
					
					for (int i = 0; i < report0.length; i++) {
						t0CatReport.add(report0[i]);
					}
					for (int i = 0; i < report1.length; i++) {
						t1CatReport.add(report1[i]);
					}
					
					Map<String, ReportItem> map = new HashMap<String, ReportItem>(); 
					for (int i = 0; i < report2.length-1; i++) {
						Object[] item = (Object[]) (report2[i]);
						String month = item[0].toString();
						int amount = Integer.parseInt(item[1].toString());
						ReportItem itemVal = new ReportItem(month, amount, 0); 
						map.put(month, itemVal);
					}
					for (int i = 0; i < report3.length-1; i++) {
						Object[] item = (Object[]) (report3[i]);
						String month = item[0].toString();
						int amount = Integer.parseInt(item[1].toString());
						if (map.keySet().contains(month)) {
							map.get(month).t1Amount = amount;
						} else {
							ReportItem itemVal = new ReportItem(month, 0, amount); 
							map.put(month, itemVal);
						}
					}
					List<Map.Entry<String, ReportItem>> report = 
						new ArrayList<Map.Entry<String, ReportItem>>(map.entrySet()); 
					Collections.sort(report, new Comparator<Map.Entry<String, ReportItem>>() {
						public int compare(Map.Entry<String, ReportItem> o1, Map.Entry<String, ReportItem> o2) {
							return (o1.getKey().toString().compareTo(o2.getKey().toString()));
						}
					}); 
					for (int i=0; i<report.size(); i++) {
						monthReport.add(report.get(i).getValue());
					}

					MergeAdapter maReports = new MergeAdapter();
					maReports.addView(tvMonth);
					maReports.addAdapter(monthReport);
					maReports.addView(tvT0Cat);
					maReports.addAdapter(t0CatReport);
					maReports.addView(tvT1Cat);
					maReports.addAdapter(t1CatReport);
					lvReports.setAdapter(maReports);
										
					Object[] t0Item = (Object[]) (report2[report2.length-1]);
					Object[] t1Item = (Object[]) (report3[report3.length-1]);
					t0Amount = Integer.parseInt(t0Item[1].toString());
					t1Amount = Integer.parseInt(t1Item[1].toString());
					balance = t0Amount - t1Amount;
					tvTotal.setText(String.format(totalStr, t0Amount, t1Amount, balance));
				} else {
					String errMsg = "RpcError[get_stat_report]: " + resInfo;
					Log.e(TAG, errMsg);
					//tvTotal.setText("RpcError[get_stat_report]: " + resInfo);
					showDialog(DIALOG_QUERY_FAILED_KEY);
				}
			}
		});

		Object[] params = { RpcMethod.sessionKey, fromMonth, toMonth, -1, };
		rpc.callReq(params);
	}

    class ReportAdapter extends ArrayAdapter<Object> {
		private LayoutInflater inflater;
		private int reportId;
		
		public ReportAdapter(Context context, int reportId) {
			super(context, 0);
			inflater = LayoutInflater.from(context);
			this.reportId = reportId;
		}
		
		@Override
		public View getView(int position, View view, ViewGroup parent) {
            
			ReportHolder holder;
            if (view == null) {
            	view = inflater.inflate(R.layout.report_item, null);

                holder = new ReportHolder();
                holder.tvSubItem1 = (TextView) view.findViewById(R.id.report_subitem1_tv);
                holder.tvSubItem2 = (TextView) view.findViewById(R.id.report_subitem2_tv);
                holder.tvSubItem3 = (TextView) view.findViewById(R.id.report_subitem3_tv);
                holder.tvSubItem4 = (TextView) view.findViewById(R.id.report_subitem4_tv);

                view.setTag(holder);
            } else {
                holder = (ReportHolder) view.getTag();
            }

        	Resources resources = getResources();
            String[] t0SubTypes = resources.getStringArray(R.array.t0_subtypes_arr);
        	String[] t1SubTypes = resources.getStringArray(R.array.t1_subtypes_arr);
        	
        	switch (reportId) {
	    		case REPORT_T0CAT_KEY: {
	            	Object[] item = (Object[]) (getItem(position));
		        	holder.tvSubItem1.setText(t0SubTypes[Integer.parseInt(item[0].toString())]);
		        	holder.tvSubItem2.setText(item[1].toString());
		        	double percent = 0;
		        	if (t0Amount != 0) percent = 100 * Integer.parseInt(item[1].toString())/t0Amount;
		        	holder.tvSubItem3.setText(String.format("%.1f%%", percent));
		        	holder.tvSubItem4.setVisibility(View.GONE);
		        	break;
	    		}
	    		case REPORT_T1CAT_KEY: {
	            	Object[] item = (Object[]) (getItem(position));
		        	holder.tvSubItem1.setText(t1SubTypes[Integer.parseInt(item[0].toString())]);
		        	holder.tvSubItem2.setText(item[1].toString());
		        	double percent = 0;
		        	if (t1Amount != 0) percent = 100 * Integer.parseInt(item[1].toString())/t1Amount;
		        	holder.tvSubItem3.setText(String.format("%.1f%%", percent));
		        	holder.tvSubItem4.setVisibility(View.GONE);
		        	break;
	    		}
	    		case REPORT_MONTH_KEY: {
	            	ReportItem item = (ReportItem) (getItem(position));
		        	holder.tvSubItem1.setText(item.month);
		        	holder.tvSubItem2.setText(String.valueOf(item.t0Amount));
		        	holder.tvSubItem3.setText(String.valueOf(item.t1Amount));
		        	holder.tvSubItem4.setText(String.valueOf(item.t0Amount - item.t1Amount));
		        	break;
	    		}
        	}

        	return view;
		}

	}
    
	class ReportHolder {
        TextView tvSubItem1;
        TextView tvSubItem2;
        TextView tvSubItem3;
        TextView tvSubItem4;
    }

	class ReportItem {
		String month;
		int t0Amount;
		int t1Amount;
		
		public ReportItem(String month, int t0Amount, int t1Amount) {
			this.month = month;
			this.t0Amount = t0Amount;
			this.t1Amount = t1Amount;
		}
	}
}