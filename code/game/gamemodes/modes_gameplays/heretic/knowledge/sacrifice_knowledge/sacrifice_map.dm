// Some various defines used in the heretic sacrifice map.

/// A global assoc list of all landmarks that denote a heretic sacrifice location. [string heretic path] = [landmark].
var/global/list/heretic_sacrifice_landmarks = list()

/// Lardmarks meant to designate where heretic sacrifices are sent.
/obj/effect/landmark/heretic
	name = "default heretic sacrifice landmark"
	icon_state = "x"
	/// What path this landmark is intended for.
	var/for_heretic_path = PATH_START

/obj/effect/landmark/heretic/atom_init()
	. = ..()
	heretic_sacrifice_landmarks[for_heretic_path] = src

/obj/effect/landmark/heretic/Destroy()
	heretic_sacrifice_landmarks[for_heretic_path] = null
	return ..()

/obj/effect/landmark/heretic/ash
	name = "ash heretic sacrifice landmark"
	for_heretic_path = PATH_ASH

/obj/effect/landmark/heretic/flesh
	name = "flesh heretic sacrifice landmark"
	for_heretic_path = PATH_FLESH

/obj/effect/landmark/heretic/void
	name = "void heretic sacrifice landmark"
	for_heretic_path = PATH_VOID

/obj/effect/landmark/heretic/rust
	name = "rust heretic sacrifice landmark"
	for_heretic_path = PATH_RUST

/obj/effect/landmark/heretic/lock
	name = "lock heretic sacrifice landmark"
	for_heretic_path = PATH_LOCK

// A fluff signpost object that doesn't teleport you somewhere when you touch it.
/obj/structure/no_effect_signpost
	name = "signpost"
	desc = "Won't somebody give me a sign?"
	icon = 'icons/obj/fluff/general.dmi'
	icon_state = "signpost"
	anchored = TRUE
	density = TRUE

/obj/structure/no_effect_signpost/void
	name = "signpost at the edge of the universe"
	desc = "A direction in the directionless void."
	density = FALSE
	/// Brightness of the signpost.
	var/range = 2
	/// Light power of the signpost.
	var/power = 0.8

/obj/structure/no_effect_signpost/void/atom_init()
	. = ..()
	set_light(range, power)

// Some VERY dim lights, used for the void sacrifice realm.
/obj/machinery/light/very_dim
	nightshift_allowed = FALSE
	bulb_colour = "#d6b6a6ff"
	brightness = 3
	fire_brightness = 3.5
	bulb_power = 0.5

/obj/machinery/light/very_dim/directional/north
	dir = NORTH

/obj/machinery/light/very_dim/directional/south
	dir = SOUTH

/obj/machinery/light/very_dim/directional/east
	dir = EAST

/obj/machinery/light/very_dim/directional/west
	dir = WEST

// Rooms for where heretic sacrifices send people.
/area/centcom/heretic_sacrifice
	name = "Mansus"
	icon_state = "heretic"
	ambience = list(
	'sound/ambience/ambimo1.ogg',
	'sound/ambience/ambimo2.ogg',
	'sound/ambience/ambimystery.ogg',
	'sound/ambience/ambiodd.ogg',
	'sound/ambience/ambiruin6.ogg',
	'sound/ambience/ambiruin7.ogg'
	)
	sound_environment = SOUND_ENVIRONMENT_CAVE

/area/centcom/heretic_sacrifice/atom_init()
	if(!ambientsounds)
		ambientsounds = ambience + 'sound/ambience/misc/ambiatm1.ogg'
	return ..()

/area/centcom/heretic_sacrifice/ash //also, the default
	name = "Mansus Ash Gate"

/area/centcom/heretic_sacrifice/void
	name = "Mansus Void Gate"
	sound_environment = SOUND_ENVIRONMENT_UNDERWATER

/area/centcom/heretic_sacrifice/flesh
	name = "Mansus Flesh Gate"
	sound_environment = SOUND_ENVIRONMENT_STONEROOM

/area/centcom/heretic_sacrifice/rust
	name = "Mansus Rust Gate"
	ambience = list(
	'sound/ambience/ambireebe1.ogg',
	'sound/ambience/ambireebe2.ogg',
	'sound/ambience/ambireebe3.ogg'
	)
	sound_environment = SOUND_ENVIRONMENT_SEWER_PIPE

/area/centcom/heretic_sacrifice/lock
	name = "Mansus Lock Gate"
	ambience = list(
	'sound/ambience/ambidanger.ogg',
	'sound/ambience/ambidanger2.ogg'
	)
	sound_environment = SOUND_ENVIRONMENT_PSYCHOTIC
