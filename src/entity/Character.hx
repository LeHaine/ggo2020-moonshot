package entity;

class Character extends ScaledEntity {
	var climbing = false;

	override function shouldCheckCeilingCollision():Bool {
		return !climbing;
	}

	public function startClimbing() {
		climbing = true;
		bdx *= 0.2;
		bdy *= 0.2;
		dx *= 0.3;
		dy *= 0.1;
	}

	public function stopClimbing() {
		climbing = false;
	}
}
