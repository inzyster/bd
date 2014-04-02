package;

import flash.display.BitmapData;
import flixel.util.loaders.CachedGraphics;
import openfl.Assets;
import haxe.io.Path;
import haxe.xml.Parser;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTileSet;

class TiledLevel extends TiledMap
{

    private inline static var TILE_IMAGES_PATH = "assets/";

	public var tileSource:CachedGraphics;
	
    public function new(tiledLevel:Dynamic)
    {
        super(tiledLevel);

		var tileset:TiledTileSet = this.tilesets.get("Walls");
		if (FlxG.bitmap.checkCache("walls"))
		{
			tileSource = FlxG.bitmap.get("walls");
		}
		else 
		{
			tileSource = FlxG.bitmap.add(TILE_IMAGES_PATH + tileset.imageSource, true, "walls");
		}
    }

}