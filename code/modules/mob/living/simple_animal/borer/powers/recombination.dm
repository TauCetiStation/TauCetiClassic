/obj/effect/proc_holder/borer/recombination
	name = "Recombination"
	desc = "Your offspring will have all your upgrades refunded."
	cost = 3

/obj/effect/proc_holder/borer/recombination/on_gain(mob/living/simple_animal/borer/B)
	B.recombinate = TRUE

/obj/effect/proc_holder/borer/recombination/on_lose(mob/living/simple_animal/borer/B)
	B.recombinate = FALSE
