/datum/bodypart_controller/robot/ipc // This is crutch for correct update body parts

/obj/item/organ/external/chest/robot/ipc
	name = "ipc chest"
	controller_type = /datum/bodypart_controller/robot/ipc

	// Only used for a quirk because our surgery code is stupid. Or dumb.
	var/posibrain_type = /obj/item/device/mmi/posibrain
	var/posibrain_species = IPC

/obj/item/organ/external/chest/robot/ipc/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]"

/obj/item/organ/external/head/robot/ipc
	name = "ipc head"
	vital = FALSE
	var/ipc_head = "Default"
	var/screen_toggle = TRUE
	var/screen_brightness = 2
	var/display_text

	controller_type = /datum/bodypart_controller/robot/ipc

/obj/item/organ/external/head/robot/ipc/is_compatible(mob/living/carbon/human/H)
	if(H.species.name == IPC)
		return TRUE

	return FALSE

/obj/item/organ/external/head/robot/ipc/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]_[ipc_head]"

/obj/item/organ/external/head/robot/ipc/cobalt
	ipc_head = "Cobalt"

/obj/item/organ/external/head/robot/ipc/cathod
	ipc_head = "Cathod"

/obj/item/organ/external/head/robot/ipc/thorax
	ipc_head = "Thorax"

/obj/item/organ/external/head/robot/ipc/axon
	ipc_head = "Axon"

/obj/item/organ/external/groin/robot/ipc
	name = "ipc groin"

	controller_type = /datum/bodypart_controller/robot/ipc

/obj/item/organ/external/groin/robot/ipc/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]"

/obj/item/organ/external/l_arm/robot/ipc
	name = "left ipc arm"

	controller_type = /datum/bodypart_controller/robot/ipc

/obj/item/organ/external/l_arm/robot/ipc/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]"

/obj/item/organ/external/r_arm/robot/ipc
	name = "right ipc arm"

	controller_type = /datum/bodypart_controller/robot/ipc

/obj/item/organ/external/r_arm/robot/ipc/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]"

/obj/item/organ/external/r_leg/robot/ipc
	name = "right ipc leg"

	controller_type = /datum/bodypart_controller/robot/ipc

/obj/item/organ/external/r_leg/robot/ipc/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]"

/obj/item/organ/external/l_leg/robot/ipc
	name = "left ipc leg"

	controller_type = /datum/bodypart_controller/robot/ipc

/obj/item/organ/external/l_leg/robot/ipc/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]"
