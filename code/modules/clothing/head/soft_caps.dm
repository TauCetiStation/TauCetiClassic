/obj/item/clothing/head/soft
	name = "cap"
	cases = list("кепка", "кепки", "кепке", "кепку", "кепкой", "кепке")
	desc = "Обыкновенная бейсболка."
	icon_state = "greysoft"
	item_state = "greysoft"
	item_state_world = "greysoft_world"
	flags = HEADCOVERSEYES
	siemens_coefficient = 0.9
	body_parts_covered = 0
	dyed_type = DYED_SOFTCAP
	item_action_types = list(/datum/action/item_action/hands_free/flip_cap)

	var/flipped = FALSE
	var/cap_color = "grey"

/datum/action/item_action/hands_free/flip_cap
	name = "Повернуть кепку"

/obj/item/clothing/head/soft/atom_init(mapload, ...)
	. = ..()
	item_state_world = "[cap_color]soft_world"

/obj/item/clothing/head/soft/wash_act(w_color)
	. = ..()
	var/obj/item/clothing/dye_type = get_dye_type(w_color)
	if(!dye_type)
		return

	var/obj/item/clothing/head/soft/S = dye_type

	item_state_inventory = "[initial(S.icon_state)][flipped ? "_flipped" : ""]"
	item_state_world = initial(S.item_state_world)
	cap_color = initial(S.cap_color)
	update_world_icon()

/obj/item/clothing/head/soft/attack_self(mob/living/carbon/human/user)
	flipped = !flipped
	if(flipped)
		item_state_inventory = "[cap_color]soft_flipped"
		to_chat(user, "Вы поворачиваете кепку козырьком назад.")
	else
		item_state_inventory = "[cap_color]soft"
		to_chat(user, "Вы поворачиваете кепку в нормальную сторону.")

	update_world_icon()
	update_inv_mob()
	update_item_actions()


/obj/item/clothing/head/soft/red
	name = "red cap"
	cases = list("красная кепка", "красной кепки", "красной кепке", "красную кепку", "красной кепкой", "красной кепке")
	desc = "Это бейсболка безвкусного красного цвета."
	icon_state = "redsoft"
	item_state_world = "redsoft_world"
	cap_color = "red"

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	cases = list("синяя кепка", "синей кепки", "синей кепке", "синюю кепку", "синей кепкой", "синей кепке")
	desc = "Это бейсболка безвкусного синего цвета."
	icon_state = "bluesoft"
	item_state_world = "bluesoft_world"
	cap_color = "blue"

/obj/item/clothing/head/soft/green
	name = "green cap"
	cases = list("зелёная кепка", "зелёной кепки", "зелёной кепке", "зелёную кепку", "зелёной кепкой", "зелёной кепке")
	desc = "Это бейсболка безвкусного зелёного цвета."
	icon_state = "greensoft"
	item_state_world = "greensoft_world"
	cap_color = "green"

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	cases = list("жёлтая кепка", "жёлтой кепки", "жёлтой кепке", "жёлтую кепку", "жёлтой кепкой", "жёлтой кепке")
	desc = "Это бейсболка безвкусного жёлтого цвета."
	icon_state = "yellowsoft"
	item_state_world = "yellowsoft_world"
	cap_color = "yellow"

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	cases = list("серая кепка", "серой кепки", "серой кепке", "серую кепку", "серой кепкой", "серой кепке")
	desc = "Это бейсболка модного серого цвета."
	icon_state = "greysoft"
	item_state_world = "greysoft_world"
	cap_color = "grey"

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	cases = list("оранжевая кепка", "оранжевой кепки", "оранжевой кепке", "оранжевую кепку", "оранжевой кепкой", "оранжевой кепке")
	desc = "Это бейсболка безвкусного оранжевого цвета."
	icon_state = "orangesoft"
	item_state_world = "orangesoft_world"
	cap_color = "orange"

