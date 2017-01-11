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
		private var _truthTable:TruthTable;
		private var _previousState:uint = 1;
		private var _currentState:uint = 0;
		
		public function Device(Type:String)
		{
			_type = Type;
			_inputs = new Object();
			_outputs = new Object();
			_search = new Object();
		}
		
		public function get inputs():Object
		{
			return _inputs;
		}
		
		public function get outputs():Object
		{
			return _outputs;
		}
		
		public function pulse(Propagator:DigitalComponent = null):Object
		{
			// Do not accept pulse requests from output nodes.
			if (Propagator)
			{
				for (var OutputKey:Object in _outputs)
				{
					if (Propagator === _outputs[OutputKey])
						return null;
				}
			}
			
			var Powered:Boolean = false;
			if (_truthTable)
			{
				var InputCount:uint = 0;
				for (var InputKey:Object in _inputs)
				{
					InputCount++;
					if (_search.hasOwnProperty(InputKey))
						_search[InputKey] = (_inputs[InputKey] as Node).powered;
				}
				var Outputs:Object = _truthTable.getOutputs(_search, _currentState);
				return Outputs;
				
				for (OutputKey in Outputs)
				{
					if (_outputs.hasOwnProperty(OutputKey))
						(_outputs[OutputKey] as Node).propagate(Outputs[OutputKey], this);
				}
			}
			else
			{
				if (_inputCount == 1)
					throw new Error("If this never throws, delete it."); //Powered = _inputs["x"].powered;
				else
					Powered = false; // _invertOutput;
			}
			
			if (_outputCount > 0 && _inputCount == 0 && !_truthTable)
			{
				throw new Error("If this never throws, delete it.");
				
				for (OutputKey in _outputs)
				{
					(_outputs[OutputKey] as Node).propagate(Powered, this);
				}
			}
			
			return null;
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
		
		public function get currentState():uint
		{
			return _currentState;
		}
		
		public function edgeTriggered():Boolean
		{
			var EdgeTriggered:Boolean = false;
			var InputNodesObj:Object = _inputs;
			for (var InputNodeKey:String in InputNodesObj)
			{
				var InputNode:Node = (InputNodesObj[InputNodeKey] as Node);
				if (InputNode.edge != 0)
					EdgeTriggered = true;
				InputNode.tick();
			}
			if (_previousState != _currentState)
				EdgeTriggered = true;
			_previousState = _currentState;
			
			return EdgeTriggered;
		}
		
		public function nextState():void
		{
			_currentState++;
			
			if (!_truthTable || (_currentState >= _truthTable.stateCount))
				_currentState = 0;
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
