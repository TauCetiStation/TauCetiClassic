/obj/item/organ/internal/kidneys
	name = "kidneys"
	cases = list("почки", "почек", "почкам", "почки", "почками", "почках")
	icon_state = "kidneys"
	item_state_world = "kidneys_world"
	min_bruised_damage = 25
	min_broken_damage = 45
	max_damage = 70
	cybernetic_version = /obj/item/organ/internal/kidneys/cybernetic
	organ_tag = O_KIDNEYS
	parent_bodypart = BP_GROIN

/obj/item/organ/internal/kidneys/vox
	name = "filtration bladder"
	cases = list("фильтрующий пузырь", "фильтрующего пузыря", "фильтрующему пузырю", "фильтрующий пузырь", "фильтрующим пузырём", "фильтрующем пузыре")
	icon = 'icons/obj/special_organs/vox.dmi'
	compability = list(VOX)
	parent_bodypart = BP_CHEST
	sterile = TRUE
	cybernetic_version = /obj/item/organ/internal/kidneys/cybernetic/voxc

/obj/item/organ/internal/kidneys/tajaran
	name = "tajaran kidneys"
	icon = 'icons/obj/special_organs/tajaran.dmi'

/obj/item/organ/internal/kidneys/unathi
	name = "unathi kidneys"
	icon = 'icons/obj/special_organs/unathi.dmi'

/obj/item/organ/internal/kidneys/skrell
	name = "skrell kidneys"
	icon = 'icons/obj/special_organs/skrell.dmi'
	desc = "The smallest kidneys you have ever seen, it probably doesn't even work."

/obj/item/organ/internal/kidneys/diona
	name = "vacuole"
	cases = list("вакуоль", "вакуоли", "вакуолям", "вакуоль", "вакуолью", "вакуоли")
	parent_bodypart = BP_GROIN
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	item_state_world = "nymph"
	compability = list(DIONA)
	tough = TRUE

/obj/item/organ/internal/kidneys/cybernetic
	name = "cybernetic kidneys"
	icon_state = "kidneys-prosthetic"
	desc = "An electronic device designed to mimic the functions of human kidneys. It fights toxins in the blood much better than regular kidneys."
	item_state_world = "kidneys-prosthetic_world"
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	durability = 0.8
	compability = list(HUMAN, PLUVIAN, UNATHI, TAJARAN, SKRELL)
	can_relocate = TRUE

/obj/item/organ/internal/kidneys/cybernetic/voxc
	compability = list(VOX)
	parent_bodypart = BP_CHEST

/obj/item/organ/internal/kidneys/ipc
	name = "self-diagnosis unit"
	cases = list("устройство самодиагностики", "устройства самодиагностики", "устройству самодиагностики", "устройство самодиагностики", "устройством самодиагностики", "устройстве самодиагностики")
	parent_bodypart = BP_GROIN
	status = ORGAN_ROBOT
	durability = 0.8
	var/next_warning = 0
	requires_robotic_bodypart = TRUE

	icon = 'icons/obj/robot_component.dmi'
	icon_state = "analyser"
	item_state_world = "analyser"

/obj/item/organ/internal/kidneys/process()
	..()

	if(!owner)
		return

	if(is_robotic() && (!is_bruised() || !is_broken()))
		owner.adjustToxLoss(-0.25)

	// Coffee is really bad for you with busted kidneys.
	// This should probably be expanded in some way, but fucked if I know
	// what else kidneys can process in our reagent list.
	var/datum/reagent/coffee = locate(/datum/reagent/consumable/drink/coffee) in owner.reagents.reagent_list
	if(coffee)
		if(is_bruised())
			owner.adjustToxLoss(0.1 * process_accuracy)
		else if(is_broken())
			owner.adjustToxLoss(0.3 * process_accuracy)


/obj/item/organ/internal/kidneys/ipc/process()
	if(!owner)
		return
	if(owner.nutrition < 1)
		return
	if(next_warning > world.time)
		return
	next_warning = world.time + 10 SECONDS

	var/damage_report = ""
	var/first = TRUE

	for(var/obj/item/organ/internal/IO in owner.organs)
		if(IO.is_bruised())
			if(!first)
				damage_report += "\n"
			first = FALSE
			damage_report += "<span class='warning'><b>%[uppertext(IO.name)]%</b> INJURY DETECTED. CEASE DAMAGE TO <b>%[uppertext(IO.name)]%</b>. REQUEST ASSISTANCE.</span>"

	if(damage_report != "")
		to_chat(owner, damage_report)
