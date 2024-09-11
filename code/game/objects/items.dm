/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	w_class = SIZE_SMALL
	var/image/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	var/righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	var/r_speed = 1.0
	var/burn_point = null
	var/burning = null
	var/list/hitsound = list()
	var/usesound = null
	var/pickup_sound = null
	var/dropped_sound = null
	var/wet = 0
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

	///Actions that item spawns on atom_init(), paths
	var/list/item_action_types = list()
	///Spawned actions, datums
	var/list/item_actions = list()
	///Add actions on equip(), otherwise we have a special behavior
	var/item_actions_special = FALSE

	var/slot_equipped = 0 // Where this item currently equipped in player inventory (slot_id) (should not be manually edited ever).

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inv //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	var/pierce_protection = 0
	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/canremove = 1 //Mostly for Ninja code at this point but basically will not allow the item to be removed if set to 0. /N
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
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
	var/toolspeed = 1
	var/obj/item/device/uplink/hidden/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.

	// optional world/inventory icon_state overrides
	var/item_state_world = null      // has priority over icon_state for item world (not in inventory) sprites
	var/item_state_inventory = null  // has priority over icon_state for item inventory sprites, defaults to initial(icon_state)

	// other icon overrides
	var/item_state = null            // has priority over icon_state for on-mob sprites
	var/icon_override = null         // Used to override hardcoded clothing dmis in human clothing proc (see also icon_custom)

	/* Species-specific sprite sheets for inventory sprites
	Works similarly to worn sprite_sheets, except the alternate sprites are used when the clothing/refit_for_species() proc is called.
	*/
	var/list/sprite_sheets_obj = null

    /// A list of all tool qualities that src exhibits. To-Do: Convert all our tools to such a system.
	var/list/qualities
	// This thing can be used to stab eyes out.
	var/stab_eyes = FALSE

	// Determines whether additional damage is given to this weapon
	var/blessed = 0

	// Whether this item is currently being swiped.
	var/swiping = FALSE
	// Is heavily utilized by swiping component. Perhaps use to determine how "quick" the strikes with this weapon are?
	// See swiping.dm for more details.
	var/sweep_step = 4
	// Is using this item requires any specific skills?
	var/list/required_skills

	var/dyed_type

	var/flash_protection = NONE
	var/list/flash_protection_slots = list()
	var/can_get_wet = TRUE

/**
  * Doesn't call parent, see [/atom/proc/atom_init]
  */
/obj/item/atom_init()
	SHOULD_CALL_PARENT(FALSE)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	if(light_power && light_range)
		update_light()

	if(opacity && isturf(loc))
		var/turf/T = loc
		T.has_opaque_atom = TRUE // No need to recalculate it in this case, it's guaranteed to be on afterwards anyways.

	if(can_block_air && isturf(loc))
		var/turf/T = loc
		if(!T.can_block_air)
			T.can_block_air = TRUE

	if(uses_integrity)
		if (!armor)
			armor = list()
		atom_integrity = max_integrity

	if(istype(loc, /obj/item/weapon/storage)) // todo: need to catch all spawns in /storage/ objects and make them use handle_item_insertion or forceMove, so we can remove this
		flags_2 |= IN_STORAGE

	if(item_state_world)
		update_world_icon()

	for(var/path in item_action_types)
		var/datum/action/B = new path (src)
		item_actions += B

	return INITIALIZE_HINT_NORMAL

/obj/item/proc/check_allowed_items(atom/target, not_inside, target_self)
	if(((src in target) && !target_self) || ((!istype(target.loc, /turf)) && (!istype(target, /turf)) && (not_inside)) || is_type_in_list(target, can_be_placed_into))
		return 0
	else
		return 1

/obj/item/device
	icon = 'icons/obj/device.dmi'

/obj/item/Destroy()
	QDEL_LIST(item_actions)
	flags &= ~DROPDEL // prevent recursive dels
	if(ismob(loc))
		var/mob/m = loc
		m.drop_from_inventory(src)
	return ..()

/obj/item/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(95))
				return
	qdel(src)

/obj/item/blob_act()
	return

///Updates all icons of action buttons associated with this item
/obj/item/proc/update_item_actions()
	for(var/datum/action/A as anything in item_actions)
		A.button.UpdateIcon()

///Adds action buttons to user associated with this item
/obj/item/proc/add_item_actions(mob/user)
	for(var/datum/action/A in item_actions)
		A.Grant(user)

///Removes all action buttons from user associated with this item
/obj/item/proc/remove_item_actions(mob/user)
	for(var/datum/action/A in item_actions)
		if(A.CheckRemoval(user))
			A.Remove(user)

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

	if(!istype(src.loc, /turf) || usr.stat != CONSCIOUS || usr.restrained() )
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T

