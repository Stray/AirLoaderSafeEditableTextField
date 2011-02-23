package stray.text {

	import asunit.framework.TestCase;
	import flash.text.TextField;
	import flash.events.KeyboardEvent;
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import asunit.errors.AssertionFailedError;

	public class APITextFieldTest extends TestCase {
		private var instance:APITextField; 
		
		private var subjectTextField:TextField;

		public function APITextFieldTest(methodName:String=null) {
			super(methodName)
		}

		override protected function setUp():void {
			super.setUp();                              
			subjectTextField = new TextField();
			instance = new APITextField(subjectTextField);
		}

		override protected function tearDown():void {
			super.tearDown();
			instance = null;
		}

		public function testInstantiated():void {
			assertTrue("instance is APITextField", instance is APITextField);
		}

		public function testFailure():void {
			assertTrue("Failing test", true);
		}     
		
		public function test_adding_charCodes_only():void {
			
			instance.text = "";
			
			var input:String = "Dog";
			
			instance.acceptCharCode(input.charCodeAt(0));
			instance.acceptCharCode(input.charCodeAt(1));
			instance.acceptCharCode(input.charCodeAt(2));
			
			assertEquals("Text input has been assembled in order", input, instance.text);
		}     
		
		public function test_adding_charCodes_and_keyCodes():void {
			instance.text = "";
			
			instance.acceptCharAndKeyCodes("I".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("t".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes(" ".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("W".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("W".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("o".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("r".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes(0, Keyboard.LEFT);
			instance.acceptCharAndKeyCodes(0, Keyboard.LEFT);
			instance.acceptCharAndKeyCodes(0, Keyboard.BACKSPACE);
			instance.acceptCharAndKeyCodes(0, Keyboard.RIGHT);
			instance.acceptCharAndKeyCodes(0, Keyboard.RIGHT);
			instance.acceptCharAndKeyCodes("k".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("s".charCodeAt(0), 0);
			
			assertEquals("Text input has been assembled in order", 'It Works', instance.text);
		}
		
		public function test_forward_deletions():void {
			instance.text = "";
			
			instance.acceptCharAndKeyCodes("I".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("t".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes(" ".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("W".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("W".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("o".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("r".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes(0, Keyboard.LEFT);
			instance.acceptCharAndKeyCodes(0, Keyboard.LEFT);
			instance.acceptCharAndKeyCodes(0, Keyboard.LEFT);
			instance.acceptCharAndKeyCodes(0, Keyboard.DELETE);
			instance.acceptCharAndKeyCodes(0, Keyboard.RIGHT);
			instance.acceptCharAndKeyCodes(0, Keyboard.RIGHT);
			instance.acceptCharAndKeyCodes(0, Keyboard.RIGHT);
			instance.acceptCharAndKeyCodes("k".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("s".charCodeAt(0), 0);
			
			assertEquals("Text input has been assembled in order", 'It Works', instance.text);
		}  
		
		public function test_restrictions():void {
		    instance.text = '';
			instance.restrict = '0123456789';
			
			instance.acceptCharAndKeyCodes("1".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("t".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("2".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("a".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("3".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("C".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("4".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("k".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("5".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("Z".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("6".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("~".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("7".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("q".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("8".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("T".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("9".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes(" ".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("0".charCodeAt(0), 0);
			instance.acceptCharAndKeyCodes("!".charCodeAt(0), 0);
			
			assertEquals("Text input has excluded restricted chars", '1234567890', instance.text);
		}
		
		public function test_entering_text_dispatches_change():void {
			var handler:Function = addAsync(check_entering_text_dispatches_change, 50);
			instance.addEventListener(Event.CHANGE, handler);
			
			instance.acceptCharCode("A".charCodeAt(0));
		}

		private function check_entering_text_dispatches_change(e:Event):void {
			assertEquals('event is correct type', Event.CHANGE, e.type);
		}  
		
		public function test_deleting_text_dispatches_change():void {
			instance.acceptCharCode("A".charCodeAt(0));
			
			var handler:Function = addAsync(check_deleting_text_dispatches_change, 50);
			instance.addEventListener(Event.CHANGE, handler);
			instance.acceptCharAndKeyCodes(0, Keyboard.BACKSPACE);
		}

		private function check_deleting_text_dispatches_change(e:Event):void {
			assertEquals('event is correct type', Event.CHANGE, e.type);
			
		}
		
		public function test_backspace_doesnt_fire_change_if_nothing_to_delete():void {
			var handler:Function = addAsync(fail_if_change_fires, 50, change_shouldnt_fire);
			instance.addEventListener(Event.CHANGE, handler);
			instance.acceptCharAndKeyCodes(0, Keyboard.BACKSPACE);
		}    
		
		private function fail_if_change_fires(e:Event):void
		{
			try {
            	assertTrue("this change handler shouldn't have fired", false);
			}
			catch(assertionFailedError:AssertionFailedError) {
				getResult().addFailure(this, assertionFailedError);
			}
		}
		
		private function change_shouldnt_fire(e:Event):void
		{
			// no problem
		}
		
		
 		public function test_keycodes():void {
			var keyChild:Sprite= new Sprite();
			addChild(keyChild);
			keyChild.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}                                                            
		
		protected function keyDownHandler(e:KeyboardEvent):void
		{
			trace(e.toString());
		}
		
		
	}
}