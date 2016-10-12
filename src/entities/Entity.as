package entities
{
	import interfaces.IGameEntity;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Entity implements IGameEntity
	{
		private var _spriteSheet:SpriteSheet;
		private var _topLeft:Point;
		private var _currentFrameKey:String;
		private var _widthInTiles:uint;
		private var _heightInTiles:uint;
		private var _drawRepeatX:uint = 1;
		private var _drawRepeatY:uint = 1;
		
		public function Entity(SpriteSheetA:SpriteSheet, TopLeft:Point, FrameKey:String, WidthInTiles:uint = 1, HeightInTiles:uint = 1)
		{
			_spriteSheet = SpriteSheetA;
			_topLeft = TopLeft.clone();
			_currentFrameKey = FrameKey;
			_widthInTiles = WidthInTiles;
			_heightInTiles = HeightInTiles;
		}
		
		public function get spriteSheet():SpriteSheet
		{
			return _spriteSheet;
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
		public function setPosition(X:Number, Y:Number):void
		{
			_topLeft.x = X;
			_topLeft.y = Y;
		}
		
		public function setFrameKey(FrameKey:String):void
		{
			_currentFrameKey = FrameKey;
		}
		
		public function get widthInTiles():uint
		{
			return _widthInTiles;
		}
		
		public function get heightInTiles():uint
		{
			return _heightInTiles;
		}
		
		public function setDrawRepeat(X:uint, Y:uint):void
		{
			_drawRepeatX = X;
			_drawRepeatY = Y;
		}
		
		/**
		 * A getter function that accesses the frame rectangle through the Entity's sprite sheet.
		 */
		public function get frameRect():Rectangle
		{
			var FrameRect:Rectangle = _spriteSheet.getFrame(_currentFrameKey);
			return FrameRect;
		}
		
		public function drawOntoBuffer(Buffer:BitmapData):void
		{
			var Position:Point = position;
			var InitialX:Number = Position.x;
			var InitialY:Number = Position.y;
			var FrameRect:Rectangle = frameRect;
			var FrameWidth:Number = FrameRect.width;
			var FrameHeight:Number = FrameRect.height;
			for (var y:uint = 0; y < _drawRepeatY; y++)
			{
				for (var x:uint = 0; x < _drawRepeatX; x++)
				{
					var TileX:Number = InitialX + FrameWidth * x;
					var TileY:Number = InitialY + FrameHeight * y;
					setPosition(TileX, TileY);
					Buffer.copyPixels(_spriteSheet.bitmapData, FrameRect, _topLeft, null, null, true);
				}
			}
			setPosition(InitialX, InitialY);
		}
	}
}
