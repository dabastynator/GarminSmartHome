using Toybox.WatchUi;
using Toybox.Application.Properties;

class SwitchDelegate extends WatchUi.Menu2InputDelegate {

	var mCaller = null;

	function initialize()
	{
		Menu2InputDelegate.initialize();
		mCaller = new WebCaller();
	}
	
	function onSelect(item)
	{
		var state = "OFF";
		if (item.isEnabled())
		{
			state = "ON";
		}
		mCaller.call("/switch/set", "id=" + item.getId() + "&state=" + state, null);
	}

}