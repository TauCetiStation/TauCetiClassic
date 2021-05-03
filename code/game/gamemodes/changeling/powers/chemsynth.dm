/obj/effect/proc_holder/changeling/chemicalsynth
	name = "Ускоренный Синтез Химикатов."
	desc = "Мы разрабатываем новые способы производства необходимых нам химикатов, что позволяет нам естественным образом создавать их быстрее."
	helptext = "Удваивает скорость восстановления химикатов."
	genomecost = 2
	chemical_cost = -1

/obj/effect/proc_holder/changeling/chemicalsynth/on_purchase(mob/user)
	..()
	var/datum/changeling/changeling=user.mind.changeling
	changeling.chem_recharge_rate *= 2
	return
