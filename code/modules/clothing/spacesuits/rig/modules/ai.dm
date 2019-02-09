/obj/item/rig_module/simple_ai
	name = "hardsuit automated diagnostic system"
	desc = "A system designed to help hardsuit users."
	origin_tech = "programming=2"
	interface_name = "automated diagnostic system"
	interface_desc = "System that will tell you exactly how you gonna die."
	toggleable = TRUE
	activate_on_start = TRUE
	mount_type = MODULE_MOUNT_AI
	icon_state = "IIS"

	var/list/nonimportant_messages = list()
	var/list/important_messages = list()

	// Used for detecting when some values change. Used for warning showing.
	var/saved_health // health of the rig user
	var/saved_rig_damage
	var/saved_power // percentage of the cell charge
	var/saved_stat // alive/dead detection

	var/restart_cooldown = 0
	var/tick = 0

	var/voice_name = "ADS"
	var/welcome_message = "Initilazing automatic diagnostic system, welcome"
	var/damage_message = "ERROR: automatic diagnostic system is restarting"
	var/destroyed_message = "CRITICAL DAMAGE: AUTOMATIC DIAGNOSTIC SYSTEM IS SHUTTING DOWN"

	var/list/health_warnings = list(
		list(80, "Vital signs are dropping", 'sound/rig/shortbeep.wav'), // health, message, sound
		list(40, "Vital signs are dropping. Evacuate area", 'sound/rig/shortbeep.wav'),
		list(0, "Warning: Vital signs critical. Seek medical attention", 'sound/rig/beep.wav'),
		list(-20, "Warning: Vital signs critical. Seek medical attention immediately", 'sound/rig/longbeep.wav'),
		list(-50, "Emergency. User death imminent", 'sound/rig/longbeep.wav'),
		)

	var/list/breach_warnings = list(
		list(3, "Minor breaches detected", 'sound/rig/shortbeep.wav'),
		list(6, "Severe breaches detected. Evacuate low preasure area", 'sound/rig/beep.wav'),
		list(8, "Warning: Critical breaches detected. Evacuate low preasure area immediately", 'sound/rig/longbeep.wav'),
		)

	var/list/energy_warnings = list(
		list(0.5, "Warning: hardsuit power level below 50%", 'sound/rig/shortbeep.wav'),
		list(0.3, "Warning: hardsuit power level below 30%", 'sound/rig/beep.wav'),
		list(0.1, "Warning: hardsuit power level is critically low", 'sound/rig/loudbeep.wav'), // waste 10% of remaining power by showing this message, that's the way to go!
		)

/obj/item/rig_module/simple_ai/activate(forced = FALSE)
	. = ..()
	saved_health = 100
	saved_rig_damage = 0
	saved_power = 1
	saved_stat = 0
	restart_cooldown = 0

	greet_user()

/obj/item/rig_module/simple_ai/process()
	if(damage >= MODULE_DESTROYED)
		return
	var/mob/living/carbon/human/H = holder.wearer

	if(!active)
		if(restart_cooldown > 0)
			restart_cooldown--
			if(!restart_cooldown)
				activate(forced = TRUE)
		return

	var/power_waste = 0

	if(H.stat == DEAD && saved_stat != DEAD)
		playsound(H, 'sound/rig/dead.wav', 50)
	saved_stat = H.stat

	process_warnings(H)
	if((tick++) > 3)
		tick = 0
		on_health(H)

	power_waste += rig_messages_process(H)

	return passive_power_cost + power_waste

/obj/item/rig_module/simple_ai/proc/greet_user()
	rig_message(welcome_message, message_type = "welcome")

/obj/item/rig_module/simple_ai/proc/on_rigdamage(mob/living/carbon/human/H, rig_damage)
	return

/obj/item/rig_module/simple_ai/proc/on_health(mob/living/carbon/human/H, current_health)
	return

/obj/item/rig_module/simple_ai/proc/process_warnings(mob/living/carbon/human/H)
	var/current_health = H.health
	var/health_warning = get_warning(saved_health, current_health, health_warnings)
	if(health_warning)
		rig_message(health_warning[2], message_class = "warning", message_type = "health", sound = health_warning[3])
	saved_health = current_health

	var/current_rig_damage = holder.damage
	var/rig_damage_warning = get_warning(saved_rig_damage, current_rig_damage, breach_warnings, descending = FALSE)
	if(rig_damage_warning)
		rig_message(rig_damage_warning[2], message_class = "warning", message_type = "breaches", sound = rig_damage_warning[3])
		on_rigdamage(H, current_rig_damage)
	saved_rig_damage = current_rig_damage

	var/current_power = 1
	if(holder.cell)
		current_power = holder.cell.charge / holder.cell.maxcharge
	var/rig_power_warning = get_warning(saved_power, current_power, energy_warnings)
	if(rig_power_warning)
		rig_message(rig_power_warning[2], message_class = "warning", message_type = "power", sound = rig_power_warning[3])
	saved_power = current_power

/obj/item/rig_module/simple_ai/proc/rig_messages_process(mob/living/carbon/human/H)
	var/power_waste = 0
	var/message_text
	var/message_class
	var/message_sound
	if(important_messages.len > 0)
		var/list/message = important_messages[important_messages[1]]
		message_text = message[1]
		message_class = message[2]
		message_sound = message[3]
		important_messages -= important_messages[1]
		power_waste += 100
	else if(nonimportant_messages.len > 0)
		var/list/message = nonimportant_messages[1]
		message_text = message[1]
		message_class = message[2]
		message_sound = message[3]
		nonimportant_messages -= list(message)
		power_waste += 100
	else
		return power_waste

	if(damage)
		message_text = stars(message_text, rand(50,100))
	to_chat(H, "<span class='notice'>\[[voice_name]\]</span> <span class='[message_class]'>[message_text]</span>")
	if(message_sound)
		H.playsound_local(src, message_sound, 50)

	return power_waste

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

