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
		private var _inputCount:uint = 0;
		private var _outputCount:uint = 0;
		private var _search:Object;
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
			// Do not accept pulse requests from output nodes.
			if (Propogator)
			{
				for (var OutputKey:Object in _outputs)
				{
					if (Propogator === _outputs[OutputKey])
						return;
				}
			}
			
			
			
			var Powered:Boolean = false;
			if (_truthTable)
			{
				for (var InputKey:Object in _inputs)
				{
					if (_search.hasOwnProperty(InputKey))
						_search[InputKey] = (_inputs[InputKey] as Node).powered;
				}
				var Outputs:Object = _truthTable.getOutputs(_search);
				for (OutputKey in Outputs)
				{
					if (_outputs.hasOwnProperty(OutputKey))
						(_outputs[OutputKey] as Node).propagate(Outputs[OutputKey], this);
				}
			}
			else
			{
				if (_inputCount == 1)
					Powered = _inputs["a"].powered;
				else
					Powered = _invertOutput;
			}
			
			if (_outputCount > 0 && _inputCount == 0)
			{
				for (OutputKey in _outputs)
				{
					(_outputs[OutputKey] as Node).propagate(Powered, this);
				}
			}
		}
		
		public function get truthTable():TruthTable
		{
			return _truthTable;
		}
		
		public function setTruthTable(TruthTableToSet:TruthTable):void
		{
			_truthTable = TruthTableToSet;
		}
		
		public function getInput(InputKey:String):Node
		{
			if (_inputs.hasOwnProperty(InputKey))
				return _inputs[InputKey];
			else
				return null;
		}
		
		public function getOutput(OutputKey:String):Node
		{
			if (_outputs.hasOwnProperty(OutputKey))
				return _outputs[OutputKey];
			else
				return null;
		}
		
		public function get inputCount():uint
		{
			return _inputCount;
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
			
			var Input:Node = new Node(this);
			_inputCount++;
			_inputs[Name] = Input;
			_search[Name] = false;
			
			return Input;
		}
		
		public function addOutput(Name:String):Node
		{
			if (_outputs.hasOwnProperty(Name))
				throw new Error("Device already has an output with name: " + Name);
			
			var Output:Node = new Node(this);
			_outputCount++;
			_outputs[Name] = Output;
			
			return Output;
		}
	}
}
