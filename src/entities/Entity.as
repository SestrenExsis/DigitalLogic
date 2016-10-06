package entities
{
	import flash.display.BitmapData;
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
		
		public function destroy():void
		{
			_boundingBox = null;
		}
		
		public function drawOntoBuffer(Buffer:BitmapData):void
		{
			var FrameRect:Rectangle = _spriteSheet.getFrame(_currentFrameKey);
			Buffer.copyPixels(_spriteSheet.bitmapData, FrameRect, _boundingBox.topLeft, null, null, true);
		}
	}
}