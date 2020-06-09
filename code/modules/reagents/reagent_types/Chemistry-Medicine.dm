/datum/reagent/srejuvenate
	name = "Soporific Rejuvenant"
	id = "stoxin2"
	description = "Put people to sleep, and heals them."
	reagent_state = LIQUID
	color = "#c8a5dc" // rgb: 200, 165, 220
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)

	data = list()

/datum/reagent/srejuvenate/on_general_digest(mob/living/M)
	..()
	if(M.losebreath >= 10)
		M.losebreath = max(10, M.losebreath-10)
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	switch(data["ticks"])
		if(1 to 15)
			M.eye_blurry = max(M.eye_blurry, 10)
		if(15 to 25)
			M.drowsyness  = max(M.drowsyness, 20)
		if(25 to INFINITY)
			M.SetSleeping(20 SECONDS)
			M.adjustOxyLoss(-M.getOxyLoss())
			M.SetWeakened(0)
			M.SetStunned(0)
			M.SetParalysis(0)
			M.dizziness = 0
			M.drowsyness = 0
			M.stuttering = 0
			M.confused = 0
			M.jitteriness = 0

/datum/reagent/inaprovaline
	name = "Inaprovaline"
	id = "inaprovaline"
	description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
	reagent_state = LIQUID
	color = "#00bfff" // rgb: 200, 165, 220
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	overdose = REAGENTS_OVERDOSE * 2
	restrict_species = list(IPC, DIONA)

/datum/reagent/inaprovaline/on_general_digest(mob/living/M)
	..()
	if(M.losebreath >= 10)
		M.losebreath = max(10, M.losebreath-5)

/datum/reagent/inaprovaline/on_vox_digest(mob/living/M)
	..()
	M.adjustToxLoss(REAGENTS_METABOLISM)
	return FALSE // General digest proc shouldn't be called.

/datum/reagent/ryetalyn
	name = "Ryetalyn"
	id = "ryetalyn"
	description = "Ryetalyn can cure all genetic abnomalities via a catalytic process."
	reagent_state = SOLID
	color = "#004000" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	custom_metabolism = 2 * REAGENTS_METABOLISM

	data = list()

/datum/reagent/ryetalyn/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1

	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(!prob(REM * data["ticks"]))
			continue
		M.dna.SetSEValue(gene.block, rand(1,2048))
		genemutcheck(M, gene.block, null, MUTCHK_FORCED)

	data["ticks"]++

/datum/reagent/paracetamol
	name = "Paracetamol"
	id = "paracetamol"
	description = "Most probably know this as Tylenol, but this chemical is a mild, simple painkiller."
	reagent_state = LIQUID
	color = "#c8a5dc"
	overdose = 60
	restrict_species = list(IPC, DIONA)

/datum/reagent/paracetamol/on_general_digest(mob/living/M)
	..()
	if(volume > overdose)
		M.hallucination = max(M.hallucination, 2)

/datum/reagent/tramadol
	name = "Tramadol"
	id = "tramadol"
	description = "A simple, yet effective painkiller."
	reagent_state = LIQUID
	color = "#cb68fc"
	overdose = 30
	custom_metabolism = 0.025
	restrict_species = list(IPC, DIONA)

/datum/reagent/tramadol/on_general_digest(mob/living/M)
	..()
	if(volume > overdose)
		M.hallucination = max(M.hallucination, 2)

/datum/reagent/oxycodone
	name = "Oxycodone"
	id = "oxycodone"
	description = "An effective and very addictive painkiller."
	reagent_state = LIQUID
	color = "#800080"
	overdose = 20
	custom_metabolism = 0.025
	restrict_species = list(IPC, DIONA)

/datum/reagent/oxycodone/on_general_digest(mob/living/M)
	..()
	if(volume > overdose)
		M.druggy = max(M.druggy, 10)
		M.hallucination = max(M.hallucination, 3)

/datum/reagent/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	reagent_state = LIQUID
	color = "#c8a5dc" // rgb: 200, 165, 220

	//makes you squeaky clean
/datum/reagent/sterilizine/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH)
		M.germ_level -= min(volume*20, M.germ_level)

/datum/reagent/sterilizine/reaction_obj(obj/O, volume)
	O.germ_level -= min(volume*20, O.germ_level)

