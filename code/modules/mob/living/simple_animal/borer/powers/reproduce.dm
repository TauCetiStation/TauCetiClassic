/obj/effect/proc_holder/borer/active/control/reproduce
	name = "Reproduce"
	desc = "Spawn several young."
	chemicals = 100

/obj/effect/proc_holder/borer/active/control/reproduce/activate(mob/living/carbon/user)
	var/mob/living/simple_animal/borer/B = user.has_brain_worms()
	if(!B || !..())
		return

	B.reproduced++
	B.upgrade_points += 1

	to_chat(user, "<span class='danger'>Your host twitches and quivers as you rapdly excrete several larvae from your sluglike body.</span>")
	user.vomit()
	new /mob/living/simple_animal/borer(user.loc, TRUE, B.generation + 1)
