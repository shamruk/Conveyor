package 
{
	import com.potapenko.remake.ExtendedConveyor;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class Example2 extends Sprite 
	{
		private var _conveyor:ExtendedConveyor;
		
		public function Example2():void 
		{
			_conveyor = new ExtendedConveyor();
			
			var shape0:Shape = newShape();
			var shape1:Shape = newShape();
			
			var tf:TextField = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.selectable = false;
			tf.text = "Кликните мышкой, чтобы продолжить";
			
			addChild(shape0);
			var i:int;
			for (i = 0; i < 100; i += 2)
			{
				_conveyor.add(setPosition, shape0, i * 2, i);
				_conveyor.addFrames(1);
			}
			_conveyor.add(addChild, tf);
			_conveyor.add(setPosition, tf, 200, 150);
			_conveyor.add(waitClick);
			_conveyor.add(removeChild, tf);
			_conveyor.add(addChild, shape1);
			for (i = 0; i < 100; i += 2)
			{
				_conveyor.addFrames(1);
				_conveyor.add(setPosition, shape0, (100 - i) * 2, (100 - i));
				_conveyor.add(setPosition, shape1, 500 - i * 2, i);
			}
			_conveyor.addMilliseconds(200);
			for (i = 0; i < 100; i += 2)
			{
				_conveyor.addFrames(1);
				_conveyor.add(setPosition, shape0, i * 2, i);
				_conveyor.add(setPosition, shape1, 500 - (100 - i) * 2, (100 - i));
			}
			_conveyor.play();
		}
		
		private function newShape():Shape
		{
			var shape:Shape = new Shape();
			var g:Graphics = shape.graphics;
			g.beginFill(0xff0000);
			g.drawRect( -50, -50, 100, 100);
			g.endFill();
			return shape;
		}
		
		private function setPosition(displayObject:DisplayObject, x:Number, y:Number):void
		{
			displayObject.x = x;
			displayObject.y = y;
		}
		
		private function setRotation(displayObject:DisplayObject, rotation:Number):void
		{
			displayObject.rotation = rotation;
		}
		
		//{ waitClick - асинхронная задача
		
		private function waitClick():void
		{
			_conveyor.stop();
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(event:Event):void
		{
			stage.removeEventListener(MouseEvent.CLICK, onClick);
			_conveyor.play();
		}
		
		//}
	}
}