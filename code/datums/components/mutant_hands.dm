/**
 * ## Mutant hands component
 *
 * This component applies to humans, and forces them to hold
 * a certain typepath item in every hand no matter what*.
 *
 * For example, zombies being forced to hold "zombie claws" - disallowing them from holding items
 * but giving them powerful weapons to infect people
 *
 * It is suggested that the item path supplied has NODROP (and likely DROPDEL),
 * but nothing's preventing you from not having that.
 *
 * If they lose or gain hands, new mutant hands will be created immediately.
 *
 * Does not override nodrop items that already exist in hand slots.
 * However if those nodrop items are lost, will immediately create a new mutant hand.
 */
/datum/component/mutant_hands
	// First come, first serve
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// The item typepath that we insert into the parent's hands
	var/obj/item/mutant_hand_path = /obj/item/weapon/melee/zombie_hand

/datum/component/mutant_hands/Initialize(obj/item/mutant_hand_path = /obj/item/weapon/melee/zombie_hand)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/mutant_hands/RegisterWithParent()
	// Give them a hand before registering ANYTHING just so it's clean
	INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

	RegisterSignals(parent, list(COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB), PROC_REF(try_reapply_hands))
	RegisterSignal(parent, COMSIG_MOB_EQUIPPED, PROC_REF(mob_equipped_item))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(mob_dropped_item))

/datum/component/mutant_hands/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_CARBON_ATTACH_LIMB,
		COMSIG_CARBON_REMOVE_LIMB,
		COMSIG_MOB_EQUIPPED,
		COMSIG_ITEM_DROPPED,
	))

	// Remove all their hands after unregistering everything so they don't return
	INVOKE_ASYNC(src, PROC_REF(remove_mutant_hands))

/**
 * Tries to give the parent mob mutant hands.
 *
 * * If a hand slot is empty, places the mutanthand type into their hand.
 * * If a hand slot is filled with a nodrop item, it will do nothing.
 * * If a hand slot is filled with a non-nodrop item, drops the item to the ground.
 * * If a hand slot is filled with a hand already, does nothing.
 */
/datum/component/mutant_hands/proc/apply_mutant_hands()
	var/mob/living/carbon/human/H = parent
	H.drop_l_hand()
	H.drop_r_hand()
	H.equip_to_slot_or_del(new mutant_hand_path, SLOT_L_HAND)
	H.equip_to_slot_or_del(new mutant_hand_path, SLOT_R_HAND)

/**
 * Removes all mutant idems from the parent's hand slots
 */
/datum/component/mutant_hands/proc/remove_mutant_hands()
	var/mob/living/carbon/human/H = parent

	if(istype(H.l_hand, mutant_hand_path))
		qdel(H.l_hand)

	if(istype(H.r_hand, mutant_hand_path))
		qdel(H.r_hand)

/**
 * Signal proc for any signals that may result in the number of hands of the parent mob changing
 *
 * Always try to re-insert mutanthands if we gain or lose hands
 */
/datum/component/mutant_hands/proc/try_reapply_hands(datum/source)
	SIGNAL_HANDLER

	if(QDELING(src) || QDELING(parent))
		return

	INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

/**
 * Signal proc for [COMSIG_MOB_EQUIPPED_ITEM]
 *
 * This is a failsafe - the mob managed to pick up something that isn't a mutant hand
 */
/datum/component/mutant_hands/proc/mob_equipped_item(mob/living/carbon/human/source, obj/item/thing, slot)
	SIGNAL_HANDLER

	if(!(slot & (SLOT_L_HAND | SLOT_R_HAND))) // Who cares
		return

	if(istype(thing, mutant_hand_path)) // This is definitely meant to be here
		return

	if(thing.flags & (NODROP | ABSTRACT)) // This is meant to be here
		return

	// We equipped something to hands that wasn't a mutant hand, and wasn't abstract!
	// This means they're meant to have a mutant hand. So help them out.
	INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

/**
 * Signal proc for [COMSIG_MOB_UNEQUIPPED_ITEM]
 *
 * This is another failsafe - the mob dropped something, maybe from their hands, so try to re-equip
 */
/datum/component/mutant_hands/proc/mob_dropped_item(mob/living/carbon/human/source, obj/item/thing)
	SIGNAL_HANDLER

	if(QDELING(src) || QDELING(parent))
		return

	INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))
