/obj/effect/proc_holder/changeling/mimicvoice
	name = "Фальшивый Голос"
	desc = "Формирует наши голосовые связки так, что мы будем полностью копировать голос совершенно другого человека."
	helptext = "Позволяет вам говорить голосом того, кого вы захотите, достаточно просто ввести имя. Требует постоянного расхода химикатов, пока включено."
	chemical_cost = 0 //constant chemical drain hardcoded
	genomecost = 1
	req_human = 1

// Fake Voice
/obj/effect/proc_holder/changeling/mimicvoice/sting_action(mob/user)
	var/datum/changeling/changeling=user.mind.changeling
	if(changeling.mimicing)
		changeling.mimicing = ""
		changeling.chem_recharge_slowdown -= 0.25
		to_chat(user, "<span class='notice'>We return our vocal glands to their original position.</span>")
		return

	var/mimic_voice = sanitize_safe(input("Enter a name to mimic.", "Mimic Voice", null) as text, MAX_NAME_LEN)
	if(!mimic_voice)
		return

	changeling.mimicing = mimic_voice
	changeling.chem_recharge_slowdown += 0.25
	to_chat(user, "<span class='notice'>We shape our glands to take the voice of <b>[mimic_voice]</b>, this will stop us from regenerating chemicals while active.</span>")
	to_chat(user, "<span class='notice'>Use this power again to return to our original voice and reproduce chemicals again.</span>")

	feedback_add_details("changeling_powers","MV")

