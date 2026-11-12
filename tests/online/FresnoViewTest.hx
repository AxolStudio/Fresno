import desktop.DesktopOnlineLeaderboard;
class FresnoViewTest {
 static function check(v:Bool,s:String){if(!v)throw s;}
 static function main(){
  var rows=[{initials:"AAA",amount:12,id:1,position:1}];
  var view=new DesktopOnlineLeaderboard(rows,true,true,1);
  check(view.title()=="Local Scores","local first");
  check(view.update(0,{status:"ok",rows:[{initials:"BBB",amount:99,id:5,position:11}],lastId:5}),"remote arrives");
  check(view.rows()[0].position==11&&view.lastId()==5,"rank preserved");
  check(view.toggle()&&view.rows()[0].initials=="AAA","local retained");
  var late=new DesktopOnlineLeaderboard(rows,true,true,1);late.update(11,null);
  check(!late.update(0,{status:"ok",rows:rows,lastId:1})&&late.title()=="Local Scores","late ignored");
  var failed=new DesktopOnlineLeaderboard(rows,true,true,1);failed.update(0,{status:"failed",rows:[],lastId:-1});
  check(failed.status().indexOf("Unavailable")>=0,"failed local");
  failed.close();check(!failed.update(0,null),"closed");
  trace("Fresno view assertions passed");
 }
}
