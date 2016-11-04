package circuits
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
		
		public function reset():void
		{
			_powered = false;
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
