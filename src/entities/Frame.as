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
		
		public static function convertObjectToFrame(ObjectToConvert:Object):Frame
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
			var Visibility:Boolean = !(_visibleValues[Index] == 0)
			return Visibility;
		}
	}
}
