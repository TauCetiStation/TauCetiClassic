/*
	The possible ways of meme spreading.
*/
#define MEME_SPREAD_VERBALLY "meme_spread_verbally"         // Meme is spread by speaking it out loud.
	#define MEME_TEXT_ALLOW_CUSTOM "meme_text_allow_custom" // Whether the meme allows to write custom text when "sharing" it.
	#define MEME_TEXT_KEYWORD "meme_text_keyword"           // Whether the meme will search and replace all %meme% in the text with it's name.
	#define MEME_FORCE_SPREAD_VERBALLY "meme_force_spread_verbally" // Whether the host will spread the meme verbally with anything they say.

#define MEME_SPREAD_INSPECTION "meme_spread_inspection"       // Meme is spread if object is examined.
	#define MEME_PREVENT_INSPECTION "meme_prevent_inspection" // This meme will prevent examination of the thing it is attached to.

#define MEME_SPREAD_READING "meme_spread_reading"             // Basically MEME_SPREAD_INSPECTION, but works only for /obj/item/weapon/paper
	#define MEME_STAR_TEXT "meme_jumble_text"                 // If meme is present, the text on paper will always appear starred(unreadable).

#define MEME_SPREAD_VISUAL "meme_spread_visual"            // The photo of a meme is a meme.

/*
	Various meme categories that are displayed
	when the player browses known memes.
*/
#define MEME_CATEGORY_MEME "Meme"
#define MEME_CATEGORY_MEMORY "Memory"
#define MEME_CATEGORY_COUNTERMEME "Countermeme"

/*
	How a meme stacks.
*/
#define MEME_STACK_KEEP_BOTH "keep_both" // Will not even call on_stack.
#define MEME_STACK_KEEP_OLD "keep_old"   // Will try to stack old meme with new. Default behaviour will qdel the new meme.
#define MEME_STACK_KEEP_NEW "keep_new"   // Will try to stack new meme with old. Default behaviour will qdel the old meme.

/*
	How this counter meme behaves.
*/
#define MEME_COUNTER_ALL "@All" // A very magic unique counter_id that would counter all meme instances.

#define MEME_COUNTER_SPREAD 1        // This countermeme prevents host from spreading the meme, but not receiving, and being affected by it.
#define MEME_COUNTER_WHILE_PRESENT 2 // This countermeme does not prevent, and or delete meme instances, only prevents them affecting the host.
#define MEME_COUNTER_DESTROY 4       // This countermeme deletes all counter instances, as well as prevent new ones piling on.
