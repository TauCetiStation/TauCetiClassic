//Procedures in this file: Brain extraction. Brain fixing. Slime Core extraction.
//////////////////////////////////////////////////////////////////
//						BRAIN SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain
	clothless = 0
	priority = 2
	blood_level = 1

/datum/surgery_step/brain/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return target_zone == BP_HEAD && ishuman(target)

/datum/surgery_step/brain/saw_skull
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75,       \
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/brain/saw_skull/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	return ..() && target_zone == BP_HEAD && target.brain_op_stage == 1

/datum/surgery_step/brain/saw_skull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to cut through [target]'s skull with \the [tool].", \
	"You begin to cut through [target]'s skull with \the [tool].")
	..()

/datum/surgery_step/brain/saw_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\blue [user] has cut [target]'s skull open with \the [tool].",		\
	"\blue You have cut [target]'s skull open with \the [tool].")
	target.brain_op_stage = 2

/datum/surgery_step/brain/saw_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\red [user]'s hand slips, cracking [target]'s skull with \the [tool]!" , \
	"\red Your hand slips, cracking [target]'s skull with \the [tool]!" )
	target.apply_damage(max(10, tool.force), BRUTE, BP_HEAD)

/datum/surgery_step/brain/cut_brain
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)
	disallowed_species = list(IPC, DIONA)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/brain/cut_brain/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	return ..() && target.brain_op_stage == 2

/datum/surgery_step/brain/cut_brain/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts separating connections to [target]'s brain with \the [tool].", \
	"You start separating connections to [target]'s brain with \the [tool].")
	..()

/datum/surgery_step/brain/cut_brain/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\blue [user] separates connections to [target]'s brain with \the [tool].",	\
	"\blue You separate connections to [target]'s brain with \the [tool].")
	target.brain_op_stage = 3

/datum/surgery_step/brain/cut_brain/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\red [user]'s hand slips, cutting a vein in [target]'s brain with \the [tool]!", \
	"\red Your hand slips, cutting a vein in [target]'s brain with \the [tool]!")
	target.apply_damage(50, BRUTE, BP_HEAD, 1, DAM_SHARP)

/datum/surgery_step/brain/saw_spine
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75,       \
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/brain/saw_spine/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	return ..() && target.brain_op_stage == 3

/datum/surgery_step/brain/saw_spine/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts separating [target]'s brain from \his spine with \the [tool].", \
	"You start separating [target]'s brain from spine with \the [tool].")
	..()

