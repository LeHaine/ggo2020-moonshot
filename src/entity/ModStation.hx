package entity;

import entity.interactable.ModStationInteractable;

class ModStation extends ScaledEntity {
	var data:World.Entity_ModStation;
	var interactable:ModStationInteractable;

	public function new(data:World.Entity_ModStation) {
		super(data.cx, data.cy);
		this.data = data;
		spr.set("modStation");

		hasGravity = false;
		isCollidable = false;
		interactable = new ModStationInteractable(cx, cy);
		interactable.follow(this, 0, -2);
	}
}