/obj/item/examine(mob/user)
	. = ..()

	if(w_class || wet)

		var/stat_flavor = "It is a[wet ? " wet" : ""] [w_class ? "[get_size_flavor()] sized" : ""] item."

		if(wet)
			stat_flavor = "<span class='wet'>[stat_flavor]</span>"

		to_chat(user, stat_flavor)

/obj/item/proc/mob_pickup(mob/user, hand_index=null)
	if (!user || anchored)
		return

	if(HULK in user.mutations)//#Z2 Hulk nerfz!
		if(istype(src, /obj/item/weapon/gun))
			if(prob(20))
				user.say(pick(";RAAAAAAAARGH! WEAPON!", ";HNNNNNNNNNGGGGGGH! I HATE WEAPONS!!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGUUUUUNNNNHH!", ";AAAAAAARRRGH!" ))
			user.visible_message("<span class='notice'>[user] crushes \a [src] with hands.</span>", "<span class='notice'>You crush the [src].</span>")
			qdel(src)
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
		else if(src.w_class < SIZE_NORMAL)
			to_chat(user, "<span class='warning'>\The [src] is far too small for you to pick up.</span>")
			return

	throwing = FALSE

	if(freeze_movement || !user.can_pickup(src))
		return

	remove_outline()
	add_fingerprint(user)

	if(!pickup(user))
		return

	user.SetNextMove(CLICK_CD_RAPID)

	if(loc == user)
		//canremove==0 means that object may not be removed. You can still wear it. This only applies to clothing. /N
		if(!canremove)
			return
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			if(slot_equipped && (slot_equipped in C.check_obscured_slots()))
				to_chat(C, "<span class='warning'>You can't reach that! Something is covering it.</span>")
				return
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(istype(H.wear_suit, /obj/item/clothing/suit))
					var/obj/item/clothing/suit/V = H.wear_suit
					V.attack_reaction(H, REACTION_ITEM_TAKEOFF)
				if(!user.delay_clothing_unequip(src))
					return
		. = user.remove_from_mob(src, user)
	else
		if(isliving(loc))
			return
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(istype(H.wear_suit, /obj/item/clothing/suit))
				var/obj/item/clothing/suit/V = H.wear_suit
				V.attack_reaction(H, REACTION_ITEM_TAKE)

		if(istype(loc, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = src.loc
			. = S.remove_from_storage(src, user)
		else
			. = TRUE

	if(QDELETED(src)) // remove_from_mob() may remove DROPDEL items, so...
		return

	if(.)
		if(isnull(hand_index))
			. = user.put_in_active_hand(src)
		else
			switch(hand_index)
				if(0)
					. = user.put_in_r_hand(src)
				if(1)
					. = user.put_in_l_hand(src)

		if(!(. || isturf(loc)))
			forceMove(get_turf(user))

/obj/item/attack_hand(mob/user)
	mob_pickup(user)

/obj/item/attack_paw(mob/user)
	if (!user || anchored)
		return

	if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = loc
		S.remove_from_storage(src)

	src.throwing = 0
	if (src.loc == user)
		//canremove==0 means that object may not be removed. You can still wear it. This only applies to clothing. /N
		if(istype(src, /obj/item/clothing) && !src:canremove)
			return
		else
			user.remove_from_mob(src)
	else
		if(isliving(src.loc))
			return

		user.next_move = max(user.next_move+2,world.time + 2)

	if(QDELETED(src) || freeze_movement) // no item - no pickup, you dummy!
		return

	if (!user.can_pickup(src))
		to_chat(user, "<span class='notice'>Your claws aren't capable of such fine manipulation!</span>")
		return

	remove_outline()
	if(!pickup(user))
		return
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
	callback = CALLBACK(src, PROC_REF(after_throw), callback) // Replace their callback with our own.
	. = ..(target, range, speed, thrower, spin, diagonals_first, callback)

/obj/item/proc/after_throw(datum/callback/callback)
	if (callback) //call the original callback
		. = callback.Invoke()
	flags_2 &= ~IN_INVENTORY // #10047
	update_world_icon()

/obj/item/proc/talk_into(mob/M, text)
	return FALSE

/obj/item/proc/moved(mob/user, old_loc)
	return

// apparently called whenever an item is removed from a slot, container, or anything else.
/obj/item/proc/dropped(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(user && user.loc != loc && isturf(loc))
		playsound(user, dropped_sound, VOL_EFFECTS_MASTER)
	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED, user)
	flags_2 &= ~IN_INVENTORY
	if(flags & DROPDEL)
		qdel(src)
	update_world_icon()
	set_alt_apperances_layers()
	if(!item_actions_special)
		remove_item_actions(user)

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(SEND_SIGNAL(src, COMSIG_ITEM_PICKUP, user) & COMPONENT_ITEM_NO_PICKUP)
		return FALSE
	playsound(user, pickup_sound, VOL_EFFECTS_MASTER)
	return TRUE

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/weapon/storage/S)
	SHOULD_CALL_PARENT(TRUE)
	flags_2 &= ~IN_STORAGE
	update_world_icon()
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/weapon/storage/S)
	SHOULD_CALL_PARENT(TRUE)
	flags_2 |= IN_STORAGE
	update_world_icon()
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
	SHOULD_CALL_PARENT(TRUE)
	flags_2 |= IN_INVENTORY
	SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED, user, slot)
	SEND_SIGNAL(user, COMSIG_MOB_EQUIPPED, src, slot)
	update_world_icon()
	set_alt_apperances_layers()
	if(!item_actions_special)
		add_item_actions(user)

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
		if(isunder(src) || istype(src, /obj/item/clothing/suit))
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
				if( w_class < SIZE_TINY	)
					return 1
				if( !(slot_flags & SLOT_FLAGS_EARS) )
					return 0
				return 1
			if(SLOT_R_EAR)
				if(H.r_ear)
					return 0
				if( (slot_flags & SLOT_FLAGS_TWOEARS) && H.l_ear )
					return 0
				if( w_class < SIZE_TINY )
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
				if( w_class <= SIZE_TINY || (slot_flags & SLOT_FLAGS_POCKET) )
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
				if( w_class <= SIZE_TINY || (slot_flags & SLOT_FLAGS_POCKET) )
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
				if(!uniform.can_attach_accessory(src))
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
	if((!iscarbon(usr)) || (isbrain(usr)))//Is humanoid, and is not a brain
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

