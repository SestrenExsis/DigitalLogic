package entities
{
	import flash.display.Bitmap;
	
	import mx.core.ByteArrayAsset;
	
	public final class SpriteSheetKey
	{
		public static const SPRITES:String = "Sprites.png";
		
		[Embed(source = "../assets/images/Sprites.png" )]
		private static var _assetSpriteImage:Class;
		[Embed(source="../assets/data/GameData.json", mimeType="application/octet-stream")]
		private static var _assetGameData:Class;
		private static var _initialized:Boolean = false;
		private static var _spriteSheetCache:Object;
		
		public static function init():void
		{
			if (_initialized)
				return;
			
			_spriteSheetCache = new Object();
			var DataBytes:ByteArrayAsset = ByteArrayAsset(new _assetGameData());
			var DataString:String = DataBytes.readUTFBytes(DataBytes.length);
			var DataObj:Object = JSON.parse(DataString);
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
			
			_initialized = true;
		}
		
		public static function getSpriteSheet(Key:String):SpriteSheet
		{
			if (_spriteSheetCache.hasOwnProperty(Key))
				return _spriteSheetCache[Key];
			else
				return null;
		}
	}
}