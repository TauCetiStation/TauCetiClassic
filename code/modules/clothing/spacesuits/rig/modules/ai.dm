/datum/rig_message
	var/text // what will be shown to the user
	var/class // css class like warning or notice
	var/sound // optional sound

/datum/rig_message/New(Text, Class, Sound)
	text = Text
	class = Class
	sound = Sound

/datum/rig_warning
	var/value // at what value should we display this warning
	var/message // text of the warning shown to the user
	var/sound // what sound should the suit play to the user

/datum/rig_warning/New(Value, Message, Sound)
	value = Value
	message = Message
	sound = Sound

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

	var/list/message_queue = list() // associative list of /datum/rig_message

	// Used for detecting when some values change. Used for warning showing.
	var/saved_health // health of the rig user
	var/saved_rig_damage // how damaged is the rig
	var/saved_power // percentage of the cell charge
	var/saved_stat // alive/dead detection

	var/restart_cooldown = 0
	var/tick = 0

	var/voice_name = "ADS"
	var/welcome_message = "Initilazing automatic diagnostic system, welcome"
	var/damage_message = "ERROR: automatic diagnostic system is restarting"
	var/destroyed_message = "CRITICAL DAMAGE: AUTOMATIC DIAGNOSTIC SYSTEM IS SHUTTING DOWN"

	// these are lists of /datum/rig_warning
	var/list/health_warnings
	var/list/breach_warnings
	var/list/energy_warnings

/obj/item/rig_module/simple_ai/atom_init()
	. = ..()
	health_warnings = list(
		new /datum/rig_warning(90,  "Vital signs are dropping",                                          'sound/rig/shortbeep.wav'), // health, message, sound
		new /datum/rig_warning(40,  "Vital signs are dropping. Evacuate area",                           'sound/rig/shortbeep.wav'),
		new /datum/rig_warning(0,   "Warning: Vital signs critical. Seek medical attention",             'sound/rig/beep.wav'),
		new /datum/rig_warning(-20, "Warning: Vital signs critical. Seek medical attention immediately", 'sound/rig/longbeep.wav'),
		new /datum/rig_warning(-50, "Emergency. User death imminent",                                    'sound/rig/longbeep.wav'),
		)

	breach_warnings = list(
		new /datum/rig_warning(3, "Minor breaches detected",                                                     'sound/rig/shortbeep.wav'),
		new /datum/rig_warning(6, "Severe breaches detected. Evacuate low preasure area",                        'sound/rig/beep.wav'),
		new /datum/rig_warning(8, "Warning: Critical breaches detected. Evacuate low preasure area immediately", 'sound/rig/longbeep.wav'),
		)

	energy_warnings = list(
		new /datum/rig_warning(0.5, "Warning: hardsuit power level below 50%",         'sound/rig/shortbeep.wav'),
		new /datum/rig_warning(0.3, "Warning: hardsuit power level below 30%",         'sound/rig/beep.wav'),
		new /datum/rig_warning(0.1, "Warning: hardsuit power level is critically low", 'sound/rig/loudbeep.wav'),
		)

/obj/item/rig_module/simple_ai/activate(forced = FALSE)
	. = ..()
	saved_health = 100
	saved_rig_damage = 0
	saved_power = 1
	saved_stat = 0
	restart_cooldown = 0

	greet_user()

/obj/item/rig_module/simple_ai/process_module()
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
		playsound(H, 'sound/rig/dead.wav', VOL_EFFECTS_MASTER)
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
	var/datum/rig_warning/health_warning = get_warning(saved_health, current_health, health_warnings)
	if(health_warning)
		rig_message(health_warning.message, message_class = "warning", message_type = "health", sound = health_warning.sound)
	saved_health = current_health

	var/current_rig_damage = holder.damage
	var/datum/rig_warning/rig_damage_warning = get_warning(saved_rig_damage, current_rig_damage, breach_warnings, descending = FALSE)
	if(rig_damage_warning)
		rig_message(rig_damage_warning.message, message_class = "warning", message_type = "breaches", sound = rig_damage_warning.sound)
		on_rigdamage(H, current_rig_damage)
	saved_rig_damage = current_rig_damage

	var/current_power = 1
	if(holder.cell)
		current_power = holder.cell.charge / holder.cell.maxcharge
	var/datum/rig_warning/rig_power_warning = get_warning(saved_power, current_power, energy_warnings)
	if(rig_power_warning)
		rig_message(rig_power_warning.message, message_class = "warning", message_type = "power", sound = rig_power_warning.sound)
	saved_power = current_power

/obj/item/rig_module/simple_ai/proc/rig_messages_process(mob/living/carbon/human/H)
	if(!message_queue.len)
		return 0

	var/power_waste = 0

	var/message_type = message_queue[1] // type of the first message in the queue
	var/datum/rig_message/message = message_queue[message_type] // take the first message
	message_queue -= message_type // remove it from the queue
	power_waste += 10 // beeping to the user shouldn't use much energy

	if(damage) // if we are damaged show the message badly
		message.text = stars(message.text, rand(50,100))
	to_chat(H, "<span class='notice'>\[[voice_name]\]</span> <span class='[message.class]'>[message.text]</span>")
	if(message.sound)
		H.playsound_local(src, message.sound, VOL_EFFECTS_MASTER, null, FALSE)

	return power_waste

