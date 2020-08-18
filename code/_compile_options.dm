#define DEBUG					//Enables byond profiling and full runtime logs - note, this may also be defined in your .dme file
								//Enables in-depth debug messages to runtime log (used for debugging)
//#define TESTING				//By using the testing("message") proc you can create debug-feedback for people with this
								//uncommented, but not visible in the release version)

#define BACKGROUND_ENABLED 0    // The default value for all uses of set background. Set background can cause gradual lag and is recommended you only turn this on if necessary.
								// 1 will enable set background. 0 will disable set background.

//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN       1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_BOOK_MESSAGE_LEN  9216
#define MAX_NAME_LEN          26
#define MAX_LNAME_LEN         64

//#define NEWYEARCONTENT		// Closets use this to spawn items like santa clothes. // TODO: convert this to holiday event?

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 513
#if DM_VERSION < MIN_COMPILER_VERSION
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 513 or higher
#endif
