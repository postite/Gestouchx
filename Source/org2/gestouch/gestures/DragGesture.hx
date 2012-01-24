package org.gestouch.gestures;

import org.gestouch.core.GesturesManager;
import org.gestouch.core.TouchPoint;
import org.gestouch.core.Gestouch_internal;
import org.gestouch.events.DragGestureEvent;
import flash.display.InteractiveObject;
import flash.events.GesturePhase;
import flash.geom.Point;

@:meta(Event(name="gestureDrag",type="org.gestouch.events.DragGestureEvent"))
class DragGesture extends MovingGestureBase {

	public function new(target : InteractiveObject = null, settings : Dynamic = null) {
		super(target, settings);
	}

	//--------------------------------------------------------------------------
	//
	//  Static methods
	//
	//--------------------------------------------------------------------------
	static public function add(target : InteractiveObject, settings : Dynamic = null) : DragGesture {
		return new DragGesture(target, settings);
	}

	static public function remove(target : InteractiveObject) : DragGesture {
		return try cast(GesturesManager.gestouch_internal::removeGestureByTarget(DragGesture, target), DragGesture) catch(e) null;
	}

	//--------------------------------------------------------------------------
	//
	//  Public methods
	//
	//--------------------------------------------------------------------------
	override public function reflect() : Class<Dynamic> {
		return DragGesture;
	}

	override public function onTouchBegin(touchPoint : TouchPoint) : Void {
		// No need to track more points than we need
		if(_trackingPointsCount == maxTouchPointsCount)  {
			return;
		}
		_trackPoint(touchPoint);
		if(_trackingPointsCount > 1)  {
			_updateCentralPoint();
			_centralPoint.lastMove.x = _centralPoint.lastMove.y = 0;
		}
	}

	override public function onTouchMove(touchPoint : TouchPoint) : Void {
		// do calculations only when we track enough points
		if(_trackingPointsCount < minTouchPointsCount)  {
			return;
		}
		_updateCentralPoint();
		if(!_slopPassed)  {
			_slopPassed = _checkSlop(_centralPoint.moveOffset);
			if(_slopPassed)  {
				var slopVector : Point = slop > (0) ? null : new Point();
				if(!slopVector)  {
					if(_canMoveHorizontally && _canMoveVertically)  {
						slopVector = _centralPoint.moveOffset.clone();
						slopVector.normalize(slop);
						slopVector.x = Math.round(slopVector.x);
						slopVector.y = Math.round(slopVector.y);
					}

					else if(_canMoveVertically)  {
						slopVector = new Point(0, _centralPoint.moveOffset.y >= (slop) ? slop : -slop);
					}

					else if(_canMoveHorizontally)  {
						slopVector = new Point(_centralPoint.moveOffset.x >= (slop) ? slop : -slop, 0);
					}
				}
				_centralPoint.lastMove = _centralPoint.moveOffset.subtract(slopVector);
				_dispatch(new DragGestureEvent(DragGestureEvent.GESTURE_DRAG, true, false, GesturePhase.BEGIN, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y, 1, 1, 0, _centralPoint.lastMove.x, _centralPoint.lastMove.y));
			}
		}

		else  {
			_dispatch(new DragGestureEvent(DragGestureEvent.GESTURE_DRAG, true, false, GesturePhase.UPDATE, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y, 1, 1, 0, _centralPoint.lastMove.x, _centralPoint.lastMove.y));
		}

	}

	override public function onTouchEnd(touchPoint : TouchPoint) : Void {
		var ending : Bool = (_slopPassed && _trackingPointsCount == minTouchPointsCount);
		_forgetPoint(touchPoint);
		_updateCentralPoint();
		if(ending)  {
			_reset();
			_dispatch(new DragGestureEvent(DragGestureEvent.GESTURE_DRAG, true, false, GesturePhase.END, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y, 1, 1, 0, 0, 0));
		}
	}

}

