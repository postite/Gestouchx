package org.gestouch.events;
//#if (cpp || neko)


import nme.events.Event;


class TransformGestureEvent extends GestureEvent
{	
	

///PROPS///
// Propriété	Défini par
//  	 	offsetX : Number
// Translation horizontale de l’objet d’affichage, depuis l’événement gesture précédent.
// TransformGestureEvent
//  	 	offsetY : Number
// Translation verticale de l’objet d’affichage, depuis l’événement gesture précédent.
// TransformGestureEvent
//  	 	rotation : Number
// Angle de rotation actuel de l’objet d’affichage le long de l’axe z depuis l’événement gesture précédent, en degrés.
// TransformGestureEvent
//  	 	scaleX : Number
// Echelle horizontale de l’objet d’affichage, depuis l’événement gesture précédent.
// TransformGestureEvent
//  	 	scaleY : Number
// Echelle verticale de l’objet d’affichage, depuis l’événement gesture précédent.



///METHODS
// TransformGestureEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, phase:String = null, localX:Number = 0, localY:Number = 0, scaleX:Number = 1.0, scaleY:Number = 1.0, rotation:Number = 0, offsetX:Number = 0, offsetY:Number = 0, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, commandKey:Boolean = false, controlKey:Boolean = false)
// Crée un objet Event contenant des informations sur des événements tactiles multipoints complexes, notamment lorsqu’un utilisateur fait glisser son doigt sur un écran.
// TransformGestureEvent
 	 	
// clone():Event
// [override] Crée une copie de l’objet TransformGestureEvent et définit la valeur de chaque propriété de sorte qu’elle corresponde à la valeur d’origine.
// TransformGestureEvent
 	 	
// toString():String
// [override] Renvoie une chaîne répertoriant toutes les propriétés de l’objet TransformGestureEvent.
// TransformGestureEvent



//CONSTANTS
// 	GESTURE_PAN : String = "gesturePan"
// [statique] Définit la valeur de la propriété type d’un objet d’événement tactile GESTURE_PAN.
// TransformGestureEvent
//  	 	GESTURE_ROTATE : String = "gestureRotate"
// [statique] Définit la valeur de la propriété type d’un objet d’événement tactile GESTURE_ROTATE.
// TransformGestureEvent
//  	 	GESTURE_SWIPE : String = "gestureSwipe"
// [statique] Définit la valeur de la propriété type d’un objet d’événement tactile GESTURE_SWIPE.
// TransformGestureEvent
//  	 	GESTURE_ZOOM : String = "gestureZoom"
// [statique] Définit la valeur de la propriété type d’un objet d’événement tactile GESTURE_ZOOM.




	
	
	static public  var GESTURE_PAN : String = "gesturePan";
	static public  var GESTURE_ROTATE : String = "gestureRotate";
	static public  var GESTURE_SWIPE : String = "gestureSwipe";
	static public  var GESTURE_ZOOM : String = "gestureZoom";


	public var offsetX : Float;
	public var offsetY : Float;
	public var rotation : Float;
	public var scaleX: Float;
	public var scaleY : Float;
	



//TransformGestureEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, phase:String = null, localX:Number = 0, localY:Number = 0, scaleX:Number = 1.0, scaleY:Number = 1.0, rotation:Number = 0, offsetX:Number = 0, offsetY:Number = 0, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, commandKey:Boolean = false, controlKey:Boolean = false)


	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false,phase:String=null,localX:Float=0,localY:Float=0,scaleX:Float=1.0,scaleY:Float=1.0,rotation:Float=0,offsetX:Float=0,offsetY:Float=0 ,ctrlKey:Bool = false, altKey:Bool = false, shiftKey:Bool = false, commandKey:Bool = false, controlKey:Bool = false):Void
	{	

		trace("check scaleX from transform"+scaleX);
		super(type, bubbles, cancelable);
		this.offsetX=offsetX;
		this.offsetY=offsetY;
		this.scaleX=scaleX;
		this.scaleY=scaleY;
		this.localX=localX;
		this.localY=localY;
		this.ctrlKey=ctrlKey;
		this.altKey=altKey;
		this.rotation=rotation;
		this.shiftKey=shiftKey;
		this.commandKey=commandKey;
		this.controlKey=controlKey;
	}
	
	
	public override function clone ():Event
	{
		return new GestureEvent (type, bubbles, cancelable, phase, localX, localY, ctrlKey,altKey,shiftKey,commandKey,controlKey);
	}
	
	
	public override function toString ():String
	{
		return "[AccelerometerEvent type=" + type + " bubbles=" + bubbles + " cancelable=" + cancelable +" and more...]";
	}
	
}


// #else
// typedef TransformGestureEvent = flash.events.TransformGestureEvent;
// #end