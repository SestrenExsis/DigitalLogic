package circuits
{
	import truthTables.TruthTable;
	
	public class Board
	{
		private var _components:Vector.<DigitalComponent>;
		private var _devices:Vector.<Device>;
		
		private var _tickCounter:uint = 0;
		private var _stepCounter:uint = 0;
		private var _devicesInTick:Vector.<Device>;
		
		public function Board()
		{
			_components = new Vector.<DigitalComponent>();
			_devices = new Vector.<Device>();
		}
		
		private function stats():void
		{
			trace("Tick #" + _tickCounter);
			trace("  Components: " + _components.length);
			trace("  Devices:    " + _devicesInTick.length + " of " + _devices.length);
		}
		
		public function newTick():void
		{
			_tickCounter++;
			stats();
			
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
						var Next:DigitalComponent = Current.propagate(Outputs[OutputKey], DeviceToTick);
						while (Next && (Next is Connector))
						{
							var Prev:DigitalComponent = Current;
							Current = (Next as Connector);
							Next = Current.propagate(Outputs[OutputKey], Prev);
						}
						if (Next is Device)
							_devicesInTick.push(Next as Device);
					}
				}
			}
		}
		
		public function prime():void
		{
			trace("---");
			for each (var CurrentDevice:Device in _devices)
			{
				if (CurrentDevice.inputCount == 0)
				{
					var IndexOfDeviceInTick:int = _devicesInTick.indexOf(CurrentDevice);
					if (IndexOfDeviceInTick == -1)
						_devicesInTick.push(CurrentDevice);
				}
			}
			stats();
		}
		
		public function reset():void
		{
			_tickCounter = 0;
			for each (var CurrentComponent:DigitalComponent in _components)
			{
				if (CurrentComponent is Connector)
					(CurrentComponent as Connector).reset();
			}
			_devicesInTick = new Vector.<Device>();
			stats();
		}
		
		/**
		 * Updates the state of all components on the board.
		 */
		public function tick():void
		{
			reset();
			
			for each (var CurrentDevice:Device in _devices)
			{
				if (CurrentDevice.inputCount == 0)
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
	}
}
