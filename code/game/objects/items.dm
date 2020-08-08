/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	var/image/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/abstract = 0
	var/item_state = null
	var/lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	var/righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	var/r_speed = 1.0
	var/health = null
	var/burn_point = null
	var/burning = null
	var/list/hitsound = list()
	var/usesound = null
	var/wet = 0
	var/w_class = ITEM_SIZE_NORMAL
	var/can_embed = 1
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	pass_flags = PASSTABLE
//	causeerrorheresoifixthis
	var/obj/item/master = null

	var/flags_pressure = 0
	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	var/datum/action/item_action/action = null
	var/action_button_name //It is also the text which gets displayed on the action button. If not set it defaults to 'Use [name]'. If it's not set, there'll be no button.
	var/action_button_is_hands_free = 0 //If 1, bypass the restrained, lying, and stunned checks action buttons normally test for

	var/slot_equipped = 0 // Where this item currently equipped in player inventory (slot_id) (should not be manually edited ever).

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inv //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	var/item_color = null
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/canremove = 1 //Mostly for Ninja code at this point but basically will not allow the item to be removed if set to 0. /N
	var/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/list/materials = list()
	var/list/allowed = null //suit storage stuff.
	var/list/can_be_placed_into = list(
		/obj/structure/table,
		/obj/structure/rack,
		/obj/structure/closet,
		/obj/item/weapon/storage,
		/obj/structure/safe,
		/obj/machinery/disposal,
		/obj/machinery/r_n_d/destructive_analyzer,
//		/obj/machinery/r_n_d/experimentor,
		/obj/machinery/autolathe
	)
	var/can_be_holstered = FALSE
	var/uncleanable = 0
	var/toolspeed = 1
	var/obj/item/device/uplink/hidden/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.

	var/icon_override = null  //Used to override hardcoded clothing dmis in human clothing proc.

	/* Species-specific sprite sheets for inventory sprites
	Works similarly to worn sprite_sheets, except the alternate sprites are used when the clothing/refit_for_species() proc is called.
	*/
	var/list/sprite_sheets_obj = null

    /// A list of all tool qualities that src exhibits. To-Do: Convert all our tools to such a system.
	var/list/tools = list()
	// This thing can be used to stab eyes out.
	var/stab_eyes = FALSE

	// Determines whether any religious activity has been carried out on the item.
	var/blessed = FALSE

	// Whether this item is currently being swiped.
	var/swiping = FALSE

/obj/item/proc/check_allowed_items(atom/target, not_inside, target_self)
	if(((src in target) && !target_self) || ((!istype(target.loc, /turf)) && (!istype(target, /turf)) && (not_inside)) || is_type_in_list(target, can_be_placed_into))
		return 0
	else
		return 1

/obj/item/device
	icon = 'icons/obj/device.dmi'

