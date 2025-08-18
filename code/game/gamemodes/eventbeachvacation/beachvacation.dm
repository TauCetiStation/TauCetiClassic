
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
	w_class = SIZE_MINUSCULE
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
			add_overlay(image(icon='icons/misc/beach.dmi',icon_state="seashell", pixel_x = rand(-12,12), pixel_y = rand(-12,12)))

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
				if(isnum(S.amount))
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
		H.apply_effect(1, PARALYZE)
		H.visible_message("<span class='warning'><b>[H] сбит с ног!</b></span>")

/*
 * Pina Colada
 */

/datum/reagent/consumable/ethanol/pinacolada
	name = "Pina Colada"
	description = "A fresh pineapple drink with coconut rum. Yum."
	id = "pinacolada"
	boozepwr = 1.5
	color = "#fceeb1"
	taste_message = "pineapple, coconut, and a hint of the ocean"

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pinacolada
	name = "Pina Colada"
	icon_state = "pinacolada"
	list_reagents = list("pinacolada" = 25)

/*
 * Ukulele
 */

/obj/item/device/guitar/ukulele
	name = "ukulele"
	icon_state = "ukulele"
	item_state = "ukulele"
	hitsound = list('sound/musical_instruments/ukulele/1hit.ogg')
	sound_path = "sound/musical_instruments/ukulele"

/*
 * Beach Umbrella
 */

/obj/structure/beach_umbrella
	name = "beach umbrella"
	desc = "A fancy umbrella designed to keep the sun off beach-goers."
	icon = 'icons/misc/beach.dmi'
	icon_state = "brella"
	density = FALSE
	anchored = FALSE

/obj/structure/beach_umbrella/security
	icon_state = "hos_brella"

/obj/structure/beach_umbrella/science
	icon_state = "rd_brella"

/obj/structure/beach_umbrella/engine
	icon_state = "ce_brella"

/obj/structure/beach_umbrella/cap
	icon_state = "cap_brella"

/obj/structure/beach_umbrella/syndi
	icon_state = "syndi_brella"

/*
 * Beach Vending
 */

