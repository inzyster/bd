package ;

import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.BlendMode;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.FlxState;
import flixel.FlxG;
import flash.Lib;
import flixel.input.touch.FlxTouch;
import flixel.input.touch.FlxTouchManager;
import flixel.util.FlxPoint;
#if !js
import flash.system.System;
#end
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.system.debug.FlxDebugger;
import openfl.Assets;

/**
 * ...
 * @author Wrong Tomato Factory
 */
class LevelState extends FlxState
{

	private var _level:TiledLevel;
	private var _wallsLayer:TiledLayer;
	private var _floorLayer:TiledLayer;
	private var _ceilingLayer:TiledLayer;
	
	private var _canvas:BitmapData;
	
	private var _needsRedraw:Bool;
	
	private var _unitCoordinates:Point;
	private var _viewingAngle:Angle;
	
	private var _canvasSprite:FlxSprite;
	
	override public function create()
	{
		super.create();
		
		_level = new TiledLevel("assets/E1M1.tmx");		
				
		_wallsLayer = _level.getLayer("Walls");
		_ceilingLayer = _level.getLayer("Ceiling");
		_floorLayer = _level.getLayer("Floor");
		
		_wallsLayer.tileArray; // unload the data first
		_floorLayer.tileArray;
		_ceilingLayer.tileArray;

		_level.tileSource.bitmap.lock();
				
		var spawners:TiledObjectGroup = _level.getObjectGroup("Spawners");
		var objects:Array<TiledObject> = spawners.objects;
		if (objects.length == 1)
		{
			var startPoint:TiledObject = objects[0];
			_unitCoordinates = new Point(startPoint.x + (startPoint.width / 2), startPoint.y + (startPoint.height / 2));
			_viewingAngle = new Angle(Std.parseFloat(startPoint.custom.get("Direction")));
		}				
		
		_canvasSprite = new FlxSprite(0, 0);
		_canvasSprite.antialiasing = false;
		_canvasSprite.makeGraphic(RenderConfig.ProjectionPlaneWidth, RenderConfig.ProjectionPlaneHeight, 0xff00007f);
		if (RenderConfig.PixelSize > 1)
		{
			_canvasSprite.scale.set(RenderConfig.PixelSize, RenderConfig.PixelSize);
			_canvasSprite.x = RenderConfig.ProjectionPlaneWidth / 2;
			_canvasSprite.y = RenderConfig.ProjectionPlaneHeight / 2;
		}
		
		_canvas = _canvasSprite.cachedGraphics.bitmap;
		
		this.add(_canvasSprite);
		
		_needsRedraw = true;
		
	}

    override public function update()
    {
        super.update();		
		
		_readInput();
		_processInput();
		_renderProjection();
		
		Debug.Commit();
    }
	
	private function _readInput()
	{
		#if desktop
		InputManager.Exit = FlxG.keys.justReleased.ESCAPE;
		
		InputManager.MoveForward = FlxG.keys.pressed.UP;
		InputManager.MoveBackward = FlxG.keys.pressed.DOWN;
		InputManager.TurnLeft = FlxG.keys.pressed.LEFT;
		InputManager.TurnRight = FlxG.keys.pressed.RIGHT;
		
		#elseif mobile
		var touch:FlxTouch = FlxG.touches.getFirst();
		if (touch != null)
		{
			if (touch.pressed)
			{
				InputManager.TurnLeft = touch.screenX < FlxG.width / 2;
				InputManager.TurnRight = touch.screenX >= FlxG.width / 2;
				InputManager.MoveForward = touch.screenY < FlxG.width / 2;
				InputManager.MoveBackward = touch.screenY >= FlxG.width / 2;
			}
		}
		#end
	}
	
