package
{
	import entities.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	[SWF(width="640", height="480", frameRate="60", backgroundColor="#555555")]
	
	public class DigitalLogic extends Sprite
	{
		private static var _spriteSheet:SpriteSheet;
		
		private var _buffer:Bitmap;
		private var _workbench:TiledEntity;
		private var _entities:Array;
		
		public function DigitalLogic()
		{
			scaleX = scaleY = 2.0;
			
			var BitmapDataA:BitmapData = new BitmapData(320, 240);
			_buffer = new Bitmap(BitmapDataA, PixelSnapping.ALWAYS);
			addChild(_buffer);
			
			SpriteSheetKey.init();
			_spriteSheet = SpriteSheetKey.getSpriteSheet(SpriteSheetKey.SPRITES);
			
			var TopLeft:Point = new Point(0, 0);
			_workbench = new TiledEntity(_spriteSheet, TopLeft, "Background");
			_entities = new Array();
			
			TopLeft.setTo(8, 8);
			var EntityA:Entity = new Entity(_spriteSheet, TopLeft, "Node - Off");
			_entities.push(EntityA);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		private function onEnterFrame(e:Event):void
		{
			_buffer.bitmapData.fillRect(_buffer.bitmapData.rect, 0xff000000);
			
			_workbench.drawOntoBuffer(_buffer.bitmapData);
			for (var i:int = 0; i < _entities.length; i++)
			{
				var EntityA:Entity = _entities[i];
				if (EntityA)
					EntityA.drawOntoBuffer(_buffer.bitmapData);
			}
		}
		
		private function onMouseClick(e:MouseEvent):void 
		{
			var MouseX:Number = 0.5 * stage.mouseX;
			var MouseY:Number = 0.5 * stage.mouseY;
			var TopLeft:Point = new Point(MouseX, MouseY);
			var EntityA:Entity = new Entity(_spriteSheet, TopLeft, "Node - Off");
			_entities.push(EntityA);
		}
	}
}
