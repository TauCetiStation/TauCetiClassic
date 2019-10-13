// ----- Effects ------
var/global/list/SOUNDIN_SHATTER   = list('sound/effects/glassbr1.ogg', 'sound/effects/glassbr2.ogg', 'sound/effects/glassbr3.ogg')
var/global/list/SOUNDIN_EXPLOSION = list('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg')
var/global/list/SOUNDIN_SPARKS    = list('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg', 'sound/effects/sparks3.ogg', 'sound/effects/sparks4.ogg')
var/global/list/SOUNDIN_BODYFALL  = list('sound/effects/bodyfall1.ogg', 'sound/effects/bodyfall2.ogg', 'sound/effects/bodyfall3.ogg', 'sound/effects/bodyfall4.ogg')
var/global/list/SOUNDIN_PAGETURN  = list('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
var/global/list/SOUNDIN_CAN_OPEN  = list('sound/effects/can_open1.ogg', 'sound/effects/can_open2.ogg', 'sound/effects/can_open3.ogg')
var/global/list/SOUNDIN_BONEBREAK = list('sound/effects/bonebreak1.ogg', 'sound/effects/bonebreak2.ogg', 'sound/effects/bonebreak3.ogg', 'sound/effects/bonebreak4.ogg')
var/global/list/SOUNDIN_RUSTLE    = list('sound/effects/rustle1.ogg', 'sound/effects/rustle2.ogg', 'sound/effects/rustle3.ogg', 'sound/effects/rustle4.ogg', 'sound/effects/rustle5.ogg')
// Footsteps
var/global/list/SOUNDIN_CLOWNSTEP = list('sound/effects/clownstep1.ogg', 'sound/effects/clownstep2.ogg')
var/global/list/SOUNDIN_FOOTSTEPS = list('sound/effects/tile1.wav', 'sound/effects/tile2.wav', 'sound/effects/tile3.wav', 'sound/effects/tile4.wav')
// Projectiles' acts
var/global/list/SOUNDIN_BULLETACT     = list('sound/effects/projectiles_acts/bullet_1.ogg', 'sound/effects/projectiles_acts/bullet_2.ogg', 'sound/effects/projectiles_acts/bullet_3.ogg')
var/global/list/SOUNDIN_LASERACT      = list('sound/effects/projectiles_acts/laser_1.ogg', 'sound/effects/projectiles_acts/laser_2.ogg', 'sound/effects/projectiles_acts/laser_2.ogg')
var/global/list/SOUNDIN_ACIDACT       = list('sound/effects/projectiles_acts/acid_1.ogg', 'sound/effects/projectiles_acts/acid_2.ogg', 'sound/effects/projectiles_acts/acid_3.ogg')
var/global/list/SOUNDIN_WEAKBULLETACT = list('sound/effects/projectiles_acts/weakbullet_1.ogg', 'sound/effects/projectiles_acts/weakbullet_2.ogg', 'sound/effects/projectiles_acts/weakbullet_3.ogg')
var/global/list/SOUNDIN_BULLETMISSACT = list('sound/effects/projectiles_acts/miss_1.ogg', 'sound/effects/projectiles_acts/miss_2.ogg', 'sound/effects/projectiles_acts/miss_3.ogg', 'sound/effects/projectiles_acts/miss_4.ogg')

// ----- Voice -----
// Human's vomit
var/global/list/SOUNDIN_MALEVOMIT   = list('sound/voice/mob/mvomit_1.ogg', 'sound/voice/mob/mvomit_2.ogg')
var/global/list/SOUNDIN_FEMALEVOMIT = list('sound/voice/mob/fvomit_1.ogg', 'sound/voice/mob/fvomit_2.ogg')
var/global/list/SOUNDIN_FRIGVOMIT   = list('sound/voice/mob/frigvomit_1.ogg', 'sound/voice/mob/frigvomit_2.ogg')
var/global/list/SOUNDIN_MRIGVOMIT   = list('sound/voice/mob/mrigvomit_1.ogg', 'sound/voice/mob/mrigvomit_2.ogg')
// Human's emotes
var/global/list/SOUNDIN_FBCOUGH = list('sound/voice/mob/fbcough_1.ogg', 'sound/voice/mob/fbcough_2.ogg', 'sound/voice/mob/fbcough_3.ogg')
var/global/list/SOUNDIN_MBCOUGH = list('sound/voice/mob/mbcough_1.ogg', 'sound/voice/mob/mbcough_2.ogg', 'sound/voice/mob/mbcough_3.ogg')
// Human's pain
var/global/list/SOUNDIN_FEMALE_LIGHT_PAIN   = list('sound/voice/mob/pain/female/light_1.ogg', 'sound/voice/mob/pain/female/light_2.ogg', 'sound/voice/mob/pain/female/light_3.ogg', 'sound/voice/mob/pain/female/light_4.ogg', 'sound/voice/mob/pain/female/light_5.ogg', 'sound/voice/mob/pain/female/light_6.ogg', 'sound/voice/mob/pain/female/light_7.ogg', 'sound/voice/mob/pain/female/light_8.ogg')
var/global/list/SOUNDIN_FEMALE_HEAVY_PAIN   = list('sound/voice/mob/pain/female/heavy_1.ogg', 'sound/voice/mob/pain/female/heavy_2.ogg', 'sound/voice/mob/pain/female/heavy_3.ogg', 'sound/voice/mob/pain/female/heavy_4.ogg', 'sound/voice/mob/pain/female/heavy_5.ogg', 'sound/voice/mob/pain/female/heavy_6.ogg')
var/global/list/SOUNDIN_FEMALE_PASSIVE_PAIN = list('sound/voice/mob/pain/female/passive_1.ogg', 'sound/voice/mob/pain/female/passive_2.ogg', 'sound/voice/mob/pain/female/passive_3.ogg', 'sound/voice/mob/pain/female/passive_4.ogg', 'sound/voice/mob/pain/female/passive_5.ogg', 'sound/voice/mob/pain/female/passive_6.ogg')
var/global/list/SOUNDIN_FEMALE_WHINER_PAIN  = list('sound/voice/mob/pain/female/passive_whiner_1.ogg', 'sound/voice/mob/pain/female/passive_whiner_2.ogg', 'sound/voice/mob/pain/female/passive_whiner_3.ogg', 'sound/voice/mob/pain/female/passive_whiner_4.ogg', 'sound/voice/mob/pain/female/passive_whiner_5.ogg', 'sound/voice/mob/pain/female/passive_whiner_6.ogg')
var/global/list/SOUNDIN_MALE_LIGHT_PAIN     = list('sound/voice/mob/pain/male/light_1.ogg', 'sound/voice/mob/pain/male/light_2.ogg', 'sound/voice/mob/pain/male/light_3.ogg', 'sound/voice/mob/pain/male/light_4.ogg', 'sound/voice/mob/pain/male/light_5.ogg', 'sound/voice/mob/pain/male/light_6.ogg', 'sound/voice/mob/pain/male/light_7.ogg', 'sound/voice/mob/pain/male/light_8.ogg')
var/global/list/SOUNDIN_MALE_HEAVY_PAIN     = list('sound/voice/mob/pain/male/heavy_1.ogg', 'sound/voice/mob/pain/male/heavy_2.ogg', 'sound/voice/mob/pain/male/heavy_3.ogg', 'sound/voice/mob/pain/male/heavy_4.ogg', 'sound/voice/mob/pain/male/heavy_5.ogg', 'sound/voice/mob/pain/male/heavy_6.ogg', 'sound/voice/mob/pain/male/heavy_7.ogg', 'sound/voice/mob/pain/male/heavy_8.ogg')
var/global/list/SOUNDIN_MALE_PASSIVE_PAIN   = list('sound/voice/mob/pain/male/passive_1.ogg', 'sound/voice/mob/pain/male/passive_2.ogg', 'sound/voice/mob/pain/male/passive_3.ogg', 'sound/voice/mob/pain/male/passive_4.ogg', 'sound/voice/mob/pain/male/passive_5.ogg')
var/global/list/SOUNDIN_MALE_WHINER_PAIN    = list('sound/voice/mob/pain/male/passive_whiner_1.ogg', 'sound/voice/mob/pain/male/passive_whiner_2.ogg', 'sound/voice/mob/pain/male/passive_whiner_3.ogg', 'sound/voice/mob/pain/male/passive_whiner_4.ogg')
// Xenomorph's emotes
var/global/list/SOUNDIN_XENOMORPH_TALK  = list('sound/voice/xenomorph/talk_1.ogg', 'sound/voice/xenomorph/talk_2.ogg', 'sound/voice/xenomorph/talk_3.ogg', 'sound/voice/xenomorph/talk_4.ogg')
var/global/list/SOUNDIN_XENOMORPH_ROAR  = list('sound/voice/xenomorph/roar_1.ogg', 'sound/voice/xenomorph/roar_2.ogg')
var/global/list/SOUNDIN_XENOMORPH_HISS  = list('sound/voice/xenomorph/hiss_1.ogg', 'sound/voice/xenomorph/hiss_2.ogg', 'sound/voice/xenomorph/hiss_3.ogg')
var/global/list/SOUNDIN_XENOMORPH_GROWL = list('sound/voice/xenomorph/growl_1.ogg', 'sound/voice/xenomorph/growl_2.ogg')
// Beepsky
var/global/list/SOUNDIN_BEEPSKY = list('sound/voice/beepsky/god.ogg', 'sound/voice/beepsky/iamthelaw.ogg', 'sound/voice/beepsky/secureday.ogg', 'sound/voice/beepsky/radio.ogg', 'sound/voice/beepsky/insult.ogg', 'sound/voice/beepsky/creep.ogg')

// ----- Misc -----
var/global/list/SOUNDIN_SCARYSOUNDS = list('sound/weapons/thudswoosh.ogg', 'sound/weapons/guns/gunpulse_Taser.ogg', 'sound/weapons/armbomb.ogg', 'sound/voice/xenomorph/hiss_1.ogg', 'sound/voice/xenomorph/hiss_2.ogg', 'sound/voice/xenomorph/hiss_3.ogg', 'sound/voice/xenomorph/growl_1.ogg', 'sound/voice/xenomorph/growl_2.ogg', 'sound/effects/Glassbr1.ogg', 'sound/effects/Glassbr2.ogg', 'sound/effects/Glassbr3.ogg', 'sound/items/Welder.ogg', 'sound/items/Welder2.ogg','sound/machines/airlock/toggle.ogg', 'sound/effects/clownstep1.ogg', 'sound/effects/clownstep2.ogg')
// Breath
var/global/list/SOUNDIN_RIGBREATH   = list('sound/misc/rigbreath1.ogg', 'sound/misc/rigbreath2.ogg', 'sound/misc/rigbreath3.ogg')
var/global/list/SOUNDIN_BREATHMASK  = list('sound/misc/breathmask1.ogg', 'sound/misc/breathmask2.ogg')
var/global/list/SOUNDIN_DESCERATION = list('sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg')

// ----- Machines -----
// Keystroke
var/global/list/SOUNDIN_KEYBOARD = list('sound/machines/keyboard/keyboard1.ogg', 'sound/machines/keyboard/keyboard2.ogg', 'sound/machines/keyboard/keyboard3.ogg', 'sound/machines/keyboard/keyboard4.ogg', 'sound/machines/keyboard/keyboard5.ogg')
// PDA's taps
var/global/list/SOUNDIN_PDA_TAPS = list('sound/machines/keyboard/pda1.ogg', 'sound/machines/keyboard/pda2.ogg', 'sound/machines/keyboard/pda3.ogg', 'sound/machines/keyboard/pda4.ogg', 'sound/machines/keyboard/pda5.ogg')

// ----- Weapons -----
// Melee
var/global/list/SOUNDIN_GENHIT = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
var/global/list/SOUNDIN_PUNCH  = list('sound/weapons/punch1.ogg', 'sound/weapons/punch2.ogg', 'sound/weapons/punch3.ogg', 'sound/weapons/punch4.ogg')

// ----- Items -----
// Medical
var/global/list/SOUNDIN_BANDAGE = list('sound/items/bandage.ogg', 'sound/items/bandage2.ogg', 'sound/items/bandage3.ogg')
