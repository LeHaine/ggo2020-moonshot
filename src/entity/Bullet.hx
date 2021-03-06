package entity;

class Bullet extends Entity {
	public var ALL:Array<Bullet> = [];

	public var owner:Entity;
	public var pierceChance = 0.;
	public var targetsToPierce = 0;
	public var targetsPierced:Array<Entity> = [];
	public var affectsToApply:Array<{affect:Affect, t:Float}> = [];

	public var damage:Int;
	public var damageMul = 1.;
	public var doesAoeDamage = false;
	public var shouldBump = false;
	public var damageRadius = 1.;
	public var damageRadiusMul = 1.;

	public var trailColor = 0xFFFFFF;

	var speed = 0.75;
	var angle:Float;

	var lastX:Float;
	var lastY:Float;

	public function new(x:Int, y:Int, owner:Entity, angle:Float, damage:Int = 1) {
		super(0, 0);
		ALL.push(this);
		this.owner = owner;
		this.damage = damage;
		this.angle = angle;

		setPosPixel(x, y);
		setSpeed(speed);

		spr.set("fxDot");
		spr.setCenterRatio();
		hei = 1;
		width = 1;
		radius = 0.5;
		hasGravity = false;
		frictX = 1;
		frictY = 1;

		lastX = centerX;
		lastY = centerY;
	}

	public function setSpeed(newSpeed:Float) {
		speed = newSpeed;
		dx = Math.cos(angle) * speed * tmod;
		dy = Math.sin(angle) * speed * tmod;
	}

	public function setSize(size:Int) {
		sprScaleX = size;
		sprScaleY = size;
		hei = size;
		width = size;
		radius = size / 2;
	}

	override function onTouch(from:Entity) {
		super.onTouch(from);
		if (from.ignoreBullets) {
			return;
		}

		if (from != owner && !from.is(Bullet) && !targetsPierced.contains(from)) {
			if (from.is(Mob) && owner.is(Mob)) {
				return;
			}
			from.hit(Std.int(damage * damageMul), this);
			for (affectToApply in affectsToApply) {
				from.setAffectS(affectToApply.affect, affectToApply.t);
			}
			var didPierce = rnd(0, 1) < pierceChance;
			if (targetsToPierce <= 0 && !didPierce) {
				fx.moonShotExplosion(centerX, centerY, damageRadiusMul);
				performAoe();
				destroy();
			} else {
				// we want the pierce chance to stack with the targetToPierce
				// if it pierced based off chance then we want to keep the guaranteed targets to pierce still
				if (!didPierce) {
					targetsToPierce--;
				}
				targetsPierced.push(from);
			}
		}
	}

	override function update() {
		super.update();

		fx.trail(lastX, lastY, centerX, centerY, trailColor, radius * 2);
		lastX = centerX;
		lastY = centerY;
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function onCollision(fromX:Int, fromY:Int) {
		super.onCollision(fromX, fromY);

		onBulletCollision();
	}

	function onBulletCollision() {
		fx.moonShotExplosion(centerX, centerY, damageRadiusMul);
		performAoe();
		destroy();
	}

	private function performAoe() {
		if (!doesAoeDamage) {
			return;
		}
		for (entity in Character.ALL) {
			if (owner == entity) {
				continue;
			}
			var dist = distCase(entity);
			if (dist <= damageRadius) {
				var damageRatio = 1 - (dist / damageRadius);
				var aoeDamage = Std.int(Math.max(1, M.floor(damage * damageRatio)));
				entity.hit(aoeDamage, this);

				if (shouldBump) {
					var bmpAng = angTo(entity);
					var bmpX = Math.cos(bmpAng) * 0.2;
					var bmpY = Math.cos(bmpAng) * 0.2;
					entity.bump(bmpX, bmpY);
				}
			}
		}
	}
}
