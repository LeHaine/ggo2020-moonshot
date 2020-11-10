package data;

import entity.Hero;

class SplitShot extends WeaponTrait {
	public function new() {
		name = "Split Shot";
		icon = "splitShotIcon";
		desc = "Splits primary attack into two weaker projectiles.";
		addAttribute("Projectiles shot", 1);
		price = 100;
		tier = S;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.projectiles = 2;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.projectiles = 1;
		hero.damageMul *= 0.75;
	}
}

class PiercingShot extends WeaponTrait {
	public function new() {
		name = "Piercing Shot";
		icon = "splitShotIcon";
		desc = "Primary attack has a chance to piece a target.";
		addAttribute("Pierce chance", 0.5, true, true);
		price = 100;
		tier = S;
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

class Rifle extends WeaponTrait {
	public function new() {
		name = "Rifle";
		icon = "splitShotIcon";
		desc = "Transforms the primary attack to act as a rifle";
		addAttribute("Targets pierced", 1);
		addAttribute("Accuracy", 1, true, true);
		addAttribute("Shots per second", -0.75, false, true);
		addAttribute("Bullet size", -0.5, false, true);
		price = 100;
		tier = S;
	}

	override public function modify(hero:Hero) {
		super.modify(hero);
		hero.targetsToPierce++;
		hero.shotsPerSecond *= 0.25;
		hero.accuracy *= 2;
	}

	override public function unmodify(hero:Hero) {
		super.unmodify(hero);
		hero.targetsToPierce--;
		hero.shotsPerSecond /= 0.25;
		hero.accuracy /= 2;
	}
}
