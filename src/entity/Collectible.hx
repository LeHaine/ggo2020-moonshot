package entity;

class Collectible extends Entity {
	var pickupRange:Float = 7;

	public function new(cx, cy) {
		super(cx, cy);

		width = 2;
		hei = 2;

		cd.setS("cooldown", rnd(0.45, 0.6));
	}

	override function update() {
		super.update();

		if (!cd.has("cooldown")) {
			hasGravity = false;
			if ((distCase(game.hero) < pickupRange)) {
				var a = angTo(game.hero);
				dx = Math.cos(a) * 0.3;
				dy = Math.sin(a) * 0.3;

				if (distPx(game.hero) < 8) {
					onCollect();
				}
			}
		}
	}

	override function performYCollisionCheck() {
		if (cd.has("cooldown")) {
			super.performYCollisionCheck();
		}
	}

	override function performXCollisionCheck() {
		if (cd.has("cooldown")) {
			super.performXCollisionCheck();
		}
	}

	function onCollect() {
		destroy();
	}
}
