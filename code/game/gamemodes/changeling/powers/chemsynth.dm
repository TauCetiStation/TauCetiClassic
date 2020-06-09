/obj/effect/proc_holder/changeling/chemicalsynth
	name = "Rapid Chemical-Synthesis"
	desc = "We evolve new pathways for producing our necessary chemicals, permitting us to naturally create them faster."
	helptext = "Doubles the rate at which we naturally recharge chemicals."
	genomecost = 2
	chemical_cost = -1

/obj/effect/proc_holder/changeling/chemicalsynth/on_purchase(mob/user)
	..()
	var/datum/changeling/changeling=user.mind.changeling
	changeling.chem_recharge_rate *= 2
	return
