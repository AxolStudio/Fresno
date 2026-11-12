#if desktop
package desktop;
import desktop.DesktopOnlineClient.DesktopOnlineResult;
typedef DesktopLeaderboardRow=desktop.DesktopOnlineClient.DesktopOnlineRow;
/** Main-thread view model. Owns copies, never writes saved records or calls UI/network. */
class DesktopOnlineLeaderboard {
 final local:Array<DesktopLeaderboardRow>;
 var remote:Null<Array<DesktopLeaderboardRow>>;
 var online=false;
 var waiting:Bool;
 var active=true;
 var elapsed=0.0;
 final saved:Bool;
 final localId:Int;
 var remoteId=-1;
 public function lastId():Int return online?remoteId:localId;
 public function new(local:Array<DesktopLeaderboardRow>,pending:Bool,saved:Bool,localId:Int){
  this.localId=localId;this.local=copy(local);waiting=pending;this.saved=saved;
 }
 static function copy(rows:Array<DesktopLeaderboardRow>):Array<DesktopLeaderboardRow> return [for(r in rows){initials:r.initials,amount:r.amount,id:r.id,position:r.position}];
 public function rows():Array<DesktopLeaderboardRow> return copy(online?remote:local);
 public function title():String return online?"Online Scores":"Local Scores";
 public function status():String {
  if(remote!=null)return !saved?"Sent; local save failed":online?"Sent; Up/Down: Local":"Sent; Up/Down: Online";
  if(!saved)return "Local save failed";
  return waiting?"Online: Pending":"Online: Unavailable";
 }
 public function close():Void {active=false;waiting=false;}
 public function pending():Bool return active&&waiting;
 public function toggle():Bool {if(!active||remote==null)return false;online=!online;return true;}
 public function update(delta:Float,result:Null<DesktopOnlineResult>):Bool {
  if(!active||!waiting)return false;
  elapsed+=Math.max(0,delta);
  if(elapsed>=10){waiting=false;return true;}
  if(result==null)return false;
  waiting=false;
  if(result.status!="ok"||!Std.isOfType(result.rows,Array)||result.rows.length>11)return true;
  for(r in result.rows)if(r==null||!Std.isOfType(r.initials,String)||!~/^[ A-Z0-9!]{3}$/.match(r.initials)||!Std.isOfType(r.amount,Int)||r.amount<0||!Std.isOfType(r.id,Int)||r.id<1||!Std.isOfType(r.position,Int)||r.position<1)return true;
  remoteId=result.lastId;remote=copy(result.rows);online=true;return true;
 }
}
#end
