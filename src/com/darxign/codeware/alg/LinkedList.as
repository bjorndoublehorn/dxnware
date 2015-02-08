package com.darxign.codeware.alg {
	/**
	*   A linked list, which is a single-dimensional chain of objects called
	*   nodes. This implementation is doubly-linked, so each node has a link
	*   to the next and previous node. It's API is designed to mimic that of
	*   the top-level Array class.
	*   @author Jackson Dunstan
	*/
	public class LinkedList
	{
		public var head:LinkedListNode;
		public var tail:LinkedListNode;
		public var length:int;
 
		public function LinkedList(...values)
		{
			var len:int = this.length = values.length;
			var head:LinkedListNode = null;
			var newNode:LinkedListNode;
			var i:int;
 
			// Equivalent to Array(len)
			if (len == 1)
			{
				len = values[0];
				head = this.tail = newNode = new LinkedListNode();
				for (i = 1; i < len; ++i)
				{
					newNode = new LinkedListNode();
					newNode.next = head;
					head.prev = newNode;
					head = newNode;
				}
			}
			// Equivalent to Array(value0, value1, ..., valueN)
			else if (len > 1)
			{
				i = len-1;
				head = this.tail = newNode = new LinkedListNode(values[i--]);
				for (; i >= 0; --i)
				{
					newNode = new LinkedListNode(values[i]);
					newNode.next = head;
					head.prev = newNode;
					head = newNode;
				}
			}
			this.head = head;
		}
 
		public function push(...args): void
		{
			var numArgs:int = args.length;
			var arg:*;
			var newNode:LinkedListNode;
 
			for (var i:int = 0; i < numArgs; ++i)
			{
				arg = args[i];
				newNode = new LinkedListNode(arg);
				newNode.prev = this.tail;
				if (this.tail)
				{
					this.tail.next = newNode;
				}
				else
				{
					this.head = newNode;
				}
				this.tail = newNode;
			}
			this.length += numArgs;
		}
	}
}