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

/obj/item/noslip_sole/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity || !istype(target, /obj/item/clothing/shoes))
		return
	var/obj/item/clothing/shoes/S = target
	if(!can_attach_to(S, user))
		return
	S.AddComponent(/datum/component/noslip_sole, src)
	to_chat(user, "<span class='notice'>You fit \the [src] onto \the [S].</span>")
	playsound(S, 'sound/items/lighter.ogg', VOL_EFFECTS_MASTER, 25)

// Lives on the shoe; the sole hides inside it, grants NOSLIP and pops back off on alt-click.
/datum/component/noslip_sole
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/obj/item/noslip_sole/sole

/datum/component/noslip_sole/Initialize(obj/item/noslip_sole/attached_sole)
	if(!istype(parent, /obj/item/clothing/shoes))
		return COMPONENT_INCOMPATIBLE
	sole = attached_sole
	var/obj/item/clothing/shoes/S = parent
	sole.forceMove(S)
	S.flags |= NOSLIP
	RegisterSignal(parent, COMSIG_ATOM_ALTCLICK, PROC_REF(on_altclick))

/datum/component/noslip_sole/Destroy(force, silent)
	var/obj/item/clothing/shoes/S = parent
	if(istype(S))
		S.flags &= ~NOSLIP
	sole = null
	return ..()

/datum/component/noslip_sole/proc/on_altclick(obj/item/clothing/shoes/S, mob/user)
	SIGNAL_HANDLER
	if(!user.Adjacent(S) || user.incapacitated())
		return
	var/obj/item/noslip_sole/released = sole
	released.forceMove(get_turf(S))
	user.put_in_hands(released)
	to_chat(user, "<span class='notice'>You pry \the [released] off \the [S].</span>")
	qdel(src)
	return COMPONENT_CANCEL_ALTCLICK
