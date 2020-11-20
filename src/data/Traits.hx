package data;

import entity.Hero;

class GlassCannon extends Trait {
	public function new() {
		name = "Glass Cannon";
		icon = "splitShotIcon";
		desc = "Increases damage but lowers life";
		addAttribute("Damage", 2, true, true);
		addAttribute("Life", -0.75, false, true);
		price = 100;
		tier = S;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.damageMul *= 3;
		hero.multiplyLife(0.25);
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.damageMul /= 3;
		hero.multiplyLife(1 / 0.25);
	}
}

class SplitShot extends Trait {
	public function new() {
		name = "Split Shot";
		icon = "splitShotIcon";
		desc = "Add extra projectile to primary attack but decreases damage";
		addAttribute("Projectiles shot", 1);
		addAttribute("Damage", -0.3, false, true);
		price = 100;
		tier = S;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.projectiles++;
		hero.damageMul *= 0.7;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.projectiles = 1;
		hero.damageMul /= 0.7;
	}
}

class Minigun extends Trait {
	public function new() {
		name = "Minigun";
		icon = "splitShotIcon";
		desc = "Transforms the primary attack to act as a minigun.";
		addAttribute("Shots per second", 1.5, true, true);
		addAttribute("Accuracy", -0.75, false, true);
		price = 100;
		tier = S;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.shotsPerSecond *= 1.5;
		hero.accuracy *= 0.5;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.shotsPerSecond /= 1.5;
		hero.accuracy /= 0.5;
	}
}

class Rifle extends Trait {
	public function new() {
		name = "Rifle";
		icon = "splitShotIcon";
		desc = "Transforms the primary attack to act as a rifle";
		addAttribute("Targets pierced", 1);
		addAttribute("Accuracy", 1, true, true);
		addAttribute("Shots per second", -0.5, false, true);
		addAttribute("Damage", 1, true, true);
		price = 100;
		tier = S;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.damageMul *= 2;
		hero.targetsToPierce++;
		hero.shotsPerSecond *= 0.5;
		hero.accuracy *= 2;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.damageMul /= 2;
		hero.targetsToPierce--;
		hero.shotsPerSecond /= 0.5;
		hero.accuracy /= 2;
	}
}

class Shotgun extends Trait {
	public function new() {
		name = "Shotgun";
		icon = "splitShotIcon";
		desc = "Transforms the primary attack to act as a shotgun.";
		addAttribute("Projectiles shot", 4);
		addAttribute("Shots per second", -0.50, false, true);
		addAttribute("Accuracy", -0.5, false, true);
		price = 100;
		tier = S;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.projectiles += 4;
		hero.shotsPerSecond *= 0.5;
		hero.accuracy *= 0.5;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.projectiles -= 4;
		hero.shotsPerSecond /= 0.5;
		hero.accuracy /= 0.5;
	}
}

class FasterCharge extends Trait {
	public function new() {
		name = "Faster Charge";
		icon = "splitShotIcon";
		desc = "Secondary attack charges slightly faster";
		addAttribute("Charge speed", 0.25, true, true);
		price = 100;
		tier = A;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.chargeTime *= 0.75;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.chargeTime /= 0.75;
	}
}

class BigExplosion extends Trait {
	public function new() {
		name = "Bigger Explosion";
		icon = "splitShotIcon";
		desc = "Increase secondary attack projectile damage radius";
		addAttribute("Increase damage radius", 0.25, true, true);
		price = 100;
		tier = A;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.secondaryRadius *= 1.25;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.chargeTime /= 1.25;
	}
}

class SecondaryDamage extends Trait {
	public function new() {
		name = "Secondary Damage";
		icon = "splitShotIcon";
		desc = "Increase secondary attack damage";
		addAttribute("Increase damage", 0.1, true, true);
		price = 100;
		tier = A;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.secondaryRadius *= 1.25;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.chargeTime /= 1.25;
	}
}

class PiercingShot extends Trait {
	public function new() {
		name = "Piercing Shot";
		icon = "splitShotIcon";
		desc = "Primary attack has a chance to piece a target.";
		addAttribute("Pierce chance", 0.5, true, true);
		price = 100;
		tier = B;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.pierceChance = 0.5;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.pierceChance = 0;
	}
}

class Tank extends Trait {
	public function new() {
		name = "Tank";
		icon = "splitShotIcon";
		desc = "Run faster";
		addAttribute("Decrease run speed", 0.05, false, true);
		addAttribute("Increase life", 0.05, true, true);
		price = 100;
		tier = B;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.baseRunSpeed *= 0.95;
		hero.multiplyLife(1.05);
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.baseRunSpeed /= 0.95;
		hero.multiplyLife(1 / 1.05);
	}
}

class Runner extends Trait {
	public function new() {
		name = "Runner";
		icon = "splitShotIcon";
		desc = "Run faster";
		addAttribute("Increase run speed", 0.05, true, true);
		price = 100;
		tier = C;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.baseRunSpeed *= 1.05;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.baseRunSpeed /= 1.05;
	}
}

class Damage extends Trait {
	public function new() {
		name = "Damage";
		icon = "splitShotIcon";
		desc = "Increase primary attack damage";
		addAttribute("Increase damage", 0.05, true, true);
		price = 100;
		tier = C;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.damageMul *= 1.05;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.damageMul /= 1.05;
	}
}

class ShotsPerSecond extends Trait {
	public function new() {
		name = "Shots Per Second";
		icon = "splitShotIcon";
		desc = "Increase primary attack speed";
		addAttribute("Shots per second", 0.05, true, true);
		price = 100;
		tier = C;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.shotsPerSecond *= 1.05;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.shotsPerSecond /= 1.05;
	}
}

class Armor extends Trait {
	public function new() {
		name = "Armor";
		icon = "splitShotIcon";
		desc = "Decrease damage taken";
		addAttribute("Damage taken", -0.1, true, true);
		price = 100;
		tier = C;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.armorMul *= 0.9;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.armorMul /= 0.9;
	}
}

class Life extends Trait {
	public function new() {
		name = "Life";
		icon = "splitShotIcon";
		desc = "Increase Life";
		addAttribute("Life increase", 0.1, true, true);
		price = 100;
		tier = C;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.multiplyLife(1.1);
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.multiplyLife(1 / 1.1);
	}
}
