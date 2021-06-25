/obj/effect/proc_holder/borer/enlarged_glands
	name = "Enlarged Chemical Glands"
	desc = "Grow size of you chemical storage by 100 units."
	cost = 3

/obj/effect/proc_holder/borer/enlarged_glands/on_gain()
	holder.max_chemicals += 100
