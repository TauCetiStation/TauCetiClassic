#define HIDINGCACHE_TIP "Тайник."

/datum/mechanic_tip/hiding_cache
	tip_name = HIDINGCACHE_TIP

/datum/mechanic_tip/hiding_cache/New(datum/component/hiding_cache/HC)
	description = "Вы можете проверить тайник кликнув CTRL+SHIFT+LMB на [HC.parent]."


/datum/component/hiding_cache
	var/obj/item/weapon/storage/internal/cache_storage
	var/obj/parent_object

/datum/component/hiding_cache/Initialize(w_size = SIZE_TINY)
	parent_object = parent
	cache_storage = new(parent_object)
	cache_storage.set_slots(slots = 1, slot_size = w_size)


	var/datum/mechanic_tip/hiding_cache/cache_tip = new(src)
	parent.AddComponent(/datum/component/mechanic_desc, list(cache_tip), CALLBACK(src, PROC_REF(can_show_cache)))

	RegisterSignal(parent_object, list(COMSIG_PARENT_CTRLSHIFTCLICKED), PROC_REF(open_cache))

	RegisterSignal(parent_object, list(COMSIG_PARENT_QDELETING), PROC_REF(on_destroyed))

/datum/component/hiding_cache/proc/can_show_cache(obj/item/source, mob/user)
	return parent_object.Adjacent(user)

/datum/component/hiding_cache/proc/open_cache(datum/source, mob/user)
	user.visible_message("<span class='danger'>[user] возится с [parent_object]...</span>")
	if(!do_after(user, 50 , target = parent_object))
		return

	user.SetNextMove(CLICK_CD_MELEE)
	cache_storage.open(user)

/datum/component/hiding_cache/proc/on_destroyed()
	qdel(src)

/datum/component/hiding_cache/Destroy()
	SEND_SIGNAL(parent_object, COMSIG_TIPS_REMOVE, list(HIDINGCACHE_TIP))
	UnregisterSignal(parent_object, list(COMSIG_PARENT_CTRLSHIFTCLICKED, COMSIG_PARENT_QDELETING))

	cache_storage.spill()
	qdel(cache_storage)
	return ..()
