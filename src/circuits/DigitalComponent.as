package circuits
{
	public class DigitalComponent
	{
		public static const DEVICE_CONSTANT:String = "Constant";
		public static const DEVICE_GATE_NOT:String = "Gate - NOT";
		public static const DEVICE_GATE_AND:String = "Gate - AND";
		public static const DEVICE_LAMP:String = "Lamp";
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
