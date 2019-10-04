/obj/item/organ/external/chest/robot/ipc
	name = "ipc chest"
	controller_type = /datum/bodypart_controller/robot/morpheus

/obj/item/organ/external/head/robot/ipc
	name = "ipc head"
	controller_type = /datum/bodypart_controller/robot/morpheus
	vital = FALSE

/obj/item/organ/external/head/robot/ipc/is_compatible(mob/living/carbon/human/H)
	if(H.get_species() == IPC)
		return TRUE

	return FALSE

/obj/item/organ/external/groin/robot/ipc
	name = "ipc groin"
	controller_type = /datum/bodypart_controller/robot/morpheus

/obj/item/organ/external/l_arm/robot/ipc
	name = "left ipc arm"
	controller_type = /datum/bodypart_controller/robot/morpheus

/obj/item/organ/external/r_arm/robot/ipc
	name = "right ipc arm"
	controller_type = /datum/bodypart_controller/robot/morpheus

/obj/item/organ/external/r_leg/robot/ipc
	name = "right ipc leg"
	controller_type = /datum/bodypart_controller/robot/morpheus

/obj/item/organ/external/l_leg/robot/ipc
	name = "left ipc leg"
	controller_type = /datum/bodypart_controller/robot/morpheus
