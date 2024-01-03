//Procedures in this file: Brain fixing. Slime Core extraction.


//////////////////////////////////////////////////////////////////
//				BRAIN DAMAGE FIXING								//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain/bone_chips
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,
	/obj/item/weapon/wirecutters = 75,
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/brain/bone_chips/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.skull ==  1 && target.has_brain() && target.op_stage.brain_fix == 0

/datum/surgery_step/brain/bone_chips/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts taking bone chips out of [target]'s brain with \the [tool].",
	"You start taking bone chips out of [target]'s brain with \the [tool].")
	..()

/datum/surgery_step/brain/bone_chips/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] takes out all the bone chips in [target]'s brain with \the [tool].</span>",
	"<span class='notice'>You take out all the bone chips in [target]'s brain with \the [tool].</span>")
	target.op_stage.brain_fix = 1


/datum/surgery_step/brain/bone_chips/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, jabbing \the [tool] in [target]'s brain!</span>",
	"<span class='warning'>Your hand slips, jabbing \the [tool] in [target]'s brain!</span>")
	BP.take_damage(30, 0, DAM_SHARP, tool)

/datum/surgery_step/brain/hematoma
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100,
	/obj/item/stack/cable_coil = 75
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/brain/hematoma/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.skull == 1 && target.has_brain() && target.op_stage.brain_fix == 1

/datum/surgery_step/brain/hematoma/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts mending hematoma in [target]'s brain with \the [tool].",
	"You start mending hematoma in [target]'s brain with \the [tool].")
	..()

/datum/surgery_step/brain/hematoma/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] mends hematoma in [target]'s brain with \the [tool].</span>",
	"<span class='notice'>You mend hematoma in [target]'s brain with \the [tool].</span>")
	var/obj/item/organ/internal/brain/IO = target.organs_by_name[O_BRAIN]
	if (IO)
		IO.damage = 0


/datum/surgery_step/brain/hematoma/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, bruising [target]'s brain with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, bruising [target]'s brain with \the [tool]!</span>")
	BP.take_damage(20, 0, used_weapon = tool)

//////////////////////////////////////////////////////////////////
//				mend skull surgery step
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain/mend_skull
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,
	/obj/item/stack/rods = 50
	)

	min_duration = 20
	max_duration = 40

/datum/surgery_step/brain/mend_skull/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.skull == 1

/datum/surgery_step/brain/mend_skull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts applying \the [tool] to [target]'s skull.",
	"[user] starts applying \the [tool] to [target]'s skull.")
	..()

/datum/surgery_step/brain/mend_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] applied \the [tool] to [target]'s skull.</span>",
	"<span class='notice'>You applied \the [tool] to [target]'s skull.</span>")
	target.op_stage.skull = 0
	target.op_stage.brain_cut = 0
	target.op_stage.brain_fix = 0

/datum/surgery_step/brain/mend_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>" ,
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>")

//////////////////////////////////////////////////////////////////
//				SLIME CORE EXTRACTION							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/slime/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	return isslime(target) && target.stat == DEAD

/datum/surgery_step/slime/cut_flesh
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50,
	)

	min_duration = 30
	max_duration = 50

/datum/surgery_step/slime/cut_flesh/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.brain_cut == 0

/datum/surgery_step/slime/cut_flesh/begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting through [target]'s flesh with \the [tool].",
	"You start cutting through [target]'s flesh with \the [tool].")

/datum/surgery_step/slime/cut_flesh/end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] cuts through [target]'s flesh with \the [tool].</span>",
	"<span class='notice'>You cut through [target]'s flesh with \the [tool], exposing the cores.</span>")
	target.op_stage.brain_cut = 1

/datum/surgery_step/slime/cut_flesh/fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing [target]'s flesh with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, tearing [target]'s flesh with \the [tool]!</span>")

/datum/surgery_step/slime/cut_innards
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50,
	)

	min_duration = 30
	max_duration = 50

/datum/surgery_step/slime/cut_innards/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.brain_cut == 1

/datum/surgery_step/slime/cut_innards/begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting [target]'s silky innards apart with \the [tool].",
	"You start cutting [target]'s silky innards apart with \the [tool].")

/datum/surgery_step/slime/cut_innards/end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] cuts [target]'s innards apart with \the [tool], exposing the cores.</span>",
	"<span class='notice'>You cut [target]'s innards apart with \the [tool], exposing the cores.</span>")
	target.op_stage.brain_cut = 2

/datum/surgery_step/slime/cut_innards/fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing [target]'s innards with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, tearing [target]'s innards with \the [tool]!</span>")

/datum/surgery_step/slime/saw_core
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100,
	/obj/item/weapon/hatchet = 75,
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/slime/saw_core/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.brain_cut == 2 && target.cores > 0

/datum/surgery_step/slime/saw_core/begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting out one of [target]'s cores with \the [tool].",
	"You start cutting out one of [target]'s cores with \the [tool].")

/datum/surgery_step/slime/saw_core/end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	target.cores--
	user.visible_message("<span class='notice'>[user] cuts out one of [target]'s cores with \the [tool].</span>",
	"<span class='notice'>You cut out one of [target]'s cores with \the [tool]. [target.cores] cores left.</span>")

	if(target.cores >= 0)
		new target.coretype(target.loc)
	if(target.cores <= 0)
		var/origstate = initial(target.icon_state)
		target.icon_state = "[origstate] dead-nocore"


/datum/surgery_step/slime/saw_core/fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, causing \him to miss the core!</span>",
	"<span class='warning'>Your hand slips, causing you to miss the core!</span>")
