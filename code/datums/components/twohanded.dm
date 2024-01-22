#define TWOHANDED_TIP "Can be double-wielded."

/datum/mechanic_tip/twohanded
	tip_name = TWOHANDED_TIP
	description = "You can use this item in your hand to make your character grab it with both hands."

/datum/mechanic_tip/twohanded/required
	description = "This item requires both of your hands to be free."

/**
 * Component Builder
 * Is used to set all the required params for twohanded component.
 * Instantinate before adding component, no need to save anywhere.
 * vars:
 * * require_twohands (optional) Does the item need both hands to be carried
 * * wieldsound (optional) The sound to play when wielded
 * * unwieldsound (optional) The sound to play when unwielded
 * * attacksound (optional) The sound to play when wielded and attacking
 * * force_multiplier (optional) The force multiplier when wielded, do not use with force_wielded, and force_unwielded
 * * force_wielded (optional) The force setting when the item is wielded, do not use with force_multiplier
 * * force_unwielded (optional) The force setting when the item is unwielded, do not use with force_multiplier
 * * icon_wielded (optional) The icon to be used when wielded
 * * on_wield(mob/wielder, obj/item/wieldee): bool (optional) The callback to be called on wield. If returns TRUE, item won't be wielded
 * * on_unwield(mob/wielder, obj/item/wieldee): bool (optional) The callback to be called on unwield. If returns TRUE, item won't be unwielded
*/
/datum/twohanded_component_builder
	var/require_twohands = FALSE
	var/wieldsound = null
	var/unwieldsound = null
	var/attacksound = null
	var/force_multiplier = 0
	var/force_wielded = 0
	var/force_unwielded = 0
	var/icon_wielded = null
	var/datum/callback/on_wield = null
	var/datum/callback/on_unwield = null

/**
 * Two Handed Component
 * When applied to an item it will make it two handed
 */

/datum/component/twohanded
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS // Only one of the component can exist on an item
	var/wielded = FALSE /// Are we holding the two handed item properly
	var/force_multiplier = 0 /// The multiplier applied to force when wielded, does not work with force_wielded, and force_unwielded
	var/force_wielded = 0 /// The force of the item when wielded
	var/force_unwielded = 0 /// The force of the item when unwielded
	var/wieldsound = FALSE /// Play sound when wielded
	var/unwieldsound = FALSE /// Play sound when unwielded
	var/attacksound = FALSE /// Play sound on attack when wielded
	var/require_twohands = FALSE /// Does it have to be held in both hands
	var/icon_wielded = FALSE /// The icon that will be used when wielded
	var/obj/item/weapon/offhand/offhand_item = null /// Reference to the offhand created for the item
	var/datum/callback/on_wield = null /// The callback that will be called on wielding
	var/datum/callback/on_unwield = null /// The callback that will be called on unwielding

/**
 * Two Handed component
 */
/datum/component/twohanded/Initialize(datum/twohanded_component_builder/TCB)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(!TCB)
		TCB = new

	require_twohands = TCB.require_twohands
	wieldsound = TCB.wieldsound
	unwieldsound = TCB.unwieldsound
	attacksound = TCB.attacksound
	force_multiplier = TCB.force_multiplier
	force_wielded = TCB.force_wielded
	force_unwielded = TCB.force_unwielded
	icon_wielded = TCB.icon_wielded
	on_wield = TCB.on_wield
	on_unwield = TCB.on_unwield

	var/datum/mechanic_tip/twohanded/tip
	if(require_twohands)
		tip = new /datum/mechanic_tip/twohanded/required
	else
		tip = new /datum/mechanic_tip/twohanded
	parent.AddComponent(/datum/component/mechanic_desc, list(tip))

/datum/component/twohanded/Destroy(force, silent)
	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(TWOHANDED_TIP))
	return ..()

// Inherit the new values passed to the component
/datum/component/twohanded/InheritComponent(datum/component/twohanded/new_comp, original, datum/twohanded_component_builder/TCB)
	if(!original)
		return
	if(!TCB)
		return

	require_twohands = TCB.require_twohands
	wieldsound = TCB.wieldsound
	unwieldsound = TCB.unwieldsound
	attacksound = TCB.attacksound
	force_multiplier = TCB.force_multiplier
	force_wielded = TCB.force_wielded
	force_unwielded = TCB.force_unwielded
	icon_wielded = TCB.icon_wielded
	on_wield = TCB.on_wield
	on_unwield = TCB.on_unwield

