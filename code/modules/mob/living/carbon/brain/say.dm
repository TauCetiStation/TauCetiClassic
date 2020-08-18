
/mob/living/carbon/brain/say(var/message)
	if (silent)
		return
	if(container)
		if(istype(container, /obj/item/device/mmi) || istype(container, /obj/item/device/mmi/posibrain))
			message = sanitize(message)
			if ((department_radio_keys[copytext(message, 1, 2 + length(message[2]))] == "binary") && (container && istype(container, /obj/item/device/mmi/posibrain)))
				message = copytext(message, 2 + length(message[2]))
				message = trim(message)
				robot_talk(message)
				return
			if(prob(emp_damage*4))
				if(prob(10))//10% chane to drop the message entirely
					return
				else
					message = Gibberish(message, (emp_damage*6))//scrambles the message, gets worse when emp_damage is higher
			if(istype(container, /obj/item/device/mmi/radio_enabled))
				var/obj/item/device/mmi/radio_enabled/R = container
				if(R.radio)
					spawn(0) R.radio.hear_talk(src, message)
			..(message, sanitize = 0)
		if(istype(container, /obj/item/device/biocan))
			var/obj/item/device/biocan/B = container
			if(B.commutator_enabled)
				..(sanitize(message), sanitize = 0)
			else
				return
		if(istype(container, /obj/item/organ/external/head/skeleton)) // Why not, talking skeleton heads are funny
			..(sanitize(message), sanitize = 0)