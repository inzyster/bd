package ;

/**
 * ...
 * @author Wrong Tomato Factory
 */
class InputManager
{

	public static var MoveForward:Bool;
	public static var MoveBackward:Bool;
	public static var TurnLeft:Bool;
	public static var TurnRight:Bool;
	public static var Exit:Bool;
	public static var Proceed:Bool;
	
	public static function Clear()
	{
		MoveForward = false;
		MoveBackward = false;
		TurnLeft = false;
		TurnRight = false;
		Exit = false;
		Proceed = false;
	}
	
}