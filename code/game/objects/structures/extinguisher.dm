/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_empty_closed"
	anchored = 1
	density = 0
	var/obj/item/weapon/reagent_containers/spray/extinguisher/has_extinguisher
	var/opened = 0

/obj/structure/extinguisher_cabinet/atom_init()
	. = ..()
	if(!has_extinguisher)
		has_extinguisher = new/obj/item/weapon/reagent_containers/spray/extinguisher/station_spawned(src)
	update_icon()

/obj/structure/extinguisher_cabinet/attackby(obj/item/O, mob/user)
	if(isrobot(user) || isxeno(user))
		return
	if(istype(O, /obj/item/weapon/reagent_containers/spray/extinguisher))
		if(!has_extinguisher && opened)
			user.drop_item()
			contents += O
			has_extinguisher = O
			to_chat(user, "<span class='notice'>You place [O] in [src].</span>")
		else
			opened = !opened
	else
		opened = !opened
	update_icon()


/obj/structure/extinguisher_cabinet/attack_hand(mob/user)
	if(isrobot(user) || isxeno(user))
		return
	if(has_extinguisher)
		user.put_in_hands(has_extinguisher)
		to_chat(user, "<span class='notice'>You take [has_extinguisher] from [src].</span>")
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(has_extinguisher)
		has_extinguisher.forceMove(loc)
		to_chat(user, "<span class='notice'>You telekinetically remove [has_extinguisher] from [src].</span>")
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_paw(mob/user)
	attack_hand(user)
	return


/obj/structure/extinguisher_cabinet/update_icon()
	var/FE = "empty"
	if(has_extinguisher)
		FE = has_extinguisher.FE_type
	if(opened)
		icon_state = "extinguisher_[FE]"
	else
		icon_state = "extinguisher_[FE]_closed"

/obj/structure/extinguisher_cabinet/highrisk
	name = "expensive extinguisher cabinet"
	icon_state = "extinguisher_golden_closed"

/obj/structure/extinguisher_cabinet/highrisk/atom_init()
	. = ..()
	has_extinguisher = new/obj/item/weapon/reagent_containers/spray/extinguisher/golden(src)
