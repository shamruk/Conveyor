package  
{
	import com.potapenko.remake.Conveyor;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class Example1 extends Sprite
	{
		private static const LIST:String = "example1_list.xml";
		
		private var _conveyor:Conveyor;
		
		public function Example1()
		{
			_conveyor = new Conveyor();
			_conveyor.add(loadList);
			_conveyor.addInclude(loadPictures);
			_conveyor.add(placePictures);
			_conveyor.play();
		}
		
		private var _pictures:Array;
		private var _loadedPictures:Array;
		
		//{ loadList - асинхронная задача
		
		private var _listLoader:URLLoader;
		
		private function loadList():void
		{
			_conveyor.stop();
			_listLoader = new URLLoader();
			_listLoader.addEventListener(Event.COMPLETE, onListLoadComplete);
			_listLoader.addEventListener(IOErrorEvent.IO_ERROR, onListLoadError);
			_listLoader.load(new URLRequest(LIST));
		}
		
		private function onListLoadComplete(event:Event):void
		{
			_pictures = [];
			var xml:XML = new XML(_listLoader.data);
			for each (var picture:* in xml.picture)
			{
				_pictures.push(String(picture));
			}
			_listLoader = null;
			_conveyor.play();
		}
		
		private function onListLoadError(event:Event):void
		{
			_listLoader = null;
			trace("List loading failure");
		}
		
		//}
		
		private function loadPictures():void
		{
			_loadedPictures = [];
			for each (var picture:String in _pictures)
			{
				_conveyor.add(loadPicture, picture);
			}
		}
		
		//{ loadPicture - асинхронная задача
		
		private var _pictureLoader:Loader;
		
		private function loadPicture(picture:String):void
		{
			_conveyor.stop();
			_pictureLoader = new Loader();
			_pictureLoader.contentLoaderInfo.addEventListener(
				Event.COMPLETE, onPictureLoadComplete);
			_pictureLoader.addEventListener(
				IOErrorEvent.IO_ERROR, onPictureLoadError);
			_pictureLoader.load(new URLRequest(picture));
		}
		
		private function onPictureLoadComplete(event:Event):void
		{
			_loadedPictures.push(_pictureLoader.content);
			_pictureLoader = null;
			_conveyor.play();
		}
		
		private function onPictureLoadError(event:Event):void
		{
			_pictureLoader = null;
			trace("Picture loading error");
		}
		
		//}
		
		private function placePictures():void
		{
			var left:Number = 0;
			for each (var picture:DisplayObject in _loadedPictures)
			{
				picture.x = left;
				addChild(picture);
				left += picture.width;
			}
		}
	}
}