class CinematicControl extends dn.Process {
	public static var ALL:Array<CinematicControl> = [];

	public var game(get, never):Game;

	inline function get_game()
		return Game.ME;

	public var level(get, never):Level;

	inline function get_level()
		return Game.ME.level;

	public var fx(get, never):Fx;

	inline function get_fx()
		return Game.ME.fx;

	var cm:dn.Cinematic;

	public function new(id:CinematicId, ?trigger:World.Entity_CinematicTrigger) {
		super(game);

		ALL.push(this);
		cm = new dn.Cinematic(Const.FPS);

		switch id {
			case PrisonWakeup:
				performPrisonWakeupCinematic(trigger);
		}
	}

	private function performPrisonWakeupCinematic(trigger:World.Entity_CinematicTrigger) {
		if (trigger == null) {
			return;
		}
		var targetPoint = new CPoint(trigger.f_cameraTarget.cx, trigger.f_cameraTarget.cy);
		var scientistColor = 0xbf2242;
		cm.create({
			game.camera.trackPoint(targetPoint, false);
			displayText("They left the door open?");
			end;
			displayText("We finally did it! We shrunk the moon and harnessed its power within this new weapon.", scientistColor);
			end;
			displayText("I shall call it, the Moon...inator? ...the Lunarinator? ...Moon shotinator? It shoots the moon, OK!", scientistColor);
			end;
			displayText("When we get time, we should blast our test subject with it to see what happens.", scientistColor);
			end;
			game.trackHero(false);
			displayText("Yikes.");
			end;
			complete();
		});
	}

	private function displayText(str:String, ?c = 0x589bd1) {
		clearText();
		var f = new h2d.Flow();
		game.root.add(f, Const.DP_UI);
		f.setScale(Const.SCALE);
		curText = f;
		f.borderWidth = 4;
		f.borderHeight = 4;
		f.layout = Vertical;
		f.padding = 8;

		var bg = new h2d.ScaleGrid(Assets.tiles.getTile("uiDialogBox"), 4, 4, f);
		f.getProperties(bg).isAbsolute = true;
		bg.colorMatrix = dn.Color.getColorizeMatrixH2d(c);

		f.onAfterReflow = function() {
			bg.width = f.outerWidth;
			bg.height = f.outerHeight;
		}

		var tf = new h2d.Text(Assets.fontSmall, f);
		tf.text = str;
		tf.maxWidth = 250;
		tf.textColor = 0xffffff;

		f.addSpacing(16);
		var tf = new h2d.Text(Assets.fontTiny, f);
		if (game.ca.isGamePad()) {
			tf.text = "[B] to continue";
		} else {
			tf.text = "F to continue";
		}
		tf.text = "F to continue";
		tf.textColor = 0xffffff;
		f.getProperties(tf).align(Top, Right);

		f.x = Std.int(w() / Const.SCALE * 0.5 - f.outerWidth * 0.5 + rnd(0, 30, true));
		f.y = rnd(20, 40);

		tw.createS(f.x, f.x - 20 > f.x, 0.2);
		cd.setS("skipLock", 0.2);
	}

	var curText:Null<h2d.Flow>;

	private function clearText() {
		if (curText != null) {
			var f = curText;
			curText = null;
			tw.createS(f.x, f.x + 20, 0.2);
			tw.createS(f.alpha, 0, 0.2).end(() -> {
				f.remove();
			});
		}
	}

	private function complete() {
		clearText();
		delayer.addS(destroy, 0.3);
	}

	override function update() {
		cm.update(tmod);
		super.update();

		if (game.ca.bPressed())
			if (!cd.has("skipLock")) {
				cm.signal();
			}
	}

	override function postUpdate() {
		super.postUpdate();
		if (curText != null) {
			curText.setScale(Const.SCALE);
		}
	}

	override function onDispose() {
		super.onDispose();
		cm.destroy();
		cm = null;
		ALL.remove(this);
	}

	public static function isEmpty() {
		return ALL.length == 0;
	}
}
