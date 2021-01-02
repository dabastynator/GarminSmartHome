using Toybox.WatchUi;
using Toybox.Application.Properties;

class MusicDelegate extends WatchUi.BehaviorDelegate {

	var mCaller = null;
	var mMusicView = null;
	var mUpdateCallback = null;
	var mVolumeDelta = 10;

	function initialize(musicView)
	{
		BehaviorDelegate.initialize();
		mCaller = new WebCaller();
		var music = Properties.getValue("musicunit");
		mCaller.setDefaultParameter("player=mplayer&id=" + music);
		mMusicView = musicView;
		mUpdateCallback = mMusicView.method(:onUpdateMusic);
		updatePlaying();	
	}
	
	function updatePlaying()
	{
		mCaller.call("/mediaserver/list", "", mUpdateCallback);
	}
	
	function changeVolume(code, data, delta)
	{
		if ((data instanceof Array) and (data.size() > 0))
		{
			var media = data[0];
			if (media instanceof Dictionary)
			{
				var current = media["current_playing"];
				if (current instanceof Dictionary)
				{
					var volume = current["volume"] + delta;
					mCaller.call("/mediaserver/volume", "volume=" + volume, null);
				}
			}
		}
	}
	
	function volDown(code, data)
	{
		changeVolume(code, data, -mVolumeDelta);
	}
	
	function volUp(code, data)
	{
		changeVolume(code, data, mVolumeDelta);
	}
	
	function onTap (event)
	{
		var width = CircleButtonView.Width;
		var height = CircleButtonView.Height;
		var coords = event.getCoordinates();
		if (coords[1] < height / 3)
		{
			updatePlaying();			
		} else if (coords[1] < 2 * height / 3)
		{
			if (coords[0] < width / 3)
			{
				mCaller.call("/mediaserver/stop", "", mUpdateCallback);
			} else if (coords[0] < 2 * width / 3)
			{
				mCaller.call("/mediaserver/play_pause", "", mUpdateCallback);
			} else
			{
				mCaller.call("/mediaserver/next", "", mUpdateCallback);
			}
		} else {
			if (coords[0] < width / 2)
			{
				mCaller.call("/mediaserver/list", "", method(:volDown));
			} else
			{
				mCaller.call("/mediaserver/list", "", method(:volUp));
			}
		}
	}

}