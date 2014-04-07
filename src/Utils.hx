package ;

/**
 * ...
 * @author Wrong Tomato Factory
 */
import RenderConfig.AspectRatio;
class Utils
{

    public static function GetAspectRatio(width:Int, height:Int):AspectRatio
    {
        if (16 * height == 10 * width)
        {
            return AspectRatio.ASPECT_16x10;
        }
        else if (16 * height == 9 * width)
        {
            return AspectRatio.ASPECT_16x9;
        }
        else if (4 * height == 3 * width)
        {
            return AspectRatio.ASPECT_4x3;
        }
        else if (3 * height == 2 * width)
        {
            return AspectRatio.ASPECT_3x2;
        }
        else if (71 * height == 40 * width)
        {
        	return AspectRatio.ASPECT_71x40;
        }
        return AspectRatio.ASPECT_UNKNOWN;
    }

    public static function GetShadingIntensity(distance:Float):Float 
	{
        if (distance > RenderConfig.ShadingDistance) 
		{
            var factor:Float = distance / (3.0 * RenderConfig.ShadingDistance);
            factor = Clampf(factor, RenderConfig.ShadingFactorMin, RenderConfig.ShadingFactorMax);
            var damp:Float = 2.0;
            return Clampf((1.0 - (damp / factor)), 0.0, 1.0);
        }
        return 0.0;
    }	
	
	public static inline function Clampf(value:Float, min:Float, max:Float):Float
	{
		return ((value < min) ? min : ((value > max) ? max : value));
	}
	
	public static inline function Clamp(value:Int, min:Int, max:Int):Int
	{
		return ((value < min) ? min : ((value > max) ? max : value));		
	}
	
	public static inline function Wrapf(value:Float, min:Float, max:Float):Float
	{
		var range:Float = max - min;
		
		if (range <= 0.0)
		{
			return 0.0;
		}
		
		var result:Float = (value - min) % range;
		
		if (result < 0.0)
		{
			result += range;
		}
		
		return result + min;
	}
	
	public static inline function GetTextureXOffset(texIndex:UInt, x:Int):Int
	{
		return (texIndex % 8) * RenderConfig.TextureWidth + x;
	}
	
	public static inline function GetTextureYOffset(texIndex:UInt, y:Int):Int
	{
		return Math.floor(texIndex / 8) * RenderConfig.TextureHeight + y;
	}
	
}