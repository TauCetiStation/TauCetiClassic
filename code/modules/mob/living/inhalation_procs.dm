//procs called when some gas is inhaled. procs get living thing which inhaled the gas and breath air mix.

/datum/xgm_gas/proc/on_inhalation(/mob/living/carbon/C, /datum/gas_mixture/B)
	return

/datum/xgm_gas/bz/on_inhalation(/mob/living/carbon/C, /datum/gas_mixture/B)
	if(!B.gas[id])
		return
	var/P = (B.gas[id] / B.total_moles) * B.return_pressure()
	if(P > 1)
		C.hallucination += 1
		to_chat(C, "<span class='warning'>You feel like there is something strange in the air.</span>")
	if(P > 5)
		var/R = ischangeling(C)
		if(R)
			R.chem_storage -= 20
		C.hallucination += 3
		C.adjustToxLoss(1)
		C.adjustBrainLoss(1)
		C.poison_alert = TRUE
		if(prob(20))
			to_chat(C, "<span class='warning'>Your mind is tearing itself apart!</span>")

/datum/xgm_gas/constantium/on_inhalation(/mob/living/carbon/C, /datum/gas_mixture/B)
	if(!B.gas[id])
		return
	var/P = (B.gas[id] / B.total_moles) * B.return_pressure()
	if(P > 5)
		C.adjustOxyLoss(1)
		to_chat(C, "<span class='warning'>You feel like something in the air makes it harder to breathe.</span>")
	if(P > 10)
		C.adjustOxyLoss(10)
		C.Paralyse(3)
		C.inhale_alert = TRUE
		if(prob(20))
			to_chat(C, "<span class='warning'>You can't get enough oxygen!</span>")
			C.emote("cough")

/datum/xgm_gas/trioxium/on_inhalation(/mob/living/carbon/C, /datum/gas_mixture/B)
	if(!B.gas[id])
		return
	var/P = (B.gas[id] / B.total_moles) * B.return_pressure()
	if(P > 1)
		if(istype(C, /mob/living/carbon/human/vox))
			C.adjustToxLoss(3)
		else
			if(C.losebreath >= 10)
				C.losebreath = max(10, C.losebreath - 5)
			C.adjustOxyLoss(-3)
			to_chat(C, "<span class='notice'>You feel extra oxygen seeping into your lungs.</span>")
	if(P > 5)
		if(istype(C, /mob/living/carbon/human/vox))
			C.adjustToxLoss(10)
			C.poison_alert = TRUE
			if(prob(20))
				to_chat(C, "<span class='warning'>You feel oxygen rushing into your lungs! Find some fresh nitrogen!</span>")
				C.emote("cough")
		else
			C.adjustOxyLoss(-10)
			C.adjustToxLoss(1)
			if(prob(20))
				to_chat(C, "<span class='warning'>You feel oxygen rushing into your lungs. Maybe even TOO much oxygen.</span>")

/datum/xgm_gas/cardotirin/on_inhalation(/mob/living/carbon/C, /datum/gas_mixture/B)
	if(!B.gas[id])
		return
	var/P = (B.gas[id] / B.total_moles) * B.return_pressure()
	if(P > 10)
		to_chat(C, "<span class='notice'>You feel like something in the air soothes your wounds.</span>")
		if(prob(50))
			C.adjustBruteLoss(-1)
		else
			C.adjustFireLoss(-1)
		if(C.losebreath >= 10)
			C.losebreath = max(10, C.losebreath-5)
		C.drowsyness += 1
	if(P > 20)
		C.drowsyness += 3
		C.Weaken(1)
		if(prob(20))
			to_chat(C, "<span class='warning'>You want to sleep.</span>")
