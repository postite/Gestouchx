/**
 * @author Pavel fljot
 */
package org.gestouch.core;

import org.gestouch.events.MouseTouchEvent;
import org.gestouch.utils.ObjectPool;
import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flash.utils.Dictionary;


class GesturesManager implements IGesturesManager {

	static public var implementation : IGesturesManager;
	static var _impl : IGesturesManager;
	static var _initialized : Bool = false;
	var _stage : Stage;
	var _gestures : Array<IGesture>;
	var _currGestures : Array<IGesture>;
	/**
	 * Maps (Dictionary[target] = gesture) by gesture type.
	 */
	var _gestureMapsByType : Dictionary;
	var _touchPoints : Array<TouchPoint>;
	var _touchPointsPool : ObjectPool;


	 function new(){
		
	}
	public static function addGesture(gesture : IGesture) : IGesture {
		if(_impl==null)  {
			_impl = (implementation !=null)? implementation : cast new GesturesManager(); 
		}
		return _impl._addGesture(gesture);
	}

	public static function removeGesture(gesture : IGesture) : IGesture {
		return _impl._removeGesture(gesture);
	}

	public static function removeGestureByTarget(gestureType : Class<Dynamic>, target : InteractiveObject) : IGesture {
		return _impl._removeGestureByTarget(gestureType, target);
	}

	public static function cancelGesture(gesture : IGesture) : Void {
		_impl._cancelGesture(gesture);
	}

	public static function addCurrentGesture(gesture : IGesture) : Void {
		_impl._addCurrentGesture(gesture);
	}

	public static function updateGestureTarget(gesture : IGesture, oldTarget : InteractiveObject, newTarget : InteractiveObject) : Void {
		_impl._updateGestureTarget(gesture, oldTarget, newTarget);
	}

