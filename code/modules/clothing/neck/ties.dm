/obj/item/clothing/neck/collar
	name = "silver collar"
	desc = "A common collar with silver covering"
	icon_state = "collar"

/obj/item/clothing/neck/collar2
	name = "gold collar"
	desc = "A common collar with gold covering"
	icon_state = "collar2"

/obj/item/clothing/neck/silver_cross
	name = "pectoral silver cross"
	desc = "That's a big pectoral silver cross for big religion figures."
	icon_state = "pectoral_silver_cross"
	item_state = "pectoral_silver_cross"

/obj/item/clothing/neck/golden_cross
	name = "pectoral golden cross"
	desc = "That's a big pectoral golden cross for the biggest religion figure."
	icon_state = "pectoral_golden_cross"
	item_state = "pectoral_golden_cross"

/obj/item/clothing/neck/unathi_mantle
	name = "hide mantle"
	desc = "A rather grisly selection of cured hides and skin, sewn together to form a ragged mantle."
	icon_state = "mantle-unathi"
	item_state = "mantle-unathi"
	body_parts_covered = UPPER_TORSO

/obj/item/clothing/neck/airbag
	name = "personal airbag"
	desc = "One-use protection from high-speed collisions and low pressure."
	icon_state = "airbag"
	item_state = "airbag"
	slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_NECK
	var/deployed = FALSE

/obj/item/clothing/neck/airbag/proc/deploy(mob/user)
	if(deployed)
		return
	deployed = TRUE
	user.drop_from_inventory(src, get_turf(src))
	icon_state = "airbag_deployed"
	anchored = TRUE
	user.forceMove(src)
	ADD_TRAIT(user, TRAIT_AIRBAG_PROTECTION, GENERIC_TRAIT)
	to_chat(user, "<span class='warning'>Your [src] deploys!</span>")
	playsound(src, 'sound/effects/inflate.ogg', VOL_EFFECTS_MASTER)
	addtimer(CALLBACK(src, PROC_REF(delete), user), 5 SECOND)

/obj/item/clothing/neck/airbag/proc/delete(mob/user)
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(src))
	REMOVE_TRAIT(user, TRAIT_AIRBAG_PROTECTION, GENERIC_TRAIT)
	qdel(src)
