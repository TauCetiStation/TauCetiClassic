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

/obj/item/clothing/neck/fanatics_necklace
	name = "green necklace"
	desc = "Green necklace. The most ordinary green necklace without any special properties. Exactly."
	icon_state = "fanaticscharm"
	item_state = "fanaticscharm"

/obj/item/clothing/neck/fanatics_necklace/atom_init()
	. = ..()

	var/obj/effect/effect/forcefield/red/R = new
	AddComponent(/datum/component/forcefield, "strong blood aura", 40, 15 SECONDS, 25 SECONDS, R, FALSE, TRUE)

/obj/item/clothing/neck/fanatics_necklace/proc/activate(mob/living/user)
	if(isfanatic(user))
		SEND_SIGNAL(src, COMSIG_FORCEFIELD_PROTECT, user)

/obj/item/clothing/neck/fanatics_necklace/proc/deactivate(mob/living/user)
	SEND_SIGNAL(src, COMSIG_FORCEFIELD_UNPROTECT, user)

/obj/item/clothing/neck/fanatics_necklace/equipped(mob/living/user, slot)
	. = ..()
	if(slot == SLOT_NECK)
		activate(user)

/obj/item/clothing/neck/fanatics_necklace/dropped(mob/living/user)
	. = ..()
	if(slot_equipped == SLOT_NECK)
		deactivate(user)

/obj/item/clothing/neck/fanatics_necklace/examine(mob/user)
	. = ..()
	if(isfanatic(user))
		to_chat(user, "<span class='fanatics'>Wearing this amulet around the neck will receive protection from damage.</span>")
