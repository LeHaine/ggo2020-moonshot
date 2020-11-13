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
		cm.create({
			game.camera.trackPoint(targetPoint, false);
			end;
			game.trackHero(false);
			complete();
		});
	}

	private function complete() {
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
