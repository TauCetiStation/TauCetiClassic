/obj/effect/proc_holder/changeling/boost_range
	name = "Повышенная Дистанция"
	desc = "Мы развиваем способность стрелять жалом в людей."
	helptext = "Способности жала можно будет использовать на расстоянии 2 тайлов."
	genomecost = 2
	chemical_cost = -1

/obj/effect/proc_holder/changeling/boost_range/on_purchase(mob/user)
	..()
	var/datum/changeling/changeling=user.mind.changeling
	changeling.sting_range = 2
	return
