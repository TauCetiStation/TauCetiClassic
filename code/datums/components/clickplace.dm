#define CLICKPLACE_TIP "Can be clickplaced."

/datum/mechanic_tip/clickplace
	tip_name = CLICKPLACE_TIP

/datum/mechanic_tip/clickplace/New()
	description = "Clicking on this object with any intent selected except [INTENT_HARM] will cause the item in currently selected hand to be placed onto it. Dragging and dropping an item on this object with your mouse will cause it to try to move onto the object."



/*
 * This component allows items to be placed on other items
 * in "precise" click coordinates with just a simple click!
 *
 * Is used in tables, and chaplain's altar.
 */
/datum/component/clickplace
	// Is called after an item is succesfully placed.
	// Will get these arguments:
	/*
	 * atom/A     - thing that user clickplaced on
	 * obj/item/I - thing that has been placed
	 * mob/user   - the one doing the clickplacing.
	 */
	var/datum/callback/on_place
	// Is called after parent is slammed by a grab. Return TRUE to prevent default logic.
	// Will get these arguments:
	/*
	 * obj/item/weapon/grab/G - the grab that parent was slammed by.
	 */
	var/datum/callback/on_slam

/datum/component/clickplace/Initialize(datum/callback/_on_place = null, datum/callback/_on_slam = null)
	if(!istype(parent, /atom))
		return COMPONENT_INCOMPATIBLE

	on_place = _on_place
	on_slam = _on_slam

	RegisterSignal(parent, list(COMSIG_PARENT_ATTACKBY), .proc/try_place_click)
	RegisterSignal(parent, list(COMSIG_MOUSEDROPPED_ONTO), .proc/try_place_drag)

	var/datum/mechanic_tip/clickplace/clickplace_tip = new
	parent.AddComponent(/datum/component/mechanic_desc, list(clickplace_tip))

/datum/component/clickplace/Destroy()
	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(CLICKPLACE_TIP))
	QDEL_NULL(on_place)
	QDEL_NULL(on_slam)
	return ..()

/datum/component/clickplace/proc/can_place(atom/place_on, obj/item/I, mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(user.a_intent == INTENT_HARM)
		return FALSE
	// Apperantly robots currently don't use
	// NODROP/ABSTRACT flags. Oh well, refactor it some day please ~Luduk
	if(isrobot(user))
		return FALSE
	if(isessence(user))
		return FALSE
	if(!I.canremove)
		return FALSE
	if(I.flags & ABSTRACT)
		return FALSE
	if(I.swiping)
		return FALSE
	return TRUE

/datum/component/clickplace/proc/try_place_click(datum/source, obj/item/I,  mob/living/user, params)
	if(istype(I, /obj/item/weapon/grab))
		try_slam(I)
		return COMPONENT_NO_AFTERATTACK
	if(!can_place(source, I, user))
		return NONE
	if(!user.drop_from_inventory(I))
		return FALSE

	var/atom/A = parent

	I.forceMove(A.loc)
	var/list/click_params = params2list(params)
	//Center the icon where the user clicked.
	if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
		return
	//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
	I.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size * 0.5), world.icon_size * 0.5)
	I.pixel_y = clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size * 0.5), world.icon_size * 0.5)

	if(on_place)
		on_place.Invoke(A, I, user)

	A.add_fingerprint(user)
	// Prevent hitting the thing if we're just putting it.
	return COMPONENT_NO_AFTERATTACK

/datum/component/clickplace/proc/jump_out(obj/item/I, atom/target, rec_limit = 3)
	if(I.loc == target || rec_limit == 0)
		return

	if(istype(I.loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = I.loc
		S.remove_from_storage(I, target)
	else if(ismob(I.loc))
		var/mob/M = I.loc
		M.drop_from_inventory(I, target)
	else
		I.forceMove(target)

	jump_out(I, target, rec_limit - 1)

/datum/component/clickplace/proc/try_place_drag(datum/source, atom/dropping, mob/living/user)
	if(!istype(dropping, /obj/item))
		return

	var/obj/item/I = dropping

	if(istype(I, /obj/item/weapon/grab))
		try_slam(I)
		return
	if(!can_place(source, I, user))
		return

	var/list/slots_to_check
	var/datum/callback/check_slot_callback
	if(user.IsAdvancedToolUser())
		slots_to_check = list(
			BP_L_ARM = user.l_hand,
			BP_R_ARM = user.r_hand
		)
		check_slot_callback = CALLBACK(user, /mob/living.proc/is_usable_arm)
	else if(istype(user, /mob/living/carbon/ian))
		var/mob/living/carbon/ian/IAN = user
		slots_to_check = list(
			BP_HEAD = IAN.mouth
		)
		check_slot_callback = CALLBACK(user, /mob/living.proc/is_usable_head)

	if(!slots_to_check)
		return

	var/spare_slots = slots_to_check.len
	for(var/slot in slots_to_check)
		if(!check_slot_callback.Invoke(slot))
			spare_slots--
		if(slots_to_check[slot] != null && slots_to_check[slot] != I)
			spare_slots--

	if(spare_slots <= 0)
		return

	jump_out(I, user.loc)

	// Bounding component took over or something.
	if(I.loc != user.loc)
		return

	var/atom/A = parent
	A.add_fingerprint(user)

	if(I.loc != A.loc)
		step_towards(I, A)

		if(I.loc == A.loc && on_place)
			on_place.Invoke(A, I, user)

// Return TRUE to prevent default qdel logic.
/datum/component/clickplace/proc/slam(obj/item/weapon/grab/G)
	var/mob/living/assailant = G.assailant
	var/mob/living/victim = G.affecting
	var/atom/A = parent

	if(on_slam && on_slam.Invoke(G))
		return TRUE

	if(prob(15))
		victim.Weaken(5)
	victim.apply_damage(8, def_zone = BP_HEAD)
	victim.visible_message("<span class='danger'>[assailant] slams [victim]'s face against \the [A]!</span>")
	playsound(src, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)

	victim.log_combat(assailant, "face-slammed against \the [parent]")
	return FALSE

/// Is called when parent is clicked with a grab with HARM selected. Return TRUE if face slammed.
/datum/component/clickplace/proc/try_slam(obj/item/weapon/grab/G)
	var/mob/living/assailant = G.assailant
	var/mob/living/victim = G.affecting
	var/atom/A = parent

	if(!A.density)
		assailant.SetNextMove(CLICK_CD_INTERACT)

		A.add_fingerprint(victim)
		A.add_fingerprint(assailant)

		victim.visible_message("<span class='danger'>[assailant] shoves [victim] into [A]!</span>")

		step_towards(victim, A)
		qdel(src)
		return

	assailant.SetNextMove(CLICK_CD_MELEE)
	if(G.state >= GRAB_AGGRESSIVE)
		victim.forceMove(A.loc)
		victim.Weaken(5)

		victim.log_combat(assailant, "laid on [A]")
	else if(assailant.a_intent != INTENT_HARM)
		/// Let's pretend a face-slam doesn't exist.
		to_chat(assailant, "<span class='warning'>You need a better grip to do that!</span>")
		return
	else if(!victim.has_bodypart(BP_HEAD))
		to_chat(assailant, "<span class='warning'>You need a better grip to do that!</span>")
		return
	else if(slam(G))
		return

	A.add_fingerprint(victim)
	A.add_fingerprint(assailant)

	qdel(G)

#undef CLICKPLACE_TIP
