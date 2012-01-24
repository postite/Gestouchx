/**
 * @author Pavel fljot
 */
package org.gestouch.events;

import nme.events.Event;
import nme.events.MouseEvent;
import nme.events.TouchEvent;

class MouseTouchEvent extends TouchEvent {

	static var typeMap : Dynamic = {
	var map={};
  
   Reflect.setField(map,MouseEvent.MOUSE_DOWN,TouchEvent.TOUCH_BEGIN);
   Reflect.setField(map,MouseEvent.MOUSE_MOVE,TouchEvent.TOUCH_MOVE);
   Reflect.setField(map,MouseEvent.MOUSE_UP,TouchEvent.TOUCH_END);
   
   map;
	// result of last block expression is saved in typeMap
	 };
	var _mouseEvent : MouseEvent;

	public function new(type:String,event:MouseEvent) 
	{
		
#if !flash
		super(type,event.bubbles,event.cancelable,event.localX, event.localY, cast event.relatedObject, event.ctrlKey, event.altKey, event.shiftKey,false,0,false,0);
#end		
#if flash

// function new( type : String, ?bubbles : Bool, ?cancelable : Bool, ?touchPointID : Int, ?isPrimaryTouchPoint : Bool, ?localX : Float, ?localY : Float, ?sizeX : Float, ?sizeY : Float, ?pressure : Float, ?relatedObject : InteractiveObject, ?ctrlKey : Bool, ?altKey : Bool, ?shiftKey : Bool ) : Void

		super(type,event.bubbles,event.cancelable,0,false, event.localX, event.localY, Math.NaN, Math.NaN, Math.NaN, event.relatedObject, event.ctrlKey, event.altKey, event.shiftKey);
#end

	}

	static public function createMouseTouchEvent(event : MouseEvent) : MouseTouchEvent {
		
		var type : String =Reflect.field( MouseTouchEvent.typeMap,event.type);
		trace("createmouseEvent"+type);
		if(type==null)  {
			throw ("No match found for MouseEvent of type \"" + event.type + "\"");
		}
		return new MouseTouchEvent(type,event);
	}


#if !flash	
 override  function  nmeGetTarget():Dynamic{

 	return _mouseEvent.target;

 }
 #else

@:getter(stageX)
public function getStageX() : Float {
		return _mouseEvent.stageX;
	}
#end

	// var _target : Dynamic;
	// @:getter(target)
	// public function getTarget() : Dynamic {
	// 	return _mouseEvent.target;
	// }
	// var _currentTarget : Dynamic;
	// @:getter(currentTarget)
 // public function getCurrentTarget() : Dynamic {
	// 	return _mouseEvent.currentTarget;
	// }
	// var _stageX : Float;
	// @:getter(stageX)
	//  public function getStageX() : Float {
	// 	return _mouseEvent.stageX;
	// }

	// var _stageY : Float;
	// @:getter(stageY)
	//  public function getStageY() : Float {
	// 	return _mouseEvent.stageY;
	// }


	// override public function getTarget() : Dynamic {
	// 	return _mouseEvent.target;
	// }

	// override public function getCurrentTarget() : Dynamic {
	// 	return _mouseEvent.currentTarget;
	// }

	// override public function getStageX() : Float {
	// 	return _mouseEvent.stageX;
	// }

	// override public function getStageY() : Float {
	// 	return _mouseEvent.stageY;
	// }

	// override public function stopPropagation() : Void {
	// 	super.stopPropagation();
	// 	_mouseEvent.stopPropagation();
	// }

	// override public function stopImmediatePropagation() : Void {
	// 	super.stopImmediatePropagation();
	// 	_mouseEvent.stopImmediatePropagation();
	// }

	// override public function clone() : Event {
	// 	return super.clone();
	// }

	// override public function toString() : String {
	// 	return super.toString() + " *faked";
	// }


	

}

