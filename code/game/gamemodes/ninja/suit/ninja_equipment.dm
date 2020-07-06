//For the love of god,space out your code! This is a nightmare to read.

// SPACE NINJA SUIT

/obj/item/clothing/suit/space/space_ninja/atom_init()
	. = ..()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/init//suit initialize verb
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_instruction//for AIs
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_holo
	//verbs += /obj/item/clothing/suit/space/space_ninja/proc/display_verb_procs//DEBUG. Doesn't work.
	spark_system = new()//spark initialize
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	stored_research = list()//Stolen research initialize.
	for(var/T in subtypesof(/datum/tech))//Store up on research.
		stored_research += new T
	var/reagent_amount//reagent initialize
	for(var/reagent_id in reagent_list)
		reagent_amount += reagent_id == "radium" ? r_maxamount+(a_boost*a_transfer) : r_maxamount//AI can inject radium directly.
	reagents = new(reagent_amount)
	reagents.my_atom = src
	for(var/reagent_id in reagent_list)
		reagent_id == "radium" ? reagents.add_reagent(reagent_id, r_maxamount+(a_boost*a_transfer)) : reagents.add_reagent(reagent_id, r_maxamount)//It will take into account radium used for adrenaline boosting.
	cell = new/obj/item/weapon/stock_parts/cell/high//The suit should *always* have a battery because so many things rely on it.
	cell.charge = 9000//Starting charge should not be higher than maximum charge. It leads to problems with recharging.

/obj/item/clothing/suit/space/space_ninja/Destroy()
	if(affecting)//To make sure the window is closed.
		affecting << browse(null, "window=hack spideros")
	if(AI)//If there are AIs present when the ninja kicks the bucket.
		killai()
	if(hologram)//If there is a hologram
		qdel(hologram.i_attached)//Delete it and the attached image.
		qdel(hologram)
	return ..()

//Simply deletes all the attachments and self, killing all related procs.
/obj/item/clothing/suit/space/space_ninja/proc/terminate()
	qdel(n_hood)
	qdel(n_gloves)
	qdel(n_shoes)
	qdel(src)

/obj/item/clothing/suit/space/space_ninja/proc/killai(mob/living/silicon/ai/A = AI)
	if(A.client)
		to_chat(A, "<span class='warning'>Self-erase protocol dete-- *bzzzzz*</span>")
		A << browse(null, "window=hack spideros")
	AI = null
	A.death(1)//Kill, deleting mob.
	qdel(A)
	return

// SUIT VERBS

/obj/item/clothing/suit/space/space_ninja/proc/init()
	set name = "Initialize Suit"
	set desc = "Initializes the suit for field operation."
	set category = "Ninja Equip"

	ninitialize()
	return

/obj/item/clothing/suit/space/space_ninja/proc/deinit()
	set name = "De-Initialize Suit"
	set desc = "Begins procedure to remove the suit."
	set category = "Ninja Equip"

	if(s_control&&!s_busy)
		deinitialize()
	else
		to_chat(affecting, "<span class='warning'>The function did not trigger!</span>")
	return

/obj/item/clothing/suit/space/space_ninja/proc/spideros()
	set name = "Display SpiderOS"
	set desc = "Utilize built-in computer system."
	set category = "Ninja Equip"

	if(s_control&&!s_busy&&!kamikaze)
		display_spideros()
	else
		to_chat(affecting, "<span class='warning'>The interface is locked!</span>")
	return

// INITIALIZE

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize(delay = s_delay, mob/living/carbon/human/U = loc)
	if(U.mind && U.mind.assigned_role=="MODE" && !s_initialized && !s_busy)//Shouldn't be busy... but anything is possible I guess.
		s_busy = 1
		for(var/i,i<7,i++)
			switch(i)
				if(0)
					to_chat(U, "<span class='notice'>Now initializing...</span>")
				if(1)
					if(!lock_suit(U))//To lock the suit onto wearer.
						break
					to_chat(U, "<span class='notice'>Securing external locking mechanism...\nNeural-net established.</span>")
				if(2)
					to_chat(U, "<span class='notice'>Extending neural-net interface...\nNow monitoring brain wave pattern...</span>")
				if(3)
					if(U.stat==2||U.health<=0)
						to_chat(U, "<span class='warning'><B>FĆAL �Rr�R</B>: 344--93#�&&21 BR��N |/|/aV� PATT$RN <B>RED</B>\nA-A-aB�rT�NG...</span>")
						unlock_suit()
						break
					lock_suit(U, TRUE)//Check for icons.
					U.regenerate_icons()
					to_chat(U, "<span class='notice'>Linking neural-net interface...\nPattern <B>GREEN</B>, continuing operation.</span>")
				if(4)
					to_chat(U, "<span class='notice'>VOID-shift device status: <B>ONLINE</B>.\nCLOAK-tech device status: <B>ONLINE</B>.</span>")
				if(5)
					to_chat(U, "<span class='notice'>Primary system status: <B>ONLINE</B>.\nBackup system status: <B>ONLINE</B>.\nCurrent energy capacity: <B>[cell.charge]</B>.</span>")
				if(6)
					to_chat(U, "<span class='notice'>All systems operational. Welcome to <B>SpiderOS</B>, [U.real_name].</span>")
					grant_ninja_verbs()
					grant_equip_verbs()
					ntick()
			sleep(delay)
		s_busy = 0
	else
		if(!U.mind||U.mind.assigned_role!="MODE")//Your run of the mill persons shouldn't know what it is. Or how to turn it on.
			to_chat(U, "You do not understand how this suit functions. Where the heck did it even come from?")
		else if(s_initialized)
			to_chat(U, "<span class='warning'>The suit is already functioning.</span> <b>Please report this bug.</b>")
		else
			to_chat(U, "<span class='warning'><B>ERROR</B>:</span> You cannot use this function at this time.")
	return

