/obj/effect/landmark/post_round_dm/arena
	name = "Arena Spawn"

/obj/effect/landmark/post_round_dm/gladiator
	name = "Gladiator"


/datum/map_template/post_round_arena
	var/spawners

/datum/map_template/post_round_arena/blank
	name = "Blank (Empty arena) - 0"
	mappath = "maps/templates/post_round_arena/blank.dmm"
	spawners = 0

/datum/map_template/post_round_arena/cult
	name = "Ultra Small Cult - 4"
	mappath = "maps/templates/post_round_arena/ultra_small_cult.dmm"
	spawners = 4

/datum/map_template/post_round_arena/small_classic
	name = "Small Classic - 12"
	mappath = "maps/templates/post_round_arena/small_classic.dmm"
	spawners = 12

/datum/map_template/post_round_arena/small_alien
	name = "Small Alien - 20"
	mappath = "maps/templates/post_round_arena/small_alien.dmm"
	spawners = 20

/datum/map_template/post_round_arena/med
	name = "Medium Medbay - 27"
	mappath = "maps/templates/post_round_arena/medium_medbay.dmm"
	spawners = 27

/datum/map_template/post_round_arena/four_biomes
	name = "Medium Four Biomes - 30"
	mappath = "maps/templates/post_round_arena/medium_four_biomes.dmm"
	spawners = 30
