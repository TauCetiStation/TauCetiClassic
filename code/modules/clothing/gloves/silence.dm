// SILENCE GLOVES
// Traitor's item to nearly mute everything in one tile
/obj/item/clothing/gloves/black/silence
	siemens_coefficient = 0.2
	var/distance = 1
	var/sound_coefficient = 0.9
	var/hide_radius_timer

/obj/item/clothing/gloves/black/silence/atom_init()
	. = ..()
	AddComponent(/datum/component/silence, distance, sound_coefficient)

/obj/item/clothing/gloves/black/silence/equipped(mob/user, slot)
	. = ..()
	if (slot == SLOT_GLOVES)
		to_chat(user, "<span class='red'>You can hear strange humming, hiding all other sounds away.</span>")
		SEND_SIGNAL(src, COMSIG_START_SUPPRESSING)
		SEND_SIGNAL(src, COMSIG_SHOW_RADIUS, user)
		hide_radius_timer = addtimer(CALLBACK(src, PROC_REF(hide_radius)), 2 SECOND, TIMER_STOPPABLE)

/obj/item/clothing/gloves/black/silence/proc/hide_radius()
	SEND_SIGNAL(src, COMSIG_HIDE_RADIUS)

/obj/item/clothing/gloves/black/silence/dropped(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Humming goes away and you can hear now.</span>")
	SEND_SIGNAL(src, COMSIG_STOP_SUPPRESSING)
	SEND_SIGNAL(src, COMSIG_HIDE_RADIUS)
	deltimer(hide_radius_timer)

// FURIOSO GLOVES
// Gloves with silence and storage capabilities
/obj/item/weapon/storage/internal/furioso
	var/list/storaged_types = list()

/obj/item/weapon/storage/internal/furioso/attackby(obj/item/I, mob/user, params)
	if (I.type in storaged_types)
		to_chat(user, "<span class='red'>There is already one [I] in storage!</span>")
		return FALSE
	. = ..()
	if(.)
		storaged_types += I.type

/obj/item/weapon/storage/internal/furioso/remove_from_storage(obj/item/W, atom/new_location, NoUpdate = FALSE)
	. = ..()
	if (.)
		storaged_types -= W.type

/obj/item/weapon/storage/internal/furioso/MouseDrop(obj/over_object, src_location, turf/over_location)
	if(over_object == usr && Adjacent(usr))
		return
	. = ..()

/obj/item/clothing/gloves/black/silence/furioso //gloves for badminery purposes
	name = "the Black Silence gloves"
	desc = "Gloves that suppresses all sound around it's wearer and can hold up to seven different types of weaponry."

	distance = 3
	siemens_coefficient = 0.0
	sound_coefficient = 1.0

	var/obj/item/weapon/storage/internal/pockets // oh yeah

/obj/item/clothing/gloves/black/silence/furioso/atom_init()
	. = ..()
	pockets = new /obj/item/weapon/storage/internal/furioso(src)
	pockets.set_slots(slots = 7, slot_size = SIZE_LARGE)
	pockets.can_hold = list(/obj/item/weapon/melee, /obj/item/weapon/gun)

/obj/item/clothing/gloves/black/silence/furioso/Destroy()
	. = ..()
	QDEL_NULL(pockets)

/obj/item/clothing/gloves/black/silence/furioso/attack_hand(mob/user)
	if (pockets && pockets.handle_attack_hand(user))
		..(user)

/obj/item/clothing/gloves/black/silence/furioso/MouseDrop(obj/over_object as obj)
	if (pockets && pockets.handle_mousedrop(usr, over_object))
		..(over_object)

/obj/item/clothing/gloves/black/silence/furioso/attackby(obj/item/I, mob/user, params)
	if(pockets && user.a_intent != INTENT_HARM && pockets.attackby(I, user, params))
		return
	return ..()

/obj/item/clothing/gloves/black/silence/furioso/emp_act(severity)
	if(pockets)
		pockets.emplode(severity)
	..()
