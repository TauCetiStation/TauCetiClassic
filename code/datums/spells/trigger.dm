/obj/effect/proc_holder/spell/targeted/trigger
	name = "Trigger"
	desc = "This spell triggers another spell or a few."

	var/list/linked_spells = list() //those are just referenced by the trigger spell and are unaffected by it directly
	var/list/starting_spells = list() //those are added on New() to contents from default spells and are deleted when the trigger spell is deleted to prevent memory leaks

/obj/effect/proc_holder/spell/targeted/trigger/atom_init()
	. = ..()

	for(var/spell_type in starting_spells)
		new spell_type(src)

/obj/effect/proc_holder/spell/targeted/trigger/Destroy()
	for(var/spell in contents)
		qdel(spell)
	return ..()

/obj/effect/proc_holder/spell/targeted/trigger/cast(list/targets)
	for(var/mob/living/target in targets)
		for(var/obj/effect/proc_holder/spell/spell in contents)
			spell.perform(list(target),0)
		for(var/obj/effect/proc_holder/spell/spell in linked_spells)
			spell.perform(list(target),0)

	return
