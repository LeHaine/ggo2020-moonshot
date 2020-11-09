package data;

class SplitShot extends WeaponTrait {
	public function new() {
		name = "Split Shot";
		icon = "splitShotIcon";
		desc = "Splits primary attack into two weaker projectiles.";
		attribute = "Projectiles shot";
		attributeValue = 1;
		price = 100;
	}
}
