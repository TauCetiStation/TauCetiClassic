/obj/item/clothing/head/hardhat
	name = "защитная каска"
	cases = list("защитная каска", "защитной каски", "защитной каске", "защитную каску", "защитной каской", "защитной каске")
	desc = "Головной убор, носимый в опасных рабочих условиях для защиты черепной коробки. Встроенный фонарик позволяет освободить руки для работы."
	gender = FEMALE
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 10, bomb = 20, bio = 10, rad = 20)
	flags_inv = 0
	siemens_coefficient = 0.9
	item_action_types = list(/datum/action/item_action/hands_free/toggle_hardhat)

/datum/action/item_action/hands_free/toggle_hardhat
	name = "Toggle Hardhat"

/obj/item/clothing/head/hardhat/atom_init()
	. = ..()
	update_icon()

/obj/item/clothing/head/hardhat/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "Вы не можете включить фонарик, находясь внутри [CASE(user.loc, GENITIVE_CASE)].")//To prevent some lighting anomalities.
		return

	on = !on
	update_icon()

	if(on)
		set_light(brightness_on)
	else
		set_light(0)

	update_inv_mob()
	update_item_actions()

/obj/item/clothing/head/hardhat/update_icon()
	icon_state = "[initial(icon_state)][on]"
	item_state = icon_state

/obj/item/clothing/head/hardhat/yellow
	icon_state = "hardhat_yellow"

/obj/item/clothing/head/hardhat/yellow/visor
	desc = "Головной убор, носимый в опасных рабочих условиях для защиты черепной коробки. Встроенный фонарик позволяет освободить руки для работы, а визор защитит глаза."
	icon_state = "hardhat_yellow_visor"
	body_parts_covered = HEAD|FACE|EYES
	flags = MASKCOVERSEYES

/obj/item/clothing/head/hardhat/orange
	icon_state = "hardhat_orange"

/obj/item/clothing/head/hardhat/red
	name = "firefighter helmet"
	gender = MALE
	cases = list("пожарный шлем", "пожарного шлема", "пожарному шлему", "пожарный шлем", "пожарным шлемом", "пожарном шлеме")
	icon_state = "hardhat_red"
	flags_pressure = STOPS_HIGHPRESSUREDMAGE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/hardhat/white
	icon_state = "hardhat_white"
	flags_pressure = STOPS_HIGHPRESSUREDMAGE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/hardhat/dblue
	icon_state = "hardhat_dblue"
