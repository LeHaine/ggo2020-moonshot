package entity;

import h2d.Flow.FlowAlign;
import dn.heaps.Controller.ControllerAccess;

class Hero extends ScaledEntity {
	var ca:ControllerAccess;

	var hasGun = true;
	var crouching = false;
	var climbing = false;

	var chargeStrongShotBarWrapper:UIEntity;
	var chargeStrongShotBar:ui.Bar;
	var chargeTime = 1.5; // secondary strong shot charge time
	var maxCharge = 2; // secondary strong shot max charge

	public function new(e:World.Entity_Hero) {
		super(e.cx, e.cy);
		ca = Main.ME.controller.createAccess("hero");
		ca.setLeftDeadZone(0.2);

		createChargeStrongShotBar();
		registerHeroAnimations();
	}

	private function createChargeStrongShotBar() {
		chargeStrongShotBarWrapper = new UIEntity(cx, cy);
		chargeStrongShotBarWrapper.follow(this);
		renderChargeBar(0);
		chargeStrongShotBar.visible = false;
	}

	private function registerHeroAnimations() {
		spr.anim.registerStateAnim('heroRunGun', 5, 2.5, () -> hasGun && !crouching && M.fabs(dx) >= 0.04 * tmod);
		spr.anim.registerStateAnim('heroIdle', 0, () -> !hasGun && !crouching);
		spr.anim.registerStateAnim('heroIdleGun', 1, () -> hasGun && !crouching);
		spr.anim.registerStateAnim('heroCrouchIdleGun', 1, () -> hasGun && crouching);
		spr.anim.registerStateAnim('heroCrouchRun', 5, 2.5, () -> hasGun && crouching && M.fabs(dx) >= 0.04 * tmod);
	}

	override function performGravityCheck():Bool {
		return super.performGravityCheck() && !climbing;
	}

	override function update() {
		super.update();

		var spd = crouching || isChargingAction("strongShot") ? 0.02 : 0.03;

		if (onGround) {
			cd.setS("onGroundRecently", 0.15);
			cd.setS("airControl", 10);
		}

		performCrouch();
		performShot();
		performStrongShot();
		performKick();
		performRun(spd);
		performLedgeHop();
		performJump();
		performDash();
	}

	private function performCrouch() {
		if (controlsLocked()) {
			return;
		}
		if (ca.rbPressed()) {
			toggleCrouch();
		}
	}

	private function toggleCrouch() {
		crouching = !crouching;
		if (crouching) {
			hei = 12;
		} else {
			hei = 16;
		}
	}

	private function performShot() {
		if (controlsLocked()) {
			return;
		}
		if (ca.xDown() && !cd.hasSetS("shoot", 0.2)) {
			if (ca.leftDist() == 0 && !crouching) {
				spr.anim.play("heroStandShoot");
			}

			if (ca.leftDist() == 0 && crouching) {
				spr.anim.play("heroCrouchShoot");
			}

			spawnBullet();
		}
	}

	private function performStrongShot() {
		if (controlsLocked()) {
			return;
		}

		var isCharging = isChargingAction("strongShot");
		var maxDamage = 5;
		var maxSize = 5;
		if (ca.yDown() && !isCharging && !cd.has("strongShot")) {
			chargeAction("strongShot", chargeTime, () -> {
				var bullet = spawnBullet(maxDamage, maxSize, maxCharge, true);
				bullet.setSpeed(1);
				bullet.damageRadiusMul = 1;
				resetAndHideChargeBar();
				cd.setS("strongShot", 0.5);
			});
		} else if (!ca.yDown() && isCharging && !cd.has("strongShot")) {
			var timeLeft = getActionTimeLeft("strongShot");
			cancelAction("strongShot");
			cd.setS("strongShot", 0.5);

			var ratio = 1 - (timeLeft / chargeTime);
			var bulletDamage = Std.int(Math.max(1, M.floor(maxDamage * ratio)));
			var bulletSize = Std.int(Math.max(1, M.floor(maxSize * ratio)));
			var bullet = spawnBullet(bulletDamage, bulletSize, maxCharge * ratio, true);
			bullet.setSpeed(Math.max(0.5, 1 * ratio));
			bullet.damageRadiusMul = ratio;
			resetAndHideChargeBar();
		} else if (ca.yDown() && isCharging) {
			var timeLeft = getActionTimeLeft("strongShot");
			var ratio = 1 - (timeLeft / chargeTime);
			chargeStrongShotBar.visible = true;
			renderChargeBar(ratio);
		}
	}

	private function renderChargeBar(v:Float) {
		if (chargeStrongShotBar == null) {
			chargeStrongShotBar = new ui.Bar(50, 5, 0xFF0000, chargeStrongShotBarWrapper.spr);
			chargeStrongShotBar.x -= 25;
			chargeStrongShotBar.enableOldValue(0xFF0000, 4);
		}

		chargeStrongShotBar.set(v, 1);
	}

	private function resetAndHideChargeBar() {
		renderChargeBar(0);
		chargeStrongShotBar.visible = false;
	}

