// basic element to encapsulate mutation properties
// we can rework dna-related mutations with this in the future
// idea is that element should be enough to attach all needed actions, traits and other
// related components/elements to the mob, so we don't need other abstractions
// maybe it should not be a element, we will see
// also maybe need to merge it with /datum/component/mob_modifier

/datum/element/mutation
	var/list/traits = list()

/datum/element/mutation/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	for(var/trait in traits)
		ADD_TRAIT(target, trait, TRAIT_FROM_ELEMENT(src))

	on_gain(target)

/datum/element/mutation/Detach(datum/target)
	. = ..()

	for(var/trait in traits)
		REMOVE_TRAIT(target, trait, TRAIT_FROM_ELEMENT(src))

	on_loose(target)

/datum/element/mutation/proc/on_gain(mob/living/M)
	return

/datum/element/mutation/proc/on_loose(mob/living/M)
	return
