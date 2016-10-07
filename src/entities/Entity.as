package entities
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Entity
	{
		private var _spriteSheet:SpriteSheet;
		private var _boundingBox:Rectangle;
		private var _currentFrameKey:String;
		
		public function Entity(SpriteSheetA:SpriteSheet, BoundingBox:Rectangle, FrameKey:String)
		{
			_spriteSheet = SpriteSheetA;
			_boundingBox = BoundingBox.clone();
			_currentFrameKey = FrameKey;
		}
		
		protected function get position():Point
		{
			return _boundingBox.topLeft;
		}
		
		protected function setPosition(X:Number, Y:Number):void
		{
			_boundingBox.x = X;
			_boundingBox.y = Y;
		}
		
		protected function get width():Number
		{
			var Width:Number = _boundingBox.width;
			return Width;
		}
		
		protected function get height():Number
		{
			var Height:Number = _boundingBox.height;
			return Height;
		}
		
		public function drawOntoBuffer(Buffer:BitmapData):void
		{
			var FrameRect:Rectangle = _spriteSheet.getFrame(_currentFrameKey);
			Buffer.copyPixels(_spriteSheet.bitmapData, FrameRect, _boundingBox.topLeft, null, null, true);
		}
	}
}
