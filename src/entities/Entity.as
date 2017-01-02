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
	
	import truthTables.TruthTable;
	
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
		
		private var _frames:Vector.<Frame>;
		
		public function Entity(SpriteSheetA:SpriteSheet, Component:DigitalComponent = null, WidthInTiles:uint = 1, HeightInTiles:uint = 1)
		{
			_spriteSheet = SpriteSheetA;
			_topLeft = new Point();
			_neighbors = new Vector.<Entity>();
			_component = Component;
			_widthInTiles = WidthInTiles;
			_heightInTiles = HeightInTiles;
			
			if (_component)
			{
				switch (_component.type)
				{
					case DigitalComponent.DEVICE:
						_drawingLayer = 1;
						break;
					default:
						_drawingLayer = ((_component.type == DigitalComponent.CONNECTOR_NODE) ? 3 : 2);
						break;
				}
			}
			
			_frames = new Vector.<Frame>();
		}
		
		public static function convertObjectToEntity(SpriteSheetA:SpriteSheet, ObjectToConvert:Object, Component:DigitalComponent = null):Entity
		{
			var NewEntity:Entity = new Entity(SpriteSheetA, Component);
			if (ObjectToConvert.hasOwnProperty("widthInTiles"))
				NewEntity._widthInTiles = ObjectToConvert["widthInTiles"];
			if (ObjectToConvert.hasOwnProperty("heightInTiles"))
				NewEntity._heightInTiles = ObjectToConvert["heightInTiles"];
			if (ObjectToConvert.hasOwnProperty("frames"))
			{
				var Frames:Object = ObjectToConvert["frames"];
				for (var FrameKey:String in Frames)
				{
					var FrameObj:Object = Frames[FrameKey];
					var NewFrame:Frame = Frame.convertObjectToFrame(FrameObj);
					NewEntity.addFrame(NewFrame);
				}
			}
			
			return NewEntity;
		}
		
		public function addFrame(FrameToAdd:Frame):void
		{
			_frames.push(FrameToAdd);
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
					default:
						FrameKey = "Default";
						break;
				}
			}
			setFrameKey(FrameKey);
			_dirty = false;
		}
		
		public function drawFramesOntoBuffer(Buffer:BitmapData):void
		{
			if (!_frames)
				return;
			
			if (_component && (_component is Device))
			{
				var DeviceA:Device = (_component as Device);
				var Index:uint = DeviceA.currentState;
				for (var InputNodeKey:String in DeviceA.inputKeys)
				{
					var InputNode:Node = DeviceA.getInput(InputNodeKey);
					var StateCount:uint = DeviceA.truthTable.stateCount;
					Index += (InputNode.powered) ? StateCount * InputNode.weight : 0;
				}
			}
			
			var TileWidth:uint = frameRect.width;
			var TileHeight:uint = frameRect.height;
			var InitialX:Number = gridX * TileWidth;
			var InitialY:Number = gridY * TileHeight;
			for each (var FrameToDraw:Frame in _frames)
			{
				if (!FrameToDraw.getVisibilityAtIndex(Index))
					continue;
				
				var FrameRect:Rectangle = _spriteSheet.getFrame(FrameToDraw.frameKey);
				var TileX:Number = InitialX + FrameToDraw.offset.x;
				var TileY:Number = InitialY + FrameToDraw.offset.y;
				_topLeft.setTo(TileX, TileY);
				Buffer.copyPixels(_spriteSheet.bitmapData, FrameRect, _topLeft, null, null, true);
			}
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
			
			if (_frames.length > 0)
			{
				drawFramesOntoBuffer(Buffer);
				return;
			}
			
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
