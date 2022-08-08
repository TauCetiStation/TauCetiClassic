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

	user.cell.charge -= 30

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

/obj/item/harmalarm/attack_self(mob/user)
	if (!COOLDOWN_FINISHED(src, alarm_cooldown))
		to_chat(user, "<span class='warning'>The device is still recharging!</span>")
		return

	var/mob/living/silicon/robot/robot_user = null
	//early silicon check
	if(isrobot(user))
		robot_user = user

	if(robot_user)
		if(!robot_user.cell || robot_user.cell.charge < 1200)
			to_chat(user, "<span class='warning'>You don't have enough charge to do this!</span>")
			return
		robot_user.cell.charge -= 1000

	//emagged borg should screech loudly than normally
	if(!robot_user.emagged)
		user.visible_message("<span class='userdanger'>The siren pierces your hearing!</span>", \
			"<span class='danger'>[user] blares out a near-deafening siren from its speakers!</span>)")
		for(var/mob/living/carbon/carbon in get_hearers_in_view(9, user))
			if(ishuman(carbon))
				var/mob/living/carbon/human/H = carbon
				if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) && istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
					continue
			carbon.MakeConfused(6)

		user.audible_message("<span class='userdanger'>HUMAN HARM!</span>")
		playsound(get_turf(src), 'sound/ai/harmalarm.ogg', VOL_EFFECTS_MASTER, 70)
		COOLDOWN_START(src, alarm_cooldown, HARM_ALARM_SAFETY_COOLDOWN)
		log_message("[user] used a Cyborg Harm Alarm in [COORD(user.loc)]", TRUE)
		//send message for AI
		to_chat(robot_user.connected_ai, "<span class='notice'>('HARM ALARM' used by: [user]")
	else
		user.audible_message("<span class='userdanger'>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT</span>")
		for(var/mob/living/carbon/carbon in get_hearers_in_view(9, user))
			if(ishuman(carbon))
				var/mob/living/carbon/human/H = carbon
				//Can lings be stunned by loud sound? i think not
				if(!(ischangeling(H) || isshadowling(H)))
					H.ear_deaf += 30
					H.AdjustConfused(20)
					H.make_jittery(500)
			//Let's pretend to be a changeling
		for(var/obj/machinery/light/L in range(4, user))
			L.on = 1
			L.broken()

		playsound(get_turf(src), 'sound/machines/warning-buzzer.ogg')
		COOLDOWN_START(src, alarm_cooldown, HARM_ALARM_NO_SAFETY_COOLDOWN)
		log_message("[user] used an emagged Cyborg Harm Alarm in [COORD(user)]", TRUE)

/obj/item/weapon/grab/cyborghug
	name = "cyborg hug"
	desc = "A tool that helps organics get back on feet."
	icon = 'icons/obj/device.dmi'
	icon_state = "robot_helper"
	item_state = "robot_helper"
	allow_upgrade = FALSE
	var/charge_cost = 500

/obj/item/weapon/cyborghug/proc/can_use(mob/living/silicon/robot/user, mob/living/carbon/human/M)
	if(!user.cell || (user.cell.charge < charge_cost))
		to_chat(user, "<span class='warning'>\The [src] doesn't have enough charge left to do that.</span>")
		return FALSE

	return TRUE

/obj/item/weapon/cyborghug/attack(mob/living/carbon/human/M, mob/living/silicon/robot/user, def_zone)
	var/mob/living/carbon/human/H = M
	if(!istype(H) || !can_use(user, M))
		return
	if(state = GRAB_PASSIVE)
		robot_help_shake(M, user)
	else
		. = ..()

/obj/item/weapon/cyborghug/attack_self(mob/user)
	if(state = GRAB_PASSIVE)
		state = GRAB_AGGRESSIVE
		to_chat(user, "<span class='warning'>Power increased!</span>")
	else
		state = GRAB_PASSIVE
		to_chat(user, "<span class='notice'>Hugs!</span>")

/obj/item/weapon/cyborghug/proc/robot_help_shake(mob/living/carbon/human/M, mob/living/silicon/robot/user)
	if(M.lying)
		if(!M.IsSleeping())
			if(M.crawling)
				M.SetCrawling(FALSE)
		user.visible_message("<span class='notice'>[user] shakes [M] trying to wake [P_THEM(M.gender)] up!</span>", \
							"<span class='notice'>You shake [M] trying to wake [P_THEM(M.gender)] up!</span>")
	else
		if(!M.IsSleeping())
			if(user.zone_selected == BODY_ZONE_HEAD)
				user.visible_message("<span class='notice'>[user] bops [M] on the head!</span>", \
									"<span class='notice'>You bop [M] on the head!</span>")
			else
				user.visible_message("<span class='notice'>[user] hugs [M] in a firm bear-hug!</span>", \
								"<span class='notice'>You hug [M] firmly to make [P_THEM(M.gender)] feel better!</span>")
		else
			user.visible_message("<span class='notice'>[user] gently touches [M] trying to wake [P_THEM(M.gender)] up!</span>", \
								"<span class='notice'>You gently touch [M] trying to wake [P_THEM(M.gender)] up!</span>")
	M.AdjustSleeping(-10 SECONDS)
	M.AdjustParalysis(-3)
	M.AdjustStunned(-3)
	M.AdjustWeakened(-3)

	playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)

	user.cell.use(charge_cost)

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