/obj/item/clothing/head/soft/mime
	name = "white cap"
	cases = list("белая кепка", "белой кепки", "белой кепке", "белую кепку", "белой кепкой", "белой кепке")
	desc = "Это бейсболка безвкусного белого цвета."
	icon_state = "mimesoft"
	item_state_world = "mimesoft_world"
	cap_color = "mime"

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	cases = list("фиолетовая кепка", "фиолетовой кепки", "фиолетовой кепке", "фиолетовую кепку", "фиолетовой кепкой", "фиолетовой кепке")
	desc = "Это бейсболка безвкусного фиолетового цвета."
	icon_state = "purplesoft"
	item_state_world = "purplesoft_world"
	cap_color = "purple"

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	cases = list("радужная кепка", "радужной кепки", "радужной кепке", "радужную кепку", "радужной кепкой", "радужной кепке")
	desc = "Это яркая семицветная бейсболка."
	icon_state = "rainbowsoft"
	item_state_world = "rainbowsoft_world"
	cap_color = "rainbow"

/obj/item/clothing/head/soft/sec
	name = "security cap"
	cases = list("кепка охраны", "кепки охраны", "кепке охраны", "кепку охраны", "кепкой охраны", "кепке охраны")
	desc = "Это бейсболка модного красного цвета."
	icon_state = "secsoft"
	item_state_world = "secsoft_world"
	cap_color = "sec"

/obj/item/clothing/head/soft/sec/corp
	name = "corporate security cap"
	cases = list("кепка корпоративной охраны", "кепки корпоративной охраны", "кепке корпоративной охраны", "кепку корпоративной охраны", "кепкой корпоративной охраны", "кепке корпоративной охраны")
	desc = "Это бейсболка корпоративного цвета."
	icon_state = "corpsoft"
	item_state_world = "corpsoft_world"
	cap_color = "corp"

/obj/item/clothing/head/soft/janitor
	name = "janitor cap"
	cases = list("кепка уборщика", "кепки уборщика", "кепке уборщика", "кепку уборщика", "кепкой уборщика", "кепке уборщика")
	desc = "Это форменная шапка уборщика."
	icon_state = "janitorsoft"
	item_state_world = "janitorsoft_world"
	cap_color = "janitor"
	can_get_wet = FALSE

/obj/item/clothing/head/soft/nt_pmc_cap
	name = "NT PMC Cap"
	cases = list("кепка НТ ЧВК", "кепки НТ ЧВК", "кепке НТ ЧВК", "кепку НТ ЧВК", "кепкой НТ ЧВК", "кепке НТ ЧВК")
	desc = "Тёмная кепка, использующаяся частной военной корпорацией. Выглядит неплохо."
	icon_state = "nt_pmcsoft"
	item_state_world = "nt_pmcsoft_world"
	cap_color = "nt_pmc"

/obj/item/clothing/head/soft/paramed
	name = "first responder cap"
	cases = list("кепка первой помощи", "кепки первой помощи", "кепке первой помощи", "кепку первой помощи", "кепкой первой помощи", "кепке первой помощи")
	desc = "Бейсболка парамедика. Показывает, кто тут спасает жизни."
	icon_state = "frsoft"
	item_state_world = "frsoft_world"
	cap_color = "fr"

/obj/item/clothing/head/soft/blueshield
	name = "blueshield cap"
	cases = list("кепка синего щита", "кепки синего щита", "кепке синего щита", "кепку синего щита", "кепкой синего щита", "кепке синего щита")
	desc = "Это бейсболка модного синего цвета с эмблемой синего щита."
	icon_state = "blueshieldsoft"
	item_state_world = "blueshieldsoft_world"
	cap_color = "blueshield"

/obj/item/clothing/head/soft/cargo
	name = "cargo cap"
	cases = list("кепка снабжения", "кепки снабжения", "кепке снабжения", "кепку снабжения", "кепкой снабжения", "кепке снабжения")
	desc = "Это бейсболка модного коричневого цвета."
	icon_state = "cargosoft"
	item_state_world = "cargosoft_world"
	cap_color = "cargo"

