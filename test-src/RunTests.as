package  
{
	import asunit.textui.TestRunner;
	
	public class RunTests extends TestRunner
	{	
		public function RunTests() 
		{
			start(MainTestSuite, null, TestRunner.SHOW_TRACE);
		}	
	}

}