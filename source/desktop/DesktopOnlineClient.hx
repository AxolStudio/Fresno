#if desktop
package desktop;
import sys.thread.Mutex;
typedef DesktopOnlineRow={initials:String,amount:Int,id:Int,position:Int};
typedef DesktopOnlineResult={status:String,rows:Array<DesktopOnlineRow>,lastId:Int};
/** Only immutable serialized requests/results cross the worker boundary. */
class DesktopOnlineClient {
 final session=new DesktopOnlineSession();
 final dispatcher:DesktopOnlineDispatcher;
 final request:(String,String)->String;
 final now:Void->Float;
 final mutex=new Mutex();
 final completions:Array<{token:String,json:String}>=[];
 var key="";
 var serial=0;
 public var ready(get,never):Bool;
 function get_ready():Bool return session.started;
 public function new(request:(String,String)->String,schedule:(Void->Void)->Void,now:Void->Float){
  this.request=request;this.now=now;dispatcher=new DesktopOnlineDispatcher(run,schedule);
 }
 public function start(key:String,read:Void->Null<String>,persist:String->Bool,generate:Void->String):Bool {
  return session.start(key,read,persist,generate,()->{this.key=key;sendEvent("Game:Event:Launch");});
 }
 public function sendEvent(name:String,value:Float=0):Void {
  var body=session.payload(name,value,now());
  if(body!=null)dispatcher.offer(haxe.Json.stringify({path:"add/event",body:body,token:""}));
 }
 public function submitScore(amount:Int,initials:String):String {
  var token="score-"+(++serial);
  if(!ready || amount<0 || initials==null || !~/^[ A-Z0-9!]{3}$/.match(initials)){
   complete(token,"unavailable",[]);return token;
  }
  var body=haxe.Json.stringify({game_id:key,amount:amount,initials:initials});
  if(!dispatcher.offer(haxe.Json.stringify({path:"set/scores",body:body,token:token})))complete(token,"unavailable",[]);
  return token;
 }
 public function takeResult(token:String):Null<DesktopOnlineResult> {
  var json:String=null;
  mutex.acquire();
  for(i in 0...completions.length)if(completions[i].token==token){json=completions.splice(i,1)[0].json;break;}
  mutex.release();
  return json==null?null:cast haxe.Json.parse(json);
 }
 function complete(token:String,status:String,rows:Array<DesktopOnlineRow>,lastId:Int=-1):Void {
  var json=haxe.Json.stringify({status:status,rows:rows,lastId:lastId});
  mutex.acquire();if(completions.length>=16)completions.shift();completions.push({token:token,json:json});mutex.release();
 }
 function run(job:String):Void {
  var item:Dynamic=haxe.Json.parse(job);
  try {
   var body=request(item.path,item.body);
   if(item.token!=""){var result=parseScores(body);complete(item.token,"ok",result.rows,result.lastId);}
  }catch(_:Dynamic){if(item.token!="")complete(item.token,"failed",[]);}
 }
 static function positive(value:Dynamic,zero:Bool=false):Int {
  var text=Std.string(value);
  if(!~/^[0-9]{1,10}$/.match(text))throw "Invalid score number";
  var number=Std.parseFloat(text);
  if(number>2147483647 || (!zero&&number==0))throw "Score number out of range";
  return Std.int(number);
 }
 static function parseScores(body:String):DesktopOnlineResult {
  if(body==null || body.length>65536)throw "Invalid online response";
  var envelope:Dynamic=haxe.Json.parse(body);
  if(envelope==null || envelope.status!=200 || envelope.data==null || envelope.data.scores==null || !Std.isOfType(envelope.data.scores.scores,Array))throw "Invalid online scores";
  var input:Array<Dynamic>=envelope.data.scores.scores;
  if(input.length>1000)throw "Too many score rows";
  var lastId=positive(envelope.data.scores.lastId);
  var rows:Array<DesktopOnlineRow>=[];
  var own:DesktopOnlineRow=null;
  for(row in input){
   if(row==null || !Std.isOfType(row.initials,String) || !~/^[ A-Z0-9!]{3}$/.match(row.initials))throw "Invalid initials";
   var valid:DesktopOnlineRow={initials:row.initials,amount:positive(row.amount,true),id:positive(row.id),position:positive(row.position)};
   if(rows.length<10)rows.push(valid);else if(valid.id==lastId)own=valid;
  }
  if(own!=null)rows.push(own);
  return {status:"ok",rows:rows,lastId:lastId};
 }
}
#end
