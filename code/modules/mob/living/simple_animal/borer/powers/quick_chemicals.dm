/obj/effect/proc_holder/borer/quick_chemicals
	name = "Chemical Production Catalysis"
	desc = "Consumes host's nutrition to boost chemical production by 0.5 units per second."
	cost = 1
	requires_t = list(/obj/effect/proc_holder/borer/enlarged_glands)

/obj/effect/proc_holder/borer/quick_chemicals/on_gain()
	holder.chemical_regeneration += 1
	holder.nutrition_consumption += 1
