package entities
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TiledEntity extends Entity
	{
		public function TiledEntity(SpriteSheetA:SpriteSheet, TopLeft:Point, FrameKey:String, WidthInTiles:uint = 20, HeightInTiles:uint = 15)
		{
			super(SpriteSheetA, TopLeft, FrameKey, WidthInTiles, HeightInTiles);
		}
		
		override public function drawOntoBuffer(Buffer:BitmapData):void
		{
			var Position:Point = position;
			var InitialX:Number = Position.x;
			var InitialY:Number = Position.y;
			var FrameRect:Rectangle = frameRect;
			var FrameWidth:Number = FrameRect.width;
			var FrameHeight:Number = FrameRect.height;
			for (var y:uint = 0; y < heightInTiles; y++)
			{
				for (var x:uint = 0; x < widthInTiles; x++)
				{
					var TileX:Number = InitialX + FrameWidth * x;
					var TileY:Number = InitialY + FrameHeight * y;
					setPosition(TileX, TileY);
					super.drawOntoBuffer(Buffer);
				}
			}
			setPosition(InitialX, InitialY);
		}
	}
}
