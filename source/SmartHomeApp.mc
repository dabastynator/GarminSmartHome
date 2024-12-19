using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;

class SmartHomeApp extends Application.AppBase {

	var mCaller;
	var mKodiCaller;

	function initialize()
	{
		AppBase.initialize();
		mCaller = new WebCaller();
		mKodiCaller = new KodiWebCaller();
	}

	// onStart() is called on application start up
	function onStart(state)
	{
	}

	// onStop() is called when your application is exiting
	function onStop(state)
	{
	}
	
	function toMusic()
	{
		var view = new MusicView();
		WatchUi.pushView(view, new MusicDelegate(view), WatchUi.SLIDE_UP);
	}
	
	function showSwitches(code, data)
	{
		if ((data instanceof Array) and (data.size() > 0))
		{
			var menu = new WatchUi.Menu2({:title=>"Switches"});
			var delegate = new SwitchDelegate();		
			for (var i = 0; i < data.size(); i++) {
				var rSwitch = data[i];
				if (rSwitch instanceof Dictionary)
				{
					menu.addItem(
						new WatchUi.ToggleMenuItem(
							rSwitch["name"],
							"",
							rSwitch["id"],
							"ON".equals(rSwitch["state"]),
							{}
						)
					);
				}
			}
			WatchUi.pushView( menu, delegate, WatchUi.SLIDE_UP);
		}
	}
	
	function showScenes(code, data)
	{
		if ((data instanceof Array) and (data.size() > 0))
		{
			var menu = new WatchUi.Menu2({:title=>"Scenes"});
			var delegate = new SceneDelegate();
			for (var i = 0; i < data.size(); i++) {
				var rScene = data[i];
				if (rScene instanceof Dictionary)
				{
					menu.addItem(
						new WatchUi.MenuItem(
							rScene["name"],
							"",
							rScene["id"],
							{}
						)
					);
				}
			}
			WatchUi.pushView( menu, delegate, WatchUi.SLIDE_UP);
		}
	}
	
	function toSwitches()
	{
		mCaller.call("/switch/list", "", method(:showSwitches));
	}
	
	function toScenes()
	{
		mCaller.call("/scene/list", "", method(:showScenes));
	}
	
	function showPlaylists(code, data)
	{
		if ((data instanceof Array) and (data.size() > 0))
		{
			var menu = new WatchUi.Menu2({:title=>"Playlists"});
			var delegate = new PlaylistDelegate();		
			for (var i = 0; i < data.size(); i++) {
				var playlist = data[i];
				if (playlist instanceof Dictionary)
				{
					menu.addItem(
						new WatchUi.MenuItem(
							playlist["name"],
							"",
							playlist["name"],
							{}
						)
					);
				}
			}
			WatchUi.pushView( menu, delegate, WatchUi.SLIDE_UP);
		}
	}
	
	function toPlaylists()
	{
		var music = Properties.getValue("musicunit");
		mCaller.call("/mediaserver/playlists", "id=" + music, method(:showPlaylists));
	}
	
	function showUser(code, data)
	{
		if (data instanceof Dictionary)
		{
			var alert = new Alert({
				:timeout => 5000,
				:font => Graphics.FONT_MEDIUM,
				:text => data["name"] + "\n" + data["role"],
				:fgcolor => Graphics.COLOR_WHITE,
				:bgcolor => Graphics.COLOR_BLACK
				});
			alert.pushView(WatchUi.SLIDE_UP);
		}
	}
	
	function toUser()
	{
		mCaller.call("/user/current", "", method(:showUser));
	}
	
	
	function kodiEnter()
	{
		mKodiCaller.call("Input.Select", null);
	}
	
	function kodiUp()
	{
		mKodiCaller.call("Input.Up", null);
	}
	
	function kodiVolUp()
	{
		mKodiCaller.callParam("Application.SetVolume", {"volume" => "increment"}, null);
	}
	
	function kodiRight()
	{
		mKodiCaller.call("Input.Right", null);
	}
	
	function kodiDown()
	{
		mKodiCaller.call("Input.Down", null);
	}
	
	function kodiBack()
	{
		mKodiCaller.call("Input.Back", null);
	}
	
	function kodiLeft()
	{
		mKodiCaller.call("Input.Left", null);
	}
	
	function kodiVolDown()
	{
		mKodiCaller.callParam("Application.SetVolume", {"volume" => "decrement"}, null);
	}
	
	function kodiMusic()
	{
		var view = new MusicView();
		WatchUi.pushView(view, new KodiMusicDelegate(view), WatchUi.SLIDE_UP);
	}
	
	function toKodi()
	{
		var view = new CircleButtonView();
		view.doShowAnimation(false);
		view.setLineColor(0x12b2e7);
		view.setMargin(0.16);
		view.setCenter(Rez.Drawables.enter, method(:kodiEnter));
		view.addButton(Rez.Drawables.up, method(:kodiUp));
		view.addButton(Rez.Drawables.vol_up, method(:kodiVolUp));
		view.addButton(Rez.Drawables.right, method(:kodiRight));
		view.addButton(Rez.Drawables.player, method(:kodiMusic));
		view.addButton(Rez.Drawables.down, method(:kodiDown));
		view.addButton(Rez.Drawables.back, method(:kodiBack));
		view.addButton(Rez.Drawables.left, method(:kodiLeft));
		view.addButton(Rez.Drawables.vol_down, method(:kodiVolDown));
		WatchUi.pushView(view, view.getDelegate(), WatchUi.SLIDE_UP);
	}

	// Return the initial view of your application here
	function getInitialView()
	{
	//view.addButton(Rez.Drawables.user, method(:toUser));
		var view = new CircleButtonView();
		view.doShowAnimation(false);
		view.setCenter(Rez.Drawables.smarthome, null);
		view.addButton(Rez.Drawables.user, method(:toUser));
		view.addButton(Rez.Drawables.playlist, method(:toPlaylists));
		view.addButton(Rez.Drawables.headphone, method(:toMusic));
		view.addButton(Rez.Drawables.switches, method(:toSwitches));
		view.addButton(Rez.Drawables.paint_pallet, method(:toScenes));
		view.addButton(Rez.Drawables.kodi, method(:toKodi));
		return [ view, view.getDelegate() ];
	}

}
