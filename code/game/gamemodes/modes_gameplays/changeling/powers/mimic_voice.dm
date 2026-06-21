/obj/effect/proc_holder/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice."
	helptext = "Will turn your voice into the name that you enter. We must constantly expend chemicals to maintain our form like this."
	button_icon_state = "shapeshift"
	chemical_cost = 0 //constant chemical drain hardcoded
	genomecost = 1
	req_human = 1
	var/slowdown_applied = FALSE

/obj/effect/proc_holder/changeling/mimicvoice/on_purchase(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	role = user.mind.GetRoleByType(/datum/role/changeling)
	action = new /datum/action/innate/changeling/mimicvoice(user)
	action.name = name
	action.target = src
	action.Grant(user)

/datum/action/innate/changeling/mimicvoice
	name = "Mimic Voice"
	button_icon = 'icons/hud/actions.dmi'
	background_icon_state = "bg_default"
	button_icon_state = "shapeshift"

// Fake Voice
/obj/effect/proc_holder/changeling/mimicvoice/sting_action(mob/user)
	var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)
	if(changeling.mimicing)
		changeling.mimicing = ""
		if(slowdown_applied)
			changeling.chem_recharge_slowdown -= 0.25
			slowdown_applied = FALSE
		to_chat(user, "<span class='notice'>We return our vocal glands to their original position.</span>")
		return FALSE

	var/mimic_voice = sanitize_safe(input("Enter a name to mimic.", "Mimic Voice", null) as text, MAX_NAME_LEN)
	if(!mimic_voice)
		return FALSE

	changeling.mimicing = mimic_voice
	if(!slowdown_applied)
		changeling.chem_recharge_slowdown += 0.25
		slowdown_applied = TRUE
	to_chat(user, "<span class='notice'>We shape our glands to take the voice of <b>[mimic_voice]</b>, this will stop us from regenerating chemicals while active.</span>")
	to_chat(user, "<span class='notice'>Use this power again to return to our original voice and reproduce chemicals again.</span>")

	feedback_add_details("changeling_powers","MV")
	return FALSE

/obj/effect/proc_holder/changeling/mimicvoice/Destroy()
	SHOULD_CALL_PARENT(TRUE)
	if(role && slowdown_applied)
		role.chem_recharge_slowdown -= 0.25
		slowdown_applied = FALSE
	return ..()
