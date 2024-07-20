///////////////////////////////////////////////////
// 	VOX
///////////////////////////////////////////////////
/atom/movable/screen/leap
	name = "toggle leap"
	icon = 'icons/hud/screen1_action.dmi'
	icon_state = "action"
	screen_loc = ui_human_leap

	copy_flags = NONE

	var/on = FALSE
	var/time_used = 0
	var/cooldown = 10 SECONDS

/atom/movable/screen/leap/atom_init()
	. = ..()
	add_overlay(image(icon, "leap"))
	update_icon()

/atom/movable/screen/leap/update_icon()
	icon_state = "[initial(icon_state)]_[on]"

/mob/living/carbon/human/proc/switch_leap()
	if(!HAS_TRAIT(src, TRAIT_CAN_LEAP))
		to_chat(src, "<span class='notice'>Вы не умеете прыгать!</span>")
		return
	switch(leap_mode)
		if(LEAP_MODE_OFF)
			to_chat(src, "<span class='notice'>Вы попытаетесь совершить прыжок.</span>")
			leap_mode = LEAP_MODE_ON
		else
			to_chat(src, "<span class='notice'>Вы не будете пытаться совершить прыжок.</span>")
			leap_mode = LEAP_MODE_OFF

/datum/action/leap
	name = "Switch Leap"
	button_icon_state = "leap"
	action_type = AB_INNATE

/datum/action/leap/Trigger()
	var/mob/living/carbon/human/H = owner
	H.switch_leap()

/mob/living/carbon/human/ClickOn(atom/A, params)
	if(leap_mode == LEAP_MODE_ON)
		leap_at(A)
	else
		..()

#define MAX_LEAP_DIST 4

/mob/living/carbon/human/proc/leap_at(atom/A)
	if(!COOLDOWN_FINISHED(src, leap_cooldown))
		to_chat(src, "<span class='warning'>You are too fatigued to leap right now!</span>")
		return

	if(status_flags & LEAPING) // Leap while you leap, so you can leap while you leap
		return

	if(!has_gravity(src))
		to_chat(src, "<span class='notice'>It is unsafe to leap without gravity!</span>")
		return

	if(incapacitated(LEGS) || buckled || anchored || stance_damage >= 4) //because you need !restrained legs to leap
		to_chat(src, "<span class='warning'>You cannot leap in your current state.</span>")
		return

	add_status_flags(LEAPING)
	COOLDOWN_START(src, leap_cooldown, 10 SECOND)
	pass_flags |= PASSTABLE
	stop_pulling()


	var/prev_intent = a_intent
	a_intent_change(INTENT_HARM)

	if(wear_suit && istype(wear_suit, /obj/item/clothing/suit/space/vox/stealth))
		for(var/obj/item/clothing/suit/space/vox/stealth/V in list(wear_suit))
			if(V.on)
				V.overload()

	throw_at(A, MAX_LEAP_DIST, 2, null, FALSE, TRUE, CALLBACK(src, PROC_REF(leap_end), prev_intent))

/mob/living/carbon/human/proc/leap_end(prev_intent)
	remove_status_flags(LEAPING)
	a_intent_change(prev_intent)
	pass_flags &= ~PASSTABLE
	//Call Crossed() for activate things and breake glass table
	var/turf/my_turf = get_turf(src)
	for(var/atom/A in my_turf.contents)
		A.Crossed(src)

/mob/living/carbon/human/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!(status_flags & LEAPING))
		return ..()

	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		L.visible_message("<span class='danger'>\The [src] leaps at [L]!</span>", "<span class='userdanger'>[src] leaps on you!</span>")
		if(issilicon(L))
			L.Stun(1) //Only brief stun
			step_towards(src, L)
		else
			L.Stun(2)
			L.Weaken(2)
			step_towards(src, L)

	else if(hit_atom.density)
		if(!hit_atom.CanPass(src, get_turf(hit_atom)))
			visible_message("<span class='danger'>[src] smashes into [hit_atom]!</span>", "<span class='danger'>You smash into [hit_atom]!</span>")
			Stun(2)
			Weaken(2)
		else if(istype(hit_atom, /obj/machinery/disposal))
			var/atom/old_loc = loc
			forceMove(hit_atom)
			INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, do_simple_move_animation), hit_atom, old_loc)

	update_canmove()

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

