using Toybox.WatchUi;

class MainDelegate extends WatchUi.BehaviorDelegate {

    function initialize(view) {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
    
    function onKey(event) {
    	System.println("on key: " + event);
    	if (event.getKey() == WatchUi.KEY_ENTER)
    	{
    		WatchUi.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(), WatchUi.SLIDE_UP);
    	}
    	if (event.getKey() == WatchUi.KEY_ESC)
    	{
    		WatchUi.pushView(new MusicView(), new MusicDelegate(), WatchUi.SLIDE_UP);
    	}
    }
    
    function onTap (event) {
    	var coords = event.getCoordinates();
	    if (coords[1] > MainView.Height / 2)
	    {
	    	if (coords[0] < MainView.Width / 2)
	    	{
	    		WatchUi.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(), WatchUi.SLIDE_UP);
	    	} else {
	    		WatchUi.pushView(new MusicView(), new MusicDelegate(), WatchUi.SLIDE_UP);
	    	}
	    }
    }

}