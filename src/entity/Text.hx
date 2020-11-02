package entity;

import h2d.Font;

class Text extends UIEntity {
	public var textData:h2d.Text;

	public function new(x:Int, y:Int, ?text:String = "", ?font:Font) {
		super(x, y);
		if (font == null) {
			font = Assets.fontPixel;
		}
		textData = new h2d.Text(font, spr);
		textData.text = text;
	}
}
