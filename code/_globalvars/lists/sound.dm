// ----- Effects ------
var/global/list/SOUNDIN_SHATTER   = list('sound/effects/glassbr1.ogg', 'sound/effects/glassbr2.ogg', 'sound/effects/glassbr3.ogg')
var/global/list/SOUNDIN_CREAK = list('sound/effects/creak1.ogg', 'sound/effects/creak2.ogg', 'sound/effects/creak3.ogg')
var/global/list/SOUNDIN_EXPLOSION = list('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg', 'sound/effects/explosion3.ogg')
var/global/list/SOUNDIN_EXPLOSION_FAR = list('sound/effects/explosionfar1.ogg', 'sound/effects/explosionfar2.ogg')
var/global/list/SOUNDIN_EXPLOSION_ECHO = list('sound/effects/explosion_echo.ogg')
var/global/list/SOUNDIN_EXPLOSION_CREAK = list('sound/effects/explosioncreak1.ogg', 'sound/effects/explosioncreak2.ogg')
var/global/list/SOUNDIN_SPARKS    = list('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg', 'sound/effects/sparks3.ogg', 'sound/effects/sparks4.ogg')
var/global/list/SOUNDIN_BODYFALL  = list('sound/effects/bodyfall1.ogg', 'sound/effects/bodyfall2.ogg', 'sound/effects/bodyfall3.ogg', 'sound/effects/bodyfall4.ogg')
var/global/list/SOUNDIN_PAGETURN  = list('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
var/global/list/SOUNDIN_CAN_OPEN  = list('sound/effects/can_open1.ogg', 'sound/effects/can_open2.ogg', 'sound/effects/can_open3.ogg')
var/global/list/SOUNDIN_BONEBREAK = list('sound/effects/bonebreak1.ogg', 'sound/effects/bonebreak2.ogg', 'sound/effects/bonebreak3.ogg', 'sound/effects/bonebreak4.ogg')
var/global/list/SOUNDIN_RUSTLE    = list('sound/effects/rustle1.ogg', 'sound/effects/rustle2.ogg', 'sound/effects/rustle3.ogg', 'sound/effects/rustle4.ogg', 'sound/effects/rustle5.ogg')
var/global/list/SOUNDIN_HORROR    = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/hallucinations/wail.ogg', 'sound/effects/screech.ogg', 'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/i_see_you_3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you_1.ogg', 'sound/hallucinations/i_see_you_2.ogg', 'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg', 'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg')
// Simple footsteps
var/global/list/SOUNDIN_CLOWNSTEP     = list('sound/effects/clownstep1.ogg', 'sound/effects/clownstep2.ogg')
var/global/list/SOUNDIN_FOOTSTEPS     = list('sound/effects/tile1.wav', 'sound/effects/tile2.wav', 'sound/effects/tile3.wav', 'sound/effects/tile4.wav')
var/global/list/SOUNDIN_WATER         = list('sound/effects/mob/footstep/water1.ogg', 'sound/effects/mob/footstep/water2.ogg', 'sound/effects/mob/footstep/water3.ogg', 'sound/effects/mob/footstep/water4.ogg')
var/global/list/SOUNDIN_WATER_SHALLOW = list('sound/effects/mob/footstep/waterstep1.ogg', 'sound/effects/mob/footstep/waterstep2.ogg', 'sound/effects/mob/footstep/waterstep3.ogg')
var/global/list/SOUNDIN_WATER_DEEP    = list('sound/effects/mob/footstep/swimming1.ogg', 'sound/effects/mob/footstep/swimming2.ogg', 'sound/effects/mob/footstep/swimming3.ogg')
// Projectiles' acts
var/global/list/SOUNDIN_BULLETACT     = list('sound/effects/projectiles_acts/bullet_1.ogg', 'sound/effects/projectiles_acts/bullet_2.ogg', 'sound/effects/projectiles_acts/bullet_3.ogg')
var/global/list/SOUNDIN_LASERACT      = list('sound/effects/projectiles_acts/laser_1.ogg', 'sound/effects/projectiles_acts/laser_2.ogg', 'sound/effects/projectiles_acts/laser_2.ogg')
var/global/list/SOUNDIN_ACIDACT       = list('sound/effects/projectiles_acts/acid_1.ogg', 'sound/effects/projectiles_acts/acid_2.ogg', 'sound/effects/projectiles_acts/acid_3.ogg')
var/global/list/SOUNDIN_WEAKBULLETACT = list('sound/effects/projectiles_acts/weakbullet_1.ogg', 'sound/effects/projectiles_acts/weakbullet_2.ogg', 'sound/effects/projectiles_acts/weakbullet_3.ogg')
var/global/list/SOUNDIN_BULLETMISSACT = list('sound/effects/projectiles_acts/miss_1.ogg', 'sound/effects/projectiles_acts/miss_2.ogg', 'sound/effects/projectiles_acts/miss_3.ogg', 'sound/effects/projectiles_acts/miss_4.ogg')
// Writing
var/global/list/SOUNDIN_KEYBOARD = list('sound/effects/writing/keyboard1.ogg', 'sound/effects/writing/keyboard2.ogg', 'sound/effects/writing/keyboard3.ogg', 'sound/effects/writing/keyboard4.ogg', 'sound/effects/writing/keyboard5.ogg')
var/global/list/SOUNDIN_PDA_TAPS = list('sound/effects/writing/pda1.ogg', 'sound/effects/writing/pda2.ogg', 'sound/effects/writing/pda3.ogg', 'sound/effects/writing/pda4.ogg', 'sound/effects/writing/pda5.ogg')
var/global/list/SOUNDIN_PEN      = list('sound/effects/writing/pen1.ogg', 'sound/effects/writing/pen2.ogg', 'sound/effects/writing/pen3.ogg')

// ----- Voice -----
// Human's vomit
var/global/list/SOUNDIN_MALEVOMIT   = list('sound/voice/mob/mvomit_1.ogg', 'sound/voice/mob/mvomit_2.ogg')
var/global/list/SOUNDIN_FEMALEVOMIT = list('sound/voice/mob/fvomit_1.ogg', 'sound/voice/mob/fvomit_2.ogg')
var/global/list/SOUNDIN_FRIGVOMIT   = list('sound/voice/mob/frigvomit_1.ogg', 'sound/voice/mob/frigvomit_2.ogg')
var/global/list/SOUNDIN_MRIGVOMIT   = list('sound/voice/mob/mrigvomit_1.ogg', 'sound/voice/mob/mrigvomit_2.ogg')
// Human's emotes
var/global/list/SOUNDIN_FBCOUGH = list('sound/voice/mob/fbcough_1.ogg', 'sound/voice/mob/fbcough_2.ogg', 'sound/voice/mob/fbcough_3.ogg')
var/global/list/SOUNDIN_MBCOUGH = list('sound/voice/mob/mbcough_1.ogg', 'sound/voice/mob/mbcough_2.ogg', 'sound/voice/mob/mbcough_3.ogg')
var/global/list/SOUNDIN_LAUGH_MALE = list('sound/voice/laugh/human_male/laugh_male-1.ogg', 'sound/voice/laugh/human_male/laugh_male-2.ogg', 'sound/voice/laugh/human_male/laugh_male-3.ogg', 'sound/voice/laugh/human_male/laugh_male-4.ogg', 'sound/voice/laugh/human_male/laugh_male-5.ogg', 'sound/voice/laugh/human_male/laugh_male-6.ogg', 'sound/voice/laugh/human_male/laugh_male-7.ogg','sound/voice/laugh/human_male/laugh_male-8.ogg', 'sound/voice/laugh/human_male/laugh_male-9.ogg')
var/global/list/SOUNDIN_LAUGH_FEMALE = list('sound/voice/laugh/human_female/laugh_female-1.ogg', 'sound/voice/laugh/human_female/laugh_female-2.ogg', 'sound/voice/laugh/human_female/laugh_female-3.ogg', 'sound/voice/laugh/human_female/laugh_female-4.ogg', 'sound/voice/laugh/human_female/laugh_female-5.ogg', 'sound/voice/laugh/human_female/laugh_female-6.ogg', 'sound/voice/laugh/human_female/laugh_female-7.ogg','sound/voice/laugh/human_female/laugh_female-8.ogg', 'sound/voice/laugh/human_female/laugh_female-9.ogg')
var/global/list/SOUNDIN_HMM_THINK_MALE 		= list('sound/voice/hmm/hmm_think_male_1.ogg', 'sound/voice/hmm/hmm_think_male_2.ogg', 'sound/voice/hmm/hmm_think_male_3.ogg', 'sound/voice/hmm/hmm_think_male_4.ogg', 'sound/voice/hmm/hmm_think_male_5.ogg', 'sound/voice/hmm/hmm_think_male_6.ogg', 'sound/voice/hmm/hmm_think_male_7.ogg')
var/global/list/SOUNDIN_HMM_THINK_FEMALE 	= list('sound/voice/hmm/hmm_think_female_1.ogg', 'sound/voice/hmm/hmm_think_female_2.ogg', 'sound/voice/hmm/hmm_think_female_3.ogg')
var/global/list/SOUNDIN_HMM_QUESTION_MALE 	= list('sound/voice/hmm/hmm_question_male_1.ogg', 'sound/voice/hmm/hmm_question_male_2.ogg', 'sound/voice/hmm/hmm_question_male_3.ogg', 'sound/voice/hmm/hmm_question_male_4.ogg', 'sound/voice/hmm/hmm_question_male_5.ogg', 'sound/voice/hmm/hmm_question_male_6.ogg')
var/global/list/SOUNDIN_HMM_QUESTION_FEMALE = list('sound/voice/hmm/hmm_question_female_1.ogg')
var/global/list/SOUNDIN_HMM_EXCLAIM_FEMALE 	= list('sound/voice/hmm/hmm_exclaim_female_1.ogg', 'sound/voice/hmm/hmm_exclaim_female_2.ogg')
var/global/list/SOUNDIN_HMM_EXCLAIM_MALE 	= list('sound/voice/hmm/hmm_exclaim_male_1.ogg', 'sound/voice/hmm/hmm_exclaim_male_2.ogg', 'sound/voice/hmm/hmm_exclaim_male_3.ogg', 'sound/voice/hmm/hmm_exclaim_male_4.ogg', 'sound/voice/hmm/hmm_exclaim_male_5.ogg')
var/global/list/SOUNDIN_WOO_MALE 	= list('sound/voice/woo/woo_male_1.ogg', 'sound/voice/woo/woo_male_2.ogg', 'sound/voice/woo/woo_male_3.ogg', 'sound/voice/woo/woo_male_4.ogg', 'sound/voice/woo/woo_male_5.ogg', 'sound/voice/woo/woo_male_6.ogg')
var/global/list/SOUNDIN_WOO_FEMALE 	= list('sound/voice/woo/woo_female_1.ogg', 'sound/voice/woo/woo_female_2.ogg', 'sound/voice/woo/woo_female_3.ogg', 'sound/voice/woo/woo_female_4.ogg', 'sound/voice/woo/woo_female_5.ogg')
var/global/list/SOUNDIN_SIGH_MALE   = list('sound/voice/sigh/sigh_male.ogg')
var/global/list/SOUNDIN_SIGH_FEMALE = list('sound/voice/sigh/sigh_female.ogg')
var/global/list/SOUNDIN_GASP_MALE   = list('sound/voice/gasp/gasp_male_1.ogg', 'sound/voice/gasp/gasp_male_2.ogg', 'sound/voice/gasp/gasp_male_3.ogg', 'sound/voice/gasp/gasp_male_4.ogg')
var/global/list/SOUNDIN_GASP_FEMALE   = list('sound/voice/gasp/gasp_female_1.ogg', 'sound/voice/gasp/gasp_female_2.ogg', 'sound/voice/gasp/gasp_female_3.ogg', 'sound/voice/gasp/gasp_female_4.ogg', 'sound/voice/gasp/gasp_female_5.ogg')
var/global/list/SOUNDIN_SNEEZE_MALE   	= list('sound/voice/sneeze/sneeze_male.ogg', 'sound/voice/sneeze/sneeze_neutral.ogg')
var/global/list/SOUNDIN_SNEEZE_FEMALE   = list('sound/voice/sneeze/sneeze_female.ogg', 'sound/voice/sneeze/sneeze_neutral.ogg')

// Human's pain
var/global/list/SOUNDIN_FEMALE_LIGHT_PAIN   = list('sound/voice/mob/pain/female/light_1.ogg', 'sound/voice/mob/pain/female/light_2.ogg', 'sound/voice/mob/pain/female/light_3.ogg', 'sound/voice/mob/pain/female/light_4.ogg', 'sound/voice/mob/pain/female/light_5.ogg', 'sound/voice/mob/pain/female/light_6.ogg', 'sound/voice/mob/pain/female/light_7.ogg', 'sound/voice/mob/pain/female/light_8.ogg')
var/global/list/SOUNDIN_FEMALE_HEAVY_PAIN   = list('sound/voice/mob/pain/female/heavy_1.ogg', 'sound/voice/mob/pain/female/heavy_2.ogg', 'sound/voice/mob/pain/female/heavy_3.ogg', 'sound/voice/mob/pain/female/heavy_4.ogg', 'sound/voice/mob/pain/female/heavy_5.ogg', 'sound/voice/mob/pain/female/heavy_6.ogg')
var/global/list/SOUNDIN_FEMALE_PASSIVE_PAIN = list('sound/voice/mob/pain/female/passive_1.ogg', 'sound/voice/mob/pain/female/passive_2.ogg', 'sound/voice/mob/pain/female/passive_3.ogg', 'sound/voice/mob/pain/female/passive_4.ogg', 'sound/voice/mob/pain/female/passive_5.ogg', 'sound/voice/mob/pain/female/passive_6.ogg')
var/global/list/SOUNDIN_FEMALE_WHINER_PAIN  = list('sound/voice/mob/pain/female/passive_whiner_1.ogg', 'sound/voice/mob/pain/female/passive_whiner_2.ogg', 'sound/voice/mob/pain/female/passive_whiner_3.ogg', 'sound/voice/mob/pain/female/passive_whiner_4.ogg', 'sound/voice/mob/pain/female/passive_whiner_5.ogg', 'sound/voice/mob/pain/female/passive_whiner_6.ogg')
var/global/list/SOUNDIN_MALE_LIGHT_PAIN     = list('sound/voice/mob/pain/male/light_1.ogg', 'sound/voice/mob/pain/male/light_2.ogg', 'sound/voice/mob/pain/male/light_3.ogg', 'sound/voice/mob/pain/male/light_4.ogg', 'sound/voice/mob/pain/male/light_5.ogg', 'sound/voice/mob/pain/male/light_6.ogg', 'sound/voice/mob/pain/male/light_7.ogg', 'sound/voice/mob/pain/male/light_8.ogg')
var/global/list/SOUNDIN_MALE_HEAVY_PAIN     = list('sound/voice/mob/pain/male/heavy_1.ogg', 'sound/voice/mob/pain/male/heavy_2.ogg', 'sound/voice/mob/pain/male/heavy_3.ogg', 'sound/voice/mob/pain/male/heavy_4.ogg', 'sound/voice/mob/pain/male/heavy_5.ogg', 'sound/voice/mob/pain/male/heavy_6.ogg', 'sound/voice/mob/pain/male/heavy_7.ogg', 'sound/voice/mob/pain/male/heavy_8.ogg')
var/global/list/SOUNDIN_MALE_PASSIVE_PAIN   = list('sound/voice/mob/pain/male/passive_1.ogg', 'sound/voice/mob/pain/male/passive_2.ogg', 'sound/voice/mob/pain/male/passive_3.ogg', 'sound/voice/mob/pain/male/passive_4.ogg', 'sound/voice/mob/pain/male/passive_5.ogg')
var/global/list/SOUNDIN_MALE_WHINER_PAIN    = list('sound/voice/mob/pain/male/passive_whiner_1.ogg', 'sound/voice/mob/pain/male/passive_whiner_2.ogg', 'sound/voice/mob/pain/male/passive_whiner_3.ogg', 'sound/voice/mob/pain/male/passive_whiner_4.ogg')
// Skrell's emotes
var/global/list/SOUNDIN_LAUGH_SKRELL_MALE = list('sound/voice/laugh/skrell_male/laugh_male-1.ogg', 'sound/voice/laugh/skrell_male/laugh_male-2.ogg', 'sound/voice/laugh/skrell_male/laugh_male-3.ogg', 'sound/voice/laugh/skrell_male/laugh_male-4.ogg', 'sound/voice/laugh/skrell_male/laugh_male-5.ogg', 'sound/voice/laugh/skrell_male/laugh_male-6.ogg', 'sound/voice/laugh/skrell_male/laugh_male-7.ogg','sound/voice/laugh/skrell_male/laugh_male-8.ogg', 'sound/voice/laugh/skrell_male/laugh_male-9.ogg')
var/global/list/SOUNDIN_LAUGH_SKRELL_FEMALE = list('sound/voice/laugh/skrell_female/laugh_female-1.ogg', 'sound/voice/laugh/skrell_female/laugh_female-2.ogg', 'sound/voice/laugh/skrell_female/laugh_female-3.ogg', 'sound/voice/laugh/skrell_female/laugh_female-4.ogg', 'sound/voice/laugh/skrell_female/laugh_female-5.ogg', 'sound/voice/laugh/skrell_female/laugh_female-6.ogg', 'sound/voice/laugh/skrell_female/laugh_female-7.ogg','sound/voice/laugh/skrell_female/laugh_female-8.ogg', 'sound/voice/laugh/skrell_female/laugh_female-9.ogg')
// Xenomorph's emotes
var/global/list/SOUNDIN_XENOMORPH_TALK  = list('sound/voice/xenomorph/talk_1.ogg', 'sound/voice/xenomorph/talk_2.ogg', 'sound/voice/xenomorph/talk_3.ogg', 'sound/voice/xenomorph/talk_4.ogg')
var/global/list/SOUNDIN_XENOMORPH_ROAR  = list('sound/voice/xenomorph/roar_1.ogg', 'sound/voice/xenomorph/roar_2.ogg')
var/global/list/SOUNDIN_XENOMORPH_HISS  = list('sound/voice/xenomorph/hiss_1.ogg', 'sound/voice/xenomorph/hiss_2.ogg', 'sound/voice/xenomorph/hiss_3.ogg')
var/global/list/SOUNDIN_XENOMORPH_GROWL = list('sound/voice/xenomorph/growl_1.ogg', 'sound/voice/xenomorph/growl_2.ogg')
//Xenomorph's sound
var/global/list/SOUNDIN_HUNTER_LEAP = list('sound/voice/xenomorph/leap_1.ogg', 'sound/voice/xenomorph/leap_2.ogg')
var/global/list/SOUNDIN_XENOMORPH_CHESTBURST = list('sound/voice/xenomorph/chestburst_1.ogg', 'sound/voice/xenomorph/chestburst_2.ogg')
var/global/list/SOUNDIN_XENOMORPH_SPLITACID = list('sound/voice/xenomorph/spitacid_1.ogg', 'sound/voice/xenomorph/spitacid_2.ogg')
// Silicon's sound
var/global/list/SOUNDIN_SILICON_PAIN = list('sound/voice/silicon/damage/borg_damage-1.ogg', 'sound/voice/silicon/damage/borg_damage-2.ogg', 'sound/voice/silicon/damage/borg_damage-3.ogg')
// Beepsky
var/global/list/SOUNDIN_BEEPSKY = list('sound/voice/beepsky/god.ogg', 'sound/voice/beepsky/iamthelaw.ogg', 'sound/voice/beepsky/secureday.ogg', 'sound/voice/beepsky/radio.ogg', 'sound/voice/beepsky/insult.ogg', 'sound/voice/beepsky/creep.ogg')

// ----- Misc -----
var/global/list/SOUNDIN_SCARYSOUNDS = list('sound/weapons/thudswoosh.ogg', 'sound/weapons/guns/gunpulse_Taser.ogg', 'sound/weapons/armbomb.ogg', 'sound/voice/xenomorph/hiss_1.ogg', 'sound/voice/xenomorph/hiss_2.ogg', 'sound/voice/xenomorph/hiss_3.ogg', 'sound/voice/xenomorph/growl_1.ogg', 'sound/voice/xenomorph/growl_2.ogg', 'sound/effects/Glassbr1.ogg', 'sound/effects/Glassbr2.ogg', 'sound/effects/Glassbr3.ogg', 'sound/items/Welder.ogg', 'sound/items/Welder2.ogg','sound/machines/airlock/toggle.ogg', 'sound/effects/clownstep1.ogg', 'sound/effects/clownstep2.ogg')
// Breath
var/global/list/SOUNDIN_RIGBREATH   = list('sound/misc/rigbreath1.ogg', 'sound/misc/rigbreath2.ogg', 'sound/misc/rigbreath3.ogg')
var/global/list/SOUNDIN_BREATHMASK  = list('sound/misc/breathmask1.ogg', 'sound/misc/breathmask2.ogg')
var/global/list/SOUNDIN_DESCERATION = list('sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg')

// ----- Punches -----
var/global/list/SOUNDIN_PUNCH_MEDIUM    = list('sound/effects/mob/hits/medium_1.ogg', 'sound/effects/mob/hits/medium_2.ogg', 'sound/effects/mob/hits/medium_3.ogg', 'sound/effects/mob/hits/medium_4.ogg', 'sound/effects/mob/hits/medium_5.ogg')
var/global/list/SOUNDIN_PUNCH_HEAVY     = list('sound/effects/mob/hits/heavy_1.ogg', 'sound/effects/mob/hits/heavy_2.ogg', 'sound/effects/mob/hits/heavy_3.ogg', 'sound/effects/mob/hits/heavy_4.ogg')
var/global/list/SOUNDIN_PUNCH_VERYHEAVY = list('sound/effects/mob/hits/veryheavy_1.ogg', 'sound/effects/mob/hits/veryheavy_2.ogg', 'sound/effects/mob/hits/veryheavy_3.ogg', 'sound/effects/mob/hits/veryheavy_4.ogg')

// ----- Weapons -----
// Melee
var/global/list/SOUNDIN_GENHIT = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')

// ----- Items -----
// Medical
var/global/list/SOUNDIN_BANDAGE = list('sound/items/bandage1.ogg', 'sound/items/bandage2.ogg')
var/global/list/SOUNDIN_KNIFE_CUTTING = list('sound/items/knife_cutting1.ogg', 'sound/items/knife_cutting2.ogg', 'sound/items/knife_cutting3.ogg')

// ----- Footsteps -----
/*
id = list(
list(sounds),
base volume,
extra range addition
)

*/

var/global/list/footstep = list(
	FOOTSTEP_WOOD = list(list(
		'sound/effects/mob/footstep/wood1.ogg',
		'sound/effects/mob/footstep/wood2.ogg',
		'sound/effects/mob/footstep/wood3.ogg',
		'sound/effects/mob/footstep/wood4.ogg',
		'sound/effects/mob/footstep/wood5.ogg'), 75, -2),
	FOOTSTEP_FLOOR = list(list(
		'sound/effects/mob/footstep/floor1.ogg',
		'sound/effects/mob/footstep/floor2.ogg',
		'sound/effects/mob/footstep/floor3.ogg',
		'sound/effects/mob/footstep/floor4.ogg',
		'sound/effects/mob/footstep/floor5.ogg'), 100, -2),
	FOOTSTEP_CATWALK = list(list(
		'sound/effects/mob/footstep/catwalk1.ogg',
		'sound/effects/mob/footstep/catwalk2.ogg',
		'sound/effects/mob/footstep/catwalk3.ogg',
		'sound/effects/mob/footstep/catwalk4.ogg',
		'sound/effects/mob/footstep/catwalk5.ogg'), 100, -1),
	FOOTSTEP_PLATING = list(list(
		'sound/effects/mob/footstep/plating1.ogg',
		'sound/effects/mob/footstep/plating2.ogg',
		'sound/effects/mob/footstep/plating3.ogg',
		'sound/effects/mob/footstep/plating4.ogg',
		'sound/effects/mob/footstep/plating5.ogg'), 100, -1),
	FOOTSTEP_CARPET = list(list(
		'sound/effects/mob/footstep/carpet1.ogg',
		'sound/effects/mob/footstep/carpet2.ogg',
		'sound/effects/mob/footstep/carpet3.ogg',
		'sound/effects/mob/footstep/carpet4.ogg',
		'sound/effects/mob/footstep/carpet5.ogg'), 80, -3),
	FOOTSTEP_SAND = list(list(
		'sound/effects/mob/footstep/asteroid1.ogg',
		'sound/effects/mob/footstep/asteroid2.ogg',
		'sound/effects/mob/footstep/asteroid3.ogg',
		'sound/effects/mob/footstep/asteroid4.ogg',
		'sound/effects/mob/footstep/asteroid5.ogg'), 100, -2),
	FOOTSTEP_GRASS = list(list(
		'sound/effects/mob/footstep/grass1.ogg',
		'sound/effects/mob/footstep/grass2.ogg',
		'sound/effects/mob/footstep/grass3.ogg',
		'sound/effects/mob/footstep/grass4.ogg'), 100, -3),
	FOOTSTEP_LAVA = list(list(
		'sound/effects/mob/footstep/lava1.ogg',
		'sound/effects/mob/footstep/lava2.ogg',
		'sound/effects/mob/footstep/lava3.ogg'), 100, 0),
	FOOTSTEP_WATER_SHALLOW = list(SOUNDIN_WATER_SHALLOW, 100, -1),
	FOOTSTEP_WATER_DEEP = list(SOUNDIN_WATER_DEEP, 100, 0),
	FOOTSTEP_SNOWSTEP = list(list(
		'sound/effects/mob/footstep/snowstep1.ogg',
		'sound/effects/mob/footstep/snowstep2.ogg',
		'sound/effects/mob/footstep/snowstep3.ogg',
		'sound/effects/mob/footstep/snowstep4.ogg',
		'sound/effects/mob/footstep/snowstep5.ogg',
		'sound/effects/mob/footstep/snowstep6.ogg',
		'sound/effects/mob/footstep/snowstep7.ogg',
		'sound/effects/mob/footstep/snowstep8.ogg',
		'sound/effects/mob/footstep/snowstep9.ogg'), 100, 0),
	FOOTSTEP_ICESTEP = list(list('sound/effects/icestep.ogg'), 100, 0),
)

//bare footsteps lists
var/global/list/barefootstep = list(
	FOOTSTEP_WOOD_BAREFOOT = list(list(
		'sound/effects/mob/footstep/woodbarefoot1.ogg',
		'sound/effects/mob/footstep/woodbarefoot2.ogg',
		'sound/effects/mob/footstep/woodbarefoot3.ogg',
		'sound/effects/mob/footstep/woodbarefoot4.ogg',
		'sound/effects/mob/footstep/woodbarefoot5.ogg'), 100, -3),
	FOOTSTEP_HARD_BAREFOOT = list(list(
		'sound/effects/mob/footstep/hardbarefoot1.ogg',
		'sound/effects/mob/footstep/hardbarefoot2.ogg',
		'sound/effects/mob/footstep/hardbarefoot3.ogg',
		'sound/effects/mob/footstep/hardbarefoot4.ogg',
		'sound/effects/mob/footstep/hardbarefoot5.ogg'), 100, -3),
	FOOTSTEP_CARPET_BAREFOOT = list(list(
		'sound/effects/mob/footstep/carpetbarefoot1.ogg',
		'sound/effects/mob/footstep/carpetbarefoot2.ogg',
		'sound/effects/mob/footstep/carpetbarefoot3.ogg',
		'sound/effects/mob/footstep/carpetbarefoot4.ogg',
		'sound/effects/mob/footstep/carpetbarefoot5.ogg'), 50, -4),
	FOOTSTEP_SAND = list(list(
		'sound/effects/mob/footstep/asteroid1.ogg',
		'sound/effects/mob/footstep/asteroid2.ogg',
		'sound/effects/mob/footstep/asteroid3.ogg',
		'sound/effects/mob/footstep/asteroid4.ogg',
		'sound/effects/mob/footstep/asteroid5.ogg'), 100, -4),
	FOOTSTEP_GRASS = list(list(
		'sound/effects/mob/footstep/grass1.ogg',
		'sound/effects/mob/footstep/grass2.ogg',
		'sound/effects/mob/footstep/grass3.ogg',
		'sound/effects/mob/footstep/grass4.ogg'), 100, -3),
	FOOTSTEP_LAVA = list(list(
		'sound/effects/mob/footstep/lava1.ogg',
		'sound/effects/mob/footstep/lava2.ogg',
		'sound/effects/mob/footstep/lava3.ogg'), 100, 0),
	FOOTSTEP_WATER_SHALLOW = list(SOUNDIN_WATER_SHALLOW, 100, -1),
	FOOTSTEP_WATER_DEEP = list(SOUNDIN_WATER_DEEP, 100, 0),
	FOOTSTEP_SNOWSTEP = list(list(
		'sound/effects/mob/footstep/snowstep1.ogg',
		'sound/effects/mob/footstep/snowstep2.ogg',
		'sound/effects/mob/footstep/snowstep3.ogg',
		'sound/effects/mob/footstep/snowstep4.ogg',
		'sound/effects/mob/footstep/snowstep5.ogg',
		'sound/effects/mob/footstep/snowstep6.ogg',
		'sound/effects/mob/footstep/snowstep7.ogg',
		'sound/effects/mob/footstep/snowstep8.ogg',
		'sound/effects/mob/footstep/snowstep9.ogg'), 100, 0),
	FOOTSTEP_ICESTEP = list(list('sound/effects/icestep.ogg'), 100, 0),
)

//claw footsteps lists
var/global/list/clawfootstep = list(
	FOOTSTEP_WOOD_CLAW = list(list(
		'sound/effects/mob/footstep/woodclaw1.ogg',
		'sound/effects/mob/footstep/woodclaw2.ogg',
		'sound/effects/mob/footstep/woodclaw3.ogg',
		'sound/effects/mob/footstep/woodclaw2.ogg',
		'sound/effects/mob/footstep/woodclaw1.ogg'), 100, 0),
	FOOTSTEP_HARD_CLAW = list(list(
		'sound/effects/mob/footstep/hardclaw1.ogg',
		'sound/effects/mob/footstep/hardclaw2.ogg',
		'sound/effects/mob/footstep/hardclaw3.ogg',
		'sound/effects/mob/footstep/hardclaw4.ogg',
		'sound/effects/mob/footstep/hardclaw1.ogg'), 100, 0),
	FOOTSTEP_CARPET_BAREFOOT = list(list(
		'sound/effects/mob/footstep/carpetbarefoot1.ogg',
		'sound/effects/mob/footstep/carpetbarefoot2.ogg',
		'sound/effects/mob/footstep/carpetbarefoot3.ogg',
		'sound/effects/mob/footstep/carpetbarefoot4.ogg',
		'sound/effects/mob/footstep/carpetbarefoot5.ogg'), 100, -1),
	FOOTSTEP_SAND = list(list(
		'sound/effects/mob/footstep/asteroid1.ogg',
		'sound/effects/mob/footstep/asteroid2.ogg',
		'sound/effects/mob/footstep/asteroid3.ogg',
		'sound/effects/mob/footstep/asteroid4.ogg',
		'sound/effects/mob/footstep/asteroid5.ogg'), 100, -2),
	FOOTSTEP_GRASS = list(list(
		'sound/effects/mob/footstep/grass1.ogg',
		'sound/effects/mob/footstep/grass2.ogg',
		'sound/effects/mob/footstep/grass3.ogg',
		'sound/effects/mob/footstep/grass4.ogg'), 100, -1),
	FOOTSTEP_LAVA = list(list(
		'sound/effects/mob/footstep/lava1.ogg',
		'sound/effects/mob/footstep/lava2.ogg',
		'sound/effects/mob/footstep/lava3.ogg'), 100, -2),
	FOOTSTEP_WATER_SHALLOW = list(SOUNDIN_WATER_SHALLOW, 100, -1),
	FOOTSTEP_WATER_DEEP = list(SOUNDIN_WATER_DEEP, 100, 0),
	FOOTSTEP_SNOWSTEP = list(list(
		'sound/effects/mob/footstep/snowstep1.ogg',
		'sound/effects/mob/footstep/snowstep2.ogg',
		'sound/effects/mob/footstep/snowstep3.ogg',
		'sound/effects/mob/footstep/snowstep4.ogg',
		'sound/effects/mob/footstep/snowstep5.ogg',
		'sound/effects/mob/footstep/snowstep6.ogg',
		'sound/effects/mob/footstep/snowstep7.ogg',
		'sound/effects/mob/footstep/snowstep8.ogg',
		'sound/effects/mob/footstep/snowstep9.ogg'), 100, 0),
	FOOTSTEP_ICESTEP = list(list('sound/effects/icestep.ogg'), 100, 0),
)

//heavy footsteps list
var/global/list/heavyfootstep = list(
	FOOTSTEP_GENERIC_HEAVY = list(list(
		'sound/effects/mob/footstep/heavy1.ogg',
		'sound/effects/mob/footstep/heavy2.ogg'), 100, 1),
	FOOTSTEP_LAVA = list(list(
		'sound/effects/mob/footstep/lava1.ogg',
		'sound/effects/mob/footstep/lava2.ogg',
		'sound/effects/mob/footstep/lava3.ogg'), 100, 0),
	FOOTSTEP_WATER_SHALLOW = list(SOUNDIN_WATER_SHALLOW, 100, -1),
	FOOTSTEP_WATER_DEEP = list(SOUNDIN_WATER_DEEP, 100, 0),
	FOOTSTEP_SNOWSTEP = list(list(
		'sound/effects/mob/footstep/snowstep1.ogg',
		'sound/effects/mob/footstep/snowstep2.ogg',
		'sound/effects/mob/footstep/snowstep3.ogg',
		'sound/effects/mob/footstep/snowstep4.ogg',
		'sound/effects/mob/footstep/snowstep5.ogg',
		'sound/effects/mob/footstep/snowstep6.ogg',
		'sound/effects/mob/footstep/snowstep7.ogg',
		'sound/effects/mob/footstep/snowstep8.ogg',
		'sound/effects/mob/footstep/snowstep9.ogg'), 100, 0),
	FOOTSTEP_ICESTEP = list(list('sound/effects/icestep.ogg'), 100, 0),
)

