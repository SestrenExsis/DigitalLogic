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
			var NewConstant:Device = new Device(DigitalComponent.DEVICE_CONSTANT, Powered);
			var NodeOut:Node = NewConstant.addOutput("out");
			_components.push(NewConstant);
			_devices.push(NewConstant);
			_components.push(NodeOut);
			
			return NewConstant;
		}
		
		/**
		 * Adds a new device to the Board with the properties of a switch.
		 * Since switches have no inputs, and one output, a Node is also added to the Board connected 
		 * to the output of the switch.
		 */
		public function addSwitch():Device
		{
			var NewSwitch:Device = new Device(DigitalComponent.DEVICE_SWITCH, false);
			var NodeOut:Node = NewSwitch.addOutput("out");
			_components.push(NewSwitch);
			_devices.push(NewSwitch);
			_components.push(NodeOut);
			
			return NewSwitch;
		}
		
		/**
		 * Adds a new device to the Board with the properties of a lamp.
		 * Since lamps have one input, and no output, a Node is also added to the Board connected to the
		 * input of the lamp.
		 */
		public function addLamp():Device
		{
			var NewLamp:Device = new Device(DigitalComponent.DEVICE_LAMP, false);
			var NodeIn:Node = NewLamp.addInput("a");
			_components.push(NewLamp);
			_devices.push(NewLamp);
			_components.push(NodeIn);
			
			return NewLamp;
		}
		
		/**
		 * Adds a new device to the Board with the properties of a splitter.
		 * Splitters have exactly one input, and up to three outputs, so up to four Nodes are also added to the 
		 * Board connected to the inputs and outputs of the splitter.
		 */
		public function addSplitter():Device
		{
			var NewGate:Device = new Device(DigitalComponent.DEVICE_GATE_COPY, true);
			var NodeIn:Node = NewGate.addInput("a");
			var NodeOut:Node = NewGate.addOutput("b");
			var NodeOut2:Node = NewGate.addOutput("c");
			var NodeOut3:Node = NewGate.addOutput("d");
			_components.push(NewGate);
			_devices.push(NewGate);
			_components.push(NodeIn);
			_components.push(NodeOut);
			_components.push(NodeOut2);
			_components.push(NodeOut3);
			var TruthTableA:TruthTable = new TruthTable("Copy", new <String>["a"], new <String>["b", "c", "d"], false);
			TruthTableA.setOutputs({a:true}, {b:true, c:true, d:true});
			NewGate.setTruthTable(TruthTableA);
			
			return NewGate;
		}
		
		/**
		 * Adds a new device to the Board with the properties of a logic gate.
		 * Gates have at least one input, and at least one output, so two or more Nodes are also added to the 
		 * Board connected to the inputs and outputs of the gate, based on its type.
		 */
		public function addGate(GateType:String = "NOT"):Device
		{
			var DeviceType:String = DigitalComponent.DEVICE_GATE + " - " + GateType;
			var NewGate:Device = new Device(DeviceType, true);
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
