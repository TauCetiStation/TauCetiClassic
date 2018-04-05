/obj/effect/proc_holder/changeling/humanform
	name = "Human form"
	desc = "We change into a human."
	chemical_cost = 5
	genetic_damage = 20
//	req_dna = 1
	max_genetic_damage = 20

/obj/effect/proc_holder/changeling/humanform/sting_action(mob/living/carbon/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)	return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	user.visible_message("<span class='warning'>[user] transforms!</span>")
	user.dna = chosen_dna.Clone()

	var/list/implants = list()
	for (var/obj/item/weapon/implant/I in user) //Still preserving implants
		implants += I

	user.monkeyizing = 1
	user.canmove = 0
	user.icon = null
	user.overlays.Cut()
	user.invisibility = 101
	var/atom/movable/overlay/animation = new /atom/movable/overlay( user.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("monkey2h", animation)
	sleep(48)
	qdel(animation)

	for(var/obj/item/W in user)
		user.drop_from_inventory(W)
	for(var/obj/T in user)
		qdel(T)

	var/mob/living/carbon/human/O = new /mob/living/carbon/human( src )
	if (user.dna.GetUIState(DNA_UI_GENDER))
		O.gender = FEMALE
	else
		O.gender = MALE
	O.dna = user.dna.Clone()
	user.dna = null
	O.real_name = chosen_dna.real_name

	for(var/obj/T in user)
		qdel(T)

	O.loc = user.loc

	O.UpdateAppearance()
	domutcheck(O, null)
	O.setToxLoss(user.getToxLoss())
	O.adjustBruteLoss(user.getBruteLoss())
	O.setOxyLoss(user.getOxyLoss())
	O.adjustFireLoss(user.getFireLoss())
	O.stat = user.stat
	for (var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O

	if(user.mind)
		user.mind.transfer_to(O)
	for(var/mob/living/parasite/essence/M in user)
		M.transfer(O)
	O.changeling_update_languages(changeling.absorbed_languages)


	feedback_add_details("changeling_powers","LFT")
	qdel(user)
	O.mind.changeling.purchasedpowers -= src
	return 1
