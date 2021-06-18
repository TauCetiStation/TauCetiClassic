/obj/effect/proc_holder/borer/enlarged_glands
	name = "Enlarged Chemical Glands"
	desc = "Grow size of you chemical storage by 100 units."
	cost = 3

/obj/effect/proc_holder/borer/enlarged_glands/on_gain(mob/living/simple_animal/borer/B)
	B.max_chemicals += 100

/obj/effect/proc_holder/borer/enlarged_glands/on_lose(mob/living/simple_animal/borer/B)
	var/chem_part = B.chemicals / B.max_chemicals
	B.max_chemicals -= 100
	// we lose some chemicals that were stored in those glands
	B.chemicals = round(chem_part * B.max_chemicals)
