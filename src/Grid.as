package
{
	import entities.DigitalComponent
	import entities.Entity;
	import entities.Wire;
	
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import interfaces.IGameEntity;
	
	public class Grid implements IGameEntity
	{
		private var _baseEntity:Entity;
		private var _gridWidthInTiles:uint;
		private var _gridHeightInTiles:uint;
		private var _components:Vector.<DigitalComponent>;
		private var _grid:Array;
		private var _tempPoint:Point;
		private var _currentComponent:DigitalComponent;
		private var _currentTouch:Point;
		
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
			_components = new Vector.<DigitalComponent>();
			_grid = new Array(_gridHeightInTiles);
			for (var i:uint = 0; i < _grid.length; i++)
			{
				_grid[i] = new Array(_gridWidthInTiles);
			}
			
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
			
			var ComponentAtTile:DigitalComponent = getComponentAtTile(GridX, GridY);
			if (ComponentAtTile)
				_currentComponent = ComponentAtTile;
			else
			{
				GridCoordinate = getGridCoordinate(X, Y, "pixels");
				var NewEntity:Wire = new Wire(_baseEntity.spriteSheet, GridCoordinate);
				addComponent(NewEntity, X, Y);
				_currentComponent = NewEntity;
			}
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
			
			// If new cell is diagonal or more than one square away, break the chain.
			if (((GridX != CurrentX) && (GridY != CurrentY)) || 
				Math.abs(GridX - CurrentX) > 1 || 
				Math.abs(GridY - CurrentY) > 1)
			{
				_currentComponent = null;
				return;
			}
			
			// If an entity already exists, link it with the previous one, otherwise create a new one
			var PreviousComponent:DigitalComponent = _currentComponent;
			_currentComponent = getComponentAtTile(GridX, GridY);
			if (_currentComponent)
			{
				_currentComponent.setInput(PreviousComponent);
			}
			else
			{
				GridCoordinate = getGridCoordinate(X, Y, "pixels");
				var NewWire:Wire = new Wire(_baseEntity.spriteSheet, GridCoordinate, PreviousComponent);
				addComponent(NewWire, X, Y);
				_currentComponent = NewWire;
			}
		}
		
		public function onRelease(X:Number, Y:Number):void
		{
			_currentComponent = null;
			_currentTouch.setTo(-1.0, -1.0);
		}
		
		private function getComponentAtTile(X:uint, Y:uint):DigitalComponent
		{
			var ComponentAtTile:DigitalComponent = _grid[Y][X];
			return ComponentAtTile;
		}
		
		private function removeComponent(ComponentToRemove:DigitalComponent):void
		{
			for (var y:uint = 0; y < _gridHeightInTiles; y++)
			{
				for (var x:uint = 0; x < _gridWidthInTiles; x++)
				{
					var ComponentAtTile:DigitalComponent = _grid[y][x];
					if (ComponentAtTile === ComponentToRemove)
						_grid[y][x] = null;
				}
			}
			
			var IndexOfEntity:int = _components.indexOf(ComponentToRemove);
			if (IndexOfEntity >= 0)
				_components.splice(IndexOfEntity, 1);
		}
		
		public function addComponent(NewComponent:DigitalComponent, X:Number = 0, Y:Number = 0):void
		{
			var FrameRect:Rectangle = _baseEntity.frameRect;
			var TileWidth:uint = FrameRect.width / _baseEntity.widthInTiles;
			var TileHeight:uint = FrameRect.width / _baseEntity.heightInTiles;
			var GridX:int = Math.floor(X / TileWidth);
			var GridY:int = Math.floor(Y / TileHeight);
			
			// Check that the new entity would fit on the grid
			if (GridX < 0 || GridX >= _gridWidthInTiles ||
				GridY < 0 || GridY >= _gridHeightInTiles)
			{
				trace("No entity added - The entity would fall off the grid");
				return;
			}
			
			// Check that there are no entities already on the grid in the space the new entity needs to occupy.
			var HeightInTiles:uint = NewComponent.heightInTiles;
			var WidthInTiles:uint = NewComponent.widthInTiles;
			for (var y:uint = 0; y < HeightInTiles; y++)
			{
				for (var x:uint = 0; x < WidthInTiles; x++)
				{
					var ComponentAtTile:Entity = _grid[GridY + y][GridX + x];
					if (ComponentAtTile)
						return;
				}
			}
			
			// Add the new entity to the list, and set the grid references to refer to the new entity.
			_components.push(NewComponent);
			for (y = 0; y < HeightInTiles; y++)
			{
				for (x = 0; x < WidthInTiles; x++)
				{
					_grid[GridY + y][GridX + x] = NewComponent;
				}
			}
			
			// Align the new entity's position with the grid.
			var X:Number = GridX * TileWidth;
			var Y:Number = GridY * TileHeight;
			NewComponent.setPosition(X, Y);
		}
		
		public function update():void
		{
			for (var i:uint = 0; i < _components.length; i++)
			{
				var Component:DigitalComponent = _components[i];
				if (!Component.input)
					Component.pulse();
			}
		}
		
		public function drawOntoBuffer(Buffer:BitmapData):void
		{
			_baseEntity.drawOntoBuffer(Buffer);
			
			for (var i:uint = 0; i < _components.length; i++)
			{
				var Component:DigitalComponent = _components[i];
				Component.drawOntoBuffer(Buffer);
			}
		}
	}
}