// DEINITIALIZE

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize(delay = s_delay)
	if(affecting==loc&&!s_busy)
		var/mob/living/carbon/human/U = affecting
		if(!s_initialized)
			to_chat(U, "<span class='warning'>The suit is not initialized.</span> <b>Please report this bug.</b>")
			return
		if(alert("Are you certain you wish to remove the suit? This will take time and remove all abilities.",,"Yes","No")=="No")
			return
		if(s_busy||flush)
			to_chat(U, "<span class='warning'><B>ERROR</B>:</span> You cannot use this function at this time.")
			return
		s_busy = 1
		for(var/i = 0,i<7,i++)
			switch(i)
				if(0)
					to_chat(U, "<span class='notice'>Now de-initializing...</span>")
					remove_kamikaze(U)//Shutdowns kamikaze.
					spideros = 0//Spideros resets.
				if(1)
					to_chat(U, "<span class='notice'>Logging off, [U:real_name]. Shutting down <B>SpiderOS</B>.</span>")
					remove_ninja_verbs()
				if(2)
					to_chat(U, "<span class='notice'>Primary system status: <B>OFFLINE</B>.\nBackup system status: <B>OFFLINE</B>.</span>")
				if(3)
					to_chat(U, "<span class='notice'>VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>.</span>")
					cancel_stealth()//Shutdowns stealth.
				if(4)
					to_chat(U, "<span class='notice'>Disconnecting neural-net interface...<B>Success</B>.</span>")
				if(5)
					to_chat(U, "<span class='notice'>Disengaging neural-net interface...<B>Success</B>.</span>")
				if(6)
					to_chat(U, "<span class='notice'>Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>.</span>")
					blade_check(U,2)
					remove_equip_verbs()
					unlock_suit()
					U.regenerate_icons()
			sleep(delay)
		s_busy = 0
	return




// GENERAL SUIT PROCS

/obj/item/clothing/suit/space/space_ninja/proc/blade_check(mob/living/carbon/U, X = 1)//Default to checking for blade energy.
	switch(X)
		if(1)
			if(istype(U.get_active_hand(), /obj/item/weapon/melee/energy/blade))
				if(cell.charge<=0)//If no charge left.
					U.drop_item()//Blade is dropped from active hand (and deleted).
				else	return 1
			else if(istype(U.get_inactive_hand(), /obj/item/weapon/melee/energy/blade))
				if(cell.charge<=0)
					U.swap_hand()//swap hand
					U.drop_item()//drop blade
				else	return 1
		if(2)
			if(istype(U.get_active_hand(), /obj/item/weapon/melee/energy/blade))
				U.drop_item()
			if(istype(U.get_inactive_hand(), /obj/item/weapon/melee/energy/blade))
				U.swap_hand()
				U.drop_item()
	return 0

/obj/item/clothing/suit/space/space_ninja/examine(mob/user)
	..()
	if(s_initialized)
		if(user == affecting)
			if(s_control)
				to_chat(user, "All systems operational. Current energy capacity: <B>[cell.charge]</B>.")
				if(!kamikaze)
					to_chat(user, "The CLOAK-tech device is <B>[s_active ? "active" : "inactive"]</B>.")
				else
					to_chat(user, "<span class='userdanger'>KAMIKAZE MODE ENGAGED!</span>")
				to_chat(user, "There are <B>[s_bombs]</B> smoke bomb\s remaining.")
				to_chat(user, "There are <B>[a_boost]</B> adrenaline booster\s remaining.")
			else
				to_chat(user, "�rr�R �a��a�� No-�-� f��N� 3RR�r")

/obj/item/clothing/suit/space/space_ninja/attack_reaction(mob/living/L, reaction_type, mob/living/carbon/human/T = null)
	if(reaction_type == REACTION_ITEM_TAKE || reaction_type == REACTION_ITEM_TAKEOFF)
		return

	if(reaction_type == REACTION_HIT_BY_BULLET || reaction_type == REACTION_INTERACT_ARMED || reaction_type == REACTION_INTERACT_UNARMED || reaction_type == REACTION_THROWITEM || reaction_type == REACTION_ATACKED)
		pop_stealth()
		return

	cancel_stealth()
