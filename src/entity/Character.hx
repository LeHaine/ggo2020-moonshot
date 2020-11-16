package entity;

import ui.Bar;

class Character extends ScaledEntity {
	var climbing = false;

	var affectToIcon = [
		Stun => "stunEffectIcon",
		Bleed => "bloodEffectIcon",
		Burn => "fireEffectIcon",
		Poison => "poisonEffectIcon"
	];

	var currentAffectIcons:Map<Affect, HSprite> = [];
	var affectIcons:h2d.Flow;

	var healthBar:Bar;
	var usesHealthBar:Bool = true;

	var elevator:Null<Elevator>;

	override function get_onGround():Bool {
		return super.get_onGround() || elevator != null;
	}

	public function new(x:Int, y:Int) {
		super(x, y);
		affectIcons = new h2d.Flow();
		game.scroller.add(affectIcons, Const.DP_FRONT);
	}

	override function onTouch(from:Entity) {
		super.onTouch(from);

		if (from.is(Elevator)) {
			elevator = cast(from, Elevator);
		}
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);
		showHealth();
	}

	override function onAffectStart(k:Affect) {
		super.onAffectStart(k);
		if (currentAffectIcons[k] != null) {
			return;
		}
		var icon = Assets.tiles.h_get(affectToIcon[k], affectIcons);
		icon.anim.playAndLoop(affectToIcon[k]);
		currentAffectIcons[k] = icon;
	}

	override function onAffectEnd(k:Affect) {
		super.onAffectEnd(k);
		affectIcons.removeChild(currentAffectIcons[k]);
		currentAffectIcons.remove(k);
	}

	override function shouldCheckCeilingCollision():Bool {
		return !climbing;
	}

	override function onFallDamage(dmg:Int) {
		super.onFallDamage(dmg);
		showHealth();
	}

	override function onTouchGround(fallHeight:Float) {
		super.onTouchGround(fallHeight);

		var impact = M.fmin(1, fallHeight / 6);
		dx *= (1 - impact) * 0.5;
		setSquashY(1 - impact * 0.7);

		if (fallHeight >= 9) {
			lockControlS(0.3);
			cd.setS("heavyLand", 0.3);
		} else if (fallHeight >= 3) {
			lockControlS(0.03 * impact);
		}
	}

	public function startClimbing() {
		climbing = true;
		bdx *= 0.2;
		bdy *= 0.2;
		dx *= 0.3;
		dy *= 0.1;
	}

	public function stopClimbing() {
		climbing = false;
	}

	public function showHealth() {
		if (usesHealthBar) {
			renderHealthBar();
			healthBar.alpha = 1;
		}
	}

	public function renderHealthBar() {
		if (healthBar == null) {
			healthBar = new Bar(10, 2, 0xFF0000);
			healthBar.enableOldValue(0xFF0000);
			game.scroller.add(healthBar, Const.DP_FRONT);
			healthBar.alpha = 0;
		}

		healthBar.set(life / maxLife, 1);
	}

	public function isOnElevator() {
		if (elevator == null) {
			return false;
		}
		return distCaseY(elevator) <= 1 && distCaseX(elevator) <= 1.2;
	}

	public function stickToElevator() {
		if (elevator != null) {
			cy = elevator.cy;
			yr = elevator.yr - 0.3;
		}
	}

	override function update() {
		super.update();

		if (isOnElevator()) {
			stickToElevator();
		} else {
			elevator = null;
		}
	}

	override function postUpdate() {
		super.postUpdate();

		if (healthBar != null) {
			healthBar.x = Std.int(spr.x - healthBar.outerWidth * 0.5);
			healthBar.y = Std.int(spr.y - hei * 1.35 - healthBar.outerHeight);
			if (!cd.has("showhealthBar")) {
				healthBar.alpha += ((life < maxLife ? 0.3 : 0) - healthBar.alpha) * 0.03;
			}
		}

		affectIcons.x = Std.int(spr.x - affectIcons.outerWidth * 0.5);
		if (healthBar != null) {
			affectIcons.y = Std.int(healthBar.y - 2 - affectIcons.outerHeight);
		} else {
			affectIcons.y = Std.int(spr.y - hei * 1.35 - affectIcons.outerHeight);
		}
	}

	override function dispose() {
		super.dispose();

		if (healthBar != null) {
			healthBar.remove();
			healthBar = null;
		}
		affectIcons.removeChildren();
		affectIcons.remove();
		affectIcons = null;
	}
}
