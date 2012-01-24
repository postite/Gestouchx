/**
 * @author Pavel fljot
 * 
 * "inspired" by Jonnie Hallman 
 * @link http://destroytoday.com
 * @link https://github.com/destroytoday
 * 
 * Added some optimization and changes.
 */
package org.gestouch.utils;



class ObjectPool {
	public var type(getType, never) : Class<Dynamic>;
	public var numObjects(getNumObjects, never) : Int;

	// --------------------------------------------------------------------------
	//
	// Properties
	//
	// --------------------------------------------------------------------------
	var _type : Class<Dynamic>;
	var objectList : Array<Dynamic>;
	// --------------------------------------------------------------------------
	//
	// Constructor
	//
	// --------------------------------------------------------------------------
	public function new(type : Class<Dynamic>, size : Int = 0) {
		objectList = [];
		_type = type;
		if(size > 0)  {
			allocate(size);
		}
	}

	// --------------------------------------------------------------------------
	//
	// Getters / Setters
	//
	// --------------------------------------------------------------------------
	public function getType() : Class<Dynamic> {
		return _type;
	}

	public function getNumObjects() : Int {
		return objectList.length;
	}

	// --------------------------------------------------------------------------
	//
	// Public Methods
	//
	// --------------------------------------------------------------------------
	public function hasObject(object : Dynamic) : Bool {
		//return objectList.indexOf(object) > -1;
		return Lambda.has(objectList,object) ;
	}

	public function getObject() : Dynamic {
		return numObjects > (0) ? objectList.pop() : createObject();
	}

	public function disposeObject(object : Dynamic) : Void {
		if(!(Std.is(object,type)))  {
			throw ("Disposed object type mismatch. Expected " + type + ", got " + Type.getClassName(object));
		}
		addObject(object);
	}

	public function empty() : Void {
		objectList=[];
	}

	//--------------------------------------------------------------------------
	//
	// Protected methods
	//
	//--------------------------------------------------------------------------
	function addObject(object : Dynamic) : Dynamic {
		if(!hasObject(object)) objectList[objectList.length] = object;
		return object;
	}

	function createObject() : Dynamic {
		return Type.createInstance(type,[]);
	}

	function allocate(value : Int) : Void {
		var n : Int = value - numObjects;
		while(n-- > 0) {
			addObject(createObject());
		}

	}

}

