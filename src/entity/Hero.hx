package entity;

import dn.heaps.Controller.ControllerAccess;

class Hero extends ScaledEntity {
	var ca:ControllerAccess;
	var name:Text;

	var hasGun = true;
	var crouching = false;

	public function new(e:World.Entity_Hero) {
		super(e.cx, e.cy);
		ca = Main.ME.controller.createAccess("hero");
		ca.setLeftDeadZone(0.2);

		name = new Text(cx, cy, "Hero");
		name.follow(this);

		registerHeroAnimations();
	}

	private function registerHeroAnimations() {
		spr.anim.registerStateAnim('heroRunGun', 5, 2.5, () -> hasGun && !crouching && M.fabs(dx) >= 0.04 * tmod);
		spr.anim.registerStateAnim('heroIdle', 0, () -> !hasGun && !crouching);
		spr.anim.registerStateAnim('heroIdleGun', 1, () -> hasGun && !crouching);
		spr.anim.registerStateAnim('heroCrouchIdleGun', 1, () -> hasGun && crouching);
		spr.anim.registerStateAnim('heroCrouchRun', 5, 2.5, () -> hasGun && crouching && M.fabs(dx) >= 0.04 * tmod);
	}

	override function update() {
		super.update();

		var spd = crouching ? 0.02 : 0.04;

		if (onGround) {
			cd.setS("onGroundRecently", 0.15);
			cd.setS("airControl", 10);
		}

		performCrouch();
		performShot();
		performRun(spd);
		performJump();
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

			setSquashX(0.95);
			var bulletX = centerX;
			var bulletY = centerY - 3;
			fx.shoot(bulletX, bulletY, angToMouse(), 0x2780D8, 5);
			fx.bulletCase(bulletX - dir * 5, bulletY, dir);
			new Bullet(M.round(bulletX), M.round(bulletY), this, angToMouse() + rnd(-0.5, 0.5) * M.DEG_RAD);
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
		if (ca.aPressed() && cd.has("onGroundRecently")) {
			setSquashX(0.7);
			dy = -0.35 * tmod;
			cd.setS("jumpForce", 0.1);
			cd.setS("jumpExtra", 0.1);
			if (crouching) {
				toggleCrouch();
			}
		} else if (cd.has("jumpExtra") && ca.aDown()) {
			dy -= 0.04 * tmod;
		}
		if (cd.has("jumpForce") && ca.aDown()) {
			dy -= 0.05 * cd.getRatio("jumpForce") * tmod;
		}
	}

	override function postUpdate() {
		super.postUpdate();
		spr.anim.setGlobalSpeed(0.2);
	}
}
