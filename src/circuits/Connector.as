package circuits
{
	public class Connector extends DigitalComponent
	{
		private var _powered:Boolean = false;
		private var _previouslyPowered:Boolean = true;
		
		public function Connector()
		{
			
		}
		
		public function get powered():Boolean
		{
			return _powered;
		}
		
		public function get edge():int
		{
			var Edge:int = 0;
			if (_powered && !_previouslyPowered)
				Edge = 1;
			else if (!_powered && _previouslyPowered)
				Edge = -1;
			
			return Edge;
		}
		
		public function get open():Boolean
		{
			return false;
		}
		
		public function reset():void
		{
			_powered = false;
			_previouslyPowered = true;
		}
		
		public function connect(ConnectorToConnect:Connector):void
		{
			
		}
		
		public function disconnect(ConnectorToDisconnect:Connector):void
		{
			
		}
		
		public function tick():void
		{
			_previouslyPowered = _powered;
		}
		
		public function propagate(Powered:Boolean, Propagator:DigitalComponent):DigitalComponent
		{
			_previouslyPowered = _powered;
			_powered = Powered;
			
			return null;
		}
	}
}
