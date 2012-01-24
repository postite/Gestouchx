/**
 * @author Pavel fljot
 */
package org.gestouch.core;

import org.gestouch.events.MouseTouchEvent;
//import org.gestouch.gestures.Gesture;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.display.InteractiveObject;
import nme.display.Stage;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.events.TouchEvent;
import nme.ui.Multitouch;
//import flash.utils.Dictionary;
import org.gestouch.utils.ObjectHash;

typedef Gesture=Dynamic;

class GesturesManager implements IGesturesManager {

	static var _instance : IGesturesManager;
	static var _allowInstantiation : Bool;
	var _touchesManager : ITouchesManager;
	var _stage : Stage;
	var _gestures : Array<Gesture>;
	var _gesturesForTouchMap : Array<Dynamic>;
	//AS> var _gesturesForTargetMap : Dictionary;
	var _gesturesForTargetMap : ObjectHash<Array<Gesture>>;
	var _dirtyGestures : Array<Gesture>;
	var _dirtyGesturesLength : Int;
	var _dirtyGesturesMap : ObjectHash<Array<Gesture>>;
	public function new() {
		_touchesManager = TouchesManager.getInstance();
		_gestures = new Array<Gesture>();
		_gesturesForTouchMap = [];
		_gesturesForTargetMap = new ObjectHash();//new Dictionary(true);
		_dirtyGestures = new Array<Gesture>();
		_dirtyGesturesLength = 0;
		_dirtyGesturesMap = new ObjectHash();//new Dictionary(true);

		/////PORTODO constructor variable in haxe ?
		// if(cast(this).constructor == GesturesManager && !_allowInstantiation)  {
		// 	throw ("Do not instantiate GesturesManager directly.");
		// }
	}

	static public function setImplementation(value : IGesturesManager) : Void {
		if(value==null)  {
			throw ("value cannot be null.");
		}
		if(_instance !=null)  {
			throw ("Instance of GesturesManager is already created. If you want to have own implementation of single GesturesManager instace, you should set it earlier.");
		}
		_instance = value;
	}

	static public function getInstance() : IGesturesManager {
		if(_instance==null)  {
			_allowInstantiation = true;
			_instance = new GesturesManager();
			_allowInstantiation = false;
		}
		return _instance;
	}

	public function addGesture(gesture : Gesture) : Void {
		if(gesture==null)  {
			throw ("Argument 'gesture' must be not null.");
		}
		if(Lambda.indexOf(_gestures,gesture) > -1)  {
			throw ("This gesture is already registered.. something wrong.");
		}
		 var targetGestures:Array<Gesture>= cast _gesturesForTargetMap.get(gesture.target);
		if(targetGestures==null)  {
		_gesturesForTargetMap.set(gesture.target , new Array<Gesture>());
		targetGestures = _gesturesForTargetMap.get(gesture.target);
		}
		targetGestures.push(gesture);
		_gestures.push(gesture);
		if(_stage==null && gesture.target.stage!=null)  {
			installStage(gesture.target.stage);
		}

		else  {
			gesture.target.addEventListener(Event.ADDED_TO_STAGE, gestureTarget_addedToStageHandler);
		}

	}

	public function removeGesture(gesture : Gesture) : Void {
		if(gesture ==null)  {
			throw ("Argument 'gesture' must be not null.");
		}
		var target : InteractiveObject = gesture.target;
		var targetGestures:Array<Gesture> =  _gesturesForTargetMap.get(target);
		targetGestures.splice(Lambda.indexOf(targetGestures,gesture), 1);
		if(targetGestures.length == 0)  {
			//PORTODO delete _gesturesForTargetMap[target];
			gesture.target.removeEventListener(Event.ADDED_TO_STAGE, gestureTarget_addedToStageHandler);
		}
		//AS> var index : Int = _gestures.indexOf(gesture);
		var index:Int= Lambda.indexOf(_gestures,gesture);
		if(index > -1)  {
			_gestures.splice(index, 1);
		}
	}

