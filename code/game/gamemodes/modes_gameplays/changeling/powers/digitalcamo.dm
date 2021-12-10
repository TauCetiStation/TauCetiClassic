/obj/effect/proc_holder/changeling/digitalcamo
	name = "Digital Camouflage"
	desc = "By evolving the ability to distort our form and proprotions, we defeat common altgorithms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera while using this skill. However, humans looking at us will find us... uncanny. We must constantly expend chemicals to maintain our form like this."
	genomecost = 1

//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/obj/effect/proc_holder/changeling/digitalcamo/sting_action(mob/user)
	if(user.digitalcamo)
		to_chat(user, "<span class='notice'>We return to normal.</span>")
		for(var/mob/living/silicon/ai/AI as anything in ai_list)
			if(AI.client)
				AI.client.images -= user.digitaldisguise
		UnhideFromAIHuds(user)
	else
		to_chat(user, "<span class='notice'>We distort our form to prevent AI-tracking.</span>")
		user.digitaldisguise = image(loc = user)
		user.digitaldisguise.override = 1
		for(var/mob/living/silicon/ai/AI as anything in ai_list)
			if(AI.client)
				AI.client.images += user.digitaldisguise
		HideFromAIHuds(user)
	user.digitalcamo = !user.digitalcamo

	spawn(0)
		var/datum/role/changeling/C = user.mind.GetRoleByType(/datum/role/changeling)
		while(user && user.digitalcamo && C)
			C.chem_charges = max(C.chem_charges - 1, 0)
			sleep(40)

	feedback_add_details("changeling_powers","CAM")
	return 1

/obj/effect/proc_holder/changeling/digitalcamo/proc/HideFromAIHuds(mob/living/target)
	for(var/mob/living/silicon/ai/AI in global.ai_list)
		var/datum/atom_hud/M = global.huds[DATA_HUD_MEDICAL]
		M.hide_single_atomhud_from(AI, target)
		var/datum/atom_hud/S = global.huds[DATA_HUD_SECURITY]
		S.hide_single_atomhud_from(AI, target)

/obj/effect/proc_holder/changeling/digitalcamo/proc/UnhideFromAIHuds(mob/living/target)
	for(var/mob/living/silicon/ai/AI in global.ai_list)
		var/datum/atom_hud/M = global.huds[DATA_HUD_MEDICAL]
		M.unhide_single_atomhud_from(AI, target)
		var/datum/atom_hud/S = global.huds[DATA_HUD_SECURITY]
		S.unhide_single_atomhud_from(AI, target)