	private function _processInput()
	{
		#if !js
        if (InputManager.Exit)
        {
            System.exit(0);
        }		
		#end
		
		if (InputManager.TurnLeft)
		{
			_viewingAngle.rotate( -GameConfig.MovementSpeed * 2.0);
			_needsRedraw = true;
		}
		else if (InputManager.TurnRight)
		{
			_viewingAngle.rotate(GameConfig.MovementSpeed * 2.0);
			_needsRedraw = true;
		}
						
		var newLocation:Point = _unitCoordinates.clone();
		var newTestLocation:Point = _unitCoordinates.clone();

        var deltaX:Float = 0.0;
        var deltaY:Float = 0.0;

		if (InputManager.MoveForward)
		{
            deltaX = Math.cos(_viewingAngle.radians) * (GameConfig.MovementSpeed + GameConfig.MovementIncrement);
            deltaY = Math.sin(_viewingAngle.radians) * (GameConfig.MovementSpeed + GameConfig.MovementIncrement);
            newLocation.x = _unitCoordinates.x + deltaX;
            newLocation.y = _unitCoordinates.y + deltaY;
            newTestLocation.x = _unitCoordinates.x + deltaX + (deltaX > 0.0 ? 16.0 : (deltaX < 0.0 ? -16.0 : 0.0));
            newTestLocation.y = _unitCoordinates.y + deltaY + (deltaY > 0.0 ? 16.0 : (deltaY < 0.0 ? -16.0 : 0.0));
            newLocation = _moveOnMap(_unitCoordinates, newLocation, newTestLocation);
            _needsRedraw = true;			
		}
		else if (InputManager.MoveBackward)
		{
            deltaX = -Math.cos(_viewingAngle.radians) * (GameConfig.MovementSpeed + GameConfig.MovementIncrement);
            deltaY = -Math.sin(_viewingAngle.radians) * (GameConfig.MovementSpeed + GameConfig.MovementIncrement);
            newLocation.x = _unitCoordinates.x + deltaX;
            newLocation.y = _unitCoordinates.y + deltaY;
            newTestLocation.x = _unitCoordinates.x + deltaX + (deltaX > 0.0 ? 16.0 : (deltaX < 0.0 ? -16.0 : 0.0));
            newTestLocation.y = _unitCoordinates.y + deltaY + (deltaY > 0.0 ? 16.0 : (deltaY < 0.0 ? -16.0 : 0.0));
            newLocation = _moveOnMap(_unitCoordinates, newLocation, newTestLocation);
            _needsRedraw = true;						
		}
		
		if (Debug.Enabled)
		{
			if (FlxG.keys.justReleased.A)
			{
				Debug.CurrentRay--;
				if (Debug.CurrentRay < 0)
				{
					Debug.CurrentRay = RenderConfig.ProjectionPlaneWidth - 1;
				}
				_needsRedraw = true;
			}
			else if (FlxG.keys.justReleased.D)
			{
				Debug.CurrentRay++;
				if (Debug.CurrentRay >= RenderConfig.ProjectionPlaneWidth)
				{
					Debug.CurrentRay = 0;
				}
				_needsRedraw = true;
			}
		}
		
		if (FlxG.keys.justReleased.MINUS)
		{
			_canvasSprite.scale.x -= 0.2;
			_canvasSprite.scale.y -= 0.2;
			_canvasSprite.update();
			_needsRedraw = true;
		}
		else if (FlxG.keys.justReleased.PLUS && _canvasSprite.scale.x + 0.0000000000002 < RenderConfig.PixelSize)
		{
			_canvasSprite.scale.set(_canvasSprite.scale.x + 0.2, _canvasSprite.scale.y + 0.2);
			_canvasSprite.update();
			_needsRedraw = true;
		}
		
		_unitCoordinates = newLocation;
		
	}
	
	private function _renderProjection()
	{
		if (!_needsRedraw)
		{
			return;
		}
		
		_canvas.fillRect(_canvas.rect, 0xff00007f);
		
		_renderLevel();
		
		#if debug
			_needsRedraw = true;
		#else
			_needsRedraw = false;
		#end
		
		
	}
	
	private function _getTileAt(x:Float, y:Float, layer:TiledLayer):UInt 
	{
		if (x < 0.0 || y < 0.0 || x > cast(_level.fullWidth, Float) || y > cast(_level.fullHeight, Float))
		{
			return 0;
		}
		
		var xGrid:Float = x / cast(_level.tileWidth, Float);
		var yGrid:Float = y / cast(_level.tileHeight, Float);
		
		var index:Int = Math.floor(xGrid) + layer.width * (Math.floor(yGrid));
		
		return layer.tileArray[index];
	}
	
	private function _getWallTileAt(x:Float, y:Float):UInt
	{
		return _getTileAt(x, y, _wallsLayer);
	}
	
	private function _getFloorTileAt(x:Float, y:Float):UInt
	{
		return _getTileAt(x, y, _floorLayer);
	}
	
	private function _getCeilingTileAt(x:Float, y:Float):UInt
	{
		return _getTileAt(x, y, _ceilingLayer);
	}
	
	private function _hasWallAt(x:Float, y:Float):Bool
	{
		return _getWallTileAt(x, y) > 0;
	}
	
