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
		 * Adds a new device to the Board based on a truth table.
		 * The number of Nodes that are also created is based on the inputs and outputs in the truth table.
		 */
		public function addDevice(TruthTableA:TruthTable):Device
		{
			var NewDevice:Device = new Device(DigitalComponent.DEVICE, false);
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
