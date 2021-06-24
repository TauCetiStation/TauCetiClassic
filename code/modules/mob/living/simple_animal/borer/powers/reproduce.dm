/obj/effect/proc_holder/borer/active/control/reproduce
	name = "Reproduce"
	desc = "Spawn several young."
	chemicals = 100
	check_capability = FALSE

/obj/effect/proc_holder/borer/active/control/reproduce/activate()
	if(!use_chemicals())
		return
	holder.reproduce()

/mob/living/simple_animal/borer/proc/reproduce()
	reproduced++
	upgrade_points += 1

	to_chat(host, "<span class='danger'>Your host twitches and quivers as you rapdly excrete several larvae from your sluglike body.</span>")
	host.vomit()
	var/mob/living/simple_animal/borer/offspring
	
	// if we recombinate, our children will have no our upgrades, but rather they will have all the points that we've spent
	if(recombinate)
		var/total_points = 1 // give them one more point than we have spent
		for(var/obj/effect/proc_holder/borer/U in upgrades)
			total_points += U.cost
		offspring = new /mob/living/simple_animal/borer(host.loc, TRUE, generation + 1, total_points)
	else
		offspring = new /mob/living/simple_animal/borer(host.loc, TRUE, generation + 1, 1, upgrades)
	return offspring
