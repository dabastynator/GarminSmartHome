using Toybox.WatchUi;

class MusicDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
        System.println("Init MusicDelegate");
    }

    
    function onKey(event) {
    	System.println("on key: " + event);
    	if (event.mKey == 4)
    	{
    		
    	}
    	if (event.mKey == 5)
    	{
    		
    	}
    }
    
    function onTap (event) {
	    System.println("on tap: " + event);
	    
    }

}