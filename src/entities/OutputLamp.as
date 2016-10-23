package entities
{
	import flash.geom.Point;

	public class OutputLamp extends DigitalComponent
	{
		public function OutputLamp(SpriteSheetA:SpriteSheet, TopLeft:Point, Input:DigitalComponent = null)
		{
			super(SpriteSheetA, TopLeft, 2, 2);
			
			if (Input)
				setInput(Input);
			
			refresh();
		}
		
		override public function clone():DigitalComponent
		{
			var Clone:OutputLamp = new OutputLamp(spriteSheet, position);
			return Clone;
		}
		
		override public function refresh():void
		{
			var FrameKey:String = "Lamp - " + ((powered) ? "On" : "Off");
			setFrameKey(FrameKey);
		}
		
		override public function pulse():void
		{
			if (input)
				setPowered(input.powered);
			else
				setPowered(false);
			
			super.pulse();
		}
	}
}
