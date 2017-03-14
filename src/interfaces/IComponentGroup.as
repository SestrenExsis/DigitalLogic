package interfaces
{
	import circuits.Node;
	
	public interface IComponentGroup
	{
		function getInput(InputKey:String):Node;
		
		function getOutput(OutputKey:String):Node;
	}
}
