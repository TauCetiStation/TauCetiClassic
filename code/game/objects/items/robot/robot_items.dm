#define HARM_ALARM_NO_SAFETY_COOLDOWN (60 SECONDS)
#define HARM_ALARM_SAFETY_COOLDOWN (20 SECONDS)

/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
//Might want to move this into several files later but for now it works here
/obj/item/borg/stun
	name = "electrified arm"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/obj/item/borg/stun/attack(mob/living/M, mob/living/silicon/robot/user)
	M.log_combat(user, "stunned with [name]")
	playsound(src, 'sound/machines/defib_zap.ogg', VOL_EFFECTS_MASTER)

	user.cell.charge -= 500

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())
		var/calc_power = 125 // 25% better than stungloves
		calc_power *= H.get_siemens_coefficient_organ(BP)
		M.apply_effects(0,0,0,0,2,0,0,calc_power)
	else
		M.Weaken(5)
		M.Stuttering(5)
		M.Stun(5)


	M.visible_message("<span class='warning'><B>[user] has prodded [M] with an electrically-charged arm!</B></span>", blind_message = "<span class='warning'>You hear someone fall</span>")

/obj/item/borg/overdrive
	name = "overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/obj/item/harmalarm
	name = "Sonic Harm Prevention Tool"
	desc = "Releases a harmless blast that confuses most organics. For when the harm is JUST TOO MUCH."
	icon = 'icons/obj/device.dmi'
	icon_state = "megaphone"
	COOLDOWN_DECLARE(alarm_cooldown)

/obj/item/harmalarm/attack_self(mob/living/silicon/robot/user)
	if (!COOLDOWN_FINISHED(src, alarm_cooldown))
		to_chat(user, "<span class='warning'>The device is still recharging!</span>")
		return
	//early silicon check
	if(!isrobot(user))
		return

	if(!user.cell || user.cell.charge < 1000 || (user.emagged && user.cell.charge < 2500))
		to_chat(user, "<span class='warning'>You don't have enough charge to do this!</span>")
		return
	if(user.emagged)
		user.cell.use(2500)
	else
		user.cell.use(1000)
	//emagged borg should screech loudly than normally
	if(!user.emagged)
		user.visible_message("<span class='userdanger'>The siren pierces your hearing!</span>", \
			"<span class='danger'>[user] blares out a near-deafening siren from its speakers!</span>")
		for(var/mob/living/carbon/human/H in view(9, user))
			if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) && istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
				continue
			if(H.head)
				var/obj/item/clothing/C = H.head
				if(istype(C) && C.flashbang_protection)
					continue
			H.MakeConfused(5)

		user.audible_message("<span class='userdanger'>HUMAN HARM!</span>")
		playsound(get_turf(src), 'sound/ai/harmalarm.ogg', VOL_EFFECTS_MASTER, 70)
		COOLDOWN_START(src, alarm_cooldown, HARM_ALARM_SAFETY_COOLDOWN)
		user.attack_log += "\[[time_stamp()]\]<font color='red'>used a Cyborg Harm Alarm in [COORD(user.loc)]</font>"
		//send message for AI
		to_chat(user.connected_ai, "<span class='info'>HARM ALARM used by <a href=?src=\ref[user.connected_ai];track=\ref[user]>[user]</span>")
	else
		user.audible_message("<span class='userdanger'>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT</span>")
		playsound(usr, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER, 100)
		for(var/mob/living/carbon/human/H in view(9, user))
			//Can lings be stunned by loud sound? i think not
			if(ischangeling(H))
				continue
			if(isshadowling(H))
				continue
			if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) && istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
				continue
			H.ear_deaf += 30
			H.MakeConfused(10)
			H.make_jittery(250)
		//Let's pretend to be a changeling
		for(var/obj/machinery/light/L in range(4, user))
			L.on = TRUE
			L.broken()

		COOLDOWN_START(src, alarm_cooldown, HARM_ALARM_NO_SAFETY_COOLDOWN)
		user.attack_log += "\[[time_stamp()]\]<font color='red'>used emagged Cyborg Harm Alarm in [COORD(user.loc)]</font>"

/obj/item/weapon/cyborghug
	name = "hugging module"
	desc = "For when a someone really needs a hug."
	icon = 'icons/obj/device.dmi'
	icon_state = "help"
	var/electrify = 0

/obj/item/weapon/cyborghug/proc/can_use(mob/living/silicon/robot/user, mob/living/carbon/human/M)
	if(!isrobot(user))
		return FALSE
	if(!user.cell || (user.cell.charge < 500))
		to_chat(user, "<span class='warning'>You doesn't have enough charge left to do that.</span>")
		return FALSE
	return TRUE

