package trailmix.runtime;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import openfl.media.Sound;

abstract Bitfield(UInt)
{
	inline public function new(i0 : UInt) { this = i0; }
	inline public function g(idx : UInt) { return (this >> idx) & 1 > 0; }
	inline public function t(idx : UInt) { this = this | (1 << idx); }
	inline public function f(idx : UInt) { this = this & ~(1 << idx); }
	inline public function array() { return [for (i0 in 0...32) g(i0)]; }
}

abstract TextId(Int) { inline public function new(i0 : Int) { this = i0; }}
abstract ItemId(Int) { inline public function new(i0 : Int) { this = i0; }}
abstract BodyId(Int) { inline public function new(i0 : Int) { this = i0; }}
abstract SceneId(Int) { inline public function new(i0 : Int) { this = i0; }}
abstract IntId(Int) { inline public function new(i0 : Int) { this = i0; }}
abstract AlgorithmId(Int) { inline public function new(i0 : Int) { this = i0; }}
abstract ItArchetypeId(Int) { inline public function new(i0 : Int) { this = i0; }}
abstract AlArchetypeId(Int) { inline public function new(i0 : Int) { this = i0; }}
abstract BitfieldId(Int) { inline public function new(i0 : Int) { this = i0; }}
abstract ImageId(Int) { inline public function new(i0 : Int) { this = i0; }}
abstract SFXId(Int) { inline public function new(i0 : Int) { this = i0; }}
abstract BGMId(Int) { inline public function new(i0 : Int) { this = i0; }}

class Image
{
	public var id : ImageId;
	public var variants : Array<BitmapData>;
	public var source : String;
	public function new(id, variants, source) 
	{ this.id = id; this.variants = variants; this.source = source; }
	public function toString():String { return source; }
}

class SFX
{
	public var id : SFXId;
	public var data : Sound;
	public var source : String;
	public function new(id, data, source) 
	{ this.id = id; this.data = data; this.source = source; }
	public function toString():String { return source; }
}

class BGM
{
	public var id : BGMId;
	public var data : Sound;
	public var source : String;
	public function new(id, data, source) 
	{ this.id = id; this.data = data; this.source = source; }
	public function toString():String { return source; }
}

class Text
{
	public var id : TextId;
	public var variants : Array<Array<String>>; /* locale [ variant(e.g. pronoun) [ text ]] */
	public var source : String;
	public function new(id : TextId, variants : Array<Array<String>>, source : String) 
	{ this.id = id; this.variants = variants; this.source = source; }
	public function toString():String { return source; }
}

class Body
{
	public var id : BodyId;
	public var variants : Array<Array<Int>>; /* locale [ array of parsable int tuples ] */
	public var source : String;
	public function new(id, variants, source) 
	{ this.id = id; this.variants = variants; this.source = source; }
	public function toString() { return source; }
}

class IntData
{
	public var i : IntId; /* id */
	public var v : Int; /* value */
	public var n : TextId; /* name */
	public function new(i, v, n) { this.i = i; this.v = v; this.n = n; }
}

class BitfieldData
{
	public var i : BitfieldId; /* id */
	public var v : Bitfield; /* value */
	public var n : TextId; /* name */
	public function new(i, v, n) { this.i = i; this.v = v; this.n = n; }
}

class ReferenceData
{
	public var intd : Array<IntId>;
	public var flagd : Array<BitfieldId>;
	public var textd : Array<TextId>;
	public var itemd : Array<ItemId>;
	public var algod : Array<AlgorithmId>;
	public var bodyd : Array<BodyId>;
	public function new(intd, textd, itemd, algod, bodyd, flagd) {
		this.intd = intd; this.textd = textd; this.itemd = itemd; 
		this.algod = algod; this.bodyd = bodyd; this.flagd = flagd;			
	}
}

class Algorithm
{
	public var id : AlgorithmId;
	public var arch : AlArchetypeId;
	public var source : String;
	public var ref : ReferenceData;
	public function new(id, arch, source, ref) { this.id = id; this.arch = arch; 
		this.source = source; this.ref = ref; }
}

class Item
{
	public var id : ItemId;
	public var arch : ItArchetypeId;
	public var source : String;
	public var ref : ReferenceData;
	public function new(id, arch, source, ref) 
	{ this.id = id; this.arch = arch; this.ref = ref; this.source = source; }
}

/* there are a pile of assumptions here. 
 * 
 * To make the game loop go, we need:
 * 
 * working tick model
 * working distance per tick model
 * 
 * definition of "party" item
 * display of party
 * 		stats
 * 		party-global values
 * 
 * "Party" is therefore an item containing the party members,
 * 		tick, and position.
 * 		Each character is an item containing
 * 			intdata of health, starvation, sickness values
 * 			flags of dead/aliveness
 * 
 * Our gamestate will be run by pushing and popping a stack of ItemIds.
 * The items have archetypes that indicate which thing it is.
 * 
 * We do a ton of "switch on this archetype variant", of course.
 * 
 * So a play stack might look like this:
 * 
 * main menu item (menu archetype)
 * 		when active, displays the bodyd data for the menu options...
 * 		upon selecting a choice, runs the algorithm of the appropriate child algod, then pushes the context of the appropriate child itemd.
 * 
 * 		gameplay item (gameplay archetype)
 * 		when active, displays the landscape and party readout by recursing into the various items for each.
 * 			each tick, runs an algorithm.
 * 
 * I think we can manage to do this.
 * Everything is kept at sufficient indirection that we can extend this indefinitely.
 * Yet we can provide the defaults necessary to make it powerful for an Oregon Trail demo.
 * 
 * The only thing we really "hard code" is what archetypes mean at each point.
 * It's a programming language, and we expose it in such a way that it's not terrible to extend.
 * All of our effort is really going towards the compiler aspect of it - the runtime shouldn't be too hard.
 * 
 * Our compiler will specify some defaults(data entry, locale conventions, etc.), and the runtime will specify other defaults(audiovisuals, input)
 * For now our compiler will be very targeted around making an Oregon Trail style English language game, even though the runtime will be far more capable than that.
 * 
 * "variants" indicates which localization is going to be used, where it's relevant.
 * We can expand on this with localizable images etc, although i don't have anything for image data yet...
 * Animations and FSM stuff can be done by compiling to Ivy code (although in the case of FSMs it may be easier to describe hardcoded algorithms first.)
 * 
 * Plans for runtime asset support
 * 
 * 1. FLAC, OGG Vorbis audio
 * 2. WebP images
 * 
 * These have decoder implementations available. They are already in some use. They don't have patenting issues.
 * I can compile everything else out to them without too much effort.
 * 
 * The bundling/preloader aspect shouldn't too terrible because I can offload that to OpenFL. What my code gets is a big binary blob, which it unpacks.
 * 
 * Plans for runtime rendering and I/O
 * 
 * 1. Bitmap display
 * 2. Multichannel audio triggers
 * 3. Click and drag mouse/touch inputs
 * 4. Textfield input
 * 
 * */

class Main extends Sprite 
{
	var inited:Bool;

	/* ENTRY POINT */
	
	function resize(e) { if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return; inited = true;

		{ /* START RUNTIME */
		}
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
