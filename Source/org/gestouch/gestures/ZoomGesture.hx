package org.gestouch.gestures;

import org.gestouch.core.GestureState;
import org.gestouch.core.Touch;
import org.gestouch.events.ZoomGestureEvent;
import nme.display.InteractiveObject;
import org.gestouch.events.GesturePhase;
import nme.events.TouchEvent;
import nme.geom.Point;

@:meta(Event(name="gestureZoom",type="org.gestouch.events.ZoomGestureEvent"))
class ZoomGesture extends Gesture {

	public var slop : Float;
	public var lockAspectRatio : Bool;
	var _touchBeginX : IntHash<Float>;
	var _touchBeginY : IntHash<Float>;
	var _scaleVector : Point;
	var _firstTouch : Touch;
	var _secondTouch : Touch;
	public function new(target : InteractiveObject = null) {
		slop = Gesture.DEFAULT_SLOP >> 1;
		lockAspectRatio = true;
		_touchBeginX = new IntHash<Float>();
		_touchBeginY = new IntHash<Float>();
		_scaleVector = new Point();
		super(target);
	}

	// --------------------------------------------------------------------------
	//
	// Public methods
	//
	// --------------------------------------------------------------------------
	override public function reflect() : Class<Dynamic> {
		return ZoomGesture;
	}

	override public function reset() : Void {
		_touchBeginX = new IntHash<Float>();
		_touchBeginY= new IntHash<Float>();
		super.reset();
	}

	// --------------------------------------------------------------------------
	//
	// Protected methods
	//
	// --------------------------------------------------------------------------
	override function onTouchBegin(touch : Touch, event : TouchEvent) : Void {
		trace("zoomGesture on TouchBegin"+touchesCount);
		if(touchesCount > 2)  {
			//TODO
			trace("ignore touch");
			ignoreTouch(touch, event);
			return;
		}
		if(touchesCount == 1)  {
			trace("zoomGesture one Touch");
			_firstTouch = touch;
		}

		else // == 2
		 {
		 	trace("zoomGesture 2 touches");
			_secondTouch = touch;
			_touchBeginX.set(_firstTouch.id,_firstTouch.x);
			//_touchBeginX[_firstTouch.id] = _firstTouch.x;
			_touchBeginY.set(_firstTouch.id,_firstTouch.y);
			//_touchBeginY[_firstTouch.id] = _firstTouch.y;
			_touchBeginX.set(_secondTouch.id,_secondTouch.x);
			//_touchBeginX[_secondTouch.id] = _secondTouch.x;
			_touchBeginY.set(_secondTouch.id,_secondTouch.y);
			//_touchBeginY[_secondTouch.id] = _secondTouch.y;
			_scaleVector.x = _secondTouch.x - _firstTouch.x;
			_scaleVector.y = _secondTouch.y - _firstTouch.y;
		}

	}

	override function onTouchMove(touch : Touch, event : TouchEvent) : Void {
		//trace("touchmove");
		if(touch.id == _firstTouch.id)  {
			_firstTouch = touch;
		}

		else  {
			_secondTouch = touch;
		}

		if(touchesCount == 2)  {
			trace ("Count==2");
			var currScaleVector : Point = new Point(_secondTouch.x - _firstTouch.x, _secondTouch.y - _firstTouch.y);
			var recognized : Bool=false;
			if(state == GestureState.POSSIBLE)  {
				// Check if finger moved enough for gesture to be recognized
				var dx : Float = _touchBeginX.get(touch.id) /* WARNING check type */ - touch.x;
				var dy : Float = _touchBeginY.get(touch.id) /* WARNING check type */ - touch.y;
				if(Math.sqrt(dx * dx + dy * dy) > slop || slop != slop) //faster isNaN(slop)

				 {
					recognized = true;
					_scaleVector.x = _secondTouch.x - _firstTouch.x;
					_scaleVector.y = _secondTouch.y - _firstTouch.y;
				}

			}

			else  {
				recognized = true;
			}

			if(recognized)  {
				updateLocation();
				var scaleX : Float;
				var scaleY : Float;
				if(lockAspectRatio)  {
					scaleX = scaleY = currScaleVector.length / _scaleVector.length;
				}

				else  {
					scaleX = currScaleVector.x / _scaleVector.x;
					scaleY = currScaleVector.y / _scaleVector.y;
				}

				_scaleVector.x = currScaleVector.x;
				_scaleVector.y = currScaleVector.y;
				if(state == GestureState.POSSIBLE)  {
					if(setState(GestureState.BEGAN) && hasEventListener(ZoomGestureEvent.GESTURE_ZOOM))  {
						dispatchEvent(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GesturePhase.BEGIN, _localLocation.x, _localLocation.y, scaleX, scaleY));
					}
				}

				else  {
					if(setState(GestureState.CHANGED) && hasEventListener(ZoomGestureEvent.GESTURE_ZOOM))  {
						dispatchEvent(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GesturePhase.UPDATE, _localLocation.x, _localLocation.y, scaleX, scaleY));
					}
				}

			}
		}
	}

	override function onTouchEnd(touch : Touch, event : TouchEvent) : Void {
		trace ("touch end");
		if(touchesCount == 0)  {
			if(state == GestureState.BEGAN || state == GestureState.CHANGED)  {
				if(setState(GestureState.ENDED) && hasEventListener(ZoomGestureEvent.GESTURE_ZOOM))  {
					dispatchEvent(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GesturePhase.END, _localLocation.x, _localLocation.y, 1, 1));
				}
			}

			else if(state == GestureState.POSSIBLE)  {
				setState(GestureState.FAILED);
			}
		}

		else //== 1
		 {
			if(touch.id == _firstTouch.id)  {
				_firstTouch = _secondTouch;
			}
			if(state == GestureState.BEGAN || state == GestureState.CHANGED)  {
				updateLocation();
				if(setState(GestureState.CHANGED) && hasEventListener(ZoomGestureEvent.GESTURE_ZOOM))  {
					dispatchEvent(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GesturePhase.UPDATE, _localLocation.x, _localLocation.y, 1, 1));
				}
			}
		}

	}

}

