package org.gestouch.gestures;

import org.gestouch.core.GestureState;
import org.gestouch.core.Touch;
import org.gestouch.events.RotateGestureEvent;
import org.gestouch.utils.GestureUtils;
import nme.display.InteractiveObject;
import org.gestouch.events.GesturePhase;
import nme.events.TouchEvent;
import nme.geom.Point;

@:meta(Event(name="gestureRotate",type="org.gestouch.events.RotateGestureEvent"))
class RotateGesture extends Gesture {

	public var slop : Float;
	var _touchBeginX : IntHash<Float>;
	var _touchBeginY : IntHash<Float>;
	var _rotationVector : Point;
	var _firstTouch : Touch;
	var _secondTouch : Touch;
	public function new(target : InteractiveObject = null) {
		slop = Gesture.DEFAULT_SLOP >> 1;
		_touchBeginX = new IntHash<Float>();
		_touchBeginY = new IntHash<Float>();
		_rotationVector = new Point();
		super(target);
	}

	// --------------------------------------------------------------------------
	//
	// Public methods
	//
	// --------------------------------------------------------------------------
	override public function reflect() : Class<Dynamic> {
		return RotateGesture;
	}

	override public function reset() : Void {
		_touchBeginX =new IntHash<Float>();
		_touchBeginY = new IntHash<Float>();
		super.reset();
	}

	// --------------------------------------------------------------------------
	//
	// Protected methods
	//
	// --------------------------------------------------------------------------
	override function onTouchBegin(touch : Touch, event : TouchEvent) : Void {
		if(touchesCount > 2)  {
			//TODO
			trace("ignoretouch");
			ignoreTouch(touch, event);
			return;
		}
		if(touchesCount == 1)  {
			trace("onetouch");
			_firstTouch = touch;
		}

		else  {
			trace("twotouch");
			_secondTouch = touch;
			
			// _touchBeginX[_firstTouch.id] = _firstTouch.x;
			// _touchBeginY[_firstTouch.id] = _firstTouch.y;
			// _touchBeginX[_secondTouch.id] = _secondTouch.x;
			// _touchBeginY[_secondTouch.id] = _secondTouch.y;
			_touchBeginX.set(_firstTouch.id,_firstTouch.x);
			//_touchBeginX[_firstTouch.id] = _firstTouch.x;
			_touchBeginY.set(_firstTouch.id,_firstTouch.y);
			//_touchBeginY[_firstTouch.id] = _firstTouch.y;
			_touchBeginX.set(_secondTouch.id,_secondTouch.x);
			//_touchBeginX[_secondTouch.id] = _secondTouch.x;
			_touchBeginY.set(_secondTouch.id,_secondTouch.y);
			//_touchBeginY[_secondTouch.id] = _secondTouch.y;
			_rotationVector.x = _secondTouch.x - _firstTouch.x;
			_rotationVector.y = _secondTouch.y - _firstTouch.y;
		}

	}

	override function onTouchMove(touch : Touch, event : TouchEvent) : Void {
		if(touch.id == _firstTouch.id)  {
			_firstTouch = touch;
		}

		else  {
			_secondTouch = touch;
		}

		if(touchesCount == 2)  {
			trace ("Count==2");
			var currRotationVector : Point = new Point(_secondTouch.x - _firstTouch.x, _secondTouch.y - _firstTouch.y);
			var recognized : Bool=false;
			if(state == GestureState.POSSIBLE)  {
				// we start once any finger moved enough
				var dx : Float = _touchBeginX.get(touch.id) /* WARNING check type */ - touch.x;
				//var dx : Float = Std.parseFloat(_touchBeginX[touch.id]) /* WARNING check type */ - touch.x;
				var dy : Float = _touchBeginY.get(touch.id) /* WARNING check type */ - touch.x;
				//var dy : Float = Std.parseFloat(_touchBeginY[touch.id]) /* WARNING check type */ - touch.y;
				if(Math.sqrt(dx * dx + dy * dy) > slop || slop != slop) //faster isNaN(slop)

				 {
					recognized = true;
					_rotationVector.x = _secondTouch.x - _firstTouch.x;
					_rotationVector.y = _secondTouch.y - _firstTouch.y;
				}

			}

			else  {
				recognized = true;
			}

			if(recognized)  {
				updateLocation();
				var rotation : Float = Math.atan2(currRotationVector.y, currRotationVector.x) - Math.atan2(_rotationVector.y, _rotationVector.x);
				rotation *= GestureUtils.RADIANS_TO_DEGREES;
				_rotationVector.x = currRotationVector.x;
				_rotationVector.y = currRotationVector.y;
				if(state == GestureState.POSSIBLE)  {
					if(setState(GestureState.BEGAN) && hasEventListener(RotateGestureEvent.GESTURE_ROTATE))  {
						dispatchEvent(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, false, false, GesturePhase.BEGIN, _localLocation.x, _localLocation.y, rotation));
					}
				}

				else  {
					if(setState(GestureState.CHANGED) && hasEventListener(RotateGestureEvent.GESTURE_ROTATE))  {
						dispatchEvent(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, false, false, GesturePhase.UPDATE, _localLocation.x, _localLocation.y, rotation));
					}
				}

			}
		}
	}

	override function onTouchEnd(touch : Touch, event : TouchEvent) : Void {
		if(touchesCount == 0)  {
			if(state == GestureState.BEGAN || state == GestureState.CHANGED)  {
				if(setState(GestureState.ENDED) && hasEventListener(RotateGestureEvent.GESTURE_ROTATE))  {
					dispatchEvent(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, false, false, GesturePhase.END, _localLocation.x, _localLocation.y, 0));
				}
			}

			else if(state == GestureState.POSSIBLE)  {
				setState(GestureState.FAILED);
			}
		}

		else // == 1
		 {
			if(touch.id == _firstTouch.id)  {
				_firstTouch = _secondTouch;
			}
			if(state == GestureState.BEGAN || state == GestureState.CHANGED)  {
				updateLocation();
				if(setState(GestureState.CHANGED) && hasEventListener(RotateGestureEvent.GESTURE_ROTATE))  {
					dispatchEvent(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, false, false, GesturePhase.UPDATE, _localLocation.x, _localLocation.y, 0));
				}
			}
		}

	}

}

