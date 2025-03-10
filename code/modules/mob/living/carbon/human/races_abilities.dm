/datum/action/innate/race
	name = "Расовое умение"
	background_icon_state = "bg_race"

/datum/action/innate/race/Grant(mob/T)
	if(!(ishuman(T)))
		qdel(src)
		return
	..()

///////////////////////////////////////////////////
// 	VOX
///////////////////////////////////////////////////
/datum/action/innate/race/leap
	name = "Switch Leap" // переводить ниче не буду
	button_icon_state = "leap"
	toggleable = TRUE
	cooldown = 10 SECOND

/datum/action/innate/race/leap/Grant(mob/T)
	..()
	RegisterSignal(owner, COMSIG_MOB_CLICK, PROC_REF(leap_at))

/datum/action/innate/race/leap/Destroy()
	UnregisterSignal(owner, COMSIG_MOB_CLICK)
	..()

/datum/action/innate/race/leap/Checks()
	if(!..())
		return FALSE

	var/mob/living/carbon/human/H = owner

	if(HAS_TRAIT(H, TRAIT_ARIBORN))
		return FALSE

	if(!has_gravity(H))
		to_chat(H, "<span class='notice'>It is unsafe to leap without gravity!</span>")
		return FALSE

	if(H.incapacitated(LEGS) || H.buckled || H.anchored || H.stance_damage >= 4) //because you need !restrained legs to leap
		to_chat(H, "<span class='warning'>You cannot leap in your current state.</span>")
		return FALSE

	return TRUE

#define MAX_LEAP_DIST 4

/datum/action/innate/race/leap/proc/leap_at(mob/source, atom/target, params)
	SIGNAL_HANDLER

	if(active)
		StartCooldown()
		var/mob/living/carbon/human/H = owner
		H.stop_pulling()

		var/prev_intent = H.a_intent
		H.a_intent_change(INTENT_HARM)

		if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit/space/vox/stealth))
			for(var/obj/item/clothing/suit/space/vox/stealth/V in list(H.wear_suit))
				if(V.on)
					INVOKE_ASYNC(V, TYPE_PROC_REF(/obj/item/clothing/suit/space/vox/stealth, overload))

		H.throw_at(target, MAX_LEAP_DIST, 2, null, FALSE, TRUE, CALLBACK(src, PROC_REF(leap_end), prev_intent))
		RegisterSignal(H, COMSIG_ATOM_PREHITBY, PROC_REF(impact))
		return COMPONENT_CANCEL_CLICK

/datum/action/innate/race/leap/proc/leap_end(prev_intent)
	var/mob/living/carbon/human/H = owner

	H.a_intent_change(prev_intent)
	//Call Crossed() for activate things and breake glass table
	var/turf/owner_turf = get_turf(H)
	for(var/atom/A in owner_turf.contents)
		A.Crossed(H)
	UnregisterSignal(H, COMSIG_ATOM_PREHITBY)

