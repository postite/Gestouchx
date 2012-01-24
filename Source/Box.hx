package;

import flash.display.Sprite;
import nme.Assets;
import nme.display.Bitmap;

class Box extends Sprite
{
	public function new()
	{
		super();
		this.draw();

	}

	private function draw() 
	{
		this.graphics.beginFill(0xaaddaa);
		this.graphics.drawRect(-200,-200,400,400);
	}

	public function load() 
	{
		var logo = new Bitmap (Assets.getBitmapData ("assets/pavatar.png"));
		addChild(logo);
	}
}