package org.gestouch.events;


/// CONSTANTS 
// ALL : String = "all"
// [statique] Valeur unique qui englobe toutes les phases de mouvements simples, tels que le glissement ou l’appui bref à deux doigts.
// GesturePhase
//  	 	BEGIN : String = "begin"
// [statique] Début d’un nouveau mouvement (notamment lorsque l’utilisateur appuie sur un écran tactile avec un doigt).
// GesturePhase
//  	 	END : String = "end"
// [statique] Fin d’un mouvement (notamment lorsque l’utilisateur retire son doigt d’un écran tactile).
// GesturePhase
//  	 	UPDATE : String = "update"
// [statique] Exécution d’un mouvement (notamment lorsqu’un utilisateur déplace son doigt sur un écran tactile).

class GesturePhase
{


	static public inline var ALL : String = "all";
	static public inline var BEGIN : String = "begin";
	static public inline var END : String = "end";
	static public inline var UPDATE : String = "update";
	
}