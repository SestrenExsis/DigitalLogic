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
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import interfaces.IGameEntity;
	
	import truthTables.TruthTable;
	
	public class Workbench implements IGameEntity
	{
		private var _baseEntity:Entity;
		private var _grid:Grid;
		private var _tempPoint:Point;
		private var _latestEntity:Entity;
		private var _currentEntity:Entity;
		private var _currentTouch:Point;
		private var _board:Board;
		private var _mouseDown:Boolean = false;
		private var _clock:Entity;
		private var _currentTime:uint = 0;
		private var _offInterval:uint = 8;
		private var _onInterval:uint = 8;
		private var _gridVisible:Rectangle;
		
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
			_clock = addEntity("Switch", 7, 15);
			_gridVisible = new Rectangle(0, 0, 20, 20);
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
		
		private function getEntitiesAtPoint(X:Number, Y:Number):Vector.<Entity>
		{
			var GridCoordinate:Point = getGridCoordinate(X, Y, "tiles");
			if (!GridCoordinate)
				return null;
			
			var GridX:uint = GridCoordinate.x;
			var GridY:uint = GridCoordinate.y;
			return _grid.selectEntities(GridX, GridY);
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
			
			var LatestComponent:DigitalComponent;
			if (_latestEntity)
				LatestComponent = _latestEntity.component;
			
			var EntitiesAtPoint:Vector.<Entity> = getEntitiesAtPoint(X, Y);
			if (EntitiesAtPoint.length > 0)
			{
				var DeviceEntity:Entity
				var WireEntity:Entity;
				var NodeEntityA:Entity;
				var NodeEntityB:Entity;
				for each (var EntityAtPoint:Entity in EntitiesAtPoint)
				{
					var ComponentAtPoint:DigitalComponent = EntityAtPoint.component;
					if (ComponentAtPoint)
					{
						if (ComponentAtPoint is Wire)
							WireEntity = EntityAtPoint;
						else if (ComponentAtPoint is Node)
						{
							if (NodeEntityA)
								NodeEntityB = EntityAtPoint;
							else
								NodeEntityA = EntityAtPoint;
						}
						else if (ComponentAtPoint is Device)
							DeviceEntity = EntityAtPoint;
					}
				}
				if (DeviceEntity)
				{
					_currentEntity = DeviceEntity;
					_latestEntity = DeviceEntity;
					if (DeviceEntity.component.type == DigitalComponent.DEVICE)
						(DeviceEntity.component as Device).nextState();
				}
				else
				{
					if (NodeEntityA && NodeEntityB && !WireEntity)
					{ // Connect two open nodes in the same cell
						if ((NodeEntityA.component as Node).open && 
							(NodeEntityB.component as Node).open)
						{
							var NewEntity:Entity = addWire(GridX, GridY, _currentEntity);
							connect(NewEntity, NodeEntityA);
							connect(NewEntity, NodeEntityB);
							_currentEntity = NewEntity;
							_latestEntity = NewEntity;
						}
					}
					else if (NodeEntityA && !WireEntity)
					{ // Connect a wire to a single open node
						if ((NodeEntityA.component as Node).open)
						{
							NewEntity = addWire(GridX, GridY, _currentEntity);
							connect(NewEntity, NodeEntityA);
							_currentEntity = NewEntity;
							_latestEntity = NewEntity;
						}
					}
					else if (WireEntity)
					{
						_currentEntity = WireEntity;
						_latestEntity = WireEntity;
					}
				}
			}
			else
			{
				if (LatestComponent)
				{
					if (LatestComponent is Device && (LatestComponent as Device).truthTable)
					{
						var LatestDevice:Device = LatestComponent as Device;
						if (LatestDevice.truthTable)
							NewEntity = addEntity(LatestDevice.truthTable.name, GridX, GridY);
					}
					else
					{
						switch (LatestComponent.type)
						{
							case DigitalComponent.CONNECTOR_WIRE:
								NewEntity = addWire(GridX, GridY, _currentEntity);
								break;
						}
					}
				}
				else
					NewEntity = addWire(GridX, GridY, _currentEntity);
				
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
			
			var PreviousEntity:Entity = _currentEntity;
			var EntitiesAtPoint:Vector.<Entity> = getEntitiesAtPoint(X, Y);
			_currentEntity = (EntitiesAtPoint.length > 0) ? EntitiesAtPoint[0] : null;
			var NewEntity:Entity;
			var PreviousComponent:DigitalComponent = null;
			if (PreviousEntity)
				PreviousComponent = PreviousEntity.component;
			if (_currentEntity)
			{
				var CurrentComponent:DigitalComponent = _currentEntity.component;
				if (((CurrentComponent is Node) && (PreviousComponent is Wire)) ||
					((PreviousComponent is Node) && (CurrentComponent is Wire)))
				{
					NewEntity = addWire(GridX, GridY, PreviousEntity, _currentEntity);
					_currentEntity = NewEntity;
				}
				else if ((CurrentComponent is Node) && (PreviousComponent is Device))
				{
					NewEntity = addWire(GridX, GridY, _currentEntity);
					_currentEntity = NewEntity;
				}
				else if ((PreviousComponent is Node) && (CurrentComponent is Device))
				{
					NewEntity = addWire(GridX, GridY, PreviousEntity);
					_currentEntity = NewEntity;
				}
				else if ((PreviousComponent is Wire) && (CurrentComponent is Wire))
				{
					if ((PreviousComponent as Wire).open &&(CurrentComponent as Wire).open)
						connect(_currentEntity, PreviousEntity);
					else if ((PreviousComponent as Wire).open)
					{
						NewEntity = addWire(GridX, GridY, PreviousEntity);
						_currentEntity = NewEntity;
					}
				}
			}
			else
			{
				if ((PreviousComponent is Wire) && !(PreviousComponent as Wire).open)
					NewEntity = addWire(GridX, GridY);
				else
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
		
		public function onKeyDown(KeyCode:uint):void
		{
			if (KeyCode == Keyboard.LEFT || KeyCode == Keyboard.RIGHT)
				(KeyCode == Keyboard.RIGHT) ? shiftGrid(1, 0) : shiftGrid(-1, 0);
			if (KeyCode == Keyboard.DOWN || KeyCode == Keyboard.UP)
				(KeyCode == Keyboard.UP) ? shiftGrid(0, -1) : shiftGrid(0, 1);
			
			if (KeyCode == Keyboard.D)
			{
				if (_latestEntity)
				{
					var ComponentToDelete:DigitalComponent = _latestEntity.component;
					if (ComponentToDelete)
					{
						_board.deleteComponent(ComponentToDelete);
						while (_latestEntity.neighbors.length > 0)
						{
							var Neighbor:Entity = _latestEntity.neighbors.pop();
							Neighbor.removeNeighbor(_latestEntity);
							if (ComponentToDelete is Device)
								_grid.deleteEntity(Neighbor);
						}
					}
					_grid.deleteEntity(_latestEntity);
					_latestEntity = null;
				}
			}
		}
		
		private function shiftGrid(AmountX:int, AmountY:int):void
		{
			var PreviousGridX:int = _gridVisible.x;
			_gridVisible.x += AmountX;
			if (_gridVisible.x < 0)
				_gridVisible.x = 0;
			else if (_gridVisible.right > _grid.widthInTiles)
				_gridVisible.x = _grid.widthInTiles - _gridVisible.width;
			
			var PreviousGridY:int = _gridVisible.y;
			_gridVisible.y += AmountY;
			if (_gridVisible.y < 0)
				_gridVisible.y = 0;
			else if (_gridVisible.bottom > _grid.heightInTiles)
				_gridVisible.y = _grid.heightInTiles - _gridVisible.height;
			
			var ShiftX:int = PreviousGridX - _gridVisible.x;
			var ShiftY:int = PreviousGridY - _gridVisible.y;
			for each (var EntityToShift:Entity in _grid.entities)
			{
				EntityToShift.gridX += ShiftX;
				EntityToShift.gridY += ShiftY;
			}
			trace(_gridVisible.toString());
		}
		
		public function update():void
		{
			_board.prime();
			_board.tick();
			_currentTime++;
			if (_currentTime == _offInterval)
				(_clock.component as Device).nextState();
			if (_currentTime >= _offInterval + _onInterval)
			{
				(_clock.component as Device).nextState();
				_currentTime = 0;
			}
		}
		
		public function drawOntoBuffer(Buffer:BitmapData):void
		{
			_baseEntity.drawOntoBuffer(Buffer);
			
			for each (var EntityToDraw:Entity in _grid.entities)
			{
				EntityToDraw.drawOntoBuffer(Buffer);
			}
		}
		
		private function addWire(GridX:uint, GridY:uint, EntityA:Entity = null, EntityB:Entity = null):Entity
		{
			trace("addWire(" + GridX + ", " + GridY + ", " + EntityA + ", " + EntityB + ")");
			var NewWire:Wire = _board.addWire();
			var WireEntity:Entity = new Entity(_baseEntity.spriteSheet, NewWire);
			if (EntityA)
				connect(WireEntity, EntityA);
			if (EntityB)
				connect(WireEntity, EntityB);
			
			_grid.addEntity(WireEntity, GridX, GridY);
			
			return WireEntity;
		}
		
		private function addEntity(EntityKey:String, GridX:uint, GridY:uint):Entity
		{
			trace("addEntity(" + EntityKey + ", " + GridX + ", " + GridY + ")");
			var EntityObject:Object = GameData.getEntityObject(EntityKey);
			var NewTruthTable:TruthTable = TruthTable.convertObjectToTruthTable(EntityKey, EntityObject);
			var NewDevice:Device = _board.addDevice(NewTruthTable);
			var NewEntity:Entity = Entity.convertObjectToEntity(_baseEntity.spriteSheet, EntityObject, NewDevice);
			
			_grid.addEntity(NewEntity, GridX, GridY);
			for each (var InputName:String in NewTruthTable.inputNames)
			{
				var InputObj:Object = EntityObject["inputs"][InputName];
				var InputOffsetX:uint = InputObj["x"];
				var InputOffsetY:uint = InputObj["y"];
				var InputWeight:uint = InputObj["weight"];
				var InputNode:Node = NewDevice.getInput(InputName);
				InputNode.weight = InputWeight;
				var NodeInEntity:Entity = new Entity(_baseEntity.spriteSheet, InputNode);
				NodeInEntity.addNeighbor(NewEntity);
				NewEntity.addNeighbor(NodeInEntity);
				_grid.addEntity(NodeInEntity, GridX + InputOffsetX, GridY + InputOffsetY);
			}
			for each (var OutputName:String in NewTruthTable.outputNames)
			{
				var OutputOffsets:Object = EntityObject["outputs"][OutputName];
				var OutputOffsetX:uint = OutputOffsets["x"];
				var OutputOffsetY:uint = OutputOffsets["y"];
				var NodeOutEntity:Entity = new Entity(_baseEntity.spriteSheet, NewDevice.getOutput(OutputName));
				NodeOutEntity.addNeighbor(NewEntity);
				NewEntity.addNeighbor(NodeOutEntity);
				_grid.addEntity(NodeOutEntity, GridX + OutputOffsetX, GridY + OutputOffsetY);
			}
			
			return NewEntity;
		}
		
		private function connect(WireEntity:Entity, ConnectorEntity:Entity):void
		{
			trace("connect(" + WireEntity.component.type + ", " + ConnectorEntity.component.type + ")");
			var BaseComponent:DigitalComponent = WireEntity.component;
			var ConnectingComponent:DigitalComponent = ConnectorEntity.component;
			if ((BaseComponent is Wire) && (ConnectingComponent is Connector))
			{
				(BaseComponent as Wire).connect(ConnectingComponent as Connector);
				WireEntity.addNeighbor(ConnectorEntity);
				if (ConnectingComponent is Wire)
					ConnectorEntity.addNeighbor(WireEntity);
			}
			WireEntity.setDirty();
			ConnectorEntity.setDirty();
		}
		
		public function addToolkit(GridX:uint, GridY:uint):void
		{
			var ConstantOff:Entity = addEntity("Constant - Off", GridX, GridY);
			var ConstantOn:Entity = addEntity("Constant - On", GridX, GridY + 2);
			var NotGate:Entity = addEntity("NOT Gate", GridX, GridY + 4);
			var ToggleableNotGate:Entity = addEntity("Toggleable NOT Gate", GridX + 2, GridY + 4);
			var AndGate:Entity = addEntity("AND Gate", GridX, GridY + 6);
			var OrGate:Entity = addEntity("OR Gate", GridX, GridY + 9);
			var XorGate:Entity = addEntity("XOR Gate", GridX, GridY + 12);
			var Lamp:Entity = addEntity("Lamp", GridX, GridY + 15);
			var Wire:Entity = addWire(GridX, GridY + 18);
			var Splitter:Entity = addEntity("Splitter", GridX, GridY + 20);
			var Switch:Entity = addEntity("Switch", GridX, GridY + 22);
			var HalfAdder:Entity = addEntity("Half Adder", GridX, GridY + 25);
			var FullAdder:Entity = addEntity("Full Adder", GridX + 3, GridY + 25);
			var BCDTo7SegConverter:Entity = addEntity("BCD to 7-segment Converter", GridX + 4, GridY);
			var DisplayBCD:Entity = addEntity("BCD Display", GridX + 4, GridY + 20);
			var Display7Seg:Entity = addEntity("7-segment Display", GridX + 8, GridY + 20);
			var FourBitSwitch:Entity = addEntity("4-bit Switch", GridX + 3, GridY + 8);
			var NandGate3:Entity = addEntity("3-Input NAND Gate", GridX + 3, GridY + 13);
			var NandGate:Entity = addEntity("NAND Gate", GridX + 3, GridY + 17);
			
			_grid.sortEntities();
		}
		
		public function testBasicCircuit(GridX:uint, GridY:uint):void
		{
			addEntity("Switch", GridX, GridY);
			addEntity("Switch", GridX, GridY + 3);
			addEntity("Switch", GridX, GridY + 5);
			addEntity("Splitter", GridX + 3, GridY + 5);
			addEntity("Splitter", GridX + 5, GridY + 3);
			addEntity("XOR Gate", GridX + 7, GridY + 3);
			addEntity("AND Gate", GridX + 7, GridY + 5);
			addEntity("Splitter", GridX + 10, GridY + 3);
			addEntity("Splitter", GridX + 11, GridY);
			addEntity("XOR Gate", GridX + 13, GridY);
			addEntity("AND Gate", GridX + 13, GridY + 2);
			addEntity("OR Gate", GridX + 16, GridY + 2);
			addEntity("Lamp", GridX + 19, GridY + 2);
			addEntity("Lamp", GridX + 19, GridY);
		}
	}
}
