/obj/item/device/radio/intercom
	name = "station intercom"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = 1
	w_class = ITEM_SIZE_LARGE
	canhear_range = 2
	flags = CONDUCT | NOBLOODY
	var/number = 0
	var/anyai = 1
	var/mob/living/silicon/ai/ai = list()

/obj/item/device/radio/intercom/attack_ai(mob/user)
	src.add_fingerprint(user)
	INVOKE_ASYNC(src, .proc/attack_self, user)

/obj/item/device/radio/intercom/attack_paw(mob/user)
	to_chat(user, "<span class='info'>The console controls are far too complicated for your tiny brain!</span>")
	return


/obj/item/device/radio/intercom/attack_hand(mob/user)
	src.add_fingerprint(user)
	INVOKE_ASYNC(src, .proc/attack_self, user)

/obj/item/device/radio/intercom/receive_range(freq, level)
	if (!on)
		return -1
	if (wires.is_index_cut(RADIO_WIRE_RECEIVE))
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.z in level))
			return -1
	if (!src.listening)
		return -1
	if(freq == SYND_FREQ)
		if(!(src.syndie))
			return -1//Prevents broadcast of messages over devices lacking the encryption

	return canhear_range


/obj/item/device/radio/intercom/hear_talk(mob/M, msg)
	if(!src.anyai && !(M in src.ai))
		return
	..()

/obj/item/device/radio/intercom/proc/power_change()
	var/area/A = get_area(src)
	if(!A)
		on = 0
	else
		on = A.powered(STATIC_EQUIP) // set "on" to the power status

	if(!on)
		icon_state = "intercom-p"
	else
		icon_state = "intercom"
