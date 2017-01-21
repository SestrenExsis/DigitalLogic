package
{
	import entities.Entity;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import overlays.FramerateCounter;
	
	[SWF(width="640", height="480", frameRate="60", backgroundColor="#555555")]
	
	public class DigitalLogic extends Sprite
	{
		private static var _spriteSheet:SpriteSheet;
		
		private var _buffer:Bitmap;
		private var _workbench:Workbench;
		private var _framerateCounter:FramerateCounter;
		
		public function DigitalLogic()
		{
			scaleX = scaleY = 2.0;
			
			var BitmapWidth:int = stage.stageWidth / scaleX;
			var BitmapHeight:int = stage.stageHeight / scaleY;
			var BitmapDataA:BitmapData = new BitmapData(BitmapWidth, BitmapHeight);
			_buffer = new Bitmap(BitmapDataA, PixelSnapping.ALWAYS);
			addChild(_buffer);
			
			GameData.init();
			_spriteSheet = GameData.getSpriteSheet(GameData.SPRITES);
			
			var BackgroundTile:Entity = new Entity(_spriteSheet, null, 2, 2);
			BackgroundTile.setFrameKey("Background");
			_workbench = new Workbench(BackgroundTile, 40, 30);
			_workbench.addToolkit(1, 2);
			//_workbench.testBasicCircuit(10, 5);
			
			_framerateCounter = new FramerateCounter(_spriteSheet);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function getMouseX():Number
		{
			var InverseScaleX:Number = 1 / scaleX;
			var MouseX:Number = InverseScaleX * stage.mouseX;
			
			return MouseX;
		}
		
		private function getMouseY():Number
		{
			var InverseScaleY:Number = 1 / scaleY;
			var MouseY:Number = InverseScaleY * stage.mouseY;
			
			return MouseY;
		}
		
		private function onEnterFrame(e:Event):void
		{
			_workbench.update();
			_buffer.bitmapData.fillRect(_buffer.bitmapData.rect, 0xff000000);
			_workbench.drawOntoBuffer(_buffer.bitmapData);
			
			_framerateCounter.update();
			_framerateCounter.drawOntoBuffer(_buffer.bitmapData);
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			_workbench.onTouch(getMouseX(), getMouseY());
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			_workbench.onRelease(getMouseX(), getMouseY());
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{
			var IsButtonDown:Boolean = e.buttonDown;
			if (IsButtonDown)
				_workbench.onDrag(getMouseX(), getMouseY());
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			_workbench.onKeyDown(e.keyCode);
		}
	}
}
