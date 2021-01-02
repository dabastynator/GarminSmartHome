using Toybox.WatchUi;
using Toybox.Graphics;


class CircleButtonView extends WatchUi.View {

	public static var Width;
	public static var Height;

	private var mImages = [];
	private var mIndex = 0;
	public var mArcAngle = 0;
	private var mMargin = 60;
	private var mCenterImage = null;

	function initialize(margin)
	{
		mMargin = margin;
		View.initialize();
	}
	
	function calcArcAngle(index)
	{
		return -(index+0.5) * 360 / mImages.size() + 90;
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
	}

	function onUpdate(dc)
	{
		Width = dc.getWidth();
		Height = dc.getWidth();
		var centerX = dc.getWidth() / 2;
		var centerY = dc.getHeight() / 2;
	 
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		
		if (mCenterImage != null)
		{
			dc.drawBitmap( centerX - mCenterImage.getWidth() / 2, centerY - mCenterImage.getHeight() / 2, mCenterImage );
		}
		
		dc.setColor(0x888888, Graphics.COLOR_BLACK);
		dc.setPenWidth(1);
		for (var i = 0; i < mImages.size(); i++) {
			var image = mImages[i];
			var sin = Math.sin(2*i*Math.PI / mImages.size());
			var cos = -Math.cos(2*i*Math.PI / mImages.size());
			var offX = sin * (centerX - mMargin);
			var offY = cos * (centerY - mMargin);
			dc.drawBitmap( centerX + offX - image.getWidth() / 2, centerY + offY - image.getHeight() / 2, image );
			
			sin = Math.sin(2*(i+0.5)*Math.PI / mImages.size()) * centerX;
			cos = -Math.cos(2*(i+0.5)*Math.PI / mImages.size()) * centerY;
			var splitLine = 0.6;
			dc.drawLine(centerX + sin * splitLine, centerY + cos * splitLine, centerX + sin, centerY + cos);
		}
				
		dc.setPenWidth(5);
		var degreeSize = 360 / mImages.size();
		dc.drawArc(centerX, centerY, centerX - 4, Graphics.ARC_COUNTER_CLOCKWISE, mArcAngle, mArcAngle + degreeSize);
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
