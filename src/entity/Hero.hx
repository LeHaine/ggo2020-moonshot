package entity;

import dn.heaps.Controller.ControllerAccess;

class Hero extends ScaledEntity {
	var ca:ControllerAccess;
	var name:Text;

	var hasGun = true;
	var crouching = false;
	var climbing = false;

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

	override function performGravityCheck():Bool {
		return super.performGravityCheck() && !climbing;
	}

	override function update() {
		super.update();

		var spd = crouching ? 0.02 : 0.03;

		if (onGround) {
			cd.setS("onGroundRecently", 0.15);
			cd.setS("airControl", 10);
		}

		dir = M.sign(Math.cos(angToMouse()));
		performCrouch();
		performShot();
		performKick();
		performRun(spd);
		performLedgeHop();
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
			fx.shoot(bulletX, bulletY, angToMouse(), 0x2780D8, 10);
			fx.bulletCase(bulletX - dir * 5, bulletY, dir);
			new Bullet(M.round(bulletX), M.round(bulletY), this, angToMouse() + rnd(-0.5, 0.5) * M.DEG_RAD);
		}
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
		} else {
			dx *= Math.pow(0.8, tmod);
		}
	}

	private function performJump() {
		if (controlsLocked()) {
			return;
		}
		if (ca.aPressed() && canJump()) {
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
		// Ledge hopping
		if (!climbing
			&& level.hasMark(GrabLeft, cx, cy)
			&& (dy < 0 || (fallHeight >= 1 && dy >= 0))
			&& xr <= 0.5
			&& !cd.hasSetS("hopLimit", 0.1)) {
			lockControlS(0.15);
			cd.setS("ledgeClimb", 0.5);
			spr.anim.playOverlap("heroLedgeClimb");
			xr = M.fmin(xr, 0.1);
			yr = 0.1;
			dx = M.fmin(-0.35, dx) * tmod;
			dy = -0.16 * tmod;
		}
		if (!climbing
			&& level.hasMark(GrabRight, cx, cy)
			&& (dy < 0 || (fallHeight >= 1 && dy >= 0))
			&& xr >= 0.5
			&& !cd.hasSetS("hopLimit", 0.1)) {
			lockControlS(0.15);
			cd.setS("ledgeClimb", 0.5);
			spr.anim.playOverlap("heroLedgeClimb");
			xr = M.fmax(xr, 0.9);
			yr = 0.1;
			dx = M.fmax(0.35, dx) * tmod;
			dy = -0.16 * tmod;
		}
	}

	override function postUpdate() {
		super.postUpdate();
		spr.anim.setGlobalSpeed(0.2);
	}
}
