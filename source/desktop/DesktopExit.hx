#if desktop
package desktop;
import flixel.FlxG;
import flixel.FlxSubState;
import globals.Actions;
import ui.NormalText;
import ui.Frame;
/** Exit only after explicit confirmation; Cancel is always initial focus. */
class DesktopExit extends FlxSubState {
 public var desktopGate=new DesktopGate();
 public var choice=new DesktopExitChoice();
 var labels:Array<NormalText>;
 var pending=-1;
 public function new(){super(0xdd3a3a50);}
 override public function create():Void {
  super.create();
  var frame=new Frame(220,64);frame.screenCenter();frame.scrollFactor.set();add(frame);
  var title=new NormalText("Quit to Launcher?");title.screenCenter();title.y=frame.y+8;title.scrollFactor.set();add(title);
  labels=[new NormalText("CANCEL"),new NormalText("QUIT")];
  for(i in 0...2){labels[i].x=frame.x+24+i*112;labels[i].y=frame.y+40;labels[i].scrollFactor.set();add(labels[i]);}
  paint();
 }
 function paint():Void {for(i in 0...2)labels[i].color=i==choice.selected?0xff63b556:0xff3a3a50;}
 override public function update(elapsed:Float):Void {
  super.update(elapsed);
  if(!DesktopControls.allow(desktopGate))return;
  if(pending>=0){if(DesktopControls.neutral()){if(pending==1)openfl.system.System.exit(0);else close();}return;}
  if(Actions.backUI.triggered)pending=0;
  else if(Actions.leftUI.triggered||Actions.rightUI.triggered||Actions.upUI.triggered||Actions.downUI.triggered){choice.move();paint();}
  else if(Actions.pressUI.triggered)pending=choice.selected;
 }
}
#end
