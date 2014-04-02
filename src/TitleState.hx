package ;

import flixel.FlxState;
import flixel.input.touch.FlxTouch;
import flixel.text.FlxText;
import flixel.FlxG;

/**
 * ...
 * @author Wrong Tomato Factory
 */
class TitleState extends FlxState
{

	override public function create()
	{
		super.create();
		
		var titleLabel:FlxText = new FlxText((FlxG.width - 100) / 2, FlxG.height / 2, 100, "basement dwellers");
		titleLabel.alignment = "center";
		
		this.add(titleLabel);
	}
	
	override public function update()
	{
		super.update();
		
		#if (desktop || web)
		if (FlxG.keys.justReleased.ENTER)
		{
			FlxG.switchState(new LevelState());
		}
		#elseif (mobile)
		var touch:FlxTouch = FlxG.touches.getFirst();
		if (touch != null)
		{
			touch.deactivate();
			FlxG.switchState(new LevelState());
		}		
		#end
	}
	
}