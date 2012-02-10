package  
{
	import asunit.framework.TestSuite;
	import com.potapenko.remake.ConveyorTest;
	
	public class MainTestSuite extends TestSuite
	{		
		public function MainTestSuite() 
		{
			addTest(new ConveyorTest());
		}
	}
}