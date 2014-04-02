package ;
import flixel.FlxG;

/**
 * ...
 * @author Wrong Tomato Factory
 */
class Debug
{

	#if debug
	public static var Enabled:Bool = true;
	#else
	public static var Enabled:Bool = false;
	#end
	
	private static var _LogEntries:Array<String> = new Array<String>();
	
	public static var CurrentRay:Int = 0;
	
	public static function Log(entry:String)
	{
		if (Enabled)
		{
			_LogEntries.push(entry);
		}
	}
	
	public static function Commit()
	{
		if (!Enabled)
		{
			return;
		}
		FlxG.log.clear();
		while (_LogEntries.length > 0)
		{
			FlxG.log.add(_LogEntries.pop());
		}
	}
	
	public static function SetUp()
	{
		CurrentRay = Math.round(cast(RenderConfig.ProjectionPlaneWidth, Float) / 2.0);
	}
	
}