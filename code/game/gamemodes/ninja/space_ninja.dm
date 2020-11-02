// For the love of god,space out your code! This is a nightmare to read.

/var/global/toggle_space_ninja = TRUE  //TRUE, If ninjas can spawn by admins and as random event or not.

// CURRENT PLAYER VERB

/client/proc/cmd_admin_ninjafy(mob/living/carbon/human/M in player_list)
	set category = null
	set name = "Make Space Ninja"

	if(!SSticker)
		alert("Wait until the game starts")
		return
	if(!toggle_space_ninja)
		alert("Space Ninjas spawning is disabled.")
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		log_admin("[key_name(src)] turned [H.key] into a Space Ninja.")
		spawn(10)
			H.create_mind_space_ninja()
			H.equip_space_ninja(1)
			if(istype(H.wear_suit, /obj/item/clothing/suit/space/space_ninja))
				var/obj/item/clothing/suit/space/space_ninja/S = H.wear_suit
				S.randomize_param()
				spawn(0)
					S.ninitialize(10, H)
	else
		alert("Invalid mob")

// CURRENT GHOST VERB

/client/proc/send_space_ninja()
	set category = "Fun"
	set name = "Spawn Space Ninja"
	set desc = "Spawns a space ninja for when you need a teenager with attitude."
	set popup_menu = 0

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!SSticker.mode)
		alert("The game hasn't started yet!")
		return
	if(!toggle_space_ninja)
		alert("Space Ninjas spawning is disabled.")
		return
	if(alert("Are you sure you want to send in a space ninja?",,"Yes","No")=="No")
		return

	var/mission

	var/input = ckey(input("Pick ckey to spawn as the Space Ninja", "Key", ""))
	if(!input || !get_mob_by_key(input))
		return

	while(!mission)
		mission = sanitize(input(src, "Please specify which mission the space ninja shall undertake.", "Specify Mission", ""))
		if(!mission)
			if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
				return

	log_admin("[key_name(usr)] used Spawn Space Ninja.")

	if(space_ninja_arrival(input, mission))
		message_admins("<span class='notice'>[key_name_admin(usr)] has spawned [input] as a Space Ninja.\nTheir <b>mission</b> is: [mission]</span>")

	return

// NINJA CREATION PROCS

/proc/create_space_ninja(obj/spawn_point)
	var/mob/living/carbon/human/new_ninja = new(spawn_point.loc)
	var/ninja_title = pick(ninja_titles)
	var/ninja_name = pick(ninja_names)
	new_ninja.gender = pick(MALE, FEMALE)

	var/datum/preferences/A = new()//Randomize appearance for the ninja.
	A.randomize_appearance_for(new_ninja)
	new_ninja.real_name = "[ninja_title] [ninja_name]"
	new_ninja.dna.ready_dna(new_ninja)
	new_ninja.create_mind_space_ninja()
	new_ninja.equip_space_ninja()
	return new_ninja

/mob/living/carbon/human/proc/create_mind_space_ninja()
	mind_initialize()
	mind.assigned_role = "MODE"
	mind.special_role = "Ninja"

	//SSticker.mode.ninjas |= mind
	return 1

/mob/living/carbon/human/proc/equip_space_ninja(safety=0)//Safety in case you need to unequip stuff for existing characters.
	if(safety)
		qdel(w_uniform)
		qdel(wear_suit)
		qdel(wear_mask)
		qdel(head)
		qdel(shoes)
		qdel(gloves)

	equipOutfit(/datum/outfit/space_ninja)
	return 1


// HELPER PROCS

//Randomizes suit parameters.
/obj/item/clothing/suit/space/space_ninja/proc/randomize_param()
	s_cost = rand(1,20)
	s_acost = rand(20,100)
	k_cost = rand(100,500)
	k_damage = rand(1,20)
	s_delay = rand(10,100)
	s_bombs = rand(5,20)
	a_boost = rand(1,7)

//This proc prevents the suit from being taken off.
/obj/item/clothing/suit/space/space_ninja/proc/lock_suit(mob/living/carbon/human/U, X = FALSE)
	if(X)//If you want to check for icons.
		if(U.mind.protector_role)
			icon_state = U.gender == FEMALE ? "s-ninjakf" : "s-ninjak"
			U.gloves.icon_state = "s-ninjak"
			U.gloves.item_state = "s-ninjak"
		else
			icon_state = U.gender == FEMALE ? "s-ninjanf" : "s-ninjan"
			U.gloves.icon_state = "s-ninjan"
			U.gloves.item_state = "s-ninjan"
	else
		if(U.mind.special_role!="Ninja")
			to_chat(U, "<span class='warning'><B>fÄTaL ÈÈRRoR</B>: 382200-*#00CÖDE <B>RED</B>\nUNAU?HORIZED USÈ DETÈC???eD\nCoMMÈNCING SUB-R0U?IN3 13...\nTÈRMInATING U-U-USÈR...</span>")
			U.gib()
			return 0
		if(!istype(U.head, /obj/item/clothing/head/helmet/space/space_ninja))
			to_chat(U, "<span class='warning'><B>ERROR</B>: 100113</span> UNABLE TO LOCATE HEAD GEAR\nABORTING...")
			return 0
		if(!istype(U.shoes, /obj/item/clothing/shoes/space_ninja))
			to_chat(U, "<span class='warning'><B>ERROR</B>: 122011</span> UNABLE TO LOCATE FOOT GEAR\nABORTING...")
			return 0
		if(!istype(U.gloves, /obj/item/clothing/gloves/space_ninja))
			to_chat(U, "<span class='warning'><B>ERROR</B>: 110223</span> UNABLE TO LOCATE HAND GEAR\nABORTING...")
			return 0

		affecting = U
		canremove = 0
		slowdown = 0
		n_hood = U.head
		n_hood.canremove=0
		n_shoes = U.shoes
		n_shoes.canremove=0
		n_shoes.slowdown--
		n_gloves = U.gloves
		n_gloves.canremove=0

	return TRUE

