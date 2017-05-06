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
	var/hitsound = null
	var/wet = 0
	var/w_class = 3.0
	var/can_embed = 1
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	pass_flags = PASSTABLE
	pressure_resistance = 5
//	causeerrorheresoifixthis
	var/obj/item/master = null

	var/slot_equipped = null // Where this item currently equipped (as slot).
	var/obj/item/bodypart/slot_bodypart = null // What bodypart holds this item (as ref).

	var/flags_pressure = 0
	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	var/datum/action/item_action/action = null
	var/action_button_name //It is also the text which gets displayed on the action button. If not set it defaults to 'Use [name]'. If it's not set, there'll be no button.
	var/action_button_is_hands_free = 0 //If 1, bypass the restrained, lying, and stunned checks action buttons normally test for

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inv //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	var/item_color = null
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	var/un_equip_time = 0 // unequip / equip delay.
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
	var/uncleanable = 0
	var/toolspeed = 1

	var/obj/item/device/uplink/hidden/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.

	/* Species-specific sprites, concept stolen from Paradise//vg/.
	ex:
	sprite_sheets = list(
		S_TAJARAN = 'icons/cat/are/bad'
		)
	If index term exists and icon_override is not set, this sprite sheet will be used.
	*/
	var/list/sprite_sheets = null
	var/icon_override = null  //Used to override hardcoded clothing dmis in human clothing proc.

	/* Species-specific sprite sheets for inventory sprites
	Works similarly to worn sprite_sheets, except the alternate sprites are used when the clothing/refit_for_species() proc is called.
	*/
	var/list/sprite_sheets_obj = null

/obj/item/proc/check_allowed_items(atom/target, not_inside, target_self)
	if(((src in target) && !target_self) || ((!istype(target.loc, /turf)) && (!istype(target, /turf)) && (not_inside)) || is_type_in_list(target, can_be_placed_into))
		return 0
	else
		return 1

/obj/item/device
	icon = 'icons/obj/device.dmi'

