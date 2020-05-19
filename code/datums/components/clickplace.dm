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
	 * params     - paramlist of click info.
	 */
	var/datum/callback/on_place

/datum/component/clickplace/Initialize(datum/callback/_on_place = null)
	if(!istype(parent, /atom))
		return COMPONENT_INCOMPATIBLE

	on_place = _on_place

	RegisterSignal(parent, list(COMSIG_PARENT_ATTACKBY), .proc/try_place_click)
	RegisterSignal(parent, list(COMSIG_MOUSEDROPPED_ONTO), .proc/try_place_drag)

	var/datum/mechanic_tip/clickplace/clickplace_tip = new
	parent.AddComponent(/datum/component/mechanic_desc, list(clickplace_tip))

/datum/component/clickplace/Destroy()
	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(CLICKPLACE_TIP))
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
	return TRUE

/datum/component/clickplace/proc/try_place_click(datum/source, obj/item/I,  mob/living/user, params)
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
	I.pixel_x = CLAMP(text2num(click_params["icon-x"]) - 16, -(world.icon_size * 0.5), world.icon_size * 0.5)
	I.pixel_y = CLAMP(text2num(click_params["icon-y"]) - 16, -(world.icon_size * 0.5), world.icon_size * 0.5)

	if(on_place)
		on_place.Invoke(A, I, user)

	// Prevent hitting the thing if we're just putting it.
	return COMPONENT_NO_AFTERATTACK

/datum/component/clickplace/proc/try_place_drag(datum/source, atom/dropping, mob/living/user)
	if(!istype(dropping, /obj/item))
		return

	var/obj/item/I = dropping

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

	// Just in case.
	if(I.loc == user)
		user.drop_from_inventory(I)
	else if(istype(I.loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = I.loc
		S.remove_from_storage(I, S.loc)

	if(!isturf(I.loc))
		return

	var/atom/A = parent

	if(I.loc != A.loc)
		step(I, get_dir(I, A))

		if(I.loc == A.loc && on_place)
			on_place.Invoke(A, I, user)

#undef CLICKPLACE_TIP
