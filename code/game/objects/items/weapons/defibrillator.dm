#define DEFIB_TIME_LIMIT (8 MINUTES) //past this many secons, defib is useless. Currently 8 Minutes
#define DEFIB_TIME_LOSS  (2 MINUTES) //past this many seconds, brain damage occurs. Currently 2 minutes

//from old nanotrasen
/obj/item/weapon/defibrillator
	name = "defibrillator"
	desc = "Device to treat ventricular fibrillation or pulseless ventricular tachycardia."
	//icon_state = "Defibunit"
	item_state = "defibunit"
	icon_state = "defibunit"
	var/state_on = "defibunit_on"
	action_button_name = "Switch Defibrillator"
	w_class = 3.0
	damtype = "brute"
	force = 4
	var/charged = 0
	var/charges = 8
	origin_tech = "combat=2;biotech=2"

/obj/item/weapon/defibrillator/attack_self(mob/user)
	if(!charged)
		if(charges)
			user.visible_message("[user] charges their [src].", "You charge your [src].</span>", "You hear electrical zap.")
			sleep(30)
			playsound(src, 'sound/items/defib_charge.ogg', 50, 1, 1)
			charged = 1
			spawn(25)
				if(wet)
					var/turf/T = get_turf(src)
					T.visible_message("<span class='wet'>Some wet device has been discharged!</span>")
					var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
					if(W)
						W.electrocute_act(150)
					else if(istype(loc, /mob/living))
						var/mob/living/L = loc
						L.Weaken(6)
						var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
						s.set_up(3, 1, src)
						s.start()
					discharge()
					return
				charged = 2
				//icon_state = "Defibunit_on"
				icon_state = state_on
				damtype = "fire"
				force = 20
		else
			to_chat(user, "Internal battery worn out. Recharge needed.")

/obj/item/weapon/defibrillator/proc/discharge()
	//icon_state = "Defibunit"
	icon_state = initial(icon_state)
	damtype = "brute"
	charged = 0
	force = initial(force)
	charges--

