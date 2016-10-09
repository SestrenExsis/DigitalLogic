package entities
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Entity
	{
		private var _spriteSheet:SpriteSheet;
		private var _topLeft:Point;
		private var _currentFrameKey:String;
		private var _widthInTiles:uint;
		private var _heightInTiles:uint;
		
		public function Entity(SpriteSheetA:SpriteSheet, TopLeft:Point, FrameKey:String, WidthInTiles:uint = 1, HeightInTiles:uint = 1)
		{
			_spriteSheet = SpriteSheetA;
			_topLeft = TopLeft.clone();
			_currentFrameKey = FrameKey;
			_widthInTiles = WidthInTiles;
			_heightInTiles = HeightInTiles;
		}
		
		/**
		 * Gets the top-left corner of the Entity.
		 */
		protected function get position():Point
		{
			return _topLeft;
		}
		
		/**
		 * Sets the top-left corner of the Entity.
		 */
		protected function setPosition(X:Number, Y:Number):void
		{
			_topLeft.x = X;
			_topLeft.y = Y;
		}
		
		protected function get widthInTiles():uint
		{
			return _widthInTiles;
		}
		
		protected function get heightInTiles():uint
		{
			return _heightInTiles;
		}
		
		/**
		 * A getter function that accesses the frame rectangle through the Entity's sprite sheet.
		 */
		protected function get frameRect():Rectangle
		{
			var FrameRect:Rectangle = _spriteSheet.getFrame(_currentFrameKey);
			return FrameRect;
		}
		
		public function drawOntoBuffer(Buffer:BitmapData):void
		{
			var FrameRect:Rectangle = _spriteSheet.getFrame(_currentFrameKey);
			Buffer.copyPixels(_spriteSheet.bitmapData, FrameRect, _topLeft, null, null, true);
		}
	}
}
