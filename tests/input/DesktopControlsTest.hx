import desktop.DesktopGate;
class DesktopControlsTest {
 static var n=0;static function check(v:Bool,s:String){n++;if(!v)throw s;}
 static function main(){
  var g=new DesktopGate();check(!g.update(1,false),"held entry blocked");check(!g.armed,"entry disarmed");
  check(!g.update(2,true)&&g.armed,"neutral arms but not activates");check(!g.update(2,false),"same render tick cannot activate after arming");
  check(g.update(3,false),"new tick accepts fresh action");check(!g.update(3,false),"cached action only once per render tick");
  g.reset();check(!g.update(4,false),"modal return held input blocked");g.update(5,true);check(g.update(6,false),"released return rearmed");
  var choice=new desktop.DesktopExitChoice();check(choice.selected==0,"Exit defaults Cancel");
  choice.move();check(choice.selected==1,"deliberate Quit selection");choice.move();check(choice.selected==0,"navigation can return to Cancel");
  trace(n+" desktop modal/tick assertions passed");
 }
}
