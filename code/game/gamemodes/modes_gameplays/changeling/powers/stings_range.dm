/obj/effect/proc_holder/changeling/boost_range
	name = "Boost Range"
	desc = "We evolve the ability to shoot our stingers at humans."
	helptext = "Stings abilities can be used against targets 2 squares away."
	genomecost = 1
	chemical_cost = -1

/obj/effect/proc_holder/changeling/boost_range/on_purchase(mob/user)
	..()
	var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)
	changeling.sting_range++

/obj/effect/proc_holder/changeling/boost_range/Destroy()
	. = ..()
	role.sting_range--
