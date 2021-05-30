//volume channels for client's volume sliders.
#define VOL_MUSIC (1<<0) // lobby.
#define VOL_AMBIENT (1<<1) // ambient music/environment sounds.

#define VOL_EFFECTS_MASTER (1<<2) // anything that doesn't go into sub categories (this acts as a master channel for all subs of this type).
//effects sub categories (VOL_EFFECTS_MASTER included, so that we don't need to type it everytime when we want to use just a sub category).
#define VOL_EFFECTS_VOICE_ANNOUNCEMENT (VOL_EFFECTS_MASTER | 1<<3) // voiced global announcements.
#define VOL_EFFECTS_MISC (VOL_EFFECTS_MASTER | 1<<4) // for any sound that may annoy players (like tesla engine).
#define VOL_EFFECTS_INSTRUMENT (VOL_EFFECTS_MASTER | 1<<5) // music instruments! actually this could be merged into spam category.

#define VOL_NOTIFICATIONS (1<<6) // mainly for ghosts, such as cloning ready, admin pm, etc.
#define VOL_ADMIN (1<<7) // admin sounds or music (fun category).

// jukebox not a VOL_MUSIC sub category because jukebox plays thru javascript, which is not boynd's sound datum.
#define VOL_JUKEBOX (1<<8)

//Misc
#define VOL_LINEAR_TO_NON(vol_raw) ((20 ** clamp(vol_raw * 0.01, 0, 1.0)) - 0.99) / (20 - 0.99) // this converts byond's linear volume into non linear (don't change anything without heavy testing with debug, even 0.01 difference may break the sound or functions that connects with this).
#define SANITIZE_VOL(vol) vol * 0.5 // environment setting can overload sound that use 100% volume (0.5 actually is max, if you want pure sound with anything).

//sound channels, max is 1024
#define CHANNEL_AMBIENT 1
#define CHANNEL_AMBIENT_LOOP 2
#define CHANNEL_MUSIC 3
#define CHANNEL_ADMIN 777
#define CHANNEL_ANNOUNCE 802
#define CHANNEL_VOLUMETEST 803
