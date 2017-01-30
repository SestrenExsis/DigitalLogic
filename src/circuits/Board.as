package circuits
{
	import truthTables.TruthTable;
	
	public class Board
	{
		private var _components:Vector.<DigitalComponent>;
		private var _devices:Vector.<Device>;
		private var _devicesInTick:Vector.<Device>;
		
		public function Board()
		{
			_components = new Vector.<DigitalComponent>();
			_devices = new Vector.<Device>();
			_devicesInTick = new Vector.<Device>();
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
