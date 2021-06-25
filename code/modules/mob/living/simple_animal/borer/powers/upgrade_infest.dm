/obj/effect/proc_holder/borer/upgrade_infest
	name = "Accelerated Infest"
	desc = "Doubles the infestation speed."
	cost = 2

/obj/effect/proc_holder/borer/upgrade_infest/on_gain()
	holder.infest_delay /= 2
