package entities
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	public class Wire extends Entity
	{
		private var _input:Wire = null;
		private var _output:Wire = null;
		
		public function Wire(SpriteSheetA:SpriteSheet, TopLeft:Point, InputWire:Wire = null)
		{
			super(SpriteSheetA, TopLeft, "Wire", 1, 1);
			
			_input = InputWire;
			refresh();
		}
		
		public function refresh():void
		{
			var X:int = position.x;
			var Y:int = position.y;
			var PreviousX:int = -1;
			var PreviousY:int = -1;
			var NextX:int = -1;
			var NextY:int = -1;
			
			if (_input)
			{
				PreviousX = _input.position.x;
				PreviousY = _input.position.y;
			}
			if (_output)
			{
				NextX = _output.position.x;
				NextY = _output.position.y;
			}
			
			var FrameKey:String = "Wire";
			if (_input && _output)
			{
				if ((NextX == PreviousX) && (NextX == PreviousX))
					FrameKey += " - Vertical";
				else if ((NextY == PreviousY) && (NextY == PreviousY))
					FrameKey += " - Horizontal";
				else
				{
					// Is north cell attached?
					if (((NextX == X) && (NextY < Y)) ||
						((PreviousX == X) && (PreviousY < Y)))
					{
						// Is west cell attached?
						if (((NextX < X) && (NextY == Y)) ||
							((PreviousX < X) && (PreviousY == Y)))
							FrameKey += " - J Bend";
						else
							FrameKey += " - L Bend";
					}
					else
					{
						// Is west cell attached?
						if (((NextX < X) && (NextY == Y)) ||
							((PreviousX < X) && (PreviousY == Y)))
							FrameKey += " - 7 Bend";
						else
							FrameKey += " - r Bend";
					}
				}
			}
			else if (_input)
			{
				if (PreviousX == X)
					FrameKey += " - Vertical";
				else if (PreviousY == Y)
					FrameKey += " - Horizontal";
			}
			else if (_output)
			{
				if (NextX == X)
					FrameKey += " - Vertical";
				else if (NextY == Y)
					FrameKey += " - Horizontal";
			}
			setFrameKey(FrameKey);
		}
		
		public function setInput(InputWire:Wire):void
		{
			_input = InputWire;
			refresh();
		}
		
		public function setOutput(OutputWire:Wire):void
		{
			_output = OutputWire;
			refresh();
		}
	}
}
