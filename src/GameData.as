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
		private static var _truthTableCache:Object;
		
		public static function init():void
		{
			if (_initialized)
				return;
			
			var DataBytes:ByteArrayAsset = ByteArrayAsset(new _assetGameData());
			var DataString:String = DataBytes.readUTFBytes(DataBytes.length);
			var DataObj:Object = JSON.parse(DataString);
			
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
			
			_truthTableCache = new Object();
			if (DataObj.hasOwnProperty("truthTables"))
			{
				var TruthTablesObj:Object = DataObj.truthTables;
				for (var TruthTableKey:String in TruthTablesObj)
				{
					var TruthTableObj:Object = TruthTablesObj[TruthTableKey];
					var InputNames:Vector.<String> = new Vector.<String>();
					if (TruthTableObj.hasOwnProperty("inputs"))
					{
						var InputsArray:Array = TruthTableObj["inputs"];
						for (var i:int = 0; i < InputsArray.length; i++)
						{
							InputNames.push(InputsArray[i]);
						}
					}
					
					var OutputNames:Vector.<String> = new Vector.<String>();
					if (TruthTableObj.hasOwnProperty("outputs"))
					{
						var OutputNamesArray:Array = TruthTableObj["outputs"];
						for (var o:int = 0; o < OutputNamesArray.length; o++)
						{
							OutputNames.push(OutputNamesArray[o]);
						}
					}
					
					var OutputValues:Object = new Object();
					if (TruthTableObj.hasOwnProperty("outputValues"))
					{
						var OutputValuesObj:Object = TruthTableObj["outputValues"];
						for (var OutputValueKey:String in OutputValuesObj)
						{
							var OutputValue:Array = OutputValuesObj[OutputValueKey];
							var NewArray:Array = new Array();
							for (var v:int = 0; v < OutputValue.length; v++)
							{
								var Value:Boolean = !(OutputValue[v] == 0);
								NewArray.push(Value);
							}
							OutputValues[OutputValueKey] = NewArray;
						}
					}
					
					var NewTruthTable:TruthTable = new TruthTable(TruthTableKey, InputNames, OutputNames, false, OutputValues);
					_truthTableCache[TruthTableKey] = NewTruthTable;
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
		
		public static function getTruthTable(Key:String):TruthTable
		{
			if (_truthTableCache.hasOwnProperty(Key))
				return _truthTableCache[Key];
			else
				return null;
		}
	}
}