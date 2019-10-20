/obj/effect/proc_holder/changeling/lesserform
	name = "Lesser form"
	desc = "We debase ourselves and become lesser. We become a monkey."
	chemical_cost = 5
	genomecost = 2
	genetic_damage = 30
	max_genetic_damage = 30
	req_human = 1

//Transform into a monkey.
/obj/effect/proc_holder/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	var/datum/changeling/changeling = user.mind.changeling

	if(user.has_brain_worms())
		to_chat(user, "<span class='warning'>We cannot perform this ability at the present time!</span>")
		return
	if(user.restrained())
		to_chat(user,"<span class='warning'>We cannot perform this ability as you restrained!</span>")
		return

	user.visible_message("<span class='warning'>[user] transforms!</span>")
	to_chat(user, "<span class='warning'>Our genes cry out!</span>")

	var/list/implants = list() //Try to preserve implants.
	for(var/obj/item/weapon/implant/W in user)
		implants += W

	user.monkeyizing = 1
	user.canmove = 0
	user.icon = null
	user.overlays.Cut()
	user.invisibility = 101

	var/atom/movable/overlay/animation = new /atom/movable/overlay( user.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48)
	qdel(animation)

	var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey(user.loc)
	O.dna = user.dna.Clone()
	user.dna = null

	for(var/obj/item/W in user)
		user.drop_from_inventory(W)
	for(var/obj/T in user)
		qdel(T)

	O.loc = user.loc
	O.name = "monkey ([copytext(md5(user.real_name), 2, 5)])"
	O.setToxLoss(user.getToxLoss())
	O.adjustBruteLoss(user.getBruteLoss())
	O.setOxyLoss(user.getOxyLoss())
	O.adjustFireLoss(user.getFireLoss())
	O.stat = user.stat
	O.a_intent = "hurt"
	for(var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O

		//transfer mind and delete old mob
	if(user.mind)
		user.mind.transfer_to(O)
		if(O.mind.changeling)
			O.mind.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
			O.changeling_update_languages(changeling.absorbed_languages)
			for(var/mob/living/parasite/essence/M in user)
				M.transfer(O)
	. = O
	feedback_add_details("changeling_powers","LF")
	qdel(user)
	return 1

