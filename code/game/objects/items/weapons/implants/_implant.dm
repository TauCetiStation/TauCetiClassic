// todo: consider removing implantcases and implanteres and transferring their functionality to implants
// it's too much of copypaste currently

/obj/item/weapon/implant
	name = "implant"
	cases = list("имплант", "импланта", "импланту", "имплант", "имплантом", "импланте")
	icon = 'icons/obj/device.dmi'
	icon_state = "implant"
	item_actions_special = TRUE

	var/legal = TRUE // is this implant is common for NT? Also changes implantcase icon

	var/mob/living/carbon/implanted_mob = null
	var/obj/item/organ/external/body_part = null

	var/implant_data = "Нет информации по импланту.<br/>" // for implantpad analyzes

	var/activation_emote

	var/malfunction = FALSE

	var/uses = INFINITY
	var/delete_after_use = FALSE

	var/implant_trait

	var/hud_id
	var/hud_icon_state

/datum/action/item_action/implant
	check_flags = AB_CHECK_ALIVE|AB_CHECK_INSIDE

/obj/item/weapon/implant/atom_init()
	. = ..()
	global.implant_list += src
	if(iscarbon(loc))
		inject(loc)
		loc = null

/obj/item/weapon/implant/Destroy()
	if(implanted_mob)
		eject()
	global.implant_list -= src
	return ..()

// Callback called before inject, can be used for some setup or mob checks
// return FALSE if you need to interrupt implantation
//
// first argument is the mob we want to implant
// second (optional) argument is the mob who is implanting and to whom we want to deliver feedback messages
/obj/item/weapon/implant/proc/pre_inject(mob/living/carbon/implant_mob, mob/operator)
	SHOULD_CALL_PARENT(TRUE)

	var/is_synthetic = FALSE
	if(ishuman(implant_mob))
		var/mob/living/carbon/human/H = implant_mob
		if(H.species.flags[IS_SYNTHETIC])
			is_synthetic = TRUE

	if(!istype(implant_mob) || isskeleton(implant_mob) || is_synthetic)
		if(operator)
			to_chat(operator, "<span class='warning'>Вы не можете имплантировать [implant_mob]!</span>")
		return FALSE

	return TRUE

// called when implant successfully implanted
/obj/item/weapon/implant/proc/inject(mob/living/carbon/C, def_zone = BP_HEAD, safe_inject = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(implanted_mob) // need to check if there is no new(src) with additional inject() call
		stack_trace("Implant already implanted, but inject() was called second time")
		return

	if(!iscarbon(C))
		stack_trace("Wrong type of mob (C.type) for implant inject()")

	forceMove(C)
	implanted_mob = C

	if(ishuman(implanted_mob))
		var/mob/living/carbon/human/H = implanted_mob
		var/obj/item/organ/external/BP = H.get_bodypart(def_zone)

		if(!BP)
			stack_trace("Implant injected without proper body part")
			BP = pick(H.bodyparts)

		BP.embedded_objects += src
		body_part = BP

	LAZYADD(implanted_mob.implants, src)

	if(implant_trait)
		ADD_TRAIT(implanted_mob, implant_trait, IMPLANT_TRAIT)

	add_item_actions(implanted_mob)

	if(activation_emote)
		set_activation_emote()

	if(hud_id && hud_icon_state)
		implanted_mob.sec_hud_set_implants()

/obj/item/weapon/implant/proc/eject()
	SHOULD_CALL_PARENT(TRUE)

	if(implant_trait)
		REMOVE_TRAIT(implanted_mob, implant_trait, IMPLANT_TRAIT)
	remove_item_actions(implanted_mob)

	if(body_part)
		body_part.embedded_objects -= src
		body_part = null

	LAZYREMOVE(implanted_mob.implants, src)

	UnregisterSignal(implanted_mob, COMSIG_MOB_EMOTE)

	if(hud_id && hud_icon_state)
		implanted_mob.sec_hud_set_implants()

	implanted_mob = null

/obj/item/weapon/implant/proc/set_activation_emote(emote)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(emote)
		activation_emote = emote

	if(implanted_mob)
		RegisterSignal(implanted_mob, COMSIG_MOB_EMOTE, PROC_REF(on_emote), override = TRUE)

/obj/item/weapon/implant/proc/on_emote(datum/source, emote, intentional)
	SHOULD_CALL_PARENT(TRUE)
	SIGNAL_HANDLER

	if(!activation_emote || emote != activation_emote)
		return FALSE

	activate()

// place your implant effects here, don't call it directly
/obj/item/weapon/implant/proc/activate()
	PROTECTED_PROC(TRUE)

	return TRUE

/obj/item/weapon/implant/proc/use_implant(...)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!implanted_mob || uses <= 0)
		return

	uses--

	. = activate(arglist(args))

	if(delete_after_use && uses <= 0)
		qdel(src)

// temporarily disable functionality
/obj/item/weapon/implant/proc/set_malfunction_for(time)
	malfunction = TRUE
	VARSET_IN(src, malfunction, FALSE, time)

// breaks it down, making implant unrecognizable
/obj/item/weapon/implant/proc/meltdown(harmful = TRUE, message)
	if(message)
		to_chat(implanted_mob, message)

	if(harmful)
		to_chat(implanted_mob, "<span class='warning'>Вы чувствуете, как в [body_part ? "в вашей [CASE(body_part, GENITIVE_CASE)]" : "вас"] что-то плавится!</span>")
		if (body_part)
			body_part.take_damage(burn = 15, used_weapon = "Implant meltdown")
		else
			var/mob/living/M = implanted_mob
			M.apply_damage(15,BURN)

	var/obj/item/weapon/implant/meltdown/replacement = new
	replacement.inject(implanted_mob, body_part.body_zone)

	qdel(src)

	return replacement

/obj/item/weapon/implant/meltdown
	name = "melted implant"
	icon_state = "implant_melted"
	cases = list("расплавленный имплант", "расплавленного импланта", "расплавленному имлпанту", "расплавленный имплант", "расплавленным имплантом", "расплавленном импланте")
	desc = "Обгоревшая плата в расплавленной пластиковой оболочке. Интересно, для чего она была..."
