#define ADVICE_TIP "Advice."

/datum/mechanic_tip/advice
	tip_name = ADVICE_TIP
	description = "HELP: brute = 0, agony = 1.5; PUSH: brute = 0.25, agony = 0.75; GRAB: brute = 0.5, agony = 0.25;HARM: brute = 1, agony = 0"

/datum/component/advice
	var/datum/callback/advice

/datum/component/advice/Initialize(datum/callback/_callback)
	var/datum/mechanic_tip/advice/advi_tip = new
	parent.AddComponent(/datum/component/mechanic_desc, list(advi_tip))

#undef ADVICE_TIP