/obj/item/organ/internal/brain
	name = "brain"
	desc = "A piece of juicy meat found in a persons head."
	cases = list("мозг", "мозга", "мозгу", "мозг", "мозгом", "мозге")
	organ_tag = O_BRAIN
	vital = TRUE
	parent_bodypart = BP_HEAD
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain2"
	item_state_world = "brain2_world"
	max_damage = 100
	min_broken_damage = 75
	min_bruised_damage = 25
	tough = TRUE // TC This is a temporary solution, so as not to complicate life
	var/destroyit = FALSE

	var/can_use_mmi = TRUE
	var/oxygen_reserve = 6

	force = 1.0
	w_class = SIZE_TINY
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=3"
	attack_verb = list("attacked", "slapped", "whacked")

	var/mob/living/carbon/brain/brainmob = null

	var/oxy = 0

/obj/item/organ/internal/brain/atom_init()
	. = ..()
	//Shifting the brain "mob" over to the brain object so it's easier to keep track of. --NEO
	//WASSSSSUUUPPPP /N
	spawn(5)
		brainmob?.client?.screen.len = null //clear the hud

/obj/item/organ/internal/brain/remove(mob/living/user)

	if(!owner)
		return ..() // Probably a redundant removal; just bail

	if(name == initial(name))
		name = "\the [owner.real_name]'s [initial(name)]"

	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()

	if(borer)
		borer.detatch() //Should remove borer if the brain is removed - RR

	if(destroyit)
		return


	transfer_identity(owner)

	..()

/obj/item/organ/internal/brain/process()

	if(!owner)
		return ..()

	if(owner.stat == DEAD)
		return ..()

	handle_damage_effects()

	if(!owner.should_have_organ(O_HEART))
		return ..()
	if(HAS_TRAIT(owner, TRAIT_NO_BLOOD))
		return
	// No heart? You are going to have a very bad time. Not 100% lethal because heart transplants should be a thing.
	var/blood_volume = owner.get_blood_oxygenation()
	if(blood_volume < BLOOD_VOLUME_SURVIVE_P)
		if(HAS_TRAIT(owner, TRAIT_EXTERNAL_HEART)) //TC The artificial blood circulation system can completely replace the heart and lungs for the brain
			return ..()
		if(!owner.reagents.has_reagent("inaprovaline") || prob(60))
			oxygen_reserve = max(0, oxygen_reserve-0,5)
		else
			oxygen_reserve = min(initial(oxygen_reserve), oxygen_reserve+0,5)
		if(!oxygen_reserve) //(hardcrit)
			owner.Paralyse(3)
	var/damprob
	// Effects of bloodloss
	oxy = owner.getOxyLoss()
	switch(blood_volume)
		if(BLOOD_VOLUME_SAFE_P to 10000)
			if(owner.pale)
				owner.pale = FALSE
				owner.update_body()
		if(BLOOD_VOLUME_OKAY_P to BLOOD_VOLUME_SAFE_P)
			if(!owner.pale)
				owner.pale = TRUE
				owner.update_body()
				var/word = pick("dizzy", "woosey", "faint")
				to_chat(src, "<span class='warning'>You feel [word]</span>")
			if(prob(1))
				var/word = pick("dizzy", "woosey", "faint")
				to_chat(src, "<span class='warning'>You feel [word]</span>")
			if(oxy < 20)
				owner.adjustOxyLoss(3)
		if(BLOOD_VOLUME_BAD_P to BLOOD_VOLUME_OKAY_P)
			if(!owner.pale)
				owner.pale = TRUE
				owner.update_body()
			owner.blurEyes(6)
			if(oxy < 50)
				owner.adjustOxyLoss(10)
			owner.adjustOxyLoss(1)
			if(!owner.paralysis && prob(10))
				owner.Paralyse(rand(1,3))
				var/word = pick("dizzy", "woosey", "faint")
				to_chat(src, "<span class='warning'>You feel extremely [word]</span>")
		if(BLOOD_VOLUME_SURVIVE_P to BLOOD_VOLUME_BAD_P)
			owner.blurEyes(6)
			owner.adjustOxyLoss(5)
			damprob = owner.reagents.has_reagent("inaprovaline") ? 60 : 100
			if(prob(damprob) && damage < 40)// without blood the brain begins to die
				take_damage(1)
			if(!owner.paralysis && prob(15))
				owner.Paralyse(3,5)
				var/word = pick("dizzy", "woosey", "faint")
				to_chat(src, "<span class='warning'>You feel extremely [word]</span>")
		if(0 to BLOOD_VOLUME_SURVIVE_P)
			if(!iszombie(owner)) // zombies dont care about blood
				owner.blurEyes(6)
				owner.adjustOxyLoss(10)
				damprob = owner.reagents.has_reagent("inaprovaline") ? 80 : 100
				if(prob(damprob))
					take_damage(1)

	..()

