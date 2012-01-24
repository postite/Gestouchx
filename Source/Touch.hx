package;

import nme.events.Event;
import nme.Lib;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.ui.Multitouch;
import nme.ui.MultitouchInputMode;
import nme.events.MouseEvent;
import nme.events.TouchEvent;


 import org.gestouch.core.IGestureDelegate;
 import org.gestouch.events.PanGestureEvent;
 import org.gestouch.events.ZoomGestureEvent;
 import org.gestouch.gestures.ZoomGesture;
import org.gestouch.events.LongPressGestureEvent;
import org.gestouch.events.MouseTouchEvent;
import org.gestouch.gestures.LongPressGesture;
import org.gestouch.gestures.Gesture;
import org.gestouch.core.GesturesManager;
import org.gestouch.gestures.SwipeGesture;
import org.gestouch.events.SwipeGestureEvent;
import org.gestouch.core.TouchesManager;
 import org.gestouch.gestures.SwipeGesture;
 import org.gestouch.events.SwipeGestureEvent;
import org.gestouch.gestures.RotateGesture;
import org.gestouch.events.RotateGestureEvent;




class Touch implements IGestureDelegate
{
	var box:Box;
	var initX:Float;
	


public function gestureShouldReceiveTouch(gesture:Gesture, touch:org.gestouch.core.Touch):Bool
			{
				return true;
			}
			
			
			public function gestureShouldBegin(gesture:Gesture):Bool
			{
				return true;
			}
			
				
			public function gesturesShouldRecognizeSimultaneously(gesture:Gesture, otherGesture:Gesture):Bool
			{
				if (gesture.target == otherGesture.target)
				{
					return true;
				}
				
				return false;
			}


	function new()
	{
		Lib.current.stage.align=StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode=StageScaleMode.NO_SCALE;
		Multitouch.inputMode=MultitouchInputMode.TOUCH_POINT;

		trace("hello18");
		box= new Box();
		box.addEventListener(Event.ADDED_TO_STAGE,onStage);
		
		Lib.current.addChild(box);
		
		//box.addEventListener(MouseEvent.CLICK,onTap);
		// var press= new LongPressGestureHash(box);
		// press.addEventListener(LongPressGestureEvent.GESTURE_LONG_PRESS, button_gestureHoldHandler);
		// var press3=new org.gestouch.gestures.PanGesture(box);
		// press3.addEventListener(PanGestureEvent.GESTURE_PAN,onPan);


var zoom = new ZoomGesture(box);
zoom.delegate=this;
zoom.addEventListener(ZoomGestureEvent.GESTURE_ZOOM,onZoom);

		var press2= new RotateGesture(box);
		press2.delegate=this;
		press2.addEventListener(RotateGestureEvent.GESTURE_ROTATE, rotateHandler);
	}
	function onStage(e:Event) {

trace("onStage");
		initX=box.x=Lib.current.stage.stageWidth/2;
		box.y=Lib.current.stage.stageHeight/2;
	}
function onZoom(event:ZoomGestureEvent) 
{
	trace("onzoom="+event.scaleX);
	

	box.width*=event.scaleX;
	box.height*=event.scaleY;
	//box.scaleY=event.scaleY;

}
	
function rotateHandler(event:RotateGestureEvent) 
{
	trace("onRotate"+event.rotation);
	box.rotation+=event.rotation;//event.rotation*90;
}
function onPan(e:PanGestureEvent) 
{
	trace("onPan"+e.offsetX);
	box.x=initX+e.offsetX;
}
function onTap(e:MouseEvent) 
{
	trace("ontap16");
}
 function button_gestureHoldHandler(event:LongPressGestureEvent) 
 {
trace("long");
box.rotation=30;
 }
	static public function main()
	{
		var app = new Touch();
	}
}