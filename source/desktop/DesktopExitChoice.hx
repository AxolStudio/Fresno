#if desktop
package desktop;
class DesktopExitChoice {
 public var selected(default,null)=0;
 public function new(){}
 public function move():Void {selected=1-selected;}
}
#end
