package entity;

class Laser extends Entity {
	var data:World.Entity_Laser;

	var laserDir:Int;
	var activeTime:Float;
	var inactiveTime:Float;
	var orientation:LaserOrientation;
	var laserStart:HSprite;
	var laserMid:HSprite;
	var laserEnd:HSprite;
	var laserEndBase:HSprite;
	var endPoint:CPoint;

	var delayer:dn.Delayer;

	public function new(data:World.Entity_Laser) {
		super(data.cx, data.cy);
		this.data = data;
		orientation = data.f_type;
		laserDir = orientation == BottomToTop ? -1 : 1;
		activeTime = data.f_activeTime;
		inactiveTime = data.f_inactiveTime;

		delayer = new dn.Delayer(Const.FPS);

		var orientationId = if (orientation == BottomToTop) {
			"Vert";
		} else {
			"Horiz";
		}
		hasGravity = false;

		spr.set('laserBase${orientationId}');
		laserStart = new HSprite(Assets.tiles, 'laserStart${orientationId}', spr);
		laserMid = new HSprite(Assets.tiles, 'laserMid${orientationId}', spr);
		laserEnd = new HSprite(Assets.tiles, 'laserStart${orientationId}', spr);
		laserEndBase = new HSprite(Assets.tiles, 'laserBase${orientationId}', spr);

		laserStart.setCenterRatio(0.5, 1);
		laserMid.setCenterRatio(0.5, 1);
		laserEnd.setCenterRatio(0.5, 1);
		laserEndBase.setCenterRatio(0.5, 1);

		if (orientation == BottomToTop) {
			laserEndBase.scaleY *= -1;
			laserEnd.scaleY *= -1;
			laserStart.y -= 2;
			laserEnd.y += 2;
		} else {
			widthAlign = LEFT;
			laserStart.x += 2;
			laserEnd.x -= 2;
			laserStart.y -= 2;
			laserEnd.y -= 2;
			laserMid.y -= 2;
			xr = 0;
			laserEndBase.scaleX *= -1;
			laserEnd.scaleX *= -1;
			laserStart.setCenterRatio(0, 1);
			laserMid.setCenterRatio(0, 1);
			laserEnd.setCenterRatio(0, 1);
			laserEndBase.setCenterRatio(0, 1);
			spr.setCenterRatio(0, 1);
		}

		if (activeTime > 0) {
			delayedActivate();
		}
		findEndPoint();
	}

	private function findEndPoint() {
		var hasCollision = false;
		var i = 0;
		while (!hasCollision) {
			i += laserDir;
			hasCollision = if (orientation == BottomToTop) {
				level.hasCollision(cx, cy + i);
			} else {
				level.hasCollision(cx + i, cy);
			}
			if (hasCollision) {
				if (orientation == BottomToTop) {
					endPoint = new CPoint(cx, cy + i);
				} else {
					endPoint = new CPoint(cx + i, cy);
				}
			}
		}
		if (orientation == BottomToTop) {
			hei = i * Const.GRID * laserDir;
			width = 8;
			var endY = i * Const.GRID;
			laserEndBase.y += endY;
			laserEnd.y += endY;
			laserMid.y += Const.GRID * laserDir;

			laserMid.scaleY = i * laserDir + (laserDir * 2);
		} else {
			var endX = i * Const.GRID;
			laserEndBase.x += endX;
			laserEnd.x += endX;
			laserMid.x += Const.GRID;
			width = i * Const.GRID;
			hei = 8;

			laserMid.scaleX = i - 2;
		}
	}

	private function setActivate(isActive:Bool) {
		isCollidable = isActive;
		laserStart.visible = isActive;
		laserMid.visible = isActive;
		laserEnd.visible = isActive;
	}

	private function delayedActivate() {
		delayer.addS("activeTimer", () -> {
			setActivate(false);
			delayedDeactivate();
		}, activeTime);
	}

	private function delayedDeactivate() {
		delayer.addS("activeTimer", () -> {
			setActivate(true);
			delayedActivate();
		}, inactiveTime);
	}

	override function onTouch(from:Entity) {
		super.onTouch(from);

		if (from.is(Hero) && !cd.hasSetS("damage", 0.2)) {
			from.hit(10, this);
			if (orientation == LeftToRight) {
				from.bump(rnd(-0.1, 0.1), 0.3 * M.sign(-from.dy));
			} else {
				from.bump(dirTo(from) * 0.3, -0.1);
			}
		}
	}

	override function update() {
		super.update();
		delayer.update(tmod);

		if (isCollidable && !cd.hasSetS("fx", 0.25)) {
			if (orientation == BottomToTop) {
				fx.laserSparks(footX, footY + (5 * laserDir), endPoint.footX, endPoint.footY - (5 * laserDir));
			} else {
				fx.laserSparks(footX + (5 * laserDir), footY, endPoint.footX - (5 * laserDir), endPoint.footY);
			}
		}
	}
}
