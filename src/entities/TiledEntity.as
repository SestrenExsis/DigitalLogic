package entities
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TiledEntity extends Entity
	{
		private var _widthInTiles:uint;
		private var _heightInTiles:uint;
		
		public function TiledEntity(SpriteSheetA:SpriteSheet, BoundingBox:Rectangle, FrameKey:String, WidthInTiles:uint = 20, HeightInTiles:uint = 15)
		{
			super(SpriteSheetA, BoundingBox, FrameKey);
			
			_widthInTiles = WidthInTiles;
			_heightInTiles = HeightInTiles;
		}
		
		override public function drawOntoBuffer(Buffer:BitmapData):void
		{
			var Position:Point = position;
			var InitialX:Number = Position.x;
			var InitialY:Number = Position.y;
			for (var y:uint = 0; y < _heightInTiles; y++)
			{
				for (var x:uint = 0; x < _widthInTiles; x++)
				{
					var TileX:Number = InitialX + width * x;
					var TileY:Number = InitialY + height * y;
					setPosition(TileX, TileY);
					super.drawOntoBuffer(Buffer);
				}
			}
			setPosition(InitialX, InitialY);
		}
	}
}