/obj/item/organ/internal/brain/proc/transfer_identity(mob/living/carbon/H)
	name = "[H]'s brain"
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	brainmob.timeofhostdeath = H.timeofdeath
	if(H.mind)
		H.mind.transfer_to(brainmob)

	to_chat(brainmob, "<span class='notice'>You feel slightly disoriented. That's normal when you're just a brain.</span>")

/obj/item/organ/internal/brain/examine(mob/user) // -- TLE
	..()
	if(brainmob && brainmob.client)//if thar be a brain inside... the brain.
		to_chat(user, "You can feel the small spark of life still left in this one.")
	else
		to_chat(user, "This one seems particularly lifeless. Perhaps it will regain some of its luster later..")


/obj/item/organ/internal/brain/proc/handle_damage_effects()
	if(owner.stat)
		return
	if(damage > 0 && prob(1))
		owner.custom_pain("Your head feels numb and painful.",10)
	if(is_bruised() && prob(1) && owner.eye_blurry <= 0)
		to_chat(owner, "<span class='warning'>It becomes hard to see for some reason.</span>")
		owner.eye_blurry = 10
	if(damage >= 0.5*max_damage && prob(1) && owner.get_active_hand())
		to_chat(owner, "<span class='warning'>Your hand won't respond properly, and you drop what you are holding!</span>")
		owner.drop_item()
	if(damage >= 0.6*max_damage)
		owner.slurring = max(owner.slurring, 2)
	if(is_broken())
		if(!owner.lying)
			to_chat(owner, "<span class='warning'>You black out!</span>")
		owner.Paralyse(10)

/obj/item/organ/internal/brain/diona
	name = "main node nymph"
	cases = list("главная нимфа", "главной нимфы", "главной нимфе", "главную нимфу", "главной нимфой", "главной нимфе")
	parent_bodypart = BP_CHEST
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	item_state_world = "nymph"
	compability = list(DIONA)
	tough = TRUE

/obj/item/organ/internal/brain/tajaran
	icon = 'icons/obj/special_organs/tajaran.dmi'

/obj/item/organ/internal/brain/unathi
	icon = 'icons/obj/special_organs/unathi.dmi'
	desc = "A smallish looking brain."

/obj/item/organ/internal/brain/vox
//	name = "cortical-stack"
//	desc = "A peculiarly advanced bio-electronic device that seems to hold the memories and identity of a Vox."
	icon = 'icons/obj/special_organs/vox.dmi'
	compability = list(VOX)
	sterile = TRUE

/obj/item/organ/internal/brain/skrell
	icon = 'icons/obj/special_organs/skrell.dmi'
	desc = "A brain with a odd division in the middle."

/obj/item/organ/internal/brain/ipc
	name = "positronic brain"
	cases = list("позитронный мозг", "позитронного мозга", "позитронному мозгу", "позитронный мозг", "позитронным мозгом", "позитронном мозге")
	parent_bodypart = BP_CHEST
	requires_robotic_bodypart = TRUE
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain-occupied"
	item_state_world = "posibrain-occupied"
	var/obj/item/device/mmi/posibrain/stored_mmi


/obj/item/organ/internal/brain/ipc/remove(mob/living/carbon/human/M)
	var/brain_type = /obj/item/device/mmi/posibrain

	var/obj/item/organ/external/BP = owner.get_bodypart(parent_bodypart)
	if(istype(BP, /obj/item/organ/external/chest/robot/ipc))
		var/obj/item/organ/external/chest/robot/ipc/I = BP
		brain_type = I.posibrain_type


	var/obj/item/device/mmi/P = new brain_type(owner.loc)
	P.transfer_identity(owner)


/obj/item/organ/internal/brain/abomination
	name = "deformed brain"
	cases = list("деформированный мозг", "деформированного мозга", "деформированному мозгу", "деформированный мозг", "деформированным мозгом", "деформированном мозге")
	parent_bodypart = BP_CHEST
