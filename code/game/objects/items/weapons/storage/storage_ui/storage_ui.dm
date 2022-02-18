/datum/storage_ui
	var/obj/item/weapon/storage/storage
	var/list/click_border_start = list() //In slotless storage, stores areas where clicking will refer to the associated item
	var/list/click_border_end = list()

/datum/storage_ui/New(storage)
	src.storage = storage
	..()

/datum/storage_ui/Destroy()
	storage = null
	. = ..()

/datum/storage_ui/proc/show_to(mob/user)
	return

/datum/storage_ui/proc/hide_from(mob/user)
	return

/datum/storage_ui/proc/prepare_ui()
	return

/datum/storage_ui/proc/close_all()
	return

/datum/storage_ui/proc/on_open(mob/user)
	return

/datum/storage_ui/proc/after_close(mob/user)
	return

/datum/storage_ui/proc/on_insertion(mob/user)
	return

/datum/storage_ui/proc/on_pre_remove(mob/user, obj/item/W)
	return

/datum/storage_ui/proc/on_post_remove(mob/user, obj/item/W)
	return

/datum/storage_ui/proc/on_hand_attack(mob/user)
	return
