/obj/effect/proc_holder/borer/quick_chemicals
	name = "Chemical Production Cathalysis"
	desc = "Consumes host's nutrition to boost chemical production by 2 units per second."
	cost = 1
	requires_t = list(/obj/effect/proc_holder/borer/enlarged_glands)

/obj/effect/proc_holder/borer/quick_chemicals/on_gain(mob/living/simple_animal/borer/B)
	B.chemical_regeneration += 2
	B.nutrition_consumption += 1

/obj/effect/proc_holder/borer/quick_chemicals/on_lose(mob/living/simple_animal/borer/B)
	B.chemical_regeneration -= 2
	B.nutrition_consumption -= 1
