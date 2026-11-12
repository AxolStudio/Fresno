package flixel.system.debug.log;
class BitmapLog {
 public var entries:Array<Int>=[1];
 public var index=0;
 public var cleared=false;
 public function new(){}
 public function clear():Void {
  entries.resize(0);
  drawCanvas();
 }
 function drawCanvas():Void {if(index>=0)throw 'retained bitmap-log index';cleared=true;}
}
