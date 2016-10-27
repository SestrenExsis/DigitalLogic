package entities
{
	import circuits.Device;
	import circuits.DigitalComponent;
	import circuits.Node;
	import circuits.Wire;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import interfaces.IGameEntity;
	
	public class Entity implements IGameEntity
	{
		private var _spriteSheet:SpriteSheet;
		private var _topLeft:Point;
		private var _currentFrameKey:String;
		private var _widthInTiles:uint;
		private var _heightInTiles:uint;
		private var _drawRepeatX:uint = 1;
		private var _drawRepeatY:uint = 1;
		private var _component:DigitalComponent;
		
		public function Entity(SpriteSheetA:SpriteSheet, X:Number, Y:Number, Component:DigitalComponent = null)
		{
			_spriteSheet = SpriteSheetA;
			_topLeft = new Point(X, Y);
			_component = Component;
			
			var FrameKey:String = "Background";
			var WidthInTiles:uint = 2;
			var HeightInTiles:uint = 2;
			
			if (_component)
			{
				FrameKey = _component.type;
				if (FrameKey == DigitalComponent.DEVICE_LAMP)
				{
					WidthInTiles = 2;
					HeightInTiles = 2;
				}
				else
				{
					WidthInTiles = 1;
					HeightInTiles = 1;
				}
			}
			
			_currentFrameKey = FrameKey;
			_widthInTiles = WidthInTiles;
			_heightInTiles = HeightInTiles;
		}
		
		public function get spriteSheet():SpriteSheet
		{
			return _spriteSheet;
		}
		
		/**
		 * Gets the top-left corner of the Entity.
		 */
		public function get position():Point
		{
			return _topLeft;
		}
		
		/**
		 * Sets the top-left corner of the Entity.
		 */
		public function setPosition(X:Number, Y:Number):void
		{
			_topLeft.x = X;
			_topLeft.y = Y;
		}
		
		protected function setFrameKey(FrameKey:String):void
		{
			_currentFrameKey = FrameKey;
		}
		
		public function get widthInTiles():uint
		{
			return _widthInTiles;
		}
		
		public function get heightInTiles():uint
		{
			return _heightInTiles;
		}
		
		public function setDrawRepeat(X:uint, Y:uint):void
		{
			_drawRepeatX = X;
			_drawRepeatY = Y;
		}
		
		/**
		 * A getter function that accesses the frame rectangle through the Entity's sprite sheet.
		 */
		public function get frameRect():Rectangle
		{
			var FrameRect:Rectangle = _spriteSheet.getFrame(_currentFrameKey);
			return FrameRect;
		}
		
		public function update():void
		{
			var FrameKey:String = "Default";
			if (_component)
			{
				FrameKey = _component.type;
				if (_component is Wire)
				{
					var WireA:Wire = (_component as Wire);
					FrameKey += ((WireA.powered) ? " - On" : " - Off");
					
					//TODO : Select the proper Wire connection frame
				}
				else if (_component is Node)
				{
					//TODO : Select the proper Node connection frame
					FrameKey += " - East";
				}
				else if (FrameKey == DigitalComponent.DEVICE_CONSTANT)
				{
					var ConstantA:Device = (_component as Device);
					FrameKey += ((ConstantA.invertOutput) ? " - On" : " - Off");
				}
				else if (FrameKey == DigitalComponent.DEVICE_LAMP)
				{
					var LampA:Device = (_component as Device);
					var Input:Node = LampA.input;
					if (Input)
						FrameKey += ((Input.powered) ? " - On" : " - Off");
					else
						FrameKey += " - Off";
				}
			}
			setFrameKey(FrameKey);
		}
		
		public function drawOntoBuffer(Buffer:BitmapData):void
		{
			var Position:Point = position;
			var InitialX:Number = Position.x;
			var InitialY:Number = Position.y;
			var FrameRect:Rectangle = frameRect;
			var FrameWidth:Number = FrameRect.width;
			var FrameHeight:Number = FrameRect.height;
			for (var y:uint = 0; y < _drawRepeatY; y++)
			{
				for (var x:uint = 0; x < _drawRepeatX; x++)
				{
					var TileX:Number = InitialX + FrameWidth * x;
					var TileY:Number = InitialY + FrameHeight * y;
					setPosition(TileX, TileY);
					Buffer.copyPixels(_spriteSheet.bitmapData, FrameRect, _topLeft, null, null, true);
				}
			}
			setPosition(InitialX, InitialY);
		}
	}
}
