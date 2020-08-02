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

	msg = lowertext(msg)

	if(listening)
		recorded = msg
		listening = 0
		audible_message("Activation message is '[recorded]'.", hearing_distance = 1)
	else
		if(findtext(msg, recorded))
			var/time = time2text(world.realtime,"hh:mm:ss")
			var/turf/T = get_turf(src)
			lastsignalers.Add("[time] <B>:</B> [M.ckey] activated [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> \"[recorded]\"")
			message_admins("[src] activated by [key_name_admin(M)], location ([T.x],[T.y],[T.z]) <B>:</B> \"[recorded]\" [ADMIN_JMP(usr)]")
			log_game("[src] activated by [key_name(M)], location ([T.x],[T.y],[T.z]), code: \"[recorded]\"")
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

/obj/item/device/assembly/voice/attach_assembly(obj/item/device/assembly/A, mob/user)
	. = ..()
	message_admins("[key_name_admin(user)] attached \the [A] to \the [src]. [ADMIN_JMP(user)]")
	log_game("[key_name(user)] attached \the [A] to \the [src].")
