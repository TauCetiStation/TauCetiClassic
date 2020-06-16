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
	STOP_PROCESSING(SSobj, src)
	return 0

/obj/Destroy()
	if(!istype(src, /obj/machinery))
		STOP_PROCESSING(SSobj, src) // TODO: Have a processing bitflag to reduce on unnecessary loops through the processing lists
	nanomanager.close_uis(src)
	return ..()

/obj/proc/get_current_temperature()
	/*
	It actually returns a rise in temperature from the enviroment since I don't know why.
	Before it was called "is_hot". And it returned 0 if something is not any hotter than it should be.

	Slap me on the wrist if you ever will need this to return a meaningful value. ~Luduk
	*/
	return 0

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
	if(src && !QDELETED(src))
		qdel(src)
	return 2

/obj/singularity_pull(S, current_size)
	if(anchored)
		if(current_size >= STAGE_FIVE)
			anchored = 0
			step_towards(src,S)
	else
		step_towards(src,S)

// the obj is deconstructed into pieces, whether through careful disassembly or when destroyed.
/obj/proc/deconstruct(disassembled = TRUE)
	qdel(src)

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
		var/is_in_use = FALSE
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = TRUE
				if(ishuman(M)) //most users is humans, so check this first
					attack_hand(M)
					continue
				if(isobserver(M)) //ghosts and synths must use their own attack_ procs
					attack_ghost(M)
					continue
				if(isAI(M) || isrobot(M)) //VERY rare AI can be placed near to something
					//with custom attack_ai
					attack_ai(M)
					continue
				attack_hand(M)
		if (isAI(usr) || isrobot(usr))
			if (!(usr in nearby))
				if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = TRUE
					attack_ai(usr)

		if (isobserver(usr))
			if (!(usr in nearby))
				if (usr.client && usr.machine==src)
					is_in_use = TRUE
					attack_ghost(usr)

		// check for TK users

		if (ishuman(usr))
			if(istype(usr.l_hand, /obj/item/tk_grab) || istype(usr.r_hand, /obj/item/tk_grab))
				if(!(usr in nearby))
					if(usr.client && usr.machine==src)
						is_in_use = 1
						attack_hand(usr)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = FALSE
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = TRUE
				src.interact(M)
		var/ai_in_use = AutoUpdateAI(src)

		in_use = is_in_use|ai_in_use

/obj/attack_ghost(mob/dead/observer/user)
	if(user.client.machine_interactive_ghost && ui_interact(user) != -1)
		return
	..()

/obj/proc/damage_flags()
	return FALSE

/obj/proc/interact(mob/user)
	return

/obj/proc/container_resist()
	return

/obj/proc/update_icon()
	return

/mob/proc/unset_machine()
	if(machine)
		machine.on_unset_machine(src)
		machine = null

/mob/proc/set_machine(obj/O)
	if(src.machine)
		unset_machine(src.machine)
	src.machine = O
	if(istype(O))
		O.in_use = 1

/atom/movable/proc/on_unset_machine(mob/user)
	return

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)


/obj/proc/alter_health()
	return 1

/obj/proc/hide(h)
	return

/obj/proc/hides_under_flooring()
	return level == 1

/atom/movable/proc/get_listeners()
	return list()

/mob/get_listeners()
	. = list(src)
	for(var/mob/M in contents)
		. |= M.get_listeners()

/atom/movable/proc/get_listening_objs()
	return list(src)

/mob/get_listening_objs()
	. = list()
	for(var/atom/movable/AM in contents)
		. |= AM.get_listening_objs()

/obj/proc/hear_talk(mob/M, text, verb, datum/language/speaking)
	if(talking_atom)
		talking_atom.catchMessage(text, M)
/*
	var/mob/mo = locate(/mob) in src
	if(mo)
		var/rendered = "<span class='game say'><span class='name'>[M.name]: </span> <span class='message'>[text]</span></span>"
		mo.oldshow_message(rendered, 2)
		*/
	return

/obj/proc/tesla_act(power)
	being_shocked = 1
	var/power_bounced = power / 2
	tesla_zap(src, 3, power_bounced)
	addtimer(VARSET_CALLBACK(src, being_shocked, FALSE), 10)

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
				return FALSE
		if(Feeded.wear_mask)
			var/obj/item/Mask = Feeded.wear_mask
			if(Mask.flags & MASKCOVERSMOUTH)
				if (Feeded == user)
					to_chat(user, "You can't [eatverb] [food] through [Mask]")
				else
					to_chat(user, "You can't feed [Feeded] with [food] through [Mask]")
				return FALSE
		return TRUE
	if(isIAN(mob))
		var/mob/living/carbon/ian/dumdum = mob
		if(dumdum.head)
			var/obj/item/Head = dumdum.head
			if(Head.flags & HEADCOVERSMOUTH)
				if (dumdum == user)
					to_chat(user, "You can't [eatverb] [food] through [Head]")
				else
					to_chat(user, "You can't feed [dumdum] with [food] through [Head]")
				return FALSE
		return TRUE

/obj/proc/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, caller)
	return !density

// To be called from things that spill objects on the floor.
// Makes an object move around randomly for a couple of tiles.
/obj/proc/tumble_async(dist)
	if(dist >= 1)
		dist += rand(0, 1)
		for(var/i in 1 to dist)
			if(src)
				step(src, pick(cardinal))
				sleep(rand(2, 4))