/obj/item/proc/use_tool(atom/target, mob/living/user, delay, amount = 0, volume = 0, quality = null, datum/callback/extra_checks = null, required_skills_override = null, skills_speed_bonus = -0.4, can_move = FALSE)
	// No delay means there is no start message, and no reason to call tool_start_check before use_tool.
	// Run the start check here so we wouldn't have to call it manually.
	if(user.is_busy())
		return

	if(!delay && !tool_start_check(user, amount))
		return

	var/skill_bonus = 1

	//in case item have no defined default required_skill or we need to check other skills e.g. check crowbar for surgery
	if(required_skills_override)
		skill_bonus = apply_skill_bonus(user, 1, required_skills_override, skills_speed_bonus)
	else if(required_skills) //default check for item
		skill_bonus = apply_skill_bonus(user, 1, required_skills, skills_speed_bonus)


	delay *= toolspeed
	delay *= max(skill_bonus, 0.1)

	if(!isnull(quality))
		var/qual_mod = get_quality(quality)
		if(qual_mod <= 0)
			return

		delay *= 1 / qual_mod

	// Play tool sound at the beginning of tool usage.
	play_tool_sound(target, volume)

	if(delay)
		// Create a callback with checks that would be called every tick by do_after.
		var/datum/callback/tool_check = CALLBACK(src, PROC_REF(tool_check_callback), user, amount, extra_checks, target)

		if(ismob(target))
			if(!do_mob(user, target, delay, extra_checks = tool_check))
				return

		else
			if(!do_after(user, delay, target=target, can_move = can_move, extra_checks = tool_check))
				return
	else
		// Invoke the extra checks once, just in case.
		if(extra_checks && !extra_checks.Invoke())
			return

	// Use tool's fuel, stack sheets or charges if amount is set.
	if(amount && !use(amount, user))
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
/obj/item/proc/tool_check_callback(mob/living/user, amount, datum/callback/extra_checks, target)
	return tool_use_check(user, amount, target) && (!extra_checks || extra_checks.Invoke())

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

	if(isxeno(M) || isslime(M))//Aliens don't have eyes./N     slimes also don't have eyes!
		to_chat(user, "<span class='warning'>You cannot locate any eyes on this creature!</span>")
		return

	user.do_attack_animation(M)
	playsound(M, 'sound/items/tools/screwdriver-stab.ogg', VOL_EFFECTS_MASTER)

	M.log_combat(user, "eyestabbed with [name]")

	add_fingerprint(user)
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
				H.adjustBlurriness(10)
				H.Paralyse(1)
				H.Weaken(4)
			if (IO.damage >= IO.min_broken_damage)
				if(H.stat != DEAD)
					to_chat(H, "<span class='warning'>You go blind!</span>")
		var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
		BP.take_damage(force)
	else
		M.take_bodypart_damage(force)

	M.adjustBlurriness(rand(force * 0.5, force))

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
		G.dirt_transfers = 0
	update_inv_mob()

