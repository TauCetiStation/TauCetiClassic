/obj/item/rig_module/simple_ai
	name = "hardsuit automated diagnostic system"
	origin_tech = list(TECH_MAGNET = 2, TECH_MATERIAL = 2, TECH_ENGINEERING = 5)
	interface_name = "automated diagnostic system"
	interface_desc = "System that will tell you exactly how you gonna die."

	var/list/nonimportant_messages = list()
	var/list/important_messages = list()

	var/saved_health
	var/saved_rig_damage

	var/list/health_warnings = list(
		list(80, "Vital signs are dropping", 'sound/rig/shortbeep.wav'), // health, message
		list(40, "Vital signs are dropping. Evacuate area", 'sound/rig/shortbeep.wav'),
		list(0, "Warning: Vital signs critical. Seek medical attention", 'sound/rig/loudbeep.wav'),
		list(-20, "Warning: Vital signs critical. Seek medical attention immediately", 'sound/rig/longbeep.wav'),
		list(-50, "Emergency. User death imminent", 'sound/rig/longbeep.wav'),
		)

	var/list/breach_warnings = list(
		list(3, "Minor breaches detected", 'sound/rig/shortbeep.wav'),
		list(6, "Severe breaches detected. Evacuate low preasure area", 'sound/rig/loudbeep.wav'),
		list(8, "Warning: Critical breaches detected. Evacuate low preasure area immediately", 'sound/rig/longbeep.wav'),
		)

/obj/item/rig_module/simple_ai/process()
	var/mob/living/carbon/human/H = holder.wearer
	if(!istype(H))
		return passive_power_cost

	if(!active)
		if(!activate())
			return passive_power_cost
		saved_health = 100
		saved_rig_damage = 0

		greet_user()

	var/power_waste = 0

	var/current_health = H.health
	var/health_warning = get_warning(saved_health, current_health, health_warnings)
	if(health_warning)
		rig_message(health_warning[2], message_class = "warning", message_type = "health", sound = health_warning[3])
	saved_health = current_health

	var/current_rig_damage = holder.damage
	var/rig_damage_warning = get_warning(saved_rig_damage, current_rig_damage, breach_warnings, descending = FALSE)
	if(rig_damage_warning)
		rig_message(rig_damage_warning[2], message_class = "warning", message_type = "breaches", sound = rig_damage_warning[3])

	saved_rig_damage = current_rig_damage

	if(important_messages.len > 0)
		var/list/message = important_messages[important_messages[1]]
		var/message_text = message[1]
		var/message_class = message[2]
		to_chat(H, "<span class='[message_class]'>[message_text]</span>")
		if(message[3])
			playsound(src, message[3], 50, 0)
		important_messages -= important_messages[1]
		power_waste += 100
	else if(nonimportant_messages.len > 0)
		var/list/message = nonimportant_messages[1]
		var/message_text = message[1]
		var/message_class = message[2]
		to_chat(H, "<span class='[message_class]'>[message_text]</span>")
		if(message[3])
			playsound(src, message[3], 50, 0)
		nonimportant_messages -= message
		power_waste += 100

	return passive_power_cost + power_waste

/obj/item/rig_module/simple_ai/proc/greet_user()
	rig_message("Initilazing automatic diagnostic system, welcome", message_type = "welcome")

// does some basic queue and priority managment
/obj/item/rig_module/simple_ai/proc/rig_message(text, message_class = "notice", message_type = null, sound = null)
	if(!message_type)
		nonimportant_messages += list(list(text, message_class, sound))
	else
		important_messages[message_type] = list(text, message_class, sound)
	return TRUE

/obj/item/rig_module/simple_ai/proc/get_warning(old_value, new_value, list/values, descending = TRUE)
	var/old_warning = null
	var/new_warning = null

	if(descending)
		for(var/list/value in values)
			if(old_value <= value[1])
				old_warning = value
			if(new_value <= value[1])
				new_warning = value
	else
		for(var/list/value in values)
			if(old_value >= value[1])
				old_warning = value
			if(new_value >= value[1])
				new_warning = value


	if(!new_warning)
		return null

	if(old_warning != new_warning)
		if(descending && new_value < old_value)
			return new_warning
		if(!descending && new_value > old_value)
			return new_warning

	return null