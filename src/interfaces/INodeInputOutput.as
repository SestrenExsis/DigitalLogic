package interfaces
{
	import circuits.Node;
	
	public interface INodeInputOutput
	{
		function getInput(InputKey:String):Node;
		
		function getOutput(OutputKey:String):Node;
	}
}
