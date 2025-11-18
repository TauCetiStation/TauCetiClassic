#define HIDINGCACHE_TIP "Тайник."

/datum/mechanic_tip/hiding_cache
	tip_name

/datum/mechanic_tip/hiding_cache/New(datum/component/hiding_cache/HC)
	description = "Вы можете проверить тайник кликнув CTRL+SHIFT+LMB на [HC.parent]."


/datum/component/hiding_cache
	var/obj/item/weapon/storage/internal/cache_storage
	var/obj/parent_object

	var/storage_item_needed
	var/storage_w_class
	var/storage_sound

	var/datum/callback/parent_open_check

	var/datum/mechanic_tip/hiding_cache/cache_tip

/datum/component/hiding_cache/Initialize(w_size = SIZE_TINY, item_needed = null, use_sound = null, datum/callback/_parent_open_check = null)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	parent_object = parent

	if(item_needed)
		storage_item_needed = item_needed
		storage_w_class = w_size
		storage_sound = use_sound
	else
		setup_cache(w_size, use_sound)

	cache_tip = new(src)
	cache_tip.tip_name = "<a href=byond://?_src_=usr;lookcache=\ref[src]>[HIDINGCACHE_TIP]</a>"
	parent.AddComponent(/datum/component/mechanic_desc, list(cache_tip), CALLBACK(src, PROC_REF(can_show_cache_tip)))

	if(_parent_open_check)
		parent_open_check = _parent_open_check

	RegisterSignal(parent_object, list(COMSIG_PARENT_QDELETING), PROC_REF(destroy_cache))
	RegisterSignal(parent_object, list(COMSIG_PARENT_CTRLSHIFTCLICKED), PROC_REF(try_open_cache))

/datum/component/hiding_cache/proc/setup_cache(w_size, use_sound)
	cache_storage = new(parent_object)
	cache_storage.set_slots(slots = 1, slot_size = w_size)

	if(use_sound)
		cache_storage.use_sound = use_sound

/datum/component/hiding_cache/proc/can_show_cache_tip(obj/item/source, mob/user)
	return parent_object.Adjacent(user)

/datum/component/hiding_cache/proc/try_open_cache(datum/source, mob/user)
	if(user.is_busy(parent_object) || user.incapacitated() || !parent_object.Adjacent(user))
		return

	if(parent_open_check && !parent_open_check.Invoke())
		return

	user.visible_message("<span class='danger'>[user] возится с [parent_object]...</span>")

	var/obj/item/I = user.get_active_hand()
	if(I && istype(I, storage_item_needed))
		to_chat(user, "Создание тайника...")

		if(!do_after(user, 30 , target = parent_object))
			return

		if(cache_storage)
			to_chat(user, "В [parent_object] тайник уже есть.")
			return

		setup_cache(storage_w_class, storage_sound)
		to_chat(user, "Тайник создан.")
		return

	if(!do_after(user, 30 , target = parent_object))
		return

	if(!cache_storage)
		to_chat(user, "Тайников не найдено.")
		return
	open_cache(user)

/datum/component/hiding_cache/proc/open_cache(mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	cache_storage.open(user)

/datum/component/hiding_cache/proc/destroy_cache()
	cache_storage.spill()
	QDEL_NULL(cache_storage)

/datum/component/hiding_cache/Destroy()
	SEND_SIGNAL(parent_object, COMSIG_TIPS_REMOVE, list(HIDINGCACHE_TIP))
	UnregisterSignal(parent_object, list(COMSIG_PARENT_CTRLSHIFTCLICKED, COMSIG_PARENT_QDELETING))

	SEND_SIGNAL(parent_object, COMSIG_TIPS_REMOVE, list(cache_tip.tip_name))

	if(cache_storage)
		destroy_cache()

	return ..()
