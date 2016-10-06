package
{
	import entities.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	[SWF(width="640", height="480", frameRate="60", backgroundColor="#555555")]
	
	public class DigitalLogic extends Sprite
	{
		private static var _spriteSheet:SpriteSheet;
		private var _buffer:Bitmap;
		private var _entities:Array;
		private var _entity:Entity;
		
		public function DigitalLogic()
		{
			scaleX = scaleY = 2.0;
			
			var BitmapDataA:BitmapData = new BitmapData(320, 240);
			_buffer = new Bitmap(BitmapDataA, PixelSnapping.ALWAYS);
			addChild(_buffer);
			
			SpriteSheetKey.init();
			_spriteSheet = SpriteSheetKey.getSpriteSheet(SpriteSheetKey.SPRITES);
			_entities = new Array();
			var BoundingBox:Rectangle = new Rectangle(0, 0, 16, 16);
			for (var y:uint = 0; y < 15; y++)
			{
				for (var x:uint = 0; x < 20; x++)
				{
					BoundingBox.x = 16 * x;
					BoundingBox.y = 16 * y;
					_entity = new Entity(_spriteSheet, BoundingBox, "Background");
					_entities.push(_entity);
				}
			}
			
			BoundingBox.setTo(8, 8, 8, 8);
			_entity = new Entity(_spriteSheet, BoundingBox, "Node - Off");
			_entities.push(_entity);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void
		{
			_buffer.bitmapData.fillRect(_buffer.bitmapData.rect, 0xff000000);
			
			for (var i:int = 0; i < _entities.length; i++)
			{
				var EntityA:Entity = _entities[i];
				if (EntityA)
					EntityA.drawOntoBuffer(_buffer.bitmapData);
			}
		}
	}
}