/////////////////////
// DISABILITY GENES
//
// These activate either a mutation, disability, or sdisability.
//
// Gene is always activated.
/////////////////////

/datum/dna/gene/disability
	name="DISABILITY"

	// Mutation to give (or 0)
	var/mutation=0

	// Disability to give (or 0)
	var/disability=0

	// SDisability to give (or 0)
	var/sdisability=0

	// Activation message
	var/activation_message=""

	// Yay, you're no longer growing 3 arms
	var/deactivation_message=""

/datum/dna/gene/disability/can_activate(mob/M,flags)
	return 1 // Always set!

/datum/dna/gene/disability/activate(mob/M, connected, flags)
	if(mutation && !(mutation in M.mutations))
		M.mutations.Add(mutation)
	if(disability)
		M.disabilities|=disability
	if(mutation)
		M.sdisabilities|=sdisability
	if(activation_message)
		to_chat(M, "\red [activation_message]")
	//else
		//testing("[name] has no activation message.")

/datum/dna/gene/disability/deactivate(mob/M, connected, flags)
	if(mutation && (mutation in M.mutations))
		M.mutations.Remove(mutation)
	if(disability)
		M.disabilities-=disability
	if(mutation)
		M.sdisabilities-=sdisability
	if(deactivation_message)
		to_chat(M, "\red [deactivation_message]")
	//else
		//testing("[name] has no deactivation message.")

// Note: Doesn't seem to do squat, at the moment.
/datum/dna/gene/disability/hallucinate
	name="Hallucinate"
	activation_message="Your mind says 'Hello'."
	mutation=HALLUCINATE

	New()
		block=HALLUCINATIONBLOCK

	OnMobLife(mob/living/carbon/human/M) //#Z2
		if(!istype(M)) return
		M.hallucination = 200

	deactivate(mob/living/carbon/human/M, connected, flags)
		..(M,connected,flags)
		M.hallucination = 0 //##Z2

/datum/dna/gene/disability/epilepsy
	name="Epilepsy"
	activation_message="You get a headache."
	disability=EPILEPSY

	New()
		block=HEADACHEBLOCK

/datum/dna/gene/disability/cough
	name="Coughing"
	activation_message="You start coughing."
	disability=COUGHING

	New()
		block=COUGHBLOCK

/datum/dna/gene/disability/clumsy
	name="Clumsiness"
	activation_message="You feel lightheaded."
	mutation=CLUMSY

	New()
		block=CLUMSYBLOCK

/datum/dna/gene/disability/tourettes
	name="Tourettes"
	activation_message="You twitch."
	disability=TOURETTES

	New()
		block=TWITCHBLOCK

/datum/dna/gene/disability/nervousness
	name="Nervousness"
	activation_message="You feel nervous."
	disability=NERVOUS

	New()
		block=NERVOUSBLOCK

/datum/dna/gene/disability/blindness
	name="Blindness"
	activation_message="You can't seem to see anything."
	sdisability=BLIND

	New()
		block=BLINDBLOCK

	OnMobLife(mob/living/carbon/human/M) //#Z2
		if(!istype(M)) return
		M.eye_blurry = 200
		M.eye_blind = 200

	deactivate(mob/living/carbon/human/M, connected, flags)
		..(M,connected,flags)
		M.eye_blurry = 0
		M.eye_blind = 0 //##Z2

/datum/dna/gene/disability/deaf
	name="Deafness"
	activation_message="It's kinda quiet."
	sdisability=DEAF

	New()
		block=DEAFBLOCK

	OnMobLife(mob/living/carbon/human/M) //#Z2
		if(!istype(M)) return
		M.ear_deaf = 200

	deactivate(mob/living/carbon/human/M, connected, flags)
		..(M,connected,flags)
		M.ear_deaf = 0 //##Z2

/datum/dna/gene/disability/nearsighted
	name="Nearsightedness"
	activation_message="Your eyes feel weird..."
	disability=NEARSIGHTED

	New()
		block=GLASSESBLOCK