/datum/action/cooldown/tailpunch
	name = "Использовать хвост"
	button_icon_state = "tailpunch"
	action_type = AB_INNATE
	check_flags = AB_CHECK_ALIVE
	cooldown_time = 600

/datum/action/cooldown/tailpunch/Checks()
	var/mob/living/carbon/human/H = owner
	if(!HAS_TRAIT(H, TRAIT_TAILPUNCH))
		to_chat(H, "<span class='notice'>Вы не умеете пользоваться хвостом!</span>")
		return FALSE
	if(!IsAvailable())
		to_chat(H, "<span class='notice'>Хвост слишком болит чтобы делать им что-то ещё раз!</span>")
		return FALSE
	. = ..()

/datum/action/cooldown/tailpunch/Activate()
	to_chat(owner, "<span class='notice'>Вы попытаетесь сделать что-либо хвостом при нажатии колёсика мыши с зажатым шифтом.</span>")
	active = TRUE

/datum/action/cooldown/tailpunch/Deactivate()
	to_chat(owner, "<span class='notice'>Вы не будете пытаться делать что-либо хвостом.</span>")
	active = FALSE

/mob/living/carbon/human/MiddleShiftClickOn(atom/A, params)
	var/datum/action/cooldown/tailpunch/tp = locate() in actions
	if(tp && tp.active && world.time > next_move)
		tailpunch(A)
		return
	..()

/mob/living/carbon/human/proc/tailpunch(atom/A)
	if(A == src)
		to_chat(src, "<span class='warning'>Вы не можете использовать на себя свой же хвост!</span>")
		return
	if(!in_range(src, A))
		to_chat(src, "<span class='warning'>Цель должна находиться рядом!</span>")
		return
	if(can_tailpunch(A))
		if(isfloorturf(A))
			me_verb("[pick("бьёт", "стучит")] хвостом по полу.")
			SetNextMove(CLICK_CD_MELEE)
			return
		else if(isliving(A))
			var/mob/living/L = A
			tailpunch_living(L)
		else
			tailpunch_obj(A)

		if(!src)
			return
		var/datum/action/cooldown/tailpunch/tp = locate() in actions
		if(tp)
			tp.active = FALSE
			tp.StartCooldown()

/mob/living/carbon/human/proc/can_tailpunch(atom/A)
	if(!src) // what the fuck dude?
		return FALSE
	if(!A)
		return FALSE
	if(restrained())
		var/mob/M = pulledby
		if(M)
			to_chat(src, "<span class='warning'>Ваши руки связаны и вас насильно удерживают!</span>")
			return FALSE
	if(restrained(LEGS))
		to_chat(src, "<span class='warning'>Движение ног сковано, вы не можете достаточно быстро двигать хвостом!</span>")
		return FALSE
	if(buckled)
		to_chat(src, "<span class='warning'>Вы пристёгнуты и ваши движения скованы!</span>")
		return FALSE
	if(stat) // CONSCIOUS = 0
		to_chat(src, "<span class='warning'>Вы не в состоянии делать это сейчас!</span>")
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/tailpunch_living(mob/living/L)
	if(a_intent == INTENT_HELP)
		if(!tailpunch_animation_easy(L, friendly = TRUE))
			return
		if(on_fire)
			L.visible_message("<span class='notice'>[src] put out the fire on [L] with his tail!</span>", "<span class='notice'>[src] put out the fire on you with his tail.</span>")
			L.ExtinguishMob()
		else
			L.visible_message("<span class='notice'>[src] patted his tail on [L] back!</span>", "<span class='notice'>[src] patted his tail on your back.</span>")
			var/datum/component/mood/mood = L.GetComponent(/datum/component/mood)
			if(mood)
				SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "friendly_hug", /datum/mood_event/betterhug, src)
		L.adjustHalLoss(-5)
	else
		L = tailpunch_animation_hard(L) // tailpunch can hit another mob or miss
		if(!L)
			return FALSE
		if(a_intent == INTENT_PUSH && is_skill_competent(src, list(/datum/skill/police = SKILL_LEVEL_TRAINED)))
			L.visible_message("<span class='danger'>\The [src] hooked a [L] with his tail!</span>",
			"<span class='userdanger'>[src] hacks you with his tail!</span>")
			L.Weaken(1)
		else if(a_intent == INTENT_GRAB)
			L.visible_message("<span class='danger'>\The [src] knocked the [L] down by himself!</span>", "<span class='userdanger'>[src] knocked you down by yourself!</span>")
			L.Weaken(2)
			Weaken(2)
		else if(a_intent == INTENT_HARM && is_skill_competent(src, list(/datum/skill/police = SKILL_LEVEL_MASTER)))
			L.visible_message("<span class='danger'>\The [src] hit the [L] with his tail!</span>", "<span class='userdanger'>[src] hits you with his tail!</span>")
			L.apply_damage(12, BRUTE, BP_CHEST)
			L.throw_at(get_step(L, get_dir(src, L)), 2, 1, src, FALSE)
			L.Weaken(1)
		else
			L.visible_message("<span class='danger'>\The [src] hit the [L] with his tail!</span>", "<span class='userdanger'>[src] hits you with his tail!</span>")
			L.apply_damage(12, BRUTE, BP_GROIN)

