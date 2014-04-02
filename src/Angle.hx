package ;

/**
 * ...
 * @author Wrong Tomato Factory
 */
class Angle
{

	private static var _DegToRad:Float = Math.PI / 180.0;
	private static var _RadToDeg:Float = 180.0 / Math.PI;
		
	private static var _Min:Float = -180.0;
	private static var _Max:Float = 180.0;
	
	public var degrees(get, set):Float;		
	public var radians(get, never):Float;
	public var quadrant(get, never):Int;
	
	private var _degrees:Float;
	public function get_degrees():Float
	{
		return _degrees;
	}
	public function set_degrees(value:Float):Float
	{
		_degrees = value;
		return _degrees;
	}
	
	public function get_radians():Float
	{
		return this.degrees * _DegToRad;
	}
	
	public function new(deg:Float)
	{
		this.degrees = deg;
	}
	
	public function get_quadrant():Int
	{
        if (this.degrees >= 0.0 && this.degrees < 90.0) 
		{
            return 1;
        }
        else if (this.degrees >= 90.0 && this.degrees < 180.0) 
		{
            return 2;
        }
        else if (this.degrees < 0.0 && this.degrees >= -90.0) 
		{
            return 4;
        }
        else 
		{
            return 3;
        }
    }	
	
	public static function FromRadians(radians:Float):Angle
	{
		return new Angle(radians * _RadToDeg);
	}
	
	public static inline function Wrap(deg:Float)
	{
		return Utils.Wrapf(deg, _Min, _Max);
	}
	
	public function rotate(deg:Float)
	{
		this.degrees = Wrap(this.degrees + deg);
	}
		
}