	private function spawnBullet(damage:Int = 1, size:Int = 1, bounceMul:Float = 0., doesAoeDamage:Bool = false) {
		setSquashX(0.85);
		var bulletX = centerX;
		var bulletY = centerY - 3;
		bdx = rnd(0.1, 0.15) * bounceMul * -Math.cos(angToMouse());
		bdy = rnd(0.1, 0.15) * bounceMul * -Math.sin(angToMouse());
		if (bounceMul >= 2) {
			fx.strongShot(bulletX, bulletY, angToMouse(), 0x2780D8, 75);
			camera.bumpAng(-angToMouse(), rnd(1, 2));
			camera.shakeS(0.3, 0.1);
		} else if (bounceMul >= 1) {
			fx.shoot(bulletX, bulletY, angToMouse(), 0x2780D8, 10);
			camera.bumpAng(-angToMouse(), rnd(0.75, 1));
			camera.shakeS(0.2, 0.075);
		} else {
			fx.shoot(bulletX, bulletY, angToMouse(), 0x2780D8, 10);
			camera.bumpAng(-angToMouse(), rnd(0.1, 0.15));
			camera.shakeS(0.10, 0.05);
		}
		var bullet = new Bullet(M.round(bulletX), M.round(bulletY), this, angToMouse() + rnd(-0.5, 0.5) * M.DEG_RAD, damage);
		bullet.damageRadiusMul = 0.15;
		bullet.setSize(size);
		bullet.doesAoeDamage = doesAoeDamage;
		return bullet;
	}

	private function performKick() {
		if (controlsLocked()) {
			return;
		}

		if (ca.bPressed() && !cd.hasSetS("kick", 0.5)) {
			for (mob in Mob.ALL) {
				if (mob.isAlive() && distCaseX(mob) <= 1.5 && dirTo(mob) == dir && mob.isCollidable) {
					mob.hit(1, this);
					mob.bump(dirTo(mob) * rnd(0.1, 0.3), -rnd(0.15, 0.25));
				}
			}
			spr.anim.playOverlap("heroKick", 0.22);
			lockControlS(0.2);
		}
	}

	private function performRun(spd:Float) {
		if (controlsLocked()) {
			return;
		}
		if (ca.leftDist() > 0 && !cd.has("run")) {
			dx += Math.cos(ca.leftAngle()) * ca.leftDist() * spd * (0.4 + 0.6 * cd.getRatio("airControl")) * tmod;
			dir = M.sign(Math.cos(ca.leftAngle()));
		} else {
			dx *= Math.pow(0.8, tmod);
		}
	}

	private function performJump() {
		if (controlsLocked()) {
			return;
		}
		if (ca.aPressed() && !ca.ltDown() && canJump()) {
			if (climbing) {
				climbing = false;
				cd.setS("climbLock", 0.2);
				dx = dir * 0.1 * tmod;
				if (dy > 0) {
					dy = 0.2;
				} else {
					dy = -0.05 * tmod;
					cd.setS("jumpForce", 0.1);
					cd.setS("jumpExtra", 0.1);
				}
			} else {
				setSquashX(0.7);
				dy = -0.35 * tmod;
				cd.setS("jumpForce", 0.1);
				cd.setS("jumpExtra", 0.1);
				if (crouching) {
					toggleCrouch();
				}
			}
		} else if (cd.has("jumpExtra") && ca.aDown()) {
			dy -= 0.04 * tmod;
		}
		if (cd.has("jumpForce") && ca.aDown()) {
			dy -= 0.05 * cd.getRatio("jumpForce") * tmod;
		}
	}

	private function canJump() {
		var jumpKeyboardDown = ca.isKeyboardDown(K.Z) || ca.isKeyboardDown(K.W) || ca.isKeyboardDown(K.UP);
		return (!climbing && cd.has("onGroundRecently") || climbing && jumpKeyboardDown);
	}

	private function performLedgeHop() {
		var heightExtended = Std.int(Math.min(1, M.floor(hei / Const.GRID)));
		if (!climbing
			&& (level.hasMark(GrabLeft, cx, cy) || (level.hasMark(GrabLeft, cx, cy - heightExtended) && yr <= 0.5))
			&& dir == -1
			&& !cd.hasSetS("hopLimit", 0.1)
			&& !cd.has("onGroundRecently")) {
			lockControlS(0.15);
			cd.setS("ledgeClimb", 0.5);
			spr.anim.playOverlap("heroLedgeClimb");
			xr = 0.1;
			yr = 0.1;
			dx = M.fmin(-0.35, dx) * tmod;
			dy = -0.16 * tmod;

			if (level.hasMark(GrabLeft, cx, cy - heightExtended)) {
				cy -= 1;
				yr = 0.9;
			}
		}

		if (!climbing
			&& (level.hasMark(GrabRight, cx, cy) || (level.hasMark(GrabRight, cx, cy - heightExtended) && yr <= 0.5))
			&& dir == 1
			&& xr >= 0.5
			&& !cd.hasSetS("hopLimit", 0.1)
			&& !cd.has("onGroundRecently")) {
			lockControlS(0.15);
			cd.setS("ledgeClimb", 0.5);
			spr.anim.playOverlap("heroLedgeClimb");
			xr = 0.9;
			yr = 0.1;
			dx = M.fmax(0.35, dx) * tmod;
			dy = -0.16 * tmod;

			if (level.hasMark(GrabRight, cx, cy - heightExtended)) {
				cy -= 1;
				yr = 0.9;
			}
		}
	}

	private function performDash() {
		if (controlsLocked()) {
			return;
		}

		if (ca.aPressed() && ca.ltDown() && !cd.hasSetS("dash", 0.75)) {
			dx = 1 * dir;
			spr.anim.playOverlap("heroDash", 0.22);
		}
	}

	override function postUpdate() {
		super.postUpdate();
		spr.anim.setGlobalSpeed(0.2);
	}
}
