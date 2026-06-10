/obj/item/noslip_sole
	name = "anti-slip soles"
	desc = "A pair of rubberized soles with aggressive tread. Attach them to any footwear to keep your footing on slippery surfaces."
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "noslip_sole"
	w_class = SIZE_TINY
	origin_tech = "syndicate=3"

/obj/item/noslip_sole/proc/can_attach_to(obj/item/clothing/shoes/S, mob/user)
	if(istype(S, /obj/item/clothing/shoes/magboots))
		to_chat(user, "<span class='warning'>The soles won't fit over the magnetic boots.</span>")
		return FALSE
	if(S.flags & NOSLIP)
		to_chat(user, "<span class='warning'>\The [S] already have good grip.</span>")
		return FALSE
	return TRUE

/obj/item/clothing/shoes/atom_init()
	. = ..()
	AddElement(/datum/element/sole_attachable)

/obj/item/clothing/shoes/AltClick(mob/user)
	var/obj/item/noslip_sole/sole = locate() in src
	if(sole && Adjacent(user) && !user.incapacitated())
		flags &= ~NOSLIP
		sole.forceMove(get_turf(src))
		user.put_in_hands(sole)
		to_chat(user, "<span class='notice'>You pry \the [sole] off \the [src].</span>")
		return
	return ..()
