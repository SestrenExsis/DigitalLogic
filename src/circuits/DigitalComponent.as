package circuits
{
	public class DigitalComponent
	{
		public static const BOARD:String = "Board";
		public static const DEVICE:String = "Device";
		public static const CONNECTOR_WIRE:String = "Wire";
		public static const CONNECTOR_NODE:String = "Node";
		
		protected var _type:String = "Default";
		
		public function DigitalComponent()
		{
			
		}
		
		public function get type():String
		{
			return _type;
		}
	}
}
