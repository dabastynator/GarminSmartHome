using Toybox.Application.Properties;

class WebCaller {

	var mUrl = "";	
	var mToken = "";
	var mDefaultParam = "";
	
	function initialize() {
        mUrl = Properties.getValue("endpoint");
		mToken = Properties.getValue("token");
		mDefaultParam = "?token=" + mToken;
		System.println("Read properties:");
		System.println(" Url: " + mUrl);
		System.println(" Token: " + mToken);
    }
    
    function setDefaultParameter(parameter) {
    	mDefaultParam = "?token=" + mToken + "&" + parameter;
    }
    
	function onReceive(responseCode, data) {
		System.println("onReceive");
		System.println(" " + responseCode + " " + data);
	}
    
    function call(path, parameter) {
    	var url = mUrl + path + mDefaultParam + "&" + parameter;
		var params = null;
		var options = {
			:method => Communications.HTTP_REQUEST_METHOD_GET,
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
		};
		System.println("Call: " + url);
		Communications.makeWebRequest(url, params, options, method(:onReceive));
    }
	
}