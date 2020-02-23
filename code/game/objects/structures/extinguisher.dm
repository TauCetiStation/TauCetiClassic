/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_empty_closed"
	anchored = TRUE
	density = FALSE
	var/extinguisher_type = /obj/item/weapon/reagent_containers/spray/extinguisher/station_spawned
	var/obj/item/weapon/reagent_containers/spray/extinguisher/has_extinguisher = null
	var/opened = FALSE

/obj/structure/extinguisher_cabinet/atom_init()
	. = ..()
	if(!has_extinguisher)
		has_extinguisher = new extinguisher_type(src)
	update_icon()

/obj/structure/extinguisher_cabinet/Destroy()
	QDEL_NULL(has_extinguisher)
	return ..()

/obj/structure/extinguisher_cabinet/attackby(obj/item/O, mob/user)
	if(isrobot(user) || isxeno(user))
		return

	if(istype(O, /obj/item/weapon/reagent_containers/spray/extinguisher) && !has_extinguisher && opened)
		user.drop_item()
		O.forceMove(src)
		has_extinguisher = O
		user.visible_message("<span class='notice'>[user] places \the [O] in \the [src].</span>", "<span class='notice'>You place \the [O] in \the [src].</span>")
	else
		opened = !opened

	update_icon()

/obj/structure/extinguisher_cabinet/attack_hand(mob/user)
	if(isrobot(user) || isxeno(user))
		return

	if(has_extinguisher)
		user.put_in_hands(has_extinguisher)
		user.visible_message("<span class='notice'>[user] takes \the [has_extinguisher] from \the [src].</span>", "<span class='notice'>You take \the [has_extinguisher] from \the [src].</span>")
		has_extinguisher = null
		opened = TRUE
	else
		opened = !opened

	update_icon()

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(has_extinguisher)
		has_extinguisher.forceMove(loc)
		to_chat(user, "<span class='notice'>You telekinetically remove \the [has_extinguisher] from \the [src].</span>")
		has_extinguisher = null
		opened = TRUE
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_paw(mob/user)
	attack_hand(user)
	return


/obj/structure/extinguisher_cabinet/update_icon()
	var/FE = has_extinguisher?.FE_type || "empty"

	if(opened)
		icon_state = "extinguisher_[FE]"
	else
		icon_state = "extinguisher_[FE]_closed"

/obj/structure/extinguisher_cabinet/highrisk
	name = "expensive extinguisher cabinet"
	icon_state = "extinguisher_golden_closed"
	extinguisher_type = /obj/item/weapon/reagent_containers/spray/extinguisher/golden
