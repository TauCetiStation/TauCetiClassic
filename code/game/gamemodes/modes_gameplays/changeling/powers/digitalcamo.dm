/obj/effect/proc_holder/changeling/digitalcamo
	name = "Digital Camouflage"
	desc = "By evolving the ability to distort our form and proprotions, we defeat common altgorithms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera while using this skill. However, humans looking at us will find us... uncanny. We must constantly expend chemicals to maintain our form like this."
	button_icon_state = "digital_camo"
	genomecost = 1
	var/active = FALSE

//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/obj/effect/proc_holder/changeling/digitalcamo/sting_action(mob/user)
	if(active)
		to_chat(user, "<span class='notice'>We return to normal.</span>")
		user.RemoveElement(/datum/element/digitalcamo)
	else
		to_chat(user, "<span class='notice'>We distort our form to prevent AI-tracking.</span>")
		user.AddElement(/datum/element/digitalcamo)
	active = !active

	feedback_add_details("changeling_powers","CAM")
	return TRUE

/obj/effect/proc_holder/changeling/digitalcamo/Destroy()
	. = ..()
	RemoveElement(/datum/element/digitalcamo)
