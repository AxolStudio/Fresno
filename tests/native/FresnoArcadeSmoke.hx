import globals.Game;
import globals.Actions;
import states.*;
import states.TitleState.Menu;
import states.PlayState.PauseSubState;
import states.GameWinState.HiScoreState;
import desktop.DesktopExit;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import openfl.events.KeyboardEvent;
/** Normal desktop boot/state loop; death and ending entry are explicitly fixture-seeded. */
class FresnoArcadeSmoke extends desktop.DesktopBoot {
 override public function create():Void {
  var driver=new FresnoSmokeDriver();FlxG.plugins.addPlugin(driver);
  try {driver.prepare();super.create();FlxG.autoPause=false;}catch(e:Dynamic)driver.fail(Std.string(e));
 }
}
@:access(objects.Player)
@:access(states.GameWinState)
@:access(states.GameWinState.HiScoreState)
@:access(states.TitleState.Menu)
@:access(states.PlayState)
@:access(flixel.FlxCamera)
@:access(flixel.input.gamepad.FlxGamepadManager)
@:access(flixel.input.gamepad.FlxGamepad)
private class FresnoSmokeDriver extends FlxBasic {
 var device:String;var output:String;var pad:FlxGamepad;
 var phase=0;var marked=-1;var started:Float;var phaseStarted:Float;var heartbeat=0.0;
 var held=false;var key:FlxKey;var button:FlxGamepadInputID;var done=false;
 var checks:Array<String>=[];
 var startY:Float;var distance:Float;var oldPlay:PlayState;var startLevel:Int;
 var holdFrames=0;var settle=0;
 public function new(){super();visible=false;device=Sys.getEnv("FRESNO_TEST_DEVICE");output=Sys.getEnv("FRESNO_TEST_RESULT");started=phaseStarted=haxe.Timer.stamp();}
 function require(ok:Bool,label:String):Void {if(!ok)throw label;}
 function pass(label:String):Void {checks.push(label);}
 public function prepare():Void {
  require(device=="keyboard"||device=="gamepad","unknown device");
  require(FlxG.fullscreen,"fullscreen startup");
  FlxG.random.initialSeed=271828;FlxG.keys.reset();pad=FlxG.gamepads.createByID(0,XINPUT);pad.reset();
  // FlxAction caches by outer-frame ticks. Dispatch between rendered frames,
  // never between catch-up fixed updates inside a rendered frame.
  FlxG.signals.postDraw.add(step);pass("fullscreen, deterministic random seed, synthetic hardware only");
 }
 function charCode(k:FlxKey):Int {var c:Int=cast k;return c>=65&&c<=90?c+32:0;}
 function pulse(k:FlxKey,b:FlxGamepadInputID):Void {
  require(!held,"overlapping pulse");key=k;button=b;
  if(device=="keyboard"){
   require(!FlxG.gamepads.anyButton(),"keyboard path used pad");
   FlxG.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN,true,false,charCode(k),k));
   require(FlxG.keys.checkStatus(k,PRESSED)||FlxG.keys.checkStatus(k,JUST_PRESSED),"key-down delivery "+Std.string(k));
  }else{
   require(FlxG.keys.firstPressed()==-1,"pad path used keyboard");pad.getButton(pad.mapping.getRawID(b)).press();
  }
  held=true;
 }
 function release():Void {
  if(device=="keyboard"){
   var before=FlxG.keys.checkStatus(key,PRESSED)||FlxG.keys.checkStatus(key,JUST_PRESSED);
   FlxG.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP,true,false,charCode(key),key));
   if(before)require(FlxG.keys.checkStatus(key,JUST_RELEASED),"key-up delivery "+Std.string(key));
  }else pad.getButton(pad.mapping.getRawID(button)).release();
  held=false;
 }
 function title():TitleState return Std.isOfType(FlxG.state,TitleState)?cast FlxG.state:null;
 function play():PlayState return Std.isOfType(FlxG.state,PlayState)?cast FlxG.state:null;
 function menu():Menu {var t=title();return t!=null&&Std.isOfType(t.subState,Menu)?cast t.subState:null;}
 function pause():PauseSubState {var p=play();return p!=null&&Std.isOfType(p.subState,PauseSubState)?cast p.subState:null;}
 function modal():flixel.FlxSubState {var s=FlxG.state.subState;if(s==null)return null;while(s.subState!=null)s=s.subState;return s;}
 function ready(s:Dynamic):Bool {
  if(s==null)return false;
  if(Reflect.hasField(s,"ready")&&Reflect.field(s,"ready")!=true)return false;
  var gate:Dynamic=Reflect.field(s,"desktopGate");
  return gate==null||Reflect.field(gate,"armed")==true;
 }
 function idle():Bool {var p=play();return p!=null&&p.ready&&p.gameStarted&&p.player.alive&&p.subState==null&&ready(p);}
 function chooseTitle(index:Int,next:Int):Void {
  var t=title();if(t==null)return;
  if(t.subState==null){if(ready(t))pulse(ENTER,A);return;}
  var m=menu();if(m==null||m.subState!=null||!ready(m))return;
  if(m.selected!=index)pulse(DOWN,DPAD_DOWN);else{pulse(ENTER,A);phase=next;}
 }
 function choosePause(index:Int,next:Int):Void {
  var p=pause();if(p==null||p.subState!=null||!ready(p))return;
  if(p.selected!=index)pulse(DOWN,DPAD_DOWN);else{pulse(ENTER,A);phase=next;}
 }
 function seedEnding():Void {
  Game.Scores=[0=>123,1=>456,2=>789];
  pass("fixture-seeded ending scores 123/456/789, not a completed playthrough");
  FlxG.switchState(()->new GameWinState());
 }
 function step():Void {
  if(done)return;
  try {
   if(marked!=phase){marked=phase;phaseStarted=haxe.Timer.stamp();sys.io.File.saveContent(output+".progress","phase "+phase);}
   if(haxe.Timer.stamp()-heartbeat>1){heartbeat=haxe.Timer.stamp();var s=modal();var p=play();
    sys.io.File.saveContent(output+".heartbeat",haxe.Json.stringify({phase:phase,state:Type.getClassName(Type.getClass(FlxG.state)),
     modal:s==null?"none":Type.getClassName(Type.getClass(s)),ready:Reflect.field(s==null?FlxG.state:s,"ready"),elapsed:heartbeat-started,
     selected:Reflect.field(s==null?FlxG.state:s,"selected"),ticks:FlxG.game.ticks,held:held,
     playerY:p==null?null:p.player.y,jumpHeight:p==null?null:p.player.jumpingHeight,distance:p==null?null:p.levelDistance}));
   }
   if(haxe.Timer.stamp()-started>285||haxe.Timer.stamp()-phaseStarted>45)throw "smoke timeout phase "+phase;
   if(held){if(holdFrames-->0)return;release();return;}
   if(phase==11){
    require(pause()!=null,"opening pause input must not auto-resume on release");
    require(play().levelDistance==distance,"pause freezes actual parent progression");
   }
   if(settle-->0)return;
   switch(phase){
    case 0:chooseTitle(1,1);
    case 1:
     if(Std.isOfType(FlxG.state,HowToPlayState)&&ready(FlxG.state)){pass("title Help opens by device");pulse(ESCAPE,B);phase=2;}
    case 2:chooseTitle(2,3);
    case 3:
     if(Std.isOfType(FlxG.state,CreditsState)&&ready(FlxG.state)){pass("Help back and Credits route by device");pulse(ESCAPE,B);phase=4;}
    case 4:chooseTitle(0,5);
    case 5:
     if(idle()){pass("Play initializes actual gameplay");startY=play().player.y;distance=play().levelDistance;pulse(DOWN,DPAD_DOWN);holdFrames=5;phase=6;}
    case 6:
     if(play().player.y>startY&&play().levelDistance>distance){pass("device moves live player down while level advances");startY=play().player.y;pulse(UP,DPAD_UP);holdFrames=5;phase=7;}
    case 7:
     if(play().player.y<startY){pass("device moves live player up");pulse(SPACE,A);holdFrames=5;phase=8;}
    case 8:
     if(play().player.jumpingHeight>0){pass("device jump raises live player");phase=9;}
    case 9:
     if(play().player.jumpingHeight==0&&!Actions.jump.triggered){pass("released jump returns player to ground");pulse(P,START);phase=10;}
    case 10:
     if(pause()!=null&&ready(pause())){require(pause().selected==0,"pause defaults Resume");pass("pause opens by device");distance=play().levelDistance;settle=10;phase=11;}
    case 11:
     require(play().levelDistance==distance,"pause freezes actual parent progression");pulse(ESCAPE,B);phase=12;
    case 12:
     if(idle()&&play().levelDistance>distance){pass("Back closes pause and resumes real progression");oldPlay=play();startLevel=Game.CurrentLevel;pulse(P,START);phase=13;}
    case 13:choosePause(1,14);
    case 14:
     if(idle()&&play()!=oldPlay){require(Game.CurrentLevel==startLevel,"restart preserves selected level");require(play().player.score==0,"restart resets player score");pass("Restart initializes a fresh same-level PlayState");oldPlay=play();
      // Exercise the production hurt/death tween/reset chain, not a claimed earned death.
      play().player.hurt(999);require(!play().player.alive,"fixture damage enters production death");pass("fixture-seeded fatal damage, real automatic death retry");phase=15;}
    case 15:
     if(idle()&&play()!=oldPlay){require(Game.CurrentLevel==startLevel,"death retry preserves level");require(play().player.alive&&play().player.score==0,"death retry resets live player");pass("production death animation automatically restarts gameplay");pulse(P,START);phase=16;}
    case 16:choosePause(3,17);
    case 17:
     if(Std.isOfType(modal(),DesktopExit)&&ready(modal())){var e:DesktopExit=cast modal();require(e.choice.selected==0,"pause Exit defaults Cancel");pulse(ESCAPE,B);phase=18;}
    case 18:
     if(pause()!=null&&pause().subState==null&&ready(pause())){pass("Exit cancel preserves pause parent");phase=19;}
    case 19:choosePause(2,20);
    case 20:
     if(title()!=null&&ready(title())){pass("pause Main Menu returns real title");seedEnding();phase=21;}
    case 21:
     if(Std.isOfType(FlxG.state,GameWinState)&&ready(FlxG.state)){pulse(ESCAPE,B);phase=22;}
    case 22:
     if(title()!=null&&ready(title())){pass("ending Back returns title without network");seedEnding();phase=23;}
    case 23:
     if(Std.isOfType(FlxG.state,GameWinState)&&ready(FlxG.state)){
      var e:GameWinState=cast FlxG.state;
      if(!e.scoresShown){pulse(ENTER,A);settle=10;}
      else {require(e.whichInit==0,"initials start at first slot");pulse(DOWN,DPAD_DOWN);phase=24;}
     }
    case 24:
     var e:GameWinState=cast FlxG.state;if(e.initVals[0]==1){pulse(RIGHT,DPAD_RIGHT);phase=25;}
    case 25:
     var e:GameWinState=cast FlxG.state;if(e.whichInit==1){pulse(DOWN,DPAD_DOWN);phase=26;}
    case 26:
     var e:GameWinState=cast FlxG.state;if(e.initVals[1]==1){pulse(RIGHT,DPAD_RIGHT);phase=27;}
    case 27:
     var e:GameWinState=cast FlxG.state;if(e.whichInit==2){pulse(DOWN,DPAD_DOWN);phase=28;}
    case 28:
     var e:GameWinState=cast FlxG.state;if(e.initVals[2]==1){pass("all three ending initials edited by device");pulse(RIGHT,DPAD_RIGHT);phase=29;}
    case 29:
     var e:GameWinState=cast FlxG.state;if(e.whichInit==3){pulse(ENTER,A);phase=30;}
    case 30:
     if(Std.isOfType(modal(),HiScoreState)&&ready(modal())){
      var rows=desktop.DesktopOnlineLocal.rows;
      require(desktop.DesktopOnlineLocal.saved,"local score flush succeeds in isolated test storage");
      require(rows.length==1&&rows[0].initials=="AAA"&&rows[0].amount==1368&&rows[0].position==1,"exact local ending score and initials recorded once");
      require(Game.RememberInits.join(",")=="1,1,1","ending remembers edited initials in session");
      pass("offline ending submission saves exact AAA/1368 once and opens local leaderboard");pulse(ESCAPE,B);phase=31;
     }
    case 31:chooseTitle(3,32);
    case 32:
     if(Std.isOfType(modal(),DesktopExit)&&ready(modal())){var e:DesktopExit=cast modal();require(e.choice.selected==0,"title Exit defaults Cancel");pulse(RIGHT,DPAD_RIGHT);phase=33;}
    case 33:
     var e:DesktopExit=cast modal();if(e.choice.selected==1){pass("device deliberately selects actual OS Exit");write(true,true,null);pulse(ENTER,A);phase=34;}
    case 34: // Production Exit alone may terminate successfully.
    default:throw "unknown phase "+phase;
   }
  }catch(e:Dynamic)fail(Std.string(e)+"\n"+haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
 }
 function write(passed:Bool,exitRequested:Bool,error:Null<String>):Void {
  sys.io.File.saveContent(output,haxe.Json.stringify({schema:1,mode:"real-loop-smoke",device:device,passed:passed,exitRequested:exitRequested,error:error,checks:checks,
   finalState:{phase:phase,state:Type.getClassName(Type.getClass(FlxG.state)),
    modal:modal()==null?"none":Type.getClassName(Type.getClass(modal())),
    distance:play()==null?null:play().levelDistance,pausedDistance:distance,
    accept:Actions.pressUI.triggered,pause:Actions.pause.triggered,pauseHeld:Actions.pauseHeld.triggered,held:held},
   notVerified:["physical controller and hotplug","cabinet focus","live network services","full gameplay completion; fatal damage and ending are explicitly fixture-seeded"]},null,"  "));
 }
 public function fail(error:String):Void {done=true;write(false,false,error);Sys.exit(1);}
}