/mob/living/carbon/human/proc/tailpunch_obj(atom/A, play_animation = TRUE)
	if(play_animation)
		if(!tailpunch_animation_easy(A))
			return

	visible_message("<span class='danger'>\The [src] hit the [A] with his tail!</span>", "<span class='userdanger'>You hit the [A] with your tail!</span>")

	if(istype(A, /atom/movable))
		var/atom/movable/AM = A
		if(!AM.anchored)
			step_away(AM, get_turf(src))
	if(!has_gravity(src))
		step_away(src, get_turf(A))

	if(A.uses_integrity)
		A.take_damage(12, BRUTE)

	if(iswallturf(A))
		Stun(1)
		Weaken(2)
		apply_damage(4, BRUTE, BP_GROIN)

	else if(istype(A, /obj/fire))
		var/obj/fire/F = A
		if(F.firelevel < 2.5)
			qdel(A)
		else
			fire_act()
			adjust_fire_stacks(5)

// just poke the tail at the atom
/mob/living/carbon/human/proc/tailpunch_animation_easy(atom/A, friendly = FALSE)
	face_atom(A)
	do_attack_animation(A)
	sleep(2)
	if(!can_tailpunch(A))
		return FALSE
	set_dir(turn(dir, 180))
	if(friendly)
		playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	else
		playsound(src, pick(SOUNDIN_PUNCH_VERYHEAVY), VOL_EFFECTS_MASTER)
	return TRUE

// swinging the tail
/mob/living/carbon/human/proc/tailpunch_animation_hard(mob/living/target)
	var/attack_dir = get_dir(src, target)
	var/attack_side = -1 // right hand - right side
	if(hand)
		attack_side = 1  // left hand - left side
	var/icon/tail_icon = new('icons/hud/actions.dmi', "tailpunch")
	tail_icon.Blend(rgb(r_skin, g_skin, b_skin), ICON_ADD)
	var/obj/tail = new /obj/effect/effect/custom(get_step(src, turn(attack_dir, 90 * attack_side)), "Tail", tail_icon, "tailpunch")
	var/animation_speed = 3
	if(is_skill_competent(src, list(/datum/skill/police = SKILL_LEVEL_PRO)))
		animation_speed = 2 // attack animation is 1.5 times faster if you skilled

	do_attack_animation(target)
	var/atom/interupt_atom
	for(var/i = 2, i >= 0, i--)
		tail.forceMove(get_step(src, turn(attack_dir, 45 * i * attack_side))) // start to 90 degree end to 0 degree
		set_dir(turn(attack_dir, -180 + 45 * i * attack_side)) // start to 90 degree end to 180 degree

		var/turf/tail_turf = get_turf(tail)
		if(tail_turf.density)
			interupt_atom = tail_turf
		else
			for(var/obj/O in tail_turf.contents)
				if(O.density)
					interupt_atom = O
					break

		sleep(animation_speed)
		if(!can_tailpunch(target))
			return null
		if(interupt_atom)
			tailpunch_obj(interupt_atom, play_animation = FALSE) // The object takes the hit on itself without double animation
			break

	var/hit_mob = null
	if(!interupt_atom)
		if(target in (get_turf(tail)).contents)
			hit_mob = target // priority on target
		else
			for(var/mob/living/L in (get_turf(tail)).contents)
				hit_mob = L
				break

	if(hit_mob || interupt_atom)
		playsound(src, pick(SOUNDIN_PUNCH_VERYHEAVY), VOL_EFFECTS_MASTER)
	else
		playsound(src, 'sound/effects/mob/hits/miss_1.ogg', VOL_EFFECTS_MASTER)
	qdel(tail)
	return hit_mob

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
