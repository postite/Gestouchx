package org.gestouch.events;
//#if (cpp || neko)


import nme.events.Event;


class GestureEvent extends Event
{	
	

///PROPS///
// altKey : Boolean
// Indique si la touche Alt est active (true) ou non (false).
// GestureEvent
//  	 	    commandKey : Boolean
// Indique si la touche Commande est activée (Mac uniquement).
// GestureEvent
//  	 	controlKey : Boolean
// Indique si la touche Contrôle et activée sous Mac et si la touche Ctrl est activée sous Windows ou Linux.
// GestureEvent
//  	 	ctrlKey : Boolean
// Sous Windows ou Linux, indique si la touche Ctrl est activée (true) ou non (false).
// GestureEvent
//  	 	localX : Number
// Coordonnée horizontale à laquelle l’événement s’est produit par rapport au sprite conteneur.
// GestureEvent
//  	 	localY : Number
// Coordonnée verticale à laquelle l’événement s’est produit par rapport au sprite conteneur.
// GestureEvent
//  	 	phase : String
// Valeur de la classe GesturePhase indiquant l’état du mouvement tactile.
// GestureEvent
//  	 	shiftKey : Boolean
// Indique si la touche Maj est activée (true) ou non (false).
// GestureEvent
//  	 	stageX : Number
// [lecture seule] Coordonnée horizontale à laquelle l’événement s’est produit, par rapport aux coordonnées globales de la scène.
// GestureEvent
//  	 	stageY : Number
// [lecture seule] Coordonnée verticale à laquelle l’événement s’est produit, par rapport aux coordonnées globales de la scène.
// GestureEvent



///METHODS
// GestureEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, phase:String = null, localX:Number = 0, localY:Number = 0, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, commandKey:Boolean = false, controlKey:Boolean = false)
// Crée un objet Event contenant des informations sur les événements tactiles multipoints (notamment lorsque l’utilisateur appuie sur un écran tactile avec deux doigts).
// GestureEvent
 	 	
// clone():Event
// [override] Crée une copie de l’objet GestureEvent et définit la valeur de chaque propriété de sorte qu’elle corresponde à la valeur d’origine.
// GestureEvent
 	 	
// toString():String
// [override] Renvoie une chaîne répertoriant toutes les propriétés de l’objet GestureEvent.
// GestureEvent
 	 	
// updateAfterEvent():void
// Actualise l’affichage du moteur d’exécution de Flash après le traitement de l’événement gesture, dans le cas où la liste d’affichage a été modifiée par le gestionnaire d’événement.


//CONSTANTS
// 	GESTURE_TWO_FINGER_TAP : String = "gestureTwoFingerTap"
// [statique] Définit la valeur de la propriété type d’un objet d’événement de mouvement GESTURE_TWO_FINGER_TAP.





	
	static public inline var GESTURE_TWO_FINGER_TAP : String = "gestureTwoFingerTap";

	public var altKey : Bool;
	public var commandKey : Bool;
	public var controlKey : Bool;
	public var ctrlKey:Bool;
	public var localX : Float;
	public var localY : Float;
	public var phase : String;
	public var shiftKey : Bool;
	public var stageX : Float;
	public var stageY : Float;



// GestureEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, phase:String = null, localX:Number = 0, localY:Number = 0, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, commandKey:Boolean = false, controlKey:Boolean = false)
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false,phase:String=null,localX:Float=0,localY:Float=0, ctrlKey:Bool = false, altKey:Bool = false, shiftKey:Bool = false, commandKey:Bool = false, controlKey:Bool = false):Void
	{	
		super(type, bubbles, cancelable);
		
		this.phase=phase;
		this.localX=localX;
		this.localY=localY;
		this.ctrlKey=ctrlKey;
		this.altKey=altKey;
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
// typedef GestureEvent = flash.events.GestureEvent;
// #end