/obj/item/noslip_sole
	name = "anti-slip soles"
	desc = "A pair of rubberized soles with aggressive tread. Attach them to any footwear to keep your footing on slippery surfaces."
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "noslip_sole"
	w_class = SIZE_TINY
	origin_tech = "syndicate=3"

/obj/item/clothing/shoes/var/obj/item/noslip_sole/installed_sole

/obj/item/clothing/shoes/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/noslip_sole))
		if(istype(src, /obj/item/clothing/shoes/magboots))
			to_chat(user, "<span class='warning'>The soles won't fit over the magnetic boots.</span>")
			return
		if(flags & NOSLIP)
			to_chat(user, "<span class='warning'>\The [src] already have good grip.</span>")
			return
		user.drop_from_inventory(I, src)
		installed_sole = I
		flags |= NOSLIP
		to_chat(user, "<span class='notice'>You fit \the [I] onto \the [src].</span>")
		playsound(src, 'sound/items/lighter.ogg', VOL_EFFECTS_MASTER, 25)
		return
	return ..()

/obj/item/clothing/shoes/AltClick(mob/user)
	if(installed_sole && Adjacent(user) && !user.incapacitated())
		flags &= ~NOSLIP
		var/obj/item/noslip_sole/S = installed_sole
		installed_sole = null
		S.forceMove(get_turf(src))
		user.put_in_hands(S)
		to_chat(user, "<span class='notice'>You pry \the [S] off \the [src].</span>")
		return
	return ..()
