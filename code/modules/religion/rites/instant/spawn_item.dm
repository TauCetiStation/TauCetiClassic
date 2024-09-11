
/datum/religion_rites/instant/spawn_item
	//Type for the item to be spawned
	var/spawn_type
	//Type for the item to be sacrificed. If you specify the type here, then the component itself will change spawn_type to sacrifice_type.
	var/sacrifice_type
	//Additional favor per sacrificing-item
	var/adding_favor = 75

/datum/religion_rites/instant/spawn_item/New()
	AddComponent(/datum/component/rite/spawn_item, spawn_type, 1, sacrifice_type, adding_favor, divine_power, CALLBACK(src, PROC_REF(modify_item)))

// Used to apply some effect to an item after its spawn.
/datum/religion_rites/instant/spawn_item/proc/modify_item(atom/item)

/datum/religion_rites/instant/spawn_item/cult
	religion_type = /datum/religion/cult

/datum/religion_rites/instant/spawn_item/cult/talisman
	name = "Призыв Талисмана"
	desc = "Призывает пустой талисман, в который можно поместить ритуал."
	ritual_length = (10 SECONDS)
	invoke_msg = "Переносная магия!!!"
	favor_cost = 150
	spawn_type = /obj/item/weapon/paper/talisman/cult

	needed_aspects = list(
		ASPECT_DEATH = 1,
	)

/datum/religion_rites/instant/spawn_item/cult/soulstone
	name = "Призыв Камня Душ"
	desc = "Призывает камень душ для заблудших лярв."
	ritual_length = (5 SECONDS)
	invoke_msg = "Призываю древний артефакт!!!"
	favor_cost = 150
	spawn_type = /obj/item/device/soulstone

	needed_aspects = list(
		ASPECT_SPAWN = 2,
	)

/datum/religion_rites/instant/spawn_item/cult/constructshell
	name = "Призыв Оболочки"
	desc = "Призывает пустую оболочку для пойманных лярв."
	ritual_length = (5 SECONDS)
	invoke_msg = "Призываю оболочку!!!"
	favor_cost = 50
	spawn_type = /obj/structure/constructshell

	needed_aspects = list(
		ASPECT_MYSTIC = 1,
	)
