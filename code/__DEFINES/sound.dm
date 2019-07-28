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
#define VOL_LINEAR_TO_NON(vol_raw) ((20 ** Clamp(vol_raw * 0.01, 0, 1.0)) - 0.99) / (20 - 0.99) // this converts byond's linear volume into non linear (don't change anything without heavy testing with debug, even 0.01 difference may break the sound or functions that connects with this).
#define SANITIZE_VOL(vol) vol * 0.5 // environment setting can overload sound that use 100% volume (0.5 actually is max, if you want pure sound with anything).

//sound channels, max is 1024
#define CHANNEL_AMBIENT 1
#define CHANNEL_AMBIENT_LOOP 2
#define CHANNEL_MUSIC 3
#define CHANNEL_ADMIN 777
#define CHANNEL_ANNOUNCE 802
#define CHANNEL_VOLUMETEST 803


 /*-----------------------------------------------------*\
|                         SOUNDIN                         |
 \*-----------------------------------------------------*/

// ----- Effects ------
#define SOUNDIN_SHATTER   list('sound/effects/glassbr1.ogg', 'sound/effects/glassbr2.ogg', 'sound/effects/glassbr3.ogg')
#define SOUNDIN_EXPLOSION list('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg')
#define SOUNDIN_SPARKS    list('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg', 'sound/effects/sparks3.ogg', 'sound/effects/sparks4.ogg')
#define SOUNDIN_BODYFALL  list('sound/effects/bodyfall1.ogg', 'sound/effects/bodyfall2.ogg', 'sound/effects/bodyfall3.ogg', 'sound/effects/bodyfall4.ogg')
#define SOUNDIN_PAGETURN  list('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
#define SOUNDIN_PAGETURN  list('sound/effects/can_open1.ogg', 'sound/effects/can_open2.ogg', 'sound/effects/can_open3.ogg')
#define SOUNDIN_BONEBREAK list('sound/effects/bonebreak1.ogg', 'sound/effects/bonebreak2.ogg', 'sound/effects/bonebreak3.ogg', 'sound/effects/bonebreak4.ogg')
#define SOUNDIN_RUSTLE    list('sound/effects/rustle1.ogg', 'sound/effects/rustle2.ogg', 'sound/effects/rustle3.ogg', 'sound/effects/rustle4.ogg', 'sound/effects/rustle5.ogg')
// Footsteps
#define SOUNDIN_CLOWNSTEP list('sound/effects/clownstep1.ogg', 'sound/effects/clownstep2.ogg')
#define SOUNDIN_FOOTSTEPS list('sound/effects/tile1.wav', 'sound/effects/tile2.wav', 'sound/effects/tile3.wav', 'sound/effects/tile4.wav')

// ----- Voice -----
// Human's vomit
#define SOUNDIN_MALEVOMIT   list('sound/voice/mob/mvomit_1.ogg', 'sound/voice/mob/mvomit_2.ogg')
#define SOUNDIN_FEMALEVOMIT list('sound/voice/mob/fvomit_1.ogg', 'sound/voice/mob/fvomit_2.ogg')
#define SOUNDIN_FRIGVOMIT   list('sound/voice/mob/frigvomit_1.ogg', 'sound/voice/mob/frigvomit_2.ogg')
#define SOUNDIN_MRIGVOMIT   list('sound/voice/mob/mrigvomit_1.ogg', 'sound/voice/mob/mrigvomit_2.ogg')
// Human's emotes
#define SOUNDIN_FBCOUGH list('sound/voice/mob/fbcough_1.ogg', 'sound/voice/mob/fbcough_2.ogg', 'sound/voice/mob/fbcough_3.ogg')
#define SOUNDIN_MBCOUGH list('sound/voice/mob/mbcough_1.ogg', 'sound/voice/mob/mbcough_2.ogg', 'sound/voice/mob/mbcough_3.ogg')
#define SOUNDIN_FSCREAM list('sound/voice/mob/femalescream_1.ogg', 'sound/voice/mob/femalescream_2.ogg', 'sound/voice/mob/femalescream_3.ogg', 'sound/voice/mob/femalescream_4.ogg', 'sound/voice/mob/femalescream_5.ogg')
#define SOUNDIN_MSCREAM list('sound/voice/mob/malescream_1.ogg', 'sound/voice/mob/malescream_2.ogg', 'sound/voice/mob/malescream_3.ogg', 'sound/voice/mob/malescream_4.ogg', 'sound/voice/mob/malescream_5.ogg', 'sound/voice/mob/malescream_6.ogg', 'sound/voice/mob/malescream_7.ogg')
// Xenomorph's emotes
#define SOUNDIN_XENOMORPH_TALK  list('sound/voice/xenomorph/talk_1.ogg', 'sound/voice/xenomorph/talk_2.ogg', 'sound/voice/xenomorph/talk_3.ogg', 'sound/voice/xenomorph/talk_4.ogg')
#define SOUNDIN_XENOMORPH_ROAR  list('sound/voice/xenomorph/roar_1.ogg', 'sound/voice/xenomorph/roar_2.ogg')
#define SOUNDIN_XENOMORPH_HISS  list('sound/voice/xenomorph/hiss_1.ogg', 'sound/voice/xenomorph/hiss_2.ogg', 'sound/voice/xenomorph/hiss_3.ogg')
#define SOUNDIN_XENOMORPH_GROWL list('sound/voice/xenomorph/growl_1.ogg', 'sound/voice/xenomorph/growl_2.ogg')
// Beepsky
#define SOUNDIN_BEEPSKY list('sound/voice/beepsky/god.ogg', 'sound/voice/beepsky/iamthelaw.ogg', 'sound/voice/beepsky/secureday.ogg', 'sound/voice/beepsky/radio.ogg', 'sound/voice/beepsky/insult.ogg', 'sound/voice/beepsky/creep.ogg')

// ----- Misc -----
// Breath
#define SOUNDIN_RIGBREATH   list('sound/misc/rigbreath1.ogg', 'sound/misc/rigbreath2.ogg', 'sound/misc/rigbreath3.ogg')
#define SOUNDIN_BREATHMASK  list('sound/misc/breathmask1.ogg', 'sound/misc/breathmask2.ogg')
#define SOUNDIN_DESCERATION list('sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg')

// ----- Machines -----
// Keystroke
#define SOUNDIN_KEYBOARD list('sound/machines/keyboard/keyboard1.ogg', 'sound/machines/keyboard/keyboard2.ogg', 'sound/machines/keyboard/keyboard3.ogg', 'sound/machines/keyboard/keyboard4.ogg', 'sound/machines/keyboard/keyboard5.ogg')
// PDA's taps
#define SOUNDIN_PDA_TAPS list('sound/machines/keyboard/pda1.ogg', 'sound/machines/keyboard/pda2.ogg', 'sound/machines/keyboard/pda3.ogg', 'sound/machines/keyboard/pda4.ogg', 'sound/machines/keyboard/pda5.ogg')

// ----- Weapons -----
// Melee
#define SOUNDIN_GENHIT list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
#define SOUNDIN_PUNCH  list('sound/weapons/punch1.ogg', 'sound/weapons/punch2.ogg', 'sound/weapons/punch3.ogg', 'sound/weapons/punch4.ogg')

// ----- Items -----
// Medical
#define SOUNDIN_BANDAGE list('sound/items/bandage.ogg', 'sound/items/bandage2.ogg', 'sound/items/bandage3.ogg')
