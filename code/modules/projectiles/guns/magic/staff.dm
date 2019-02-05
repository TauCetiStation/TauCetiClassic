/obj/item/weapon/gun/magic/staff
	slot_flags = SLOT_BACK
	icon_state = "staff"
	w_class = 4

/obj/item/weapon/gun/magic/staff/change
	name = "staff of change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "staffofchange"
	item_state = "staffofchange"
	fire_delay = 30

/obj/item/weapon/gun/magic/staff/animate
	name = "staff of animation"
	desc = "An artefact that spits bolts of life-force which causes objects which are hit by it to animate and come to life! This magic doesn't affect machines."
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "staffofanimation"
	item_state = "staffofanimation"
	item_color = "staffofanimation"

/obj/item/weapon/gun/magic/staff/healing
	name = "staff of healing"
	desc = "An artefact that spits bolts of restoring magic which can remove ailments of all kinds and even raise the dead."
	ammo_type = /obj/item/ammo_casing/magic/heal
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staffofhealing"
	item_state = "staffofhealing"
	fire_sound = 'sound/magic/Staff_Healing.ogg'

/obj/item/weapon/gun/magic/staff/doorcreation
	name = "staff of door creation"
	desc = "An artefact that spits bolts of transformative magic that can create doors in walls."
	ammo_type = /obj/item/ammo_casing/magic/door
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staffofdoor"
	item_state = "staffofdoor"
	fire_sound = 'sound/magic/Staff_Door.ogg'
