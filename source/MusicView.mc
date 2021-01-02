using Toybox.WatchUi;

class MusicView extends WatchUi.View {

	var mMarqueeArtist;
	var mMarqueeTitle;
	var mPlay;
    var mFireAnimation = true;
    
    function initialize()
    {
    	var marginTitle = 0.154 * CircleButtonView.Width;
    	var marginArtist = 0.038 * CircleButtonView.Width;
    	mMarqueeTitle = new MarqueeLabel(marginTitle, CircleButtonView.Width - marginTitle);
    	mMarqueeArtist = new MarqueeLabel(marginArtist, CircleButtonView.Width - marginArtist);
    	mMarqueeTitle.updateText("<loading>");
    	mMarqueeArtist.updateText("<loading>");
        View.initialize();        
    }

    // Load your resources here
    function onLayout(dc)
    {
    	var layout = Rez.Layouts.Player(dc);
    	mMarqueeTitle.setLabel(layout[0]);
    	mMarqueeArtist.setLabel(layout[1]);
    	mPlay = layout[5];
        setLayout(layout);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow()
    {
    }

    // Update the view
    function onUpdate(dc)
    {
    	// Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        mMarqueeArtist.calculateWidth(dc);
        mMarqueeTitle.calculateWidth(dc);
        if (mFireAnimation)
        {
	        mMarqueeArtist.animate();
        	mMarqueeTitle.animate();
		    mFireAnimation = false;
	    }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }    
    
    function onUpdateMusic(code, data)
    {
    	var artist = "---";
    	var title = "---";
    	var play = Rez.Drawables.play;
    	var current = null;
    	if ((data instanceof Array) and (data.size() > 0))
    	{
    		var media = data[0];
    		if (media instanceof Dictionary)
    		{
    			current = media["current_playing"];
    			
    		}
    	} else {
    		current = data;
    	}
    	if (current instanceof Dictionary)
		{
			if (current["artist"] != null)
			{
				artist = current["artist"];
			}
			if (current["title"] != null)
			{ 
				title = current["title"];
			}
			if ("PLAY".equals(current["state"]))
			{
				play = Rez.Drawables.pause;
			}
		}
		WatchUi.cancelAllAnimations();
		mMarqueeArtist.updateText(artist);
		mMarqueeTitle.updateText(title);
		mPlay.setBitmap(play);
		mFireAnimation = true;
		WatchUi.requestUpdate();
    }

}
