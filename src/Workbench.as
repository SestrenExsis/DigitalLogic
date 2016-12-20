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
		private var _truthTables:Object;
		
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
			
			_truthTables = new Object();
			var StringAB:Vector.<String> = new <String>["a", "b"];
			var StringOut:Vector.<String> = new <String>["out"];
			
			var AndTable:TruthTable = new TruthTable("AND Gate", StringAB, StringOut, false);
			AndTable.setOutputs({a:true, b:true}, {out:true});
			_truthTables["AND Gate"] = AndTable;
			
			var OrTable:TruthTable = new TruthTable("OR Gate", StringAB, StringOut, true);
			OrTable.setOutputs({a:false, b:false}, {out:false});
			_truthTables["OR Gate"] = OrTable;
			
			var XorTable:TruthTable = new TruthTable("XOR Gate", StringAB, StringOut, true);
			XorTable.setOutputs({a:false, b:false}, {out:false});
			XorTable.setOutputs({a:true, b:true}, {out:false});
			_truthTables["XOR Gate"] = XorTable;
			
			var NotTable:TruthTable = new TruthTable("NOT Gate", new <String>["a"], StringOut, false);
			NotTable.setOutputs({a:false}, {out:true});
			_truthTables["NOT Gate"] = NotTable;
			
			var SplitterTable:TruthTable = new TruthTable(
				"Splitter",
				new <String>["a"], 
				new <String>["b", "c", "d"], 
				false
			);
			SplitterTable.setOutputs({a:true}, {b:true, c:true, d:true});
			_truthTables["Splitter"] = SplitterTable;
			
			var HalfAdderTable:TruthTable = new TruthTable(
				"Half Adder", 
				new <String>["a", "b"], 
				new <String>["sum", "carry_out"], 
				false
			);
			HalfAdderTable.setOutputs({a:false, b:true}, {sum:true, carry_out:false});
			HalfAdderTable.setOutputs({a:true, b:false}, {sum:true, carry_out:false});
			HalfAdderTable.setOutputs({a:true, b:true}, {sum:false, carry_out:true});
			_truthTables["Half Adder"] = HalfAdderTable;
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
					if (DeviceEntity.component.type == DigitalComponent.DEVICE_SWITCH)
						(DeviceEntity.component as Device).toggle();
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
						if ((WireEntity.component as Wire).open)
						{
							_currentEntity = WireEntity;
							_latestEntity = WireEntity;
						}
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
						{
							if (LatestDevice.truthTable.name == "Splitter")
								NewEntity = addSplitter(GridX, GridY);
							else
								NewEntity = addDevice(GridX, GridY, LatestDevice.truthTable);
						}
					}
					else
					{
						switch (LatestComponent.type)
						{
							case DigitalComponent.CONNECTOR_WIRE:
								NewEntity = addWire(GridX, GridY, _currentEntity);
								break;
							case DigitalComponent.DEVICE_CONSTANT:
								var Powered:Boolean = (LatestComponent as Device).invertOutput;
								NewEntity = addPowerSource(GridX, GridY, Powered);
								break;
							case DigitalComponent.DEVICE_SWITCH:
								NewEntity = addSwitch(GridX, GridY);
								break;
							case DigitalComponent.DEVICE_LAMP:
								NewEntity = addLamp(GridX, GridY);
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
			trace("addPowerSource(" + GridX + ", " + GridY + ", " + Powered + ")");
			var PowerSource:Device = _board.addConstant(Powered);
			var PowerSourceEntity:Entity = new Entity(_baseEntity.spriteSheet, PowerSource);
			var NodeOutEntity:Entity = new Entity(_baseEntity.spriteSheet, PowerSource.getOutput("out"));
			NodeOutEntity.addNeighbor(PowerSourceEntity);
			
			_grid.addEntity(PowerSourceEntity, GridX, GridY);
			_grid.addEntity(NodeOutEntity, GridX + 1, GridY);
			
			return PowerSourceEntity;
		}
		
		private function addSwitch(GridX:uint, GridY:uint):Entity
		{
			trace("addSwitch(" + GridX + ", " + GridY + ")");
			var Switch:Device = _board.addSwitch();
			var SwitchEntity:Entity = new Entity(_baseEntity.spriteSheet, Switch, 2, 2);
			var NodeOutEntity:Entity = new Entity(_baseEntity.spriteSheet, Switch.getOutput("out"));
			NodeOutEntity.addNeighbor(SwitchEntity);
			
			_grid.addEntity(SwitchEntity, GridX, GridY);
			_grid.addEntity(NodeOutEntity, GridX + 2, GridY);
			
			return SwitchEntity;
		}
		
		private function addLamp(GridX:uint, GridY:uint):Entity
		{
			trace("addLamp(" + GridX + ", " + GridY + ")");
			
			var Lamp:Device = _board.addLamp();
			var LampEntity:Entity = new Entity(_baseEntity.spriteSheet, Lamp, 2, 2);
			var NodeInEntity:Entity = new Entity(_baseEntity.spriteSheet, Lamp.getInput("a"));
			NodeInEntity.addNeighbor(LampEntity);
			_grid.addEntity(LampEntity, GridX, GridY);
			_grid.addEntity(NodeInEntity, GridX - 1, GridY);
			
			return LampEntity;
		}
		
		private function addDevice(GridX:uint, GridY:uint, TruthTableA:TruthTable, OutputPositions:Vector.<Point> = null):Entity
		{
			var NewDevice:Device = _board.addDevice(TruthTableA);
			var HeightInTiles:uint = TruthTableA.inputNames.length;
			var WidthInTiles:uint = HeightInTiles;
			var DeviceEntity:Entity = new Entity(_baseEntity.spriteSheet, NewDevice, WidthInTiles, HeightInTiles);
			_grid.addEntity(DeviceEntity, GridX, GridY);
			var Index:uint = 0;
			for each (var InputName:String in TruthTableA.inputNames)
			{
				var NodeInEntity:Entity = new Entity(_baseEntity.spriteSheet, NewDevice.getInput(InputName));
				NodeInEntity.addNeighbor(DeviceEntity);
				_grid.addEntity(NodeInEntity, GridX - 1, GridY + Index);
				Index++;
			}
			Index = 0;
			for each (var OutputName:String in TruthTableA.outputNames)
			{
				var NodeOutEntity:Entity = new Entity(_baseEntity.spriteSheet, NewDevice.getOutput(OutputName));
				NodeOutEntity.addNeighbor(DeviceEntity);
				if (OutputPositions)
				{
					var OutputPosition:Point = OutputPositions[Index];
					_grid.addEntity(NodeOutEntity, GridX + OutputPosition.x, GridY + OutputPosition.y);
				}
				else
					_grid.addEntity(NodeOutEntity, GridX + DeviceEntity.widthInTiles, GridY + Index);
				Index++;
			}
			
			return DeviceEntity;
		}
		
		private function addSplitter(GridX:uint, GridY:uint):Entity
		{
			trace("addSplitter(" + GridX + ", " + GridY + ")");
			
			var TruthTableA:TruthTable = new TruthTable("Splitter", 
				new <String>["a"], 
				new <String>["b", "c", "d"], 
				false
			);
			TruthTableA.setOutputs({a:true}, {b:true, c:true, d:true});
			
			var OutputPositions:Vector.<Point> = new Vector.<Point>();
			OutputPositions.push(new Point(0, -1));
			OutputPositions.push(new Point(1, 0));
			OutputPositions.push(new Point(0, 1));
			var GateEntity:Entity = addDevice(GridX, GridY, TruthTableA, OutputPositions);
			
			return GateEntity;
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
			var PowerSourceA:Entity = addPowerSource(GridX, GridY, false);
			var PowerSourceB:Entity = addPowerSource(GridX, GridY + 2, true);
			var NotGate:Entity = addDevice(GridX, GridY + 4, _truthTables["NOT Gate"]);
			var AndGate:Entity = addDevice(GridX, GridY + 6, _truthTables["AND Gate"]);
			var OrGate:Entity = addDevice(GridX, GridY + 9, _truthTables["OR Gate"]);
			var XorGate:Entity = addDevice(GridX, GridY + 12, _truthTables["XOR Gate"]);
			var Lamp:Entity = addLamp(GridX, GridY + 15);
			var Wire:Entity = addWire(GridX, GridY + 18);
			var Splitter:Entity = addSplitter(GridX, GridY + 20);
			var Switch:Entity = addSwitch(GridX, GridY + 22);
			var HalfAdder:Entity = addDevice(GridX, GridY + 25, _truthTables["Half Adder"]);
			
			_grid.sortEntities();
		}
		
		public function testBasicCircuit(GridX:uint, GridY:uint):void
		{
			addSwitch(GridX, GridY);
			addSwitch(GridX, GridY + 3);
			addSwitch(GridX, GridY + 5);
			addSplitter(GridX + 3, GridY + 5);
			addSplitter(GridX + 5, GridY + 3);
			addDevice(GridX + 7, GridY + 3, _truthTables["XOR Gate"]);
			addDevice(GridX + 7, GridY + 5, _truthTables["AND Gate"]);
			addSplitter(GridX + 10, GridY + 3);
			addSplitter(GridX + 11, GridY);
			addDevice(GridX + 13, GridY, _truthTables["XOR Gate"]);
			addDevice(GridX + 13, GridY + 2, _truthTables["AND Gate"]);
			addDevice(GridX + 16, GridY + 2, _truthTables["OR Gate"]);
			addLamp(GridX + 19, GridY + 2);
			addLamp(GridX + 19, GridY);
		}
	}
}
