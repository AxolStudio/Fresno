package flixel.util;
class FlxSave {
 public static var allowBind=true;
 public static var allowFlush=true;
 public static var flushes=0;
 public var data:Dynamic={};
 public function new(){}
 public function bind(name:String,path:String):Bool return allowBind;
 public function flush():Bool {flushes++;return allowFlush;}
}
