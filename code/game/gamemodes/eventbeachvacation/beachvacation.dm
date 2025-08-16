
/*
 * Lounge Chair
 */

/obj/structure/stool/bed/lounge
	name = "lounge chair"
	desc = "Удобный шезлонг. Так и манит, чтобы на него прилечь."
	icon = 'icons/misc/beach.dmi'
	icon_state = "lounge"
	anchored = FALSE

/*
 * Sea Shell
 */

/obj/item/stack/seashell
	name = "sea shell"
	icon = 'icons/misc/beach.dmi'
	force = 1.0
	icon_state = "seashell"
	amount = 1
	max_amount = 20
	color = COLOR_WHITE
	desc = "Красивая переливающаяся на солнце ракушка. Кажется, собрав их много, можно выиграть! Можно соединить вместе, кликнув одной по другой."
	throwforce = 1
	w_class = SIZE_TINY
	throw_speed = 2
	throw_range = 5
	item_state = "toxinbottle"
	singular_name = "seashell"
	full_w_class = SIZE_TINY
	merge_type = /obj/item/stack/seashell


/obj/item/stack/seashell/atom_init(mapload, new_amount = null, param_color = null)
	. = ..()
	update_icon()

/obj/item/stack/seashell/update_icon()
	cut_overlays()
	if(amount > 1)
		for(var/i in 1 to amount - 1)
			add_overlay(image(icon='icons/misc/beach.dmi',icon_state="seashell", pixel_x = rand(-14,14), pixel_y = rand(-14,14)))

/*
 * Announce shell count - admin verb
 */

/client/proc/seashell_count()
	set name = "Announce Sea Shell Count"
	set category = "Fun"

	if(!check_rights(R_FUN))
		return

	if(!player_list.len)
		to_chat(usr, "player list is empty!")
		return

	var/list/winners_list = list()
	for(var/mob/living/carbon/human/H in player_list)
		var/shell_amount = 0
		var/list/items_to_check = H.GetAllContents()
		for(var/A in items_to_check)
			if(istype(A, /obj/item/stack/seashell))
				var/obj/item/stack/seashell/S = A
				shell_amount += S.amount
		winners_list[H.name] = shell_amount
	sortTim(winners_list, GLOBAL_PROC_REF(cmp_numeric_dsc), associative=TRUE)

	var/message = ""
	var/position = 0
	for(var/key in winners_list)
		position++
		message += "<br> [position]: [key] - [winners_list[key]] ракушек. "
		if(position == 1)
			message += "Лидер!"
		else if(position == 12)
			break

	var/datum/announcement/centcomm/shellannouncement/announcement_finished = new
	announcement_finished.message = message
	announcement_finished.play()


/datum/announcement/centcomm/shellannouncement
	name = "Таблица лидеров по собранным ракушкам:"
	subtitle = ""
	sound = "commandreport"


/*
 * Dodge Ball
 */

/obj/item/weapon/beach_ball/dodgeball
	name = "dodge ball"
	desc = "Используется для игры Вышибалы. Стоять останутся только сильнейшие."
	icon_state = "dodgeball"
	item_state = "dodgeball"
	w_class = SIZE_NORMAL //Stops people from hiding it in their bags/pockets

/obj/item/weapon/beach_ball/dodgeball/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		playsound(src, 'sound/items/dodgeball.ogg', 50, TRUE)
		H.apply_effect(4, PARALYZE)
		H.visible_message("<span class='warning'>[H] сбит с ног!</span>")

/*
 * Pina Colada
 */

/datum/reagent/consumable/ethanol/pinacolada
	name = "Pina Colada"
	description = "A fresh pineapple drink with coconut rum. Yum."
	id = "pinacolada"
	boozepwr = 1.5
	color = "#FFF1B2"
	taste_message = "pineapple, coconut, and a hint of the ocean"

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pinacolada
	name = "Pina Colada"
	icon_state = "pinacolada"
	list_reagents = list("pinacolada" = 25)
