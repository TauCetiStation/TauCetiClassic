/obj/structure/pillory
	name = "Позорный столб"
	desc = "Какой позор.."
	can_buckle = TRUE
	icon = 'icons/obj/structures/scrap/bonfire.dmi'
	icon_state = "bonfire_rod"
	anchored = TRUE
	layer = 1
	pixel_y = 16
	buckle_require_restraints = TRUE

/obj/structure/pillory/post_buckle_mob(mob/user)
	update_mob(user,1)

/obj/structure/pillory/proc/update_mob(mob/M, buckling = 0)
	if(M == buckled_mob)
		var/new_pixel_x = 0
		var/new_pixel_y = 14
		if(buckling)
			animate(M, pixel_x = new_pixel_x, pixel_y = new_pixel_y, 2, 1, LINEAR_EASING)
		else
			M.pixel_x = new_pixel_x
			M.pixel_y = new_pixel_y
	else
		animate(M, pixel_x = 0, pixel_y = 0, 2, 1, LINEAR_EASING)

/obj/item/pillory_tablet
	name = "Преступление"
	icon = 'icons/obj/structures/scrap/bonfire.dmi'
	icon_state = "tablet"
	pixel_y = 14
	layer = 11

/obj/item/pillory_tablet/text
	icon = 'icons/obj/structures/scrap/bonfire.dmi'
	icon_state = "tablet"
	name = "Преступление"
	desc = "..."
	pixel_y = 14
	layer = 11

/obj/item/pillory_tablet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pen))
		var/defaultText = ""
		var/targName = sanitize(input(usr, "Напишите преступление этого человека", "Transparant text", input_default(defaultText)))
		var/obj/item/pillory_tablet/text/W = new /obj/item/pillory_tablet/text
		W.desc = targName
		user.remove_from_mob(src)
		user.put_in_hands(W)
		qdel(src)
		to_chat(user, "<span class='notice'> Здесь написано: <span class='emojify'>[targName]</span>.")
		return

/obj/item/weapon/melee/whip
	name = "Плетка"
	desc = "Для серьезных преступлений"
	icon_state = "chain"
	item_state = "chain"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	force = 1
	hitsound = list('sound/weapons/captainwhip.ogg')
	throwforce = 1
	w_class = SIZE_SMALL
	origin_tech = "combat=4"
	attack_verb = list("выпорол")
