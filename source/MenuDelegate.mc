using Toybox.WatchUi;
using Toybox.System;

class MenuDelegate extends WatchUi.MenuInputDelegate {

	const URL = "http://localhost:5061/";
	
	const TOKEN = "w4kzd4HQ";

    function initialize() {
        MenuInputDelegate.initialize();
    }
    
	function onReceive(responseCode, data) {
		System.println("onReceive");
		System.println(" " + responseCode + " " + data);
	}

    function onMenuItem(item) {
    	var trigger = "";
    	if (item == :item_1) {
            trigger = "mobile.come_home";
        } else if (item == :item_2) {
            trigger = "mobile.leaving";
        }
    
		var url = URL + "trigger/dotrigger?token=" + TOKEN + "&trigger=" + trigger;
		var params = null;
		var options = {
			:method => Communications.HTTP_REQUEST_METHOD_GET,
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
		};
		System.println("Call: " + url);
		Communications.makeWebRequest(url, params, options, method(:onReceive));
    }

}