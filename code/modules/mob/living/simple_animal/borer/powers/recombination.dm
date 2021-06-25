/obj/effect/proc_holder/borer/recombination
	name = "Recombination"
	desc = "Your offspring will have all your upgrades refunded."
	cost = 3

/obj/effect/proc_holder/borer/recombination/on_gain()
	holder.recombinate = TRUE
