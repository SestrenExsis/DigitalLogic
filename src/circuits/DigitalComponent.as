package circuits
{
	public class DigitalComponent
	{
		public static const BOARD:String = "Board";
		public static const DEVICE:String = "Device";
		public static const CONNECTOR_WIRE:String = "Wire";
		public static const CONNECTOR_NODE:String = "Node";
		
		private static var _currentComponentID:uint = 0;
		
		protected var _componentID:uint;
		protected var _type:String = "Default";
		
		public function DigitalComponent()
		{
			_componentID = _currentComponentID;
			_currentComponentID++;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get componentID():uint
		{
			return _componentID;
		}
	}
}
