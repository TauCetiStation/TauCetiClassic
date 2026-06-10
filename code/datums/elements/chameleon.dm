// Shared "disguise" behaviour for chameleon gear. Bespoke per root_type, so one element
// instance == one cached choices list (the element itself is the cache). Adds the
// "Change Appearance" verb, reacts to EMP, and applies a picked disguise.

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

/datum/element/chameleon/Attach(datum/target, root_type)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	if(isnull(choices))
		build_choices(root_type)
	var/obj/item/I = target
	I.verbs += /obj/item/proc/chameleon_change
	RegisterSignal(target, COMSIG_ITEM_CHAMELEON_CHANGE, PROC_REF(on_change))
	RegisterSignal(target, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))

/datum/element/chameleon/Detach(datum/source, ...)
	var/obj/item/I = source
	if(istype(I))
		I.verbs -= /obj/item/proc/chameleon_change
	UnregisterSignal(source, list(COMSIG_ITEM_CHAMELEON_CHANGE, COMSIG_ATOM_EMP_ACT))
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

/datum/element/chameleon/proc/on_change(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(disguise), source, user)

/datum/element/chameleon/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER
	reset(source)

/datum/element/chameleon/proc/disguise(obj/item/I, mob/user)
	if(!(I in user) || user.incapacitated())
		return
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

/obj/item/proc/chameleon_change()
	set name = "Change Appearance"
	set category = "Object"
	set src in usr
	SEND_SIGNAL(src, COMSIG_ITEM_CHAMELEON_CHANGE, usr)
