package axollib;

import haxe.Http;
import haxe.Json;
import haxe.crypto.Sha1;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import openfl.utils.Object;

using StringTools;
#if flash
import flash.system.Security;
#end


class AxolAPI {
	public static inline var VERSION:String = "2.0";

	public static inline var URL:String = "https://axolstudio.com/api/" + VERSION;

	public static var gameID:String = "";

	public static var playerID:String = "";

	public static var initialized:Bool = false;

	public static var firstState:Class<FlxState>;

	private static var Save:FlxSave;

	private static var Packets:Map<String, APIPacket>;

	private static var Timer:FlxTimer;

	public static var LoggedIn:Bool = false;

	public static var UserNo:Int = -1;

	public static var User:UserData;

	public static var init:Void->Void= null;

	static public function initialize(GameID:String = "", ?PlayerID:String = ""):Void {
		if (initialized)
			return;
		initialized = true;

		gameID = GameID;

		if (PlayerID == "")
			PlayerID = generateGUID();
		#if flash
		Security.allowDomain("axolstudio.com");
		Security.allowInsecureDomain("axolstudio.com");
		#end
		
		initSave(PlayerID);
		
		Packets = new Map<String, APIPacket>();

		Timer = new FlxTimer().start(.5, checkData, 0);

		//FlxG.camera.pixelPerfectRender = true;
	}

	public static function initSave(PlayerID:String = "", ?UseSave:FlxSave):Void {
		playerID = PlayerID;
		User = null;
		UserNo = -1;
		LoggedIn = false;

		if (UseSave == null) {
			Save = new FlxSave();
			Save.bind(gameID + playerID);
		} else
			Save = UseSave;

		if (Save.data.packets != null) {
			Packets = Save.data.packets;
		}

		Save.flush();
	}

	public static function generateGUID():String {
		var uid = new StringBuf(), a = 8;
		uid.add(StringTools.hex(Std.parseInt(getDate()), 8));
		while ((a++) < 36) {
			uid.add(a * 51 & 52 != 0 ? StringTools.hex(a ^ 15 != 0 ? 8 ^ Std.int(Math.random() * (a ^ 20 != 0 ? 16 : 4)) : 4) : "-");
		}
		return uid.toString().toLowerCase();
	}

