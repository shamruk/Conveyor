package com.potapenko.remake
{
	import asunit.framework.TestCase;
	import flash.events.Event;
	
	public class ConveyorTest extends TestCase
	{
		private var _log:Array;
		private var _conveyor:Conveyor;
		
		override protected function setUp():void 
		{
			_log = [];
			_conveyor = new Conveyor();
		}
		
		private function addStarToLog():void
		{
			_log.push("*");
		}
		
		private function addTextToLog(text:String):void
		{
			_log.push(text);
		}
		
		private function onConveyorComplete(event:Event):void
		{
			_log.push("conveyor:complete");
		}
		
		public function testНеасинхронныеОперацииВыполняютсяВсеСразуПриЗапускеКонвеера():void
		{
			_conveyor.add(addStarToLog);
			_conveyor.add(addStarToLog);
			_conveyor.add(addTextToLog, "1");
			_conveyor.add(addTextToLog, "2");
			
			assertEqualsArrays([], _log);
			_conveyor.play();
			assertEqualsArrays(["*", "*", "1", "2"], _log);
		}
		
		public function testОднаОперацияТожеВыполняетсяСразуПриЗапускеКонвеера():void
		{
			_conveyor.add(addStarToLog);
			_conveyor.play();
			assertEqualsArrays(["*"], _log);
		}
		
		public function
			testАсинхроннаяОперацияНачинаетВыполнятьсяТолькоПослеЗавершенияПредыдущей():void
		{
			var async0:FakeAsync = new FakeAsync(_log, "0", _conveyor);
			var async1:FakeAsync = new FakeAsync(_log, "1", _conveyor);
			_conveyor.add(async0.run);
			_conveyor.add(async1.run, "*");
			_conveyor.add(async1.run, "**");
			
			assertEqualsArrays([], _log);
			_conveyor.play();
			assertEqualsArrays(["0:run()"], _log);
			async0.emulateComplete();
			assertEqualsArrays(["0:run()", "0:complete", "1:run(*)"], _log);
		}
		
		public function testПустойКонвеерСразуРаспространяетСобытиеОЗавершенииПриПуске():void
		{
			_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
			_conveyor.play();
			assertEqualsArrays(["conveyor:complete"], _log);
		}
		
		public function testКонвеерРаспространяетСобытиеОЗавершенииПослеВыполненияВсехЗадач():void
		{
			var async:FakeAsync = new FakeAsync(_log, "0", _conveyor);
			_conveyor.add(async.run);
			_conveyor.add(async.run, "*");
			_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
			_conveyor.play();
			assertEqualsArrays(["0:run()"], _log);
			async.emulateComplete();
			assertEqualsArrays(["0:run()", "0:complete", "0:run(*)"], _log);
			async.emulateComplete();
			assertEqualsArrays(["0:run()", "0:complete", "0:run(*)", "0:complete", "conveyor:complete"], _log);
		}
		
		private function add3TasksInConveyor():void
		{
			_conveyor.add(addTextToLog, "inner0");
			_conveyor.add(addTextToLog, "inner1");
			_conveyor.add(addTextToLog, "inner2");
		}
		
		private function addTasksWithAddInclude():void
		{
			_conveyor.addInclude(add3TasksInConveyor);
			_conveyor.add(addStarToLog);
			_conveyor.addInclude(add3TasksInConveyor);
		}
		
		public function testЗадания_добавленныеВнутриЗадания_выполняютсяПослеОстальных():void
		{
			_conveyor.add(addTextToLog, "1");
			_conveyor.add(add3TasksInConveyor);
			_conveyor.add(addTextToLog, "2");
			_conveyor.add(addTextToLog, "3");
			_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
			_conveyor.play();
			assertEqualsArrays(["1", "2", "3", "inner0", "inner1", "inner2", "conveyor:complete"], _log);
		}
		
		public function testДобавленныеЗаданияВнутриЗадания_добавленногоС_addInclude_выполняютсяСразуПослеНего():void
		{
			_conveyor.add(addTextToLog, "1");
			_conveyor.addInclude(add3TasksInConveyor);
			_conveyor.add(addTextToLog, "2");
			_conveyor.add(addTextToLog, "3");
			_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
			_conveyor.play();
			assertEqualsArrays(["1", "inner0", "inner1", "inner2", "2", "3", "conveyor:complete"], _log);
		}
		
		public function testДвойнаяВложенностьЗаданийС_addInclude_тожеРаботаетНормально():void
		{
			_conveyor.add(addTextToLog, "1");
			_conveyor.addInclude(addTasksWithAddInclude);
			_conveyor.add(addTextToLog, "2");
			_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
			_conveyor.play();
			assertEqualsArrays(["1", "inner0", "inner1", "inner2", "*", "inner0", "inner1", "inner2", "2", "conveyor:complete"], _log);
		}
		
		public function testПриОтсутсвующихПосле_addInclude_заданияхТожеВсеРаботаетНормально():void
		{
			_conveyor.add(addTextToLog, "1");
			_conveyor.addInclude(add3TasksInConveyor);
			_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
			_conveyor.play();
			assertEqualsArrays(["1", "inner0", "inner1", "inner2", "conveyor:complete"], _log);
		}
		
		public function testДобавленныеВЛюбомМестеАсинхроннойЗадачиТожеВыполняютсяСразуПослеНее_еслиЗадачаДобавленаС_addInclude():void
		{
			_conveyor.add(addTextToLog, "1");
			_conveyor.addInclude(asyncAdd1TaskInConveyor);
			_conveyor.add(addTextToLog, "2");
			_conveyor.play();
			asyncAdd1TaskInConveyor_emulateComplete();
			assertEqualsArrays(["1", "inner", "2"], _log);
		}
		
		private function asyncAdd1TaskInConveyor():void
		{
			_conveyor.stop();
		}
		
		private function asyncAdd1TaskInConveyor_emulateComplete():void
		{
			_conveyor.add(addTextToLog, "inner");
			_conveyor.play();
		}
		
		public function testВызовPlayДляНеостановленногоКонвеераНеПортитПорядокИСобытиеОЗавершенииПосылаетсяОдинРаз_т_е_конвеерСнаружиНеДолженЛоматься():void
		{
			_conveyor.add(addTextToLog, "1");
			_conveyor.add(addTextToLog, "2");
			_conveyor.add(playConveyor);
			_conveyor.add(addTextToLog, "3");
			_conveyor.add(addTextToLog, "4");
			_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
			_conveyor.play();
			assertEqualsArrays(["1", "2", "play", "3", "4", "conveyor:complete"], _log);
		}
		
		private function playConveyor():void
		{
			_log.push("play");
			_conveyor.play();
		}
		
		public function testСинхронныйОстановИПускНеЛомаетПосылкуСобытияОЗавершении():void
		{
			_conveyor.add(addTextToLog, "1");
			_conveyor.add(addTextToLog, "2");
			_conveyor.add(stopAndPlayConveyor);
			_conveyor.add(addTextToLog, "3");
			_conveyor.add(addTextToLog, "4");
			_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
			_conveyor.play();
			assertEqualsArrays(["1", "2", "stopAndPlay", "3", "4", "conveyor:complete"], _log);
		}
		
		private function stopAndPlayConveyor():void
		{
			_log.push("stopAndPlay");
			_conveyor.stop();
			_conveyor.play();
		}
		
		//------------------------------------------------------------------------------------------
		//
		//  Дополнительные тесты для проверки линкованного списка, эти списки требуют аккуратности
		//
		//------------------------------------------------------------------------------------------
		
		public function testПроверяемРаботуС_addInclude_безДобавленияВложенныхЗадачНаРазныхКоличествах():void
		{
			_log.length = 0;
			_conveyor = new Conveyor();
			_conveyor.addInclude(addTextToLog, "1");
			_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
			_conveyor.play();
			assertEqualsArrays(["1", "conveyor:complete"], _log);
			
			_log.length = 0;
			_conveyor = new Conveyor();
			_conveyor.addInclude(addTextToLog, "1");
			_conveyor.addInclude(addTextToLog, "2");
			_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
			_conveyor.play();
			assertEqualsArrays(["1", "2", "conveyor:complete"], _log);
			
			_log.length = 0;
			_conveyor = new Conveyor();
			_conveyor.addInclude(addTextToLog, "1");
			_conveyor.addInclude(addTextToLog, "2");
			_conveyor.addInclude(addTextToLog, "3");
			_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
			_conveyor.play();
			assertEqualsArrays(["1", "2", "3", "conveyor:complete"], _log);
		}
		
		public function testПроверяемРаботуС_addInclude_сВложеннымиЗадачамиНаРазныхКоличествах():void
		{
			for each (var f:Function in [addTasksInConveyor, addIncludeTasksInConveyor])
			{
				_log.length = 0;
				_conveyor = new Conveyor();
				_conveyor.addInclude(addTasksInConveyor, "1:", 1);
				_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
				_conveyor.play();
				assertEqualsArrays(["1:0", "conveyor:complete"], _log);
				
				_log.length = 0;
				_conveyor = new Conveyor();
				_conveyor.addInclude(addTasksInConveyor, "1:", 1);
				_conveyor.addInclude(addTasksInConveyor, "2:", 1);
				_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
				_conveyor.play();
				assertEqualsArrays(["1:0", "2:0", "conveyor:complete"], _log);
				
				_log.length = 0;
				_conveyor = new Conveyor();
				_conveyor.addInclude(addTasksInConveyor, "1:", 1);
				_conveyor.addInclude(addTasksInConveyor, "2:", 1);
				_conveyor.addInclude(addTasksInConveyor, "3:", 1);
				_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
				_conveyor.play();
				assertEqualsArrays(["1:0", "2:0", "3:0", "conveyor:complete"], _log);
				
				_log.length = 0;
				_conveyor = new Conveyor();
				_conveyor.addInclude(addTasksInConveyor, "1:", 2);
				_conveyor.addInclude(addTasksInConveyor, "2:", 1);
				_conveyor.addInclude(addTasksInConveyor, "3:", 2);
				_conveyor.addEventListener(Event.COMPLETE, onConveyorComplete);
				_conveyor.play();
				assertEqualsArrays(["1:0", "1:1", "2:0", "3:0", "3:1", "conveyor:complete"], _log);
			}
		}
		
		private function addTasksInConveyor(text:String, count:int):void
		{
			for (var i:int = 0; i < count; i++)
			{
				_conveyor.add(addTextToLog, text + i);
			}
		}
		
		private function addIncludeTasksInConveyor(text:String, count:int):void
		{
			for (var i:int = 0; i < count; i++)
			{
				_conveyor.addInclude(addTextToLog, text + i);
			}
		}
	}
}