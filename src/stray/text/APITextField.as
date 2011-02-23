package stray.text {
	
	import flash.text.TextField;
	import flash.events.EventDispatcher;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.events.Event;
	
	public class APITextField extends EventDispatcher {
						
		protected var _subjectTextField:TextField;
		
		protected var _restrict:String;
		
		protected var _currentIndex:int;
		
		protected var _keyCodeActionReference:Dictionary;
		
		public function APITextField(subjectTextField:TextField) {
			_subjectTextField = subjectTextField;
			_subjectTextField.addEventListener(Event.CHANGE, dispatchChange);
			_currentIndex = 0;   
			_restrict = "";
			createKeyCodeActionReference();
		}
		
		public function get restrict():String
		{
			return _restrict;
		}

		public function set restrict(value:String):void
		{
		    _restrict = value;
		}
		
		public function acceptCharCode(charCode:int):void
		{                                     
			var newChar:String = String.fromCharCode(charCode);  

			if(isRestricted(newChar))
			{
				return;
			}

			var textWas:Array = text.split();
			textWas.splice(_currentIndex,0, newChar);
			text = textWas.join("");
			
			_currentIndex+=1;
			dispatchChange();
		}   
		
		public function acceptKeyCode(keyCode:int):void
		{
			if(_keyCodeActionReference[keyCode] != null)
			{
				_keyCodeActionReference[keyCode]();
			}
		}
		
		public function acceptCharAndKeyCodes(charCode:int, keyCode:int):void
		{
			trace("APITextField::acceptCharAndKeyCodes()", charCode, keyCode);
			if((charCode == 0)||(charCode == 8))
			{
				acceptKeyCode(keyCode);
			}                           
			else
			{
				acceptCharCode(charCode);
			}
		}

		public function get text():String
		{
			return _subjectTextField.text;
		}   
		
		public function set text(txt:String):void
		{
			_subjectTextField.text = txt;
		} 
		
		protected function createKeyCodeActionReference():void
		{
			_keyCodeActionReference = new Dictionary();
			_keyCodeActionReference[Keyboard.BACKSPACE] = backspace;
			_keyCodeActionReference[Keyboard.LEFT] = left;
			_keyCodeActionReference[Keyboard.RIGHT] = right;
			_keyCodeActionReference[Keyboard.DELETE] = del;
		}                                                             
		
		protected function backspace():void
		{
			trace("APITextField::backspace()");
			if(_currentIndex > 0)
			{
				var textWas:Array = text.split("");  
				textWas.splice(_currentIndex-1, 1);
				text = textWas.join(""); 
				_currentIndex-=1; 
				dispatchChange();
			}
		}
		
		protected function left():void
		{
			_currentIndex = Math.max(0, _currentIndex-1);
		}
		
		protected function right():void
		{
			_currentIndex = Math.min(text.length-1, _currentIndex+1);
		}
		
		protected function del():void
		{
			if(_currentIndex < text.length-1)
			{
				var textWas:Array = text.split("");  
				textWas.splice(_currentIndex, 1);
				text = textWas.join("");
				dispatchChange();
			}
		}   
		
		protected function isRestricted(char:String):Boolean
		{
			if(_restrict == "")
			{
				return false;
			}
			
			if(_restrict.indexOf(char) > -1)
			{
				return false;
			}               
			
			return true;
		}
		
		protected function dispatchChange(e:Event = null):void
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}