	static private function sendData(P:APIPacket):Void {
	#if !hl
	#if (target.threaded)
	sys.thread.Thread.create(() -> {
	#end
		var url:String = URL + "/" + P.action + "/" + P.object + "?ref=" + Date.now().getTime();
		var h:Http = new Http(url);
		h.setHeader("Content-Type", "application/json; charset=utf-8");
		h.onError = onError.bind(_, P.ID, h.responseData);
		h.onData = onData.bind(_, P.ID);
		h.onStatus = onStatus.bind(_, P.ID);
		P.packetStatus = SENDING;
		P.timeSent = Std.parseInt(getDate());
		h.setPostData(P.data);
		//h.async = true;
		h.request(true);
	#if (target.threaded)
	});
	#end
	#end
}

static private function onStatus(Status:Int, PacketID:String):Void {
	trace(Status);
}

static private function onError(Msg:String, PacketID:String, R:Null<String>):Void {
#if !hl
#if (target.threaded)
sys.thread.Thread.create(() -> {
#end
	var p:APIPacket = Packets.get(PacketID);
	p.packetStatus = ERRORED;
	trace("API Data Error", Msg, p, R);
	if (Msg.endsWith("#451"))
		FlxG.switchState(new Blocked());
#if (target.threaded)
});
#end
#end
}

static public function logout():Void {
#if !hl
#if (target.threaded)
sys.thread.Thread.create(() -> {
#end
UserNo = -1;
User = null;
Save.data.jwt = null;
Save.data.user = null;
LoggedIn = false;
Save.flush();
#if (target.threaded)
});
#end
#end
}

static private function onData(Data:String, PacketID:String):Void {
#if !hl
#if (target.threaded)
sys.thread.Thread.create(() -> {
#end
var p:APIPacket = Packets.get(PacketID);
if (p == null)
return;
p.packetStatus = SENT;

var data:Response = null;
try {
data = Json.parse(Data);
} catch (e:Dynamic) {
trace("Error Parsing Data", e, Data);
}

if (data != null) {
if (data.status == 200) {
	if (data.data != null) {
		if (data.data.user != null) {
			UserNo = data.data.user.user_id;
			Save.data.user = data.data.user;
			User = cast data.data.user;
		}
		if (data.data.jwt != null) {
			Save.data.jwt = data.data.jwt;
			LoggedIn = true;
		}
		Save.flush();
	}
} 
else if (data.status == 451)
{
	FlxG.switchState(new Blocked());
} else {
	trace("API Data Error", data, p);
}
}

if (p.callback != null)
p.callback(data);

Packets.remove(p.ID);
#if (target.threaded)
});
#end
#end
}

static public function login(U:String, P:String, ?Callback:String->Void = null):Void {
#if !hl
#if (target.threaded)
sys.thread.Thread.create(() -> {
#end
var p:APIPacket = new APIPacket();
p.action = "login";
p.object = "user";
p.callback = Callback;
p.data = Json.stringify({username: U, password: Sha1.encode(P)});
p.usesData = true;
addPacket(p);
#if (target.threaded)
});
#end
#end
}

static public function checkUser(K:String, ?Callback:String->Void = null):Void {
#if !hl
#if (target.threaded)
sys.thread.Thread.create(() -> {
#end
var p:APIPacket = new APIPacket();
p.action = "check";
p.object = "user";
p.callback = Callback;
p.data = Json.stringify({token: K});
p.usesData = true;
addPacket(p);
#if (target.threaded)
});
#end
#end
}

static public function getScores(Callback:String->Void):Void {
#if !hl
#if (target.threaded)
sys.thread.Thread.create(() -> {
#end
var p:APIPacket = new APIPacket();
p.action = "get";
p.object = "scores";
p.callback = Callback;
p.usesData = true;
p.data = Json.stringify({game_id: gameID});
addPacket(p);
#if (target.threaded)
});
#end
#end
}

static public function sendScore(Amount:Int, Initials:String, Callback:String->Void):Void {
#if !hl
#if (target.threaded)
sys.thread.Thread.create(() -> {
#end
trace("sending!");
var p:APIPacket = new APIPacket();
p.action = "set";
p.object = "scores";
p.callback = Callback;
p.data = Json.stringify({game_id: gameID, amount: Amount, initials: Initials});
addPacket(p);
#if (target.threaded)
});
#end
#else
if (Callback != null)
Callback(null);
#end
}

static private function addPacket(P:APIPacket):Void {
Packets.set(P.ID, P);
sendData(P);
}

static private function checkData(_):Void {
if (!initialized)
return;

for (p in Packets) {
if ((p.packetStatus == SENDING && p.timeSent + 60000 >= Std.parseInt(getDate())) || p.packetStatus != SENT) {
// we need to send this packet!
sendData(p);
}
}
}

static public function sendAchieve(PA:APIPlayerAchieve, Callback:String->APIPlayerAchieve->Void):Void {
#if !hl
#if (target.threaded)
sys.thread.Thread.create(() -> {
#end
var p:APIPacket = new APIPacket();
p.action = "give-achieve";
p.object = "user";
p.callback = Callback.bind(_, PA);
p.data = Json.stringify({
token: Save.data.jwt,
user_id: UserNo,
game_id: gameID,
achieve_id: PA.ID,
earned: PA.earned
});
addPacket(p);
#if (target.threaded)
});
#end
#end
}

static public function sendEvent(EventName:String, Value:Float = 0):Void {
	trace("Event: " + EventName + " :: " + Value);
#if !hl
#if (target.threaded)
sys.thread.Thread.create(() -> {
#end
var p:APIPacket = new APIPacket();
p.action = "add";
p.object = "event";
var pID:String = playerID;
#if debug
pID = "D-" + pID;
#end

p.data = Json.stringify({
event_time: getDate(),
event_name: EventName,
player_id: pID,
game_id: gameID,
value: Value
});
addPacket(p);
#if (target.threaded)
});
#end
#end
}

static public function sendDeath(Room:Int, X:Int, Y:Int):Void {
#if !hl
#if (target.threaded)
sys.thread.Thread.create(() -> {
#end
var p:APIPacket = new APIPacket();
p.action = "add";
p.object = "death";
var pID:String = playerID;
#if debug
pID = "D-" + pID;
#end

p.data = Json.stringify({
death_time: getDate(),
player_id: pID,
game_id: gameID,
room: Room,
x_pos: X,
y_pos: Y
});
addPacket(p);
#if (target.threaded)
});
#end
#end
}

public static function getDate(?D:Date):String {
var d:Date;
if (D == null) {
d = Date.now();
} else {
d = D;
}
return Std.string(d.getTime()).substr(0, 10);
}
}


typedef UserData = {
	public var user_id:Int;
	public var username:String;
	public var email:String;
	public var lastactive:String;
	public var active:Bool;
	public var allow_emails:Bool;
	public var allow_news:Bool;
	public var g_token:String;
	public var avatar:String;
	public var achievements:Array<AchievementData>;
	public var games:Dynamic;
	public var error:String;
}

typedef AchievementData = {
	public var game_id:Int;
	public var achieve_id:Int;
	public var name:String;
	public var description:String;
	public var image:String;
	public var earned:Float;
}

typedef GameData = {
	public var id:Int;
	public var name:String;
	public var icon:String;
	public var key:String;
}

typedef Response = {
	public var status:Int;
	public var status_message:String;
	public var data:ResponseData;
}

typedef ResponseData = {
	public var user:UserData;
	public var jwt:Object;
}

class APIPacket {
	public var ID:String;
	public var action:String = "";
	public var object:String = "";
	public var data:String = "";
	public var packetStatus:APIPacketStatus = UNSENT;
	public var timeSent:Int = -1;
	public var callback:Dynamic->Void = null;

	public var usesData:Bool = false;

	public function new() {
		ID = AxolAPI.generateGUID();
	}
}

enum abstract APIPacketStatus(Int) {
	var UNSENT = 0;
	var SENDING = 1;
	var SENT = 2;
	var ERRORED = 3;
}

class APIPlayerAchieve {
	public var ID:Int;
	public var earned:Float;
	public var confirmed:Bool;

	public function new() {}
}
