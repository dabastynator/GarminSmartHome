using Toybox.Application.Properties;

class WebCaller {

	var mUrl = "";	
	var mToken = "";
	var mDefaultParam = "";
	
	function initialize()
	{
        mUrl = Properties.getValue("endpoint");
		mToken = Properties.getValue("token");
		mDefaultParam = "?token=" + mToken;
		System.println("Read properties:");
		System.println(" Url: " + mUrl);
		System.println(" Token: " + mToken);
    }
    
    function setDefaultParameter(parameter)
    {
    	mDefaultParam = "?token=" + mToken + "&" + parameter;
    }
    
	function onReceive(responseCode, data)
	{
		System.println("WebCaller::onReceive: " + responseCode);
	}
    
    function call(path, parameter, callback)
    {
    	var url = mUrl + path + mDefaultParam + "&" + parameter;
		var params = null;
		var options = {
			:method => Communications.HTTP_REQUEST_METHOD_GET,
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
		};
		if (callback == null) {
			callback = method(:onReceive);
		}
		System.println("Call: " + url);		
		Communications.makeWebRequest(url, params, options, callback);
    }
	
}