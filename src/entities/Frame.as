package entities
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Frame
	{
		private var _frameKey:String;
		private var _offset:Point;
		private var _layer:uint = 0;
		private var _visibleValues:Array;
		
		public function Frame(FrameKey:String, OffsetX:Number, OffsetY:Number, Layer:uint, VisibleValues:Array)
		{
			_frameKey = FrameKey;
			_offset = new Point(OffsetX, OffsetY);
			_layer = Layer;
			_visibleValues = VisibleValues.concat();
		}
		
		public function clone():Frame
		{
			var NewFrame:Frame = new Frame(_frameKey, _offset.x, _offset.y, _layer, _visibleValues);
			
			return NewFrame;
		}
		
		public static function convertObjectToFrames(ObjectToConvert:Object):Vector.<Frame>
		{
			var BaseFrame:Frame = convertObjectToFrame(ObjectToConvert);
			
			var Kerning:uint = 0;
			if (ObjectToConvert.hasOwnProperty("kerning"))
				Kerning = ObjectToConvert.kerning;
			var LineHeight:uint = 0;
			if (ObjectToConvert.hasOwnProperty("lineHeight"))
				LineHeight = ObjectToConvert.lineHeight;
			
			var Frames:Vector.<Frame> = new Vector.<Frame>();
			
			if (ObjectToConvert.hasOwnProperty("glyphs"))
			{
				var Glyphs:Array = ObjectToConvert["glyphs"];
				for (var i:uint = 0; i < Glyphs.length; i++)
				{
					var GlyphX:uint = 0;
					var GlyphY:uint = 0;
					var GlyphKey:String;
					var NewFrame:Frame;
					if (Glyphs[i] is Array)
					{
						GlyphY = i;
						
						for (var j:uint = 0; j < Glyphs[i].length; j++)
						{
							GlyphX = j;
							GlyphKey = Glyphs[GlyphY][GlyphX];
							NewFrame = BaseFrame.clone();
							NewFrame._frameKey += " - " + GlyphKey;
							NewFrame._offset.x += GlyphX * Kerning;
							NewFrame._offset.y += GlyphY * LineHeight;
							Frames.push(NewFrame);
						}
					}
					else
					{
						GlyphX = i;
						GlyphKey = Glyphs[GlyphX];
						NewFrame = BaseFrame.clone();
						NewFrame._frameKey += " - " + GlyphKey;
						NewFrame._offset.x += GlyphX * Kerning;
						Frames.push(NewFrame);
					}
				}
			}
			else
				Frames.push(BaseFrame);
			
			return Frames;
		}
		
		private static function convertObjectToFrame(ObjectToConvert:Object):Frame
		{
			var FrameKey:String = "Default";
			var OffsetX:uint = 0;
			var OffsetY:uint = 0;
			var Layer:uint = 0;
			var VisibleValues:Array = null;
			if (ObjectToConvert.hasOwnProperty("frameKey"))
				FrameKey = ObjectToConvert["frameKey"];
			if (ObjectToConvert.hasOwnProperty("xOffset"))
				OffsetX = ObjectToConvert["xOffset"];
			if (ObjectToConvert.hasOwnProperty("yOffset"))
				OffsetY = ObjectToConvert["yOffset"];
			if (ObjectToConvert.hasOwnProperty("layer"))
				Layer = ObjectToConvert["layer"];
			if (ObjectToConvert.hasOwnProperty("visibleValues"))
				VisibleValues = ObjectToConvert["visibleValues"];
			var NewFrame:Frame = new Frame(FrameKey, OffsetX, OffsetY, Layer, VisibleValues);
			
			return NewFrame;
		}
		
		public function get frameKey():String
		{
			return _frameKey;
		}
		
		public function get layer():uint
		{
			return _layer;
		}
		
		public function get offset():Point
		{
			return _offset;
		}
		
		public function getVisibilityAtIndex(Index:uint):Boolean
		{
			var ModdedIndex:uint = Index % _visibleValues.length;
			var VisibleValue:uint = _visibleValues[ModdedIndex];
			var Visibility:Boolean = !(VisibleValue == 0)
			return Visibility;
		}
	}
}