/obj/item/Destroy()
	flags &= ~DROPDEL //prevent recursive dels
	if(ismob(loc))
		var/mob/m = loc
		m.temporarilyRemoveItemFromInventory(src, TRUE)
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
	..()
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
	if (!user || user.is_busy(user, slot_equipped, TRUE))
		return

	if(HULK in user.mutations)//#Z2 Hulk nerfz!
		if(istype(src, /obj/item/weapon/melee/))
			if(src.w_class < 4)
				to_chat(user, "\red \The [src] is far too small for you to pick up.")
				return
		else if(istype(src, /obj/item/weapon/gun/))
			if(prob(20))
				user.say(pick(";RAAAAAAAARGH! WEAPON!", ";HNNNNNNNNNGGGGGGH! I HATE WEAPONS!!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGUUUUUNNNNHH!", ";AAAAAAARRRGH!" ))
			user.visible_message("\blue [user] crushes \a [src] with hands.", "\blue You crush the [src].")
			qdel(src)
			//user << "\red \The [src] is far too small for you to pick up."
			return
		else if(istype(src, /obj/item/clothing/))
			if(prob(20))
				to_chat(user, "\red [pick("You are not interested in [src].", "This is nothing.", "Humans stuff...", "A cat? A scary cat...",
				"A Captain? Let's smash his skull! I don't like Captains!",
				"Awww! Such lovely doggy! BUT I HATE DOGGIES!!", "A woman... A lying woman! I love womans! Fuck womans...")]")
			return
		else if(istype(src, /obj/item/weapon/book/))
			to_chat(user, "\red A book! I LOVE BOOKS!!")
		else if(istype(src, /obj/item/weapon/reagent_containers/food))
			if(prob(20))
				to_chat(user, "\red I LOVE FOOD!!")
		else if(src.w_class < 4)
			to_chat(user, "\red \The [src] is far too small for you to pick up.")
			return

	if(hasbodyparts(user))
		var/mob/living/carbon/C = user
		var/obj/item/bodypart/BP = C.active_hand
		if(BP && !BP.is_usable())
			to_chat(user, "<span class='notice'>You try to move your [BP.name], but cannot!")
			return

	if(istype(src.loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = src.loc
		S.remove_from_storage(src)

	src.throwing = 0
	if(src.loc == user)
		if(!src.canremove)
			return
		if(un_equip_time && !do_mob(user, user, un_equip_time, target_slot = slot_equipped))
			return
		if(!remove_from(FALSE, user, FALSE, user))
			return
	else
		if(isliving(src.loc))
			return
		user.next_move = max(user.next_move+2,world.time + 2)
	src.pickup(user)
	add_fingerprint(user)
	user.put_in_active_hand(src)
	return

/obj/item/attack_paw(mob/user) // TODO rewrite this

	if(isalien(user)) // -- TLE
		var/mob/living/carbon/alien/A = user

		if(!A.has_fine_manipulation || w_class >= 4)
			if(src in A.contents) // To stop Aliens having items stuck in their pockets
				A.dropItemToGround(src)
			to_chat(user, "Your claws aren't capable of such fine manipulation.")
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
		src.pickup(user)
		user.next_move = max(user.next_move+2,world.time + 2)

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
/obj/item/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		if(S.use_to_pickup)
			if(S.collection_mode) //Mode is set to collect all items on a tile and we clicked on a valid one.
				if(isturf(src.loc))
					var/list/rejections = list()
					var/success = 0
					var/failure = 0

					for(var/obj/item/I in src.loc)
						if(I.type in rejections) // To limit bag spamming: any given type only complains once
							continue
						if(!S.can_be_inserted(I))	// Note can_be_inserted still makes noise when the answer is no
							rejections += I.type	// therefore full bags are still a little spammy
							failure = 1
							continue
						success = 1
						S.handle_item_insertion(I, 1)	//The 1 stops the "You put the [src] into [S]" insertion message from being displayed.
					if(success && !failure)
						to_chat(user, "<span class='notice'>You put everything in [S].</span>")
					else if(success)
						to_chat(user, "<span class='notice'>You put some things in [S].</span>")
					else
						to_chat(user, "<span class='notice'>You fail to pick anything up with [S].</span>")

			else if(S.can_be_inserted(src))
				S.handle_item_insertion(src)
	return

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

//the mob C is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
/obj/item/proc/mob_can_equip(mob/living/carbon/C, slot, disable_warning = FALSE)
	if(!slot || !C)
		return FALSE

	if(istype(C))
		return limb_can_equip(C.get_BP_by_slot(slot), slot, disable_warning)
	return FALSE

/obj/item/proc/limb_can_equip(obj/item/bodypart/BP, slot, disable_warning = FALSE)
	if(!slot || !BP)
		return FALSE

	if(istype(BP))
		if(BP.can_hold(src, slot, disable_warning = FALSE))
			var/list/obscured = BP.check_obscured_slots()
			if(obscured && obscured[slot])
				return FALSE
			return TRUE

	return FALSE

/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(!(usr)) //BS12 EDIT
		return
	if(!usr.canmove || usr.stat || usr.restrained() || !Adjacent(usr))
		return
	if(!iscarbon(usr))
		to_chat(usr, "\red You can't pick things up!")
		return
	if( usr.stat || usr.restrained() )//Is not asleep/dead and is not restrained
		to_chat(usr, "\red You can't pick things up!")
		return
	if(src.anchored) //Object isn't anchored
		to_chat(usr, "\red You can't pick that up!")
		return
	if(usr.get_active_hand() && usr.get_inactive_hand())
		to_chat(usr, "\red Your hands are full.")
		return
	if(!istype(src.loc, /turf)) //Object is on a turf
		to_chat(usr, "\red You can't pick that up!")
		return
	//All checks are done, time to pick it up!
	usr.UnarmedAttack(src)
	return


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
	while(L && !istype(L, /turf/))
		L = L.loc
	return loc

/obj/item/proc/eyestab(mob/living/carbon/M, mob/living/carbon/user)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			// you can't stab someone in the eyes wearing a mask!
			to_chat(user, "\red You're going to need to remove the eye covering first.")
			return

	var/mob/living/carbon/monkey/Mo = M
	if(istype(Mo) && ( \
			(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
		))
		// you can't stab someone in the eyes wearing a mask!
		to_chat(user, "\red You're going to need to remove the eye covering first.")
		return

	if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/slime))//Aliens don't have eyes./N     slimes also don't have eyes!
		to_chat(user, "\red You cannot locate any eyes on this creature!")
		return

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
	M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
	msg_admin_attack("[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)") //BS12 EDIT ALG

	src.add_fingerprint(user)
	//if((user.disabilities & CLUMSY) && prob(50))
	//	M = user
		/*
		to_chat(M, "\red You stab yourself in the eye.")
		M.disabilities |= BLIND
		M.weakened += 4
		M.adjustBruteLoss(10)
		*/
	if(M != user)
		for(var/mob/O in (viewers(M) - user - M))
			O.show_message("\red [M] has been stabbed in the eye with [src] by [user].", 1)
		to_chat(M, "\red [user] stabs you in the eye with [src]!")
		to_chat(user, "\red You stab [M] in the eye with [src]!")
	else
		user.visible_message( \
			"\red [user] has stabbed themself with [src]!", \
			"\red You stab yourself in the eyes with [src]!" \
		)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/eyes/eyes = H.organs_by_name[BP_EYES]
		eyes.damage += rand(3,4)
		if(eyes.damage >= eyes.min_bruised_damage)
			if(H.stat != DEAD)
				if(eyes.robotic <= 1) //robot eyes bleeding might be a bit silly
					to_chat(H, "\red Your eyes start to bleed profusely!")
			if(prob(50))
				if(H.stat != DEAD)
					to_chat(H, "\red You drop what you're holding and clutch at your eyes!")
					H.drop_item()
				H.eye_blurry += 10
				H.Paralyse(1)
				H.Weaken(4)
			if (eyes.damage >= eyes.min_broken_damage)
				if(H.stat != DEAD)
					to_chat(H, "\red You go blind!")
		var/obj/item/bodypart/BP = H.get_bodypart(BP_HEAD)
		BP.take_damage(7)
	else
		M.take_bodypart_damage(7)
	M.eye_blurry += rand(3,4)
	return

/obj/item/clean_blood()
	if(uncleanable)
		return

	. = ..()

	if(blood_overlay)
		overlays -= blood_overlay

	update_inv_item()

/obj/item/bodypart/clean_blood()
	if(uncleanable)
		return

	src.germ_level = 0 // copypasted from atom, because i dont want parents stuff.
	if(istype(blood_DNA, /list))
		blood_DNA = null
		. = TRUE

	if(blood_overlay)
		overlays -= blood_overlay

	if(bld_overlay)
		bld_overlay = null
		if(owner)
			owner.update_bloody_bodypart(body_zone)

/obj/item/add_blood(mob/living/carbon/C)
	if (!..())
		return FALSE

	//if we haven't made our blood_overlay already
	if( !blood_overlay )
		generate_blood_overlay()

	//apply the blood-splatter overlay if it isn't already in there
	if(!blood_DNA.len)
		blood_overlay.color = blood_color
		overlays += blood_overlay

	//if this blood isn't already in the list, add it

	if(blood_DNA[C.dna.unique_enzymes])
		return FALSE //already bloodied with this blood. Cannot add more.
	blood_DNA[C.dna.unique_enzymes] = C.dna.b_type

	update_inv_item()

	return TRUE //we applied blood to the item

/obj/item/bodypart/add_blood(mob/living/carbon/C)
	if (!..())
		return FALSE

	if(body_zone != BP_GROIN)
		bld_overlay = image(icon = species.blood_overlays, icon_state = "bloody_" + body_zone, layer = -DAMAGE_LAYER + limb_layer_priority + 0.1)
		bld_overlay.color = blood_color
		if(owner)
			owner.update_bloody_bodypart(body_zone)

	return TRUE //we applied blood to the item

var/list/items_blood_overlay_by_type = list()
/obj/item/proc/generate_blood_overlay()
	if(blood_overlay)
		return

	// TODO: proper implementation of this without blend if possible.
	// At least this removes heavy CPU load and makes it cost smt like (self: 0.000 | calls: 3) instead of (self: 0.090 | calls: 3) with old code that uses for(A in world).
	var/image/img = items_blood_overlay_by_type[src.type]
	if(img)
		blood_overlay = img
	else
		var/icon/I = new /icon(icon, icon_state)
		I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
		I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
		img = image("icon" = I)
		items_blood_overlay_by_type[src.type] = img
		blood_overlay = img

/obj/item/proc/showoff(mob/user)
	for (var/mob/M in view(user))
		M.show_message("[user] holds up [src]. <a HREF=?src=\ref[M];lookitem=\ref[src]>Take a closer look.</a>",1)

/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"

	var/obj/item/I = get_active_hand()
	if(I && !I.abstract)
		I.showoff(src)
