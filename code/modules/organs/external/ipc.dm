#define IPC_UPDATE_SPRITE \
	var/gender = owner ? owner.gender : MALE; \
	var/mutations = owner ? owner.mutations : list(); \
	var/fat; \
	var/g; \
	if(body_zone == BP_CHEST) { \
		fat = (FAT in mutations) ? "fat" : null; \
	} \
	if(body_zone in list(BP_CHEST, BP_GROIN, BP_HEAD)) { \
		g = (gender == FEMALE ? "f" : "m"); \
	} \
	if (!species.has_gendered_icons) { \
		g = null; \
	}\
	icon = species.icobase; \
	icon_state = "[body_zone][g ? "_[g]" : ""][fat ? "_[fat]" : ""]";

/obj/item/organ/external/chest/robot/ipc
	name = "ipc chest"

/obj/item/organ/external/chest/robot/ipc/update_sprite()
	IPC_UPDATE_SPRITE

/obj/item/organ/external/head/robot/ipc
	name = "ipc head"
	vital = FALSE

/obj/item/organ/external/head/robot/ipc/is_compatible(mob/living/carbon/human/H)
	if(H.species.name == IPC)
		return TRUE

	return FALSE

/obj/item/organ/external/head/robot/ipc/update_sprite()
	IPC_UPDATE_SPRITE

/obj/item/organ/external/groin/robot/ipc
	name = "ipc groin"

/obj/item/organ/external/groin/robot/ipc/update_sprite()
	IPC_UPDATE_SPRITE

/obj/item/organ/external/l_arm/robot/ipc
	name = "left ipc arm"

/obj/item/organ/external/l_arm/robot/ipc/update_sprite()
	IPC_UPDATE_SPRITE

/obj/item/organ/external/r_arm/robot/ipc
	name = "right ipc arm"

/obj/item/organ/external/r_arm/robot/ipc/update_sprite()
	IPC_UPDATE_SPRITE

/obj/item/organ/external/r_leg/robot/ipc
	name = "right ipc leg"

/obj/item/organ/external/r_leg/robot/ipc/update_sprite()
	IPC_UPDATE_SPRITE

/obj/item/organ/external/l_leg/robot/ipc
	name = "left ipc leg"

/obj/item/organ/external/l_leg/robot/ipc/update_sprite()
	IPC_UPDATE_SPRITE

#undef IPC_UPDATE_SPRITE