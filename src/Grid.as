package
{
	import entities.Entity;
	
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
		private var _entities:Vector.<Entity>;
		private var _grid:Array;
		
		private var _tempPoint:Point;
		private var _previousTouch:Point;
		private var _currentTouch:Point;
		private var _dragBuffer:Vector.<Point>;
		
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
			_grid = new Array(_gridHeightInTiles);
			for (var i:uint = 0; i < _grid.length; i++)
			{
				_grid[i] = new Array(_gridWidthInTiles);
			}
			
			_tempPoint = new Point();
			_previousTouch = new Point(-1.0, -1.0);
			_currentTouch = new Point(-1.0, -1.0);
			_dragBuffer = new Vector.<Point>;
		}
		
		private function getGridCoordinate(X:Number, Y:Number):Point
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
			
			_tempPoint.setTo(GridX, GridY);
			return _tempPoint;
		}
		
		public function onTouch(X:Number, Y:Number):void
		{
			var GridCoordinate:Point = getGridCoordinate(X, Y);
			if (!GridCoordinate)
				return;
			
			var GridX:uint = GridCoordinate.x;
			var GridY:uint = GridCoordinate.y;
			
			_previousTouch.setTo(-1.0, -1.0);
			_currentTouch.setTo(GridX, GridY);
			_dragBuffer.splice(0, _dragBuffer.length);
			_dragBuffer.push(_currentTouch.clone());
			
			var EntityAtTile:Entity = getEntityAtTile(GridX, GridY);
			if (EntityAtTile)
				removeEntity(EntityAtTile);
			
			var TopLeft:Point = new Point(X, Y);
			var NewEntity:Entity = new Entity(_baseEntity.spriteSheet, TopLeft, "Wire");
			addEntity(NewEntity, X, Y);
		}
		
		public function onDrag(X:Number, Y:Number):void
		{
			var GridCoordinate:Point = getGridCoordinate(X, Y);
			if (!GridCoordinate || GridCoordinate.equals(_currentTouch))
				return;
			
			var GridX:uint = GridCoordinate.x;
			var GridY:uint = GridCoordinate.y;
			var CurrentX:uint = _currentTouch.x;
			var CurrentY:uint = _currentTouch.y;
			
			// If we have transitioned to a cell diagonal to the last cell, break the chain.
			if ((GridX != CurrentX) && (GridY != CurrentY))
			{
				var EntityAtTile:Entity = getEntityAtTile(CurrentX, CurrentY);
				if (EntityAtTile)
					removeEntity(EntityAtTile);
				return;
			}
			
			_previousTouch.setTo(CurrentX, CurrentY);
			_currentTouch.setTo(GridX, GridY);
			_dragBuffer.push(_currentTouch.clone());
			
			var TopLeft:Point = new Point(X, Y);
			var NewEntity:Entity = new Entity(_baseEntity.spriteSheet, TopLeft, "Wire");
			addEntity(NewEntity, X, Y);
		}
		
		public function onRelease(X:Number, Y:Number):void
		{
			var GridCoordinate:Point = getGridCoordinate(X, Y);
			if (!GridCoordinate)
				return;
			
			var GridX:uint = GridCoordinate.x;
			var GridY:uint = GridCoordinate.y;
			
			var EntityAtTile:Entity = getEntityAtTile(GridX, GridY);
			if (EntityAtTile)
				removeEntity(EntityAtTile);
			
			_previousTouch.setTo(-1.0, -1.0);
			_currentTouch.setTo(-1.0, -1.0);
			_dragBuffer.splice(0, _dragBuffer.length);
		}
		
		private function getEntityAtTile(X:uint, Y:uint):Entity
		{
			var EntityAtTile:Entity = _grid[Y][X];
			return EntityAtTile;
		}
		
		private function removeEntity(EntityToRemove:Entity):void
		{
			for (var y:uint = 0; y < _gridHeightInTiles; y++)
			{
				for (var x:uint = 0; x < _gridWidthInTiles; x++)
				{
					var EntityAtTile:Entity = _grid[y][x];
					if (EntityAtTile === EntityToRemove)
						_grid[y][x] = null;
				}
			}
			
			var IndexOfEntity:int = _entities.indexOf(EntityToRemove);
			if (IndexOfEntity >= 0)
				_entities.splice(IndexOfEntity, 1);
		}
		
		public function addEntity(NewEntity:Entity, X:Number = 0, Y:Number = 0):void
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
			var HeightInTiles:uint = NewEntity.heightInTiles;
			var WidthInTiles:uint = NewEntity.widthInTiles;
			for (var y:uint = 0; y < HeightInTiles; y++)
			{
				for (var x:uint = 0; x < WidthInTiles; x++)
				{
					var EntityAtTile:Entity = _grid[GridY + y][GridX + x];
					if (EntityAtTile)
						return;
				}
			}
			
			// Add the new entity to the list, and set the grid references to refer to the new entity.
			_entities.push(NewEntity);
			for (y = 0; y < HeightInTiles; y++)
			{
				for (x = 0; x < WidthInTiles; x++)
				{
					_grid[GridY + y][GridX + x] = NewEntity;
				}
			}
			
			// Align the new entity's position with the grid.
			var X:Number = GridX * TileWidth;
			var Y:Number = GridY * TileHeight;
			NewEntity.setPosition(X, Y);
		}
		
		public function drawOntoBuffer(Buffer:BitmapData):void
		{
			_baseEntity.drawOntoBuffer(Buffer);
			
			for (var i:uint = 0; i < _entities.length; i++)
			{
				var EntityA:Entity = _entities[i];
				EntityA.drawOntoBuffer(Buffer);
			}
		}
	}
}
