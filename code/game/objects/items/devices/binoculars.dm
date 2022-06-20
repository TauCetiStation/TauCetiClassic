/obj/item/device/binoculars
	name = "binoculars"
	icon_state = "binoculars"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_TINY

/obj/item/device/binoculars/atom_init()
	. = ..()
	AddComponent(/datum/component/zoom, 12, TRUE)

/obj/item/device/binoculars/attack_self(mob/user)
	SEND_SIGNAL(src, COMSIG_ZOOM_TOGGLE, user)
