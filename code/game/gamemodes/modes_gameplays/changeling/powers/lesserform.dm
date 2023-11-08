/obj/effect/proc_holder/changeling/lesserform
	name = "Lesser form"
	desc = "We debase ourselves and become lesser. We become a monkey."
	button_icon_state = "lesser_form"
	chemical_cost = 5
	genomecost = 1
	genetic_damage = 30
	max_genetic_damage = 30
	req_human = 1
	can_be_used_in_abom_form = FALSE

/obj/effect/proc_holder/changeling/lesserform/can_sting(mob/user)
	var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
	var/obj/effect/proc_holder/changeling/humanform/A = locate(/obj/effect/proc_holder/changeling/humanform) in C.purchasedpowers
	if(A)
		A.try_to_sting(user)
		return FALSE
	. = ..()

//Transform into a monkey.
/obj/effect/proc_holder/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(user.has_brain_worms())
		to_chat(user, "<span class='warning'>We cannot perform this ability at the present time!</span>")
		return FALSE
	if(user.restrained())
		to_chat(user,"<span class='warning'>We cannot perform this ability as you restrained!</span>")
		return FALSE

	user.visible_message("<span class='warning'>[user] transforms!</span>")
	to_chat(user, "<span class='warning'>Our genes cry out!</span>")

	user.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE)

	feedback_add_details("changeling_powers","LF")
	return TRUE
