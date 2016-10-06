package entities
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class SpriteSheet
	{
		private var _bitmapData:BitmapData;
		private var _frames:Object;
		
		public function SpriteSheet(BitmapDataA:BitmapData, SpriteSheetData:Object)
		{
			_bitmapData = BitmapDataA;
			
			if (SpriteSheetData.hasOwnProperty("frames"))
			{
				_frames = new Object();
				var FramesData:Object = SpriteSheetData.frames;
				for (var FrameKey:String in FramesData)
				{
					var Frame:Object = FramesData[FrameKey];
					var Rect:Rectangle = new Rectangle();
					if (Frame.hasOwnProperty("x"))
						Rect.x = Frame.x;
					if (Frame.hasOwnProperty("y"))
						Rect.y = Frame.y;
					if (Frame.hasOwnProperty("width"))
						Rect.width = Frame.width;
					if (Frame.hasOwnProperty("height"))
						Rect.height = Frame.height;
					_frames[FrameKey] = Rect;
				}
			}
		}
		
		public function destroy():void
		{
			for (var FrameKey:String in _frames)
			{
				_frames[FrameKey] = null;
			}
			_frames = null;
		}
		
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		
		public function getFrame(FrameKey:String):Rectangle
		{
			var FrameRect:Rectangle = null;
			if (_frames.hasOwnProperty(FrameKey))
				FrameRect = _frames[FrameKey];
			return FrameRect;
		}
	}
}