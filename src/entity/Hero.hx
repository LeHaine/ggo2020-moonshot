package entity;

import dn.heaps.Controller.ControllerAccess;

class Hero extends ScaledEntity {
	var ca:ControllerAccess;
	var name:Text;

	public function new(e:World.Entity_Hero) {
		super(e.cx, e.cy);
		ca = Main.ME.controller.createAccess("hero");
		ca.setLeftDeadZone(0.2);
		name = new Text(cx, cy, "Hero");

		name.follow(this);
	}

	override function update() {
		super.update();

		var spd = 0.04;

		if (onGround) {
			cd.setS("onGroundRecently", 0.15);
			cd.setS("airControl", 10);
		}

		performRun(spd);
		performJump();
	}

	private function performRun(spd:Float) {
		if (!controlsLocked() && ca.leftDist() > 0 && !cd.has("run")) {
			dx += Math.cos(ca.leftAngle()) * ca.leftDist() * spd * (0.4 + 0.6 * cd.getRatio("airControl")) * tmod;
			dir = M.sign(Math.cos(ca.leftAngle()));
		} else {
			dx *= Math.pow(0.8, tmod);
		}
	}

	private function performJump() {
		if (!controlsLocked() && ca.aPressed() && cd.has("onGroundRecently")) {
			setSquashX(0.7);
			dy = -0.35 * tmod;
			cd.setS("jumpForce", 0.1);
			cd.setS("jumpExtra", 0.1);
		} else if (cd.has("jumpExtra") && ca.aDown()) {
			dy -= 0.04 * tmod;
		}
		if (cd.has("jumpForce") && ca.aDown()) {
			dy -= 0.05 * cd.getRatio("jumpForce") * tmod;
		}
	}
}
