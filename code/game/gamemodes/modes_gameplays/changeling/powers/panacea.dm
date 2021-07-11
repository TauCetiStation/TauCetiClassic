/obj/effect/proc_holder/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form; curing diseases, genetic disabilities, and removing toxins and radiation."
	helptext = "Can be used while unconscious."
	chemical_cost = 25
	genomecost = 1
	req_stat = UNCONSCIOUS

//Heals the things that the other regenerative abilities don't.
/obj/effect/proc_holder/changeling/panacea/sting_action(mob/living/carbon/user)

	to_chat(user, "<span class='notice'>We cleanse impurities from our form.</span>")
	user.reagents.add_reagent("ryetalyn", 10)
	user.reagents.add_reagent("hyronalin", 10)
	user.reagents.add_reagent("anti_toxin", 20)

	if(user.virus2.len)
		for (var/ID in user.virus2)
			var/datum/disease2/disease/V = user.virus2[ID]
			V.cure(user)

	feedback_add_details("changeling_powers","AP")
	return 1
