// Lets any footwear receive a /obj/item/noslip_sole (click the sole on the shoe to attach).
// Stateless: the attached sole just lives in the shoe's contents; removal is the shoe's AltClick.
/datum/element/sole_attachable
	element_flags = ELEMENT_DETACH

/datum/element/sole_attachable/Attach(datum/target)
	. = ..()
	if(!istype(target, /obj/item/clothing/shoes))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))

/datum/element/sole_attachable/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_PARENT_ATTACKBY)
	return ..()

/datum/element/sole_attachable/proc/on_attackby(obj/item/clothing/shoes/source, obj/item/W, mob/user, params)
	SIGNAL_HANDLER
	if(!istype(W, /obj/item/noslip_sole))
		return
	var/obj/item/noslip_sole/sole = W
	if(!sole.can_attach_to(source, user))
		return COMPONENT_NO_AFTERATTACK
	user.drop_from_inventory(sole, source)
	source.flags |= NOSLIP
	to_chat(user, "<span class='notice'>You fit \the [sole] onto \the [source].</span>")
	playsound(source, 'sound/items/lighter.ogg', VOL_EFFECTS_MASTER, 25)
	return COMPONENT_NO_AFTERATTACK
