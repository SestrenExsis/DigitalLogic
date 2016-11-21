package circuits
{
	/**
	 * The basic component that functions as constants, gates, display outputs, etc.
	 */
	public class Device extends DigitalComponent
	{
		private var _input:Node;
		private var _input2:Node;
		private var _output:Node;
		private var _invertOutput:Boolean = false;
		
		public function Device(InvertOutput:Boolean)
		{
			_invertOutput = InvertOutput;
		}
		
		public function pulse(Propogator:DigitalComponent = null):void
		{
			// Do not accept pulse requests from the output node.
			if (Propogator && (Propogator === _output))
				return;
			
			var Powered:Boolean;
			if (_input && _input2)
				Powered = _input.powered && _input2.powered;
			else if (_input)
				Powered = ((_invertOutput) ? !_input.powered : _input.powered);
			else
				Powered = _invertOutput;
			
			if (_output)
				_output.propagate(Powered, this);
		}
		
		public function get input():Node
		{
			return _input;
		}
		
		public function get input2():Node
		{
			return _input2;
		}
		
		public function get output():Node
		{
			return _output;
		}
		
		public function get invertOutput():Boolean
		{
			return _invertOutput;
		}
		
		public function addInput():Node
		{
			if (_input && _input2)
				return null;
			
			var Input:Node = new Node(this);
			if (_input)
				_input2 = Input;
			else
				_input = Input;
			updateType();
			
			return _input;
		}
		
		public function addOutput():Node
		{
			if (_output)
				return null;
			
			var Output:Node = new Node(this);
			_output = Output;
			updateType();
			
			return _output;
		}
		
		private function updateType():void
		{
			if (_input && _input2 && _output)
				_type = DEVICE_GATE_AND;
			else if (_input && _output && _invertOutput)
				_type = DEVICE_GATE_NOT;
			else if (_input)
				_type = DEVICE_LAMP;
			else if (_output)
				_type = DEVICE_CONSTANT;
		}
	}
}
