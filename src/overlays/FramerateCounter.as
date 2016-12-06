package overlays
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import interfaces.IGameEntity;
	
	public class FramerateCounter implements IGameEntity
	{
		private var _spriteSheet:SpriteSheet;
		private var _topLeft:Point;
		private var _timeLastUpdate:uint;
		private var _timeLastFrame:uint;
		private var _frameCount:uint;
		private var _displayValue:String;
		private var _refreshInterval:uint = 1000;
		
		public function FramerateCounter(SpriteSheetA:SpriteSheet)
		{
			_spriteSheet = SpriteSheetA;
			_topLeft = new Point(1, 1);
			_frameCount = 0;
			_displayValue = ".";
			_timeLastUpdate = _timeLastFrame = getTimer();
		}
		
		private function getFrameRect(FrameKey:String):Rectangle
		{
			var FrameRect:Rectangle = _spriteSheet.getFrame(FrameKey);
			return FrameRect;
		}
		
		public function update():void
		{
			_frameCount++;
			var CurrentTime:int = getTimer();
			var TimeElapsed:int = CurrentTime - _timeLastUpdate;
			if (TimeElapsed > _refreshInterval)
			{
				var framerateValue:Number = _refreshInterval / (TimeElapsed / _frameCount);
				_displayValue = framerateValue.toFixed(1).toString();
				_timeLastUpdate = CurrentTime;
				_frameCount = 0;
			}
			_timeLastFrame = CurrentTime;
		}
		
		public function drawOntoBuffer(Buffer:BitmapData):void
		{
			var InitialX:Number = _topLeft.x;
			var InitialY:Number = _topLeft.y;
			var CurrentX:Number = InitialX;
			var CurrentY:Number = InitialY;
			for (var i:uint = 0; i < _displayValue.length; i++)
			{
				var DisplayChar:String = _displayValue.charAt(i);
				var FrameRect:Rectangle = getFrameRect("Font - " + DisplayChar);
				var FrameWidth:Number = FrameRect.width;
				var FrameHeight:Number = FrameRect.height;
				_topLeft.setTo(CurrentX, CurrentY);
				Buffer.copyPixels(_spriteSheet.bitmapData, FrameRect, _topLeft, null, null, true);
				CurrentX += FrameWidth + 1;
			}
			_topLeft.setTo(InitialX, InitialY);
		}
	}
}
