/obj/effect/landmark/mafia_game_area //locations where mafia will be loaded by the datum
	name = "Mafia Area Spawn"
	var/game_id = "mafia"

/obj/effect/landmark/mafia
	name = "Mafia Player Spawn"
	var/game_id = "mafia"

/obj/effect/landmark/mafia/town_center
	name = "Mafia Town Center"

//for ghosts/admins
/obj/mafia_game_board
	name = "Mafia Game Board"
	icon = 'icons/obj/mafia.dmi'
	icon_state = "board"
	anchored = TRUE
	flags = ABSTRACT
	var/game_id = "mafia"
	var/datum/mafia_controller/MF

/obj/mafia_game_board/attack_ghost(mob/user)
	. = ..()
	if(!MF)
		MF = global.mafia_game
	if(!MF)
		MF = create_mafia_game()
	MF.tgui_interact(user)

/area/mafia
	name = "Mafia Minigame"
	icon_state = "mafia"
	dynamic_lighting = FALSE
	requires_power = FALSE

/datum/map_template/mafia
	var/description

/datum/map_template/mafia/summerball
	name = "Summerball 2020"
	description = "The original, the OG. The 2020 Summer ball was where mafia came from, with this map."
	mappath = "maps/mafia/mafia_ball.dmm"

/datum/map_template/mafia/syndicate
	name = "Syndicate Megastation"
	description = "Yes, it's a very confusing day at the Megastation. Will the syndicate conflict resolution operatives succeed?"
	mappath = "maps/mafia/mafia_syndie.dmm"

/datum/map_template/mafia/cult_heaven
	name = "Initiation Ritual"
	description = "Cult Heaven and his turfs"
	mappath = "maps/mafia/mafia_heaven.dmm"

/datum/map_template/mafia/ufo
	name = "Alien Mothership"
	description = "The haunted ghost UFO tour has gone south and now it's up to our fine townies and scare seekers to kill the actual real alien changelings..."
	mappath = "maps/mafia/mafia_ayylmao.dmm"

/datum/map_template/mafia/gothic
	name = "Vampire's Castle"
	description = "Vampires and changelings clash to find out who's the superior bloodsucking monster in this creepy castle map."
	mappath = "maps/mafia/mafia_gothic.dmm"

/datum/map_template/mafia/alien
	name = "Alien Base"
	mappath = "maps/mafia/mafia_infestation.dmm"

/datum/map_template/mafia/park
	name = "Peaceful Place"
	mappath = "maps/mafia/mafia_park.dmm"

/datum/map_template/mafia/winter
	name = "Snow on the Earth"
	mappath = "maps/mafia/mafia_snow.dmm"
