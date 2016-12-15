package truthTables
{
	public class TruthTable
	{
		private var _name:String;
		private var _inputNames:Vector.<String>;
		private var _outputNames:Vector.<String>;
		private var _inputMaps:Vector.<Object>;
		private var _outputMaps:Vector.<Object>;
		
		public function TruthTable(Name:String, InputNames:Vector.<String>, OutputNames:Vector.<String>, Default:Boolean = false)
		{
			_name = Name;
			_inputNames = InputNames.concat();
			_outputNames = OutputNames.concat();
			
			_inputMaps = new Vector.<Object>();
			_outputMaps = new Vector.<Object>();
			var InputCombinationCount:uint = Math.pow(2, _inputNames.length);
			for (var i:uint = 0; i < InputCombinationCount; i++)
			{
				var InputMap:Object = new Object();
				for (var j:uint = 0; j < _inputNames.length; j++)
				{
					var Bit:uint = (i >> j) % 2;
					var Bool:Boolean = (Bit > 0) ? true : false;
					var InputName:String = _inputNames[j];
					InputMap[InputName] = Bool;
				}
				
				var OutputMap:Object = new Object();
				for each (var OutputName:String in _outputNames)
				{
					OutputMap[OutputName] = Default;
				}
				
				_inputMaps.push(InputMap);
				_outputMaps.push(OutputMap);
			}
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get inputNames():Vector.<String>
		{
			return _inputNames;
		}
		
		public function get outputNames():Vector.<String>
		{
			return _outputNames;
		}
		
		public function toString():String
		{
			var ReturnString:String = "Inputs: " + _inputNames.toString();
			ReturnString += "\nOutputs: " + _outputNames.toString();
			ReturnString += "\nMap:\n";
			for (var i:uint = 0; i < _inputMaps.length; i++)
			{
				var Key:Object = _inputMaps[i];
				var KeyString:String = "[";
				for (var InputKey:Object in Key)
				{
					KeyString += InputKey + ": " + Key[InputKey] + ",";
				}
				KeyString += "]";
				
				var Value:Object = _outputMaps[i];
				var ValueString:String = "[";
				for (var OutputKey:Object in Value)
				{
					ValueString += OutputKey + ": " + Value[OutputKey] + ",";
				}
				ValueString += "]";
				
				ReturnString += KeyString + " = " + ValueString + "\n";
			}
			return ReturnString;
		}
		
		public function getOutputs(Search:Object):Object
		{
			var Match:Boolean;
			for (var i:uint = 0; i < _inputMaps.length; i++)
			{
				Match = true;
				var Key:Object = _inputMaps[i];
				for (var SearchKey:Object in Key)
				{
					if (!Search.hasOwnProperty(SearchKey) || (Key[SearchKey] != Search[SearchKey]))
						Match = false;
				}
				if (Match)
					return _outputMaps[i];
			}
			return null;
		}
		
		public function setOutputs(Search:Object, NewOutputs:Object):void
		{
			var OldOutputs:Object = getOutputs(Search);
			for (var SearchKey:Object in NewOutputs)
			{
				if (OldOutputs.hasOwnProperty(SearchKey))
					OldOutputs[SearchKey] = NewOutputs[SearchKey];
			}
		}
	}
}