// Register signals with the parent item
/datum/component/twohanded/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

// Remove all siginals registered to the parent item
/datum/component/twohanded/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_PICKUP,
                                COMSIG_ITEM_EQUIPPED,
                                COMSIG_ITEM_DROPPED,
                                COMSIG_ITEM_ATTACK_SELF,
                                COMSIG_ITEM_ATTACK,
                                COMSIG_MOVABLE_MOVED))

/// Triggered on pickup of the item containing the component
/datum/component/twohanded/proc/on_pickup(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!require_twohands)
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='notice'>[parent] is too heavy and cumbersome for you to carry!</span>")
		return COMPONENT_ITEM_NO_PICKUP
	var/mob/living/carbon/human/wielder = user
	var/obj/item/organ/external/l_hand = wielder.bodyparts_by_name[BP_L_ARM]
	var/obj/item/organ/external/r_hand = wielder.bodyparts_by_name[BP_R_ARM]
	if((!l_hand || l_hand.is_stump) || (!r_hand || r_hand.is_stump))
		to_chat(user, "<span class='notice'>[parent] is too cumbersome to carry in one hand!</span>")
		return COMPONENT_ITEM_NO_PICKUP

/// Triggered on equip of the item containing the component
/datum/component/twohanded/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(require_twohands && ((slot == SLOT_L_HAND) || (slot == SLOT_R_HAND))) // force equip the item
		wield(user)
	if(!user.is_in_hands(parent) && wielded && !require_twohands)
		unwield(user)
	if(slot == SLOT_BACK)
		unwield(user, FALSE, FALSE)

/// Triggered on drop of item containing the component
/datum/component/twohanded/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	if(require_twohands) //Don't let the item fall to the ground and cause bugs if it's actually being equipped on another slot.
		unwield(user, FALSE, FALSE)
	if(wielded)
		unwield(user)
	if(source == offhand_item && !QDELETED(source))
		qdel(source)

/// Triggered on attack self of the item containing the component
/datum/component/twohanded/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER

	if(wielded)
		unwield(user)
	else if(user.is_in_hands(parent))
		wield(user)

/**
 * Wield the two handed item in both hands
 *
 * vars:
 * * user The mob/living/carbon that is wielding the item
 */
