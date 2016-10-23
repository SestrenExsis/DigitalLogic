package entities
{
	import flash.geom.Point;
	
	public class DigitalComponent extends Entity
	{
		private var _powered:Boolean = false;
		private var _input:DigitalComponent;
		private var _output:DigitalComponent;
		
		public function DigitalComponent(SpriteSheetA:SpriteSheet, TopLeft:Point)
		{
			var FrameKey:String = "Constant - Off";
			super(SpriteSheetA, TopLeft, FrameKey, 1, 1);
		}
		
		public function clone():DigitalComponent
		{
			var Clone:DigitalComponent = new DigitalComponent(spriteSheet, position);
			Clone.setPowered(powered);
			return Clone;
		}
		
		public function get powered():Boolean
		{
			return _powered;
		}
		
		public function setPowered(Powered:Boolean):void
		{
			var OriginalPower:Boolean = _powered;
			_powered = Powered;
			if (_powered != OriginalPower)
				refresh();
		}
		
		public function get input():DigitalComponent
		{
			return _input;
		}
		
		public function setInput(Input:DigitalComponent):void
		{
			if ((_input === Input) || (Input === _output))
				return;
			
			if (_input)
			{
				_input._output = null;
				_input.refresh();
			}
			_input = Input;
			if (_input)
				_input.setOutput(this);
			refresh();
		}
		
		public function get output():DigitalComponent
		{
			return _output;
		}
		
		public function setOutput(Output:DigitalComponent):void
		{
			if ((_output === Output) || (Output === _input))
				return;
			
			if (_output)
			{
				_output._input = null;
				_output.refresh();
			}
			_output = Output;
			if (_output)
				_output.setInput(this);
			refresh();
		}
		
		public function pulse():void
		{
			if (output)
			{
				output.setPowered(powered);
				output.pulse();
			}
		}
		
		public function refresh():void
		{
			var FrameKey:String = "Constant - " + ((powered) ? "On" : "Off");
			setFrameKey(FrameKey);
		}
	}
}