/obj/item/proc/health_analyze(mob/living/M, mob/living/user, mode, output_to_chat)
	var/message = ""
	if(!output_to_chat)
		message += "<HTML><head><title>[M.name]'s scan results</title></head><BODY>"

	if(((CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))
		user.visible_message("<span class='warning'>[user] has analyzed the floor's vitals!</span>", "<span class = 'warning'>You try to analyze the floor's vitals!</span>")
		message += "<span class='notice'>Analyzing Results for The floor:\n&emsp; Overall Status: Healthy</span><br>"
		message += "<span class='notice'>&emsp; Damage Specifics: [0]-[0]-[0]-[0]</span><br>"
		message += "<span class='notice'>Key: Suffocation/Toxin/Burns/Brute</span><br>"
		message += "<span class='notice'>Body Temperature: ???</span>"
		if(!output_to_chat)
			message += "</BODY></HTML>"
		return message
	if(!(istype(user, /mob/living/carbon/human) || SSticker) && SSticker.mode.name != "monkey")
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return ""
	user.visible_message("<span class='notice'>[user] has analyzed [M]'s vitals.</span>","<span class='notice'>You have analyzed [M]'s vitals.</span>")

	var/fake_oxy = max(rand(1,40), M.getOxyLoss(), (300 - (M.getToxLoss() + M.getFireLoss() + M.getBruteLoss())))
	var/OX = M.getOxyLoss() > 50 	? 	"<b>[M.getOxyLoss()]</b>" 		: M.getOxyLoss()
	var/TX = M.getToxLoss() > 50 	? 	"<b>[M.getToxLoss()]</b>" 		: M.getToxLoss()
	var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 			? 	"<b>[fake_oxy]</b>" 			: fake_oxy
		message += "<span class='notice'>Analyzing Results for [M]:\n&emsp; Overall Status: dead</span><br>"
	else
		message += "<span class='notice'>Analyzing Results for [M]:\n&emsp; Overall Status: [M.stat > 1 ? "dead" : "[M.health - M.halloss]% healthy"]</span><br>"
	message += "&emsp; Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font><br>"
	message += "&emsp; Damage Specifics: <font color='blue'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font><br>"
	message += "<span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span><br>"
	if(M.tod && (M.stat == DEAD || (M.status_flags & FAKEDEATH)))
		message += "<span class='notice'>Time of Death: [M.tod]</span><br>"
	if(istype(M, /mob/living/carbon/human) && mode)
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_bodyparts(1, 1)
		message += "<span class='notice'>Localized Damage, Brute/Burn:</span><br>"
		if(length(damaged))
			for(var/obj/item/organ/external/BP in damaged)
				message += "<span class='notice'>&emsp; [capitalize(BP.name)]: [(BP.brute_dam > 0) ? "<span class='warning'>[BP.brute_dam]</span>" : 0][(BP.status & ORGAN_BLEEDING) ? "<span class='warning bold'>\[Bleeding\]</span>" : "&emsp;"] - [(BP.burn_dam > 0) ? "<font color='#FFA500'>[BP.burn_dam]</font>" : 0]</span><br>"
		else
			message += "<span class='notice'>&emsp; Limbs are OK.</span><br>"

	OX = M.getOxyLoss() > 50 ? "<font color='blue'><b>Severe oxygen deprivation detected</b></font>" : "Subject bloodstream oxygen level normal"
	TX = M.getToxLoss() > 50 ? "<font color='green'><b>Dangerous amount of toxins detected</b></font>" : "Subject bloodstream toxin level minimal"
	BU = M.getFireLoss() > 50 ? "<font color='#FFA500'><b>Severe burn damage detected</b></font>" : "Subject burn injury status O.K"
	BR = M.getBruteLoss() > 50 ? "<font color='red'><b>Severe anatomical damage detected</b></font>" : "Subject brute-force injury status O.K"
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 ? 		"<span class='warning'>Severe oxygen deprivation detected</span>" : "Subject bloodstream oxygen level normal"
	message += "[OX]<br>[TX]<br>[BU]<br>[BR]<br>"
	if(istype(M, /mob/living/carbon))
		var/mob/living/carbon/C = M
		if(C.reagents.total_volume || C.is_infected_with_zombie_virus())
			message += "<span class='warning'>Warning: Unknown substance detected in subject's blood.</span><br>"
		if(C.virus2.len)
			for (var/ID in C.virus2)
				if (ID in virusDB)
					var/datum/data/record/V = virusDB[ID]
					message += "<span class='warning'>Warning: Pathogen [V.fields["name"]] detected in subject's blood. Known antigen : [V.fields["antigen"]]</span><br>"
//			user.oldshow_message(text("<span class='warning'>Warning: Unknown pathogen detected in subject's blood.</span>"))
		if(C.roundstart_quirks.len)
			message += "\t<span class='info'>Subject has the following physiological traits: [C.get_trait_string()].</span><br>"
	if(M.getCloneLoss())
		to_chat(user, "<span class='warning'>Subject appears to have been imperfectly cloned.</span>")
	for(var/datum/disease/D in M.viruses)
		if(!D.hidden[SCANNER])
			message += "<span class = 'warning bold'>Warning: [D.form] Detected</span>\n<span class = 'warning'>Name: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]</span><br>"
	if(M.reagents && M.reagents.get_reagent_amount("inaprovaline"))
		message += "<span class='notice'>Bloodstream Analysis located [M.reagents:get_reagent_amount("inaprovaline")] units of rejuvenation chemicals.</span><br>"
	if(M.has_brain_worms())
		message += "<span class='warning'>Subject suffering from aberrant brain activity. Recommend further scanning.</span><br>"
	else if(M.getBrainLoss() >= 100 || (istype(M, /mob/living/carbon/human) && !M:has_brain() && M:should_have_organ(O_BRAIN)))
		message += "<span class='warning'>Subject is brain dead.</span>"
	else if(M.getBrainLoss() >= 60)
		message += "<span class='warning'>Severe brain damage detected. Subject likely to have mental retardation.</span><br>"
	else if(M.getBrainLoss() >= 10)
		message += "<span class='warning'>Significant brain damage detected. Subject may have had a concussion.</span><br>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		var/found_bleed
		var/found_broken
		for(var/obj/item/organ/external/BP in H.bodyparts)
			if(BP.status & ORGAN_BROKEN)
				if(((BP.body_zone == BP_L_ARM) || (BP.body_zone == BP_R_ARM) || (BP.body_zone == BP_L_LEG) || (BP.body_zone == BP_R_LEG)) && !(BP.status & ORGAN_SPLINTED))
					message += "<span class='warning'>Unsecured fracture in subject [BP.name]. Splinting recommended for transport.</span><br>"
				if(!found_broken)
					found_broken = TRUE

			if(!found_bleed && (BP.status & ORGAN_ARTERY_CUT))
				found_bleed = TRUE

			if(BP.has_infected_wound())
				message += "<span class='warning'>Infected wound detected in subject [BP.name]. Disinfection recommended.</span><br>"

		if(found_bleed)
			message += "<span class='warning'>Arterial bleeding detected. Advanced scanner required for location.</span><br>"
		if(found_broken)
			message += "<span class='warning'>Bone fractures detected. Advanced scanner required for location.</span><br>"

		if(H.vessel)
			var/blood_volume = round(H.vessel.get_reagent_amount("blood"))
			var/blood_percent =  blood_volume / 560
			var/blood_type = H.dna.b_type
			blood_percent *= 100
			if(blood_volume <= 500 && blood_volume > 336)
				message += "<span class='warning bold'>Warning: Blood Level LOW: [blood_percent]% [blood_volume]cl.</span><span class='notice'>Type: [blood_type]</span><br>"
			else if(blood_volume <= 336)
				message += "<span class='warning bold'>Warning: Blood Level CRITICAL: [blood_percent]% [blood_volume]cl.</span><span class='notice bold'>Type: [blood_type]</span><br>"
			else
				message += "<span class='notice'>Blood Level Normal: [blood_percent]% [blood_volume]cl. Type: [blood_type]</span><br>"
		var/obj/item/organ/internal/heart/Heart = H.organs_by_name[O_HEART]
		switch(Heart.heart_status)
			if(HEART_FAILURE)
				message += "<span class='notice'><font color='red'>Warning! Subject's heart stopped!</font></span><br>"
			if(HEART_FIBR)
				message += "<span class='notice'>Subject's Heart status: <font color='blue'>Attention! Subject's heart fibrillating.</font></span><br>"
		message += "<span class='notice'>Subject's pulse: <font color='[H.pulse == PULSE_THREADY || H.pulse == PULSE_NONE ? "red" : "blue"]'>[H.get_pulse(GETPULSE_TOOL)] bpm.</font></span><br>"

	if(!output_to_chat)
		message += "</BODY></HTML>"
	return message

/obj/item/Destroy()
	QDEL_NULL(action)
	flags &= ~DROPDEL // prevent recursive dels
	if(ismob(loc))
		var/mob/m = loc
		m.drop_from_inventory(src)
	return ..()

/obj/item/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return
		else
	return

/obj/item/blob_act()
	return

//user: The mob that is suiciding
//damagetype: The type of damage the item will inflict on the user
//BRUTELOSS = 1
//FIRELOSS = 2
//TOXLOSS = 4
//OXYLOSS = 8
//Output a creative message and then return the damagetype done
/obj/item/proc/suicide_act(mob/user)
	return

/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)

	if(!istype(src.loc, /turf) || usr.stat || usr.restrained() )
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T

