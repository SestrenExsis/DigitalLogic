package
{
	import entities.Entity;
	import entities.SpriteSheet;
	import interfaces.IGameEntity;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Grid implements IGameEntity
	{
		private var _tiledEntity:Entity;
		private var _gridWidthInTiles:uint;
		private var _gridHeightInTiles:uint;
		private var _entities:Vector.<Entity>;
		private var _grid:Array;
		
		public function Grid(TiledEntity:Entity, GridWidthInTiles:uint = 40, GridHeightInTiles:uint = 30)
		{
			_tiledEntity = TiledEntity;
			var TiledEntityWidthInTiles:uint = _tiledEntity.widthInTiles;
			var TiledEntityHeightInTiles:uint = _tiledEntity.heightInTiles;
			var DrawRepeatX:uint = GridWidthInTiles / TiledEntityWidthInTiles;
			var DrawRepeatY:uint = GridHeightInTiles / TiledEntityHeightInTiles;
			_tiledEntity.setDrawRepeat(DrawRepeatX, DrawRepeatY);
			
			_gridWidthInTiles = GridWidthInTiles * TiledEntityWidthInTiles;
			_gridHeightInTiles = GridHeightInTiles * TiledEntityHeightInTiles;
			_entities = new Vector.<Entity>();
			_grid = new Array(_gridHeightInTiles);
			for (var i:uint = 0; i < _grid.length; i++)
			{
				_grid[i] = new Array(_gridWidthInTiles);
			}
		}
		
		public function addEntity(NewEntity:Entity, X:Number = 0, Y:Number = 0):void
		{
			var FrameRect:Rectangle = _tiledEntity.frameRect;
			var TileWidth:uint = FrameRect.width / _tiledEntity.widthInTiles;
			var TileHeight:uint = FrameRect.width / _tiledEntity.heightInTiles;
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
					{
						trace("No entity added - Another entity is in the way");
						return;
					}
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
			_tiledEntity.drawOntoBuffer(Buffer);
			
			for (var i:uint = 0; i < _entities.length; i++)
			{
				var EntityA:Entity = _entities[i];
				EntityA.drawOntoBuffer(Buffer);
			}
		}
	}
}
