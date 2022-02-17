/datum/quality
	var/desc

	var/restriction

/datum/quality/proc/restriction_check(mob/living/carbon/human/H)
	return TRUE

/datum/quality/proc/add_effect(mob/living/carbon/human/H)
	return

/datum/quality/test
	desc = "Write 'lol' in chat after quirks"

	restriction = "Dont be a dick"

/datum/quality/test/restriction_check(mob/living/carbon/human/H)
	to_chat(H, "I believe you are not a dick")
	return TRUE

/datum/quality/test/add_effect(mob/living/carbon/human/H)
	to_chat(H, "lol")