/datum/reagent/sterilizine/reaction_turf(turf/T, volume)
	. = ..()
	T.germ_level -= min(volume*20, T.germ_level)

/datum/reagent/leporazine
	name = "Leporazine"
	id = "leporazine"
	description = "Leporazine can be use to stabilize an individuals body temperature."
	reagent_state = LIQUID
	color = "#c8a5dc" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/leporazine/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature > BODYTEMP_NORMAL)
		M.bodytemperature = max(BODYTEMP_NORMAL, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(BODYTEMP_NORMAL, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/kelotane
	name = "Kelotane"
	id = "kelotane"
	description = "Kelotane is a drug used to treat burns."
	reagent_state = LIQUID
	color = "#ffc600" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/kelotane/on_general_digest(mob/living/M)
	..()
	M.heal_bodypart_damage(0,2 * REM)

/datum/reagent/dermaline
	name = "Dermaline"
	id = "dermaline"
	description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
	reagent_state = LIQUID
	color = "#ff8000" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE * 0.5
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/dermaline/on_general_digest(mob/living/M)
	..()
	M.heal_bodypart_damage(0,3 * REM)
	if(volume >= overdose && (HUSK in M.mutations) && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.mutations.Remove(HUSK)
		H.update_body()

/datum/reagent/dexalin
	name = "Dexalin"
	id = "dexalin"
	description = "Dexalin is used in the treatment of oxygen deprivation."
	reagent_state = LIQUID
	color = "#0080ff" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	taste_message = "oxygen"
	restrict_species = list(IPC, DIONA)

/datum/reagent/dexalin/on_general_digest(mob/living/M)
	..()
	M.adjustOxyLoss(-2 * REM)

	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2 * REM)

/datum/reagent/dexalin/on_vox_digest(mob/living/M, alien) // Now dexalin does not remove lexarin from Vox. For the better or the worse.
	..()
	M.adjustToxLoss(2 * REM)
	return FALSE

/datum/reagent/dextromethorphan
	name = "Dextromethorphan"
	id = "dextromethorphan"
	description = "Analgesic chemical that heals lung damage and coughing."
	reagent_state = LIQUID
	color = "#ffc0cb" // rgb: 255, 192, 203
	overdose = 10
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	taste_message = "sickening bitterness"
	restrict_species = list(IPC, DIONA)

	data = list()

/datum/reagent/dextromethorphan/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	M.adjustOxyLoss(-M.getOxyLoss())
	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2 * REM)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/lungs/IO = H.organs_by_name[O_LUNGS]
		if(istype(IO))
			if(IO.damage > 0 && IO.robotic < 2)
				IO.damage = max(IO.damage - 0.7, 0)
		switch(data["ticks"])
			if(50 to 100)
				H.disabilities &= ~COUGHING
			if(100 to INFINITY)
				H.hallucination = max(H.hallucination, 7)
	data["ticks"]++

/datum/reagent/dexalinp/on_vox_digest(mob/living/M)
	..()
	M.adjustToxLoss(7 * REM)
	return FALSE

/datum/reagent/dexalinp
	name = "Dexalin Plus"
	id = "dexalinp"
	description = "Dexalin Plus is used in the treatment of oxygen deprivation. It is highly effective."
	reagent_state = LIQUID
	color = "#0040ff" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE * 0.5
	taste_message = "ability to breath"
	restrict_species = list(IPC, DIONA)

/datum/reagent/dexalinp/on_general_digest(mob/living/M)
	..()
	M.adjustOxyLoss(-M.getOxyLoss())

	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2 * REM)

/datum/reagent/dexalinp/on_vox_digest(mob/living/M) // Now dexalin plus does not remove lexarin from Vox. For the better or the worse.
	..()
	M.adjustToxLoss(6 * REM) // Let's just say it's thrice as poisonous.
	return FALSE

/datum/reagent/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
	reagent_state = LIQUID
	color = "#00b080" // rgb: 200, 165, 220
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/tricordrazine/on_general_digest(mob/living/M)
	..()
	if(M.getOxyLoss())
		M.adjustOxyLoss(-1 * REM)
	if(M.getBruteLoss() && prob(80))
		M.heal_bodypart_damage(REM, 0)
	if(M.getFireLoss() && prob(80))
		M.heal_bodypart_damage(0, REM)
	if(M.getToxLoss() && prob(80))
		M.adjustToxLoss(-1 * REM)

