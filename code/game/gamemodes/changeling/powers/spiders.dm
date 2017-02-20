/obj/effect/proc_holder/changeling/spiders
	name = "Spread Infestation"
	desc = "Our form divides, creating arachnids which will grow into deadly beasts."
	helptext = "The spiders are thoughtless creatures, and may attack their creators when fully grown. Requires at least 4 DNA absorptions."
	chemical_cost = 30
	genomecost = 3
	req_dna = 4

//Makes some spiderlings. Good for setting traps and causing general trouble.
/obj/effect/proc_holder/changeling/spiders/sting_action(mob/user)
	var/turf = get_turf(user)
	for(var/I in 1 to 2)
		var/obj/effect/spider/spiderling/Sp = new(turf)
		Sp.amount_grown = 1

	feedback_add_details("changeling_powers","SI")
	return 1
