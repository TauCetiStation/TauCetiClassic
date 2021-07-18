/obj/effect/proc_holder/changeling/glands
	name = "Увеличение Химических Желез"
	desc = "Наши химические железы набухают, что позволяет нам накапливать в них больше химикатов."
	helptext = "Увеличивает максимальный объем химикатов на 25 единиц."
	genomecost = 2
	chemical_cost = -1

/obj/effect/proc_holder/changeling/glands/on_purchase(mob/user)
	..()
	var/datum/changeling/changeling=user.mind.changeling
	changeling.chem_storage += 25
	return
