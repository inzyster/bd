package ;

import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.Lib;
import flixel.FlxGame;
import flash.display.StageAlign;
import flash.display.StageScaleMode;

/**
 * ...
 * @author Wrong Tomato Factory
 */

class Main extends Sprite 
{
	public static function main():Void
	{	
/*		#if (!js && !flash)
		var args:Array<String> = Sys.args();
		if (args.length == 1)
		{
			GameConfig.GlobalScale = Std.parseFloat(args[0]);
		}
		#end
		GameConfig.Update();
*/		
		Lib.current.addChild(new Main());
	}
	
	public function new() 
	{
		super();
		
		if (stage != null) 
		{
			init();
		}
		else 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
	
	private function init(?E:Event):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		initialize();
		
		var game:FlxGame = new GameClass();
		addChild(game);
	}
	
	private function initialize():Void 
	{
		Lib.current.stage.align = StageAlign.TOP_LEFT;
        #if !ios
        {
		    Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
        }
        #end
		#if (desktop)
		{
			Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		}
		#end
	}
}