/datum/reagent/anti_toxin
	name = "Anti-Toxin (Dylovene)"
	id = "anti_toxin"
	description = "Dylovene is a broad-spectrum antitoxin."
	reagent_state = LIQUID
	color = "#00a000" // rgb: 200, 165, 220
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/anti_toxin/on_general_digest(mob/living/M)
	..()
	M.reagents.remove_all_type(/datum/reagent/toxin, REM, 0, 1)
	M.drowsyness = max(M.drowsyness - 2 * REM, 0)
	M.hallucination = max(0, M.hallucination - 5 * REM)
	M.adjustToxLoss(-2 * REM)

/datum/reagent/thermopsis
	name = "Thermopsis"
	id = "thermopsis"
	description = "Irritates stomach receptors, that leads to reflex rise of vomiting."
	reagent_state = LIQUID
	color = "#a0a000"
	taste_message = "vomit"
	restrict_species = list(IPC, DIONA)

	data = list()

/datum/reagent/thermopsis/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	if(data["ticks"] > 10)
		M.vomit()
		data["ticks"] -= rand(0, 10)

/datum/reagent/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	id = "adminordrazine"
	description = "It's magic. We don't have to explain it."
	reagent_state = LIQUID
	color = "#c8a5dc" // rgb: 200, 165, 220
	taste_message = "admin abuse"

/datum/reagent/adminordrazine/on_general_digest(mob/living/M)
	..()
	M.reagents.remove_all_type(/datum/reagent/toxin, 5 * REM, 0, 1)
	M.setCloneLoss(0)
	M.setOxyLoss(0)
	M.radiation = 0
	M.heal_bodypart_damage(5,5)
	M.adjustToxLoss(-5)
	M.hallucination = 0
	M.setBrainLoss(0)
	M.disabilities = 0
	M.sdisabilities = 0
	M.eye_blurry = 0
	M.eye_blind = 0
	M.SetWeakened(0)
	M.SetStunned(0)
	M.SetParalysis(0)
	M.silent = 0
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	M.SetSleeping(0)
	M.jitteriness = 0
	for(var/datum/disease/D in M.viruses)
		D.spread = "Remissive"
		D.stage--
		if(D.stage < 1)
			D.cure()

/datum/reagent/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	description = "Synaptizine is used to treat various diseases."
	reagent_state = LIQUID
	color = "#99ccff" // rgb: 200, 165, 220
	custom_metabolism = 0.01
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)

/datum/reagent/synaptizine/on_general_digest(mob/living/M)
	..()
	M.drowsyness = max(M.drowsyness - 5, 0)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(60))
		M.adjustToxLoss(1)

/datum/reagent/hyronalin
	name = "Hyronalin"
	id = "hyronalin"
	description = "Hyronalin is a medicinal drug used to counter the effect of radiation poisoning."
	reagent_state = LIQUID
	color = "#408000" // rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/hyronalin/on_general_digest(mob/living/M)
	..()
	M.radiation = max(M.radiation - 3 * REM, 0)

/datum/reagent/arithrazine
	name = "Arithrazine"
	id = "arithrazine"
	description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
	reagent_state = LIQUID
	color = "#008000" // rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/arithrazine/on_general_digest(mob/living/M)
	..()
	M.radiation = max(M.radiation - 7 * REM, 0)
	M.adjustToxLoss(-1 * REM)
	if(prob(15))
		M.take_bodypart_damage(1, 0)

/datum/reagent/alkysine
	name = "Alkysine"
	id = "alkysine"
	description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
	reagent_state = LIQUID
	color = "#8b00ff" // rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/alkysine/on_general_digest(mob/living/M)
	..()
	M.adjustBrainLoss(-3 * REM)

/datum/reagent/imidazoline
	name = "Imidazoline"
	id = "imidazoline"
	description = "Heals eye damage"
	reagent_state = LIQUID
	color = "#a0dbff" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	taste_message = "carrot"
	restrict_species = list(IPC, DIONA)

