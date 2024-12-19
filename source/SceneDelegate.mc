using Toybox.WatchUi;
using Toybox.Application.Properties;

class SceneDelegate extends WatchUi.Menu2InputDelegate {

	var mCaller = null;

	function initialize()
	{
		Menu2InputDelegate.initialize();
		mCaller = new WebCaller();
	}
	
	function onSelect(item)
	{
		var state = "ON";
		mCaller.call("/scene/activate", "id=" + item.getId() + "&state=" + state, null);
	}

}