/datum/surgery_step/brain/saw_spine/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\blue [user] separates [target]'s brain from \his spine with \the [tool].",	\
	"\blue You separate [target]'s brain from spine with \the [tool].")

	var/mob/living/simple_animal/borer/borer = target.has_brain_worms()

	if(borer)
		borer.detach() //Should remove borer if the brain is removed - RR

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Debrained [target.name] ([target.ckey]) with [tool.name] (INTENT: [uppertext(user.a_intent)])</font>"
	target.attack_log += "\[[time_stamp()]\]<font color='orange'> Debrained by [user.name] ([user.ckey]) with [tool.name] (INTENT: [uppertext(user.a_intent)])</font>"
	msg_admin_attack("[user.name] ([user.ckey]) debrained [target.name] ([target.ckey]) with [tool.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	var/obj/item/brain/B
	B = new(target.loc)
	B.transfer_identity(target)

	target.organs -= B
	target.organs_by_name -= O_BRAIN // this is SOOO wrong.

	target:brain_op_stage = 4.0
	target.death()//You want them to die after the brain was transferred, so not to trigger client death() twice.

/datum/surgery_step/brain/saw_spine/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\red [user]'s hand slips, cutting a vein in [target]'s brain with \the [tool]!", \
	"\red Your hand slips, cutting a vein in [target]'s brain with \the [tool]!")
	target.apply_damage(30, BRUTE, BP_HEAD, 1, DAM_SHARP)
	if (ishuman(user))
		user:bloody_body(target)
		user:bloody_hands(target, 0)


//////////////////////////////////////////////////////////////////
//				BRAIN DAMAGE FIXING								//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain/bone_chips
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100, 		\
	/obj/item/weapon/wirecutters = 75, 		\
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/brain/bone_chips/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	return ..() && target.brain_op_stage == 2

/datum/surgery_step/brain/bone_chips/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts taking bone chips out of [target]'s brain with \the [tool].", \
	"You start taking bone chips out of [target]'s brain with \the [tool].")
	..()

/datum/surgery_step/brain/bone_chips/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\blue [user] takes out all the bone chips in [target]'s brain with \the [tool].",	\
	"\blue You take out all the bone chips in [target]'s brain with \the [tool].")
	target.brain_op_stage = 3


/datum/surgery_step/brain/bone_chips/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\red [user]'s hand slips, jabbing \the [tool] in [target]'s brain!", \
	"\red Your hand slips, jabbing \the [tool] in [target]'s brain!")
	target.apply_damage(30, BRUTE, BP_HEAD, 1, DAM_SHARP)

/datum/surgery_step/brain/hematoma
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, \
	/obj/item/stack/cable_coil = 75
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/brain/hematoma/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	return ..() && target.brain_op_stage == 3

/datum/surgery_step/brain/hematoma/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts mending hematoma in [target]'s brain with \the [tool].", \
	"You start mending hematoma in [target]'s brain with \the [tool].")
	..()

/datum/surgery_step/brain/hematoma/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\blue [user] mends hematoma in [target]'s brain with \the [tool].",	\
	"\blue You mend hematoma in [target]'s brain with \the [tool].")
	var/obj/item/organ/internal/brain/IO = target.organs_by_name[O_BRAIN]
	if (IO)
		IO.damage = 0


/datum/surgery_step/brain/hematoma/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("\red [user]'s hand slips, bruising [target]'s brain with \the [tool]!", \
	"\red Your hand slips, bruising [target]'s brain with \the [tool]!")
	target.apply_damage(20, BRUTE, BP_HEAD, 1, DAM_SHARP)

//////////////////////////////////////////////////////////////////
//				SLIME CORE EXTRACTION							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/slime/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	return istype(target, /mob/living/carbon/slime) && target.stat == DEAD

/datum/surgery_step/slime/cut_flesh
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 30
	max_duration = 50

/datum/surgery_step/slime/cut_flesh/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	if(!isslime(target))	return 0
	return ..() && target.brain_op_stage == 0

/datum/surgery_step/slime/cut_flesh/begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting through [target]'s flesh with \the [tool].", \
	"You start cutting through [target]'s flesh with \the [tool].")

/datum/surgery_step/slime/cut_flesh/end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("\blue [user] cuts through [target]'s flesh with \the [tool].",	\
	"\blue You cut through [target]'s flesh with \the [tool], exposing the cores.")
	target.brain_op_stage = 1

/datum/surgery_step/slime/cut_flesh/fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("\red [user]'s hand slips, tearing [target]'s flesh with \the [tool]!", \
	"\red Your hand slips, tearing [target]'s flesh with \the [tool]!")

/datum/surgery_step/slime/cut_innards
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 30
	max_duration = 50

/datum/surgery_step/slime/cut_innards/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	if(!isslime(target))	return 0
	return ..() && target.brain_op_stage == 1

/datum/surgery_step/slime/cut_innards/begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting [target]'s silky innards apart with \the [tool].", \
	"You start cutting [target]'s silky innards apart with \the [tool].")

/datum/surgery_step/slime/cut_innards/end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("\blue [user] cuts [target]'s innards apart with \the [tool], exposing the cores.",	\
	"\blue You cut [target]'s innards apart with \the [tool], exposing the cores.")
	target.brain_op_stage = 2

/datum/surgery_step/slime/cut_innards/fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("\red [user]'s hand slips, tearing [target]'s innards with \the [tool]!", \
	"\red Your hand slips, tearing [target]'s innards with \the [tool]!")

/datum/surgery_step/slime/saw_core
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75,       \
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/slime/saw_core/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	if(!isslime(target))	return 0
	return ..() && target.brain_op_stage == 2 && target.cores > 0

/datum/surgery_step/slime/saw_core/begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting out one of [target]'s cores with \the [tool].", \
	"You start cutting out one of [target]'s cores with \the [tool].")

/datum/surgery_step/slime/saw_core/end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	target.cores--
	user.visible_message("\blue [user] cuts out one of [target]'s cores with \the [tool].",,	\
	"\blue You cut out one of [target]'s cores with \the [tool]. [target.cores] cores left.")

	if(target.cores >= 0)
		new target.coretype(target.loc)
	if(target.cores <= 0)
		var/origstate = initial(target.icon_state)
		target.icon_state = "[origstate] dead-nocore"


/datum/surgery_step/slime/saw_core/fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("\red [user]'s hand slips, causing \him to miss the core!", \
	"\red Your hand slips, causing you to miss the core!")
