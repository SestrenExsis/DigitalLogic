package circuits
{
	import truthTables.TruthTable;

	/**
	 * The basic component that functions as constants, gates, display outputs, etc.
	 */
	public class Device extends DigitalComponent
	{
		private var _inputs:Object;
		private var _outputs:Object;
		private var _search:Object;
		private var _input:Node;
		private var _input2:Node;
		private var _output:Node;
		private var _output2:Node;
		private var _output3:Node;
		private var _invertOutput:Boolean = false;
		private var _truthTable:TruthTable;
		
		public function Device(Type:String, InvertOutput:Boolean)
		{
			_type = Type;
			_invertOutput = InvertOutput;
			_inputs = new Object();
			_outputs = new Object();
			_search = new Object();
		}
		
		public function pulse(Propogator:DigitalComponent = null):void
		{
			// Do not accept pulse requests from the output node.
			if (Propogator && (Propogator === _output))
				return;
			
			var Powered:Boolean;
			if (_input && _output)
			{
				for (var InputKey:Object in _inputs)
				{
					if (_search.hasOwnProperty(InputKey))
						_search[InputKey] = (_inputs[InputKey] as Node).powered;
				}
				var Outputs:Object = _truthTable.getOutputs(_search);
				for (var OutputKey:Object in Outputs)
				{
					if (_outputs.hasOwnProperty(OutputKey))
						(_outputs[OutputKey] as Node).propagate(Outputs[OutputKey], this);
				}
			}
			else if (_input)
				Powered = _input.powered;
			else
				Powered = _invertOutput;
			
			if (_output && !_input)
				_output.propagate(Powered, this);
		}
		
		public function setTruthTable(TruthTableToSet:TruthTable):void
		{
			_truthTable = TruthTableToSet;
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
		
		public function get output2():Node
		{
			return _output2;
		}
		
		public function get output3():Node
		{
			return _output3;
		}
		
		public function get invertOutput():Boolean
		{
			return _invertOutput;
		}
		
		public function toggle():void
		{
			_invertOutput = !_invertOutput;
		}
		
		public function addInput(Name:String):Node
		{
			if (_inputs.hasOwnProperty(Name))
				throw new Error("Device already has an input with name: " + Name);
			if (_input && _input2)
				return null;
			
			var Input:Node = new Node(this);
			if (_input)
				_input2 = Input;
			else
				_input = Input;
			_inputs[Name] = Input;
			_search[Name] = false;
			
			return _input;
		}
		
		public function addOutput(Name:String):Node
		{
			if (_outputs.hasOwnProperty(Name))
				throw new Error("Device already has an output with name: " + Name);
			if (_output && _output2 && _output3)
				return null;
			
			var Output:Node = new Node(this);
			if (_output && _output2)
				_output3 = Output;
			else if (_output)
				_output2 = Output;
			else
				_output = Output;
			_outputs[Name] = Output;
			
			return _output;
		}
	}
}
