package com.potapenko.remake 
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * А вот здесь навешиваем плюшки кто во что горазд
	 */
	public class ExtendedConveyor extends Conveyor
	{
		public function ExtendedConveyor() 
		{
		}
		
		public function addFrames(numFrames:int):void
		{
			add(waitFrames, numFrames);
		}
		
		public function addMilliseconds(milliseconds:int):void
		{
			add(waitMilliseconds, milliseconds);
		}
		
		//------------------------------------------------------------------------------------------
		//
		//  Ожидание заданное количество кадров
		//
		//------------------------------------------------------------------------------------------
		
		private var _enterFrameDispatcher:IEventDispatcher;
		private var _numFrames:int;
		
		private function waitFrames(numFrames:int):void
		{
			stop();
			if (_enterFrameDispatcher == null)
			{
				_enterFrameDispatcher = new Shape();
			}
			_numFrames = numFrames;
			_enterFrameDispatcher.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void 
		{
			_numFrames--;
			if (_numFrames <= 0)
			{
				_enterFrameDispatcher.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				play();
			}
		}
		
		//------------------------------------------------------------------------------------------
		//
		//  Ожидание заданное количество миллисекунд
		//
		//------------------------------------------------------------------------------------------
		
		private var _timer:Timer;
		
		private function waitMilliseconds(milliseconds:int):void
		{
			stop();
			if (_timer == null)
			{
				_timer = new Timer(1000);
			}
			_timer.delay = milliseconds;
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
		}
		
		private function onTimer(event:Event):void
		{
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			_timer.reset();
			play();
		}
	}
}