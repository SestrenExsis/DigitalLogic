package
{
	import circuits.Board;
	import circuits.Connector;
	import circuits.Device;
	import circuits.DigitalComponent;
	import circuits.Node;
	import circuits.Wire;
	
	import entities.Entity;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import interfaces.IGameEntity;
	
	public class Grid implements IGameEntity
	{
		private var _baseEntity:Entity;
		private var _gridWidthInTiles:uint;
		private var _gridHeightInTiles:uint;
		private var _entities:Vector.<Entity>;
		private var _tempPoint:Point;
		private var _latestEntity:Entity;
		private var _currentEntity:Entity;
		private var _currentTouch:Point;
		private var _powerSource:Device;
		private var _board:Board;
		private var _mouseDown:Boolean = false;
		
		public function Grid(BaseEntity:Entity, GridWidthInTiles:uint = 40, GridHeightInTiles:uint = 30)
		{
			_baseEntity = BaseEntity;
			var TiledEntityWidthInTiles:uint = _baseEntity.widthInTiles;
			var TiledEntityHeightInTiles:uint = _baseEntity.heightInTiles;
			var DrawRepeatX:uint = GridWidthInTiles / TiledEntityWidthInTiles;
			var DrawRepeatY:uint = GridHeightInTiles / TiledEntityHeightInTiles;
			_baseEntity.setDrawRepeat(DrawRepeatX, DrawRepeatY);
			
			_gridWidthInTiles = GridWidthInTiles * TiledEntityWidthInTiles;
			_gridHeightInTiles = GridHeightInTiles * TiledEntityHeightInTiles;
			_entities = new Vector.<Entity>();
			
			_tempPoint = new Point();
			_currentTouch = new Point(-1.0, -1.0);
			_board = new Board();
		}
		
		private function getGridCoordinate(X:Number, Y:Number, Units:String = "tiles"):Point
		{
			var FrameRect:Rectangle = _baseEntity.frameRect;
			var TileWidth:uint = FrameRect.width / _baseEntity.widthInTiles;
			var TileHeight:uint = FrameRect.width / _baseEntity.heightInTiles;
			var GridX:int = Math.floor(X / TileWidth);
			var GridY:int = Math.floor(Y / TileHeight);
			
			// Check that the coordinate is on the grid
			if (GridX < 0 || GridX >= _gridWidthInTiles ||
				GridY < 0 || GridY >= _gridHeightInTiles)
			{
				trace("Coordinate is outside the bounds of the grid");
				return null;
			}
			
			if (Units == "tiles")
				_tempPoint.setTo(GridX, GridY);
			else if (Units == "pixels")
			{
				var PixelX:Number = TileWidth * GridX;
				var PixelY:Number = TileHeight * GridY;
				_tempPoint.setTo(PixelX, PixelY);
			}
			return _tempPoint;
		}
		
		private function getEntityAtPoint(X:Number, Y:Number, IgnoreComponentType:String = ""):Entity
		{
			var FrameRect:Rectangle = new Rectangle();
			for each (var CurrentEntity:Entity in _entities)
			{
				if (CurrentEntity.frameRect)
				{
					FrameRect.copyFrom(CurrentEntity.frameRect);
					var Pos:Point = CurrentEntity.position;
					FrameRect.x = Pos.x;
					FrameRect.y = Pos.y;
					if (FrameRect.contains(X, Y))
					{
						if (IgnoreComponentType == "")
							return CurrentEntity;
						else if (CurrentEntity.component.type != IgnoreComponentType)
							return CurrentEntity;
					}
				}
			}
			
			return null;
		}
		
		public function onTouch(X:Number, Y:Number):void
		{
			if (_mouseDown)
				return;
			
			_mouseDown = true;
			var GridCoordinate:Point = getGridCoordinate(X, Y);
			if (!GridCoordinate)
				return;
			
			var GridX:uint = GridCoordinate.x;
			var GridY:uint = GridCoordinate.y;
			_currentTouch.setTo(GridX, GridY);
			
			var EntityAtPoint:Entity = getEntityAtPoint(X, Y, DigitalComponent.CONNECTOR_NODE);
			if (EntityAtPoint)
			{
				_currentEntity = EntityAtPoint;
				_latestEntity = EntityAtPoint;
			}
			else
			{
				GridCoordinate = getGridCoordinate(X, Y, "pixels");
				var SnappedX:Number = GridCoordinate.x;
				var SnappedY:Number = GridCoordinate.y;
				var NewEntity:Entity = addWire(SnappedX, SnappedY, _currentEntity);
				_currentEntity = NewEntity;
				_latestEntity = NewEntity;
			}
		}
		
		public function onDrag(X:Number, Y:Number):void
		{
			var GridCoordinate:Point = getGridCoordinate(X, Y, "tiles");
			if (!GridCoordinate || GridCoordinate.equals(_currentTouch))
				return;
			
			var GridX:int = GridCoordinate.x;
			var GridY:int = GridCoordinate.y;
			var CurrentX:int = _currentTouch.x;
			var CurrentY:int = _currentTouch.y;
			_currentTouch.setTo(GridX, GridY);
			
			// If new cell is diagonal or more than one square away, break the chain.
			if (((GridX != CurrentX) && (GridY != CurrentY)) || 
				Math.abs(GridX - CurrentX) > 1 || 
				Math.abs(GridY - CurrentY) > 1)
			{
				_currentEntity = null;
				return;
			}
			
			// If an entity already exists, link it with the previous one, otherwise create a new one
			var PreviousEntity:Entity = _currentEntity;
			_currentEntity = getEntityAtPoint(X, Y);
			GridCoordinate = getGridCoordinate(X, Y, "pixels");
			var SnappedX:Number = GridCoordinate.x;
			var SnappedY:Number = GridCoordinate.y;
			var NewEntity:Entity
			if (_currentEntity)
			{
				var CurrentComponent:DigitalComponent = _currentEntity.component;
				var PreviousComponent:DigitalComponent = PreviousEntity.component;
				if (((CurrentComponent is Node) && (PreviousComponent is Wire)) ||
				((CurrentComponent is Wire) && (PreviousComponent is Node)))
				{
					NewEntity = addWire(SnappedX, SnappedY, PreviousEntity, _currentEntity);
					_currentEntity = NewEntity;
				}
					
				//if ((CurrentComponent is Connector) && (PreviousComponent is Connector))
				//	(CurrentComponent as Connector).connect(PreviousComponent as Connector);
			}
			else
			{
				NewEntity = addWire(SnappedX, SnappedY, PreviousEntity);
				_currentEntity = NewEntity;
			}
			_entities.sort(sortEntitiesByDrawingLayer);
		}
		
		public function onRelease(X:Number, Y:Number):void
		{
			if (!_mouseDown)
				return;
			
			_mouseDown = false;
			_currentEntity = null;
			_currentTouch.setTo(-1.0, -1.0);
		}
		
		public function update():void
		{
			_board.tick();
		}
		
		public function drawOntoBuffer(Buffer:BitmapData):void
		{
			_baseEntity.drawOntoBuffer(Buffer);
			
			for each (var EntityToDraw:Entity in _entities)
			{
				EntityToDraw.drawOntoBuffer(Buffer);
			}
		}
		
		private function addPowerSource(X:Number, Y:Number, Powered:Boolean):Entity
		{
			var PowerSource:Device = _board.addConstant(Powered);
			var PowerSourceEntity:Entity = new Entity(_baseEntity.spriteSheet, X, Y, PowerSource);
			var NodeOutEntity:Entity = new Entity(_baseEntity.spriteSheet, X + 8, Y, PowerSource.output);
			NodeOutEntity.addNeighbor(PowerSourceEntity);
			_entities.push(PowerSourceEntity);
			_entities.push(NodeOutEntity);
			
			return PowerSourceEntity;
		}
		
		private function addLamp(X:Number, Y:Number):Entity
		{
			var Lamp:Device = _board.addLamp();
			var LampEntity:Entity = new Entity(_baseEntity.spriteSheet, X, Y, Lamp);
			var NodeInEntity:Entity = new Entity(_baseEntity.spriteSheet, X - 8, Y, Lamp.input);
			NodeInEntity.addNeighbor(LampEntity);
			_entities.push(LampEntity);
			_entities.push(NodeInEntity);
			
			return LampEntity;
		}
		
		private function addNotGate(X:Number, Y:Number):Entity
		{
			var NotGate:Device = _board.addGate();
			var NotGateEntity:Entity = new Entity(_baseEntity.spriteSheet, X, Y, NotGate);
			var NodeInEntity:Entity = new Entity(_baseEntity.spriteSheet, X - 8, Y, NotGate.input);
			NodeInEntity.addNeighbor(NotGateEntity);
			var NodeOutEntity:Entity = new Entity(_baseEntity.spriteSheet, X + 8, Y, NotGate.output);
			NodeOutEntity.addNeighbor(NotGateEntity);
			_entities.push(NotGateEntity);
			_entities.push(NodeInEntity);
			_entities.push(NodeOutEntity);
			
			return NotGateEntity;
		}
		
		private function addWire(X:Number, Y:Number, EntityA:Entity = null, EntityB:Entity = null):Entity
		{
			var NewWire:Wire = _board.addWire();
			var WireEntity:Entity = new Entity(_baseEntity.spriteSheet, X, Y, NewWire);
			if (EntityA)
				connect(WireEntity, EntityA);
			if (EntityB)
				connect(WireEntity, EntityB);
			_entities.push(WireEntity);
			
			return WireEntity;
		}
		
		private function connect(WireEntity:Entity, ConnectorEntity:Entity):void
		{
			var BaseComponent:DigitalComponent = WireEntity.component;
			var ConnectingComponent:DigitalComponent = ConnectorEntity.component;
			if ((BaseComponent is Wire) && (ConnectingComponent is Connector))
			{
				(BaseComponent as Wire).connect(ConnectingComponent as Connector);
				WireEntity.addNeighbor(ConnectorEntity);
				if (ConnectingComponent is Wire)
					ConnectorEntity.addNeighbor(WireEntity);
			}
		}
		
		public function testBasicCircuit(X:Number, Y:Number):void
		{
			var PowerSource:Entity = addPowerSource(X, Y, true);
			var PowerSourceOut:Entity = _entities[_entities.length - 1];
			
			var NotGateA:Entity = addNotGate(X + 16, Y + 8);
			var NotGateAIn:Entity = _entities[_entities.length - 2];
			var NotGateAOut:Entity = _entities[_entities.length - 1];
			
			var NotGateB:Entity = addNotGate(X + 32, Y + 8);
			var NotGateBIn:Entity = _entities[_entities.length - 2];
			var NotGateBOut:Entity = _entities[_entities.length - 1];
			
			var Lamp:Entity = addLamp(X + 48, Y + 24);
			var LampIn:Entity = _entities[_entities.length - 1];
			LampIn.setPosition(LampIn.position.x + 8, LampIn.position.y - 8);
			
			var WireEntityA:Entity = addWire(X + 8, Y, PowerSourceOut);
			var WireEntityB:Entity = addWire(X + 8, Y + 8, WireEntityA, NotGateAIn);
			var WireEntityC:Entity = addWire(X + 24, Y + 8, NotGateAOut, NotGateBIn);
			var WireEntityD:Entity = addWire(X + 40, Y + 8, NotGateBOut);
			var WireEntityE:Entity = addWire(X + 48, Y + 8, WireEntityD);
			var WireEntityF:Entity = addWire(X + 48, Y + 16, WireEntityE, LampIn);
			
			_entities.sort(sortEntitiesByDrawingLayer);
		}
		
		private function sortEntitiesByDrawingLayer(EntityA:Entity, EntityB:Entity):Number
		{
			if (EntityA.drawingLayer < EntityB.drawingLayer)
				return -1;
			else if (EntityA.drawingLayer > EntityB.drawingLayer)
				return 1;
			else
				return 0;
		}
	}
}
