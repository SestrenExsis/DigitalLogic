package 
{
	import flash.net.SharedObject;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	import entities.Grid;
	
	public final class SaveData
	{
		private static const SHARED_OBJECT_NAME:String = "SaveState";
		
		private static var _saveState:SharedObject;
		private static var _grids:Object;
		
		private static var _stagedGridName:String = "Default";
		private static var _stagedGrid:Grid;

		public function SaveData()
		{
			
		}
		
		public static function getGridString():String
		{
			_saveState = SharedObject.getLocal(SHARED_OBJECT_NAME);
			
			var SaveStateData:Object;
			if (_saveState && _saveState.data)
				SaveStateData = _saveState.data;
			
			// Load grids
			if (SaveStateData && 
				SaveStateData.hasOwnProperty("_grids") &&
				SaveStateData._grids.hasOwnProperty(_stagedGridName))
			{
				_grids = SaveStateData._grids;
				var GridString:String = _grids[_stagedGridName];
				
				return GridString;
			}
			else
				return null;
			trace("getGridString()");
		}
		
		public static function saveGrid(GridToSave:Grid):void
		{
			_saveState = SharedObject.getLocal(SHARED_OBJECT_NAME);
			
			var SaveStateData:Object = _saveState.data;
			if (!SaveStateData._grids)
				SaveStateData._grids = new Object();
			
			var GridString:String = GridToSave.saveData;
			SaveStateData._grids[_stagedGridName] = GridString;
			
			_saveState.flush();
			trace("saveGrid(...)");
		}
	}
}