import dn.heaps.Sfx;
import GameStorage.Settings;
import GameStorage.PermaUpgrades;
import entity.CrystalShardStation;
import hxd.Timer;
import data.Trait;
import hxd.Key;
import dn.Process;

class Game extends Process {
	public static var ME:Game;

	public var mouseX(get, never):Float;

	function get_mouseX()
		return Main.ME.mouseX;

	public var mouseY(get, never):Float;

	function get_mouseY()
		return Main.ME.mouseY;

	/** Game controller (pad or keyboard) **/
	public var ca:dn.heaps.Controller.ControllerAccess;

	/** Particles **/
	public var fx:Fx;

	/** Basic viewport control **/
	public var camera:Camera;

	/** Container of all visual game objects. Ths wrapper is moved around by Camera. **/
	public var scroller:h2d.Layers;

	/** Level data **/
	public var level:Level;

	/** UI **/
	public var hud:ui.Hud;

	public var minimap:ui.Minimap;

	/** Slow mo internal values**/
	var curGameSpeed = 1.0;

	var slowMos:Map<String, {id:String, t:Float, f:Float}> = new Map();

	/** LEd world data **/
	public var world:World;

	public var hero:entity.Hero;

	public var storage:GameStorage;

	public var permaUpgrades(get, never):PermaUpgrades;

	inline function get_permaUpgrades() {
		return storage.permaUpgrades;
	}

	public var settings(get, never):Settings;

	inline function get_settings() {
		return storage.settings;
	}

	public var coins(get, set):Int;

	inline function set_coins(v) {
		hud.invalidate();
		return storage.collectibles.coins = v;
	}

	inline function get_coins() {
		return storage.collectibles.coins;
	}

	public var shards(get, set):Int;

	inline function set_shards(v) {
		hud.invalidate();
		return storage.collectibles.shards = v;
	}

	inline function get_shards() {
		return storage.collectibles.shards;
	}

	#if debug
	var fpsTf:h2d.Text;
	#end

	var nextLevelReady = false;
	var lastSpawn = 0;

