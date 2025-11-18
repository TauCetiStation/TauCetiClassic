/obj/item/organ/internal/liver
	name = "liver"
	cases = list("печень", "печени", "печени", "печень", "печенью", "печени")
	icon_state = "liver"
	item_state_world = "liver_world"
	organ_tag = O_LIVER
	parent_bodypart = BP_GROIN
	var/alcohol_intensity = 1
	min_bruised_damage = 25
	min_broken_damage = 45
	max_damage = 70
	cybernetic_version = /obj/item/organ/internal/liver/cybernetic
	process_accuracy = 4

/obj/item/organ/internal/liver/diona
	name = "chlorophyll sac"
	cases = list("хлорофилловый мешок", "хлорофиллового мешка", "хлорофилловому мешку", "хлорофилловый мешок", "хлорофилловым мешком", "хлорофилловом мешке")
	icon = 'icons/obj/objects.dmi'
	icon_state = "podkid"
	item_state_world = "podkid"
	alcohol_intensity = 0.5
	compability = list(DIONA)
	tough = TRUE

/obj/item/organ/internal/liver/vox
	name = "waste tract"
	cases = list("канал отходов", "канала отходов", "каналу отходов", "канал отходов", "каналом отходов", "канале отходов")
	icon = 'icons/obj/special_organs/vox.dmi'
	compability = list(VOX)
	parent_bodypart = BP_CHEST
	alcohol_intensity = 1.6
	sterile = TRUE
	cybernetic_version = /obj/item/organ/internal/liver/cybernetic/voxc

/obj/item/organ/internal/liver/tajaran
	name = "tajaran liver"
	icon = 'icons/obj/special_organs/tajaran.dmi'
	alcohol_intensity = 1.4

/obj/item/organ/internal/liver/unathi
	name = "unathi liver"
	icon = 'icons/obj/special_organs/unathi.dmi'
	desc = "A large looking liver."
	alcohol_intensity = 0.8

/obj/item/organ/internal/liver/skrell
	name = "skrell liver"
	icon = 'icons/obj/special_organs/skrell.dmi'
	alcohol_intensity = 0

/obj/item/organ/internal/liver/cybernetic
	name = "cybernetic liver"
	icon_state = "liver-prosthetic"
	desc = "An electronic device designed to mimic the functions of a human liver. It has no benefits over an organic liver, but is easy to produce."
	item_state_world = "liver-prosthetic_world"
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	durability = 0.8
	compability = list(HUMAN, PLUVIAN, UNATHI, TAJARAN, SKRELL)
	can_relocate = TRUE

/obj/item/organ/internal/liver/cybernetic/voxc
	compability = list(VOX)
	parent_bodypart = BP_CHEST

/obj/item/organ/internal/liver/ipc
	name = "accumulator"
	cases = list("аккумулятор", "аккумулятора", "аккумулятору", "аккумулятор", "аккумулятором", "аккумуляторе")
	var/accumulator_warning = 0
	requires_robotic_bodypart = TRUE
	status = ORGAN_ROBOT
	durability = 0.8
	icon = 'icons/obj/power.dmi'
	icon_state = "hpcell"
	item_state_world = "hpcell"

/obj/item/organ/internal/liver/ipc/set_owner(mob/living/carbon/human/H, datum/species/S)
	..()
	new/obj/item/weapon/stock_parts/cell/crap(src)
	RegisterSignal(owner, COMSIG_ATOM_ELECTROCUTE_ACT, PROC_REF(ipc_cell_explode))

/obj/item/organ/internal/liver/proc/handle_liver_infection()
	if(germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			to_chat(owner, "<span class='warning'>Your skin itches.</span>")
	if(germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/living/carbon/human, vomit))

