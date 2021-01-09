
/datum/religion_rites/instant/spawn_item
	name = "Spawn item"
	//Type for the item to be spawned
	var/spawn_type
	//Type for the item to be sacrificed. If you specify the type here, then the component itself will change spawn_type to sacrifice_type.
	var/sacrifice_type
	//Additional favor per sacrificing-item
	var/adding_favor = 75

/datum/religion_rites/instant/spawn_item/New()
	AddComponent(/datum/component/rite/spawn_item, spawn_type, 1, sacrifice_type, adding_favor, CALLBACK(src, .proc/modify_item))

// Used to apply some effect to an item after its spawn.
/datum/religion_rites/instant/spawn_item/proc/modify_item(atom/item)

/datum/religion_rites/instant/spawn_item/cult
	religion_type = /datum/religion/cult

/datum/religion_rites/instant/spawn_item/cult/talisman
	name = "Summon talisman"
	desc = "Summons an empty talisman in which to place the ritual."
	ritual_length = (10 SECONDS)
	invoke_msg = "Portable magic!!!"
	favor_cost = 75
	spawn_type = /obj/item/weapon/paper/talisman/cult

	needed_aspects = list(
		ASPECT_DEATH = 1,
	)
