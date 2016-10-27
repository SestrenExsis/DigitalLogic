package entities
{
	/**
	 * The basic component that functions as constants, gates, display outputs, etc.
	 */
	public class Device extends DigitalComponent
	{
		private var _input:Node;
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
			if (_input)
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
			var Input:Node = new Node(this);
			_input = Input;
			
			if (_output)
			{
				if (_invertOutput)
					_type = DEVICE_GATE_NOT;
			}
			else
				_type = DEVICE_LAMP;
			
			return _input;
		}
		
		public function addOutput():Node
		{
			var Output:Node = new Node(this);
			_output = Output;
			
			if (_input)
			{
				if (_invertOutput)
					_type = DEVICE_GATE_NOT;
			}
			else
				_type = DEVICE_CONSTANT;
			
			return _output;
		}
	}
}
