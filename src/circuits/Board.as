package circuits
{
	import truthTables.TruthTable;
	
	public class Board
	{
		private var _components:Vector.<DigitalComponent>;
		private var _devices:Vector.<Device>;
		
		public function Board()
		{
			_components = new Vector.<DigitalComponent>();
			_devices = new Vector.<Device>();
		}
		
		/**
		 * Updates the state of all components on the board.
		 */
		public function tick():void
		{
			for each (var CurrentComponent:DigitalComponent in _components)
			{
				if (CurrentComponent is Connector)
					(CurrentComponent as Connector).reset();
			}
			for each (var CurrentDevice:Device in _devices)
			{
				if (!CurrentDevice.input)
					CurrentDevice.pulse();
			}
		}
		
		/**
		 * Adds a new wire to the Board.
		 */
		public function addWire(Input:Connector = null, Output:Connector = null):Wire
		{
			var NewWire:Wire = new Wire(Input);
			if (Output)
				NewWire.connect(Output);
			_components.push(NewWire);
			
			return NewWire;
		}
		
		/**
		 * Adds a new device to the Board with the properties of a constant.
		 * Since constants have no inputs, and one output, a Node is also added to the Board connected 
		 * to the output of the constant.
		 */
		public function addConstant(Powered:Boolean):Device
		{
			var NewConstant:Device = new Device(Powered);
			var NodeOut:Node = NewConstant.addOutput("out");
			_components.push(NewConstant);
			_devices.push(NewConstant);
			_components.push(NodeOut);
			
			return NewConstant;
		}
		
		/**
		 * Adds a new device to the Board with the properties of a lamp.
		 * Since lamps have one input, and no output, a Node is also added to the Board connected to the
		 * input of the lamp.
		 */
		public function addLamp():Device
		{
			var NewLamp:Device = new Device(false);
			var NodeIn:Node = NewLamp.addInput("a");
			_components.push(NewLamp);
			_devices.push(NewLamp);
			_components.push(NodeIn);
			
			return NewLamp;
		}
		
		/**
		 * Adds a new device to the Board with the properties of a logic gate.
		 * Gates have at least one input, and at least one output, so two or more Nodes are also added to the 
		 * Board connected to the inputs and outputs of the gate, based on its type.
		 */
		public function addGate(GateType:String = "NOT"):Device
		{
			var NewGate:Device = new Device(true);
			var NodeIn:Node = NewGate.addInput("a");
			var NodeOut:Node = NewGate.addOutput("out");
			_components.push(NewGate);
			_devices.push(NewGate);
			_components.push(NodeIn);
			_components.push(NodeOut);
			if (GateType == "AND")
			{
				var TruthTableA:TruthTable = new TruthTable(GateType, new <String>["a", "b"], new <String>["out"], false);
				TruthTableA.setOutputs({a:true, b:true}, {out:true});
				NewGate.setTruthTable(TruthTableA);
				
				var NodeIn2:Node = NewGate.addInput("b");
				_components.push(NodeIn2);
			}
			else if (GateType == "OR")
			{
				TruthTableA = new TruthTable(GateType, new <String>["a", "b"], new <String>["out"], true);
				TruthTableA.setOutputs({a:false, b:false}, {out:false});
				NewGate.setTruthTable(TruthTableA);
				
				NodeIn2 = NewGate.addInput("b");
				_components.push(NodeIn2);
			}
			else if (GateType == "XOR")
			{
				TruthTableA = new TruthTable(GateType, new <String>["a", "b"], new <String>["out"], true);
				TruthTableA.setOutputs({a:false, b:false}, {out:false});
				TruthTableA.setOutputs({a:true, b:true}, {out:false});
				NewGate.setTruthTable(TruthTableA);
				
				NodeIn2 = NewGate.addInput("b");
				_components.push(NodeIn2);
			}
			else if (GateType == "NOT")
			{
				TruthTableA = new TruthTable(GateType, new <String>["a"], new <String>["out"], false);
				TruthTableA.setOutputs({a:false}, {out:true});
				NewGate.setTruthTable(TruthTableA);
			}
			
			return NewGate;
		}
	}
}
