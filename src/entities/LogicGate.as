package entities
{
	import flash.geom.Point;

	public class LogicGate extends DigitalComponent
	{
		public function LogicGate(SpriteSheetA:SpriteSheet, TopLeft:Point, Input:DigitalComponent = null)
		{
			super(SpriteSheetA, TopLeft);
			
			if (Input)
				setInput(Input);
			
			refresh();
		}
		
		override public function clone():DigitalComponent
		{
			var Clone:LogicGate = new LogicGate(spriteSheet, position);
			return Clone;
		}
		
		override public function refresh():void
		{
			var FrameKey:String = "Gate - NOT";
			setFrameKey(FrameKey);
		}
		
		override public function pulse():void
		{
			if (input)
				setPowered(!input.powered);
			else
				setPowered(false);
			
			super.pulse();
		}
	}
}
