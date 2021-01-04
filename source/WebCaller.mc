using Toybox.Application.Properties;

class WebCaller {

	var mUrl = "";	
	var mToken = "";
	var mDefaultParam = "";
	var mParameter = null;
	var mCallback = null;
	
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
		if (data instanceof Dictionary)
		{
			var error = data["error"]; 
			if (error  instanceof Dictionary)
			{
				var alert = new Alert({
					:timeout => 5000,
					:font => Graphics.FONT_MEDIUM,
					:text => error["message"],
					:fgcolor => Graphics.COLOR_RED,
					:bgcolor => Graphics.COLOR_BLACK
					});
				alert.pushView(WatchUi.SLIDE_UP);
				return;
			}
		}
		if (mCallback != null)
		{
			mCallback.invoke(responseCode, data);
		}
	}
	
	function setParameter(parameter)
	{
		mParameter = parameter;
	}
	
	function call(path, parameter, callback)
	{
		var url = mUrl + path + mDefaultParam + "&" + parameter;
		var options = {
			:method => Communications.HTTP_REQUEST_METHOD_GET,
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
		};
		mCallback = callback;		
		System.println("Call: " + url);		
		Communications.makeWebRequest(url, mParameter, options, method(:onReceive));
	}
	
}