package ;

/**
 * ...
 * @author Wrong Tomato Factory
 */
class Utils
{

    public static function GetShadingIntensity(distance:Float):Float 
	{
        if (distance > RenderConfig.ShadingDistance) 
		{
            var factor:Float = distance / (2.0 * RenderConfig.ShadingDistance);
            factor = Clampf(factor, RenderConfig.ShadingFactorMin, RenderConfig.ShadingFactorMax);
            return 1.0 - (1.0 / factor);
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