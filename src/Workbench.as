package
{
	import circuits.*;
	
	import entities.Entity;
	import entities.Frame;
	import entities.Grid;
	
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import interfaces.IGameEntity;
	import interfaces.INodeInputOutput;
	
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
		private var _offInterval:uint = 64;
		private var _onInterval:uint = 64;
		private var _gridVisible:Rectangle;
		
		public function Workbench(GridWidthInTiles:uint = 40, GridHeightInTiles:uint = 30)
		{
			GameData.init();
			var SpriteSheetA:SpriteSheet = GameData.getSpriteSheet(GameData.SPRITES);
			var BackgroundTile:Entity = new Entity(SpriteSheetA, null, 2, 2);
			BackgroundTile.addFrame(new Frame("Background", 0, 0, 0, [1]));
			_baseEntity = BackgroundTile;
			
			var TiledEntityWidthInTiles:uint = _baseEntity.widthInTiles;
			var TiledEntityHeightInTiles:uint = _baseEntity.heightInTiles;
			var DrawRepeatX:uint = GridWidthInTiles / TiledEntityWidthInTiles;
			var DrawRepeatY:uint = GridHeightInTiles / TiledEntityHeightInTiles;
			_baseEntity.setDrawRepeat(DrawRepeatX, DrawRepeatY);
			
			// TO DO: Get rid of these hard-coded values (the 8s)
			_grid = new Grid(8, 8, GridWidthInTiles, GridHeightInTiles);
			_tempPoint = new Point();
			_currentTouch = new Point(-1.0, -1.0);
			_board = new Board("Default");
			//_clock = addEntity("Switch", 10, 15);
			_gridVisible = new Rectangle(0, 0, 40, 30);
		}
		
		private function getGridCoordinate(X:Number, Y:Number, Units:String = "tiles"):Point
		{
			var TileWidth:Number = _grid.gridWidth;
			var TileHeight:Number = _grid.gridHeight;
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
						else if (ComponentAtPoint is Board)
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
					else if (LatestComponent is Board)
					{
						var LatestBoard:Board = LatestComponent as Board;
						NewEntity = addEntity(LatestBoard.name, GridX, GridY);
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
			
			var TileWidth:Number = _grid.gridWidth;
			var TileHeight:Number = _grid.gridHeight;
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
							if (ComponentToDelete is INodeInputOutput)
								_grid.deleteEntity(Neighbor);
						}
					}
					_grid.deleteEntity(_latestEntity);
					_latestEntity = null;
				}
			}
			if (KeyCode == Keyboard.S)
				SaveData.saveGrid(_grid);
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
				_grid.setGridPositionOfEntity(EntityToShift, EntityToShift.gridX + ShiftX, EntityToShift.gridY + ShiftY);
			}
			trace(_gridVisible.toString());
		}
		
		public function update():void
		{
			_board.prime();
			_board.tick();
			_currentTime++;
			/*
			if (_currentTime == _offInterval)
				(_clock.component as Device).nextState();
			if (_currentTime >= _offInterval + _onInterval)
			{
				(_clock.component as Device).nextState();
				_currentTime = 0;
			}
			*/
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
			var EntityObject:Object = GameData.getEntityObject("Wire");
			var NewWire:Wire = _board.addWire();
			var WireEntity:Entity = Entity.convertObjectToEntity(_baseEntity.spriteSheet, EntityObject, NewWire);
			if (EntityA)
				connect(WireEntity, EntityA);
			if (EntityB)
				connect(WireEntity, EntityB);
			
			_grid.addEntity(WireEntity, GridX, GridY);
			
			return WireEntity;
		}
		
		private function addEntity(EntityKey:String, GridX:uint, GridY:uint):Entity
		{
			trace("addEntity(\"" + EntityKey + "\", " + GridX + ", " + GridY + ")");
			var EntityObject:Object = GameData.getEntityObject(EntityKey);
			var IsBoard:Boolean = EntityObject.hasOwnProperty("devices") && 
				EntityObject.hasOwnProperty("connections");
			var NewEntity:Entity;
			var NewDevice:Device;
			
			if (IsBoard)
			{
				var NewBoard:Board = _board.convertObjectToBoard(EntityKey, EntityObject);
				NewEntity = Entity.convertObjectToEntity(_baseEntity.spriteSheet, EntityObject, NewBoard);
			}
			else
			{
				var NewDeviceTable:TruthTable = TruthTable.convertObjectToTruthTable(EntityKey, EntityObject);
				NewDevice = _board.addDevice(NewDeviceTable);
				NewEntity = Entity.convertObjectToEntity(_baseEntity.spriteSheet, EntityObject, NewDevice);
			}
			
			_grid.addEntity(NewEntity, GridX, GridY);
			var NodeEntityObject:Object = GameData.getEntityObject("Node");
			for (var InputKey:String in EntityObject.inputs)
			{
				var InputObj:Object = EntityObject["inputs"][InputKey];
				var InputOffsetX:uint = InputObj["x"];
				var InputOffsetY:uint = InputObj["y"];
				var InputNode:Node = (IsBoard) ? NewBoard.getInput(InputKey) : NewDevice.getInput(InputKey);
				var NodeInEntity:Entity = Entity.convertObjectToEntity(_baseEntity.spriteSheet, NodeEntityObject, InputNode);
				NodeInEntity.addNeighbor(NewEntity);
				NewEntity.addNeighbor(NodeInEntity);
				_grid.addEntity(NodeInEntity, GridX + InputOffsetX, GridY + InputOffsetY);
			}
			for (var OutputKey:String in EntityObject.outputs)
			{
				var OutputOffsets:Object = EntityObject["outputs"][OutputKey];
				var OutputOffsetX:uint = OutputOffsets["x"];
				var OutputOffsetY:uint = OutputOffsets["y"];
				var OutputNode:Node = (IsBoard) ? NewBoard.getOutput(OutputKey) : NewDevice.getOutput(OutputKey);
				var NodeOutEntity:Entity = Entity.convertObjectToEntity(_baseEntity.spriteSheet, NodeEntityObject, OutputNode);
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
		
		private function connectByIndex(WireIndex:uint, ConnectorIndex:uint, NodeName:String = ""):void
		{
			trace("connectByIndex(" + WireIndex + ", " + ConnectorIndex + ")");
			var WireEntity:Entity = _grid.getEntityByIndex(WireIndex);
			var ConnectorEntity:Entity = _grid.getEntityByIndex(ConnectorIndex);
			if (NodeName == "")
				connect(WireEntity, ConnectorEntity);
			else
			{
				// TO DO: Connect wires to nodes
			}
		}
		
		public function loadGridString(GridString:String):void
		{
			// The index map is for mapping component IDs to entity indexes
			var IndexMap:Object = new Object();
			var GridObj:Object = JSON.parse(GridString);
			if (GridObj.hasOwnProperty("devices"))
			{
				var Devices:Array = GridObj.devices;
				for (var d:uint = 0; d < Devices.length; d++)
				{
					var CurrentDevice:Object = Devices[d];
					if (CurrentDevice.hasOwnProperty("x") &&
						CurrentDevice.hasOwnProperty("y") &&
						CurrentDevice.hasOwnProperty("device") &&
						CurrentDevice.hasOwnProperty("component_id"))
					{
						var X:uint = CurrentDevice.x;
						var Y:uint = CurrentDevice.y;
						var ComponentID:uint = CurrentDevice.component_id;
						var DeviceName:String = CurrentDevice.device;
						var DeviceEntity:Entity = addEntity(DeviceName, X, Y);
						IndexMap[ComponentID] = _grid.getIndexOfEntity(DeviceEntity);
					}
					else
						throw new Error("Invalid device object");
				}
			}
			if (GridObj.hasOwnProperty("wires"))
			{
				var Wires:Array = GridObj.wires;
				for (var w:uint = 0; w < Wires.length; w++)
				{
					var CurrentWire:Object = Wires[w];
					if (CurrentWire.hasOwnProperty("x") &&
						CurrentWire.hasOwnProperty("y") &&
						CurrentWire.hasOwnProperty("component_id"))
					{
						X = CurrentWire.x;
						Y = CurrentWire.y;
						ComponentID = CurrentWire.component_id;
						var WireEntity:Entity = addWire(X, Y);
						IndexMap[ComponentID] = _grid.getIndexOfEntity(WireEntity);
					}
					else
						throw new Error("Invalid wire object");
				}
			}
			if (GridObj.hasOwnProperty("connections"))
			{
				var Connections:Array = GridObj.connections;
				for (var c:uint = 0; c < Connections.length; c++)
				{
					var CurrentConnection:Object = Connections[c];
					if (CurrentConnection.hasOwnProperty("left_component_id") &&
						CurrentConnection.hasOwnProperty("right_component_id"))
					{
						var LeftComponentID:uint = CurrentConnection.left_component_id;
						var LeftEntityIndex:uint = IndexMap[LeftComponentID];
						var RightComponentID:uint = CurrentConnection.right_component_id;
						var RightEntityIndex:uint = IndexMap[RightComponentID];
						var RightNode:String = "";
						if (CurrentConnection.hasOwnProperty("right_node"))
							RightNode = CurrentConnection.right_node;
						connectByIndex(LeftEntityIndex, RightEntityIndex, RightNode);
					}
					else
						throw new Error("Invalid connection object");
				}
			}
			var DebugStr:String = "";
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
			var AndGate3:Entity = addEntity("3-Input AND Gate", GridX + 6, GridY + 13);
			var NandGate3:Entity = addEntity("3-Input NAND Gate", GridX + 3, GridY + 13);
			var Multiplexer4to1:Entity = addEntity("4-to-1 Multiplexer", GridX + 13, GridY + 13);
			var NandGate:Entity = addEntity("NAND Gate", GridX + 3, GridY + 17);
			
			var SRLatch:Entity = addEntity("S-R Latch", GridX + 20, GridY + 15);
			var JKFlipFlop:Entity = addEntity("J-K Flip Flop", GridX + 25, GridY + 20);
			_grid.sortEntities();
		}
		
		public function testBasicCircuit(GridX:uint, GridY:uint):void
		{
			// Place all entities, not counting nodes
			var FirstEntity:Entity = addEntity("Switch", GridX + 0, GridY + 0); // a:1
			addEntity("Switch", GridX + 0, GridY + 2); // a:3
			addEntity("AND Gate", GridX + 3, GridY + 1); // x:6, y:5, a:7
			addEntity("Lamp", GridX + 6, GridY + 1); // x:9, a:10
			
			addWire(GridX + 2, GridY + 0); // 11
			addWire(GridX + 2, GridY + 1); // 12
			addWire(GridX + 2, GridY + 2); // 13
			addWire(GridX + 5, GridY + 1); // 14
			
			// Connect all entities
			var FirstIndex:uint = _grid.getIndexOfEntity(FirstEntity);
			connectByIndex(FirstIndex + 11, FirstIndex + 1);
			connectByIndex(FirstIndex + 11, FirstIndex + 12);
			connectByIndex(FirstIndex + 12, FirstIndex + 6);
			connectByIndex(FirstIndex + 13, FirstIndex + 3);
			connectByIndex(FirstIndex + 13, FirstIndex + 5);
			connectByIndex(FirstIndex + 14, FirstIndex + 7);
			connectByIndex(FirstIndex + 14, FirstIndex + 9);
			
			var SaveData:String = _grid.saveData;
		}
	}
}
