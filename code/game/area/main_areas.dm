 //////////////
 //MAIN AREAS//
 //////////////

/area/space
	name = "Space"
	icon_state = "space"
	requires_power = 1
	always_unpowered = 1
	power_light = 0
	power_equip = 0
	power_environ = 0
	valid_territory = 0
/* <base>
	looped_ambience = 'sound/ambience/loop_space.ogg'
	is_force_ambience = TRUE
	ambience = list(
		'sound/ambience/space_1.ogg',
		'sound/ambience/space_2.ogg',
		'sound/ambience/space_3.ogg',
		'sound/ambience/space_4.ogg',
		'sound/ambience/space_5.ogg',
		'sound/ambience/space_6.ogg',
		'sound/ambience/space_7.ogg',
		'sound/ambience/space_8.ogg'
</base> */
// <basecodetrainstation13>
	looped_ambience = 'trainstation13/sound/ambience/loop_street.ogg'
	is_force_ambience = FALSE
	ambience = list(
		'trainstation13/sound/music/Azure_Studios_Foundations_I_24bit_01_mg1.ogg',\
		'trainstation13/sound/music/Azure_Studios_Foundations_I_24bit_03_mg3.ogg',\
		'trainstation13/sound/music/Azure_Studios_Foundations_I_24bit_05_mg5.ogg',\
		'trainstation13/sound/music/Azure_Studios_Foundations_I_24bit_09_mg9.ogg',\
		'trainstation13/sound/music/Azure_Studios_Foundations_I_24bit_11_mgb.ogg',\
		'trainstation13/sound/music/Azure_Studios_Foundations_I_24bit_13_mgd.ogg',\
		'trainstation13/sound/music/Azure_Studios_Foundations_I_24bit_15_mgf.ogg'
	)
// </basecodetrainstation13>
	outdoors = TRUE

/area/start            // will be unused once kurper gets his login interface patch done
	name = "start area"
	icon_state = "start"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = 1

// other environment areas
/area/space/snow
	name = "Snow field"
