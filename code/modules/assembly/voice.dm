/obj/item/device/assembly/voice
	name = "voice analyzer"
	desc = "A small electronic device able to record a voice sample, and send a signal when that sample is repeated."
	icon_state = "voice"
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	origin_tech = "magnets=1"
	m_amt = 500
	g_amt = 50

	var/listening = 0
	var/recorded = "" //the activation message


/obj/item/device/assembly/voice/hear_talk(mob/living/M, msg)

	msg = lowertext_(sanitize(msg))
	
	if(listening)
		recorded = msg
		listening = 0
		audible_message("Activation message is '[recorded]'.", hearing_distance = 1)
	else
		if(findtext(msg, recorded))
			audible_message("Beeeep", hearing_distance = 1)
			spawn(10)
				pulse(0)

/obj/item/device/assembly/voice/activate()
	if(secured)
		if(!holder)
			listening = !listening
			audible_message("[listening ? "Now" : "No longer"] recording input.", hearing_distance = 1)

/obj/item/device/assembly/voice/attack_self(mob/user)
	if(!user)
		return 0
	activate()
	return 1

/obj/item/device/assembly/voice/toggle_secure()
	. = ..()
	listening = 0
