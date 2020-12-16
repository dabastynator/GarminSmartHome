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
    	if (item == :item_1)
    	{
            trigger = "mobile.come_home";
        } else if (item == :item_2)
        {
            trigger = "mobile.leaving";
        }
		mCaller.call("/trigger/dotrigger", "trigger=" + trigger, null);
    }

}