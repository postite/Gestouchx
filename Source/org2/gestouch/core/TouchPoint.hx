/**
 * @author Pavel fljot
 */
package org.gestouch.core;

import flash.geom.Point;

class TouchPoint extends Point {

	public var id : Int;
	public var localX : Float;
	public var localY : Float;
	public var sizeX : Float;
	public var sizeY : Float;
	public var pressure : Float;
	public var touchBeginPos : Point;
	public var touchBeginTime : Int;
	public var moveOffset : Point;
	public var lastMove : Point;
	public var lastTime : Int;
	public var velocity : Point;
	public function new(id : Int = 0, x : Float = 0, y : Float = 0, sizeX : Float = null, sizeY : Float = null, pressure : Float = null, touchBeginPos : Point = null, touchBeginTime : Int = 0, moveOffset : Point = null, lastMove : Point = null, lastTime : Int = 0, velocity : Point = null) {
		super(x, y);
		this.id = id;
		this.sizeX = sizeX;
		this.sizeY = sizeY;
		this.pressure = pressure;
		

		this.touchBeginPos = (touchBeginPos!=null)? touchBeginPos :  new Point();
			this.touchBeginTime = touchBeginTime;
			this.moveOffset = (moveOffset!=null)? moveOffset :  new Point();
			this.lastMove = (lastMove!=null)? lastMove :  new Point();
			this.lastTime = lastTime;
			this.velocity = (velocity!=null)? velocity :  new Point();
	}

	override public function clone() : Point {
		var p : TouchPoint = new TouchPoint(id, x, y, sizeX, sizeY, pressure, touchBeginPos.clone(), touchBeginTime, moveOffset.clone(), lastMove.clone(), lastTime, velocity.clone());
		return p;
	}

	public function reset() : Void {
	}

	override public function toString() : String {
		return "Touch point [id: " + id + ", x: " + x + ", y: " + y + ", ...]";
	}

}

