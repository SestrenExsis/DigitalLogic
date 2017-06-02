package circuits
{
	/**
	 * A type of connector that sits between a Wire and a Device, controlling the flow of inputs and outputs.
	 */
	public class Node extends Connector
	{
		private var _wire:Wire;
		private var _device:Device;
		private var _name:String;
		
		public var weight:uint = 1;
		
		public function Node(AttachedDevice:Device, Name:String)
		{
			_type = CONNECTOR_NODE;
			_device = AttachedDevice;
			_name = Name;
		}
		
		public function get wire():Wire
		{
			return _wire;
		}
		
		public function get device():Device
		{
			return _device;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		override public function get open():Boolean
		{
			var Open:Boolean = true;
			if (_wire)
				Open = false;
			
			return Open;
		}
		
		override public function connect(ConnectorToConnect:Connector):void
		{
			if (ConnectorToConnect === _wire)
				return;
			
			if (ConnectorToConnect is Wire)
				_wire = (ConnectorToConnect as Wire);
			
			ConnectorToConnect.connect(this);
		}
		
		override public function disconnect(ConnectorToDisconnect:Connector):void
		{
			var Reflexive:Boolean = false;
			if (ConnectorToDisconnect === _wire)
			{
				Reflexive = true;
				_wire = null;
			}
			
			if (Reflexive)
				ConnectorToDisconnect.disconnect(this);
		}
		
		override public function propagate(Powered:Boolean, Propagator:DigitalComponent):DigitalComponent
		{
			super.propagate(Powered, Propagator);
			
			if (Propagator is Device)
				return _wire;
			else if (Propagator is Wire)
				return _device;
			else
				return null;
		}
	}
}