/obj/item/examine(mob/user)
	. = ..()
	var/size
	switch(src.w_class)
		if(1.0)
			size = "tiny"
		if(2.0)
			size = "small"
		if(3.0)
			size = "normal-sized"
		if(4.0)
			size = "bulky"
		if(5.0)
			size = "huge"
		else

	var/open_span  = "[src.wet ? "<span class='wet'>" : ""]"
	var/close_span = "[src.wet ? "</span>" : ""]"
	var/wet_status = "[src.wet ? " wet" : ""]"

	to_chat(user, "[open_span]It's a[wet_status] [size] item.[close_span]")

/obj/item/attack_hand(mob/user)
	if (!user || anchored)
		return

	if(HULK in user.mutations)//#Z2 Hulk nerfz!
		if(istype(src, /obj/item/weapon/melee))
			if(src.w_class < ITEM_SIZE_LARGE)
				to_chat(user, "<span class='warning'>\The [src] is far too small for you to pick up.</span>")
				return
		else if(istype(src, /obj/item/weapon/gun))
			if(prob(20))
				user.say(pick(";RAAAAAAAARGH! WEAPON!", ";HNNNNNNNNNGGGGGGH! I HATE WEAPONS!!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGUUUUUNNNNHH!", ";AAAAAAARRRGH!" ))
			user.visible_message("<span class='notice'>[user] crushes \a [src] with hands.</span>", "<span class='notice'>You crush the [src].</span>")
			qdel(src)
			//user << "<span class='warning'>\The [src] is far too small for you to pick up.</span>"
			return
		else if(istype(src, /obj/item/clothing))
			if(prob(20))
				to_chat(user, "<span class='warning'>[pick("You are not interested in [src].", "This is nothing.", "Humans stuff...", "A cat? A scary cat...",
				"A Captain? Let's smash his skull! I don't like Captains!",
				"Awww! Such lovely doggy! BUT I HATE DOGGIES!!", "A woman... A lying woman! I love womans! Fuck womans...")]</span>")
			return
		else if(istype(src, /obj/item/weapon/book))
			to_chat(user, "<span class='warning'>A book! I LOVE BOOKS!!</span>")
		else if(istype(src, /obj/item/weapon/reagent_containers/food))
			if(prob(20))
				to_chat(user, "<span class='warning'>I LOVE FOOD!!</span>")
		else if(src.w_class < ITEM_SIZE_LARGE)
			to_chat(user, "<span class='warning'>\The [src] is far too small for you to pick up.</span>")
			return

	if(istype(src.loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = src.loc
		S.remove_from_storage(src)

	src.throwing = 0
	if(src.loc == user)
		//canremove==0 means that object may not be removed. You can still wear it. This only applies to clothing. /N
		if(!src.canremove)
			return
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			if(slot_equipped && (slot_equipped in C.check_obscured_slots()))
				to_chat(C, "<span class='warning'>You can't reach that! Something is covering it.</span>")
				return
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
					var/obj/item/clothing/suit/V = H.wear_suit
					V.attack_reaction(H, REACTION_ITEM_TAKEOFF)
				if(istype(src, /obj/item/clothing/suit/space)) // If the item to be unequipped is a rigid suit
					if(!user.delay_clothing_u_equip(src))
						return 0
				else
					user.remove_from_mob(src)
			else
				user.remove_from_mob(src)
		else
			user.remove_from_mob(src)
	else
		if(isliving(src.loc))
			return
		user.SetNextMove(CLICK_CD_RAPID)

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
				var/obj/item/clothing/suit/V = H.wear_suit
				V.attack_reaction(H, REACTION_ITEM_TAKE)

	if(QDELETED(src) || freeze_movement) // remove_from_mob() may remove DROPDEL items, so...
		return

	if(!user.can_pickup(src))
		to_chat(user, "<span class='notice'>Your claws aren't capable of such fine manipulation!</span>")
		return

	src.pickup(user)
	add_fingerprint(user)
	user.put_in_active_hand(src)
	return


/obj/item/attack_paw(mob/user)
	if (!user || anchored)
		return

	if (istype(src.loc, /obj/item/weapon/storage))
		for(var/mob/M in range(1, src.loc))
			if (M.s_active == src.loc)
				if (M.client)
					M.client.screen -= src
	src.throwing = 0
	if (src.loc == user)
		//canremove==0 means that object may not be removed. You can still wear it. This only applies to clothing. /N
		if(istype(src, /obj/item/clothing) && !src:canremove)
			return
		else
			user.remove_from_mob(src)
	else
		if(istype(src.loc, /mob/living))
			return

		user.next_move = max(user.next_move+2,world.time + 2)

	if(QDELETED(src) || freeze_movement) // no item - no pickup, you dummy!
		return

	if (!user.can_pickup(src))
		to_chat(user, "<span class='notice'>Your claws aren't capable of such fine manipulation!</span>")
		return

	src.pickup(user)
	user.put_in_active_hand(src)
	return

/obj/item/attack_ai(mob/user)
	if (istype(src.loc, /obj/item/weapon/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!isrobot(user))
			return
		var/mob/living/silicon/robot/R = user
		R.activate_module(src)
		R.hud_used.update_robot_modules_display()

// Due to storage type consolidation this should get used more now.
// I have cleaned it up a little, but it could probably use more.  -Sayu
/obj/item/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = I
		if(S.use_to_pickup)
			if(S.collection_mode) //Mode is set to collect all items on a tile and we clicked on a valid one.
				if(isturf(loc))
					S.gather_all(loc, user)
			else if(S.can_be_inserted(src))
				S.handle_item_insertion(src)
			return FALSE
	return ..()

/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback)
	callback = CALLBACK(src, .proc/after_throw, callback) // Replace their callback with our own.
	. = ..(target, range, speed, thrower, spin, diagonals_first, callback)

/obj/item/proc/after_throw(datum/callback/callback)
	if (callback) //call the original callback
		. = callback.Invoke()

/obj/item/proc/talk_into(mob/M, text)
	return

/obj/item/proc/moved(mob/user, old_loc)
	return

// apparently called whenever an item is removed from a slot, container, or anything else.
/obj/item/proc/dropped(mob/user)
	if(DROPDEL & flags)
		qdel(src)

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	return

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/weapon/storage/S)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/weapon/storage/S)
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(mob/user, slot)
	return

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
/obj/item/proc/mob_can_equip(mob/M, slot, disable_warning = 0)
	if(!slot)
		return FALSE
	if(QDELETED(M))
		return FALSE

	if(ishuman(M))
		//START HUMAN
		var/mob/living/carbon/human/H = M
		if(!H.has_bodypart_for_slot(slot))
			return FALSE
		if(!H.specie_has_slot(slot))
			if(!disable_warning)
				to_chat(H, "<span class='warning'>Your species can not wear clothing of this type.</span>")
			return FALSE
		//fat mutation
		if(istype(src, /obj/item/clothing/under) || istype(src, /obj/item/clothing/suit))
			if(HAS_TRAIT(H, TRAIT_FAT))
				//testing("[M] TOO FAT TO WEAR [src]!")
				if(!(flags & ONESIZEFITSALL))
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You're too fat to wear the [name].</span>")
					return 0

		switch(slot)
			if(SLOT_L_HAND)
				if(H.l_hand)
					return 0
				return 1
			if(SLOT_R_HAND)
				if(H.r_hand)
					return 0
				return 1
			if(SLOT_WEAR_MASK)
				if(H.wear_mask)
					return 0
				if( !(slot_flags & SLOT_FLAGS_MASK) )
					return 0
				return 1
			if(SLOT_BACK)
				if(H.back)
					return 0
				if( !(slot_flags & SLOT_FLAGS_BACK) )
					return 0
				return 1
			if(SLOT_WEAR_SUIT)
				if(H.wear_suit)
					return 0
				if( !(slot_flags & SLOT_FLAGS_OCLOTHING) )
					return 0
				return 1
			if(SLOT_GLOVES)
				if(H.gloves)
					return 0
				if( !(slot_flags & SLOT_FLAGS_GLOVES) )
					return 0
				return 1
			if(SLOT_SHOES)
				if(H.shoes)
					return 0
				if( !(slot_flags & SLOT_FLAGS_FEET) )
					return 0
				return 1
			if(SLOT_BELT)
				if(H.belt)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if( !(slot_flags & SLOT_FLAGS_BELT) )
					return
				return 1
			if(SLOT_GLASSES)
				if(H.glasses)
					return 0
				if( !(slot_flags & SLOT_FLAGS_EYES) )
					return 0
				return 1
			if(SLOT_HEAD)
				if(H.head)
					return 0
				if( !(slot_flags & SLOT_FLAGS_HEAD) )
					return 0
				return 1
			if(SLOT_L_EAR)
				if(H.l_ear)
					return 0
				if( (slot_flags & SLOT_FLAGS_TWOEARS) && H.r_ear )
					return 0
				if( w_class < ITEM_SIZE_SMALL	)
					return 1
				if( !(slot_flags & SLOT_FLAGS_EARS) )
					return 0
				return 1
			if(SLOT_R_EAR)
				if(H.r_ear)
					return 0
				if( (slot_flags & SLOT_FLAGS_TWOEARS) && H.l_ear )
					return 0
				if( w_class < ITEM_SIZE_SMALL )
					return 1
				if( !(slot_flags & SLOT_FLAGS_EARS) )
					return 0
				return 1
			if(SLOT_W_UNIFORM)
				if(H.w_uniform)
					return 0
				if( !(slot_flags & SLOT_FLAGS_ICLOTHING) )
					return 0
				return 1
			if(SLOT_WEAR_ID)
				if(H.wear_id)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if( !(slot_flags & SLOT_FLAGS_ID) )
					return 0
				return 1
			if(SLOT_L_STORE)
				if(H.l_store)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if(slot_flags & SLOT_FLAGS_DENYPOCKET)
					return 0
				if( w_class <= ITEM_SIZE_SMALL || (slot_flags & SLOT_FLAGS_POCKET) )
					return 1
			if(SLOT_R_STORE)
				if(H.r_store)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if(slot_flags & SLOT_FLAGS_DENYPOCKET)
					return 0
				if( w_class <= ITEM_SIZE_SMALL || (slot_flags & SLOT_FLAGS_POCKET) )
					return 1
				return 0
			if(SLOT_S_STORE)
				if(H.s_store)
					return 0
				if(!H.wear_suit)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a suit before you can attach this [name].</span>")
					return 0
				if(!H.wear_suit.allowed)
					if(!disable_warning)
						to_chat(usr, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
					return 0
				if( istype(src, /obj/item/device/pda) || istype(src, /obj/item/weapon/pen) || is_type_in_list(src, H.wear_suit.allowed) )
					return 1
				return 0
			if(SLOT_HANDCUFFED)
				if(H.handcuffed)
					return 0
				if(!istype(src, /obj/item/weapon/handcuffs))
					return 0
				return 1
			if(SLOT_LEGCUFFED)
				if(H.legcuffed)
					return 0
				if(!istype(src, /obj/item/weapon/legcuffs))
					return 0
				return 1
			if(SLOT_IN_BACKPACK)
				if (H.back && istype(H.back, /obj/item/weapon/storage/backpack))
					var/obj/item/weapon/storage/backpack/B = H.back
					if(B.can_be_inserted(src, M, 1))
						return 1
				return 0
			if(SLOT_TIE)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return FALSE
				var/obj/item/clothing/under/uniform = H.w_uniform
				if(uniform.accessories.len && !uniform.can_attach_accessory(src))
					if (!disable_warning)
						to_chat(H, "<span class='warning'>You already have an accessory of this type attached to your [uniform].</span>")
					return FALSE
				if( !(slot_flags & SLOT_FLAGS_TIE) )
					return FALSE
				return TRUE
		return 0 //Unsupported slot
		//END HUMAN

	else if(ismonkey(M))
		//START MONKEY
		var/mob/living/carbon/monkey/MO = M
		switch(slot)
			if(SLOT_L_HAND)
				if(MO.l_hand)
					return 0
				return 1
			if(SLOT_R_HAND)
				if(MO.r_hand)
					return 0
				return 1
			if(SLOT_WEAR_MASK)
				if(MO.wear_mask)
					return 0
				if( !(slot_flags & SLOT_FLAGS_MASK) )
					return 0
				return 1
			if(SLOT_BACK)
				if(MO.back)
					return 0
				if( !(slot_flags & SLOT_FLAGS_BACK) )
					return 0
				return 1
			if(SLOT_HANDCUFFED)
				if(MO.handcuffed)
					return 0
				if(!istype(src, /obj/item/weapon/handcuffs))
					return 0
				return 1
		return 0 //Unsupported slot

		//END MONKEY
	else if(isIAN(M))
		var/mob/living/carbon/ian/C = M
		switch(slot)
			if(SLOT_HEAD)
				if(C.head)
					return FALSE
				if(istype(src, /obj/item/clothing/mask/facehugger))
					return TRUE
				if( !(slot_flags & SLOT_FLAGS_HEAD) )
					return FALSE
				return TRUE
			if(SLOT_MOUTH)
				if(C.mouth)
					return FALSE
				return TRUE
			if(SLOT_NECK)
				if(C.neck)
					return FALSE
				if(istype(src, /obj/item/weapon/handcuffs))
					return TRUE
				if( !(slot_flags & SLOT_FLAGS_ID) )
					return FALSE
				return TRUE
			if(SLOT_BACK)
				if(C.back)
					return FALSE
				if(istype(src, /obj/item/clothing/suit/armor/vest))
					return TRUE
				if( !(slot_flags & SLOT_FLAGS_BACK) )
					return FALSE
				return TRUE
		return FALSE

/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(!(usr)) //BS12 EDIT
		return
	if(usr.incapacitated() || !Adjacent(usr))
		return
	if((!istype(usr, /mob/living/carbon)) || (istype(usr, /mob/living/carbon/brain)))//Is humanoid, and is not a brain
		to_chat(usr, "<span class='warning'>You can't pick things up!</span>")
		return
	if(src.anchored) //Object isn't anchored
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
		return
	if(!usr.hand && usr.r_hand) //Right hand is not full
		to_chat(usr, "<span class='warning'>Your right hand is full.</span>")
		return
	if(usr.hand && usr.l_hand) //Left hand is not full
		to_chat(usr, "<span class='warning'>Your left hand is full.</span>")
		return
	if(!istype(src.loc, /turf)) //Object is on a turf
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
		return
	//All checks are done, time to pick it up!
	usr.UnarmedAttack(src)
	return

/obj/item/proc/use_tool(atom/target, mob/living/user, delay, amount = 0, volume = 0, datum/callback/extra_checks)
	// No delay means there is no start message, and no reason to call tool_start_check before use_tool.
	// Run the start check here so we wouldn't have to call it manually.
	if(user.is_busy())
		return

	if(!delay && !tool_start_check(user, amount))
		return

	delay *= toolspeed

	// Play tool sound at the beginning of tool usage.
	play_tool_sound(target, volume)

	if(delay)
		// Create a callback with checks that would be called every tick by do_after.
		var/datum/callback/tool_check = CALLBACK(src, .proc/tool_check_callback, user, amount, extra_checks)

		if(ismob(target))
			if(!do_mob(user, target, delay, extra_checks = tool_check))
				return

		else
			if(!do_after(user, delay, target=target, extra_checks = tool_check))
				return
	else
		// Invoke the extra checks once, just in case.
		if(extra_checks && !extra_checks.Invoke())
			return

	// Use tool's fuel, stack sheets or charges if amount is set.
	if(amount && !use(amount))
		return

	// Play tool sound at the end of tool usage,
	// but only if the delay between the beginning and the end is not too small
	if(delay >= MIN_TOOL_SOUND_DELAY)
		play_tool_sound(target, volume)

	return TRUE

// Called before use_tool if there is a delay, or by use_tool if there isn't.
// Only ever used by welding tools and stacks, so it's not added on any other use_tool checks.
/obj/item/proc/tool_start_check(mob/living/user, amount=0)
	return tool_use_check(user, amount)

// A check called by tool_start_check once, and by use_tool on every tick of delay.
/obj/item/proc/tool_use_check(mob/living/user, amount)
	return TRUE

// Plays item's usesound, if any.
/obj/item/proc/play_tool_sound(atom/target, volume=null) // null, so default value of this proc won't override default value of the playsound.
	if(target && usesound && volume)
		var/played_sound = usesound

		if(islist(usesound))
			played_sound = pick(usesound)

		playsound(target, played_sound, VOL_EFFECTS_MASTER, volume)

// Generic use proc. Depending on the item, it uses up fuel, charges, sheets, etc.
// Returns TRUE on success, FALSE on failure.
/obj/item/proc/use(used, mob/M = null)
	return !used

// Used in a callback that is passed by use_tool into do_after call. Do not override, do not call manually.
/obj/item/proc/tool_check_callback(mob/living/user, amount, datum/callback/extra_checks)
	return tool_use_check(user, amount) && (!extra_checks || extra_checks.Invoke())

//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'icon_action_button' to the icon_state of the image of the button in screen1_action.dmi
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click()
	attack_self(usr)

/obj/item/proc/IsReflect(def_zone, hol_dir, hit_dir) //This proc determines if and at what% an object will reflect energy projectiles if it's in l_hand,r_hand or wear_suit
	return FALSE

/obj/item/proc/Get_shield_chance()
	return 0

/obj/item/proc/get_loc_turf()
	var/atom/L = loc
	while(L && !istype(L, /turf))
		L = L.loc
	return loc

/obj/item/proc/eyestab(mob/living/carbon/M, mob/living/carbon/user)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			// you can't stab someone in the eyes wearing a mask!
			to_chat(user, "<span class='warning'>You're going to need to remove the eye covering first.</span>")
			return

	var/mob/living/carbon/monkey/Mo = M
	if(istype(Mo) && ( \
			(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
		))
		// you can't stab someone in the eyes wearing a mask!
		to_chat(user, "<span class='warning'>You're going to need to remove the eye covering first.</span>")
		return

	if(istype(M, /mob/living/carbon/xenomorph) || istype(M, /mob/living/carbon/slime))//Aliens don't have eyes./N     slimes also don't have eyes!
		to_chat(user, "<span class='warning'>You cannot locate any eyes on this creature!</span>")
		return

	user.do_attack_animation(M)
	playsound(M, 'sound/items/tools/screwdriver-stab.ogg', VOL_EFFECTS_MASTER)

	M.log_combat(user, "eyestabbed with [name]")

	src.add_fingerprint(user)
	//if((CLUMSY in user.mutations) && prob(50))
	//	M = user
		/*
		to_chat(M, "<span class='warning'>You stab yourself in the eye.</span>")
		M.sdisabilities |= BLIND
		M.weakened += 4
		M.adjustBruteLoss(10)
		*/
	if(M != user)
		visible_message("<span class='warning'>[M] has been stabbed in the eye with [src] by [user].</span>", ignored_mobs = list(user, M))
		to_chat(M, "<span class='warning'>[user] stabs you in the eye with [src]!</span>")
		to_chat(user, "<span class='warning'>You stab [M] in the eye with [src]!</span>")
	else
		user.visible_message( \
			"<span class='warning'>[user] has stabbed themself with [src]!</span>", \
			"<span class='warning'>You stab yourself in the eyes with [src]!</span>" \
		)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/eyes/IO = H.organs_by_name[O_EYES]
		IO.damage += rand(force * 0.5, force)
		if(IO.damage >= IO.min_bruised_damage)
			if(H.stat != DEAD)
				if(IO.robotic <= 1) //robot eyes bleeding might be a bit silly
					to_chat(H, "<span class='warning'>Your eyes start to bleed profusely!</span>")
			if(prob(10 * force))
				if(H.stat != DEAD)
					to_chat(H, "<span class='warning'>You drop what you're holding and clutch at your eyes!</span>")
					H.drop_item()
				H.eye_blurry += 10
				H.Paralyse(1)
				H.Weaken(4)
			if (IO.damage >= IO.min_broken_damage)
				if(H.stat != DEAD)
					to_chat(H, "<span class='warning'>You go blind!</span>")
		var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
		BP.take_damage(force)
	else
		M.take_bodypart_damage(force)

	M.eye_blurry += rand(force * 0.5, force)

/obj/item/clean_blood()
	. = ..() // FIX: If item is `uncleanable` we shouldn't nullify `dirt_overlay`
	if(uncleanable)
		return
	if(blood_overlay)
		cut_overlay(blood_overlay)
		blood_overlay.color = null
		blood_overlay = null
	if(istype(src, /obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = src
		G.transfer_blood = 0

/obj/item/add_dirt_cover()
	if(!blood_overlay)
		generate_blood_overlay()
	..()
	if(dirt_overlay)
		if(blood_overlay.color != dirt_overlay.color)
			cut_overlay(blood_overlay)
			blood_overlay.color = dirt_overlay.color
			add_overlay(blood_overlay)

/obj/item/add_blood(mob/living/carbon/human/M)
	if (!..())
		return 0

	if(blood_DNA[M.dna.unique_enzymes])
		return 0 //already bloodied with this blood. Cannot add more.
	blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	return 1 //we applied blood to the item

var/global/list/items_blood_overlay_by_type = list()
/obj/item/proc/generate_blood_overlay()
	if(blood_overlay)
		return

	var/image/IMG = items_blood_overlay_by_type[type]
	if(IMG)
		blood_overlay = IMG
	else
		var/icon/ICO = new /icon(icon, icon_state)
		ICO.Blend(new /icon('icons/effects/blood.dmi', rgb(255, 255, 255)), ICON_ADD) // fills the icon_state with white (except where it's transparent)
		ICO.Blend(new /icon('icons/effects/blood.dmi', "itemblood"), ICON_MULTIPLY)   // adds blood and the remaining white areas become transparant
		IMG = image("icon" = ICO)
		items_blood_overlay_by_type[type] = IMG
		blood_overlay = IMG

/obj/item/proc/showoff(mob/user)
	user.visible_message("[user] holds up [src]. <a HREF=?_src_=usr;lookitem=\ref[src]>Take a closer look.</a>")

/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"

	var/obj/item/I = get_active_hand()
	if(I && !I.abstract)
		I.showoff(src)

/obj/item/proc/update_inv_mob()
	if(!slot_equipped || !ismob(loc))
		return
	var/mob/M = loc
	M.update_inv_item(src)

/obj/item/proc/extinguish()
	return

// Whether or not the given item counts as sharp in terms of dealing damage
/obj/item/proc/is_sharp()
	return sharp || edge

// Whether or not the given item counts as cutting with an edge in terms of removing limbs
/obj/item/proc/has_edge()
	return edge

/obj/item/damage_flags()
	. = FALSE
	if(has_edge())
		. |= DAM_EDGE
	if(is_sharp())
		. |= DAM_SHARP
		if(damtype == BURN)
			. |= DAM_LASER

// Is called when somebody is stripping us using the panel. Return TRUE to allow the strip, FALSE to disallow.
/obj/item/proc/onStripPanelUnEquip(mob/living/who, strip_gloves = FALSE)
	return TRUE

/obj/item/proc/play_unique_footstep_sound() // TODO: port https://github.com/tgstation/tgstation/blob/master/code/datums/components/squeak.dm
	return
