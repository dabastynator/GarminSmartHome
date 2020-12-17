using Toybox.WatchUi;
using Toybox.System;
using Toybox.Application.Properties;

class MenuDelegate extends WatchUi.MenuInputDelegate {

	var mCaller = null;

    function initialize()
    {
        MenuInputDelegate.initialize();
        mCaller = new WebCaller();
    }
    
	function onReceive(responseCode, data)
	{
		System.println("onReceive");
		System.println(" " + responseCode + " " + data);
	}

    function onMenuItem(item)
    {
    	var trigger = "";
    	if (item == :come_home)
		{
			trigger = "mobile.come_home";
		}
		if (item == :leaving)
		{
			trigger = "mobile.leaving";
		}
		if (item == :bedroom)
		{
			trigger = "mobile.bedroom";
		}
		if (item == :go_to_bed)
		{
			trigger = "mobile.go_to_bed";
		}
		if (item == :mobile_jazz)
		{
			trigger = "trigger.mobile_jazz";
		}
		mCaller.call("/trigger/dotrigger", "trigger=" + trigger, null);
    }

}