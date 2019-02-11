/obj/effect/proc_holder/changeling/digitalcamo
	name = "Digital Camouflage"
	desc = "By evolving the ability to distort our form and proprotions, we defeat common altgorithms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera while using this skill. However, humans looking at us will find us... uncanny. We must constantly expend chemicals to maintain our form like this."
	genomecost = 1

//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/obj/effect/proc_holder/changeling/digitalcamo/sting_action(mob/user)

	if(user.digitalcamo)
		to_chat(user, "<span class='notice'>We return to normal.</span>")
		for(var/mob/living/silicon/ai/AI in ai_list)
			if(AI.client)
				AI.client.images -= user.digitaldisguise
	else
		to_chat(user, "<span class='notice'>We distort our form to prevent AI-tracking.</span>")
		user.digitaldisguise = image(loc = user)
		user.digitaldisguise.override = 1
		for(var/mob/living/silicon/ai/AI in ai_list)
			if(AI.client)
				AI.client.images += user.digitaldisguise
	user.digitalcamo = !user.digitalcamo

	spawn(0)
		while(user && user.digitalcamo && user.mind && user.mind.changeling)
			user.mind.changeling.chem_charges = max(user.mind.changeling.chem_charges - 1, 0)
			sleep(40)

	feedback_add_details("changeling_powers","CAM")
	return 1