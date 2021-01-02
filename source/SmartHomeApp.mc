using Toybox.Application;
using Toybox.WatchUi;

class SmartHomeApp extends Application.AppBase {

	function initialize()
	{
		AppBase.initialize();
	}

	// onStart() is called on application start up
	function onStart(state)
	{
	}

	// onStop() is called when your application is exiting
	function onStop(state)
	{
	}
	
	function toScripts()	
	{
		WatchUi.pushView(new Rez.Menus.TriggerMenu(), new MenuDelegate(), WatchUi.SLIDE_UP);
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
	
	function toSwitches()
	{
		var caller = new WebCaller();
		caller.call("/switch/list", "", method(:showSwitches));
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
		var caller = new WebCaller();
		var music = Properties.getValue("musicunit");
		caller.call("/mediaserver/playlists", "id=" + music, method(:showPlaylists));
	}

	// Return the initial view of your application here
	function getInitialView()
	{
		var view = new CircleButtonView(60);
		view.setCenter(Rez.Drawables.SmartHome);
		view.addButton(Rez.Drawables.script);
		view.addButton(Rez.Drawables.headphone);
		view.addButton(Rez.Drawables.switches);
		view.addButton(Rez.Drawables.playlist);
		var delegate = new CircleButtonDelegate(view);
		delegate.addCallback(method(:toScripts));
		delegate.addCallback(method(:toMusic));
		delegate.addCallback(method(:toSwitches));
		delegate.addCallback(method(:toPlaylists));
		return [ view, delegate ];
	}

}
