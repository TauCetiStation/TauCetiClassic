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
	if(locate(/obj/item/noslip_sole) in S)
		to_chat(user, "<span class='warning'>\The [S] already have soles attached.</span>")
		return FALSE
	return TRUE

/obj/item/clothing/shoes/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/noslip_sole))
		return ..()
	var/obj/item/noslip_sole/sole = I
	if(!sole.can_attach_to(src, user))
		return TRUE
	user.drop_from_inventory(sole, src)
	AddElement(/datum/element/noslip_sole, sole)
	to_chat(user, "<span class='notice'>You fit \the [sole] onto \the [src].</span>")
	playsound(src, 'sound/items/lighter.ogg', VOL_EFFECTS_MASTER, 25)
	return TRUE

/obj/item/clothing/shoes/AltClick(mob/user)
	var/obj/item/noslip_sole/sole = locate() in src
	if(!sole || !Adjacent(user) || user.incapacitated())
		return ..()
	RemoveElement(/datum/element/noslip_sole)
	user.put_in_hands(sole)
	to_chat(user, "<span class='notice'>You pry \the [sole] off \the [src].</span>")
	return

/datum/element/noslip_sole
	element_flags = ELEMENT_DETACH

/datum/element/noslip_sole/Attach(datum/target, obj/item/noslip_sole/sole)
	if(!istype(target, /obj/item/clothing/shoes) || !istype(sole))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	var/obj/item/clothing/shoes/S = target
	sole.forceMove(S)
	S.flags |= NOSLIP

/datum/element/noslip_sole/Detach(obj/item/clothing/shoes/S)
	. = ..()
	S.flags &= ~NOSLIP
