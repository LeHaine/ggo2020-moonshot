package entity;

class DeadBody extends ScaledEntity {
	public static var ALL:Array<DeadBody> = [];

	public function new(e:Entity, sid:String, ?xMult:Float = 1, ?yMult:Float = 1) {
		super(e.cx, e.cy);
		ALL.push(this);
		xr = e.xr;
		yr = e.yr;
		isCollidable = false;
		sprScaleX = e.sprScaleX;
		sprScaleY = e.sprScaleY;
		dx = e.lastHitDirFromSource * 0.18 * xMult;
		dir = -e.lastHitDirFromSource;
		gravityMul = 0.25;
		frictX = 1;
		frictY = 0.97;
		dy = -0.05 * yMult;
		spr.set(e.spr.groupName);
		spr.anim.registerStateAnim(sid + "DeathBounce", 2, function() return !onGround && cd.has("hitGround"));
		spr.anim.registerStateAnim(sid + "DeathFall", 1, function() return !onGround);
		spr.anim.registerStateAnim(sid + "DeadBody", 0);
		spr.colorize(e.spr.color.toColor());
		cd.setS("bleeding", 2);
		cd.setS("decay", rnd(20, 25));
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function onTouchGround() {
		if (M.fabs(dy) <= 0.05) {
			dy = 0;
			frictX = frictY = 0.8;
		} else {
			dy = -dy * 0.7;
		}
		cd.setS("hitGround", Const.INFINITE);
	}

	override public function postUpdate() {
		super.postUpdate();
		if (cd.has("decay"))
			spr.scaleY = cd.getRatio("decay");
	}

	override public function update() {
		super.update();
		if (cd.has("bleeding") && !cd.hasSetS("bleedFx", 0.03))
			fx.woundBleed(centerX - dir * 8, centerY);

		if (!onGround) {
			// Push mobs
			for (e in entity.Mob.ALL) {
				if (e.isAlive() && distPx(e) <= radius + e.radius && !e.cd.hasSetS("bodyHit", 0.4) && e.canBePushed()) {
					e.bump(dirTo(e) * rnd(0.025, 0.15), rnd(-0.05, -0.1));
				}
			}
		}

		if (!cd.has("decay"))
			destroy();
	}
}
