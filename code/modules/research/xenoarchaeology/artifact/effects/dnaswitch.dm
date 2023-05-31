/datum/artifact_effect/dnaswitch
	log_name = "Dna Switch"
	type_name = ARTIFACT_EFFECT_ORGANIC
	var/severity

/datum/artifact_effect/dnaswitch/New()
	..()
	if(release_method == ARTIFACT_EFFECT_AURA)
		severity = rand(5,30)
	else
		severity = rand(25,95)

/datum/artifact_effect/dnaswitch/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	if(!ishuman(user))
		return
	roll_and_change_genes(user, 50, severity)

/datum/artifact_effect/dnaswitch/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/carbon/human/H in range(range, curr_turf))
		roll_and_change_genes(H, 50, severity)

/datum/artifact_effect/dnaswitch/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	for(var/mob/living/carbon/human/H in range(range, curr_turf))
		roll_and_change_genes(H, 20, severity)

/datum/artifact_effect/dnaswitch/proc/roll_and_change_genes(mob/receiver, chance, severity)
	var/weakness = get_anomaly_protection(receiver)
	if(!prob(weakness * 100))
		return
	if(prob(chance))
		scramble(1, receiver, weakness * severity)
	else
		scramble(0, receiver, weakness * severity)
	to_chat(receiver, pick("<span class='notice'>You feel a little different.</span>",
	"<span class='notice'>You feel very strange.</span>",
	"<span class='notice'>Your stomach churns.</span>",
	"<span class='notice'>Your skin feels loose.</span>",
	"<span class='notice'>You feel a stabbing pain in your head.</span>",
	"<span class='notice'>You feel a tingling sensation in your chest.</span>",
	"<span class='notice'>Your entire body vibrates.</span>"))

