

//backpack item
/obj/item/weapon/defibrillator
	name = "defibrillator"
	desc = "A device that delivers powerful shocks via detachable paddles to resuscitate incapacitated patients."
	icon = 'icons/obj/defibrillator.dmi'
	icon_state = "defibunit"
	item_state = "defibunit"
	slot_flags = SLOT_FLAGS_BACK
	force = 5
	throwforce = 6
	w_class = ITEM_SIZE_LARGE
	origin_tech = list("biotech" = 2, "powerstorage" = 1)
	action_button_name = "Remove/Replace Paddles"

	var/obj/item/weapon/twohanded/shockpaddles/linked/paddles
	var/obj/item/weapon/stock_parts/cell/bcell = null
	var/charge_time = 1 SECONDS

/obj/item/weapon/defibrillator/atom_init() // starts without a cell for rnd
	. = ..()
	if(ispath(paddles))
		paddles = new paddles(src, src)
	else
		paddles = new(src, src)

	if(ispath(bcell))
		bcell = new bcell(src)
	update_icon()

/obj/item/weapon/defibrillator/Destroy()
	. = ..()
	QDEL_NULL(paddles)
	QDEL_NULL(bcell)

/obj/item/weapon/defibrillator/loaded //starts with regular power cell for R&D to replace later in the round.
	bcell = /obj/item/weapon/stock_parts/cell/high

/obj/item/weapon/defibrillator/update_icon()
	var/list/new_overlays = list()

	if(paddles) //in case paddles got destroyed somehow.
		if(paddles.loc == src)
			new_overlays += "[initial(icon_state)]-paddles"
		if(bcell && bcell.charge >= paddles.charge_cost)
			if(!paddles.safety)
				new_overlays += "[initial(icon_state)]-emagged"
			else
				new_overlays += "[initial(icon_state)]-powered"

	if(bcell)
		var/ratio = CEIL(bcell.percent()/25) * 25
		new_overlays += "[initial(icon_state)]-charge[ratio]"
	else
		new_overlays += "[initial(icon_state)]-nocell"

	if(blood_DNA && blood_DNA.len && blood_overlay)
		new_overlays += blood_overlay

	cut_overlays()
	add_overlay(new_overlays)

/obj/item/weapon/defibrillator/ui_action_click()
	toggle_paddles()

/obj/item/weapon/defibrillator/attack_hand(mob/user)
	if(loc == user)
		toggle_paddles()
	else
		..()

/obj/item/weapon/defibrillator/MouseDrop()
	if(ismob(loc))
		if(!CanMouseDrop(src))
			return
		var/mob/M = loc
		if(!M.unEquip(src))
			return
		src.add_fingerprint(usr)
		M.put_in_hands(src)


/obj/item/weapon/defibrillator/attackby(obj/item/I, mob/user, params)
	if(I == paddles)
		reattach_paddles(user)

	else if(istype(I, /obj/item/weapon/stock_parts/cell))
		if(bcell)
			to_chat(user, "<span class='notice'>\the [src] already has a cell.</span>")
		else
			if(!user.unEquip(I))
				return
			I.forceMove(src)
			bcell = I
			to_chat(user, "<span class='notice'>You install a cell in \the [src].</span>")
			update_icon()

	else if(isscrewdriver(I))
		if(bcell)
			bcell.update_icon()
			bcell.forceMove(get_turf(src.loc))
			bcell = null
			to_chat(user, "<span class='notice'>You remove the cell from \the [src].</span>")
			update_icon()

	else
		return ..()

//Paddle stuff

