package entity;

import entity.interactable.DialogInteracble;

class Elevator extends Entity {
	public var entitiesStanding:Array<Character> = [];

	var data:World.Entity_Elevator;
	var interactable:DialogInteracble;

	var origin:CPoint;
	var endPoint:CPoint;

	var targetPoint:CPoint;

	public function new(data:World.Entity_Elevator) {
		super(data.cx, data.cy);
		this.data = data;

		hasGravity = false;

		spr.set("elevator");
		hei = 6;
		width = Const.GRID * 3;

		origin = new CPoint(cx, cy);
		endPoint = new CPoint(data.f_end.cx, data.f_end.cy);
		targetPoint = origin;

		interactable = new DialogInteracble(cx, cy, "Use", () -> {
			interactable.unfocus();
			interactable.active = false;

			if (cy == origin.cy) {
				targetPoint = endPoint;
			} else {
				targetPoint = origin;
			}
		});
		interactable.follow(this);
	}

	private function moveToPoint(spd:Float, point:CPoint) {
		if (point.cy > cy) {
			dy += spd * tmod;
		}
		if (point.cy < cy) {
			dy -= spd * tmod;
		}
	}

	override function update() {
		super.update();

		moveToPoint(0.05, targetPoint);

		if (cy == targetPoint.cy && !interactable.active) {
			interactable.active = true;
			yr = 0;
		}

		for (e in entitiesStanding) {
			e.stickToElevator();
		}
	}
}
