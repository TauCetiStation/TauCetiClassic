/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	item_state = "magboots"
	var/magpulse = 0
	var/magboot_state = "magboots"
	var/slowdown_off = 2
	action_button_name = "Toggle Magboots"
	origin_tech = "materials=3;magnets=4;engineering=4"
//	flags = NOSLIP //disabled by default

/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	if(magpulse)
		flags &= ~(NOSLIP | AIR_FLOW_PROTECT)
		slowdown = SHOES_SLOWDOWN
		magpulse = 0
		icon_state = "[magboot_state]0"
		to_chat(user, "You disable the mag-pulse traction system.")
	else
		flags |= NOSLIP | AIR_FLOW_PROTECT
		slowdown = slowdown_off
		magpulse = 1
		icon_state = "[magboot_state]1"
		to_chat(user, "You enable the mag-pulse traction system.")
	update_inv_mob()
	user.update_gravity(user.mob_has_gravity())

/obj/item/clothing/shoes/magboots/examine(mob/user)
	..()
	var/state = "disabled"
	if(src.flags & (NOSLIP | AIR_FLOW_PROTECT))
		state = "enabled"
	to_chat(user, "Its mag-pulse traction system appears to be [state].")

/obj/item/clothing/shoes/magboots/negates_gravity()
	return flags & NOSLIP
