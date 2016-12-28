package entities
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Frame
	{
		private var _frameKey:String;
		private var _offset:Point;
		private var _visibleValues:Array;
		
		public function Frame(FrameKey:String, OffsetX:Number, OffsetY:Number, VisibleValues:Array)
		{
			_frameKey = FrameKey;
			_offset = new Point(OffsetX, OffsetY);
			_visibleValues = VisibleValues.concat();
		}
		
		public static function convertObjectToFrame(ObjectToConvert:Object):Frame
		{
			var FrameKey:String = "Default";
			var OffsetX:uint = 0;
			var OffsetY:uint = 0;
			var VisibleValues:Array = null;
			if (ObjectToConvert.hasOwnProperty("frameKey"))
				FrameKey = ObjectToConvert["frameKey"];
			if (ObjectToConvert.hasOwnProperty("xOffset"))
				OffsetX = ObjectToConvert["xOffset"];
			if (ObjectToConvert.hasOwnProperty("yOffset"))
				OffsetY = ObjectToConvert["yOffset"];
			if (ObjectToConvert.hasOwnProperty("visibleValues"))
				VisibleValues = ObjectToConvert["visibleValues"];
			var NewFrame:Frame = new Frame(FrameKey, OffsetX, OffsetY, VisibleValues);
			
			return NewFrame;
		}
		
		public function get frameKey():String
		{
			return _frameKey;
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
