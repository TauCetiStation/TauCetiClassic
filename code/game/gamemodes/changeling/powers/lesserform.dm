/obj/effect/proc_holder/changeling/lesserform
	name = "Меньшая форма"
	desc = "Мы уменьшаем себя в меньшую форму. Мы становимся обезьяной."
	chemical_cost = 5
	genomecost = 2
	genetic_damage = 30
	max_genetic_damage = 30
	req_human = 1

//Transform into a monkey.
/obj/effect/proc_holder/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(user.has_brain_worms())
		to_chat(user, "<span class='warning'>We cannot perform this ability at the present time!</span>")
		return
	if(user.restrained())
		to_chat(user,"<span class='warning'>We cannot perform this ability as you restrained!</span>")
		return

	user.visible_message("<span class='warning'>[user] transforms!</span>")
	to_chat(user, "<span class='warning'>Our genes cry out!</span>")

	user.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE)

	feedback_add_details("changeling_powers","LF")
	return 1
