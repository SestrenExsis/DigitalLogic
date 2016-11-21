package entities
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Grid
	{
		private var _widthInTiles:uint;
		private var _heightInTiles:uint;
		private var _entities:Vector.<Entity>;
		
		public function Grid(WidthInTiles:uint = 40, HeightInTiles:uint = 30)
		{
			_widthInTiles = WidthInTiles;
			_heightInTiles = HeightInTiles;
			_entities = new Vector.<Entity>();
		}
		
		public function selectEntities(SelectLeft:uint, SelectTop:uint, Width:uint = 1, Height:uint = 1):Vector.<Entity>
		{
			var SelectRight:uint = SelectLeft + Width - 1;
			var SelectBottom:uint = SelectTop + Height - 1;
			var SelectedEntities:Vector.<Entity> = new Vector.<Entity>();
			for each (var CurrentEntity:Entity in _entities)
			{
				var Left:uint = CurrentEntity.gridX;
				var Top:uint = CurrentEntity.gridY;
				var Right:uint = Left + CurrentEntity.widthInTiles - 1;
				var Bottom:uint = Top + CurrentEntity.heightInTiles - 1;
				if (SelectLeft <= Right && SelectRight >= Left &&
					SelectTop <= Bottom && SelectBottom >= Top)
					SelectedEntities.push(CurrentEntity);
			}
			
			return SelectedEntities;
		}
		
		public function addEntity(EntityToAdd:Entity, GridX:uint, GridY:uint):void
		{
			//var Right:uint = GridX + EntityToAdd.widthInTiles - 1;
			//var Bottom:uint = GridY + EntityToAdd.heightInTiles - 1;
			//if (Right >= _widthInTiles || Bottom >= _heightInTiles)
			//	return false;
			
			EntityToAdd.gridX = GridX;
			EntityToAdd.gridY = GridY;
			_entities.push(EntityToAdd);
			
			//return true;
		}
		
		public function sortEntities():void
		{
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
		
		public function get widthInTiles():uint
		{
			return _widthInTiles;
		}
		
		public function get heightInTiles():uint
		{
			return _heightInTiles;
		}
		
		public function get entities():Vector.<Entity>
		{
			return _entities;
		}
	}
}
