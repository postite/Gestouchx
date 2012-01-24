/**
 * @author Pavel fljot
 */
package org.gestouch.core;

import nme.display.InteractiveObject;
import nme.display.Stage;
import nme.events.MouseEvent;
import nme.events.TouchEvent;
import nme.ui.Multitouch;
import nme.ui.MultitouchInputMode;
//import flash.utils.GetTimer;
import nme.Lib;

class TouchesManager implements ITouchesManager {
	public var activeTouchesCount(getActiveTouchesCount, never) : Int;
	static inline var MAX_VALUE:Int= 2147483647;
	static  var _instance : ITouchesManager;
	static  var _allowInstantiation : Bool;
	var _stage : Stage;
	var _touchesMap : Dynamic;
	public function new() {
		_touchesMap = { };
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		//PORTODO constructor stuff
		// if(cast((this)).constructor == TouchesManager && !_allowInstantiation)  {
		// 	throw ("Do not instantiate TouchesManager directly.");
		// }
	}

	var _activeTouchesCount : Int;
	public function getActiveTouchesCount() : Int {
		return _activeTouchesCount;
	}

	static public function setImplementation(value : ITouchesManager) : Void {
		if(value==null)  {
			throw ("value cannot be null.");
		}
		if(_instance !=null)  {
			throw ("Instance of TouchesManager is already created. If you want to have own implementation of single TouchesManager instace, you should set it earlier.");
		}
		_instance = value;
	}

	static public function getInstance() : ITouchesManager {
		if(_instance==null)  {
			_allowInstantiation = true;
			_instance = new TouchesManager();
			_allowInstantiation = false;
		}
		return _instance;
	}

	public function init(stage : Stage) : Void {
		_stage = Lib.current.stage;
		if(Multitouch.supportsTouchEvents)  {
			trace("support TouchEvents");
			_stage.addEventListener(TouchEvent.TOUCH_BEGIN, stage_touchBeginHandler, true, MAX_VALUE);
			_stage.addEventListener(TouchEvent.TOUCH_MOVE, stage_touchMoveHandler, true, MAX_VALUE);
			_stage.addEventListener(TouchEvent.TOUCH_END, stage_touchEndHandler, true, MAX_VALUE);
		}

		else  {
			trace("touchEvent not supported");
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, true, MAX_VALUE);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, true, MAX_VALUE);
			_stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, true, MAX_VALUE);
		}

	}

	public function getTouch(touchPointID : Int) : Touch {
		//trace("getTouch"+touchPointID);
		
		//Reflect.field(_touchesMap,Std.string(touchPointID))
		var touch : Touch = cast Reflect.field(_touchesMap,Std.string(touchPointID)) ;
		//trace("getTouchX"+touch.x);
		return (touch!=null) ? touch.clone() : null;
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	function stage_touchBeginHandler(event : TouchEvent) : Void {
		trace("stage_touchBeginHandler");
		var touch : Touch = new Touch(event.touchPointID);
		
		Reflect.setField(_touchesMap,Std.string(event.touchPointID),touch);
		touch.target = cast(event.target, InteractiveObject) ;
		#if flash
		touch.x = event.stageX;
		touch.y = event.stageY;
		touch.sizeX = event.sizeX;
		touch.sizeY = event.sizeY;
		touch.pressure = event.pressure;
		#end


		///nme.touchEvent has no field sizeX,sizeY, pressure
		#if (cpp || neko)
		trace("stage_touchBeginHandler"+event.stageX);
		touch.x = event.stageX;
		touch.y = event.stageY;
		touch.sizeX = Math.NaN; //event.sizeX;
		touch.sizeY = Math.NaN;//event.sizeY;
		touch.pressure = Math.NaN;//event.pressure;
		#end

		touch.time = nme.Lib.getTimer();
		//TODO: conditional compilation + event.timestamp
		_activeTouchesCount++;
	}

	function stage_mouseDownHandler(event : MouseEvent) : Void {
		var touch : Touch = new Touch(0);
		Reflect.setField(_touchesMap,Std.string(0),touch);
		
		touch.target = cast(event.target, InteractiveObject);
		touch.x = event.stageX;
		touch.y = event.stageY;
		touch.sizeX = Math.NaN;
		touch.sizeY = Math.NaN;
		touch.pressure = Math.NaN;
		touch.time = nme.Lib.getTimer();
		//TODO: conditional compilation + event.timestamp
		_activeTouchesCount++;
	}

	function stage_touchMoveHandler(event : TouchEvent) : Void {
		var touch : Touch = cast(Reflect.field(_touchesMap,Std.string(event.touchPointID)));
		if(touch==null)  {
			// some fake event?
			return;
		}
		#if flash
		touch.x = event.stageX;
		touch.y = event.stageY;
		touch.sizeX = event.sizeX;
		touch.sizeY = event.sizeY;
		touch.pressure = event.pressure;
#end
#if (cpp || neko)
		touch.x = event.stageX;
		touch.y = event.stageY;
		touch.sizeX = Math.NaN; //event.sizeX;
		touch.sizeY = Math.NaN;//event.sizeY;
		touch.pressure = Math.NaN;//event.pressure;
		#end

		touch.time = nme.Lib.getTimer();
		//TODO: conditional compilation + event.timestamp
	}

	function stage_mouseMoveHandler(event : MouseEvent) : Void {
		var touch : Touch =cast(Reflect.field(_touchesMap,Std.string(0)));
		if(touch==null)  {
			// some fake event?
			return;
		}
		touch.x = event.stageX;
		touch.y = event.stageY;
		touch.time = nme.Lib.getTimer();
		//TODO: conditional compilation + event.timestamp
	}

	function stage_touchEndHandler(event : TouchEvent) : Void {
		var touch : Touch = cast(Reflect.field(_touchesMap,Std.string(event.touchPointID)));
		if(touch==null)  {
			// some fake event?
			return;
		}
#if flash
		touch.x = event.stageX;
		touch.y = event.stageY;
		touch.sizeX = event.sizeX;
		touch.sizeY = event.sizeY;
		touch.pressure = event.pressure;
#end
#if (cpp || neko)
touch.x = event.stageX;
		touch.y = event.stageY;
		touch.sizeX = Math.NaN; //event.sizeX;
		touch.sizeY = Math.NaN;//event.sizeY;
		touch.pressure = Math.NaN;//event.pressure;
#end
		touch.time = nme.Lib.getTimer();
		//TODO: conditional compilation + event.timestamp
		_activeTouchesCount--;
	}

	function stage_mouseUpHandler(event : MouseEvent) : Void {
		trace("mousedoawnHandler");
		var touch : Touch =cast  Reflect.field(_touchesMap,Std.string(0)) ;
		if(touch==null)  {
			trace("somefakeEvent");
			// some fake event?
			return;
		}
		touch.x = event.stageX;
		touch.y = event.stageY;
		touch.time = nme.Lib.getTimer();
		//TODO: conditional compilation + event.timestamp
		_activeTouchesCount--;
	}



}