/obj/item/add_dirt_cover()
	. = ..()
	if(!.)
		return
	if(blood_overlay && blood_overlay.color == dirt_overlay.color)
		return
	generate_blood_overlay()
	cut_overlay(blood_overlay)
	blood_overlay.color = dirt_overlay.color
	add_overlay(blood_overlay)
	update_inv_mob()

/obj/item/add_blood(mob/living/carbon/human/M)
	if (!..())
		return 0

	if(blood_DNA[M.dna.unique_enzymes])
		return 0 //already bloodied with this blood. Cannot add more.
	blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	update_inv_mob() // if item on mob, update mob's icon too.
	return 1 //we applied blood to the item

/obj/item/proc/generate_blood_overlay()
	var/static/list/items_blood_overlay_by_type = list()

	if(blood_overlay)
		return

	if(items_blood_overlay_by_type[type])
		blood_overlay = items_blood_overlay_by_type[type]
		return

	var/image/blood = image(icon = 'icons/effects/blood.dmi', icon_state = "itemblood") // Needs to be a new one each time since we're slicing it up with filters.
	blood.filters += filter(type = "alpha", icon = icon(icon, icon_state)) // Same, this filter is unique for each blood overlay per type
	items_blood_overlay_by_type[type] = blood

	blood_overlay = blood

/obj/item/proc/showoff(mob/user)
	user.visible_message("[user] holds up [src]. <a HREF=?_src_=usr;lookitem=\ref[src]>Take a closer look.</a>")

/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"

	var/obj/item/I = get_active_hand()
	if(I && !(I.flags & ABSTRACT))
		I.showoff(src)

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

/obj/item/proc/set_alt_apperances_layers()
	if(alternate_appearances)
		for(var/key in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/basic/AA = alternate_appearances[key]
			AA.theImage.layer = layer
			AA.theImage.plane = plane
			AA.theImage.appearance_flags = appearance_flags

/obj/item/MouseEntered()
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	apply_outline()

/obj/item/MouseExited()
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	remove_outline()

/obj/item/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	if(src != over)
		remove_outline()

/obj/item/be_thrown(mob/living/thrower, atom/target)
	if(!canremove || flags & NODROP)
		return null
	return src

/obj/item/airlock_crush_act()
	var/qual_prying = get_quality(QUALITY_PRYING)
	if(qual_prying <= 0)
		return

	var/chance = w_class / (qual_prying * (m_amt + 1))

	if(prob(chance * 100))
		qdel(src)

/obj/item/proc/display_accessories()
	return

/obj/item/taken(mob/living/user, atom/fallback)
	if(user.Adjacent(src) && user.put_in_hands(src))
		return TRUE

	return ..()

/obj/item/proc/get_quality(quality)
	if(!qualities)
		return 0
	return qualities[quality]

/obj/item/proc/get_dye_type(w_color)
	if(!dyed_type)
		return

	var/list/dye_colors = global.dyed_item_types[dyed_type]
	if(!dye_colors)
		return

	var/obj/item/clothing/dye_type = dye_colors[w_color]
	if(!dye_type)
		return

	if(islist(dye_type))
		dye_type = pick(dye_type)

	return dye_type

/obj/item/proc/wash_act(w_color)
	decontaminate()
	wet = 0

	var/obj/item/clothing/dye_type = get_dye_type(w_color)
	if(!dye_type)
		return

	name = initial(dye_type.name)
	icon_state = initial(dye_type.icon_state)
	item_state = initial(dye_type.item_state)
	desc = "The colors are a bit dodgy."

/obj/item/attack_hulk(mob/living/user)
	return FALSE

/obj/item/burn()
	var/turf/T = get_turf(src)
	var/ash_type
	if(w_class >= SIZE_BIG)
		ash_type = /obj/effect/decal/cleanable/ash/large
	else
		ash_type = /obj/effect/decal/cleanable/ash
	var/obj/effect/decal/cleanable/ash/A = new ash_type(T)
	A.desc += "\nLooks like this used to be \an [name] some time ago."
	..()

// swap between world (small) and ui (big) icons when item changes location
// feel free to override for items with complicated icon mechanics
/obj/item/proc/update_world_icon()
	if(!item_state_world)
		return

	if(flags_2 & IN_INVENTORY || flags_2 & IN_STORAGE)
		// moving to inventory, restore icon (big inventory icon)
		icon_state = item_state_inventory ? item_state_inventory : initial(icon_state)
	else
		// moving to world, change icon (small world icon)
		icon_state = item_state_world

/obj/item/CtrlShiftClick(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	SEND_SIGNAL(H, COMSIG_CLICK_CTRL_SHIFT, src)
