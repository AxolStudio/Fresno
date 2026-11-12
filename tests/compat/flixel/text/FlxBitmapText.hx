package flixel.text;
class FlxBitmapText {
 public var calls=0;
 public function new(){}
 public function checkPendingChanges(useTiles:Bool=false):Void {
  calls++;
  if(calls==1)checkPendingChanges(useTiles);
 }
}
