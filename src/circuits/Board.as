package circuits
{
	import truthTables.TruthTable;
	import interfaces.IComponentGroup;
	
	public class Board extends DigitalComponent implements IComponentGroup
	{
		private var _components:Vector.<DigitalComponent>;
		private var _devices:Vector.<IComponentGroup>;
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
			_devices = new Vector.<IComponentGroup>();
			_devicesInTick = new Vector.<Device>();
			
			_children = new Vector.<Board>();
			_inputs = new Object();
			_outputs = new Object();
		}
		
		public function convertObjectToBoard(ObjectToConvert:Object):Board
		{
			if (!ObjectToConvert.hasOwnProperty("devices") || 
				!ObjectToConvert.hasOwnProperty("connections"))
				return null;
				
			var NewBoard:Board = addBoard();
			var Devices:Array = ObjectToConvert.devices;
			for (var i:uint = 0; i < Devices.length; i++)
			{
				var ChildEntityKey:String = Devices[i];
				var ChildEntityObject:Object = GameData.getEntityObject(ChildEntityKey);
				if (ChildEntityObject.hasOwnProperty("devices") && 
					ChildEntityObject.hasOwnProperty("connections"))
				{
					var ChildBoard:Board = convertObjectToBoard(ChildEntityObject);
					NewBoard.addBoard(ChildBoard);
				}
				else
				{
					var DeviceTable:TruthTable = TruthTable.convertObjectToTruthTable(ChildEntityKey, ChildEntityObject);
					NewBoard.addDevice(DeviceTable);
				}
			}
			
			var Connections:Array = ObjectToConvert.connections;
			for (var j:uint = 0; j < Connections.length; j++)
			{
				var Connection:Object = Connections[j];
				if (Connection.hasOwnProperty("left_device_index") &&
					Connection.hasOwnProperty("left_node") &&
					Connection.hasOwnProperty("right_device_index") &&
					Connection.hasOwnProperty("right_node"))
				{
					var LeftNode:Node;
					var RightNode:Node;
					if (Connection.left_device_index == -1)
					{
						var RightDevice:IComponentGroup = NewBoard.getDeviceByIndex(Connection.right_device_index);
						RightNode = RightDevice.getInput(Connection.right_node);
						if (!RightNode)
							RightNode = RightDevice.getOutput(Connection.right_node);
						
						if (ObjectToConvert.inputs.hasOwnProperty(Connection.left_node))
							NewBoard.exposeInput(Connection.left_node, RightNode);
						else
							NewBoard.exposeOutput(Connection.left_node, RightNode);
					}
					else if (Connection.right_device_index == -1)
					{
						var LeftDevice:IComponentGroup = NewBoard.getDeviceByIndex(Connection.left_device_index);
						LeftNode = LeftDevice.getInput(Connection.left_node);
						if (!LeftNode)
							LeftNode = LeftDevice.getOutput(Connection.left_node);
						
						RightNode = NewBoard.getInput(Connection.right_node);
						if (ObjectToConvert.inputs.hasOwnProperty(Connection.right_node))
							NewBoard.exposeInput(Connection.right_node, LeftNode);
						else
							NewBoard.exposeOutput(Connection.right_node, LeftNode);
					}
					else
					{
						LeftDevice = NewBoard.getDeviceByIndex(Connection.left_device_index);
						LeftNode = LeftDevice.getInput(Connection.left_node);
						if (!LeftNode)
							LeftNode = LeftDevice.getOutput(Connection.left_node);
						
						RightDevice = NewBoard.getDeviceByIndex(Connection.right_device_index);
						RightNode = RightDevice.getInput(Connection.right_node);
						if (!RightNode)
							RightNode = RightDevice.getOutput(Connection.right_node);
						NewBoard.addWire(LeftNode, RightNode);
					}
				}
			}
			
			return NewBoard;
		}
		
		public function getDeviceByIndex(Index:uint):IComponentGroup
		{
			return _devices[Index];
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
			for each (var CurrentGroup:IComponentGroup in _devices)
			{
				if (CurrentGroup is Device)
				{
					var CurrentDevice:Device = (CurrentGroup as Device);
					var EdgeTriggered:Boolean = CurrentDevice.edgeTriggered();
					if (EdgeTriggered)
						_devicesInTick.push(CurrentDevice);
				}
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
		
		public function addBoard(BoardToAdd:Board = null):Board
		{
			var NewBoard:Board;
			if (BoardToAdd)
				NewBoard = BoardToAdd;
			else
				NewBoard = new Board(this);
			
			_components.push(NewBoard);
			_devices.push(NewBoard);
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
	}
}
