package entity;

class ModStation extends ScaledEntity {
	var data:World.Entity_ModStation;

	public function new(data:World.Entity_ModStation) {
		super(data.cx, data.cy);
		this.data = data;
		spr.set("modStation");
	}
}