/obj/item/weapon/defibrillator/verb/toggle_paddles()
	set src in oview(1)
	set name = "Toggle Paddles"
	set category = "Object"

	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/user = usr
	if(user.incapacitated())
		return

	if(!paddles)
		to_chat(user, "<span class='warning'>The paddles are missing!</span>")
		return

	if(paddles.loc != src)
		reattach_paddles(user) //Remove from their hands and back onto the defib unit
		return

	if(!slot_check())
		to_chat(user, "<span class='warning'>You need to equip [src] before taking out [paddles].</span>")
	else
		if(!usr.put_in_hands(paddles)) //Detach the paddles into the user's hands
			to_chat(user, "<span class='warning'>You need a free hand to hold the paddles!</span>")
		update_icon() //success

//checks that the base unit is in the correct slot to be used
/obj/item/weapon/defibrillator/proc/slot_check()
	if(!ishuman(loc))
		return FALSE //not equipped

	var/mob/living/carbon/human/H = loc
	if((slot_flags & SLOT_FLAGS_BACK) && H.back == src)
		return TRUE
	if((slot_flags & SLOT_FLAGS_BELT) && H.belt == src)
		return TRUE
	return FALSE

/obj/item/weapon/defibrillator/dropped(mob/user)
	..()
	reattach_paddles(user) //paddles attached to a base unit should never exist outside of their base unit or the mob equipping the base unit

/obj/item/weapon/defibrillator/proc/reattach_paddles(mob/user)
	if(!paddles)
		return

	if(ismob(paddles.loc))
		var/mob/M = paddles.loc
		if(M.drop_from_inventory(paddles, src))
			to_chat(user, "<span class='notice'>\The [paddles] snap back into the main unit.</span>")
	else
		paddles.forceMove(src)

	update_icon()

/*
	Base Unit Subtypes
*/

/obj/item/weapon/defibrillator/compact
	name = "compact defibrillator"
	desc = "A belt-equipped defibrillator that can be rapidly deployed."
	icon_state = "defibcompact"
	item_state = "defibcompact"
	w_class = ITEM_SIZE_NORMAL
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = list("biotech" = 3, "powerstorage" = 2)
	charge_time = 0.5 SECONDS

/obj/item/weapon/defibrillator/compact/loaded
	bcell = /obj/item/weapon/stock_parts/cell/super


/obj/item/weapon/defibrillator/compact/combat
	name = "combat defibrillator"
	desc = "A belt-equipped blood-red defibrillator that can be rapidly deployed. Does not have the restrictions or safeties of conventional defibrillators and can revive through almost all space suits."
	paddles = /obj/item/weapon/twohanded/shockpaddles/linked/combat
	charge_time = 0.25 SECONDS

/obj/item/weapon/defibrillator/compact/combat/loaded
	bcell = /obj/item/weapon/stock_parts/cell/super

/obj/item/weapon/twohanded/shockpaddles/linked/combat
	combat = TRUE
	safety = FALSE
	charge_time = 0.5 SECONDS


//paddles

/obj/item/weapon/twohanded/shockpaddles
	name = "defibrillator paddles"
	desc = "A pair of plastic-gripped paddles with flat metal surfaces that are used to deliver powerful electric shocks."
	icon = 'icons/obj/defibrillator.dmi'
	icon_state = "defibpaddles0"
	item_state = "defibpaddles"
	gender = PLURAL
	force = 2
	force_unwielded = 2
	force_wielded = 2
	throwforce = 6
	w_class = ITEM_SIZE_LARGE
	offhand_item = /obj/item/weapon/twohanded/offhand/shockpaddles

	var/safety = TRUE //if you can zap people with the paddles on harm mode
	var/combat = FALSE //If it can be used to revive people wearing thick clothing (e.g. spacesuits)
	var/cooldown_time = 6 SECONDS // How long in deciseconds until the defib is ready again after use.
	var/charge_time = 1 SECONDS
	var/charge_cost = 250 //units of charge
	var/burn_damage_amt = 5

	var/cooldown = FALSE
	var/busy = FALSE

/obj/item/weapon/twohanded/shockpaddles/proc/set_cooldown(delay)
	cooldown = TRUE
	update_icon()
	addtimer(CALLBACK(src, .proc/reset_cooldown), delay, TIMER_UNIQUE)

