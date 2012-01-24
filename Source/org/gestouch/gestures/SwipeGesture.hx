package org.gestouch.gestures;

import org.gestouch.core.GestureState;
import org.gestouch.core.Touch;
import org.gestouch.events.SwipeGestureEvent;
import flash.display.InteractiveObject;
import org.gestouch.events.GesturePhase;
import nme.events.TouchEvent;
import flash.geom.Point;
import flash.system.Capabilities;

@:meta(Event(name="gestureSwipe",type="org.gestouch.events.SwipeGestureEvent"))
class SwipeGesture extends Gesture {

	public var numTouchesRequired : Int;
	public var velocityThreshold : Float;
	public var minVelocity : Float;
	public var minDistance : Float;
	public var direction : Int;
	var _offset : Point;
	var _startTime : Int;
	var _noDirection : Bool;
	public function new(target : InteractiveObject = null) {
		trace("new swipeGesture");
		numTouchesRequired = 1;
		velocityThreshold = 0.1;
		minVelocity = 1.5;
		minDistance = Capabilities.screenDPI * 0.5;
		direction = SwipeGestureDirection.ORTHOGONAL;
		_offset = new Point();
		super(target);
	}

	// --------------------------------------------------------------------------
	//
	// Public methods
	//
	// --------------------------------------------------------------------------
	override public function reflect() : Class<Dynamic> {
		return SwipeGesture;
	}

	override public function reset() : Void {
		_startTime = 0;
		_offset.x = 0;
		_offset.y = 0;
		super.reset();
	}

	// --------------------------------------------------------------------------
	//
	// Protected methods
	//
	// --------------------------------------------------------------------------
	override function onTouchBegin(touch : Touch, event : TouchEvent) : Void {
		trace( "swipe begin");
		if(touchesCount > numTouchesRequired)  {
			trace("too miuch touches");
			setState(GestureState.FAILED);
			return;
		}
		if(touchesCount == numTouchesRequired)  {
			updateLocation();
			_startTime = touch.time;
			// cache direction condition for performance
			_noDirection = (SwipeGestureDirection.ORTHOGONAL & direction) == 0;
		}
		trace("end swipe begin");
	}

	override function onTouchMove(touch : Touch, event : TouchEvent) : Void {
		trace("swipe move");
		if(touchesCount < numTouchesRequired) return;
		updateCentralPoint();
		trace("swipemove");
		_offset.x = _centralPoint.x - _location.x;
		_offset.y = _centralPoint.y - _location.y;
		var offsetLength : Float = _offset.length;
		var timeDelta : Int = touch.time - _startTime;
		var vel : Float = offsetLength / timeDelta;
		var absVel : Float = vel > (0) ? vel : -vel;
		//faster Math.abs()
		//			trace(_offset, _offset.length, ".....velocity:", vel);
		if(offsetLength > Gesture.DEFAULT_SLOP && absVel < velocityThreshold)  {
			setState(GestureState.FAILED);
			trace("swipefailed");
			return;
		}
		var velX : Float = _offset.x / timeDelta;
		var velY : Float = _offset.y / timeDelta;
		if(_noDirection)  {
			if(absVel >= minVelocity || (minDistance != minDistance || offsetLength >= minDistance))  {
				if(setState(GestureState.RECOGNIZED) && hasEventListener(SwipeGestureEvent.GESTURE_SWIPE))  {
					dispatchEvent(new SwipeGestureEvent(SwipeGestureEvent.GESTURE_SWIPE, false, false, GesturePhase.ALL, _localLocation.x, _localLocation.y, _offset.x, _offset.y));
				}
			}
		}

		else  {
			//faster Math.abs()
			var absVelX : Float = velX > (0) ? velX : -velX;
			var absVelY : Float = velY > (0) ? velY : -velY;
			var absOffsetX : Float = _offset.x > (0) ? _offset.x : -_offset.x;
			var absOffsetY : Float = _offset.y > (0) ? _offset.y : -_offset.y;
			if(absVelX > absVelY)  {
				if((SwipeGestureDirection.HORIZONTAL & direction) == 0)  {
					// horizontal velocity is greater then vertical, but we're not interested in any horizontal direction
					setState(GestureState.FAILED);
				}

				else if(velX < 0 && (direction & SwipeGestureDirection.LEFT) == 0)  {
					setState(GestureState.FAILED);
				}

				else if(velX > 0 && (direction & SwipeGestureDirection.RIGHT) == 0)  {
					setState(GestureState.FAILED);
				}

				else if(absVelX >= minVelocity || (minDistance != minDistance || absOffsetX >= minDistance))  {
					if(setState(GestureState.RECOGNIZED) && hasEventListener(SwipeGestureEvent.GESTURE_SWIPE))  {
						dispatchEvent(new SwipeGestureEvent(SwipeGestureEvent.GESTURE_SWIPE, false, false, GesturePhase.ALL, _localLocation.x, _localLocation.y, _offset.x, 0));
					}
				}
			}

			else if(absVelY > absVelX)  {
				if((SwipeGestureDirection.VERTICAL & direction) == 0)  {
					// horizontal velocity is greater then vertical, but we're not interested in any horizontal direction
					setState(GestureState.FAILED);
				}

				else if(velY < 0 && (direction & SwipeGestureDirection.UP) == 0)  {
					setState(GestureState.FAILED);
				}

				else if(velY > 0 && (direction & SwipeGestureDirection.DOWN) == 0)  {
					setState(GestureState.FAILED);
				}

				else if(absVelY >= minVelocity || (minDistance != minDistance || absOffsetY >= minDistance))  {
					if(setState(GestureState.RECOGNIZED) && hasEventListener(SwipeGestureEvent.GESTURE_SWIPE))  {
						dispatchEvent(new SwipeGestureEvent(SwipeGestureEvent.GESTURE_SWIPE, false, false, GesturePhase.ALL, _localLocation.x, _localLocation.y, 0, _offset.y));
					}
				}
			}

			else  {
				setState(GestureState.FAILED);
			}

		}
trace("end swipemove");
	}

	override function onTouchEnd(touch : Touch, event : TouchEvent) : Void {
		setState(GestureState.FAILED);
	}

}

