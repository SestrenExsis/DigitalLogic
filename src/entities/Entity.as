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
		private var _widthInTiles:uint;
		private var _heightInTiles:uint;
		
		public var gridX:int = 0;
		public var gridY:int = 0;
		
		private var _topLeft:Point;
		private var _destPoint:Point;
		private var _currentFrameKey:String;
		private var _drawingLayer:int = 0;
		
		private var _drawRepeatX:uint = 1;
		private var _drawRepeatY:uint = 1;
		private var _neighbors:Vector.<Entity>;
		private var _component:DigitalComponent;
		private var _dirty:Boolean = true;
		
		private var _frames:Vector.<Frame>;
		
		public function Entity(SpriteSheetA:SpriteSheet, Component:DigitalComponent = null, WidthInTiles:uint = 1, HeightInTiles:uint = 1)
		{
			_spriteSheet = SpriteSheetA;
			_topLeft = new Point();
			_destPoint = new Point();
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
			NewEntity.sortFrames();
			
			return NewEntity;
		}
		
		public function addFrame(FrameToAdd:Frame):void
		{
			_frames.push(FrameToAdd);
		}
		
		private function sortFrames():void
		{
			var SortingArray:Array = new Array();
			while (_frames.length > 0)
			{
				SortingArray.push(_frames.pop());
			}
			SortingArray.sortOn("layer", Array.NUMERIC | Array.DESCENDING);
			while (SortingArray.length > 0)
			{
				_frames.push(SortingArray.pop());
			}
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
		
		public function set x(Value:Number):void
		{
			_topLeft.x = Value;
		}
		
		public function set y(Value:Number):void
		{
			_topLeft.y = Value;
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
		
		public function get neighbors():Vector.<Entity>
		{
			return _neighbors;
		}
		
		public function addNeighbor(NeighboringEntity:Entity):void
		{
			if (_neighbors.indexOf(NeighboringEntity) == -1)
				_neighbors.push(NeighboringEntity);
			
			_dirty = true;
		}
		
		public function removeNeighbor(NeighboringEntity:Entity):void
		{
			var IndexOfNeighbor:int = _neighbors.indexOf(NeighboringEntity);
			if (IndexOfNeighbor >= 0)
			{
				_neighbors.splice(IndexOfNeighbor, 1);
				_dirty = true;
			}
		}
		
		protected function getNeighborValue():uint
		{
			var Left:int = gridX;
			var Right:int = Left + widthInTiles - 1;
			var Top:int = gridY;
			var Bottom:int = Top + heightInTiles - 1;
			var NeighborValue:uint = 0;
			for each (var Neighbor:Entity in _neighbors)
			{
				var NeighborComponent:DigitalComponent = Neighbor.component;
				if (NeighborComponent is Node)
					NeighborValue += Neighbor.getNeighborValue();
				
				var NeighborLeft:int = Neighbor.gridX;
				var NeighborRight:int = NeighborLeft + Neighbor.widthInTiles - 1;
				var NeighborTop:int = Neighbor.gridY;
				var NeighborBottom:int = NeighborTop + Neighbor.heightInTiles - 1;
				
				if (NeighborBottom < Top)
					NeighborValue += 1; // North
				else if (NeighborLeft > Right)
					NeighborValue += 2; // East
				else if (NeighborTop > Bottom)
					NeighborValue += 4; // South
				else if (NeighborRight < Left)
					NeighborValue += 8; // West
			}
			
			return NeighborValue;
		}
		
		public function drawFramesOntoBuffer(Buffer:BitmapData, OffsetX:Number = 0, OffsetY:Number = 0):void
		{
			if (!_frames)
				return;
			
			var Index:uint = 0;
			if (_component)
			{
				if (_component is Device)
				{
					var DeviceA:Device = (_component as Device);
					Index = DeviceA.currentState;
					for (var InputNodeKey:String in DeviceA.inputs)
					{
						var InputNode:Node = DeviceA.getInput(InputNodeKey);
						var StateCount:uint = DeviceA.truthTable.stateCount;
						Index += (InputNode.powered) ? StateCount * InputNode.weight : 0;
					}
				}
				else if (_component is Connector)
				{
					Index += getNeighborValue();
					if ((_component is Wire) && ((_component as Wire).powered))
						Index += 16;
				}
			}
			
			var InitialX:Number = _topLeft.x + OffsetX;
			var InitialY:Number = _topLeft.y + OffsetY;
			for (var i:uint = 0; i < _frames.length; i++)
			{
				var FrameToDraw:Frame = _frames[i];
				if (!FrameToDraw.getVisibilityAtIndex(Index))
					continue;
				
				var FrameRect:Rectangle = _spriteSheet.getFrame(FrameToDraw.frameKey);
				var TileX:Number = InitialX + FrameToDraw.offset.x;
				var TileY:Number = InitialY + FrameToDraw.offset.y;
				_destPoint.setTo(TileX, TileY);
				Buffer.copyPixels(_spriteSheet.bitmapData, FrameRect, _destPoint, null, null, true);
			}
		}
		
		public function drawOntoBuffer(Buffer:BitmapData):void
		{
			if (_frames.length > 0)
			{
				for (var y:uint = 0; y < _drawRepeatY; y++)
				{
					for (var x:uint = 0; x < _drawRepeatX; x++)
					{
						// TO DO: Get rid of these hard-coded values (the 16s)
						var OffsetX:Number = 16 * x;
						var OffsetY:Number = 16 * y;
						drawFramesOntoBuffer(Buffer, OffsetX, OffsetY);
					}
				}
			}
		}
	}
}
