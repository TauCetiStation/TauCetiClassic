
/datum/religion_rites/instant/spawn_item
	name = "Spawn item"
	//Type for the item to be spawned
	var/spawn_type
	//Type for the item to be sacrificed. If you specify the type here, then the component itself will change spawn_type to sacrifice_type.
	var/sacrifice_type
	//Additional favor per sacrificing-item
	var/adding_favor = 75

/datum/religion_rites/instant/spawn_item/New()
	AddComponent(/datum/component/rite/spawn_item, spawn_type, 1, sacrifice_type, adding_favor, divine_power, CALLBACK(src, .proc/modify_item))

// Used to apply some effect to an item after its spawn.
/datum/religion_rites/instant/spawn_item/proc/modify_item(atom/item)

/datum/religion_rites/instant/spawn_item/cult
	religion_type = /datum/religion/cult

/datum/religion_rites/instant/spawn_item/cult/talisman
	name = "Summon talisman"
	desc = "Summons an empty talisman in which to place the ritual."
	ritual_length = (10 SECONDS)
	invoke_msg = "Переносная магия!!!"
	favor_cost = 150
	spawn_type = /obj/item/weapon/paper/talisman/cult

	needed_aspects = list(
		ASPECT_DEATH = 1,
	)

/datum/religion_rites/instant/spawn_item/cult/soulstone
	name = "Summon soulstone"
	desc = "Summons an empty soulstone for forgotten souls."
	ritual_length = (5 SECONDS)
	invoke_msg = "За всё паранормальное!!!"
	favor_cost = 150
	spawn_type = /obj/item/device/soulstone

	needed_aspects = list(
		ASPECT_SPAWN = 2,
	)

/datum/religion_rites/instant/spawn_item/cult/constructshell
	name = "Summon shell"
	desc = "Summons an empty shell for forgotten souls."
	ritual_length = (5 SECONDS)
	invoke_msg = "За всё паранормальное!!!"
	favor_cost = 50
	spawn_type = /obj/structure/constructshell

	needed_aspects = list(
		ASPECT_MYSTIC = 1,
	)

/datum/religion_rites/instant/spawn_item/cult/space_suits
	name = "Summon space suits"
	desc = "Summons armor in which you can freely walk in space."
	ritual_length = (5 SECONDS)
	invoke_msg = "Я прийду к тебе!!!"
	favor_cost = 200
	spawn_type = /obj/item/clothing/suit/space/cult

	needed_aspects = list(
		ASPECT_WEAPON = 2,
		ASPECT_SCIENCE = 1
	)

/datum/religion_rites/instant/spawn_item/cult/space_suits/invoke_effect(mob/living/user, obj/AOG)
	. = ..()
	for(var/i in 1 to divine_power)
		new /obj/item/clothing/head/helmet/space/cult(get_turf(AOG))
	playsound(AOG, 'sound/magic/cult_equip.ogg', VOL_EFFECTS_MASTER)

	return TRUE
