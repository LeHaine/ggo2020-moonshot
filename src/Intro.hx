class Intro extends dn.Process {
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
			3000;
			tw.createMs(root.alpha, 0, 3000);
			3000;
			destroy();
			Main.ME.startGame();
		});
		text("A game by Colt Daily / LeHaine");
		text("Programming, design, art by Colt Daily");
		text("Sound effects and music by Andrew Tran");
		text("Art by D");

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
		#if js
		textBox.x = logo.getBounds().width * 0.5 / Const.SCALE - textBox.outerWidth;
		#else
		textBox.x = logo.getBounds().width * 0.5 / Const.SCALE - textBox.outerWidth * 0.5;
		#end
	}

	override function preUpdate() {
		super.preUpdate();
		cm.update(tmod);
	}
}
