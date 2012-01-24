package org.gestouch.gestures;

import org.gestouch.Direction;
import org.gestouch.GestureUtils;
import org.gestouch.core.GesturesManager;
import org.gestouch.core.TouchPoint;
import org.gestouch.core.Gestouch_internal;
import org.gestouch.events.SwipeGestureEvent;
import flash.display.InteractiveObject;
import flash.events.GesturePhase;
import flash.geom.Point;
import flash.utils.GetTimer;

@:meta(Event(name="gestureSwipe",type="org.gestouch.events.SwipeGestureEvent"))
class SwipeGesture extends MovingGestureBase {

	public var moveThreshold : Float;
	public var minTimeThreshold : Int;
	public var velocityThreshold : Float;
	public var sideVelocityThreshold : Float;
	var _startTime : Int;
	public function new(target : InteractiveObject = null, settings : Dynamic = null) {
		moveThreshold = Gesture.DEFAULT_SLOP;
		minTimeThreshold = 50;
		velocityThreshold = 7 * GestureUtils.IPS_TO_PPMS;
		sideVelocityThreshold = 2 * GestureUtils.IPS_TO_PPMS;
		super(target, settings);
	}

	//--------------------------------------------------------------------------
	//
	//  Static methods
	//
	//--------------------------------------------------------------------------
	static public function add(target : InteractiveObject, settings : Dynamic = null) : SwipeGesture {
		return new SwipeGesture(target, settings);
	}

	static public function remove(target : InteractiveObject) : SwipeGesture {
		return try cast(GesturesManager.gestouch_internal::removeGestureByTarget(SwipeGesture, target), SwipeGesture) catch(e) null;
	}

	//--------------------------------------------------------------------------
	//
	//  Public methods
	//
	//--------------------------------------------------------------------------
	override public function reflect() : Class<Dynamic> {
		return SwipeGesture;
	}

	override public function onTouchBegin(touchPoint : TouchPoint) : Void {
		// No need to track more points than we need
		if(_trackingPointsCount == maxTouchPointsCount)  {
			return;
		}
		_trackPoint(touchPoint);
	}

	override public function onTouchMove(touchPoint : TouchPoint) : Void {
		// do calculations only when we track enought points
		if(_trackingPointsCount < minTouchPointsCount)  {
			return;
		}
		_updateCentralPoint();
		if(!_slopPassed)  {
			_slopPassed = _checkSlop(_centralPoint.moveOffset);
		}
		if(_slopPassed)  {
			var velocity : Point = _centralPoint.velocity;
			var foo : Float = _centralPoint.moveOffset.length;
			//FIXME!
			var swipeDetected : Bool = false;
			if(getTimer() - _startTime > minTimeThreshold && foo > 10)  {
				var lastMoveX : Float = 0;
				var lastMoveY : Float = 0;
				if(_canMoveHorizontally && _canMoveVertically)  {
					lastMoveX = _centralPoint.lastMove.x;
					lastMoveY = _centralPoint.lastMove.y;
					if(direction == Direction.STRAIGHT_AXES)  {
						// go to logic below: if (!swipeDetected && _canMove*)..
					}

					else if(direction == Direction.OCTO)  {
						swipeDetected = velocity.length >= velocityThreshold;
						if(Math.abs(velocity.y) < sideVelocityThreshold)  {
							// horizontal swipe
							lastMoveY = 0;
						}

						else if(Math.abs(velocity.x) < sideVelocityThreshold)  {
							// vertical swipe
							lastMoveX = 0;
						}
					}

					else  {
						// free direction swipe
						swipeDetected = velocity.length >= velocityThreshold;
					}

				}
				if(!swipeDetected && _canMoveHorizontally)  {
					swipeDetected = Math.abs(velocity.x) >= velocityThreshold && Math.abs(velocity.y) < sideVelocityThreshold;
					lastMoveX = _centralPoint.lastMove.x;
					lastMoveY = 0;
				}
				if(!swipeDetected && _canMoveVertically)  {
					swipeDetected = Math.abs(velocity.y) >= velocityThreshold && Math.abs(velocity.x) < sideVelocityThreshold;
					lastMoveX = 0;
					lastMoveY = _centralPoint.lastMove.y;
				}
				if(swipeDetected)  {
					_reset();
					//						trace("swipe detected:", lastMoveX, lastMoveY);
					_dispatch(new SwipeGestureEvent(SwipeGestureEvent.GESTURE_SWIPE, true, false, GesturePhase.ALL, target.mouseX, target.mouseY, 1, 1, 0, lastMoveX, lastMoveY));
				}
			}
		}
	}

	override public function onTouchEnd(touchPoint : TouchPoint) : Void {
		_forgetPoint(touchPoint);
	}

}

