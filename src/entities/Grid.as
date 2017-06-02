package entities
{
	import circuits.Board;
	import circuits.Connector;
	import circuits.Device;
	import circuits.DigitalComponent;
	import circuits.Node;
	import circuits.Wire;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Grid
	{
		private var _widthInTiles:uint;
		private var _heightInTiles:uint;
		private var _gridWidth:Number;
		private var _gridHeight:Number;
		private var _entities:Vector.<Entity>;
		
		public function Grid(GridWidth:Number = 8, GridHeight:Number = 8, WidthInTiles:uint = 40, HeightInTiles:uint = 30)
		{
			_gridWidth = GridWidth;
			_gridHeight = GridHeight;
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
		
		public function setGridPositionOfEntity(EntityToPosition:Entity, GridX:int, GridY:int):void
		{
			EntityToPosition.gridX = GridX;
			EntityToPosition.x = GridX * _gridWidth;
			EntityToPosition.gridY = GridY;
			EntityToPosition.y = GridY * _gridHeight;
		}
		
		public function addEntity(EntityToAdd:Entity, GridX:uint, GridY:uint):void
		{
			//var Right:uint = GridX + EntityToAdd.widthInTiles - 1;
			//var Bottom:uint = GridY + EntityToAdd.heightInTiles - 1;
			//if (Right >= _widthInTiles || Bottom >= _heightInTiles)
			//	return false;
			
			setGridPositionOfEntity(EntityToAdd, GridX, GridY);
			_entities.push(EntityToAdd);
			
			//return true;
		}
		
		public function deleteEntity(EntityToDelete:Entity):void
		{
			var IndexOfEntity:int = _entities.indexOf(EntityToDelete);
			if (IndexOfEntity == -1)
				throw new Error("Entity to delete not found on Grid.");
			
			_entities.splice(IndexOfEntity, 1);
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
		
		public function get gridWidth():Number
		{
			return _gridWidth;
		}
		
		public function get gridHeight():Number
		{
			return _gridHeight;
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
		
		public function get saveData():String
		{
			var SaveData:Object = new Object();
			var Devices:Object = new Array();
			var Wires:Object = new Array();
			var WiresToCheck:Vector.<Wire> = new Vector.<Wire>();
			var Connections:Object = new Array();
			for each (var CurrentEntity:Entity in _entities)
			{
				var CurrentComponent:DigitalComponent = CurrentEntity.component;
				var NewComponentObj:Object = new Object();
				NewComponentObj.component_id = CurrentComponent.componentID;
				NewComponentObj.x = CurrentEntity.gridX;
				NewComponentObj.y = CurrentEntity.gridY;
				if (CurrentComponent is Wire)
				{
					WiresToCheck.push(CurrentComponent as Wire);
					Wires.push(NewComponentObj);
				}
				else if (CurrentComponent is Board)
				{
					NewComponentObj.device = (CurrentComponent as Board).name;
					Devices.push(NewComponentObj);
				}
				else if (CurrentComponent is Device)
				{
					NewComponentObj.device = (CurrentComponent as Device).truthTable.name;
					Devices.push(NewComponentObj);
				}
			}
			SaveData.devices = Devices;
			SaveData.wires = Wires;
			
			var ConnectionsChecked:Vector.<uint> = new Vector.<uint>();
			for each (var CurrentWire:Wire in WiresToCheck)
			{
				if (CurrentWire.a)
				{
					var CurrentConnectorA:Connector = CurrentWire.a;
					if (ConnectionsChecked.indexOf(CurrentConnectorA.componentID) < 0)
					{
						
						if (CurrentConnectorA is Node)
						{
							var CurrentNodeA:Node = CurrentConnectorA as Node;
							var CurrentDeviceA:Device = CurrentNodeA.device;
							var NewConnectionObjA:Object = new Object();
							NewConnectionObjA.left_component_id = CurrentWire.componentID;
							NewConnectionObjA.right_component_id = CurrentDeviceA.componentID;
							NewConnectionObjA.right_node = CurrentNodeA.name;
							Connections.push(NewConnectionObjA);
						}
						else if (CurrentConnectorA is Wire)
						{
							NewConnectionObjA = new Object();
							NewConnectionObjA.left_component_id = CurrentWire.componentID;
							NewConnectionObjA.right_component_id = CurrentWire.a.componentID;
							Connections.push(NewConnectionObjA);
						}
					}
				}
				if (CurrentWire.b)
				{
					var CurrentConnectorB:Connector = CurrentWire.b;
					if (ConnectionsChecked.indexOf(CurrentConnectorB.componentID) < 0)
					{
						if (CurrentConnectorB is Node)
						{
							var CurrentNodeB:Node = CurrentConnectorB as Node;
							var CurrentDeviceB:Device = CurrentNodeB.device;
							var NewConnectionObjB:Object = new Object();
							NewConnectionObjB.left_component_id = CurrentWire.componentID;
							NewConnectionObjB.right_component_id = CurrentDeviceB.componentID;
							NewConnectionObjB.right_node = CurrentNodeB.name;
							Connections.push(NewConnectionObjB);
						}
						else if (CurrentConnectorB is Wire)
						{
							NewConnectionObjB = new Object();
							NewConnectionObjB.left_component_id = CurrentWire.componentID;
							NewConnectionObjB.right_component_id = CurrentWire.b.componentID;
							Connections.push(NewConnectionObjB);
						}
					}
				}
				ConnectionsChecked.push(CurrentWire.componentID);
			}
			SaveData.connections = Connections;
			
			var SaveDataStr:String = JSON.stringify(SaveData);
			return SaveDataStr;
		}
	}
}
