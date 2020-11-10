package data;

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
