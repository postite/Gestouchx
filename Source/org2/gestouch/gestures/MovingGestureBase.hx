/**
 * Base class for those gestures where you have to move finger/mouse,
 * i.e. DragGesture, SwipeGesture
 * 
 * @author Pavel fljot
 */
package org.gestouch.gestures;

import flash.display.InteractiveObject;
import flash.geom.Point;
import org.gestouch.Direction;

class MovingGestureBase extends Gesture {
	public var direction(getDirection, setDirection) : String;

	/**
	 * Threshold for screen distance they must move to count as valid input 
	 * (not an accidental offset on touch). Once this distance is passed,
	 * gesture starts more intensive and specific processing in onTouchMove() method.
	 * 
	 * @default Gesture.DEFAULT_SLOP
	 * 
	 * @see org.gestouch.gestures.Gesture#DEFAULT_SLOP
	 */
	public var slop : Float;
	var _slopPassed : Bool;
	var _canMoveHorizontally : Bool;
	var _canMoveVertically : Bool;
	public function new(target : InteractiveObject = null, settings : Dynamic = null) {
		slop = Gesture.DEFAULT_SLOP;
		_slopPassed = false;
		_canMoveHorizontally = true;
		_canMoveVertically = true;
		_direction = Direction.ALL;
		super(target, settings);
		if(reflect() == MovingGestureBase)  {
			dispose();
			throw new Error("This is abstract class and cannot be instantiated.");
		}
	}

	/**
	 * @private
	 * Storage for direction property.
	 */
	var _direction : String;
	/**
	 * Allowed direction for this gesture. Used to determine slop overcome
	 * and could be used for specific calculations (as in SwipeGesture for example).
	 * 
	 * @default Direction.ALL
	 * 
	 * @see org.gestouch.Direction
	 * @see org.gestouch.gestures.SwipeGesture
	 */
	public function getDirection() : String {
		return _direction;
	}

	public function setDirection(value : String) : String {
		if(_direction == value) return;
		_validateDirection(value);
		_direction = value;
		_canMoveHorizontally = (_direction != Direction.VERTICAL);
		_canMoveVertically = (_direction != Direction.HORIZONTAL);
		return value;
	}

	//--------------------------------------------------------------------------
	//
	//  Protected methods
	//
	//--------------------------------------------------------------------------
	override function _preinit() : Void {
		super._preinit();
		_propertyNames.push("slop", "direction");
	}

	override function _reset() : Void {
		super._reset();
		_slopPassed = false;
	}

	/**
	 * Validates direction property (in setter) to help
	 * developer prevent accidental mistake (Strings suck).
	 * 
	 * @see org.gestouch.Direction
	 */
	function _validateDirection(value : String) : Void {
		if(value != Direction.HORIZONTAL && value != Direction.VERTICAL && value != Direction.STRAIGHT_AXES && value != Direction.DIAGONAL_AXES && value != Direction.OCTO && value != Direction.ALL)  {
			throw new ArgumentError("Invalid direction value \"" + value + "\".");
		}
	}

	/**
	 * Checks wether slop has been overcome.
	 * Typically used in onTouchMove() method.
	 * 
	 * @param moveDelta offset of touch point / central point
	 * starting from beginning of interaction cycle.
	 * 
	 * @see #onTouchMove()
	 */
	function _checkSlop(moveDelta : Point) : Bool {
		var slopPassed : Bool = false;
		if(!(slop > 0))  {
			// return true immideately if slop is 0 or NaN
			return true;
		}
		if(_canMoveHorizontally && _canMoveVertically)  {
			slopPassed = moveDelta.length > slop;
		}

		else if(_canMoveHorizontally)  {
			slopPassed = Math.abs(moveDelta.x) > slop;
		}

		else if(_canMoveVertically)  {
			slopPassed = Math.abs(moveDelta.y) > slop;
		}
		if(slopPassed)  {
			var slopVector : Point;
			if(_canMoveHorizontally && _canMoveVertically)  {
				slopVector = moveDelta.clone();
				slopVector.normalize(slop);
				slopVector.x = Math.round(slopVector.x);
				slopVector.y = Math.round(slopVector.y);
			}

			else if(_canMoveHorizontally)  {
				slopVector = new Point(moveDelta.x >= (slop) ? slop : -slop, 0);
			}

			else if(_canMoveVertically)  {
				slopVector = new Point(0, moveDelta.y >= (slop) ? slop : -slop);
			}
		}
		return slopPassed;
	}

}

