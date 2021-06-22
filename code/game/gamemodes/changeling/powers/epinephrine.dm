/obj/effect/proc_holder/changeling/epinephrine
	name = "Адреналиновая Передозировка"
	desc = "Мы отращиваем железы, вырабатывающие адреналин."
	helptext = "Мнгновенно впрыскивает накопленный адреналин, позволяя вам сбросить кратковременное оглушение. Частое использование будет отравлять организм."
	chemical_cost = 30
	genomecost = 3
	req_human = 1
	req_stat = UNCONSCIOUS

//Recover from stuns.
/obj/effect/proc_holder/changeling/epinephrine/sting_action(mob/user)

	if(user.lying)
		to_chat(user, "<span class='notice'>We arise.</span>")
	else
		to_chat(user, "<span class='notice'>Adrenaline rushes through us.</span>")
	user.stat = CONSCIOUS
	user.SetParalysis(0)
	user.SetStunned(0)
	user.SetWeakened(0)
	user.lying = 0
	user.update_canmove()
	user.reagents.add_reagent("synaptizine", 0.5)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.halloss = 0
		H.shock_stage = 0

	feedback_add_details("changeling_powers","UNS")
	return 1