// does some basic queue and priority managment. message_type is used to override messages with the same type so we don't get 2 messages about the same thing. Like "module X damaged" and then "module X destroyed" at the next second
/obj/item/rig_module/simple_ai/proc/rig_message(text, message_class = "notice", message_type, sound = null)
	message_queue[message_type] = new /datum/rig_message(text, message_class, sound)
	return TRUE

// decides if value has moved to a new category so we need to show warning to the rig user
/obj/item/rig_module/simple_ai/proc/get_warning(old_value, new_value, list/values, descending = TRUE)
	var/old_warning = null
	var/new_warning = null

	if(descending)
		for(var/datum/rig_warning/warning in values)
			if(old_value <= warning.value)
				old_warning = warning
			if(new_value <= warning.value)
				new_warning = warning
	else
		for(var/datum/rig_warning/warning in values)
			if(old_value >= warning.value)
				old_warning = warning
			if(new_value >= warning.value)
				new_warning = warning

	if(!new_warning)
		return null

	if(old_warning != new_warning)
		if(descending && new_value < old_value)
			return new_warning
		if(!descending && new_value > old_value)
			return new_warning

	return null

/obj/item/rig_module/simple_ai/proc/handle_module_damage(source, obj/item/rig_module/dam_module)
	if(dam_module == src) // ai module is damaged, we need to forget about old messages and show to the user that we broke
		message_queue.Cut() // clearing the message queue
		if(dam_module.damage >= MODULE_DESTROYED)
			rig_message(destroyed_message, message_class = "danger", message_type = "[dam_module.name]", sound = 'sound/rig/longbeep.wav')
		else
			rig_message(damage_message, message_class = "warning", message_type = "[dam_module.name]", sound = 'sound/rig/beep.wav')
			restart_cooldown = 10
		rig_messages_process(holder.wearer)
		return

	if(dam_module.damage >= MODULE_DESTROYED)
		rig_message("The [source] has disabled your [dam_module.interface_name]!", message_class = "warning", message_type = "[dam_module.name]", sound = 'sound/rig/longbeep.wav')
	else
		rig_message("The [source] has damaged your [dam_module.interface_name]!", message_class = "warning", message_type = "[dam_module.name]", sound = 'sound/rig/beep.wav')

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

/datum/rig_aivoice/wheatley
	name = "Wheatley"
	welcome_message = "Oi, just say hi already! That's too aggressive... Hello, friend!"
	damage_message = "Hello? Anyone in there?"
	destroyed_message = "Hellooooo-ooo-o..."

	health_warnings = list(
		"AHHH!!! Oh God. You look te-- ummm... good. Looking good, actually.",
		"Are you okay? Are you - Don't answer that. I'm absolutely sure you're fine.",
		"Oh. You MIGHT want to call out to somebody...",
		"Do you still understand what I'm saying? At all? If \"yes\" - please seek help. If \"no\" please seek help immediately!",
		"You are basically dying. But don't be alarmed, alright? Although, if you do feel alarm, try to hold onto that feeling because that is the proper reaction to being told that you are dying.",
		)

	breach_warnings = list(
		"You, no, I, no, WE are taking some damage.",
		"OOOF, I don't want to be bossy to you or anything, but you might want to cease the damage dealt to us.",
		"GAAAH!!! It's not like you're at risk of losing me, or me losing you, but you might want to patch us up.",
		)

	energy_warnings = list(
		"Oi, listen, you might want to consider the following fun fact: the charge bar, responsible for the charge says it's at 50%.",
		"Alright, listen, for I am going to tell you something. The suit. Yes, it. It is running low on charge. Look at the meter. AT THE METER YOU DON'T GET TO SEE.",
		"Wha-a-a-at's going o-o-o-on? Oh, right, you seem to be in a litte bit of non-haste when considering the fact that the SUIT IS ALMOST OUT OF POWER.",
		)

/datum/rig_aivoice/jester
	name = "Jester"
	welcome_message = "If we are going to die, let's at least enjoy it!"
	damage_message = "If all else fails, and I be gone... laugh. It blinds the mind..."
	destroyed_message = "At last, the greatest joke of all..."

	health_warnings = list(
		"Nasty ugly thing, this wound. It suits you.",
		"Well, so much for bravery, thy are wounded.",
		"All this leather and steel and blood... For what?",
		"All your courage and your nobility... All for what?!",
		"Why do we hang about here? We are defeated!",
		)

	breach_warnings = list(
		"Ha-ha, they're onto you! The barrier is shed...",
		"I admire your guile, I am immune to death, albeit the suit isn't.",
		"... You're leading us into a trap! Clever, but I must decline. I urge you to retreat.",
		)

	energy_warnings = list(
		"You pitiable fool! What use in scampering about!? You are in need of charging.",
		"I should never have come out here...",
		"We're all going to die..."
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

	// replacing default rig lines with lines from a custom voice, without changing anything else
	for (var/i in 1 to health_warnings.len)
		var/datum/rig_warning/RW = health_warnings[i]
		RW.message = voice.health_warnings[i]

	for (var/i in 1 to breach_warnings.len)
		var/datum/rig_warning/RW = breach_warnings[i]
		RW.message = voice.breach_warnings[i]

	for (var/i in 1 to energy_warnings.len)
		var/datum/rig_warning/RW = energy_warnings[i]
		RW.message = voice.energy_warnings[i]

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