/obj/machinery/vending/vacation
	name = "Vacation-o-mat"
	desc = "Special costume pack for your vacation."
	icon_state = "Vacation"
	products = list(
		/obj/item/clothing/under/swimsuit/black = 5,
		/obj/item/clothing/under/swimsuit/blue = 5,
		/obj/item/clothing/under/swimsuit/purple = 5,
		/obj/item/clothing/under/swimsuit/green = 5,
		/obj/item/clothing/under/swimsuit/red = 5,
		/obj/item/clothing/mask/snorkel = 5,
		/obj/item/clothing/shoes/swimmingfins = 5,
		/obj/item/clothing/shoes/sandal/pink = 5,
		/obj/item/clothing/shoes/sandal = 5,
		/obj/item/clothing/glasses/sunglasses = 5,
		/obj/item/clothing/glasses/sunglasses/big = 5,
		/obj/item/clothing/suit/monkeysuit = 5,
		/obj/item/clothing/head/collectable/petehat = 5,
		/obj/item/clothing/head/kitty = 5,
		/obj/item/clothing/head/cardborg = 5,
		/obj/item/clothing/suit/cardborg = 5,
		/obj/item/clothing/head/bearpelt = 5,
		/obj/item/clothing/mask/fakemoustache = 5,
		/obj/item/weapon/storage/backpack/santabag = 5,
		/obj/item/clothing/mask/gas/sexyclown = 5,
		/obj/item/clothing/mask/gas/sexymime = 5,
		/obj/item/clothing/mask/horsehead = 5,
		/obj/item/clothing/under/dress/dress_purple = 5,
		/obj/item/clothing/under/sundress = 5,
		/obj/item/clothing/under/roman = 3,
		/obj/item/clothing/shoes/roman = 3,
		/obj/item/clothing/head/helmet/roman = 2,
		/obj/item/clothing/head/helmet/roman/legionaire = 1,
		/obj/item/clothing/under/popking = 1,
		/obj/item/clothing/under/popking/alternate = 1,
		/obj/item/clothing/mask/fake_face = 2,
		/obj/item/clothing/suit/hooded/ian_costume = 1,
		/obj/item/clothing/suit/hooded/carp_costume = 1,
		/obj/item/clothing/head/that = 4,
		/obj/item/clothing/head/fedora = 2,
		/obj/item/clothing/glasses/monocle = 2,
		/obj/item/clothing/suit/jacket = 4,
		/obj/item/clothing/head/chep = 2,
		/obj/item/clothing/suit/jacket/puffer/vest = 4,
		/obj/item/clothing/suit/jacket/puffer = 4,
		/obj/item/clothing/suit/jacket/letterman = 2,
		/obj/item/clothing/suit/jacket/letterman_red = 2,
		/obj/item/clothing/under/kilt = 2,
		/obj/item/clothing/under/overalls = 2,
		/obj/item/clothing/under/suit_jacket/really_black = 4,
		/obj/item/clothing/under/suit_jacket/rouge = 4,
		/obj/item/clothing/under/pants/jeans = 6,
		/obj/item/clothing/under/pants/classicjeans = 4,
		/obj/item/clothing/under/pants/camo = 2,
		/obj/item/clothing/under/pants/blackjeans = 4,
		/obj/item/clothing/under/pants/khaki = 4,
		/obj/item/clothing/under/pants/white = 4,
		/obj/item/clothing/under/pants/red = 2,
		/obj/item/clothing/under/pants/black = 4,
		/obj/item/clothing/under/pants/tan = 4,
		/obj/item/clothing/under/pants/blue = 2,
		/obj/item/clothing/under/pants/track = 2,
		/obj/item/clothing/under/sundress = 4,
		/obj/item/clothing/under/blacktango = 2,
		/obj/item/clothing/suit/jacket = 6,
		/obj/item/clothing/glasses/regular = 4,
		/obj/item/clothing/head/sombrero = 2,
		/obj/item/clothing/suit/poncho = 2,
		/obj/item/clothing/suit/ianshirt = 1,
		/obj/item/clothing/shoes/laceup = 4,
		/obj/item/clothing/shoes/sandal = 2,
		/obj/item/clothing/head/byzantine_hat = 1,
		/obj/item/clothing/suit/byzantine_dress = 1,
		/obj/item/clothing/mask/bandana/black = 2,
		/obj/item/clothing/mask/bandana/skull = 2,
		/obj/item/clothing/mask/bandana/green = 2,
		/obj/item/clothing/mask/bandana/gold = 2,
		/obj/item/clothing/mask/bandana/blue = 2,
		/obj/item/clothing/suit/student_jacket = 3,
		/obj/item/clothing/suit/shawl = 2,
		/obj/item/clothing/suit/atlas_jacket = 4,
		/obj/item/clothing/under/sukeban_pants = 2,
		/obj/item/clothing/under/sukeban_dress = 2,
		/obj/item/clothing/suit/sukeban_coat = 4,
		/obj/item/clothing/under/pinkpolo = 3,
		/obj/item/clothing/under/pretty_dress = 1,
		/obj/item/clothing/under/dress/dress_summer = 2,
		/obj/item/clothing/under/dress/dress_vintage = 2,
		/obj/item/clothing/under/dress/dress_evening = 2,
		/obj/item/clothing/under/dress/dress_party = 2,
		/obj/item/clothing/glasses/aviator_orange = 2,
		/obj/item/clothing/glasses/aviator_black = 2,
		/obj/item/clothing/glasses/aviator_red = 2,
		/obj/item/clothing/glasses/aviator_mirror = 2,
		/obj/item/clothing/glasses/jerusalem = 2,
		/obj/item/clothing/glasses/threedglasses = 2,
		/obj/item/clothing/glasses/gar = 2,
	)
	private = TRUE
