#if desktop
package desktop;
import flixel.util.FlxSave;
import desktop.DesktopOnlineClient.DesktopOnlineRow;
/** Separate desktop records; never touches another platform's data. Main thread only. */
class DesktopOnlineLocal {
 static var save:FlxSave;
 static var bound=false;
 public static var saved(default,null)=false;
 public static var rows(default,null):Array<DesktopOnlineRow>=[];
 public static var lastId(default,null)=0;
 public static function initialize():Void {
  if(save!=null)return;
  save=new FlxSave();
  try {
   #if arcade_regression
   if(!save.bind("Fresno-arcade-test-"+Sys.getEnv("FRESNO_TEST_DEVICE"),"axolstudio-tests"))return;
   bound=true;rows=[];lastId=0;
   #else
   if(!save.bind("Fresno-desktop-scores-v1","axolstudio"))return;
   bound=true;
   if(Std.isOfType(save.data.serial,Int)&&save.data.serial>0&&save.data.serial<2147483647)lastId=save.data.serial;
   if(Std.isOfType(save.data.rows,Array)) {
    var loaded:Array<Dynamic>=save.data.rows;
    for(r in loaded)if(rows.length<10&&r!=null&&Std.isOfType(r.initials,String)&&~/^[ A-Z0-9!]{3}$/.match(r.initials)&&Std.isOfType(r.amount,Int)&&r.amount>=0&&Std.isOfType(r.id,Int)&&r.id>0){
     rows.push({initials:r.initials,amount:r.amount,id:r.id,position:rows.length+1});if(r.id>lastId)lastId=r.id;
    }
   }
   #end
  }catch(_:Dynamic){}
 }
 public static function record(amount:Int,initials:String):Void {
  initialize();lastId++;
  rows.push({initials:initials,amount:amount,id:lastId,position:0});
  rows.sort((a,b)->a.amount==b.amount?b.id-a.id:(a.amount>b.amount?-1:1));
  for(i in 0...rows.length)rows[i].position=i+1;
  var own=rows.filter(r->r.id==lastId)[0];
  rows=rows.slice(0,10);if(own!=null&&own.position>10)rows.push(own);
  saved=false;
  if(!bound)return;
  try {save.data.rows=rows.slice(0,10);save.data.serial=lastId;saved=save.flush();}catch(_:Dynamic){}
 }
}
#end
