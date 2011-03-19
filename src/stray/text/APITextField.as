package stray.text {
	
	import flash.text.TextField;
	import flash.events.EventDispatcher;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class APITextField extends EventDispatcher {
						
		protected var _subjectTextField:TextField;
		protected var _restrict:String;
		protected var _currentIndex:int;
		protected var _keyCodeActionReference:Dictionary;
		protected var _cursorTimer:Timer;
		protected var _cursor:Sprite;
		protected var _cursorHolder:Sprite;
		
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
            
			var textWas:Array = text.split("");
			textWas.splice(_currentIndex,0, newChar); 
		   
			text = textWas.join("");
			
			_currentIndex+=1;
			dispatchChange(); 
			updateCursor();
		}   
		
		public function acceptKeyCode(keyCode:int):void
		{
			if(_keyCodeActionReference[keyCode] != null)
			{
				_keyCodeActionReference[keyCode]();
			}
			updateCursor();
		}
		
		public function acceptCharAndKeyCodes(charCode:int, keyCode:int):void
		{
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

		public function get fakeCursor():Boolean
		{
			return (_cursor != null);
		}

		public function set fakeCursor(value:Boolean):void
		{
			if (value === fakeCursor)
			{   
				return;
			}

			if(value)
			{
				createCursor();
			}
			else
			{
				destroyCursor();
			}
		}           
		
		protected function createCursor():void
		{
			if(_cursorTimer == null)
			{
				_cursorTimer = new Timer(400);
			}
			_cursorTimer.addEventListener(TimerEvent.TIMER, flashCursor);
			_cursorTimer.start();
		   	drawCursor();
		}	
		
		protected function destroyCursor():void
		{               
			if(_subjectTextField.parent.contains(_cursorHolder))
			{
				_subjectTextField.parent.removeChild(_cursorHolder);
			}                                             
			
			if(_cursorTimer != null)
			{
				_cursorTimer.removeEventListener(TimerEvent.TIMER, flashCursor);
				_cursorTimer.stop();                                            
			}
			
			_cursor = null;
			_cursorHolder = null;
		}
		
		protected function drawCursor():void
		{                                                          
			createCursorGraphics();
			
			_cursor.graphics.lineStyle(0, _subjectTextField.textColor); 
			// add a character if required, in order to get textHeight
			if(_subjectTextField.text == "")
			{
				_subjectTextField.text = "|";
			}
			
			_cursor.graphics.lineTo(0, _subjectTextField.textHeight);
			
			if(_subjectTextField.text == "|")
			{
				_subjectTextField.text = "";
			}
		}	  
		
		protected function createCursorGraphics():void
		{
			_cursorHolder = new Sprite();
			_cursorHolder.x = _subjectTextField.x;
			_cursorHolder.y = _subjectTextField.y;

			_cursor = new Sprite();
			
			_cursorHolder.addChild(_cursor);
			
			_subjectTextField.parent.addChild(_cursorHolder);
		}                   
		
		protected function flashCursor(e:TimerEvent):void
		{
			_cursor.visible = !_cursor.visible;
		}
		
		protected function updateCursor():void
		{   
			if(_cursor == null)
			{
				return;
			}
			
			var charBoundaries:Rectangle;
			                                                     
			if(_subjectTextField.text.length == 0)
			{
				_cursor.x = 0;
			}
			else if(_subjectTextField.text.length == _currentIndex)
			{
				charBoundaries = _subjectTextField.getCharBoundaries((_currentIndex-1));
				_cursor.x = (charBoundaries.x + charBoundaries.width)
			}  
			else
			{               
				charBoundaries = _subjectTextField.getCharBoundaries((_currentIndex));
				_cursor.x = charBoundaries.x
			}
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
			_currentIndex = Math.min(text.length, _currentIndex+1);
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