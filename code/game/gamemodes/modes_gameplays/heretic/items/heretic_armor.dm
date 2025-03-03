// Eldritch armor. Looks cool, hood lets you cast heretic spells.
/obj/item/clothing/head/culthood/eldritch

	name = "ominous hood"
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH
	flash_protection = FLASHES_FULL_PROTECTION
	armor = list(melee = 40, bullet = 40, laser = 40, energy = 35, bomb = 10, bio = 10, rad = 0)

/obj/item/clothing/head/culthood/eldritch/atom_init()
	. = ..()
	AddElement(/datum/element/heretic_focus)

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/weapon/sickly_blade, /obj/item/weapon/gun/projectile/lionhunter)
	hoodtype = /obj/item/clothing/head/culthood/eldritch
	// Slightly better than normal cult robes
	armor = list(melee = 40, bullet = 45, laser = 55, energy = 50, bomb = 35, bio = 20, rad = 0)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return
	if(hood_up)
		return

	// Our hood gains the heretic_focus element.
	. += span_notice("Allows you to cast heretic spells while the hood is up.")

// Void cloak. Turns invisible with the hood up, lets you hide stuff.
/obj/item/clothing/head/culthood/void
	name = "void hood"
	desc = "Black like tar, reflecting no light. Runic symbols line the outside. \
		With each flash you lose comprehension of what you are seeing."
	icon_state = "void_cloak"
	flags_inv = NONE
	flags = NONE
	canremove = FALSE
	item_flags = EXAMINE_SKIP
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 30, bomb = 15, bio = 0, rad = 0)

/obj/item/clothing/head/culthood/void/atom_init()
	. = ..()

/obj/item/clothing/suit/hooded/cultrobes/void
	name = "void cloak"
	desc = "Black like tar, reflecting no light. Runic symbols line the outside. \
		With each flash you lose comprehension of what you are seeing."
	icon_state = "void_cloak"
	allowed = list(/obj/item/weapon/sickly_blade)
	hoodtype = /obj/item/clothing/head/culthood/void
	flags_inv = NONE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	// slightly worse than normal cult robes
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 30, bomb = 15, bio = 0, rad = 0)
	alternative_mode = TRUE

/obj/item/clothing/suit/hooded/cultrobes/void/atom_init()
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/void_cloak)
	make_visible()

/obj/item/clothing/suit/hooded/cultrobes/void/equipped(mob/user, slot)
	. = ..()
	if(slot & SLOT_FLAGS_OCLOTHING)
		RegisterSignal(user, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(hide_item))
		RegisterSignal(user, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(show_item))
	#warn Missmatched slots? ^^^

/obj/item/clothing/suit/hooded/cultrobes/void/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_MOB_UNEQUIPPED_ITEM, COMSIG_MOB_EQUIPPED_ITEM))

/obj/item/clothing/suit/hooded/cultrobes/void/proc/hide_item(datum/source, obj/item/item, slot)
	SIGNAL_HANDLER
	if(slot & ITEM_SLOT_SUITSTORE)
		item.canremove = FALSE
	#warn Missmatched slots? ^^^

/obj/item/clothing/suit/hooded/cultrobes/void/proc/show_item(datum/source, obj/item/item, slot)
	SIGNAL_HANDLER
	item.canremove = TRUE

/obj/item/clothing/suit/hooded/cultrobes/void/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return
	if(!hood_up)
		return

	// Let examiners know this works as a focus only if the hood is down
	. += span_notice("Allows you to cast heretic spells while the hood is down.")

/obj/item/clothing/suit/hooded/cultrobes/void/on_hood_down(obj/item/clothing/head/hooded/hood)
	make_visible()
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/void/can_create_hood()
	if(!isliving(loc))
		CRASH("[src] attempted to make a hood on a non-living thing: [loc]")
	var/mob/living/wearer = loc
	if(ishereticormonster(wearer))
		return TRUE

	loc.balloon_alert(loc, "can't get the hood up!")
	return FALSE

/obj/item/clothing/suit/hooded/cultrobes/void/on_hood_created(obj/item/clothing/head/hooded/hood)
	. = ..()
	make_invisible()

/// Makes our cloak "invisible". Not the wearer, the cloak itself.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_invisible()
	item_flags |= EXAMINE_SKIP
	canremove = FALSE
	RemoveElement(/datum/element/heretic_focus)

	if(isliving(loc))
		REMOVE_TRAIT(loc, TRAIT_RESISTLOWPRESSURE, REF(src))
		loc.balloon_alert(loc, "cloak hidden")
		loc.visible_message(span_notice("Light shifts around [loc], making the cloak around them invisible!"))

/// Makes our cloak "visible" again.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_visible()
	item_flags &= ~EXAMINE_SKIP
	canremove = TRUE
	AddElement(/datum/element/heretic_focus)

	if(isliving(loc))
		ADD_TRAIT(loc, TRAIT_RESISTLOWPRESSURE, REF(src))
		loc.balloon_alert(loc, "cloak revealed")
		loc.visible_message(span_notice("A kaleidoscope of colours collapses around [loc], a cloak appearing suddenly around their person!"))
