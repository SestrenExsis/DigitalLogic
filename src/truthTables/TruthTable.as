package truthTables
{
	public class TruthTable
	{
		private var _name:String;
		private var _inputNames:Vector.<String>;
		private var _outputNames:Vector.<String>;
		private var _inputWeights:Object;
		private var _outputMaps:Array;
		
		public function TruthTable(Name:String, Inputs:Object, OutputNames:Vector.<String>, OutputValues:Object)
		{
			_name = Name;
			_inputNames = new Vector.<String>();
			_inputWeights = new Object();
			for (var InputKey:String in Inputs)
			{
				_inputNames.push(InputKey);
				_inputWeights[InputKey] = Inputs[InputKey];
			}
			_outputNames = OutputNames.concat();
			
			_outputMaps = new Array();
			var InputCombinationCount:uint = Math.pow(2, _inputNames.length);
			for (var i:uint = 0; i < InputCombinationCount; i++)
			{
				var InputMap:Object = new Object();
				var Index:uint = 0;
				for (var j:uint = 0; j < _inputNames.length; j++)
				{
					var Bit:uint = (i >> j) % 2;
					var Bool:Boolean = (Bit > 0) ? true : false;
					var InputName:String = _inputNames[j];
					Index += (Bool) ? Inputs[InputName] : 0;
				}
				
				var OutputMap:Object = new Object();
				for each (var OutputName:String in _outputNames)
				{
					OutputMap[OutputName] = OutputValues[OutputName][Index];
				}
				if (_outputMaps[Index])
					throw new Error("Duplicate index found");
				_outputMaps[Index] = OutputMap;
			}
		}
		
		public static function convertObjectToTruthTable(Name:String, ObjectToConvert:Object):TruthTable
		{
			var Inputs:Object = new Object();
			var InputNames:Vector.<String> = new Vector.<String>();
			var OutputNames:Vector.<String> = new Vector.<String>();
			var OutputValues:Object = new Object();
			if (ObjectToConvert.hasOwnProperty("inputs"))
			{
				var InputsObj:Object = ObjectToConvert["inputs"];
				for (var InputKey:String in InputsObj)
				{
					var InputObj:Object = InputsObj[InputKey];
					InputNames.push(InputKey);
					if (InputObj.hasOwnProperty("weight"))
						Inputs[InputKey] = InputObj["weight"];
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
			var NewTruthTable:TruthTable = new TruthTable(Name, Inputs, OutputNames, OutputValues);
			
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
			ReturnString += "\nOutputMaps: " + _outputMaps.toString();
			
			return ReturnString;
		}
		
		public function getOutputs(Search:Object):Object
		{
			var Index:int = 0;
			for (var InputKey:String in Search)
			{
				var Powered:Boolean = Search[InputKey];
				if (Powered)
					Index += _inputWeights[InputKey]
			}
			return _outputMaps[Index];
		}
	}
}