//This proc allows the suit to be taken off.
/obj/item/clothing/suit/space/space_ninja/proc/unlock_suit()
	affecting = null
	canremove = 1
	slowdown = 1
	icon_state = "s-ninja"
	if(n_hood)//Should be attached, might not be attached.
		n_hood.canremove=1
	if(n_shoes)
		n_shoes.canremove=1
		n_shoes.slowdown++
	if(n_gloves)
		n_gloves.icon_state = "s-ninja"
		n_gloves.item_state = "s-ninja"
		n_gloves.canremove=1
		n_gloves.candrain=0
		n_gloves.draining=0

//Allows the mob to grab a stealth icon.
/mob/proc/NinjaStealthActive(atom/A)//A is the atom which we are using as the overlay.
	invisibility = INVISIBILITY_LEVEL_TWO//Set ninja invis to 2.
	var/icon/opacity_icon = new(A.icon, A.icon_state)
	var/icon/alpha_mask = getIconMask(src)
	var/icon/alpha_mask_2 = new('icons/effects/effects.dmi', "at_shield1")
	alpha_mask.AddAlphaMask(alpha_mask_2)
	opacity_icon.AddAlphaMask(alpha_mask)
	for(var/i=0,i<5,i++)//And now we add it as overlays. It's faster than creating an icon and then merging it.
		var/image/I = image("icon" = opacity_icon, "icon_state" = A.icon_state, "layer" = layer+0.8)//So it's above other stuff but below weapons and the like.
		switch(i)//Now to determine offset so the result is somewhat blurred.
			if(1)
				I.pixel_x -= 1
			if(2)
				I.pixel_x += 1
			if(3)
				I.pixel_y -= 1
			if(4)
				I.pixel_y += 1

		add_overlay(I)//And finally add the overlay.
	add_overlay(image("icon"='icons/effects/effects.dmi',"icon_state" ="electricity","layer" = layer+0.9))

//When ninja steal malfunctions.
/mob/proc/NinjaStealthMalf()
	invisibility = 0//Set ninja invis to 0.
	add_overlay(image("icon"='icons/effects/effects.dmi',"icon_state" ="electricity","layer" = layer+0.9))
	playsound(src, 'sound/effects/stealthoff.ogg', VOL_EFFECTS_MASTER)

// GENERIC VERB MODIFIERS

/obj/item/clothing/suit/space/space_ninja/proc/grant_equip_verbs()
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/init
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/stealth
	n_gloves.verbs += /obj/item/clothing/gloves/space_ninja/proc/toggled

	s_initialized = 1

/obj/item/clothing/suit/space/space_ninja/proc/remove_equip_verbs()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/init
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/stealth
	if(n_gloves)
		n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled

	s_initialized = 0

/obj/item/clothing/suit/space/space_ninja/proc/grant_ninja_verbs()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjasmoke
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjaboost
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjablade
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjanet

	s_initialized=1
	slowdown=0

/obj/item/clothing/suit/space/space_ninja/proc/remove_ninja_verbs()
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjaboost
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjablade
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjanet

//=======//KAMIKAZE VERBS//=======//

/obj/item/clothing/suit/space/space_ninja/proc/grant_kamikaze(mob/living/carbon/U)
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjanet
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjaslayer
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjawalk
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjamirage

	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/stealth

	kamikaze = 1

	icon_state = U.gender==FEMALE ? "s-ninjakf" : "s-ninjak"
	if(n_gloves)
		n_gloves.icon_state = "s-ninjak"
		n_gloves.item_state = "s-ninjak"
		n_gloves.candrain = 0
		n_gloves.draining = 0
		n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled

	cancel_stealth()

	U << browse(null, "window=spideros")
	to_chat(U, "<span class='warning'>Do or Die, <b>LET'S ROCK!!</b></span>")

/obj/item/clothing/suit/space/space_ninja/proc/remove_kamikaze(mob/living/carbon/U)
	if(kamikaze)
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
		verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjaslayer
		verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjawalk
		verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjamirage

		verbs += /obj/item/clothing/suit/space/space_ninja/proc/stealth
		if(n_gloves)
			n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled

		U.incorporeal_move = 0
		kamikaze = 0
		k_unlock = 0
		to_chat(U, "<span class='notice'>Disengaging mode...\n</span><b>CODE NAME</b>: <span class='warning'><b>KAMIKAZE</b></span>")

// AI VERBS

/obj/item/clothing/suit/space/space_ninja/proc/grant_AI_verbs()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_hack_ninja
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_return_control

	s_busy = 0
	s_control = 0

/obj/item/clothing/suit/space/space_ninja/proc/remove_AI_verbs()
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_hack_ninja
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_return_control

	s_control = 1