/obj/item/organ/internal/liver/proc/handle_liver_life()
	if(owner.life_tick % process_accuracy != 0)
		return

	if(damage < 0)
		src.damage = 0

	//High toxins levels are dangerous
	if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent("anti_toxin"))
		//Healthy liver suffers on its own
		if (src.damage < min_broken_damage)
			src.damage += 0.2 * process_accuracy
		//Damaged one shares the fun
		else
			var/obj/item/organ/internal/IO = pick(owner.organs)
			if(IO)
				IO.damage += 0.2 * process_accuracy

	//Detox can heal small amounts of damage
	if (src.damage && src.damage < src.min_bruised_damage && owner.reagents.has_reagent("anti_toxin"))
		src.damage -= 0.2 * process_accuracy

	var/blood_total = owner.blood_amount()

	// Blood regeneration if there is some space:
	if(blood_total < BLOOD_VOLUME_NORMAL)
		var/change_volume = 0.1 * process_accuracy // Regenerate blood VERY slowly
		if (owner.reagents.has_reagent("nutriment")) // Getting food speeds it up
			change_volume += 0.4 * process_accuracy
			owner.reagents.remove_reagent("nutriment", 0.1 * process_accuracy)
		if (owner.reagents.has_reagent("copper") && owner.get_species(owner) == SKRELL) // skrell blood base on copper
			change_volume += 1 * process_accuracy
			owner.reagents.remove_reagent("copper", 0.1 * process_accuracy)
		if (owner.reagents.has_reagent("iron")) // Hematogen candy anyone?
			if(owner.get_species(owner) == SKRELL) // a little more toxins when trying to restore blood with iron
				var/mob/living/carbon/human/H = owner
				H.adjustToxLoss(1 * process_accuracy)
			else
				change_volume += 0.8 * process_accuracy
				owner.reagents.remove_reagent("iron", 0.1 * process_accuracy)
		owner.blood_add(change_volume)
		blood_total += change_volume

	// Damaged liver means some chemicals are very dangerous
	if(src.damage >= src.min_bruised_damage)
		for(var/datum/reagent/R in owner.reagents.reagent_list)
			// Ethanol and all drinks are bad
			if(istype(R, /datum/reagent/consumable/ethanol))
				owner.adjustToxLoss(0.1 * process_accuracy)
			// Can't cope with toxins at all
			if(istype(R, /datum/reagent/toxin))
				owner.adjustToxLoss(0.3 * process_accuracy)

		// Without enough blood you slowly go hungry.
	var/blood_volume = owner.get_blood_oxygenation()
	if(blood_volume < BLOOD_VOLUME_SAFE_P)
		if(owner.nutrition >= 300)
			owner.nutrition -= 10 * process_accuracy
		else if(owner.nutrition >= 200)
			owner.nutrition -= 3 * process_accuracy

/obj/item/organ/internal/liver/process()
	..()
	if(!owner)
		return

	handle_liver_infection()
	handle_liver_life()

/obj/item/organ/internal/liver/serpentid

/obj/item/organ/internal/liver/serpentid/handle_liver_life()
	if(is_bruised())
		if(owner.life_tick % process_accuracy == 0)
			for(var/datum/reagent/R in owner.reagents.reagent_list)
				if(istype(R, /datum/reagent/consumable/ethanol))
					owner.adjustToxLoss(0.1 * process_accuracy)
				if(istype(R, /datum/reagent/toxin))
					owner.adjustToxLoss(0.3 * process_accuracy)
		owner.adjustOxyLoss(damage)

	if(owner.reagents.get_reagent_amount("dexalinp") >= 4.0)
		return
	owner.reagents.add_reagent("dexalinp", REAGENTS_METABOLISM * 1.5)

	if(owner.reagents.get_reagent_amount("dexalinp") >= 3.0)
		return
	damage += 0.2


/obj/item/organ/internal/liver/ipc/process()
	if(!owner)
		return
	var/obj/item/weapon/stock_parts/cell/C = locate(/obj/item/weapon/stock_parts/cell) in src

	if(!C)
		if(!owner.is_bruised_organ(O_KIDNEYS) && prob(2))
			to_chat(owner, "<span class='warning bold'>%ACCUMULATOR% DAMAGED BEYOND FUNCTION. SHUTTING DOWN.</span>")
		owner.SetParalysis(2)
		owner.blurEyes(2)
		owner.silent = 2
		return
	if(damage)
		C.charge = owner.nutrition
		if(owner.nutrition > (C.maxcharge - damage * 5))
			owner.nutrition = C.maxcharge - damage * 5
	if(owner.nutrition < 1)
		owner.SetParalysis(2)
		if(accumulator_warning < world.time)
			to_chat(owner, "<span class='warning bold'>%ACCUMULATOR% LOW CHARGE. SHUTTING DOWN.</span>")
			accumulator_warning = world.time + 15 SECONDS

/obj/item/organ/internal/liver/ipc/proc/ipc_cell_explode()
	var/obj/item/weapon/stock_parts/cell/C = locate() in src
	if(!C)
		return
	var/turf/T = get_turf(owner.loc)
	if(owner.nutrition > (C.maxcharge * 1.2))
		explosion(T, 0, 1, 2)
		C.ex_act(EXPLODE_DEVASTATE)
