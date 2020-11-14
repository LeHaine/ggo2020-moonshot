package entity;

import entity.interactable.DialogInteracble;

class Gun extends ScaledEntity {
	var data:World.Entity_Gun;

	var interactable:DialogInteracble;

	public function new(data:World.Entity_Gun) {
		super(data.cx, data.cy);
		this.data = data;

		spr.set("gun");
		yr = 0.5;
		ignoreBullets = true;
		hasGravity = false;

		interactable = new DialogInteracble(cx, cy, "Take", () -> {
			hero.equipGun();
			destroy();
		});
		interactable.follow(this, 0, -1.5);
	}

	override function dispose() {
		super.dispose();
		interactable.destroy();
	}
}
