package 
{
	import flash.display.Bitmap;
	
	import mx.core.ByteArrayAsset;
	
	import truthTables.TruthTable;
	
	public final class GameData
	{
		public static const SPRITES:String = "Sprites.png";
		
		[Embed(source = "../assets/images/Sprites.png" )]
		private static var _assetSpriteImage:Class;
		[Embed(source="../assets/data/GameData.json", mimeType="application/octet-stream")]
		private static var _assetGameData:Class;
		private static var _initialized:Boolean = false;
		private static var _spriteSheetCache:Object;
		private static var _entityObjectCache:Object;
		
		public static function init():void
		{
			if (_initialized)
				return;
			
			var DataBytes:ByteArrayAsset = ByteArrayAsset(new _assetGameData());
			var DataString:String = DataBytes.readUTFBytes(DataBytes.length);
			var DataObj:Object = JSON.parse(DataString);
			
			// Initialize sprite sheet cache
			_spriteSheetCache = new Object();
			if (DataObj.hasOwnProperty("spriteSheets"))
			{
				var SpriteSheetsObj:Object = DataObj.spriteSheets;
				if (SpriteSheetsObj.hasOwnProperty(SPRITES))
				{
					var SpriteSheetKeyObj:Object = SpriteSheetsObj[SPRITES];
					var SpriteBitmap:Bitmap = new _assetSpriteImage() as Bitmap;
					var SpriteSheetA:SpriteSheet = new SpriteSheet(SpriteBitmap.bitmapData, SpriteSheetKeyObj);
					_spriteSheetCache[SPRITES] = SpriteSheetA;
				}
			}
			
			// Initialize entity object cache
			_entityObjectCache = new Object();
			if (DataObj.hasOwnProperty("entities"))
			{
				var EntitiesObj:Object = DataObj.entities;
				for (var EntityKey:String in EntitiesObj)
				{
					var EntityObj:Object = EntitiesObj[EntityKey];
					_entityObjectCache[EntityKey] = EntityObj;
				}
			}
			
			_initialized = true;
		}
		
		public static function getSpriteSheet(Key:String):SpriteSheet
		{
			if (_spriteSheetCache.hasOwnProperty(Key))
				return _spriteSheetCache[Key];
			else
				return null;
		}
		
		public static function getEntityObject(Key:String):Object
		{
			if (_entityObjectCache.hasOwnProperty(Key))
				return _entityObjectCache[Key];
			else
				return null;
		}
	}
}