package;

import flash.display.Sprite;

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
}