/datum/reagent/imidazoline/on_general_digest(mob/living/M)
	..()
	M.eye_blurry = max(M.eye_blurry - 5, 0)
	M.eye_blind = max(M.eye_blind - 5, 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/eyes/IO = H.organs_by_name[O_EYES]
		if(istype(IO))
			if(IO.damage > 0 && IO.robotic < 2)
				IO.damage = max(IO.damage - 1, 0)

/datum/reagent/peridaxon
	name = "Peridaxon"
	id = "peridaxon"
	description = "Used to encourage recovery of organs and nervous systems. Medicate cautiously."
	reagent_state = LIQUID
	color = "#561ec3" // rgb: 200, 165, 220
	overdose = 10
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/peridaxon/on_general_digest(mob/living/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/damaged_organs = 0
		//Peridaxon is hard enough to get, it's probably fair to make this all organs
		for(var/obj/item/organ/internal/IO in H.organs)
			if(IO.damage > 0 && IO.robotic < 2)
				damaged_organs++

		if(!damaged_organs)
			return
		for(var/obj/item/organ/internal/IO in H.organs)
			if(IO.damage > 0 && IO.robotic < 2)
				IO.damage = max(IO.damage - (3 * custom_metabolism / damaged_organs), 0)

/datum/reagent/kyphotorin
	name = "Kyphotorin"
	id = "kyphotorin"
	description = "Used nanites to encourage recovery of body parts and bones. Medicate cautiously."
	reagent_state = LIQUID
	color = "#551a8b" // rgb: 85, 26, 139
	overdose = 5.1
	custom_metabolism = 0.07
	taste_message = "machines"
	restrict_species = list(IPC, DIONA)

/datum/reagent/kyphotorin/on_general_digest(mob/living/M)
	..()
	if(!ishuman(M) || volume > overdose)
		return
	var/mob/living/carbon/human/H = M
	if(H.nutrition < 200) // if nanites don't have enough resources, they stop working and still spend
		H.make_jittery(100)
		volume += 0.07
		return
	H.jitteriness = max(0,H.jitteriness - 100)
	if(!H.regenerating_bodypart)
		H.regenerating_bodypart = H.find_damaged_bodypart()
	if(H.regenerating_bodypart)
		H.nutrition -= 3
		H.apply_effect(3, WEAKEN)
		H.apply_damages(0,0,1,4,0,5)
		H.regen_bodyparts(4, FALSE)
	else
		volume += 0.07

/datum/reagent/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
	reagent_state = LIQUID
	color = "#bf0000" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/bicaridine/on_general_digest(mob/living/M, alien)
	..()
	M.heal_bodypart_damage(2 * REM, 0)

/datum/reagent/hyperzine
	name = "Hyperzine"
	id = "hyperzine"
	description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
	reagent_state = LIQUID
	color = "#ff4f00" // rgb: 200, 165, 220
	custom_metabolism = 0.03
	overdose = REAGENTS_OVERDOSE * 0.5
	taste_message = "speed"
	restrict_species = list(IPC, DIONA)

/datum/reagent/hyperizine/on_general_digest(mob/living/M)
	..()
	if(prob(5))
		M.emote(pick("twitch","blink","shiver"))

/datum/reagent/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
	reagent_state = LIQUID
	color = "#80bfff" // rgb: 200, 165, 220
	taste_message = null

/datum/reagent/cryoxadone/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-1)
		M.adjustOxyLoss(-1)
		M.heal_bodypart_damage(1, 1)
		M.adjustToxLoss(-1)

/datum/reagent/clonexadone
	name = "Clonexadone"
	id = "clonexadone"
	description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' the cloning process when used in conjunction with a cryo tube."
	reagent_state = LIQUID
	color = "#8080ff" // rgb: 200, 165, 220
	taste_message = null

/datum/reagent/clonexadone/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-3)
		M.adjustOxyLoss(-3)
		M.heal_bodypart_damage(3, 3)
		M.adjustToxLoss(-3)

/datum/reagent/rezadone
	name = "Rezadone"
	id = "rezadone"
	description = "A powder derived from fish toxin, this substance can effectively treat genetic damage in humanoids, though excessive consumption has side effects."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	overdose = REAGENTS_OVERDOSE
	taste_message = null

	data = list()

