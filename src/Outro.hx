class Outro extends dn.Process {
	var logo:HSprite;
	var cm = new dn.Cinematic(Const.FPS);
	var textBox:h2d.Flow;

	public function new() {
		super(Main.ME);
		createRoot(Main.ME.root);

		logo = Assets.tiles.h_get("logo", root);
		logo.setCenterRatio(0, 0.5);

		textBox = new h2d.Flow(logo);
		textBox.layout = Vertical;
		textBox.verticalSpacing = 1;

		cm.create({
			tw.createMs(root.alpha, 0 > 1, 500);
			15000;
			tw.createMs(root.alpha, 0, 3000);
			3000;
			destroy();
		});
		var game = Game.ME;
		game.settings.outroPlayed = true;
		game.storage.saveSettings();
		text("Congratulations! You beat the boss!\n\n");
		text("Thanks for playing. We hope you enjoyed it!");
		text("You may continue playing with your current progress");
		text("to unlock anything else if you so please.");
		text("You won't see this screen again!");

		dn.Process.resizeAll();
	}

	function text(str:String, c = 0xFFFFFF) {
		var tf = new h2d.Text(Assets.fontPixelSmall, textBox);
		tf.textAlign = Center;
		tf.text = str;
		tf.textColor = c;
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
		var percent = 0.5;
		#if js
		percent = 0.55;
		#end
		logo.y = M.ceil(h() * percent / Const.SCALE);
		textBox.x = Main.ME.w() * 0.5 / Const.SCALE;
	}

	override function preUpdate() {
		super.preUpdate();
		cm.update(tmod);
	}
}
