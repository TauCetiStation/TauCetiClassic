/datum/reagent/drug
// a drug reagent is something that makes a peron under its effect comply

/datum/reagent/drug/space_drugs
	name = "Space drugs"
	id = "space_drugs"
	description = "An illegal chemical compound used as drug."
	reagent_state = LIQUID
	color = "#60a584" // rgb: 96, 165, 132
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)

/datum/reagent/drug/space_drugs/on_general_digest(mob/living/M)
	..()
	M.adjustDrugginess(2)
	if(isturf(M.loc) && !isspaceturf(M.loc))
		if(M.canmove && !M.incapacitated())
			if(prob(10))
				step(M, pick(cardinal))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))

/datum/reagent/drug/serotrotium
	name = "Serotrotium"
	id = "serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	reagent_state = LIQUID
	color = "#202040" // rgb: 20, 20, 40
	custom_metabolism = REAGENTS_METABOLISM * 0.25
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)

/datum/reagent/drug/serotrotium/on_general_digest(mob/living/M)
	..()
	if(ishuman(M))
		if(prob(7))
			M.emote(pick("twitch","drool","moan","gasp"))

/datum/reagent/drug/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	description = "Cryptobiolin causes confusion and dizzyness."
	reagent_state = LIQUID
	color = "#000055" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/drug/cryptobiolin/on_general_digest(mob/living/M)
	..()
	M.make_dizzy(1)
	M.MakeConfused(20)

/datum/reagent/drug/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	reagent_state = LIQUID
	color = "#c8a5dc" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)

/datum/reagent/drug/impedrezene/on_general_digest(mob/living/M)
	..()
	M.jitteriness = max(M.jitteriness - 5, 0)
	if(prob(80))
		M.adjustBrainLoss(1 * REM)
	if(prob(50))
		M.drowsyness = max(M.drowsyness, 3)
	if(prob(10))
		M.emote("drool")

/datum/reagent/drug/mindbreaker
	name = "Mindbreaker Toxin"
	id = "mindbreaker"
	description = "A powerful hallucinogen, it can cause fatal effects in users."
	reagent_state = LIQUID
	color = "#b31008" // rgb: 139, 166, 233
	custom_metabolism = 0.05
	overdose = REAGENTS_OVERDOSE
	flags = list()

/datum/reagent/drug/mindbreaker/on_general_digest(mob/living/M)
	..()
	M.hallucination += 10
