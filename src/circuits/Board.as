package circuits
{
	import truthTables.TruthTable;
	
	public class Board extends DigitalComponent
	{
		private var _components:Vector.<DigitalComponent>;
		private var _devices:Vector.<Device>;
		private var _devicesInTick:Vector.<Device>;
		
		private var _parent:Board;
		private var _children:Vector.<Board>;
		private var _inputs:Object;
		private var _outputs:Object;
		
		public function Board(Parent:Board = null)
		{
			_type = DigitalComponent.BOARD;
			_parent = Parent;
			_components = new Vector.<DigitalComponent>();
			_devices = new Vector.<Device>();
			_devicesInTick = new Vector.<Device>();
			
			_children = new Vector.<Board>();
			_inputs = new Object();
			_outputs = new Object();
		}
		
		public function getInput(InputName:String):Node
		{
			if (_inputs.hasOwnProperty(InputName))
				return _inputs[InputName];
			else
				return null;
		}
		
		public function exposeInput(InputName:String, InputNode:Node):void
		{
			if (_inputs.hasOwnProperty(InputName))
				throw new Error("Board already has an input with name: " + InputName);
			
			_inputs[InputName] = InputNode;
		}
		
		public function getOutput(OutputName:String):Node
		{
			if (_outputs.hasOwnProperty(OutputName))
				return _outputs[OutputName];
			else
				return null;
		}
		
		public function exposeOutput(OutputName:String, OutputNode:Node):void
		{
			if (_outputs.hasOwnProperty(OutputName))
				throw new Error("Board already has an output with name: " + OutputName);
			
			_outputs[OutputName] = OutputNode;
		}
		
		public function reset():void
		{
			for each (var CurrentComponent:DigitalComponent in _components)
			{
				if (CurrentComponent is Connector)
					(CurrentComponent as Connector).reset();
			}
			while (_devicesInTick.length > 0)
				_devicesInTick.pop();
		}
		
		public function prime():void
		{
			for each (var CurrentDevice:Device in _devices)
			{
				var EdgeTriggered:Boolean = CurrentDevice.edgeTriggered();
				if (EdgeTriggered)
					_devicesInTick.push(CurrentDevice);
			}
		}
		
		private function propagate(Current:Connector, Next:DigitalComponent, Power:Boolean):void
		{
			while (Next && (Next is Connector))
			{
				var Prev:DigitalComponent = Current;
				var Current:Connector = (Next as Connector);
				Next = Current.propagate(Power, Prev);
			}
			if (Next is Device)
			{
				var NextDevice:Device = (Next as Device);
				var IndexOfDeviceInTick:int = _devicesInTick.indexOf(NextDevice);
				if (IndexOfDeviceInTick == -1)
					_devicesInTick.push(NextDevice);
			}
		}
		
		public function tick():void
		{
			var DeviceCount:uint = _devicesInTick.length;
			for (var j:uint = 0; j < DeviceCount; j++)
			{
				var DeviceToTick:Device = _devicesInTick.shift();
				var Outputs:Object = DeviceToTick.pulse();
				for (var OutputKey:String in Outputs)
				{
					var OutputNode:Node = DeviceToTick.getOutput(OutputKey);
					if (OutputNode)
					{
						var Current:Connector = OutputNode;
						var OutputPower:Boolean = Outputs[OutputKey];
						var Next:DigitalComponent = Current.propagate(OutputPower, DeviceToTick);
						propagate(Current, Next, OutputPower);
					}
				}
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
		 * Adds a new device to the Board based on a truth table.
		 * The number of Nodes that are also created is based on the inputs and outputs in the truth table.
		 */
		public function addDevice(TruthTableA:TruthTable):Device
		{
			var NewDevice:Device = new Device(DigitalComponent.DEVICE);
			for each (var InputName:String in TruthTableA.inputNames)
			{
				var NodeIn:Node = NewDevice.addInput(InputName);
				_components.push(NodeIn);
			}
			
			for each (var OutputName:String in TruthTableA.outputNames)
			{
				var NodeOut:Node = NewDevice.addOutput(OutputName);
				_components.push(NodeOut);
			}
			_components.push(NewDevice);
			_devices.push(NewDevice);
			NewDevice.setTruthTable(TruthTableA);
			
			return NewDevice;
		}
		
		public function addBoard():Board
		{
			var NewBoard:Board = new Board(this);
			_children.push(NewBoard);
			
			return NewBoard;
		}
		
		public function deleteComponent(ComponentToDelete:DigitalComponent):void
		{
			var IndexOfComponent:int = _components.indexOf(ComponentToDelete);
			if (IndexOfComponent == -1)
				throw new Error("Component to delete not found on Board.");
			
			_components.splice(IndexOfComponent, 1);
			if (ComponentToDelete is Device)
			{
				var DeviceToDelete:Device = (ComponentToDelete as Device);
				var IndexOfDevice:int = _devices.indexOf(DeviceToDelete);
				if (IndexOfDevice == -1)
					throw new Error("Component deleted, but Device to delete not found on Board.");
				
				_devices.splice(IndexOfDevice, 1);
				for (var InputKey:String in DeviceToDelete.inputs)
				{
					var InputNode:Node = DeviceToDelete.inputs[InputKey];
					deleteComponent(InputNode);
				}
				for (var OutputKey:String in DeviceToDelete.outputs)
				{
					var OutputNode:Node = DeviceToDelete.outputs[OutputKey];
					deleteComponent(OutputNode);
				}
			}
			else if (ComponentToDelete is Node)
			{
				var NodeToDelete:Node = (ComponentToDelete as Node);
				if (NodeToDelete.wire)
				{
					NodeToDelete.disconnect(NodeToDelete.wire);
					propagate(NodeToDelete, NodeToDelete.wire, false);
				}
			}
			else if (ComponentToDelete is Wire)
			{
				var WireToDelete:Wire = (ComponentToDelete as Wire);
				if (WireToDelete.a)
				{
					WireToDelete.disconnect(WireToDelete.a);
					propagate(WireToDelete, WireToDelete.a, false);
				}
				if (WireToDelete.b)
				{
					WireToDelete.disconnect(WireToDelete.b);
					propagate(WireToDelete, WireToDelete.b, false);
				}
			}
		}
		
		public function addTestBoard():Board
		{
			// Add NOT Gate - NAND Logic
			var BoardA:Board = addBoard();
			
			// Create truth tables
			var NANDStr:String = "NAND Gate";
			var NANDObj:Object = GameData.getEntityObject(NANDStr);
			var NANDTab:TruthTable = TruthTable.convertObjectToTruthTable(NANDStr, NANDObj);
			
			var SplitterStr:String = "Splitter";
			var SplitterObj:Object = GameData.getEntityObject(SplitterStr);
			var SplitterTab:TruthTable = TruthTable.convertObjectToTruthTable(SplitterStr, SplitterObj);
			
			var Nand3GateA:Device = BoardA.addDevice(NANDTab);
			_devices.push(Nand3GateA);
			var SplitterA:Device = BoardA.addDevice(SplitterTab);
			_devices.push(SplitterA);
			
			var GateNodeX:Node = Nand3GateA.getInput("x");
			var GateNodeY:Node = Nand3GateA.getInput("y");
			var GateNodeA:Node = Nand3GateA.getOutput("a");
			
			var SplitterNodeX:Node = SplitterA.getInput("x");
			var SplitterNodeB:Node = SplitterA.getOutput("b");
			var SplitterNodeC:Node = SplitterA.getOutput("c");
			
			BoardA.addWire(SplitterNodeB, GateNodeX);
			BoardA.addWire(SplitterNodeC, GateNodeY);
			BoardA.exposeInput("x", SplitterNodeX);
			BoardA.exposeOutput("a", GateNodeA);
			
			return BoardA;
		}
	}
}
