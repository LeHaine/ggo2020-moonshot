package data;

import data.Traits.SplitShot;
import entity.Hero;

enum Tier {
	S;
	A;
	B;
	C;
}

class Attribute {
	public var name:String;
	public var value:Float;
	public var positive:Bool;
	public var isPercentage:Bool;

	public function new(name:String, value:Float, positive:Bool, isPercentage:Bool = false) {
		this.name = name;
		this.value = value;
		this.positive = positive;
		this.isPercentage = isPercentage;
	}
}

class Trait {
	public var name:String;
	public var icon:String;
	public var price:Int;
	public var desc:String;
	public var attributes:Array<Attribute> = [];
	public var tier:Tier;

	public function modify(hero:Hero) {}

	public function unmodify(hero:Hero) {}

	public function valueDifference():Float {
		return 0;
	}

	private function addAttribute(name:String, value:Float, positive:Bool = true, isPercentage:Bool = false) {
		attributes.push(new Attribute(name, value, positive, isPercentage));
	}
}

enum SelectTrait {
	// S
	GlassCannon;
	SplitShot;
	Rifle;
	Shotgun;
	Minigun;
	// A
	FasterCharge;
	BigExplosion;
	SecondaryDamage;
	// B
	PiercingShot;
	Tank;
	// C
	Runner;
	Damage;
	ShotsPerSecond;
	Armor;
	Life;
}

class TraitSelector {
	public static var tieredTraits = [
		Tier.S => [GlassCannon, SplitShot, Rifle, Shotgun, Minigun],
		Tier.A => [FasterCharge, BigExplosion, SecondaryDamage],
		Tier.B => [PiercingShot, Tank],
		Tier.C => [Runner, Damage, ShotsPerSecond, Armor, Life]
	];

	public static function chooseRandomTraitFromTier(tier:Tier) {
		var idx = Lib.irnd(0, tieredTraits[tier].length - 1);
		var trait = tieredTraits[tier][idx];

		return switch trait {
			case GlassCannon: new data.Traits.GlassCannon();
			case SplitShot: new data.Traits.SplitShot();
			case Shotgun: new data.Traits.Shotgun();
			case Rifle: new data.Traits.Rifle();
			case Minigun: new data.Traits.Minigun();
			case FasterCharge: new data.Traits.FasterCharge();
			case BigExplosion: new data.Traits.BigExplosion();
			case SecondaryDamage: new data.Traits.SecondaryDamage();
			case PiercingShot: new data.Traits.PiercingShot();
			case Tank: new data.Traits.Tank();
			case Runner: new data.Traits.Runner();
			case Damage: new data.Traits.Damage();
			case ShotsPerSecond: new data.Traits.ShotsPerSecond();
			case Armor: new data.Traits.Armor();
			case Life: new data.Traits.Life();
		}
	}
}
