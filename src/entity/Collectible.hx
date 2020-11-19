package entity;

class Collectible extends Entity {
	var pickupRange:Float = 3;

	public function new(cx, cy) {
		super(cx, cy);

		width = 2;
		hei = 2;

		cd.setS("cooldown", rnd(0.6, 0.85));
	}

	override function update() {
		super.update();

		if (!cd.has("cooldown")) {
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

	function onCollect() {
		destroy();
	}
}
