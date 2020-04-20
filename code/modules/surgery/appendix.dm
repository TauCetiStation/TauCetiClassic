//Procedures in this file: Appendectomy
//////////////////////////////////////////////////////////////////
//						APPENDECTOMY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/appendectomy
	priority = 2
	can_infect = 1
	blood_level = 1

/datum/surgery_step/appendectomy/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!ishuman(target))
		return 0
	if (target_zone != BP_GROIN)
		return 0
	var/obj/item/organ/external/BP = target.bodyparts_by_name[BP_GROIN]
	if (!BP)
		return 0
	if (BP.open < 2)
		return 0
	return 1

/datum/surgery_step/appendectomy/cut_appendix
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/appendectomy/cut_appendix/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.appendix == 0

/datum/surgery_step/appendectomy/cut_appendix/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to separate [target]'s appendix from the abdominal wall with \the [tool].", \
	"You start to separate [target]'s appendix from the abdominal wall with \the [tool]." )
	target.custom_pain("The pain in your abdomen is living hell!",1)
	..()

/datum/surgery_step/appendectomy/cut_appendix/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has separated [target]'s appendix with \the [tool].</span>" , \
	"<span class='notice'>You have separated [target]'s appendix with \the [tool].</span>")
	target.op_stage.appendix = 1

/datum/surgery_step/appendectomy/cut_appendix/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.bodyparts_by_name[BP_GROIN]
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing an artery inside [target]'s abdomen with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing an artery inside [target]'s abdomen with \the [tool]!</span>")
	BP.take_damage(50, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/appendectomy/remove_appendix
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/appendectomy/remove_appendix/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.appendix == 1

/datum/surgery_step/appendectomy/remove_appendix/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts removing [target]'s appendix with \the [tool].", \
	"You start removing [target]'s appendix with \the [tool].")
	target.custom_pain("Someone's ripping out your bowels!",1)
	..()

/datum/surgery_step/appendectomy/remove_appendix/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has removed [target]'s appendix with \the [tool].</span>", \
	"<span class='notice'>You have removed [target]'s appendix with \the [tool].</span>")
	var/app = 0
	for(var/datum/disease/appendicitis/appendicitis in target.viruses)
		app = 1
		appendicitis.cure()
		target.resistances += appendicitis
	if (app)
		new /obj/item/weapon/reagent_containers/food/snacks/appendix/inflamed(get_turf(target))
	else
		new /obj/item/weapon/reagent_containers/food/snacks/appendix(get_turf(target))
	target.op_stage.appendix = 2

/datum/surgery_step/appendectomy/remove_appendix/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.bodyparts_by_name[BP_GROIN]
	user.visible_message("<span class='warning'>[user]'s hand slips, nicking organs in [target]'s abdomen with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, nicking organs in [target]'s abdomen with \the [tool]!</span>")
	BP.take_damage(20, 0, used_weapon = tool)
