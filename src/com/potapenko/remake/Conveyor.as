package com.potapenko.remake {
	import flash.events.Event;
	import flash.events.EventDispatcher;

	[Event(name="complete", type="flash.events.Event")]
	public class Conveyor extends EventDispatcher {
		private var _head:Node;
		private var _tail:Node;
		private var _playing:Boolean = false;
		private var _callbackCalling:Boolean = false;
		private var _bookmarks:Array;

		public function Conveyor() {
			// Создание головы и хвоста и неиспользование их для хранения данных уменьшает
			// количество условной логики для работы с добавлением и удалением элементов из списка
			init();
		}

		private function init():void {
			_bookmarks = [];
			_head = new Node();
			_tail = new Node();
			_head.next = _tail;
			_tail.prev = _head;
		}

		/**
		 * @param    callback
		 * @param    ...args - аргументы функции callback
		 */
		public function add(callback:Function, ...args:Array):void {
			privateAdd(callback, args);
		}

		/**
		 * То же что и add, но добавленные задачи внутри задачи, запущенной функцией callback,
		 * будут выполнены сразу после завершения данной, а не после завершения всех остальных
		 * @param    callback
		 * @param    ...args - аргументы функции callback
		 */
		public function addInclude(callback:Function, ...args:Array):void {
			privateAdd(addBookmark, null);
			privateAdd(callback, args);
			privateAdd(removeBookmark, null);
		}

		public function play():void {
			if (_playing) {
				return;
			}
			_playing = true;
			if (_callbackCalling) {
				return;
			}
			var node:Node;
			while (true) {
				node = _head.next;
				if (node == _tail) {
					break;
				}
				node.prev.next = node.next;
				node.next.prev = node.prev;
				node.next = null;
				node.prev = null;
				_callbackCalling = true;
				node.callback.apply(null, node.args);
				_callbackCalling = false;
				if (!_playing) {
					return;
				}
			}
			if (hasEventListener(Event.COMPLETE)) {
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		public function stop():void {
			_playing = false;
		}

		private function privateAdd(callback:Function, args:Array):void {
			var node:Node = new Node();
			node.callback = callback;
			node.args = args;
			_tail.prev.next = node;
			node.prev = _tail.prev;
			_tail.prev = node;
			node.next = _tail;
		}

		private function addBookmark():void {
			var node:Node = new Node();
			_tail.prev.next = node;
			node.prev = _tail.prev;
			_tail.prev = node;
			node.next = _tail;
			_bookmarks.push(node);
		}

		private function removeBookmark():void {
			// Переносим все что после закладки на начало списка.
			// Строчек, конечно, многовато, но зато выполняется за время O(1),
			// т.е. не зависит от количества элементов
			var node:Node = _bookmarks.pop();
			var leftTail:Node = node.prev;
			var rightHead:Node = node.next;
			node.prev.next = node.next;
			node.next.prev = node.prev;
			node.prev = null;
			node.next = null;
			if (leftTail != _head && rightHead != _tail) {
				var rightTail:Node = _tail.prev;
				var leftHead:Node = _head.next;
				rightHead.prev = _head;
				_head.next = rightHead;
				rightTail.next = leftHead;
				leftHead.prev = rightTail;
				leftTail.next = _tail;
				_tail.prev = leftTail;
			}
		}

		public function stopAndClean():void {
			stop();
			init();
			_callbackCalling = false;
		}
	}
}
class Node {
	public function Node() {
	}

	public var prev:Node;
	public var next:Node;
	public var callback:Function;
	public var args:Array;
}