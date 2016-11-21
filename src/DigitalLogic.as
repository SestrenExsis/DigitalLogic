package
{
	import entities.Entity;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	[SWF(width="640", height="480", frameRate="60", backgroundColor="#555555")]
	
	public class DigitalLogic extends Sprite
	{
		private static var _spriteSheet:SpriteSheet;
		
		private var _buffer:Bitmap;
		private var _workbench:Workbench;
		
		public function DigitalLogic()
		{
			scaleX = scaleY = 2.0;
			
			var BitmapDataA:BitmapData = new BitmapData(320, 240);
			_buffer = new Bitmap(BitmapDataA, PixelSnapping.ALWAYS);
			addChild(_buffer);
			
			SpriteSheetKey.init();
			_spriteSheet = SpriteSheetKey.getSpriteSheet(SpriteSheetKey.SPRITES);
			
			var BackgroundTile:Entity = new Entity(_spriteSheet);
			BackgroundTile.setFrameKey("Background");
			_workbench = new Workbench(BackgroundTile, 40, 30);
			_workbench.addToolkit(1, 0);
			_workbench.testBasicCircuit(5, 5);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onEnterFrame(e:Event):void
		{
			_workbench.update();
			_buffer.bitmapData.fillRect(_buffer.bitmapData.rect, 0xff000000);
			_workbench.drawOntoBuffer(_buffer.bitmapData);
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			var MouseX:Number = 0.5 * stage.mouseX;
			var MouseY:Number = 0.5 * stage.mouseY;
			_workbench.onTouch(MouseX, MouseY);
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			var MouseX:Number = 0.5 * stage.mouseX;
			var MouseY:Number = 0.5 * stage.mouseY;
			_workbench.onRelease(MouseX, MouseY);
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{
			var MouseX:Number = 0.5 * stage.mouseX;
			var MouseY:Number = 0.5 * stage.mouseY;
			var IsButtonDown:Boolean = e.buttonDown;
			if (IsButtonDown)
				_workbench.onDrag(MouseX, MouseY);
		}
	}
}
