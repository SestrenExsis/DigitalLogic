package circuits
{
	public class DigitalComponent
	{
		public static const DEVICE_CONSTANT:String = "Constant";
		public static const DEVICE_SWITCH:String = "Switch";
		public static const DEVICE_GATE:String = "Gate";
		public static const DEVICE_GATE_NOT:String = "Gate - NOT";
		public static const DEVICE_GATE_AND:String = "Gate - AND";
		public static const DEVICE_GATE_OR:String = "Gate - OR";
		public static const DEVICE_GATE_XOR:String = "Gate - XOR";
		public static const DEVICE_GATE_COPY:String = "Gate - Copy";
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
