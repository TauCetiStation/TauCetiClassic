/obj/effect/proc_holder/borer/active/control/reproduce
	name = "Reproduce"
	desc = "Spawn several young."
	chemicals = 100

/obj/effect/proc_holder/borer/active/control/reproduce/activate(mob/living/carbon/user)
	var/mob/living/simple_animal/borer/B = user.has_brain_worms()
	if(!B || !..())
		return
	B.reproduce()

/mob/living/simple_animal/borer/proc/reproduce()
	reproduced++
	upgrade_points += 1

	to_chat(host, "<span class='danger'>Your host twitches and quivers as you rapdly excrete several larvae from your sluglike body.</span>")
	host.vomit()
	var/mob/living/simple_animal/borer/offspring = new /mob/living/simple_animal/borer(host.loc, TRUE, generation + 1, upgrades)
	return offspring
