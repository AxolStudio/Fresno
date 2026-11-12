#if macro
package desktop;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
/** Scoped compatibility for pinned Flixel 6.2.1; no vendored library edits. */
class DesktopCompatibility {
 public static function install():Void {
  Compiler.addGlobalMetadata("flixel.text.FlxBitmapText","@:build(desktop.DesktopCompatibility.bitmapText())",false,true,false);
  Compiler.addGlobalMetadata("flixel.system.debug.log.BitmapLog","@:build(desktop.DesktopCompatibility.bitmapLog())",false,true,false);
 }
 public static function bitmapText():Array<Field> {
  var fields=Context.getBuildFields();var found=false;
  for(field in fields)if(field.name=="checkPendingChanges")switch(field.kind){
   case FFun(fn):
    var body=fn.expr;
    fn.expr=macro {
     if(_desktopBitmapBusy)return;
     _desktopBitmapBusy=true;
     try $body catch(e:Dynamic){_desktopBitmapBusy=false;throw e;}
     _desktopBitmapBusy=false;
    };
    found=true;
   default:Context.error("Unexpected bitmap pending-changes method",field.pos);
  }
  if(!found)Context.error("Pinned bitmap pending-changes method missing",Context.currentPos());
  fields.push({name:"_desktopBitmapBusy",access:[APrivate],kind:FVar(macro:Bool,macro false),pos:Context.currentPos()});
  return fields;
 }
 public static function bitmapLog():Array<Field> {
  var fields=Context.getBuildFields();
  if(!Context.defined("FLX_DEBUG"))return fields;
  for(field in fields)if(field.name=="clear")switch(field.kind){
   case FFun(fn):switch(fn.expr.expr){
    case EBlock(expressions):
     if(expressions.length!=2||ExprTools.toString(expressions[0]).indexOf("entries.resize(0)")<0||ExprTools.toString(expressions[1]).indexOf("drawCanvas()")<0)
      Context.error("BitmapLog.clear changed; review desktop compatibility",field.pos);
     expressions.insert(1,macro index=-1);
    default:Context.error("Unexpected BitmapLog.clear body",field.pos);
   }
   default:
  }
  return fields;
 }
}
#end