	public function scheduleGestureStateReset(gesture : Gesture) : Void {
		if(_dirtyGesturesMap.get(gesture)==null)  {
			_dirtyGestures.push(gesture);
			_dirtyGesturesLength++;
			_stage.addEventListener(Event.ENTER_FRAME, stage_enterFrameHandler);
		}
	}

	public function onGestureRecognized(gesture : Gesture) : Void {
		for(otherGesture  in _gestures) {
			// conditions for otherGesture "own properties"
			if(otherGesture != gesture && otherGesture.enabled && otherGesture.state == GestureState.POSSIBLE)  {
				// conditions for otherGesture target
				if(otherGesture.target == gesture.target || Std.is(gesture.target, DisplayObjectContainer) && cast(gesture.target, DisplayObjectContainer).contains(otherGesture.target) || Std.is(otherGesture.target, DisplayObjectContainer) && cast(otherGesture.target, DisplayObjectContainer).contains(gesture.target))  {
					// conditions for gestures relations
					if(gesture.canPreventGesture(otherGesture) && otherGesture.canBePreventedByGesture(gesture) && (gesture.delegate==null || !gesture.delegate.gesturesShouldRecognizeSimultaneously(gesture, otherGesture)) && (otherGesture.delegate==null || !otherGesture.delegate.gesturesShouldRecognizeSimultaneously(otherGesture, gesture)))  {
						otherGesture.setState_internal(GestureState.FAILED);
					}
				}
			}
		}

	}

	//--------------------------------------------------------------------------
	//
	//  Private methods
	//
	//--------------------------------------------------------------------------
	function installStage(stage : Stage) : Void {
		trace("installStage");
		var stage= nme.Lib.current.stage;
		_touchesManager.init(stage);
		_stage = stage;
		if(Multitouch.supportsTouchEvents)  {
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler, true);
		}