/obj/item/weapon/cyborghug/attack(mob/living/carbon/human/M, mob/living/silicon/robot/user, def_zone)
	var/mob/living/carbon/human/H = M
	if(!istype(H) || !can_use(user, H))
		return
	if(electrify && user.emagged)
		robot_stun_act(H, user)
	else
		robot_help_shake(H, user)

/obj/item/weapon/cyborghug/attack_self(mob/living/silicon/robot/user)
	electrify = !electrify
	if(electrify && user.emagged)
		to_chat(user, "<span class='warning'>Power increased! Electrifying arms...</span>")
	else
		to_chat(user, "<span class='notice'>Hugs!</span>")

/obj/item/weapon/cyborghug/proc/robot_help_shake(mob/living/carbon/human/M, mob/living/silicon/robot/user)
	if(M.lying)
		if(!M.IsSleeping())
			if(M.crawling)
				M.SetCrawling(FALSE)
		user.visible_message("<span class='notice'>[user] shakes [M] trying to wake [P_THEM(M)] up!</span>", \
							"<span class='notice'>You shake [M] trying to wake [P_THEM(M)] up!</span>")
	else
		if(!M.IsSleeping())
			if(M.has_bodypart(BP_HEAD) && (user.get_targetzone() == BP_HEAD))
				user.visible_message("<span class='notice'>[user] bops [M] on the head!</span>", \
									"<span class='notice'>You bop [M] on the head!</span>")
			else
				user.visible_message("<span class='notice'>[user] hugs [M] in a firm bear-hug!</span>", \
								"<span class='notice'>You hug [M] firmly to make [P_THEM(M)] feel better!</span>")
		else
			user.visible_message("<span class='notice'>[user] gently touches [M] trying to wake [P_THEM(M)] up!</span>", \
								"<span class='notice'>You gently touch [M] trying to wake [P_THEM(M)] up!</span>")
	M.AdjustSleeping(-10 SECONDS)
	M.AdjustParalysis(-3)
	M.AdjustStunned(-3)
	M.AdjustWeakened(-3)
	user.cell.use(500)
	playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/cyborghug/proc/robot_stun_act(mob/living/carbon/human/M, mob/living/silicon/robot/user)
	user.cell.use(500)
	var/calc_power = 100
	var/obj/item/organ/external/BP = M.get_bodypart(user.get_targetzone())
	calc_power *= M.get_siemens_coefficient_organ(BP)
	M.visible_message("<span class='warning bold'>[user] electrocutes [M] with [src] touch!</span>")
	M.log_combat(user, "stunned witht [name]")
	M.apply_effects(0,0,0,0,2,0,0,calc_power)
	playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(3, 1, M)
	s.start()

/obj/item/borg/bubble_creator
	name = "Energy Barrier Projector"
	desc = "A projector that creates fragile energy fields."
	icon = 'icons/obj/device.dmi'
	icon_state = "bubble_creator"
	var/max_fields = 5

/obj/item/borg/bubble_creator/attack_self(mob/living/silicon/robot/user)
	if(!isrobot(user) || !user.cell)
		return
	if(global.peacekeeper_shields_count >= max_fields)
		to_chat(user, "<span class='warning'>Recharging!</span>")
		return
	if(user.cell.charge < 250)
		to_chat(user, "<span class='warning'>Not enough charge!</span>")
		return
	user.cell.use(250)
	var/cyborg_bubble = new /obj/structure/barricade/bubble(user.loc)
	QDEL_IN(cyborg_bubble, 5 SECONDS)

/**********************************************************************
						HUD/SIGHT things
***********************************************************************/
/obj/item/borg/sight
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	var/sight_mode = null


/obj/item/borg/sight/xray
	name = "x-ray Vision"
	sight_mode = BORGXRAY


/obj/item/borg/sight/thermal
	name = "thermal vision"
	sight_mode = BORGTHERM
	icon_state = "thermal"
	icon = 'icons/obj/clothing/glasses.dmi'


/obj/item/borg/sight/meson
	name = "meson vision"
	sight_mode = BORGMESON
	icon_state = "meson"
	icon = 'icons/obj/clothing/glasses.dmi'

/obj/item/borg/sight/night
	name = "night vision"
	sight_mode = BORGNIGHT
	icon_state = "night"
	icon = 'icons/obj/clothing/glasses.dmi'
