/mob/living/simple_animal/heretic_summon/ash_spirit
	name = "\improper Ash Spirit"
	real_name = "Ashy"
	desc = "A manifestation of ash, trailing a perpetual cloud of short-lived cinders."
	icon_state = "ash_walker"
	icon_living = "ash_walker"
	maxHealth = 75
	health = 75
	melee_damage = 20
	sight = SEE_TURFS

/mob/living/simple_animal/heretic_summon/ash_spirit/atom_init()
	. = ..()
	var/static/list/actions_to_add = list(
		/obj/effect/proc_holder/spell/fire_sworn,
		/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/ash,
		/obj/effect/proc_holder/spell/pointed/cleave,
	)
	grant_actions_by_list(actions_to_add)
