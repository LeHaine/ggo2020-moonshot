package entity;

enum Body {
	Head;
	Torso;
	Legs;
}

class Mob extends ScaledEntity {
	public static var ALL:Array<Mob> = [];

	var lastBodyPartShot:Null<Body>;
	var data:World.Entity_Mob;

	public function new(data:World.Entity_Mob) {
		super(data.cx, data.cy);
		ALL.push(this);
		this.data = data;
		initLife(data.f_health);
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		if (from != null) {
			if (M.dist(from.centerX, from.centerY, headX, headY) < 1) {
				lastBodyPartShot = Head;
				dmg *= 2;
			} else if (M.dist(from.centerX, from.centerY, centerX, centerY) < 1) {
				lastBodyPartShot = Torso;
			} else if (M.dist(from.centerX, from.centerY, footX, footY) < 1) {
				lastBodyPartShot = Legs;
				dmg = M.ceil(dmg * 0.85);
			}
		}

		super.hit(dmg, from);
	}

	public function canBePushed() {
		return true;
	}
}
