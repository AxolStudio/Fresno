import desktop.DesktopOnlineClient;
class FresnoOnlineTest {
 static function check(v:Bool,label:String) {if(!v)throw label;}
 static function main(){
  var jobs:Array<Void->Void>=[];var requests=0;
  var rows=[for(i in 0...12){id:Std.string(i+1),position:Std.string(i+1),initials:"AAA",amount:Std.string(100-i)}];
  var response=haxe.Json.stringify({status:200,data:{scores:{scores:rows,lastId:"12"}}});
  var c=new DesktopOnlineClient((path,body)->{requests++;return response;},job->jobs.push(job),()->1000);
  check(c.start("test",()->null,_ ->true,()->"12345678-1234-1234-1234-123456789abc"),"start");
  jobs.shift()();var token=c.submitScore(100,"AAA");check(c.takeResult(token)==null,"pending");jobs.shift()();
  var result=c.takeResult(token);check(result.status=="ok","ok");check(result.rows.length==11,"top ten plus own");
  check(result.rows[10].id==12&&result.rows[10].position==12&&result.lastId==12,"own ranking retained");
  response='{"status":200,"data":{"scores":{"scores":[{"id":"x","position":1,"initials":"AAA","amount":1}],"lastId":1}}}';
  token=c.submitScore(1,"AAA");jobs.shift()();check(c.takeResult(token).status=="failed","malformed rejected");
  check(requests==3,"no retry");
  trace("Fresno online contract assertions passed");
 }
}
