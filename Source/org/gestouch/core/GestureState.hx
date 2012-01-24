/**
 * @author Pavel fljot
 */
package org.gestouch.core;

class GestureState {

	static  public inline var POSSIBLE : Int = 1 << 0;
	//1
	static public inline var BEGAN : Int = 1 << 1;
	//2
	static public inline var CHANGED : Int = 1 << 2;
	//4
	static public inline var ENDED : Int = 1 << 3;
	//8
	static public inline var CANCELLED : Int = 1 << 4;
	//16
	static public inline var FAILED : Int = 1 << 5;
	//32
	static public inline var RECOGNIZED : Int = 1 << 6;
	//64
}

