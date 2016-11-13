package
{
	import circuits.Board;
	import circuits.Connector;
	import circuits.Device;
	import circuits.DigitalComponent;
	import circuits.Node;
	import circuits.Wire;
	
	import entities.Entity;
	import entities.Grid;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import interfaces.IGameEntity;
	
	public class Workbench implements IGameEntity
	{
		private var _baseEntity:Entity;
		private var _grid:Grid;
		private var _tempPoint:Point;
		private var _latestEntity:Entity;
		private var _currentEntity:Entity;
		private var _currentTouch:Point;
		private var _powerSource:Device;
		private var _board:Board;
		private var _mouseDown:Boolean = false;
		
		public function Workbench(BaseEntity:Entity, GridWidthInTiles:uint = 40, GridHeightInTiles:uint = 30)
		{
			_baseEntity = BaseEntity;
			var TiledEntityWidthInTiles:uint = _baseEntity.widthInTiles;
			var TiledEntityHeightInTiles:uint = _baseEntity.heightInTiles;
			var DrawRepeatX:uint = GridWidthInTiles / TiledEntityWidthInTiles;
			var DrawRepeatY:uint = GridHeightInTiles / TiledEntityHeightInTiles;
			_baseEntity.setDrawRepeat(DrawRepeatX, DrawRepeatY);
			
			_grid = new Grid(GridWidthInTiles, GridHeightInTiles);
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
			if (GridX < 0 || GridX >= _grid.widthInTiles ||
				GridY < 0 || GridY >= _grid.heightInTiles)
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
			var GridCoordinate:Point = getGridCoordinate(X, Y, "tiles");
			if (!GridCoordinate)
				return null;
			
			var GridX:uint = GridCoordinate.x;
			var GridY:uint = GridCoordinate.y;
			var EntitiesAtPoint:Vector.<Entity> = _grid.selectEntities(GridX, GridY);
			for each (var CurrentEntity:Entity in EntitiesAtPoint)
			{
				if (IgnoreComponentType == "")
					return CurrentEntity;
				else if (CurrentEntity.component.type != IgnoreComponentType)
					return CurrentEntity;
			}
			
			return null;
		}
		
		public function onTouch(X:Number, Y:Number):void
		{
			if (_mouseDown)
				return;
			
			_mouseDown = true;
			var GridCoordinate:Point = getGridCoordinate(X, Y, "tiles");
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
				var NewEntity:Entity = addWire(GridX, GridY, _currentEntity);
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
			
			var FrameRect:Rectangle = _baseEntity.frameRect;
			var TileWidth:uint = FrameRect.width / _baseEntity.widthInTiles;
			var TileHeight:uint = FrameRect.width / _baseEntity.heightInTiles;
			while ((Math.abs(GridX - CurrentX) + Math.abs(GridY - CurrentY)) > 1)
			{
				if (CurrentX < GridX)
					CurrentX++;
				else if (CurrentX > GridX)
					CurrentX--;
				else if (CurrentY < GridY)
					CurrentY++;
				else if (CurrentY > GridY)
					CurrentY--;
				placeEntity(CurrentX * TileWidth, CurrentY * TileHeight);
			}
			
			placeEntity(X, Y);
			_grid.sortEntities();
		}
		
		private function placeEntity(X:Number, Y:Number):void
		{
			var GridCoordinate:Point = getGridCoordinate(X, Y, "tiles");
			var GridX:int = GridCoordinate.x;
			var GridY:int = GridCoordinate.y;
			
			// If an entity already exists, link it with the previous one, otherwise create a new one
			var PreviousEntity:Entity = _currentEntity;
			_currentEntity = getEntityAtPoint(X, Y);
			var NewEntity:Entity
			if (_currentEntity)
			{
				var CurrentComponent:DigitalComponent = _currentEntity.component;
				var PreviousComponent:DigitalComponent = PreviousEntity.component;
				if (((CurrentComponent is Node) && (PreviousComponent is Wire)) ||
					((CurrentComponent is Wire) && (PreviousComponent is Node)))
				{
					NewEntity = addWire(GridX, GridY, PreviousEntity, _currentEntity);
					_currentEntity = NewEntity;
				}
			}
			else
			{
				NewEntity = addWire(GridX, GridY, PreviousEntity);
				_currentEntity = NewEntity;
			}
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
			
			for each (var EntityToDraw:Entity in _grid.entities)
			{
				EntityToDraw.drawOntoBuffer(Buffer);
			}
		}
		
		private function addPowerSource(GridX:uint, GridY:uint, Powered:Boolean):Entity
		{
			var PowerSource:Device = _board.addConstant(Powered);
			var PowerSourceEntity:Entity = new Entity(_baseEntity.spriteSheet, PowerSource);
			var NodeOutEntity:Entity = new Entity(_baseEntity.spriteSheet, PowerSource.output);
			NodeOutEntity.addNeighbor(PowerSourceEntity);
			
			_grid.addEntity(PowerSourceEntity, GridX, GridY);
			_grid.addEntity(NodeOutEntity, GridX + 1, GridY);
			
			return PowerSourceEntity;
		}
		
		private function addLamp(GridX:uint, GridY:uint):Entity
		{
			var Lamp:Device = _board.addLamp();
			var LampEntity:Entity = new Entity(_baseEntity.spriteSheet, Lamp);
			var NodeInEntity:Entity = new Entity(_baseEntity.spriteSheet, Lamp.input);
			NodeInEntity.addNeighbor(LampEntity);
			
			_grid.addEntity(LampEntity, GridX, GridY);
			_grid.addEntity(NodeInEntity, GridX - 1, GridY);
			
			return LampEntity;
		}
		
		private function addNotGate(GridX:uint, GridY:uint):Entity
		{
			var NotGate:Device = _board.addGate();
			var NotGateEntity:Entity = new Entity(_baseEntity.spriteSheet, NotGate);
			var NodeInEntity:Entity = new Entity(_baseEntity.spriteSheet, NotGate.input);
			NodeInEntity.addNeighbor(NotGateEntity);
			var NodeOutEntity:Entity = new Entity(_baseEntity.spriteSheet, NotGate.output);
			NodeOutEntity.addNeighbor(NotGateEntity);
			
			_grid.addEntity(NotGateEntity, GridX, GridY);
			_grid.addEntity(NodeInEntity, GridX - 1, GridY);
			_grid.addEntity(NodeOutEntity, GridX + 1, GridY);
			
			return NotGateEntity;
		}
		
		private function addWire(GridX:uint, GridY:uint, EntityA:Entity = null, EntityB:Entity = null):Entity
		{
			var NewWire:Wire = _board.addWire();
			var WireEntity:Entity = new Entity(_baseEntity.spriteSheet, NewWire);
			if (EntityA)
				connect(WireEntity, EntityA);
			if (EntityB)
				connect(WireEntity, EntityB);
			
			_grid.addEntity(WireEntity, GridX, GridY);
			
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
		
		public function testBasicCircuit(GridX:uint, GridY:uint):void
		{
			var PowerSource:Entity = addPowerSource(GridX, GridY, true);
			var PowerSourceOut:Entity = _grid.entities[_grid.entities.length - 1];
			
			var NotGateA:Entity = addNotGate(GridX + 2, GridY + 1);
			var NotGateAIn:Entity = _grid.entities[_grid.entities.length - 2];
			var NotGateAOut:Entity = _grid.entities[_grid.entities.length - 1];
			
			var NotGateB:Entity = addNotGate(GridX + 4, GridY + 1);
			var NotGateBIn:Entity = _grid.entities[_grid.entities.length - 2];
			var NotGateBOut:Entity = _grid.entities[_grid.entities.length - 1];
			
			var Lamp:Entity = addLamp(GridX + 6, GridY + 3);
			var LampIn:Entity = _grid.entities[_grid.entities.length - 1];
			LampIn.gridX += 1;
			LampIn.gridY -= 1;
			
			var WireEntityA:Entity = addWire(GridX + 1, GridY, PowerSourceOut);
			var WireEntityB:Entity = addWire(GridX + 1, GridY + 1, WireEntityA, NotGateAIn);
			var WireEntityC:Entity = addWire(GridX + 3, GridY + 1, NotGateAOut, NotGateBIn);
			var WireEntityD:Entity = addWire(GridX + 5, GridY + 1, NotGateBOut);
			var WireEntityE:Entity = addWire(GridX + 6, GridY + 1, WireEntityD);
			var WireEntityF:Entity = addWire(GridX + 6, GridY + 2, WireEntityE, LampIn);
			
			_grid.sortEntities();
		}
	}
}
