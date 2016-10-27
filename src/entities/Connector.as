package entities
{
	public class Connector extends DigitalComponent
	{
		private var _powered:Boolean = false;
		
		public function Connector()
		{
			
		}
		
		public function get powered():Boolean
		{
			return _powered;
		}
		
		public function connect(ConnectorToConnect:Connector):void
		{
			
		}
		
		public function propagate(Powered:Boolean, Propagator:DigitalComponent):void
		{
			_powered = Powered;
		}
	}
}
