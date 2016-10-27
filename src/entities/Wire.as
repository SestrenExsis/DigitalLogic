package entities
{
	/**
	 * A type of connector that sits between other types of connectors, allowing signals to pass through.
	 */
	public class Wire extends Connector
	{
		private var _a:Connector;
		private var _b:Connector;
		
		public function Wire(Input:Connector = null)
		{
			_type = CONNECTOR_WIRE;
			connect(Input);
		}
		
		override public function connect(ConnectorToConnect:Connector):void
		{
			if (_a === ConnectorToConnect || _b === ConnectorToConnect)
				return;
			
			if (_a)
				_b = ConnectorToConnect;
			else
				_a = ConnectorToConnect;
			
			ConnectorToConnect.connect(this);
		}
		
		override public function propagate(Powered:Boolean, Propagator:DigitalComponent):void
		{
			super.propagate(Powered, Propagator);
			
			if (Propagator === _a)
			{
				if (_b)
					_b.propagate(Powered, this);
			}
			else if (Propagator === _b)
			{
				if (_a)
					_a.propagate(Powered, this);
			}
		}
	}
}
