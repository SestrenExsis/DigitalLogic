package entities
{
	/**
	 * A type of connector that sits between a Wire and a Device, controlling the flow of inputs and outputs.
	 */
	public class Node extends Connector
	{
		private var _wire:Wire;
		private var _device:Device;
		
		public function Node(AttachedDevice:Device)
		{
			_type = CONNECTOR_NODE;
			_device = AttachedDevice;
		}
		
		override public function connect(ConnectorToConnect:Connector):void
		{
			if (ConnectorToConnect === _wire)
				return;
			
			if (ConnectorToConnect is Wire)
				_wire = (ConnectorToConnect as Wire);
			
			ConnectorToConnect.connect(this);
		}
		
		override public function propagate(Powered:Boolean, Propagator:DigitalComponent):void
		{
			super.propagate(Powered, Propagator);
			
			if (Propagator is Device)
			{
				if (_wire)
					_wire.propagate(powered, this);
			}
			else if (Propagator is Wire)
			{
				if (_device)
					_device.pulse(this);
			}
		}
	}
}
