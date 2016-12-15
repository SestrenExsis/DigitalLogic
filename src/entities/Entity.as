package entities
{
	import circuits.Connector;
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
		private var _drawingLayer:int = 0;
		
		private var _drawRepeatX:uint = 1;
		private var _drawRepeatY:uint = 1;
		private var _neighbors:Vector.<Entity>;
		private var _component:DigitalComponent;
		private var _dirty:Boolean = true;
		
		private var _widthInTiles:uint;
		private var _heightInTiles:uint;
		
		public var gridX:uint = 0;
		public var gridY:uint = 0;
		
		public function Entity(SpriteSheetA:SpriteSheet, Component:DigitalComponent = null)
		{
			_spriteSheet = SpriteSheetA;
			_topLeft = new Point();
			_neighbors = new Vector.<Entity>();
			_component = Component;
			
			var WidthInTiles:uint = 2;
			var HeightInTiles:uint = 2;
			
			if (_component)
			{
				switch (_component.type)
				{
					case DigitalComponent.DEVICE_LAMP:
					case DigitalComponent.DEVICE_GATE_AND:
					case DigitalComponent.DEVICE_GATE_OR:
					case DigitalComponent.DEVICE_GATE_XOR:
					case DigitalComponent.DEVICE_SWITCH:
					case DigitalComponent.DEVICE_HALF_ADDER:
						_drawingLayer = 1;
						WidthInTiles = 2;
						HeightInTiles = 2;
						break;
					default:
						_drawingLayer = ((_component.type == DigitalComponent.CONNECTOR_NODE) ? 3 : 2);
						WidthInTiles = 1;
						HeightInTiles = 1;
						break;
				}
			}
			
			_widthInTiles = WidthInTiles;
			_heightInTiles = HeightInTiles;
		}
		
		public function get spriteSheet():SpriteSheet
		{
			return _spriteSheet;
		}
		
		public function setDirty():void
		{
			_dirty = true;
		}
		
		public function setFrameKey(FrameKey:String):void
		{
			_currentFrameKey = FrameKey;
			_dirty = false;
		}
		
		public function get drawingLayer():int
		{
			return _drawingLayer;
		}
		
		public function get widthInTiles():uint
		{
			return _widthInTiles;
		}
		
		public function get heightInTiles():uint
		{
			return _heightInTiles;
		}
		
		public function get component():DigitalComponent
		{
			return _component;
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
		
		public function addNeighbor(NeighboringEntity:Entity):void
		{
			if (_neighbors.indexOf(NeighboringEntity) == -1)
				_neighbors.push(NeighboringEntity);
			_dirty = true;
		}
		
		protected function getNeighborString():String
		{
			var Left:uint = gridX;
			var Right:uint = Left + widthInTiles - 1;
			var Top:uint = gridY;
			var Bottom:uint = Top + heightInTiles - 1;
			var NeighborString:String = "";
			for each (var Neighbor:Entity in _neighbors)
			{
				var NeighborComponent:DigitalComponent = Neighbor.component;
				if (NeighborComponent is Node)
					NeighborString += Neighbor.getNeighborString();
				
				var NeighborLeft:uint = Neighbor.gridX;
				var NeighborRight:uint = NeighborLeft + Neighbor.widthInTiles - 1;
				var NeighborTop:uint = Neighbor.gridY;
				var NeighborBottom:uint = NeighborTop + Neighbor.heightInTiles - 1;
				
				if (NeighborTop > Bottom)
					NeighborString += "South";
				else if (NeighborBottom < Top)
					NeighborString += "North";
				else if (NeighborLeft > Right)
					NeighborString += "East";
				else if (NeighborRight < Left)
					NeighborString += "West";
			}
			
			switch (NeighborString)
			{
				case "NorthSouth":
				case "SouthNorth":
					NeighborString = "Vertical";
					break;
				case "EastWest":
				case "WestEast":
					NeighborString = "Horizontal";
					break;
				case "NorthEast":
				case "EastNorth":
					NeighborString = "L Bend";
					break;
				case "NorthWest":
				case "WestNorth":
					NeighborString = "J Bend";
					break;
				case "SouthEast":
				case "EastSouth":
					NeighborString = "r Bend";
					break;
				case "SouthWest":
				case "WestSouth":
					NeighborString = "7 Bend";
					break;
			}
			
			return NeighborString;
		}
		
		private function update():void
		{
			var FrameKey:String = "Default";
			if (_component)
			{
				FrameKey = _component.type;
				switch (_component.type)
				{
					case DigitalComponent.CONNECTOR_WIRE:
						var WireA:Wire = (_component as Wire);
						FrameKey += ((WireA.powered) ? " - On" : " - Off");
						var NeighborString:String = getNeighborString();
						if (NeighborString != "")
							FrameKey += " - " + NeighborString;
						break;
					case DigitalComponent.CONNECTOR_NODE:
						NeighborString = getNeighborString();
						if (NeighborString != "")
							FrameKey += " - " + NeighborString;
						break;
					case DigitalComponent.DEVICE_CONSTANT:
					case DigitalComponent.DEVICE_SWITCH:
						var PowerSourceA:Device = (_component as Device);
						FrameKey += ((PowerSourceA.invertOutput) ? " - On" : " - Off");
						break;
					case DigitalComponent.DEVICE_GATE_COPY:
					case DigitalComponent.DEVICE_LAMP:
						var LampA:Device = (_component as Device);
						var Input:Node = LampA.getInput("a");
						if (Input)
							FrameKey += ((Input.powered) ? " - On" : " - Off");
						else
							FrameKey += " - Off";
						break;
				}
			}
			setFrameKey(FrameKey);
			_dirty = false;
		}
		
		public function drawOntoBuffer(Buffer:BitmapData):void
		{
			if (component)
			{
				if ((component is Device) || (component is Connector))
					_dirty = true;
			}
			if (_dirty)
				update();
			
			var FrameRect:Rectangle = frameRect;
			var TileWidth:uint = FrameRect.width / _widthInTiles;
			var TileHeight:uint = FrameRect.height / _heightInTiles;
			var InitialX:Number = gridX * TileWidth;
			var InitialY:Number = gridY * TileHeight;
			var FrameWidth:Number = FrameRect.width;
			var FrameHeight:Number = FrameRect.height;
			for (var y:uint = 0; y < _drawRepeatY; y++)
			{
				for (var x:uint = 0; x < _drawRepeatX; x++)
				{
					var TileX:Number = InitialX + FrameWidth * x;
					var TileY:Number = InitialY + FrameHeight * y;
					_topLeft.setTo(TileX, TileY);
					Buffer.copyPixels(_spriteSheet.bitmapData, FrameRect, _topLeft, null, null, true);
				}
			}
		}
	}
}
