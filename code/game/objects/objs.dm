/obj
	//var/datum/module/mod		//not used
	var/m_amt = 0	// metal
	var/g_amt = 0	// glass
	var/w_amt = 0	// waster amounts
	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/reliability = 100	//Used by SOME devices to determine how reliable they are.
	var/crit_fail = 0
	var/unacidable = 0 //universal "unacidabliness" var, here so you can use it in any obj.
	animate_movement = 2
	var/throwforce = 1
	var/list/attack_verb = list() //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/sharp = 0		// whether this object cuts
	var/edge = 0		// whether this object is more likely to dismember
	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!

	var/damtype = "brute"
	var/force = 0
	var/icon_custom = null //Default Bay12 sprite or not

	var/being_shocked = 0

/obj/item/proc/is_used_on(obj/O, mob/user)

/obj/process()
	SSobj.processing.Remove(src)
	return 0

/obj/Destroy()
	if(!istype(src, /obj/machinery))
		SSobj.processing.Remove(src) // TODO: Have a processing bitflag to reduce on unnecessary loops through the processing lists
	nanomanager.close_uis(src)
	return ..()

/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/singularity_act()
	ex_act(1.0)
	if(src && !qdeleted(src))
		qdel(src)
	return 2

/obj/singularity_pull(S, current_size)
	if(anchored)
		if(current_size >= STAGE_FIVE)
			anchored = 0
			step_towards(src,S)
	else
		step_towards(src,S)

/obj/proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
	//Return: (NONSTANDARD)
	//		null if object handles breathing logic for lifeform
	//		datum/air_group to tell lifeform to process using that breath return
	//DEFAULT: Take air from turf to give to have mob process
	if(breath_request>0)
		return remove_air(breath_request)
	else
		return null

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.attack_hand(M)
		if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
			if (!(usr in nearby))
				if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = 1
					src.attack_ai(usr)

		// check for TK users

		if (istype(usr, /mob/living/carbon/human))
			if(istype(usr.l_hand, /obj/item/tk_grab) || istype(usr.r_hand, /obj/item/tk_grab/))
				if(!(usr in nearby))
					if(usr.client && usr.machine==src)
						is_in_use = 1
						src.attack_hand(usr)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.interact(M)
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = 0

/obj/proc/interact(mob/user)
	return

/obj/proc/container_resist()
	return

/obj/proc/update_icon()
	return

/mob/proc/unset_machine(obj/O)
	if(O && O == src.machine)
		src.machine = null
	else
		src.machine = null

/mob/proc/set_machine(obj/O)
	if(src.machine)
		unset_machine(src.machine)
	src.machine = O
	if(istype(O))
		O.in_use = 1

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)


/obj/proc/alter_health()
	return 1

/obj/proc/hide(h)
	return


/obj/proc/hear_talk(mob/M, text, verb, datum/language/speaking)
	if(talking_atom)
		talking_atom.catchMessage(text, M)
/*
	var/mob/mo = locate(/mob) in src
	if(mo)
		var/rendered = "<span class='game say'><span class='name'>[M.name]: </span> <span class='message'>[text]</span></span>"
		mo.show_message(rendered, 2)
		*/
	return

/obj/proc/tesla_act(power)
	being_shocked = 1
	var/power_bounced = power / 2
	tesla_zap(src, 3, power_bounced)
	spawn(10)
		reset_shocked()

/obj/proc/reset_shocked()
	being_shocked = 0

//mob - who is being feed
//user - who is feeding
//food - whai is feeded
//eatverb - take/drink/eat method
/proc/CanEat(user, mob, food, eatverb = "consume")
	if(ishuman(mob))
		var/mob/living/carbon/human/Feeded = mob
		if(Feeded.head)
			var/obj/item/Head = Feeded.head
			if(Head.flags & HEADCOVERSMOUTH)
				if (Feeded == user)
					to_chat(user, "You can't [eatverb] [food] through [Head]")
				else
					to_chat(user, "You can't feed [Feeded] with [food] through [Head]")
				return 0
		if(Feeded.wear_mask)
			var/obj/item/Mask = Feeded.wear_mask
			if(Mask.flags & MASKCOVERSMOUTH)
				if (Feeded == user)
					to_chat(user, "You can't [eatverb] [food] through [Mask]")
				else
					to_chat(user, "You can't feed [Feeded] with [food] through [Mask]")
				return 0
		return 1
