
/datum/religion_rites/instant/spawn_item
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

/datum/religion_rites/instant/spawn_item/cult/book
	name = "Призыв Тома"
	desc = "Призывает ваше основное оружие и инструмент - книгу."
	ritual_length = (3 SECONDS)
	invoke_msg = "Призываю инструмент божий!!!"
	favor_cost = 50
	spawn_type = /obj/item/weapon/storage/bible/tome

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

/datum/religion_rites/instant/spawn_item/cult/cult_sword
	name = "Создание Меча"
	desc = "Создаёт меч для боя со всякой нечестью, по типу экипажа станции."
	ritual_length = (5 SECONDS)
	invoke_msg = "Н'ез Рез!!!"
	favor_cost = 100
	spawn_type = /obj/item/weapon/melee/cultblade

/datum/religion_rites/instant/spawn_item/cult/cult_robes
	name = "Создание Робы"
	desc = "Создаёт броню для защиты вашей души и тела от посягательства врагов."
	ritual_length = (5 SECONDS)
	invoke_msg = "Шай'ро Ез!!!"
	favor_cost = 200
	spawn_type = /obj/item/weapon/storage/backpack/cultpack/armor

/datum/religion_rites/instant/spawn_item/cult/cult_space_suit
	name = "Создание Брони"
	desc = "Создаёт набор тяжелой космической брони для защиты вашей души и тела от посягательства врагов и космоса."
	ritual_length = (5 SECONDS)
	invoke_msg = "Ат Драггазнор!!!"
	favor_cost = 300
	piety_cost = 20
	spawn_type =/obj/item/weapon/storage/backpack/cultpack/space_armor

/datum/religion_rites/instant/spawn_item/cult/cult_blindfold
	name = "Создание Повязки"
	desc = "Создаёт повязку, позволяющую смотреть глазами бога."
	ritual_length = (5 SECONDS)
	invoke_msg = "Фве'ш Мех Ерлоз!!!"
	favor_cost = 120
	piety_cost = 30
	spawn_type = /obj/item/clothing/glasses/cult_blindfold

/datum/religion_rites/instant/spawn_item/cult/cult_stone
	name = "Создание Камня Прозрения"
	desc = "Создаёт камень, позволяющую смотреть глазами пилонов."
	ritual_length = (5 SECONDS)
	favor_cost = 100
	invoke_msg = "Набо'р Се'езма!!!"
	spawn_type = /obj/item/device/cult_camera