	private function _moveOnMap(_fromLocation:Point, _toLocation:Point, _testLocation:Point = null):Point
	{
		if (_testLocation == null)
		{
			_testLocation = _toLocation;
		}		
		
		if (_hasWallAt(_testLocation.x, _fromLocation.y))
		{
			_toLocation.x = _fromLocation.x;
		}
		
		if (_hasWallAt(_fromLocation.x, _testLocation.y))
		{
			_toLocation.y = _fromLocation.y;
		}
		
		return _toLocation;
	}
	
	private function _renderLevel()
	{
		var alpha:Angle = new Angle(Angle.Wrap(_viewingAngle.degrees - (RenderConfig.FOV.degrees / 2.0)));
        var horizontalRayPos:Point = _unitCoordinates.clone();
        var verticalRayPos:Point = _unitCoordinates.clone();
        var horizontalDist:Float = Math.POSITIVE_INFINITY;
        var verticalDist:Float = Math.POSITIVE_INFINITY;
        var wallHit:Bool = false;
        var deltaX:Float;
        var deltaY:Float;
        var wallHeight:Int = 0;
        var alphaRadians:Float = 0.0;
        var viewingAngleRadians:Float = _viewingAngle.radians;
        var horizontalHitPos:Point = null;
        var verticalHitPos:Point = null;
        var textureOffset:Int = 0;
        var verticalWall:UInt = 0;
        var horizontalWall:UInt = 0;
        var wallTexture:UInt = 0;
        var quadrant:Int = 0;
        var tanAlpha:Float = 0.0;
        var betaRadians:Float = 0.0;
        var dist:Float = 0.0;
		
		var tileWidth:Float = cast(_level.tileWidth, Float);
		var tileHeight:Float = cast(_level.tileHeight, Float);
		var mapWidth:Float = cast(_level.fullWidth, Float);
		var mapHeight:Float = cast(_level.fullHeight, Float);
		var wallSlice:BitmapData = new BitmapData(1, RenderConfig.WallHeight, false, 0xff000000);
		
		_canvas.lock();
		
		for (column in 0...RenderConfig.ProjectionPlaneWidth)
		{
            alphaRadians = alpha.radians;
            verticalDist = Math.POSITIVE_INFINITY;
            horizontalDist = Math.POSITIVE_INFINITY;
            wallHeight = 0;
            horizontalHitPos = null;
            verticalHitPos = null;
            horizontalRayPos = _unitCoordinates.clone();
            verticalRayPos = _unitCoordinates.clone();
            textureOffset = 0;
            horizontalWall = 0;
            verticalWall = 0;
            wallTexture = 0;
            quadrant = alpha.quadrant;
            tanAlpha = Math.tan(alphaRadians);
            betaRadians = alphaRadians - viewingAngleRadians;
            dist = 0;


            // ray facing down
            if (quadrant == 1 || quadrant == 2) 
			{
                horizontalRayPos.y = (Math.floor(_unitCoordinates.y / tileHeight) * tileHeight) + tileHeight;
                deltaY = tileHeight;
                deltaX = tileWidth / tanAlpha;
                horizontalRayPos.x = _unitCoordinates.x + (Math.abs(_unitCoordinates.y - horizontalRayPos.y) / tanAlpha);
            }
            else 
			{
                horizontalRayPos.y = (Math.floor(_unitCoordinates.y / tileHeight) * tileHeight) - 1;
                deltaY = -tileHeight;
                deltaX = -tileWidth / tanAlpha;
                horizontalRayPos.x = _unitCoordinates.x - (Math.abs(_unitCoordinates.y - horizontalRayPos.y) / tanAlpha);
            }

            if (alpha.degrees == 90.0 || alpha.degrees == -90.0) 
			{
                deltaX = 0.0;
                horizontalRayPos.x = _unitCoordinates.x;
            }
            else if (alpha.degrees == 0.0 || alpha.degrees == 180.0 || alpha.degrees == -180.0) 
			{
                horizontalRayPos.x = Math.POSITIVE_INFINITY;
            }

            while (!wallHit) 
			{
                horizontalWall = _getWallTileAt(horizontalRayPos.x, horizontalRayPos.y);
                wallHit = (horizontalWall > 0);
                if (!wallHit) 
				{
                    horizontalRayPos.x += deltaX;
                    horizontalRayPos.y += deltaY;
                }
                if (horizontalRayPos.x <= 0.0 ||
                    horizontalRayPos.y <= 0.0 ||
                    horizontalRayPos.x >= mapWidth ||
                    horizontalRayPos.y >= mapHeight) 
				{
                    break;
                }
            }

			if (Debug.Enabled && column == Debug.CurrentRay)
			{
				Debug.Log("horizontal ray = " + horizontalRayPos);
				Debug.Log("deltaX = " + deltaX + ", deltaY = " + deltaY);
			}
			
            if (wallHit) 
			{
                horizontalRayPos.x = Math.floor(horizontalRayPos.x);
                horizontalRayPos.y = Math.floor(horizontalRayPos.y);
                horizontalDist = Point.distance(_unitCoordinates, horizontalRayPos);
                horizontalDist = horizontalDist * Math.cos(betaRadians);
                horizontalHitPos = horizontalRayPos.clone();
            }
            wallHit = false;

            // looking for vertical intersection

            // ray facing right
            if (quadrant == 1 || quadrant == 4) 
			{
                verticalRayPos.x = (Math.floor(_unitCoordinates.x / tileWidth) * tileWidth) + tileWidth;
                deltaX = tileWidth;
                deltaY = tileHeight * tanAlpha;
                verticalRayPos.y = _unitCoordinates.y + (Math.abs(_unitCoordinates.x - verticalRayPos.x) * tanAlpha);
            }
            else 
			{
                verticalRayPos.x = (Math.floor(_unitCoordinates.x / tileWidth) * tileWidth) - 1;
                deltaX = -tileWidth;
                deltaY = -tileHeight * tanAlpha;
                verticalRayPos.y = _unitCoordinates.y - (Math.abs(_unitCoordinates.x - verticalRayPos.x) * tanAlpha);
            }

            if (alpha.degrees == 0.0 || alpha.degrees == 180.0 || alpha.degrees == -180.0) 
			{
                deltaY = 0.0;
            }
            else if (alpha.degrees == 90.0 || alpha.degrees == - 90.0) 
			{
                verticalRayPos.y = Math.POSITIVE_INFINITY;
            }

            while (!wallHit) 
			{
                verticalWall = _getWallTileAt(verticalRayPos.x, verticalRayPos.y);
                wallHit = (verticalWall > 0);
                if (!wallHit) 
				{
                    verticalRayPos.x += deltaX;
                    verticalRayPos.y += deltaY;
                }
                if (verticalRayPos.x <= 0.0 ||
                    verticalRayPos.y <= 0.0 ||
                    verticalRayPos.x >= mapWidth ||
                    verticalRayPos.y >= mapHeight) 
				{
                    break;
                }
            }

			if (Debug.Enabled && column == Debug.CurrentRay)
			{
				Debug.Log("vertical ray = " + verticalRayPos);
				Debug.Log("deltaX = " + deltaX + ", deltaY = " + deltaY);
			}
			
            if (wallHit) 
			{
                verticalRayPos.x = Math.floor(verticalRayPos.x);
                verticalRayPos.y = Math.floor(verticalRayPos.y);
                verticalDist = Point.distance(_unitCoordinates, verticalRayPos);
                verticalDist = verticalDist * Math.cos(betaRadians);
                verticalHitPos = verticalRayPos.clone();
            }
            wallHit = false;
			
            // render!

            if (Math.isFinite(horizontalDist) || Math.isFinite(verticalDist)) 
			{
                if (horizontalDist < verticalDist) 
				{
                    dist = horizontalDist;
                    textureOffset = Math.round(horizontalHitPos.x) % RenderConfig.TextureWidth;
                    wallTexture = horizontalWall - 1;
                }
                else 
				{
                    dist = verticalDist;
                    textureOffset = Math.round(verticalHitPos.y) % RenderConfig.TextureHeight;
                    wallTexture = verticalWall + 8 - 1;
                }
                wallHeight = Math.round((RenderConfig.WallHeightF / dist) * RenderConfig.ProjectionPlaneDistance);
            }

            if (wallHeight > 0) 
			{
				var wallHeightF = cast(wallHeight, Float);
				var srcRect:Rectangle = new Rectangle(
						cast(Utils.GetTextureXOffset(wallTexture, textureOffset), Float), 
						0.0, 
						1.0, 
						cast(RenderConfig.TextureHeight, Float)
					);
					
				var yStart:Int = Std.int((RenderConfig.ProjectionPlaneHeight - wallHeight) / 2.0);
				var srcY:Int = 0;	
				
				var textureAlpha:Int = Std.int(255.0 * (1.0 - Utils.GetShadingIntensity(dist)));
					
				var wallScale:Float = wallHeightF / RenderConfig.WallHeightF;

				for (y in 0...wallHeight)
				{
					if (y == 0)
					{
						srcY = 0;
					}
					else if (y == wallHeight - 1)
					{
						srcY = RenderConfig.WallHeight - 1;
					}
					else 
					{
						if (wallScale == 1.0)
						{
							srcY = y;
						}
						else
						{
                            srcY = Math.floor(cast(y, Float) / wallScale);
						}
					}
					if ((y + yStart) >= 0 && (y + yStart) < RenderConfig.ProjectionPlaneHeight)
					{
						_canvas.setPixel32(
							column, 
							y + yStart, 
							_level.tileSource.bitmap.getPixel(
								Std.int(srcRect.x), 
								srcY
							) | textureAlpha << 24
						);
					}
				}
			
                if (RenderConfig.Floors) 
				{
					var yFloorStart = yStart + wallHeight;
					var yEnd = RenderConfig.ProjectionPlaneHeight - (yFloorStart);
					
					var floorDist:Float = Math.POSITIVE_INFINITY;
					var linearDist:Float = Math.POSITIVE_INFINITY;
					var floorRay:Point = _unitCoordinates.clone();
					var floorTexture:UInt = 0;
					var ceilingTexture:UInt = 0;
					var floorTextureOffset:Point = new Point();
					
					for (yFloor in 0...yEnd)
					{
						linearDist = ((RenderConfig.WallHeightF / 2.0) * RenderConfig.ProjectionPlaneDistance) / (yFloor + yFloorStart - (RenderConfig.ProjectionPlaneHeight / 2) + 1);
						floorDist = linearDist / Math.cos(betaRadians);
						floorRay.x = _unitCoordinates.x + (floorDist * Math.cos(alphaRadians));
						floorRay.y = _unitCoordinates.y + (floorDist * Math.sin(alphaRadians));
						floorTexture = _getFloorTileAt(floorRay.x, floorRay.y);
						ceilingTexture = _getCeilingTileAt(floorRay.x, floorRay.y);
						if (floorTexture > 0)
						{
							floorTexture--;
							ceilingTexture--;
							floorTextureOffset.x = Math.floor(floorRay.x) % RenderConfig.TextureWidth;
							floorTextureOffset.y = Math.floor(floorRay.y) % RenderConfig.TextureHeight;
							
							textureAlpha = Std.int(255.0 * (1.0 - Utils.GetShadingIntensity(linearDist)));
							
							if ((yFloorStart + yFloor) < RenderConfig.ProjectionPlaneHeight)
							{
								_canvas.setPixel32(
									column, 
									yFloorStart + yFloor, 
									(_level.tileSource.bitmap.getPixel(
										Utils.GetTextureXOffset(floorTexture, Std.int(floorTextureOffset.x)), 
										Utils.GetTextureYOffset(floorTexture, Std.int(floorTextureOffset.y))
									) | textureAlpha << 24)
								);
							}

							if ((yFloorStart - yFloor - wallHeight - 1) >= 0)
							{
								_canvas.setPixel32(
									column,
									yFloorStart - yFloor - wallHeight - 1,
									(_level.tileSource.bitmap.getPixel(
										Utils.GetTextureXOffset(ceilingTexture, Std.int(floorTextureOffset.x)), 
										Utils.GetTextureYOffset(ceilingTexture, Std.int(floorTextureOffset.y))
									) | textureAlpha << 24)
								);
							}							

							floorTexture = 0;
                            ceilingTexture = 0;
						}
						else 
						{
							Debug.Log("failed floor ray: " + floorRay);
						}
					}
					
                }

            }

			
            if (Debug.Enabled && column == Debug.CurrentRay) 
			{
                Debug.Log("ray for angle " + alpha.degrees);
                Debug.Log("horizontal = " + horizontalDist);
                Debug.Log("vertical = " + verticalDist);
                if (horizontalHitPos != null) 
				{
                    Debug.Log("horizontal hit at " + horizontalHitPos);
                }
                if (verticalHitPos != null) 
				{
                    Debug.Log("vertical hit at " + verticalHitPos);
                }
                Debug.Log("wall height = " + wallHeight);
                Debug.Log("texture offset = " + textureOffset);
                Debug.Log("wall texture = " + wallTexture);
            }			
			
            alpha.rotate(RenderConfig.RayStep.degrees);						
			
		}
		
		_canvas.unlock();
		
	}
	
}