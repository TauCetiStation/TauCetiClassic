/obj/item/weapon/gun/magic/change
	name = "staff of change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "staffofchange"
	item_state = "staffofchange"
	fire_delay = 30
	max_charges = 1

/obj/item/weapon/gun/magic/animate
	name = "staff of animation"
	desc = "An artefact that spits bolts of life-force which causes objects which are hit by it to animate and come to life! This magic doesn't affect machines."
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "staffofanimation"
	item_state = "staffofanimation"
	item_color = "staffofanimation"

/obj/item/weapon/gun/magic/healing
	name = "staff of healing"
	desc = "An artefact that spits bolts of restoring magic which can remove ailments of all kinds and even raise the dead."
	ammo_type = /obj/item/ammo_casing/magic/heal
	icon_state = "staffofhealing"
	item_state = "staffofhealing"
	fire_sound = 'sound/magic/Staff_Healing.ogg'

/obj/item/weapon/gun/magic/doorcreation
	name = "staff of door creation"
	desc = "An artefact that spits bolts of transformative magic that can create doors in walls."
	ammo_type = /obj/item/ammo_casing/magic/door
	icon_state = "staffofdoor"
	item_state = "staffofdoor"
	fire_sound = 'sound/magic/Staff_Door.ogg'

/*
/obj/item/weapon/gun/energy/staff/focus
	name = "mental focus"
	desc = "An artefact that channels the will of the user into destructive bolts of force. If you aren't careful with it, you might poke someone's brain out."
	icon_state = "focus"
	item_state = "focus"
	projectile_type = "/obj/item/projectile/forcebolt"

/obj/item/weapon/gun/energy/staff/focus/attack_self(mob/living/user)
	if(projectile_type == "/obj/item/projectile/forcebolt")
		charge_cost = 200
		to_chat(user, "<span class='warning'>The [src.name] will now strike a small area.</span>")
		projectile_type = "/obj/item/projectile/forcebolt/strong"
	else
		charge_cost = 100
		to_chat(user, "<span class='warning'>The [src.name] will now strike only a single person.</span>")
		projectile_type = "/obj/item/projectile/forcebolt"
*/
