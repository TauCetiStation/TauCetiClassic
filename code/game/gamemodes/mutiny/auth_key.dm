/obj/item/weapon/mutiny/auth_key
	name = "authentication key"
	desc = "Better keep this safe."
	icon = 'icons/obj/items.dmi'
	icon_state = "nucleardisk"
	item_state = "card-id"
	w_class = ITEM_SIZE_TINY

	var/time_entered_space
	var/obj/item/device/radio/radio

/obj/item/weapon/mutiny/auth_key/atom_init()
	radio = new(src)
	addtimer(CALLBACK(src, .proc/keep_alive), 20 SECONDS)
	. = ..()

/obj/item/weapon/mutiny/auth_key/proc/keep_alive()
	var/in_space = istype(loc, /turf/space)
	if (!in_space && time_entered_space)
		// Recovered before the key was lost
		time_entered_space = null
	else if (in_space && !time_entered_space)
		// The key has left the station
		time_entered_space = world.time
	else if (in_space && time_entered_space + (10 SECONDS) < world.time)
		// Time is up
		radio.autosay("This device has left the station's perimeter. Triggering emergency activation failsafe.", name)
		qdel(src)
		return
	addtimer(CALLBACK(src, .proc/keep_alive), 10 SECONDS)

/obj/item/weapon/mutiny/auth_key/captain
	name = "Captain's Authentication Key"

/obj/item/weapon/mutiny/auth_key/secondary
	name = "Emergency Secondary Authentication Key"