/datum/reagent/rezadone/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	switch(data["ticks"])
		if(1 to 15)
			M.adjustCloneLoss(-1)
			M.heal_bodypart_damage(1, 1)
		if(15 to 35)
			M.adjustCloneLoss(-2)
			M.heal_bodypart_damage(2, 1)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/obj/item/organ/external/head/BP = H.bodyparts_by_name[BP_HEAD]
				if(BP && BP.disfigured)
					BP.disfigured = FALSE
					to_chat(M, "Your face is shaped normally again.")
		if(35 to INFINITY)
			M.adjustToxLoss(1)
			M.make_dizzy(5)
			M.make_jittery(5)

/datum/reagent/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	description = "An all-purpose antiviral agent."
	reagent_state = LIQUID
	color = "#ffffff" // rgb: 200, 165, 220
	custom_metabolism = 0.01
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/ethylredoxrazine // FUCK YOU, ALCOHOL
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	description = "A powerful oxidizer that reacts with ethanol."
	reagent_state = SOLID
	color = "#605048" // rgb: 96, 80, 72
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/ethylredoxrazine/on_general_digest(mob/living/M)
	..()
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 1 * REM, 0, 1)

/datum/reagent/vitamin //Helps to regen blood and hunger(but doesn't really regen hunger because of the commented code below).
	name = "Vitamin"
	id = "vitamin"
	description = "All the best vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	color = "#664330" // rgb: 102, 67, 48
	taste_message = null

/datum/reagent/vitamin/on_general_digest(mob/living/M)
	..()
	if(prob(50))
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
	/*if(M.nutrition < NUTRITION_LEVEL_WELL_FED) //we are making him WELL FED
		M.nutrition += 30*/  //will remain commented until we can deal with fat
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/blood_volume = H.vessel.get_reagent_amount("blood")
		if(!(NO_BLOOD in H.species.flags))//do not restore blood on things with no blood by nature.
			if(blood_volume < BLOOD_VOLUME_NORMAL && blood_volume)
				var/datum/reagent/blood/B = locate() in H.vessel.reagent_list
				B.volume += 0.5

/datum/reagent/lipozine
	name = "Lipozine" // The anti-nutriment.
	id = "lipozine"
	description = "A chemical compound that causes a powerful fat-burning reaction."
	reagent_state = LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#bbeda4" // rgb: 187, 237, 164
	overdose = REAGENTS_OVERDOSE

/datum/reagent/lipozine/on_general_digest(mob/living/M)
	..()
	M.nutrition = max(M.nutrition - nutriment_factor, 0)
	M.overeatduration = 0

/datum/reagent/stimulants
	name = "Stimulants"
	id = "stimulants"
	description = "Stimulants to keep you up in a critical moment"
	reagent_state = LIQUID
	color = "#99ccff" // rgb: 200, 165, 220
	custom_metabolism = 0.5
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)

/datum/reagent/stimulants/on_general_digest(mob/living/M)
	..()
	M.drowsyness = max(M.drowsyness - 5, 0)
	M.AdjustParalysis(-3)
	M.AdjustStunned(-3)
	M.AdjustWeakened(-3)
	var/mob/living/carbon/human/H = M
	H.adjustHalLoss(-30)
	H.shock_stage -= 20

/datum/reagent/nanocalcium
	name = "Nano-Calcium"
	id = "nanocalcium"
	description = "Highly advanced nanites equipped with calcium payloads designed to repair bones. Nanomachines son."
	reagent_state = LIQUID
	color = "#9b3401"
	overdose = REAGENTS_OVERDOSE
	custom_metabolism = 0.1
	taste_message = "wholeness"
	restrict_species = list(IPC, DIONA)
	data = list()

/datum/reagent/nanocalcium/on_general_digest(mob/living/carbon/human/M)
	..()
	if(!ishuman(M))
		return

	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	switch(data)
		if(1 to 10)
			M.make_dizzy(1)
			if(prob(10))
				to_chat(M, "<span class='warning'>Your skin feels hot and your veins are on fire!</span>")
		if(10 to 20)
			if(M.reagents.has_reagent("tramadol") || M.reagents.has_reagent("oxycodone"))
				M.adjustToxLoss(5)
			else
				M.confused += 2
		if(20 to 60)
			for(var/obj/item/organ/external/E in M.bodyparts)
				if(E.is_broken())
					if(prob(50))
						to_chat(M, "<span class='notice'>You feel a burning sensation in your [E.name] as it straightens involuntarily!</span>")
						E.brute_dam = 0
						E.status &= ~BROKEN
						holder.remove_reagent("nanocalcium", 10)
