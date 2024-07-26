/datum/pref/keybinds/movement
	category = PREF_KEYBINDS_MOVEMENT
	weight = WEIGHT_HIGHEST

/datum/pref/keybinds/movement/on_update(client/client, old_value)
	..()
	client?.update_movement_keybinds()

/datum/pref/keybinds/movement/north
	name = "Move North"
	description = "Moves your character north"
	value = "W North"

	legacy_keyname = "North"

/datum/pref/keybinds/movement/south
	name = "Move South"
	description = "Moves your character south"
	value = "S South"

	legacy_keyname = "South"

/datum/pref/keybinds/movement/west
	name = "Move West"
	description = "Moves your character left"
	value = "A West"

	legacy_keyname = "West"

/datum/pref/keybinds/movement/east
	name = "Move East"
	description = "Moves your character east"
	value = "D East"

	legacy_keyname = "East"
