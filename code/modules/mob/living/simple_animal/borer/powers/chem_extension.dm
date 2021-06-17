/obj/effect/proc_holder/borer/chem_extension
	var/chems = list()

/obj/effect/proc_holder/borer/chem_extension/on_gain(mob/living/simple_animal/borer/B)
	. = ..()
	B.synthable_chems |= chems

/obj/effect/proc_holder/borer/chem_extension/on_lose(mob/living/simple_animal/borer/B)
	. = ..()
	B.synthable_chems -= chems

/obj/effect/proc_holder/borer/chem_extension/advanced
	name = "Advanced Chemical Synthesis"
	desc = "Unlocks synthesis of oxycodone, kelotane and anti-toxin."
	chems = list("oxycodone" = 10, "kelotane" = 15, "anti_toxin" = 15)
	cost = 2

/obj/effect/proc_holder/borer/chem_extension/improved
	name = "Improved Chemical Synthesis"
	desc = "Unlocks synthesis of peridaxon, dexalin+ and dermaline."
	chems = list("peridaxon" = 10, "dexalinp" = 15, "dermaline" = 15)
	cost = 3
	requires_t = list(/obj/effect/proc_holder/borer/chem_extension/advanced)

/obj/effect/proc_holder/borer/chem_extension/improved
	name = "Sucrase Synthesis"
	desc = "Unlocks synthesis of sucrase, enzyme, that breaks down sugar."
	chems = list("sucrase" = 15)
	cost = 4
