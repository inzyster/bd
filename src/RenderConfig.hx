package ;
import flixel.FlxCamera;
import flixel.FlxG;

/**
 * ...
 * @author Wrong Tomato Factory
 */
class RenderConfig
{

	public static var UseScale:Bool = false;
	public static var PixelSize:Int = 2;
	public static var GlobalScale:Int = 1;
	
	public static var ReferenceWidth:Int = 320;
	public static var ReferenceHeight:Int = 200;
	
    public static var ProjectionPlaneWidth:Int;
    public static var ProjectionPlaneHeight:Int;
    public static var HalfHeight:Int;

    public static var FOV: Angle = new Angle(60.0);

    public static var ProjectionPlaneDistance:Float;

    public static var RayStep:Angle;

    public static var ShadingDistance:Float = 10.0;
    public static var ShadingFactorMin:Float = 2.0;
    public static var ShadingFactorMax:Float = 15.0;
	
	public static var TextureWidth:Int = 64;
	public static var TextureHeight:Int = 64;
	public static var WallHeight:Int = 64;
	public static var WallHeightF:Float = cast(WallHeight, Float);

    public static var Floors:Bool = true;

    public static function Update() 
	{
		GlobalScale = Std.int(FlxCamera.defaultZoom);
        ProjectionPlaneDistance = (cast(ProjectionPlaneWidth, Float) / 2.0) / Math.tan(FOV.radians / 2.0);
        RayStep = new Angle(FOV.degrees / cast(ProjectionPlaneWidth, Float));
        HalfHeight = Math.round(ProjectionPlaneHeight / 2);
    }	
	
}