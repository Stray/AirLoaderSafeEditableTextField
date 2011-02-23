package {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import skins.AirLoadedEditableTextFieldSkin;
	
	public class AirLoadedEditableTextField extends Sprite {

		public function AirLoadedEditableTextField() {
			addChild(new AirLoadedEditableTextFieldSkin.ProjectSprouts() as DisplayObject);
			trace("AirLoadedEditableTextField instantiated!");
		}
	}
}
