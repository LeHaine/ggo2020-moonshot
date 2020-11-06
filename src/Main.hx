import hxd.Res;
import hxd.Cursor.CustomCursor;
import hxd.Key;

class Main extends dn.Process {
	public static var ME:Main;

	public var controller:dn.heaps.Controller;
	public var ca:dn.heaps.Controller.ControllerAccess;

	var scene:h2d.Scene;

	public var mouseX(get, never):Float;

	function get_mouseX()
		return (scene.mouseX - Game.ME.scroller.x) / Const.SCALE;

	public var mouseY(get, never):Float;

	function get_mouseY()
		return (scene.mouseY - Game.ME.scroller.y) / Const.SCALE;

	public var rawMouseX(get, never):Float;

	function get_rawMouseX()
		return (scene.mouseX) / Const.SCALE;

	public var rawMouseY(get, never):Float;

	function get_rawMouseY()
		return (scene.mouseY) / Const.SCALE;

	@:access(h2d.Scene)
	public function new(s:h2d.Scene) {
		super();
		ME = this;
		scene = s;

		createRoot(s);

		// Engine settings
		hxd.Timer.wantedFPS = Const.FPS;
		engine.backgroundColor = 0xff << 24 | 0x111133;
		#if (hl && !debug)
		engine.fullScreen = true;
		#end

		// Resources
		#if (hl && debug)
		hxd.Res.initLocal();
		#else
		hxd.Res.initEmbed();
		#end
		scene.events.defaultCursor = Cursor.Custom(new CustomCursor([Res.cursor.toBitmap()], 0, 16, 16));

		// Hot reloading
		#if debug
		hxd.res.Resource.LIVE_UPDATE = true;
		hxd.Res.world.world.watch(function() {
			delayer.cancelById("led");
			delayer.addS("led", function() {
				if (Game.ME != null)
					Game.ME.onLedReload(hxd.Res.world.world.entry.getBytes().toString());
			}, 0.2);
		});
		#end

		// Assets & data init
		Assets.init();
		new ui.Console(Assets.fontTiny, s);
		Lang.init("en");

		// Game controller
		controller = new dn.heaps.Controller(s);
		ca = controller.createAccess("main");
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(AXIS_LEFT_Y_NEG, Key.UP, Key.Z, Key.W);
		controller.bind(AXIS_LEFT_Y_POS, Key.DOWN, Key.S);
		controller.bind(X, Key.MOUSE_LEFT);
		controller.bind(A, Key.UP, Key.SPACE, Key.Z);
		controller.bind(B, Key.F);
		controller.bind(Y, Key.MOUSE_RIGHT);
		controller.bind(RB, Key.SHIFT);
		controller.bind(SELECT, Key.R);
		controller.bind(START, Key.N);

		// Start
		new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.fontMedium);
		delayer.addF(startGame, 1);
	}

	public function startGame() {
		if (Game.ME != null) {
			Game.ME.destroy();
			delayer.addF(function() {
				new Game();
			}, 1);
		} else
			new Game();
	}

	override public function onResize() {
		super.onResize();

		// Auto scaling
		if (Const.AUTO_SCALE_TARGET_WID > 0)
			Const.SCALE = M.ceil(w() / Const.AUTO_SCALE_TARGET_WID);
		else if (Const.AUTO_SCALE_TARGET_HEI > 0)
			Const.SCALE = M.ceil(h() / Const.AUTO_SCALE_TARGET_HEI);

		Const.UI_SCALE = Const.SCALE;
	}

	override function update() {
		Assets.tiles.tmod = tmod;
		super.update();
	}
}
