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
		
		private function addPowerSource(X:Number, Y:Number, Powered:Boolean):Device
		{
			var PowerSource:Device = new Device(Powered);
			var NodeOut:Node = PowerSource.addOutput();
			var EntityA:Entity = new Entity(_baseEntity.spriteSheet, X, Y, PowerSource);
			var EntityB:Entity = new Entity(_baseEntity.spriteSheet, X + 8, Y, NodeOut);
			_entities.push(EntityA);
			_entities.push(EntityB);
			
			return PowerSource;
		}
		
		private function addLamp(X:Number, Y:Number):Device
		{
			var Lamp:Device = new Device(false);
			var NodeIn:Node = Lamp.addInput();
			var EntityA:Entity = new Entity(_baseEntity.spriteSheet, X, Y, Lamp);
			var EntityB:Entity = new Entity(_baseEntity.spriteSheet, X - 8, Y, NodeIn);
			_entities.push(EntityA);
			_entities.push(EntityB);
			
			return Lamp;
		}
		
		private function addNotGate(X:Number, Y:Number):Device
		{
			var NotGate:Device = new Device(true);
			var NodeIn:Node = NotGate.addInput();
			var NodeOut:Node = NotGate.addOutput();
			var EntityA:Entity = new Entity(_baseEntity.spriteSheet, X, Y, NotGate);
			var EntityB:Entity = new Entity(_baseEntity.spriteSheet, X - 8, Y, NodeIn);
			var EntityC:Entity = new Entity(_baseEntity.spriteSheet, X + 8, Y, NodeOut);
			_entities.push(EntityA);
			_entities.push(EntityB);
			_entities.push(EntityC);
			
			return NotGate;
		}
		
		private function addWire(X:Number, Y:Number, Input:Connector):Wire
		{
			var NewWire:Wire = new Wire(Input);
			var EntityA:Entity = new Entity(_baseEntity.spriteSheet, X, Y, NewWire);
			_entities.push(EntityA);
			
			return NewWire;
		}
		
		public function testBasicCircuit(X:Number, Y:Number):void
		{
			var PowerSource:Device = addPowerSource(X, Y, true);
			var NotGateA:Device = addNotGate(X + 16, Y + 8);
			var NotGateB:Device = addNotGate(X + 32, Y + 8);
			var Lamp:Device = addLamp(X + 48, Y + 24);
			
			var WireA:Wire = addWire(X + 8, Y, PowerSource.output);
			var WireB:Wire = addWire(X + 8, Y + 8, WireA);
			WireB.connect(NotGateA.input);
			var WireC:Wire = addWire(X + 24, Y + 8, NotGateA.output);
			WireC.connect(NotGateB.input);
			var WireD:Wire = addWire(X + 40, Y + 8, NotGateB.output);
			var WireE:Wire = addWire(X + 48, Y + 8, WireD);
			var WireF:Wire = addWire(X + 48, Y + 16, WireE);
			WireF.connect(Lamp.input);
			
			_powerSource = PowerSource;
		}
	}
}