	public function init(stage : Stage) : Void {
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		_stage = stage;
		_stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler);
		_stage.addEventListener(TouchEvent.TOUCH_BEGIN, stage_touchBeginHandler);
		_stage.addEventListener(TouchEvent.TOUCH_MOVE, stage_touchMoveHandler);
		_stage.addEventListener(TouchEvent.TOUCH_END, stage_touchEndHandler, true);
	}

	static public function getTouchPoint(touchPointID : Int) : TouchPoint {
		return _impl._getTouchPoint(touchPointID);
	}

	public function _addGesture(gesture : IGesture) : IGesture {
		if(Lambda.indexOf(_gestures,gesture) > -1)  {
			throw new IllegalOperationError("Gesture instace '" + gesture + "' is already registered.");
		}
		_gestures.push(gesture);
		return gesture;
	}

	public function _removeGesture(gesture : IGesture) : IGesture {
		var index:Int = Lambda.indexOf(_gestures,gesture);
		
		if(index == -1)  {
			throw new IllegalOperationError("Gesture instace '" + gesture + "' is not registered.");
		}
		_gestures.splice(index, 1);
		index = Lambda.indexOf(_currGestures,gesture);
		
		if(index > -1)  {
			_currGestures.splice(index, 1);
		}
		gesture.dispose();
		return gesture;
	}

	public function _removeGestureByTarget(gestureType : Class<Dynamic>, target : InteractiveObject) : IGesture {
		var gesture : IGesture = _getGestureByTarget(gestureType, target);
		return removeGesture(gesture);
	}

	public function _getGestureByTarget(gestureType : Class<Dynamic>, target : InteractiveObject) : IGesture {
		var gesturesOfTypeByTarget : Dictionary = try cast(_gestureMapsByType[gestureType], Dictionary) catch(e:String) null;
		var gesture : IGesture = (gesturesOfTypeByTarget) ? try cast(gesturesOfTypeByTarget[target], IGesture) catch(e:String) null : null;
		return gesture;
	}

	public function _cancelGesture(gesture : IGesture) : Void {

		var index : Int = Lambda.indexOf(_currGestures,gesture);
		if(index == -1)  {
			return;
			// don't see point in throwing error
		}
		_currGestures.splice(index, 1);
		gesture.onCancel();
	}

	public function _addCurrentGesture(gesture : IGesture) : Void {
		if(Lambda.indexOf(_currGestures,gesture) == -1 ) {
			_currGestures.push(gesture);
		}
	}

	public function _updateGestureTarget(gesture : IGesture, oldTarget : InteractiveObject, newTarget : InteractiveObject) : Void {
		if(!_initialized && newTarget!=null)  {
			var stage : Stage = newTarget.stage;
			if(stage!=null)  {
				_impl.init(stage);
				_initialized = true;
			}

			else  {
				newTarget.addEventListener(Event.ADDED_TO_STAGE, target_addedToStageHandler, false, 0, true);
			}

		}
		var gesturesOfTypeByTarget : Dictionary = try cast(_gestureMapsByType[gesture.reflect()], Dictionary) catch(e:String) null;
		if(gesturesOfTypeByTarget==null)  {
			gesturesOfTypeByTarget = _gestureMapsByType[gesture.reflect()] = new Dictionary();
		}

		else if(gesturesOfTypeByTarget[newTarget])  {
			throw new IllegalOperationError("You cannot add two gestures of the same type to one target (it makes no sence).");
		}
		if(oldTarget!=null)  {
			oldTarget.addEventListener(Event.ADDED_TO_STAGE, target_addedToStageHandler);
			//delete gesturesOfTypeByTarget[oldTarget]; PORTODO
			gesturesOfTypeByTarget[oldTarget];
		}
		if(newTarget!=null)  {
			gesturesOfTypeByTarget[newTarget] = gesture;
		}
	}

	public function _getTouchPoint(touchPointID : Int) : TouchPoint {
		var p : TouchPoint = _touchPoints[touchPointID];
		if(p==null)  {
			throw ("No touch point with ID " + touchPointID + " found.");
		}
		return try cast(p.clone(), TouchPoint) catch(e:String) null;
	}

	static function target_addedToStageHandler(event : Event) : Void {
		var target : InteractiveObject = try cast(event.currentTarget, InteractiveObject) catch(e:String) null;
		target.removeEventListener(Event.ADDED_TO_STAGE, target_addedToStageHandler);
		if(!_initialized)  {
			_impl.init(target.stage);
			_initialized = true;
		}
	}

	function stage_mouseDownHandler(event : MouseEvent) : Void {
		if(Multitouch.supportsTouchEvents)  {
			return;
		}
		_stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
		_stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		stage_touchBeginHandler(new MouseTouchEvent(TouchEvent.TOUCH_BEGIN, event));
	}

	function stage_mouseMoveHandler(event : MouseEvent) : Void {
		stage_touchMoveHandler(new MouseTouchEvent(TouchEvent.TOUCH_MOVE, event));
	}

	function stage_mouseUpHandler(event : MouseEvent) : Void {
		_stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
		_stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		stage_touchEndHandler(new MouseTouchEvent(TouchEvent.TOUCH_END, event));
	}

	function stage_touchBeginHandler(event : TouchEvent) : Void {
		var outOfRange : Bool = (_touchPoints.length <= event.touchPointID);
		var tp : TouchPoint = (outOfRange==true) ? null : _touchPoints[event.touchPointID];
		if(tp==null)  {
			tp = try cast(_touchPointsPool.getObject(), TouchPoint) catch(e:String) null;
			tp.id = event.touchPointID;
			if(outOfRange)  {
				_touchPoints.length = tp.id + 1; //PORTODO
			}
			_touchPoints[tp.id] = tp;
		}
		tp.reset();
		tp.x = event.stageX;
		tp.y = event.stageY;
		tp.sizeX = event.sizeX;
		tp.sizeY = event.sizeY;
		tp.pressure = event.pressure;
		tp.touchBeginPos.x = tp.x;
		tp.touchBeginPos.y = tp.y;
		tp.touchBeginTime = tp.lastTime = nme.Lib.getTimer();
		tp.moveOffset.x = tp.moveOffset.y = 0;
		tp.lastMove.x = tp.lastMove.y = 0;
		tp.velocity.x = tp.velocity.y = 0;
		for( gesture in _gestures) {
			if(gesture.target!=null && gesture.shouldTrackPoint(event, tp))  {
				gesture.onTouchBegin(tp);
			}
		}

		// add gestures that are being tracked to the current gestures list
		var n : Int = _gestures.length;
		while(n-- > 0) {
			var gesture = _gestures[n];
			//TODO: which condition first (performance-wise)?
			

			if(Lambda.indexOf(_currGestures,gesture) == -1 && gesture.isTracking(tp.id))  {
				_currGestures.push(gesture);
			}
		}

	}

	function stage_touchMoveHandler(event : TouchEvent) : Void {
		var tp : TouchPoint = _touchPoints[event.touchPointID];
		var oldX : Float = tp.x;
		var oldY : Float = tp.y;
		tp.x = event.stageX;
		tp.y = event.stageY;
		tp.sizeX = event.sizeX;
		tp.sizeY = event.sizeY;
		tp.pressure = event.pressure;
		//			tp.moveOffset = tp.subtract(tp.touchBeginPos);
		tp.moveOffset.x = tp.x - tp.touchBeginPos.x;
		tp.moveOffset.y = tp.y - tp.touchBeginPos.y;
		tp.lastMove.x = tp.x - oldX;
		tp.lastMove.y = tp.y - oldY;
		var now : Int = nme.Lib.getTimer();
		var dt : Int = now - tp.lastTime;
		tp.lastTime = now;
		tp.velocity.x = tp.lastMove.x / dt;
		tp.velocity.y = tp.lastMove.y / dt;
		for(gesture  in _currGestures) {
			if(gesture.isTracking(tp.id))  {
				gesture.onTouchMove(tp);
			}
		}

	}

	function stage_touchEndHandler(event : TouchEvent) : Void {
		var tp : TouchPoint = _touchPoints[event.touchPointID];
		tp.x = event.stageX;
		tp.y = event.stageY;
		tp.sizeX = event.sizeX;
		tp.sizeY = event.sizeY;
		tp.pressure = event.pressure;
		tp.moveOffset = tp.subtract(tp.touchBeginPos);
		for(gesture  in _currGestures) {
			if(gesture.isTracking(tp.id))  {
				gesture.onTouchEnd(tp);
			}
		}

		var i : Int = 0;
		for(gesture in _currGestures.concat(null)) {
			if(gesture.trackingPointsCount == 0)  {
				_currGestures.splice(i, 1);
			}

			else  {
				i++;
			}

		}

	}

}

