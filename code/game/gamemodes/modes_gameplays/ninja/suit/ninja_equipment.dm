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
	affecting = null
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
