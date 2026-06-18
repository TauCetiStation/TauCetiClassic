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
	forceMove(S)
	S.AddElement(/datum/element/noslip_sole)
	to_chat(user, "<span class='notice'>You fit \the [src] onto \the [S].</span>")
	playsound(S, 'sound/items/lighter.ogg', VOL_EFFECTS_MASTER, 25)

// The sole obj hides inside the shoe; this element just grants NOSLIP and wires alt-click to pry it
// back off, so the shoe carries no sole-specific code or state of its own.
/datum/element/noslip_sole
	element_flags = ELEMENT_DETACH

/datum/element/noslip_sole/Attach(datum/target)
	. = ..()
	if(!istype(target, /obj/item/clothing/shoes))
		return ELEMENT_INCOMPATIBLE
	var/obj/item/clothing/shoes/S = target
	S.flags |= NOSLIP
	RegisterSignal(S, COMSIG_ATOM_ALTCLICK, PROC_REF(on_altclick))

/datum/element/noslip_sole/Detach(obj/item/clothing/shoes/S)
	. = ..()
	S.flags &= ~NOSLIP
	UnregisterSignal(S, COMSIG_ATOM_ALTCLICK)

/datum/element/noslip_sole/proc/on_altclick(obj/item/clothing/shoes/S, mob/user)
	SIGNAL_HANDLER
	if(!user.Adjacent(S))
		return
	if(user.incapacitated())
		return
	var/obj/item/noslip_sole/sole = locate() in S
	if(!sole)
		return
	user.put_in_hands(sole)
	to_chat(user, "<span class='notice'>You pry \the [sole] off \the [S].</span>")
	S.RemoveElement(/datum/element/noslip_sole)
	return COMPONENT_CANCEL_ALTCLICK