/obj/item/rig_module/simple_ai/proc/handle_module_damage(source, obj/item/rig_module/dam_module)
	if(dam_module == src) // this module is damaged
		important_messages = list() // clearing the message queue
		nonimportant_messages = list()
		if(dam_module.damage >= MODULE_DESTROYED)
			rig_message(destroyed_message, message_class = "danger", sound = 'sound/rig/longbeep.wav')
		else
			rig_message(damage_message, message_class = "warning", sound = 'sound/rig/beep.wav')
			restart_cooldown = 10
		rig_messages_process(holder.wearer)
		return

	if(dam_module.damage >= MODULE_DESTROYED)
		rig_message("The [source] has disabled your [dam_module.interface_name]!", message_class = "warning", sound = 'sound/rig/longbeep.wav')
	else
		rig_message("The [source] has damaged your [dam_module.interface_name]!", message_class = "warning", sound = 'sound/rig/beep.wav')

/datum/rig_aivoice
	var/name = "ADS"
	var/welcome_message
	var/damage_message
	var/destroyed_message

	var/list/health_warnings
	var/list/breach_warnings
	var/list/energy_warnings

/datum/rig_aivoice/friday
	name = "FRIDAY"
	welcome_message = "Good evening, boss"
	damage_message = "The retranslator is damaged, boss. The connection is unstable, I'm atempting to restart..."
	destroyed_message = "Boss, I'm losing you..."

	health_warnings = list(
		"I'm detecting some light bruises",
		"Be carefull! Multiple injures detected",
		"Boss! Your health is reaching critical levels, evacuate immediately",
		"Please seek medical attention, you are dying!",
		"Oh no...",
		)

	breach_warnings = list(
		"The suit is taking damage, be careful",
		"Your suit can't sustain any more damage, boss",
		"The suit is breached, boss! Please find a safe place and repair it",
		)

	energy_warnings = list(
		"Power is at 50%, boss",
		"Power is running out, please recharge the suit cell",
		"The suit power is almost dead, can't help you much",
		)

/obj/item/rig_module/simple_ai/advanced
	name = "hardsuit advanced diagnostic system"
	origin_tech = "programming=4"
	interface_name = "advanced diagnostic system"
	interface_desc = "System that might actually save you, wow."

/obj/item/rig_module/simple_ai/advanced/proc/get_random_voice()
	var/voice_type = pick(subtypesof(/datum/rig_aivoice))
	if(!voice_type)
		return
	var/datum/rig_aivoice/voice = new voice_type

	voice_name = voice.name
	welcome_message = voice.welcome_message
	damage_message = voice.damage_message
	destroyed_message = voice.destroyed_message

	for (var/i in 1 to health_warnings.len)
		health_warnings[i][2] = voice.health_warnings[i]

	for (var/i in 1 to breach_warnings.len)
		breach_warnings[i][2] = voice.breach_warnings[i]

	for (var/i in 1 to energy_warnings.len)
		energy_warnings[i][2] = voice.energy_warnings[i]

	qdel(voice)

/obj/item/rig_module/simple_ai/advanced/atom_init()
	. = ..()
	get_random_voice()

/obj/item/rig_module/simple_ai/advanced/on_rigdamage(mob/living/carbon/human/H, rig_damage)
	if(rig_damage < 7)
		return
	var/obj/item/rig_module/selfrepair/repair_module = holder.find_module(/obj/item/rig_module/selfrepair/)
	if(repair_module && !repair_module.active)
		repair_module.activate(forced = TRUE)

/obj/item/rig_module/simple_ai/advanced/on_health(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return

	var/obj/item/rig_module/chem_dispenser/chem_disp = holder.find_module(/obj/item/rig_module/chem_dispenser/)
	if(!chem_disp)
		return

	if(H.getOxyLoss() > 40)
		if(try_inject(H, chem_disp, list("dexalin plus", "dexalin", "inaprovaline", "tricordrazine")))
			return
	if(H.getFireLoss() > 40)
		if(try_inject(H, chem_disp, list("dermaline", "kelotane", "tricordrazine")))
			return
	if(H.getBruteLoss() > 40)
		if(try_inject(H, chem_disp, list("bicaridine", "tricordrazine")))
			return
	if(H.traumatic_shock > 40 || H.shock_stage > 40)
		if(try_inject(H, chem_disp, list("oxycodone", "tramadol", "paracetamol")))
			return
	if(H.getToxLoss() > 20)
		if(try_inject(H, chem_disp, list("dylovene", "tricordrazine")))
			return

/obj/item/rig_module/simple_ai/advanced/proc/try_inject(mob/living/carbon/human/H, obj/item/rig_module/chem_dispenser/chem_disp, list/reagents)
	if(holder.cell.charge < chem_disp.use_power_cost)
		return TRUE

	for(var/reagent in reagents)
		if(!chem_disp.charges[reagent])
			continue

		if(H.reagents.get_reagent_amount(chem_disp.charges[reagent].product_type) > 1)
			continue

		if(chem_disp.use_charge(reagent, show_warnings = FALSE))
			holder.cell.use(chem_disp.use_power_cost)
			return TRUE
	return FALSE