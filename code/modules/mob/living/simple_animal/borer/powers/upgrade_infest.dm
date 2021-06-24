/obj/effect/proc_holder/borer/upgrade_infest
	name = "Accelerated Infest"
	desc = "Doubles the infestation speed."
	cost = 2

/obj/effect/proc_holder/borer/upgrade_infest/on_gain(mob/living/simple_animal/borer/B)
	..()
	B.infest_delay /= 2

/obj/effect/proc_holder/borer/upgrade_infest/on_lose(mob/living/simple_animal/borer/B)
	B.infest_delay *= 2
