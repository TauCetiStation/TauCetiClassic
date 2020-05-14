#define CLICKPLACE_TIP "Clickplace"

/datum/mechanic_tip/clickplace
	tip_name = CLICKPLACE_TIP

/datum/mechanic_tip/clickplace/New()
	description = "Clicking on this object with any intent selected except [I_HURT] will cause the item in currently selected hand to be placed onto it."

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

	RegisterSignal(parent, list(COMSIG_PARENT_ATTACKBY), .proc/try_place)

	var/datum/mechanic_tip/clickplace/clickplace_tip = new
	parent.AddComponent(/datum/component/mechanic_desc, list(clickplace_tip))

/datum/component/clickplace/Destroy()
	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(CLICKPLACE_TIP))
	return ..()

/datum/component/clickplace/proc/try_place(datum/source, obj/item/I, mob/user, params)
	if(user.a_intent == I_HURT)
		return NONE
	// Apperantly robots currently don't use
	// NODROP/ABSTRACT flags. Oh well, refactor it some day please ~Luduk
	if(isrobot(user))
		return NONE
	if(!I.canremove)
		return NONE
	if(I.flags & ABSTRACT)
		return NONE
	if(!user.drop_from_inventory(I))
		return NONE

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
		on_place.Invoke(A, I, user, params)

	// Prevent hitting the thing if we're just putting it.
	return COMPONENT_NO_AFTERATTACK

#undef CLICKPLACE_TIP
