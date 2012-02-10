package com.potapenko.remake 
{
	public class FakeAsync 
	{
		private var _log:Array;
		private var _name:String;
		private var _conveyor:Conveyor;
		
		public function FakeAsync(log:Array, name:String, conveyor:Conveyor)
		{
			_log = log;
			_name = name;
			_conveyor = conveyor;
		}
		
		private var _runned:Boolean = false;
		private var _completed:Boolean = true;
		
		public function run(arg:String = null):void
		{
			if (!_completed)
			{
				throw new Error("Mast complete before run");
			}
			
			_conveyor.stop();
			_runned = true;
			_log.push(_name + ":run(" + (arg != null ? arg : "") + ")");
		}
		
		public function emulateComplete():void
		{
			if (!_runned)
			{
				throw new Error("Can't emulate complete if not runned");
			}
			
			_runned = false;
			_completed = true;
			_log.push(_name + ":complete");
			_conveyor.play();
		}
	}
}