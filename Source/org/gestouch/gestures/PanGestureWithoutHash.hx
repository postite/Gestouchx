package org.gestouch.gestures;

import org.gestouch.events.PanGestureEvent;
import org.gestouch.core.GestureState;
import org.gestouch.core.Touch;
import org.gestouch.events.ZoomGestureEvent;
import nme.display.InteractiveObject;
import org.gestouch.events.GesturePhase;
import nme.events.TouchEvent;
import nme.geom.Point;

@:meta(Event(name="gesturePan",type="org.gestouch.events.PanGestureEvent"))
class PanGesture extends Gesture {
	public var maxNumTouchesRequired(getMaxNumTouchesRequired, setMaxNumTouchesRequired) : Int;
	public var minNumTouchesRequired(getMinNumTouchesRequired, setMinNumTouchesRequired) : Int;

	public var slop : Float;
	var _touchBeginX : IntHash<Float>;
	var _touchBeginY : IntHash<Float>;
	public function new(target : InteractiveObject = null) {
		slop = Gesture.DEFAULT_SLOP;
		_touchBeginX = new IntHash<Float>();
		_touchBeginY = new IntHash<Float>();
		_maxNumTouchesRequired = 1;
		_minNumTouchesRequired = 1;
		super(target);
	}

	/** @private */
	var _maxNumTouchesRequired : Int;
	/**
	 * 
	 */
	public function getMaxNumTouchesRequired() : Int {
		return _maxNumTouchesRequired;
	}

	public function setMaxNumTouchesRequired(value : Int) : Int {
		if(_maxNumTouchesRequired == value) return 0;
		if(value < minNumTouchesRequired) throw ("maxNumTouchesRequired must be not less then minNumTouchesRequired");
		_maxNumTouchesRequired = value;
		return value;
	}

	/** @private */
	var _minNumTouchesRequired : Int;
	/**
	 * 
	 */
	public function getMinNumTouchesRequired() : Int {
		return _minNumTouchesRequired;
	}

	public function setMinNumTouchesRequired(value : Int) : Int {
		if(_minNumTouchesRequired == value) return 0;
		if(value > maxNumTouchesRequired) ("minNumTouchesRequired must be not greater then maxNumTouchesRequired");
		_minNumTouchesRequired = value;
		return value;
	}

	// --------------------------------------------------------------------------
	//
	// Public methods
	//
	// --------------------------------------------------------------------------
	override public function reflect() : Class<Dynamic> {
		return PanGesture;
	}

	override public function reset() : Void {
		_touchBeginX = new IntHash<Float>();
		_touchBeginY = new IntHash<Float>();
		super.reset();
	}

	// --------------------------------------------------------------------------
	//
	// Protected methods
	//
	// --------------------------------------------------------------------------
	override function onTouchBegin(touch : Touch, event : TouchEvent) : Void {
		if(touchesCount > maxNumTouchesRequired)  {
			//TODO
			ignoreTouch(touch, event);
			return;
		}
		_touchBeginX.set(touch.id,touch.x);
		//_touchBeginX[touch.id] = touch.x;
		_touchBeginY.set(touch.id,touch.y);
		//_touchBeginY[touch.id] = touch.y;
		if(touchesCount >= minNumTouchesRequired)  {
			updateLocation();
		}
	}

	override function onTouchMove(touch : Touch, event : TouchEvent) : Void {
		if(touchesCount < minNumTouchesRequired) return;
		var prevLocationX : Float;
		var prevLocationY : Float;
		var offsetX : Float;
		var offsetY : Float;
		if(state == GestureState.POSSIBLE)  {
			// Check if finger moved enough for gesture to be recognized
			var dx : Float = _touchBeginX.get(touch.id) /* WARNING check type */ - touch.x;
			var dy : Float = _touchBeginY.get(touch.id) /* WARNING check type */ - touch.y;
			if(Math.sqrt(dx * dx + dy * dy) > slop || slop != slop) //faster isNaN(slop)

			 {
				prevLocationX = _location.x;
				prevLocationY = _location.y;
				updateLocation();
				offsetX = _location.x - prevLocationX;
				offsetY = _location.y - prevLocationY;
				// Unfortunately we create several new point instances here,
				// but thats not a big deal since this code executed only once per recognition session
				var offset : Point = new Point(offsetX, offsetY);
				if(offset.length > slop)  {
					var slopVector : Point = offset.clone();
					slopVector.normalize(slop);
					offset = offset.subtract(slopVector);
				}
				if(setState(GestureState.BEGAN) && hasEventListener(PanGestureEvent.GESTURE_PAN))  {
					dispatchEvent(new PanGestureEvent(PanGestureEvent.GESTURE_PAN, false, false, GesturePhase.BEGIN, _localLocation.x, _localLocation.y, offset.x, offset.y));
				}
			}

		}

		else if(state == GestureState.BEGAN || state == GestureState.CHANGED)  {
			prevLocationX = _location.x;
			prevLocationY = _location.y;
			updateLocation();
			offsetX = _location.x - prevLocationX;
			offsetY = _location.y - prevLocationY;
			if(setState(GestureState.CHANGED) && hasEventListener(PanGestureEvent.GESTURE_PAN))  {
				dispatchEvent(new PanGestureEvent(PanGestureEvent.GESTURE_PAN, false, false, GesturePhase.UPDATE, _localLocation.x, _localLocation.y, offsetX, offsetY));
			}
		}
	}

	override function onTouchEnd(touch : Touch, event : TouchEvent) : Void {
		if(touchesCount < minNumTouchesRequired)  {
			if(state == GestureState.POSSIBLE)  {
				setState(GestureState.FAILED);
			}

			else  {
				if(setState(GestureState.ENDED) && hasEventListener(PanGestureEvent.GESTURE_PAN))  {
					dispatchEvent(new PanGestureEvent(PanGestureEvent.GESTURE_PAN, false, false, GesturePhase.END, _localLocation.x, _localLocation.y, 0, 0));
				}
			}

		}

		else  {
			updateLocation();
		}

	}

}