		else  {
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true);
		}

	}

	function installStageListeners() : Void {
		//TODO: maximum priority to prevent event hijacking?
		if(Multitouch.supportsTouchEvents)  {
			_stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, true);
			_stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler, true);
		}

		else  {
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
			_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
		}

	}

	function uninstallStageListeners() : Void {
		if(Multitouch.supportsTouchEvents)  {
			_stage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, true);
			_stage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler, true);
		}

		else  {
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
		}

	}

	function resetDirtyGestures() : Void {
		for( gesture  in _dirtyGestures) {
			gesture.reset();
		}

		_dirtyGestures=[];
		_dirtyGesturesLength = 0;
		_dirtyGesturesMap = new ObjectHash();//new Dictionary(true);
		_stage.removeEventListener(Event.ENTER_FRAME, stage_enterFrameHandler);
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	function gestureTarget_addedToStageHandler(event : Event) : Void {
		var target : DisplayObject = cast(event.target, DisplayObject) ;
		target.removeEventListener(Event.ADDED_TO_STAGE, gestureTarget_addedToStageHandler);
		if(_stage==null)  {
			installStage(target.stage);
		}
		var depth : Int = 1;
		//NB! not using 0-based for sorting function
		var targetParent : DisplayObjectContainer = target.parent;
		while(targetParent !=null) {
			depth++;
			targetParent = targetParent.parent;
		}

	}

	function touchBeginHandler(event : TouchEvent) : Void {
		

		if(_dirtyGesturesLength > 0)  {
			resetDirtyGestures();
		}
		var touch : Touch = _touchesManager.getTouch(event.touchPointID);
		var gesture : Gesture;
		var i : Int;
		// This vector will contain active gestures for specific touch (ID) during all touch session.
		var gesturesForTouch:Array<Gesture> = cast _gesturesForTouchMap[touch.id] ;
		if(gesturesForTouch==null)  {
			gesturesForTouch = new Array<Gesture>();
			_gesturesForTouchMap[touch.id] = gesturesForTouch;
		}

		else  {
			gesturesForTouch=[];
		}

		// Create a sorted(!) list of gestures which are interested in this touch.
		// Sorting priority: deeper target has higher priority, recently added gesture has higher priority.
		var target : InteractiveObject = touch.target;
		var gesturesForTarget : Array<Gesture>;
		while(target!=null) {
			gesturesForTarget = _gesturesForTargetMap.get(target);
			if(gesturesForTarget!=null)  {
				i = gesturesForTarget.length;
				while(i-- > 0) {
					gesture = try cast(gesturesForTarget[i], Gesture) catch(e:String) null;
					if(gesture.enabled && (gesture.delegate==null || gesture.delegate.gestureShouldReceiveTouch(gesture, touch)))  {
						//TODO: optimize performance! decide between unshift() vs [i++] = gesture + reverse()
						gesturesForTouch.unshift(gesture);
					}
				}

			}
			target = target.parent;
		}

		// Then we populate them with this touch and event.
		// They might start tracking this touch or ignore it (via Gesture#ignoreTouch())
		i = gesturesForTouch.length;
		while(i-- > 0) {
			gesture = try cast(gesturesForTouch[i], Gesture) catch(e:String) null;
			// Check for state because previous (i+1) gesture may already abort current (i) one
			if(gesture.state != GestureState.FAILED)  {
				gesture.touchBeginHandler(touch, event);
			}

			else  {
				gesturesForTouch.splice(i, 1);
			}

		}

		installStageListeners();
	}

	function mouseDownHandler(event : MouseEvent) : Void {
		//trace("mouseDown");
		touchBeginHandler(cast MouseTouchEvent.createMouseTouchEvent(event));
		//test >touchBeginHandler(event);

	}

	function touchMoveHandler(event : TouchEvent) : Void {
		trace("manager moveHandler");
		if(_dirtyGesturesLength > 0)  {
			resetDirtyGestures();
		}
		var touch : Touch = _touchesManager.getTouch(event.touchPointID);
		var gesturesForTouch:Array<Gesture> = cast _gesturesForTouchMap[touch.id];
		var gesture : Gesture;
		var i : Int = gesturesForTouch.length;
		while(i-- > 0) {
			gesture = try cast(gesturesForTouch[i], Gesture) catch(e:String) null;
			if(gesture.state != GestureState.FAILED && gesture.isTrackingTouch(touch.id))  {
				gesture.touchMoveHandler(touch, event);
			}

			else  {
				// gesture is no more interested in this touch (e.g. ignoreTouch was called)
				gesturesForTouch.splice(i, 1);
			}

		}
	}

	function mouseMoveHandler(event : MouseEvent) : Void {
		//TODO: copy code from touchMoveHandler: save 1 function call?
		touchMoveHandler(MouseTouchEvent.createMouseTouchEvent(event));
	}

	function touchEndHandler(event:TouchEvent) : Void {
		if(_dirtyGesturesLength > 0)  {
			resetDirtyGestures();
		}
		var touch : Touch = _touchesManager.getTouch(event.touchPointID);
		var gesturesForTouch:Array<Gesture> = cast _gesturesForTouchMap[touch.id] ;
		var gesture : Gesture;
		var i : Int = gesturesForTouch.length;
		while(i-- > 0) {
			gesture = cast(gesturesForTouch[i], Gesture) ;
			// TODO: handle cancelled touch:
			// if (event.hasOwnProperty("isTouchPointCanceled") && event["isTouchPointCanceled"] && ...
			if(gesture.state != GestureState.FAILED && gesture.isTrackingTouch(touch.id))  {
				gesture.touchEndHandler(touch, event);
			}
		}

		if(_touchesManager.activeTouchesCount == 0)  {
			uninstallStageListeners();
		}
	}

	function mouseUpHandler(event : MouseEvent) : Void {
		touchEndHandler(MouseTouchEvent.createMouseTouchEvent(event));
	}

	function stage_enterFrameHandler(event : Event) : Void {
		resetDirtyGestures();
	}

}

