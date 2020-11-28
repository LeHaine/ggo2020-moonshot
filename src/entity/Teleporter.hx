package entity;

import entity.interactable.DialogInteracble;

class Teleporter extends Entity {
	public static var ALL:Array<Teleporter> = [];

	var data:World.Entity_Checkpoint;

	public var found = false;

	var interactable:DialogInteracble;

	public function new(data:World.Entity_Checkpoint) {
		super(data.cx, data.cy);
		ALL.push(this);
		this.data = data;

		hasGravity = false;
		isCollidable = false;
		interactable = new DialogInteracble(cx, cy, "Teleport", () -> {
			game.minimap.enlargeAndNavigate();
		});
		interactable.follow(this);

		spr.anim.registerStateAnim("teleporterInactive", 0, () -> !found);
		spr.anim.registerStateAnim("teleporterActive", 1, () -> found);
	}

	override function update() {
		super.update();

		if (hero != null) {
			if (distCase(hero) <= 7 && !found) {
				found = true;
				Assets.SLIB.teleporterUnlock0().playOnGroup(Const.EXTRA, 0.6);
			}
		}
	}

	override function postUpdate() {
		super.postUpdate();
		spr.anim.setGlobalSpeed(0.2);
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
		interactable.destroy();
	}
}
