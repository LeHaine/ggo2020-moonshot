package entity;

class ExplosiveBarrel extends Character {
	var data:World.Entity_ExplosiveBarrel;
	var damageRadius = 5;
	var damage = 50;

	public function new(data:World.Entity_ExplosiveBarrel) {
		super(data.cx, data.cy);
		this.data = data;

		spr.set("explosiveBarrel");
		initLife(20);
	}

	override function onDie() {
		super.onDie();

		fx.explosion(centerX, centerY, damageRadius);

		for (entity in Character.ALL) {
			var dist = distCase(entity);
			if (dist <= damageRadius) {
				var damageRatio = 1 - (dist / damageRadius);
				var aoeDamage = Std.int(Math.max(1, M.floor(damage * damageRatio)));
				var ang = angTo(entity);
				entity.bump(Math.cos(ang) * 0.3, Math.sin(ang) * 0.3);
				entity.hit(aoeDamage, this);
			}
		}
	}
}
