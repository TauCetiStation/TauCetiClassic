/obj/item/weapon/shield_belt
    name = "shield belt"
    icon = 'icons/obj/clothing/belts.dmi'
    desc = "Protective energy belt for personal use"
    item_color = "shield_belt"
    item_state = "shield_belt"
    icon_state = "shieldbelt"
    slot_flags = SLOT_FLAGS_BELT
    w_class = ITEM_SIZE_LARGE

/obj/item/weapon/shield_belt/atom_init()
    . = ..()
    var/obj/effect/effect/forcefield/energy_field/F = new
    AddComponent(/datum/component/forcefield, "energy field", 80, 8 SECONDS, 16 SECONDS, F, TRUE, TRUE)

/obj/item/weapon/shield_belt/equipped(mob/user, slot)
    if(slot == SLOT_BELT)
        SEND_SIGNAL(src, COMSIG_FORCEFIELD_PROTECT, user)
    else if(slot_equipped == SLOT_BELT)
        SEND_SIGNAL(src, COMSIG_FORCEFIELD_UNPROTECT, user)

/obj/item/weapon/shield_belt/dropped(mob/user)
    if(slot_equipped == SLOT_BELT)
        SEND_SIGNAL(src, COMSIG_FORCEFIELD_UNPROTECT, user)