/obj/item/weapon/twohanded/shockpaddles/proc/reset_cooldown()
	if(cooldown)
		cooldown = FALSE
		update_icon()

		make_announcement("beeps, \"Unit is re-energized.\"")
		playsound(src, 'sound/items/surgery/defib_ready.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/item/weapon/twohanded/shockpaddles/update_icon()
	icon_state = "defibpaddles[wielded]"
	if(cooldown)
		icon_state = "defibpaddles[wielded]_cooldown"
	if(wielded)
		if(!ishuman(loc))
			return
		var/mob/living/carbon/human/H = loc
		var/obj/item/weapon/twohanded/offhand/shockpaddles/second_paddle = H.get_inactive_hand()
		if(!istype(second_paddle))
			return
		second_paddle.icon_state = cooldown ? "defibpaddleso_cooldown" : "defibpaddleso"

/obj/item/weapon/twohanded/shockpaddles/proc/can_use(mob/user, mob/M)
	if(busy)
		return FALSE
	if(!check_charge(charge_cost))
		to_chat(user, "<span class='warning'>\The [src] doesn't have enough charge left to do that.</span>")
		return FALSE
	if(!wielded && !isrobot(user))
		to_chat(user, "<span class='warning'>You need to wield the paddles with both hands before you can use them on someone!</span>")
		return FALSE
	if(cooldown)
		to_chat(user, "<span class='warning'>\The [src] are re-energizing!</span>")
		return FALSE
	return TRUE

//Checks for various conditions to see if the mob is revivable
/obj/item/weapon/twohanded/shockpaddles/proc/can_defib(mob/living/carbon/human/H) //This is checked before doing the defib operation
	if(H.species.flags[NO_SCAN] || H.isSynthetic() || (NOCLONE in H.mutations))
		return "buzzes, \"Unrecogized physiology. Operation aborted.\""

	if(!check_contact(H))
		return "buzzes, \"Patient's chest is obstructed. Operation aborted.\""

	if(!check_blood_level(H))
		return "buzzes, \"Warning - Patient is in hypovolemic shock and require a blood transfusion. Operation aborted.\""

	if(!check_brain(H))
		return "buzzes, \"Error - Patient's brain is missing or is too damaged to be functional. Operation aborted.\""

/obj/item/weapon/twohanded/shockpaddles/proc/check_contact(mob/living/carbon/human/H, sel_zone = BP_CHEST)
	if(!combat)
		if(H.check_thickmaterial(target_zone = sel_zone))
			return FALSE
	if(H.get_siemens_coefficient_organ(H.get_bodypart(sel_zone)) <= 0)
		return FALSE
	return TRUE

/obj/item/weapon/twohanded/shockpaddles/proc/check_blood_level(mob/living/carbon/human/H)
	if(!H.should_have_organ(O_HEART))
		return TRUE
	var/obj/item/organ/internal/heart/heart = H.organs_by_name[O_HEART]
	if(!heart || H.vessel.get_reagent_amount("blood") < BLOOD_VOLUME_SURVIVE)
		return FALSE
	return TRUE

/obj/item/weapon/twohanded/shockpaddles/proc/check_brain(mob/living/carbon/human/H)
	if(!H.should_have_organ(O_BRAIN))
		return TRUE
	if(!H.organs_by_name[O_BRAIN])
		return FALSE
	var/obj/item/organ/external/bodypart_head = H.bodyparts_by_name[BP_HEAD]
	if(!bodypart_head || (bodypart_head.is_stump))
		return FALSE
	return TRUE

/obj/item/weapon/twohanded/shockpaddles/proc/check_charge(charge_amt)
	return TRUE

/obj/item/weapon/twohanded/shockpaddles/proc/checked_use(charge_amt)
	return TRUE

/obj/item/weapon/twohanded/shockpaddles/attack(mob/M, mob/living/user, def_zone)
	var/mob/living/carbon/human/H = M
	if(!istype(H) || !can_use(user, M))
		return

	busy = TRUE
	update_icon()

	if(user.a_intent == INTENT_HARM)
		do_electrocute(M, user, def_zone)
	else
		try_revive(M, user)

	busy = FALSE
	update_icon()


// This proc is used so that we can return out of the revive process while ensuring that busy and update_icon() are handled
/obj/item/weapon/twohanded/shockpaddles/proc/try_revive(mob/living/carbon/human/H, mob/user)
	//beginning to place the paddles on patient's chest to allow some time for people to move away to stop the process
	user.visible_message("<span class='warning'>\The [user] begins to place [src] on [H]'s chest.</span>", "<span class='warning'>You begin to place [src] on [H]'s chest...</span>")
	if(!do_after(user, 30, target = H))
		return
	user.visible_message("<span class='notice'>\The [user] places [src] on [H]'s chest.</span>", "<span class='warning'>You place [src] on [H]'s chest.</span>")
	playsound(src, 'sound/items/surgery/defib_charge.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	var/error = can_defib(H)
	if(error)
		make_announcement(error)
		playsound(src, 'sound/items/surgery/defib_failed.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		return

	//placed on chest and short delay to shock for dramatic effect, revive time is ~5sec total
	if(!do_after(user, charge_time, target = H))
		return

	//deduct charge here, in case the base unit was EMPed or something during the delay time
	if(!checked_use(charge_cost))
		make_announcement("buzzes, \"Insufficient charge.\"")
		playsound(src, 'sound/items/surgery/defib_failed.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		return

	H.log_combat(user, "shocked with [name]")
	user.visible_message("<span class='warning'>[user] shocks [H] with [src].</span>", "<span class='warning'>You shock [H] with [src].</span>", "<span class='warning'>You hear electricity zaps flesh.</span>")

	H.apply_effect(4, STUN, 0)
	H.apply_effect(4, WEAKEN, 0)
	H.apply_effect(4, STUTTER, 0)

	if(H.jitteriness <= 100)
		H.make_jittery(150)
	else
		H.make_jittery(50)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, H)
	s.start()
	playsound(src, pick(SOUNDIN_BODYFALL), VOL_EFFECTS_MASTER)
	playsound(src, 'sound/items/surgery/defib_zap.ogg', VOL_EFFECTS_MASTER)
	set_cooldown(cooldown_time)

	var/obj/item/organ/internal/heart/IO = H.organs_by_name[O_HEART]
	if(!IO)
		return

	if(H.stat == DEAD && IO.heart_status == HEART_FAILURE)
		make_announcement("buzzes, \"Defibrillation failed - patient's heart is not beating.\"")
		playsound(src, 'sound/items/surgery/defib_failed.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		return

	if(H.stat == DEAD && (world.time - H.timeofdeath) >= DEFIB_TIME_LIMIT)
		make_announcement("buzzes, \"Defibrillation failed - Severe neurological decay makes recovery of patient impossible. Further attempts futile.\"")
		playsound(src, 'sound/items/surgery/defib_failed.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		return

	if(IO.heart_status == HEART_NORMAL && prob(20))
		IO.heart_stop()
		return

	if(IO.heart_status == HEART_FIBR)
		if(H.stat == DEAD)
			IO.heart_normalize()
			H.reanimate_body(H)
			H.stat = UNCONSCIOUS
			H.return_to_body_dialog(src)
		else
			IO.heart_normalize()

	if(H.health <= config.health_threshold_crit || prob(10))
		var/suff = min(H.getOxyLoss(), 20)
		H.adjustOxyLoss(-suff)
	else
		H.adjustFireLoss(burn_damage_amt)
	H.updatehealth()

	if(H.health < config.health_threshold_dead)
		make_announcement("buzzes, \"Defibrillation failed - Patinent's body is too wounded to sustain heart beating.\"")
		playsound(src, 'sound/items/surgery/defib_failed.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		return

	if(wet)
		var/turf/T = get_turf(src)
		T.visible_message("<span class='wet'>Some wet device has been discharged!</span>")
		var/obj/effect/fluid/F = locate() in T
		if(F)
			F.electrocute_act(150)
		else
			user.Weaken(6)

	make_announcement("pings, \"Defibrillation successful.\"")
	playsound(src, 'sound/items/surgery/defib_success.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/item/weapon/twohanded/shockpaddles/proc/do_electrocute(mob/living/carbon/human/H, mob/user, var/target_zone)
	var/obj/item/organ/external/affecting = H.get_bodypart(target_zone)
	if(!affecting)
		to_chat(user, "<span class='warning'>They are missing that body part!</span>")
		return

	//no need to spend time carefully placing the paddles, we're just trying to shock them
	user.visible_message("<span class='danger'>\The [user] slaps [src] onto [H]'s [affecting.name].</span>", "<span class='danger'>You overcharge [src] and slap them onto [H]'s [affecting.name].</span>")

	if(!check_contact(H, target_zone))
		to_chat(user, "<span class='warning'>Target's [affecting.name] is obstructed. Operation aborted.</span>")
		return

	//Just stop at awkwardly slapping electrodes on people if the safety is enabled
	if(safety)
		to_chat(user, "<span class='warning'>You can't do that while the safety is enabled.</span>")
		return

	playsound(src, 'sound/items/surgery/defib_charge.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	audible_message("<span class='warning'>\The [src] lets out a steadily rising hum...</span>")

	if(!do_after(user, charge_time, target = H))
		return

	//deduct charge here, in case the base unit was EMPed or something during the delay time
	if(!checked_use(charge_cost))
		make_announcement("buzzes, \"Insufficient charge.\"")
		playsound(src, 'sound/items/surgery/defib_failed.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		return

	user.visible_message("<span class='danger'><i>\The [user] shocks [H] with \the [src]!</i></span>", "<span class='warning'>You shock [H] with \the [src]!</span>")
	playsound(src, 'sound/items/surgery/defib_zap.ogg', VOL_EFFECTS_MASTER)
	playsound(src, 'sound/weapons/Egloves.ogg', VOL_EFFECTS_MASTER)
	set_cooldown(cooldown_time)

	H.apply_effect(4, STUN, 0)
	H.apply_effect(4, WEAKEN, 0)
	H.apply_effect(4, STUTTER, 0)
	H.electrocute_act(burn_damage_amt*2, src, def_zone = target_zone)

	H.log_combat(user, "shocks with [name]")

/obj/item/weapon/twohanded/shockpaddles/proc/make_announcement(message)
	audible_message("<b>\The [src]</b> [message]", "\The [src] vibrates slightly.")

/obj/item/weapon/twohanded/shockpaddles/emag_act(mob/user)
	if(safety)
		safety = FALSE
		to_chat(user, "<span class='warning'>You silently disable \the [src]'s safety protocols with the cryptographic sequencer.</span>")
		burn_damage_amt *= 3
	else
		safety = TRUE
		to_chat(user, "<span class='notice'>You silently enable \the [src]'s safety protocols with the cryptographic sequencer.</span>")
		burn_damage_amt = initial(burn_damage_amt)
	update_icon()
	return TRUE

/obj/item/weapon/twohanded/shockpaddles/emp_act(severity)
	var/new_safety = rand(0, 1)
	if(safety != new_safety)
		safety = new_safety
		if(safety)
			make_announcement("beeps, \"Safety protocols enabled!\"")
			playsound(src, 'sound/items/surgery/defib_safetyOn.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		else
			make_announcement("beeps, \"Safety protocols disabled!\"")
			playsound(src, 'sound/items/surgery/defib_safetyOff.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		update_icon()
	..()

/obj/item/weapon/twohanded/shockpaddles/robot
	name = "defibrillator paddles"
	desc = "A pair of advanced shockpaddles powered by a robot's internal power cell, able to penetrate thick clothing."
	charge_cost = 50
	combat = TRUE
	cooldown_time = 3 SECONDS

/obj/item/weapon/twohanded/shockpaddles/robot/check_charge(charge_amt)
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		return (R.cell && R.cell.charge >= charge_amt)

/obj/item/weapon/twohanded/shockpaddles/robot/checked_use(charge_amt)
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		return (R.cell && R.cell.use(charge_amt))

/obj/item/weapon/twohanded/shockpaddles/robot/attack_self(mob/user)
	return //No, this can't be wielded

/*
	Shockpaddles that are linked to a base unit
*/
/obj/item/weapon/twohanded/shockpaddles/linked
	var/obj/item/weapon/defibrillator/base_unit

/obj/item/weapon/twohanded/shockpaddles/linked/atom_init(mapload, obj/item/weapon/defibrillator/defib)
	base_unit = defib
	charge_time = base_unit.charge_time
	. = ..()

/obj/item/weapon/twohanded/shockpaddles/linked/Destroy()
	if(base_unit)
		//ensure the base unit's icon updates
		if(base_unit.paddles == src)
			base_unit.paddles = null
			base_unit.update_icon()
		base_unit = null
	return ..()

/obj/item/weapon/twohanded/shockpaddles/linked/dropped(mob/user)
	..() //update twohanding
	if(base_unit)
		base_unit.reattach_paddles(user) //paddles attached to a base unit should never exist outside of their base unit or the mob equipping the base unit

/obj/item/weapon/twohanded/shockpaddles/linked/check_charge(charge_amt)
	return (base_unit.bcell && base_unit.bcell.charge >= charge_amt)

/obj/item/weapon/twohanded/shockpaddles/linked/checked_use(charge_amt)
	return (base_unit.bcell && base_unit.bcell.use(charge_amt))

/obj/item/weapon/twohanded/shockpaddles/linked/make_announcement(message)
	base_unit.audible_message("<b>\The [base_unit]</b> [message]", "\The [base_unit] vibrates slightly.")

/*
	Standalone Shockpaddles
*/

/obj/item/weapon/twohanded/shockpaddles/standalone
	desc = "A pair of shockpaddles with integrated capacitor" //Good old defib
	var/charges = 10
	w_class = ITEM_SIZE_NORMAL

/obj/item/weapon/twohanded/shockpaddles/standalone/set_prototype_qualities(rel_val=100, mark=0)
	..()
	while(!prob(reliability))
		if(charges == 0)
			break
		charges = max(charges - 1, 0)

/obj/item/weapon/twohanded/shockpaddles/standalone/check_charge(charge_amt)
	return charges

/obj/item/weapon/twohanded/shockpaddles/standalone/checked_use(charge_amt)
	if(charges)
		charges--
		return TRUE
	return FALSE

/obj/item/weapon/twohanded/shockpaddles/standalone/traitor
	name = "defibrillator paddles"
	desc = "A pair of unusual looking paddles with integrated capacitor. It possesses both the ability to penetrate almost all armor and to deliver powerful shocks."
	combat = TRUE
	safety = FALSE
	charge_time = 0.5 SECONDS
	burn_damage_amt = 15
	charges = 20

/obj/item/weapon/twohanded/offhand/shockpaddles
	icon = 'icons/obj/defibrillator.dmi'
	icon_state = "defibpaddleso"
	item_state = "defibpaddles"

/obj/item/weapon/twohanded/offhand/shockpaddles/atom_init()
	. = ..()
	var/mob/user = loc
	var/obj/item/weapon/twohanded/shockpaddles/paddles
	if(istype(user))
		paddles = user.get_active_hand()
	if(!istype(paddles))
		return
	if(paddles.cooldown)
		icon_state = "defibpaddleso_cooldown"
