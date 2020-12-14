using Toybox.WatchUi;
using Toybox.Application.Properties;

class MusicDelegate extends WatchUi.BehaviorDelegate {

	var mCaller = null;

    function initialize() {
        BehaviorDelegate.initialize();
        mCaller = new WebCaller();
        var music = Properties.getValue("musicunit");
        mCaller.setDefaultParameter("player=mplayer&id=" + music);
    }
    
    function onTap (event) {
	    var coords = event.getCoordinates();
	    if (coords[1] < MainView.Height / 3)
	    {
	    	if (coords[0] < MainView.Width / 2)
	    	{
	    		//mCaller.call("/mediaserver/volup", "");
	    	} else
	    	{
	    		//mCaller.call("/mediaserver/next", "");
	    	}	    	
	    } else if (coords[1] < 2 * MainView.Height / 3)
	    {
	    	if (coords[0] < MainView.Width / 3)
	    	{
	    		mCaller.call("/mediaserver/stop", "");
	    	} else if (coords[0] < 2 * MainView.Width / 3)
	    	{
	    		mCaller.call("/mediaserver/play_pause", "");
	    	} else
	    	{
	    		mCaller.call("/mediaserver/next", "");
	    	}
	    }
    }

}