	static var BOSS_ROOM = 3;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_MAIN);

		scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		storage = new GameStorage();
		storage.loadSavedData();

		world = new World();
		camera = new Camera();
		fx = new Fx();
		hud = new ui.Hud();

		if (storage.settings.finishedTutorial) {
			startLevel(1);
		} else {
			startLevel(0);
		}
		#if debug
		fpsTf = new h2d.Text(Assets.fontTiny);
		root.add(fpsTf, Const.DP_UI);
		fpsTf.setPosition(2, 2);
		#end
	}

	public function startLevel(idx:Int) {
		// Cleanup
		if (level != null)
			level.destroy();

		for (e in Entity.ALL) {
			if (hero == null || (hero != null && e != hero && e != hero.chargeStrongShotBarWrapper)) {
				e.destroy();
			}
		}
		gc();

		storage.loadSavedData();
		// Init
		level = new Level(idx, world.levels[idx]);

		// Create entities here

		if (idx == 0 && !storage.heroData.hasGun) {
			for (e in level.data.l_Entities.all_Gun) {
				new entity.Gun(e);
			}
		}

		for (e in level.data.l_Entities.all_CinematicTrigger) {
			new entity.CinematicTrigger(e);
		}

		for (e in level.data.l_Entities.all_EndLevel) {
			new entity.EndLevel(e);
		}

		for (e in level.data.l_Entities.all_ModStation) {
			if (e.f_isPersonal && permaUpgrades.personalModStation) {
				new entity.ModStation(e);
			} else {
				var shouldSpawn = Lib.rnd(0, 1);
				if (shouldSpawn <= 0.25 || lastSpawn >= 5) {
					new entity.ModStation(e);
					lastSpawn = 0;
				} else {
					lastSpawn++;
				}
			}
		}

		for (e in level.data.l_Entities.all_CrystalShardStation) {
			new entity.CrystalShardStation(e);
		}

		for (e in level.data.l_Entities.all_Laser) {
			new entity.Laser(e);
		}

		for (e in level.data.l_Entities.all_Elevator) {
			new entity.Elevator(e);
		}

		for (e in level.data.l_Entities.all_ExplosiveBarrel) {
			new entity.ExplosiveBarrel(e);
		}

		for (e in level.data.l_Entities.all_Water) {
			new entity.Water(e);
		}

		for (e in level.data.l_Entities.all_Checkpoint) {
			new entity.Teleporter(e);
		}

		for (e in level.data.l_Entities.all_Mob) {
			switch e.f_type {
				case Scientist_Pistol:
					new entity.mob.scientist.ScientistPistol(e);
				case Scientist_Stun:
					new entity.mob.scientist.ScientistStun(e);
				case Scientist_Hammer:
					new entity.mob.scientist.ScientistHammer(e);
				case Guard_Fists:
					new entity.mob.GuardFists(e);
				case Rat:
					new entity.mob.Rat(e);
			}
		}

		for (e in level.data.l_Entities.all_Boss) {
			new entity.boss.Boss(e);
		}

		if (hero == null) {
			hero = new entity.Hero(level.data.l_Entities.all_Hero[0]);
		} else {
			var data = level.data.l_Entities.all_Hero[0];
			hero.cx = data.cx;
			hero.cy = data.cy;
			hero.yr = 0.5;
			hero.xr = 0.5;
		}

		if (idx != BOSS_ROOM) {
			if (minimap == null) {
				minimap = new ui.Minimap();
			} else {
				minimap.refresh();
			}
		} else {
			if (minimap != null) {
				minimap.destroy();
				minimap = null;
			}
		}
		setHeroSavedData();

		trackHero();

		startMusic();
		fx.clear();
		hud.invalidate();
		Process.resizeAll();
	}

	private function setHeroSavedData() {
		var data = storage.heroData;
		hero.hasGun = data.hasGun;
	}

	public function trackHero(immediate:Bool = true) {
		camera.trackTarget(hero, immediate, 0, -Const.GRID * 2);
	}

	function startMusic() {
		if (level.idx > 1 && !Assets.runMusic.isPlaying()) {
			Assets.restMusic.stop();
			Assets.runMusic.play(true);
		} else if (level.idx <= 1 && !Assets.restMusic.isPlaying()) {
			Assets.runMusic.stop();
			Assets.restMusic.play(true);
		}
		if (settings.musicMuted) {
			Sfx.muteGroup(1);
			Assets.restMusic.stop();
			Assets.runMusic.stop();
		}
		if (!settings.musicMuted) {
			Sfx.unmuteGroup(1);
		}
	}

	public function markNextLevelReady() {
		nextLevelReady = true;
	}

	public function resetRun() {
		var coinsToKeep = permaUpgrades.coinsCarriedOverLvl * 250;
		if (coins > coinsToKeep) {
			coins = coinsToKeep;
		}

		storage.save();
		hero.destroy();
		hero = null;
		startLevel(1);
	}

	public function startNextLevel() {
		storage.save();
		if (level.idx == 0) {
			startLevel(level.idx + 2);
		} else {
			startLevel(level.idx + 1);
		}
	}

	function restartLevel() {
		startLevel(level.idx);
	}

	public function onLedReload(json:String) {
		world.parseJson(json);
		restartLevel();
	}

	override function onResize() {
		super.onResize();
		scroller.setScale(Const.SCALE);
	}

	public function unlockPersonalModStation() {
		for (e in level.data.l_Entities.all_ModStation) {
			if (e.f_isPersonal && permaUpgrades.personalModStation) {
				new entity.ModStation(e);
			}
		}
	}

	function gc() {
		if (Entity.GC == null || Entity.GC.length == 0)
			return;

		for (e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	/**
		Start a cumulative slow-motion effect that will affect `tmod` value in this Process
		and its children.

		@param sec Realtime second duration of this slowmo
		@param speedFactor Cumulative multiplier to the Process `tmod`
	**/
	public function addSlowMo(id:String, sec:Float, speedFactor = 0.3) {
		if (slowMos.exists(id)) {
			var s = slowMos.get(id);
			s.f = speedFactor;
			s.t = M.fmax(s.t, sec);
		} else
			slowMos.set(id, {id: id, t: sec, f: speedFactor});
	}

	function updateSlowMos() {
		// Timeout active slow-mos
		for (s in slowMos) {
			s.t -= utmod * 1 / Const.FPS;
			if (s.t <= 0)
				slowMos.remove(s.id);
		}

		// Update game speed
		var targetGameSpeed = 1.0;
		for (s in slowMos)
			targetGameSpeed *= s.f;
		curGameSpeed += (targetGameSpeed - curGameSpeed) * (targetGameSpeed > curGameSpeed ? 0.2 : 0.6);

		if (M.fabs(curGameSpeed - targetGameSpeed) <= 0.001)
			curGameSpeed = targetGameSpeed;
	}

	public function addTrait(trait:Trait) {
		hero.traits.push(trait);
		trait.modify(hero);
	}

	/**
		Pause briefly the game for 1 frame: very useful for impactful moments,
		like when hitting an opponent in Street Fighter ;)
	**/
	public inline function stopFrame() {
		ucd.setS("stopFrame", 0.2);
	}

	public function toggleMusic() {
		Sfx.toggleMuteGroup(1);
		hud.invalidate();
		settings.musicMuted = Sfx.isMuted(1);
		storage.save();
		startMusic();
	}

	override function preUpdate() {
		super.preUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.preUpdate();
	}

	override function update() {
		super.update();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.update();

		#if debug
		fpsTf.text = Std.string(M.pretty(Timer.fps()));
		#end
		if (!ui.Console.ME.isActive() && !ui.Modal.hasAny()) {
			#if hl
			// Exit
			if (ca.isKeyboardPressed(Key.ESCAPE))
				if (!cd.hasSetS("exitWarn", 3))
					trace(Lang.t._("Press ESCAPE again to exit."));
				else
					hxd.System.exit();
			#end

			// Restart
			if (ca.selectPressed()) {
				Main.ME.startGame();
			}

			if (ca.dpadUpPressed() && minimap != null) {
				minimap.enlarge();
			}

			if (ca.dpadDownDown()) {
				startLevel(3); // boss room
			}

			if (ca.isKeyboardPressed(Key.M)) {
				toggleMusic();
			}
		}

		if (nextLevelReady) {
			nextLevelReady = false;
			startNextLevel();
		}
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.fixedUpdate();
	}

	override function postUpdate() {
		super.postUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.postUpdate();
		for (e in Entity.ALL)
			if (!e.destroyed)
				e.finalUpdate();
		gc();

		// Update slow-motions
		updateSlowMos();
		baseTimeMul = (0.2 + 0.8 * curGameSpeed) * (ucd.has("stopFrame") ? 0.3 : 1);
		Assets.tiles.tmod = tmod;
	}

	override function onDispose() {
		super.onDispose();

		if (minimap != null) {
			minimap.destroy();
		}

		for (c in CinematicControl.ALL) {
			c.destroy();
		}

		fx.destroy();
		for (e in Entity.ALL)
			e.destroy();
		gc();
	}
}