/obj/item/weapon/defibrillator/attack(mob/M, mob/user) // TODO update defibs
	if(charged == 2 && istype(M, /mob/living/carbon))
		var/mob/living/carbon/C = M
		if(C.ssd_check())
			to_chat(find_dead_player(C.ckey, 1), "Someone is attempting to resuscitate you. Re-enter your body if you want to be revived!")

		//beginning to place the paddles on patient's chest to allow some time for people to move away to stop the process
		user.visible_message("<span class='warning'>\The [user] begins to place [src] on [C]'s chest.</span>", "<span class='warning'>You begin to place [src] on [C]'s chest...</span>")
		if(!do_after(user, 30, target = C))
			return

		user.visible_message("<span class='notice'>\The [user] places [src] on [C]'s chest.</span>", "<span class='warning'>You place [src] on [C]'s chest.</span>")
		playsound(src, 'sound/machines/defib_charge.ogg', 50, 0)

		var/error = can_defib(C)
		if(error)
			make_announcement(error, "warning")
			playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
			return

		if(check_blood_level(C))
			make_announcement("buzzes, \"Warning - Patient is in hypovolemic shock.\"", "warning") //also includes heart damage

		//placed on chest and short delay to shock for dramatic effect, revive time is 5sec total
		if(!do_after(user, 30, C))
			return

		if(charged != 2)
			make_announcement("buzzes, \"Insufficient charge.\"", "warning")
			playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
			return

		C.visible_message("<span class='warning'>\The [C]'s body convulses a bit.</span>")
		playsound(src, "bodyfall", 50, 1)
		playsound(src, 'sound/items/defib_zap.ogg', 50, 1, 1)

		discharge()
		C.apply_effect(4, STUN, 0)
		C.apply_effect(4, WEAKEN, 0)
		C.apply_effect(4, STUTTER, 0)
		if(C.jitteriness<=100)
			C.make_jittery(150)
		else
			C.make_jittery(50)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, C)
		s.start()

		error = can_revive(C)
		if(error)
			make_announcement(error, "warning")
			playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
			return

		user.visible_message("[user] shocks [M] with [src].", "You shock [M] with [src].</span>", "You hear electricity zaps flesh.")
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Shock [M.name] ([M.ckey]) with [src.name]</font>"
		msg_admin_attack("[user.name] ([user.ckey]) shock [M.name] ([M.ckey]) with [src.name] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		if(C.health <= config.health_threshold_crit || prob(10))
			var/suff = min(C.getOxyLoss(), 20)
			C.adjustOxyLoss(-suff)
		else
			C.adjustFireLoss(5)
		C.updatehealth()
		if(C.stat == DEAD && C.health > config.health_threshold_dead)
			C.reanimate_body()
			make_announcement("pings, \"Resuscitation successful.\"", "notice")
			playsound(src, 'sound/machines/defib_success.ogg', 50, 0)

		if(wet)
			var/turf/T = get_turf(src)
			T.visible_message("<span class='wet'>Some wet device has been discharged!</span>")
			var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
			if(W)
				W.electrocute_act(150)
			else if(istype(loc, /mob/living))
				var/mob/living/L = loc
				L.Weaken(6)
				s = new /datum/effect/effect/system/spark_spread
				s.set_up(3, 1, src)
				s.start()
	else
		return ..(M,user)

/mob/living/carbon/proc/return_to_body_dialog()
	if (key) // in body?
		src << 'sound/misc/mario_1up.ogg'
	else if(mind)
		for(var/mob/dead/observer/ghost in player_list)
			if(ghost.mind == mind && ghost.can_reenter_corpse)
				ghost << 'sound/misc/mario_1up.ogg'
				var/answer = alert(ghost,"You have been reanimated. Do you want to return to body?","Reanimate","Yes","No")
				if(answer == "Yes")
					ghost.reenter_corpse()
				break

/mob/living/carbon/proc/reanimate_body(stat = UNCONSCIOUS)
	var/deadtime = world.time - timeofdeath

	dead_mob_list -= src
	living_mob_list += src
	timeofdeath = 0
	src.stat = stat
	tod = null
	failed_last_breath = 0 //So mobs that died of oxyloss don't revive and have perpetual out of breath.
	update_health_hud()
	return_to_body_dialog()

	emote("gasp")
	Weaken(rand(10,25))
	updatehealth()
	apply_brain_damage(src, deadtime)

/mob/living/carbon/proc/apply_brain_damage(mob/living/carbon/C, deadtime)
	if(deadtime < DEFIB_TIME_LOSS) return

	if(!C.should_have_organ(BP_BRAIN)) return //no brain

	var/obj/item/organ/brain/brain = C.organs_by_name[BP_BRAIN]
	if(!brain) return //no brain

	var/brain_damage = Clamp((deadtime - DEFIB_TIME_LOSS)/(DEFIB_TIME_LIMIT - DEFIB_TIME_LOSS)*brain.max_damage, C.getBrainLoss(), brain.max_damage)
	C.setBrainLoss(brain_damage)

//Checks for various conditions to see if the mob is revivable
/obj/item/weapon/defibrillator/proc/can_defib(mob/living/carbon/C) //This is checked before doing the defib operation
	if((C.species.flags[NO_SCAN]) || C.isSynthetic())
		return "buzzes, \"Unrecogized physiology. Operation aborted.\""

	if(C.stat != DEAD)
		return "buzzes, \"Patient is not in a valid state. Operation aborted.\""

	if(!check_contact(C))
		return "buzzes, \"Patient's chest is obstructed. Operation aborted.\""

	return null

/obj/item/weapon/defibrillator/proc/make_announcement(message)
	audible_message("<b>\The [src]</b> [message]", "\The [src] vibrates slightly.")

/obj/item/weapon/defibrillator/proc/check_contact(mob/living/carbon/C)
	for(var/obj/item/clothing/cloth in list(C.wear_suit, C.w_uniform))
		if((cloth.body_parts_covered & UPPER_TORSO) && (cloth.flags & THICKMATERIAL))
			return FALSE
	return TRUE

/obj/item/weapon/defibrillator/proc/check_vital_organs(mob/living/carbon/C)
	for(var/organ_tag in C.species.has_organ)
		var/obj/item/organ/IO = C.species.has_organ[organ_tag]
		var/name = initial(IO.name)
		var/vital = initial(IO.vital) //check for vital organs
		if(vital)
			IO = C.organs_by_name[organ_tag]
			if(!IO)
				return "buzzes, \"Resuscitation failed - Patient is missing vital organ ([name]). Further attempts futile.\""
			if(IO.damage > IO.max_damage)
				return "buzzes, \"Resuscitation failed - Excessive damage to vital organ ([name]). Further attempts futile.\""
	return null

/obj/item/weapon/defibrillator/proc/check_blood_level(mob/living/carbon/C)
	if(!C.should_have_organ(BP_HEART))
		return FALSE

	var/obj/item/organ/heart/heart = C.organs_by_name[BP_HEART]
	if(!heart || C.get_effective_blood_volume() < BLOOD_VOLUME_SURVIVE)
		return TRUE

	return FALSE

/obj/item/weapon/defibrillator/proc/can_revive(mob/living/carbon/C) //This is checked right before attempting to revive

	//var/deadtime = world.time - C.timeofdeath
	//if((world.time - C.timeofdeath) < 3600 || C.stat != DEAD)
	//if (deadtime > DEFIB_TIME_LIMIT)
	if((world.time - C.timeofdeath) >= 3600)
		return "buzzes, \"Resuscitation failed - Excessive neural degeneration. Further attempts futile.\""

	C.updatehealth()
	if(C.health + C.getOxyLoss() <= config.health_threshold_dead || (C.disabilities & (HUSK | NOCLONE)))
		return "buzzes, \"Resuscitation failed - Severe tissue damage makes recovery of patient impossible via defibrillator. Further attempts futile.\""

	var/bad_vital_organ = check_vital_organs(C)
	if(bad_vital_organ)
		return bad_vital_organ

	//this needs to be last since if any of the 'other conditions are met their messages take precedence
	if(C.ssd_check())
		return "buzzes, \"Resuscitation failed - Mental interface error. Further attempts may be successful.\""

	return null

#undef DEFIB_TIME_LIMIT
#undef DEFIB_TIME_LOSS
