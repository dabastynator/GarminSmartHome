using Toybox.WatchUi;

class CircleButtonDelegate extends WatchUi.BehaviorDelegate {

	var mCallbacks = [];
	var mView = null;

	function initialize(view)
	{
		mView = view;
		BehaviorDelegate.initialize();
	}
	
	function addCallback(callback)
	{
		mCallbacks.add(callback);
	}
	
	function onKey(event)
	{
		if (event.getKey() == WatchUi.KEY_ENTER)
		{
			if (mView.getIndex() < mCallbacks.size())
			{
				mCallbacks[mView.getIndex()].invoke();
			}
		}
		if (event.getKey() == WatchUi.KEY_UP)
		{
			mView.setIndex((mView.getIndex() + 1) % mCallbacks.size());
		}
		if (event.getKey() == WatchUi.KEY_DOWN)
		{
			mView.setIndex((mView.getIndex() + mCallbacks.size() - 1) % mCallbacks.size());
		}
	}
	
	function onTap (event)
	{
		var coords = event.getCoordinates();
		var maxDot = 0;
		var callback = null;
		for (var i = 0; i < mCallbacks.size(); i++) {
			var sin = Math.sin(2*i*Math.PI / mCallbacks.size());
			var cos = -Math.cos(2*i*Math.PI / mCallbacks.size());
			var dot = sin * (coords[0] - mView.Width / 2) + cos * (coords[1] - mView.Height / 2);
			if (dot > maxDot)
			{
				maxDot = dot;
				callback = mCallbacks[i];
			}
		}
		if (callback != null)
		{
			callback.invoke();
		}
	}

}