/datum/component/twohanded/proc/wield(mob/living/carbon/user)
	if(wielded)
		return
	if(!user.IsAdvancedToolUser())
		if(require_twohands)
			to_chat(user, "<span class='notice'>[parent] is too heavy and cumbersome for you to carry!</span>")
			user.drop_from_inventory(parent)
		else
			to_chat(user, "<span class='notice'>It's too heavy for you to wield fully.</span>")
		return
	if(user.get_inactive_hand())
		if(require_twohands)
			to_chat(user, "<span class='notice'>[parent] is too cumbersome to carry in one hand!</span>")
			user.drop_from_inventory(parent)
		else
			to_chat(user, "<span class='warning'>You need your other hand to be empty!</span>")
		return
	var/mob/living/carbon/human/wielder = user
	var/obj/item/organ/external/l_hand = wielder.bodyparts_by_name[BP_L_ARM]
	var/obj/item/organ/external/r_hand = wielder.bodyparts_by_name[BP_R_ARM]
	if((!l_hand || l_hand.is_stump) || (!r_hand || r_hand.is_stump))
		if(require_twohands)
			wielder.drop_from_inventory(parent)
		to_chat(wielder, "<span class='warning'>You don't have enough intact hands.</span>")
		return

	// Wield update status
	if(on_wield && on_wield.Invoke(wielder, parent))
		return // Blocked wield from item
	wielded = TRUE
	RegisterSignal(wielder, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_swap_hands))
	ADD_TRAIT(parent, TRAIT_DOUBLE_WIELDED, TWOHANDED_TRAIT)

	// Update item stats and name
	var/obj/item/parent_item = parent
	if(force_multiplier)
		parent_item.force *= force_multiplier
	else if(force_wielded)
		parent_item.force = force_wielded
	parent_item.name = "[parent_item.name] (Wielded)"

	if(icon_wielded)
		parent_item.icon_state = icon_wielded
	else
		parent_item.update_icon()

	if(isrobot(wielder))
		to_chat(wielder, "<span class='notice'>You dedicate your module to [parent].</span>")
	else
		to_chat(wielder, "<span class='notice'>You grab [parent] with both hands.</span>")

	// Play sound if one is set
	if(wieldsound)
		playsound(parent_item.loc, wieldsound, VOL_EFFECTS_MASTER, 50, TRUE)

	// Let's reserve the other hand
	offhand_item = new(wielder)
	offhand_item.name = "[parent_item.name] - offhand"
	offhand_item.desc = "Your second grip on [parent_item]."
	offhand_item.wielded = TRUE
	RegisterSignal(offhand_item, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	wielder.put_in_inactive_hand(offhand_item)

/**
 * Unwield the two handed item
 *
 * vars:
 * * user The mob/living/carbon that is unwielding the item
 * * show_message (option) show a message to chat on unwield
 * * can_drop (option) whether 'drop_from_inventory' can be called or not.
 */
/datum/component/twohanded/proc/unwield(mob/living/carbon/user, show_message = TRUE, can_drop = TRUE)
	if(!wielded)
		return

	if(on_unwield && on_unwield.Invoke(user, parent))
		return // Blocked wield from item
	// Wield update status
	wielded = FALSE
	REMOVE_TRAIT(parent, TRAIT_DOUBLE_WIELDED, TWOHANDED_TRAIT)
	UnregisterSignal(user, COMSIG_MOB_SWAP_HANDS)

	// Update item stats
	var/obj/item/parent_item = parent
	if(force_multiplier)
		parent_item.force /= force_multiplier
	else if(force_unwielded)
		parent_item.force = force_unwielded

	// update the items name to remove the wielded status
	var/sf = findtext(parent_item.name, " (Wielded)", -10) // 10 == length(" (Wielded)")
	if(sf)
		parent_item.name = copytext(parent_item.name, 1, sf)
	else
		parent_item.name = "[initial(parent_item.name)]"

	// Update icons
	if(icon_wielded)
		parent_item.icon_state = initial(parent_item.icon_state)
	else
		parent_item.update_icon()

	if(istype(user))
		parent_item.update_inv_mob()

		// If the item requires two handed drop the item on unwield
		if(require_twohands && can_drop)
			user.drop_from_inventory(parent)

		// Show message if requested
		if(show_message)
			if(isrobot(user))
				to_chat(user, "<span class='notice'>You free up your module.</span>")
			else if(require_twohands)
				to_chat(user, "<span class='notice'>You drop [parent].</span>")
			else
				to_chat(user, "<span class='notice'>You are now carrying [parent] with one hand.</span>")

	// Play sound if set
	if(unwieldsound)
		playsound(parent_item.loc, unwieldsound, VOL_EFFECTS_MASTER, 50, TRUE)

	// Remove the object in the offhand
	if(offhand_item)
		UnregisterSignal(offhand_item, COMSIG_ITEM_DROPPED)
		qdel(offhand_item)
	offhand_item = null

/**
 * on_attack triggers on attack with the parent item
 */
/datum/component/twohanded/proc/on_attack(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	if(wielded && attacksound)
		var/obj/item/parent_item = parent
		playsound(parent_item.loc, attacksound, VOL_EFFECTS_MASTER, 50, TRUE)

/**
 * on_moved Triggers on item moved
 */
/datum/component/twohanded/proc/on_moved(datum/source, mob/user, dir)
	SIGNAL_HANDLER

	unwield(user)

/**
 * on_swap_hands Triggers on swapping hands, blocks swap if the other hand is busy
 */
/datum/component/twohanded/proc/on_swap_hands(mob/user, obj/item/held_item)
	SIGNAL_HANDLER

	if(!held_item)
		return
	if(held_item == parent)
		return COMPONENT_BLOCK_SWAP

/**
 * The offhand dummy item for two handed items
 */
/obj/item/weapon/offhand
	name = "offhand"
	icon_state = "offhand"
	w_class = SIZE_LARGE
	flags = NODROP | ABSTRACT
	canremove = FALSE
	unacidable = TRUE
	var/wielded = FALSE // Off Hand tracking of wielded status

/obj/item/weapon/offhand/Destroy()
	wielded = FALSE
	return ..()

/obj/item/weapon/offhand/dropped(mob/user)
	UnregisterSignal(src, COMSIG_ITEM_DROPPED)
	. = ..()

/obj/item/weapon/offhand/equipped(mob/user, slot)
	. = ..()
	if(wielded && !user.is_in_hands(src) && !QDELETED(src))
		qdel(src)
