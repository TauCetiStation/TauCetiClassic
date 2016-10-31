//Languages!
#define LANGUAGE_HUMAN		1
#define LANGUAGE_ALIEN		2
#define LANGUAGE_DOG		4
#define LANGUAGE_CAT		8
#define LANGUAGE_BINARY		16
#define LANGUAGE_OTHER		32768

#define LANGUAGE_UNIVERSAL	65535

//Language flags.
#define WHITELISTED 1  		// Language is available if the speaker is whitelisted.
#define RESTRICTED 	2   	// Language can only be accquired by spawning or an admin.
#define NONVERBAL 	4    	// Language has a significant non-verbal component. Speech is garbled without line-of-sight
#define SIGNLANG 	8     	// Language is completely non-verbal. Speech is displayed through emotes for those who can understand.