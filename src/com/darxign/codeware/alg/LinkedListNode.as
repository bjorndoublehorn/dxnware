package com.darxign.codeware.alg {
	/**
	*   A node in a linked list. Its purpose is to hold the data in the
	*   node as well as links to the previous and next nodes.
	*   @author Jackson Dunstan
	*/
	public class LinkedListNode
	{
		public var next:Object;
		public var prev:Object;
		public var data:*;
		public function LinkedListNode(data:*=undefined)
		{
			this.data = data;
		}
	}
}