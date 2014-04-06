package ;

import RenderConfig.AspectRatio;
import flash.ui.Mouse;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxG;
import flash.Lib;
import flash.geom.Point;

/**
 * ...
 * @author Wrong Tomato Factory
 */
class GameClass extends FlxGame
{

	public function new(GameSizeX:Int=640, GameSizeY:Int=480, ?InitialState:Class<FlxState>, Zoom:Float=1, UpdateFramerate:Int=60, DrawFramerate:Int=60, SkipSplash:Bool=false, StartFullscreen:Bool=false) 
	{
        var stageWidth:Int = Lib.current.stage.stageWidth;
        var stageHeight:Int = Lib.current.stage.stageHeight;

        var ratio:AspectRatio = Utils.GetAspectRatio(stageWidth, stageHeight);

        var refSize:Point = RenderConfig.GetReferenceSizeForAspect(ratio);

        RenderConfig.ReferenceWidth = Std.int(refSize.x);
        RenderConfig.ReferenceHeight = Std.int(refSize.y);

		RenderConfig.ProjectionPlaneWidth = Std.int(RenderConfig.ReferenceWidth / RenderConfig.PixelSize);
		RenderConfig.ProjectionPlaneHeight = Std.int(RenderConfig.ReferenceHeight / RenderConfig.PixelSize);

		var ratioX:Float = stageWidth / cast(RenderConfig.ReferenceWidth, Float);
		var ratioY:Float = stageHeight / cast(RenderConfig.ReferenceHeight, Float);
		var ratio:Float = Math.min(ratioX, ratioY);
		
		var fps:Int = 60;
		
		var fullScreen:Bool = false;
		#if desktop
		{
			fullScreen = true;
		}
		#end
		
		super(Math.ceil(stageWidth / ratio), Math.ceil(stageHeight / ratio), TitleState, ratio, fps, fps, false, fullScreen);		
		
		RenderConfig.Update();
		Debug.SetUp();
		
		#if desktop
		{
			Mouse.hide();
		}
		#end
		
	}
	
}