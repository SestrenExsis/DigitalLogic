package truthTables
{
	public class TruthTable
	{
		private var _name:String;
		private var _inputNames:Vector.<String>;
		private var _outputNames:Vector.<String>;
		private var _inputMaps:Vector.<Object>;
		private var _outputMaps:Vector.<Object>;
		
		public function TruthTable(Name:String, InputNames:Vector.<String>, OutputNames:Vector.<String>, OutputValues:Object)
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
					OutputMap[OutputName] = OutputValues[OutputName][i];
				}
				
				_inputMaps.push(InputMap);
				_outputMaps.push(OutputMap);
			}
		}
		
		public static function convertObjectToTruthTable(Name:String, ObjectToConvert:Object):TruthTable
		{
			var InputNames:Vector.<String> = new Vector.<String>();
			var OutputNames:Vector.<String> = new Vector.<String>();
			var OutputValues:Object = new Object();
			if (ObjectToConvert.hasOwnProperty("inputs"))
			{
				var InputsObj:Object = ObjectToConvert["inputs"];
				for (var InputKey:String in InputsObj)
				{
					InputNames.push(InputKey);
				}
			}
			if (ObjectToConvert.hasOwnProperty("outputs"))
			{
				var OutputsObj:Object = ObjectToConvert["outputs"];
				for (var OutputKey:String in OutputsObj)
				{
					var OutputObj:Object = OutputsObj[OutputKey];
					OutputNames.push(OutputKey);
					if (OutputObj.hasOwnProperty("outputValues"))
						OutputValues[OutputKey] = OutputObj["outputValues"].concat();
				}
			}
			var NewTruthTable:TruthTable = new TruthTable(Name, InputNames, OutputNames, OutputValues);
			
			return NewTruthTable;
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
	}
}
