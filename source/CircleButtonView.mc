using Toybox.WatchUi;
using Toybox.Graphics;


class CircleButtonView extends WatchUi.View {

	public static var Width;
	public static var Height;

	private var mImages = [];
	private var mIndex = 0;
	public var mArcAngle = 0;
	private var mMargin = 0;
	private var mCenterImage = null;
	public var mAppearAnimation = 0;

	function initialize()
	{
		View.initialize();
	}
	
	function calcArcAngle(index)
	{
		return -(index+0.5) * 360 / mImages.size() + 90;
	}
	
	function smoothstep(x)
	{
		if (x < 0)
		{
			return 0;
		} else if (x < 1)
		{
			return (3 - 2 * x) * x * x;
		} else {
			return 1;
		}
	}
	
	function smootherstep(x)
	{
		if (x < 0)
		{
			return 0;
		} else if (x < 1)
		{
			return (6 * x * x - 15 * x + 10) * x * x * x;
		} else {
			return 1;
		}
	}
	
	// Add a resource like Rez.Drawables.id_monkey
	function addButton(resource)
	{
		var image = WatchUi.loadResource( resource );
		mImages.add(image);
		mArcAngle = calcArcAngle(mIndex);
	}
	// Set a resource like Rez.Drawables.id_monkey
	function setCenter(resource)
	{
		mCenterImage = WatchUi.loadResource( resource );
	}

	function onShow()
	{
		WatchUi.animate(self, :mAppearAnimation, WatchUi.ANIM_TYPE_LINEAR, 0, 1, 0.6, null);
	}

	function onUpdate(dc)
	{
		Width = dc.getWidth();
		Height = dc.getHeight();
		var centerX = dc.getWidth() / 2;
		var centerY = dc.getHeight() / 2;
		mMargin = 0.15 * Width;
	 
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		
		if (mCenterImage != null)
		{
			dc.drawBitmap( centerX - mCenterImage.getWidth() / 2, centerY - mCenterImage.getHeight() / 2, mCenterImage );
		}
		
		dc.setColor(0x888888, Graphics.COLOR_BLACK);
		dc.setPenWidth(1);
		var animationStep = smootherstep(mAppearAnimation);
		var rAnimationStep = 1 - animationStep; 
		for (var i = 0; i < mImages.size(); i++) {
			var image = mImages[i];
			var angle = 2 * i * Math.PI / mImages.size();
			var sin = Math.sin(angle);
			var cos = -Math.cos(angle);
			var marginFactor = 2 * smootherstep(1.5 * (mAppearAnimation * 2 - 1.0 * i / mImages.size())) - 1;
			var offX = sin * (centerX - mMargin * marginFactor);
			var offY = cos * (centerY - mMargin * marginFactor);
			dc.drawBitmap( centerX + offX - image.getWidth() / 2, centerY + offY - image.getHeight() / 2, image );
			
			angle = 2 * (i + 0.5) * Math.PI / mImages.size();
			sin = Math.sin(angle) * centerX;
			cos = -Math.cos(angle) * centerY;
			var splitLine = 0.5 + 0.5 * rAnimationStep;
			dc.drawLine(centerX + sin * splitLine, centerY + cos * splitLine, centerX + sin, centerY + cos);
		}
				
		dc.setPenWidth(5);
		var degreeSize = 360 / mImages.size();
		var from = mArcAngle + 0.5 * degreeSize * rAnimationStep;
		var to = mArcAngle + degreeSize * (0.5 + 0.5 * animationStep);  
		if (from < to)
		{
			dc.drawArc(centerX, centerY, centerX - 4, Graphics.ARC_COUNTER_CLOCKWISE, from, to);
		}		
	}
	
	function getIndex()
	{
		return mIndex;
	}
	
	function setIndex(index)
	{
		mIndex = index;
		var newArcAngle = calcArcAngle(mIndex);
		while (newArcAngle - mArcAngle > 180)
		{
			newArcAngle = newArcAngle - 360;	
		}
		while (newArcAngle - mArcAngle < -180)
		{
			newArcAngle = newArcAngle + 360;
		} 
		WatchUi.requestUpdate();
		WatchUi.cancelAllAnimations();
		WatchUi.animate(self, :mArcAngle, WatchUi.ANIM_TYPE_EASE_OUT, mArcAngle, newArcAngle, 0.3, null);
	}

	function onHide()
	{
	}

}
