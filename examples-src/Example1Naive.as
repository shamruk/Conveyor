package  
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class Example1Naive extends Sprite
	{
		private static const LIST:String = "example1_list.xml";
		
		public function Example1Naive()
		{
			loadList();
		}
		
		private var _listLoader:URLLoader;
		
		private function loadList():void
		{
			_listLoader = new URLLoader();
			_listLoader.addEventListener(Event.COMPLETE, onListLoadComplete);
			_listLoader.addEventListener(IOErrorEvent.IO_ERROR, onListLoadError);
			_listLoader.load(new URLRequest(LIST));
		}
		
		private var _pictures:Array;
		
		private function onListLoadComplete(event:Event):void
		{
			_pictures = [];
			var xml:XML = new XML(_listLoader.data);
			for each (var picture:* in xml.picture)
			{
				_pictures.push(String(picture));
			}
			_listLoader = null;
			loadPictures();
		}
		
		private function onListLoadError(event:Event):void
		{
			_listLoader = null;
			trace("List loading failure");
		}
		
		private var _pictureLoader:Loader;
		private var _loadingPictureIndex:int;
		private var _loadedPictures:Array;
		
		private function loadPictures():void
		{
			_loadingPictureIndex = 0;
			_loadedPictures = [];
			loadPicture();
		}
		
		private function loadPicture():void
		{
			var picture:String = _pictures[_loadingPictureIndex];
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
			_loadingPictureIndex++;
			if (_loadingPictureIndex >= _pictures.length)
			{
				placePictures();
			}
			else
			{
				loadPicture();
			}
		}
		
		private function onPictureLoadError(event:Event):void
		{
			_pictureLoader = null;
			trace("Picture loading error");
		}
		
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