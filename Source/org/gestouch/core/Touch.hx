/**
 * TODO:
 * - maybe add "phase" (began, moved, stationary, ended)?
 * 
 * @author Pavel fljot
 */
package org.gestouch.core;

import nme.display.InteractiveObject;

class Touch {

	/**
	 * Touch point ID.
	 */
	public var id : Int;
	/**
	 * The original event target for this touch (touch began with).
	 */
	public var target : InteractiveObject;
	public var x : Float;
	public var y : Float;
	public var sizeX : Float;
	public var sizeY : Float;
	public var pressure : Float;
	public var time : Int;
	//		public var touchBeginPos:Point;
	//		public var touchBeginTime:Int;
	//		public var moveOffset:Point;
	//		public var lastMove:Point;
	//		public var velocity:Point;
	public function new(id : Int = 0) {
		this.id = id;
	}

	public function clone() : Touch {
		//trace("clone");
		var touch : Touch = new Touch(id);
		touch.x = x;
		touch.y = y;
		touch.target = target;
		touch.sizeX = sizeX;
		touch.sizeY = sizeY;
		touch.pressure = pressure;
		touch.time = time;
		return touch;
	}

	public function toString() : String {
		return "Touch [id: " + id + ", x: " + x + ", y: " + y + ", ...]";
	}

}

