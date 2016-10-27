package
{
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
		private var _latestComponent:DigitalComponent;
		private var _currentComponent:DigitalComponent;
		private var _currentTouch:Point;
		private var _powerSource:Device;
		
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
		
		public function onTouch(X:Number, Y:Number):void
		{
			var GridCoordinate:Point = getGridCoordinate(X, Y);
			if (!GridCoordinate)
				return;
			
			var GridX:uint = GridCoordinate.x;
			var GridY:uint = GridCoordinate.y;
			_currentTouch.setTo(GridX, GridY);
		}
		
		public function onDrag(X:Number, Y:Number):void
		{
			var GridCoordinate:Point = getGridCoordinate(X, Y);
			if (!GridCoordinate || GridCoordinate.equals(_currentTouch))
				return;
			
			var GridX:int = GridCoordinate.x;
			var GridY:int = GridCoordinate.y;
			var CurrentX:int = _currentTouch.x;
			var CurrentY:int = _currentTouch.y;
			_currentTouch.setTo(GridX, GridY);
		}
		
		public function onRelease(X:Number, Y:Number):void
		{
			_currentComponent = null;
			_currentTouch.setTo(-1.0, -1.0);
		}
		
		public function update():void
		{
			for (var i:uint = 0; i < _entities.length; i++)
			{
				var EntityToUpdate:Entity = _entities[i];
				EntityToUpdate.update();
			}
			
			if (_powerSource)
				_powerSource.pulse();
		}
		
		public function drawOntoBuffer(Buffer:BitmapData):void
		{
			_baseEntity.drawOntoBuffer(Buffer);
			
			for (var i:uint = 0; i < _entities.length; i++)
			{
				var EntityToDraw:Entity = _entities[i];
				EntityToDraw.drawOntoBuffer(Buffer);
			}
		}
		
		private function addPowerSource(X:Number, Y:Number, Powered:Boolean):Entity
		{
			var PowerSource:Device = new Device(Powered);
			var NodeOut:Node = PowerSource.addOutput();
			var PowerSourceEntity:Entity = new Entity(_baseEntity.spriteSheet, X, Y, PowerSource);
			var NodeOutEntity:Entity = new Entity(_baseEntity.spriteSheet, X + 8, Y, NodeOut);
			NodeOutEntity.addNeighbor(PowerSourceEntity);
			_entities.push(PowerSourceEntity);
			_entities.push(NodeOutEntity);
			
			return PowerSourceEntity;
		}
		
		private function addLamp(X:Number, Y:Number):Entity
		{
			var Lamp:Device = new Device(false);
			var NodeIn:Node = Lamp.addInput();
			var LampEntity:Entity = new Entity(_baseEntity.spriteSheet, X, Y, Lamp);
			var NodeInEntity:Entity = new Entity(_baseEntity.spriteSheet, X - 8, Y, NodeIn);
			NodeInEntity.addNeighbor(LampEntity);
			_entities.push(LampEntity);
			_entities.push(NodeInEntity);
			
			return LampEntity;
		}
		
		private function addNotGate(X:Number, Y:Number):Entity
		{
			var NotGate:Device = new Device(true);
			var NodeIn:Node = NotGate.addInput();
			var NodeOut:Node = NotGate.addOutput();
			var NotGateEntity:Entity = new Entity(_baseEntity.spriteSheet, X, Y, NotGate);
			var NodeInEntity:Entity = new Entity(_baseEntity.spriteSheet, X - 8, Y, NodeIn);
			NodeInEntity.addNeighbor(NotGateEntity);
			var NodeOutEntity:Entity = new Entity(_baseEntity.spriteSheet, X + 8, Y, NodeOut);
			NodeOutEntity.addNeighbor(NotGateEntity);
			_entities.push(NotGateEntity);
			_entities.push(NodeInEntity);
			_entities.push(NodeOutEntity);
			
			return NotGateEntity;
		}
		
		private function addWire(X:Number, Y:Number, EntityA:Entity = null, EntityB:Entity = null):Entity
		{
			var NewWire:Wire = new Wire();
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
			
			_powerSource = (PowerSource.component as Device);
			
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
