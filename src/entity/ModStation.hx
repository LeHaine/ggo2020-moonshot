package entity;

import ui.ModStationWindow;
import entity.interactable.DialogInteracble;

class ModStation extends Entity {
	public static var ALL:Array<ModStation> = [];

	var data:World.Entity_ModStation;
	var interactable:DialogInteracble;

	public function new(data:World.Entity_ModStation) {
		super(data.cx, data.cy);
		ALL.push(this);
		this.data = data;
		spr.set("modStation");

		hasGravity = false;
		isCollidable = false;
		interactable = new DialogInteracble(cx, cy, "Modify Traits", () -> new ModStationWindow(onItemBought));
		interactable.follow(this);
	}

	override function dispose() {
		super.dispose();
		interactable.destroy();
		ALL.remove(this);
	}

	private function onItemBought() {
		#if !debug
		destroy();
		interactable.destroy();
		#end
	}
}
