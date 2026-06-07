// Shared "disguise" behaviour for chameleon gear. Holds the appearance choices and
// applies them, replacing the per-item copy-pasted change() logic.
var/global/list/chameleon_choices_cache = list()

// name -> type for every disguise of root_type, built once and cached (it only depends on root_type).
/proc/get_chameleon_choices(root_type, list/blocked)
	. = global.chameleon_choices_cache[root_type]
	if(.)
		return
	. = list()
	for(var/t in subtypesof(root_type) - blocked)
		var/obj/item/A = t
		.[initial(A.name)] = t
	global.chameleon_choices_cache[root_type] = .

/datum/component/chameleon
	var/list/choices

/datum/component/chameleon/Initialize(root_type, list/blocked)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	choices = get_chameleon_choices(root_type, blocked)

/datum/component/chameleon/proc/disguise(mob/user)
	var/obj/item/I = parent
	var/picked = input(user, "Select appearance to change it to", "Chameleon") as null|anything in choices
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

/datum/component/chameleon/proc/reset()
	var/obj/item/I = parent
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
