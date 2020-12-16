using Toybox.WatchUi;

class MarqueeLabel {

	var mLabel = null;	
	var mText = "";
	var mWidth = 0;
	var mStatus = 0;
	var mLeft = 0;
	var mRight = 0;
	var mStayDuration = 1.5;
	
	function initialize(left, right)
	{
        mLeft = left;
        mRight = right;
    }
    
    function setLabel(label)
    {
    	mLabel = label;
    }
    
    function updateText(text)
    {
    	mText = text;
    	mLabel.setText(text);
    }
    
    function calculateWidth(dc)
    {
    	mWidth = dc.getTextWidthInPixels(mText, Graphics.FONT_SMALL);
    }
    
    function animate()
    {
    	if (mWidth > mRight - mLeft)
    	{
    		var from = mLeft;
    		var to = mRight - mWidth;
    		if (mStatus == 0)
    		{
    			to = from+1;
    		}
    		if (mStatus == 2)
    		{
    			from = to+1;
    		}
    		var duration = (from-to).abs() / 40;
    		if (duration < mStayDuration)
    		{
    			duration = mStayDuration;
    		}
			WatchUi.animate(mLabel, :locX, WatchUi.ANIM_TYPE_LINEAR, from, to, duration, method(:animate));
		} else {
			mLabel.locX = mLeft + (mRight - mLeft - mWidth) / 2;
			WatchUi.requestUpdate();
    	}
    	mStatus = (mStatus + 1) % 3;
    }
	
}