/datum/action/innate/race/leap/proc/impact(atom/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = owner

	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		L.visible_message("<span class='danger'>\The [H] leaps at [L]!</span>", "<span class='userdanger'>[H] leaps on you!</span>")
		if(issilicon(L))
			L.Stun(1) //Only brief stun
			step_towards(H, L)
		else
			L.Stun(2)
			L.Weaken(2)
			step_towards(H, L)

	else if(hit_atom.density)
		if(!hit_atom.CanPass(H, get_turf(hit_atom)))
			H.visible_message("<span class='danger'>[H] smashes into [hit_atom]!</span>", "<span class='danger'>You smash into [hit_atom]!</span>")
			H.Stun(2)
			H.Weaken(2)
		else if(istype(hit_atom, /obj/machinery/disposal))
			var/atom/old_loc = H.loc
			H.forceMove(hit_atom)
			INVOKE_ASYNC(H, TYPE_PROC_REF(/atom/movable, do_simple_move_animation), hit_atom, old_loc)

	H.update_canmove()
	return COMSIG_HIT_PREVENTED

#undef MAX_LEAP_DIST

/mob/living/carbon/human/proc/gut()
	set category = "IC"
	set name = "Gut"
	set desc = "While grabbing someone aggressively, rip their guts out or tear them apart."

	if(last_special > world.time)
		return

	if(incapacitated())
		to_chat(src, "<span class='warning'>You cannot do that in your current state.</span>")
		return

	var/obj/item/weapon/grab/G = locate() in src
	if(!G || !istype(G))
		to_chat(src, "<span class='warning'>You are not grabbing anyone.</span>")
		return

	if(G.state < GRAB_AGGRESSIVE)
		to_chat(src, "<span class='warning'>You must have an aggressive grab to gut your prey!</span>")
		return

	last_special = world.time + 50

	visible_message("<span class='warning'><b>\The [src]</b> rips viciously at \the [G.affecting]'s body with its claws!</span>")

	if(ishuman(G.affecting))
		var/mob/living/carbon/human/H = G.affecting
		H.apply_damage(50,BRUTE)
		if(H.stat == DEAD)
			H.gib()
	else
		var/mob/living/M = G.affecting
		if(!istype(M)) return //wut
		M.apply_damage(50,BRUTE)
		if(M.stat == DEAD)
			M.gib()

///////////////////////////////////////////////////
// 	UNATH
///////////////////////////////////////////////////
/mob/living/carbon/human/proc/air_sample()
	set category = "IC"
	set name = "Air sample"
	set desc = "pull out the tongue and understand the approximate state of the air"

	if(incapacitated())
		to_chat(src, "<span class='notice'>You can not do this in your current state.</span>")
		return
	if(wear_mask && wear_mask.flags & HEADCOVERSMOUTH || head && head.flags & MASKCOVERSMOUTH)
		to_chat(usr,"<span class='notice'>I can't get my tongue out.</span>")
		return

	visible_message("<span class='notice'>[src] quickly pulled out and put the tongue back</span>")
	to_chat(src,"<span class='notice'>Ressults air sample:</span>")
	var/datum/gas_mixture/mixture = return_air()
	var/pressure = mixture.return_pressure()
	var/total_moles = mixture.total_moles

	if(total_moles > 0)
		if(pressure - ONE_ATMOSPHERE * 2 <= 10)
			to_chat(src,"<span class='notice'>The pressure of about: [round(pressure, 20)] kPa.</span>")
		else
			to_chat(src,"<span class='warning'>The pressure extremely high.</span>")

		for(var/mix in mixture.gas)
			if(mix == "sleeping_agent" && mixture.gas[mix] > 1)
				to_chat(src,"<span class='warning'>Sssleepy.</span>")
			else if(mix == "phoron" && mixture.gas[mix] > 1)
				to_chat(src,"<span class='warning'>Deadly.</span>")
			else if(mix == "oxygen")
				if(mixture.gas[mix] > 22)
					to_chat(src,"<span class='notice'>Airfull.</span>")
				else if(mixture.gas[mix] < 19)
					to_chat(src,"<span class='notice'>Airless.</span>")

		to_chat(src,"<span class='notice'>Temperature around [round(mixture.temperature-T0C, 5)]&deg;C.</span>")
		return
	to_chat(src,"<span class='warning'>Well... I need my mask back.</span>")

///////////////////////////////////////////////////
// 	MACHINE | IPC
///////////////////////////////////////////////////
/mob/living/carbon/human/proc/IPC_change_screen()
	set category = "IPC"
	set name = "Change IPC Screen"
	set desc = "Allow change monitor type"
	if(stat != CONSCIOUS)
		return
	var/obj/item/organ/external/head/robot/ipc/BP = bodyparts_by_name[BP_HEAD]
	if(!BP || BP.is_stump)
		return

	if(!BP.screen_toggle)
		set_light(BP.screen_brightness)
		BP.screen_toggle = TRUE

	var/list/valid_hairstyles = get_valid_styles_from_cache(hairs_cache, get_species(), gender, BP.ipc_head)
	var/new_h_style = ""
	if(valid_hairstyles.len == 1)
		new_h_style = valid_hairstyles[1]
	else
		new_h_style = input(src, "Choose your IPC screen style:", "Character Preference")  as null|anything in valid_hairstyles

	if(new_h_style)
		var/datum/sprite_accessory/SA = hair_styles_list[new_h_style]
		if(SA.do_colouration)
			var/new_hair = input(src, "Choose your IPC screen colour:", "Character Preference") as color|null
			if(new_hair)
				r_hair = HEX_VAL_RED(new_hair)
				g_hair = HEX_VAL_GREEN(new_hair)
				b_hair = HEX_VAL_BLUE(new_hair)

		h_style = new_h_style
	if(h_style == "IPC off screen")
		random_hair_style(gender, get_species(), BP.ipc_head)

	update_hair()

/mob/living/carbon/human/proc/IPC_toggle_screen()
	set category = "IPC"
	set name = "Toggle IPC Screen"
	set desc = "Allow toggle monitor"

	if(stat != CONSCIOUS)
		return
	var/obj/item/organ/external/head/robot/ipc/BP = bodyparts_by_name[BP_HEAD]
	if(!BP || (BP.is_stump))
		set_light(0)
		return

	BP.screen_toggle = !BP.screen_toggle
	if(BP.screen_toggle)
		IPC_change_screen()
		set_light(BP.screen_brightness)
	else
		r_hair = 15
		g_hair = 15
		b_hair = 15
		set_light(0)
		if(BP.ipc_head == "Default")
			h_style = "IPC off screen"
		update_hair()

/mob/living/carbon/human/proc/IPC_display_text()
	set category = "IPC"
	set name = "Display Text On Screen"
	set desc = "Display text on your monitor"

	if(stat != CONSCIOUS)
		return

	var/obj/item/organ/external/head/robot/ipc/BP = bodyparts_by_name[BP_HEAD]
	if(!BP || BP.is_stump)
		return

	if(BP.ipc_head != "Default")
		to_chat(usr, "<span class='warning'>Your head has no screen!</span>")
		return

	var/S = input("Write something to display on your screen (emoticons supported):", "Display Text") as text|null
	if(!S)
		return
	if(!length(S))
		return

	if(get_species() != IPC)
		return

	if(!BP.screen_toggle)
		set_light(BP.screen_brightness)
		BP.screen_toggle = TRUE

	BP.display_text = S
	h_style = "IPC text screen"
	update_hair()

	var/skipface = FALSE
	if(head)
		skipface = head.flags_inv & HIDEFACE
	if(wear_mask)
		skipface |= wear_mask.flags_inv & HIDEFACE

	if(!BP.disfigured && !skipface) // we still text even tho the screen may be broken or hidden
		me_emote("отображает на экране, \"<span class=\"emojify\">[S]</span>\"", intentional=TRUE)

