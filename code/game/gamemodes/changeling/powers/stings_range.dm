/obj/effect/proc_holder/changeling/boost_range
	name = "Boost Range"
	desc = "We evolve the ability to shoot our stingers at humans."
	helptext = "Stings abilities can be used against targets 2 squares away."
	genomecost = 2
	chemical_cost = -1

/obj/effect/proc_holder/changeling/boost_range/on_purchase(mob/user)
	..()
	var/datum/changeling/changeling=user.mind.changeling
	changeling.sting_range = 2
	return
