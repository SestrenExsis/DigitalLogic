package 
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
					if (Frame.hasOwnProperty("glyphs") && Frame.hasOwnProperty("widthInGlyphs"))
					{
						var WidthInGlyphs:uint = Frame.widthInGlyphs;
						var Glyphs:Array = Frame.glyphs;
						var HeightInGlyphs:uint = Glyphs.length / WidthInGlyphs;
						var GlyphWidth:uint = Rect.width / WidthInGlyphs;
						var GlyphHeight:uint = Rect.height / HeightInGlyphs;
						for (var i:uint = 0; i < Glyphs.length; i++)
						{
							var GlyphRect:Rectangle = new Rectangle();
							GlyphRect.width = GlyphWidth;
							GlyphRect.height = GlyphHeight;
							var GlyphX:uint = i % WidthInGlyphs;
							var GlyphY:uint = Math.floor(i / WidthInGlyphs);
							GlyphRect.x = Frame.x + GlyphX * GlyphWidth;
							GlyphRect.y = Frame.y + GlyphY * GlyphHeight;
							var GlyphKey:String = FrameKey + " - " + Glyphs[i];
							_frames[GlyphKey] = GlyphRect;
						}
					}
					else
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
			else if (_frames.hasOwnProperty("Default"))
				FrameRect = _frames["Default"];
			return FrameRect;
		}
	}
}