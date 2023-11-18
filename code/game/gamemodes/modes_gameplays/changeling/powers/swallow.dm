/obj/effect/proc_holder/changeling/devour
	name = "Devour"
	desc = "Devour our prey whole."
	button_icon_state = "gib"
	chemical_cost = 30
	genomecost = 0
	max_genetic_damage = 100

/obj/effect/proc_holder/changeling/devour/can_sting(mob/living/carbon/user)
	if(!..())
		return FALSE
	if(HAS_TRAIT_FROM(user, TRAIT_CHANGELING_ABSORBING, GENERIC_TRAIT))
		to_chat(user, "<span class='warning'>We are already devouring!</span>")
		return FALSE

	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(!istype(G))
		to_chat(user, "<span class='warning'>We must be grabbing a creature in our active hand to devour them.</span>")
		return FALSE
	if(G.state <= GRAB_AGGRESSIVE)
		to_chat(user, "<span class='warning'>We must have a tighter grip to devour this creature.</span>")
		return FALSE

	var/mob/living/carbon/target = G.affecting
	if(!istype(target))
		return FALSE
	if(target.stat != DEAD)
		to_chat(user, "<span class='warning'>[target] is alive! Kill him!</span>")
		return FALSE

	if(!ishuman(target))
		to_chat(user, "<span class='warning'>[target] is too simple for devour.</span>")
		return FALSE
	var/mob/living/carbon/human/T = target
	if(T.species.flags[IS_SYNTHETIC] || T.species.flags[IS_PLANT])
		to_chat(user, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return FALSE
	if(T.species.flags[NO_SCAN])
		to_chat(user, "<span class='warning'>We do not know how to digest this creature!</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/changeling/devour/sting_action(mob/living/user)
	var/obj/item/weapon/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting
	ADD_TRAIT(user, TRAIT_CHANGELING_ABSORBING, GENERIC_TRAIT)
	feedback_add_details("changeling_powers","S")
	if(!do_mob(user, target, 15 SECONDS))
		to_chat(user, "<span class='warning'>Our devour of [target] has been interrupted!</span>")
		REMOVE_TRAIT(user, TRAIT_CHANGELING_ABSORBING, GENERIC_TRAIT)
		return FALSE
	user.visible_message("<span class='danger'>[user] devours [target]!</span>",
	                     "<span class='notice'>We have devour [target]!</span>")
	to_chat(target, "<span class='danger'>You have been devoured by the changeling!</span>")
	for(var/obj/item/I in target)
		target.drop_from_inventory(I)
	target.spawn_gibs()
	qdel(target)
	REMOVE_TRAIT(user, TRAIT_CHANGELING_ABSORBING, GENERIC_TRAIT)
	return TRUE
