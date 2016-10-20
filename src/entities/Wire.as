package entities
{
	import flash.geom.Point;

	public class Wire extends DigitalComponent
	{
		public function Wire(SpriteSheetA:SpriteSheet, TopLeft:Point, Input:DigitalComponent = null)
		{
			super(SpriteSheetA, TopLeft);
			
			if (Input)
				setInput(Input);
			
			refresh();
		}
		
		override public function clone():DigitalComponent
		{
			var Clone:Wire = new Wire(spriteSheet, position);
			return Clone;
		}
		
		override public function refresh():void
		{
			var X:int = position.x;
			var Y:int = position.y;
			var InputX:int = -1;
			var InputY:int = -1;
			if (input)
			{
				var InputPos:Point = input.position;
				InputX = InputPos.x;
				InputY = InputPos.y;
			}
			var OutputX:int = -1;
			var OutputY:int = -1;
			if (output)
			{
				var OutputPos:Point = output.position;
				OutputX = OutputPos.x;
				OutputY = OutputPos.y;
			}
			
			var FrameKey:String = "Wire - " + ((powered) ? "On" : "Off");
			if (input && output)
			{
				if ((OutputX == InputX) && (OutputX == InputX))
					FrameKey += " - Vertical";
				else if ((OutputY == InputY) && (OutputY == InputY))
					FrameKey += " - Horizontal";
				else
				{
					// Is north cell attached?
					if (((OutputX == X) && (OutputY < Y)) ||
						((InputX == X) && (InputY < Y)))
					{
						// Is west cell attached?
						if (((OutputX < X) && (OutputY == Y)) ||
							((InputX < X) && (InputY == Y)))
							FrameKey += " - J Bend";
						else
							FrameKey += " - L Bend";
					}
					else
					{
						// Is west cell attached?
						if (((OutputX < X) && (OutputY == Y)) ||
							((InputX < X) && (InputY == Y)))
							FrameKey += " - 7 Bend";
						else
							FrameKey += " - r Bend";
					}
				}
			}
			else if (input || output)
			{
				var ConnectorX:int = -1;
				var ConnectorY:int = -1;
				if (input)
				{
					ConnectorX = InputX;
					ConnectorY = InputY;
				}
				else if (output)
				{
					ConnectorX = OutputX;
					ConnectorY = OutputY;
				}
				if (ConnectorX < X)
					FrameKey += " - West";
				else if (ConnectorX > X)
					FrameKey += " - East";
				else if (ConnectorY < Y)
					FrameKey += " - North";
				else if (ConnectorY > Y)
					FrameKey += " - South";
			}
			setFrameKey(FrameKey);
		}
		
		override public function pulse():void
		{
			if (!input)
				setPowered(false);
			
			super.pulse();
		}
	}
}
