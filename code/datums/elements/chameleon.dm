// Shared "disguise" behaviour for chameleon gear. Bespoke per root_type, so one element
// instance == one cached choices list (the element itself is the cache). Worn/held/pocketed
// chameleon items register in one shared "Chameleon" action button, reacts to EMP, and
// applies a picked disguise.

// root_type -> list of subtypes that must not show up as disguises.
var/global/list/chameleon_blocked_disguises = list(
	/obj/item/clothing/under = list(/obj/item/clothing/under/chameleon, /obj/item/clothing/under/golem, /obj/item/clothing/under/gimmick),
	/obj/item/clothing/head = list(/obj/item/clothing/head/chameleon, /obj/item/clothing/head/helmet/space/golem, /obj/item/clothing/head/justice, /obj/item/clothing/head/collectable/tophat/badmin_magic_hat),
	/obj/item/clothing/suit = list(/obj/item/clothing/suit/chameleon, /obj/item/clothing/suit/space/space_ninja, /obj/item/clothing/suit/space/golem, /obj/item/clothing/suit/justice, /obj/item/clothing/suit/greatcoat),
	/obj/item/clothing/shoes = list(/obj/item/clothing/shoes/chameleon, /obj/item/clothing/shoes/golem, /obj/item/clothing/shoes/syndigaloshes, /obj/item/clothing/shoes/cyborg),
	/obj/item/weapon/storage/backpack = list(/obj/item/weapon/storage/backpack/chameleon, /obj/item/weapon/storage/backpack/satchel/withwallet),
	/obj/item/clothing/gloves = list(/obj/item/clothing/gloves/chameleon, /obj/item/clothing/gloves/black/strip, /obj/item/clothing/gloves/black/silence),
	/obj/item/clothing/mask = list(/obj/item/clothing/mask/chameleon),
	/obj/item/clothing/glasses = list(/obj/item/clothing/glasses/chameleon),
	/obj/item/weapon/gun = list(/obj/item/weapon/gun/projectile/chameleon)
)

/datum/element/chameleon
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	// name -> type for every disguise of this element's root_type (real sprites only).
	var/list/choices
	// name -> image, built lazily for the radial menu.
	var/list/choice_images

/datum/element/chameleon/Attach(datum/target, root_type)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	if(isnull(choices))
		build_choices(root_type)
	RegisterSignal(target, COMSIG_ITEM_ACTION_TRIGGER, PROC_REF(on_action))
	RegisterSignal(target, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))

/datum/element/chameleon/Detach(datum/source, ...)
	UnregisterSignal(source, list(COMSIG_ITEM_ACTION_TRIGGER, COMSIG_ATOM_EMP_ACT, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	return ..()

/datum/element/chameleon/proc/build_choices(root_type)
	choices = list()
	var/list/blocked = global.chameleon_blocked_disguises[root_type]
	for(var/t in subtypesof(root_type) - blocked)
		var/obj/item/A = t
		var/ic = initial(A.icon_custom) || initial(A.icon)
		if(!ic || !icon_exists(ic, initial(A.icon_state)))
			continue
		choices[initial(A.name)] = t

/datum/element/chameleon/proc/get_choice_images()
	if(choice_images)
		return choice_images
	choice_images = list()
	for(var/name in choices)
		var/obj/item/A = choices[name]
		var/ic = initial(A.icon_custom) || initial(A.icon)
		var/state = initial(A.item_state_inventory) || initial(A.icon_state)
		choice_images[name] = image(icon = ic, icon_state = state)
	return choice_images

/datum/element/chameleon/proc/on_action(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(disguise), source, user)
	return COMPONENT_ACTION_HANDLED

/datum/element/chameleon/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER
	reset(source)

// Worn/held/pocketed chameleon items collect into one shared "Chameleon" button per mob.
/datum/element/chameleon/proc/on_equipped(obj/item/I, mob/user, slot)
	SIGNAL_HANDLER
	if(slot == SLOT_IN_BACKPACK)
		on_dropped(I, user)
		return
	var/datum/action/chameleon_outfit/action = locate() in user.actions
	if(!action)
		action = new(user) // target=user: update_action_buttons() deletes targetless actions
		action.Grant(user)
	action.items |= I

/datum/element/chameleon/proc/on_dropped(obj/item/I, mob/user)
	SIGNAL_HANDLER
	var/datum/action/chameleon_outfit/action = locate() in user.actions
	if(!action)
		return
	action.items -= I
	if(!length(action.items))
		qdel(action)

/datum/element/chameleon/proc/disguise(obj/item/I, mob/user)
	if(!(I in user) || user.incapacitated())
		return
	var/picked = show_radial_menu(user, I, get_choice_images(), require_near = TRUE, tooltips = TRUE)
	if(!picked || !choices[picked])
		return
	if(!(I in user) || user.incapacitated())
		return
	var/obj/item/A = choices[picked]
	// initial(): reading a live/new'd sample is corrupted by update_world_icon() (icon_state -> "_w")
	I.icon = initial(A.icon_custom) || initial(A.icon)
	I.icon_custom = initial(A.icon_custom)
	I.name = initial(A.name)
	I.desc = initial(A.desc)
	var/inv = initial(A.item_state_inventory) || initial(A.icon_state)
	I.icon_state = inv
	I.item_state_inventory = inv
	I.item_state = initial(A.item_state)
	I.item_state_world = initial(A.item_state_world)
	I.flags_inv = initial(A.flags_inv)
	I.body_parts_covered = initial(A.body_parts_covered)
	I.render_flags = initial(A.render_flags)
	I.update_world_icon()
	I.update_inv_mob()

/datum/element/chameleon/proc/reset(obj/item/I)
	I.icon = initial(I.icon)
	I.icon_custom = initial(I.icon_custom)
	I.name = initial(I.name)
	I.desc = initial(I.desc)
	I.icon_state = initial(I.icon_state)
	I.item_state = initial(I.item_state)
	I.item_state_inventory = initial(I.item_state_inventory)
	I.item_state_world = initial(I.item_state_world)
	I.flags_inv = initial(I.flags_inv)
	I.update_world_icon()
	I.update_icon()
	I.update_inv_mob()

// One button per mob: radial to pick which chameleon item, then that item's disguise radial.
/datum/action/chameleon_outfit
	name = "Chameleon"
	action_type = AB_GENERIC
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_ALIVE
	button_overlay_icon = 'icons/obj/device.dmi'
	button_overlay_state = "shield0"
	var/list/obj/item/items = list()

/datum/action/chameleon_outfit/Trigger()
	if(!Checks())
		return
	INVOKE_ASYNC(src, PROC_REF(pick_item))

/datum/action/chameleon_outfit/proc/pick_item()
	var/list/choices = list()
	var/list/by_name = list()
	for(var/obj/item/I as anything in items)
		var/name = I.name
		while(by_name[name])
			name = "[name] "
		by_name[name] = I
		choices[name] = image(icon = I.icon, icon_state = I.icon_state)
	var/picked = show_radial_menu(owner, owner, choices, require_near = TRUE, tooltips = TRUE)
	if(!picked)
		return
	var/obj/item/I = by_name[picked]
	if(!I)
		return
	SEND_SIGNAL(I, COMSIG_ITEM_ACTION_TRIGGER, owner)
