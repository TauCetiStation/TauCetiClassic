#define HIDINGCACHE_TIP "Тайник."

var/global/list/roundstart_caches = list()

/datum/mechanic_tip/hiding_cache
	tip_name = HIDINGCACHE_TIP

/datum/mechanic_tip/hiding_cache/New(datum/component/hiding_cache/HC)
	description = "Вы можете проверить тайник кликнув CTRL+SHIFT+LMB на [HC.parent]."


/datum/component/hiding_cache
	var/obj/item/weapon/storage/internal/cache_storage
	var/obj/parent_object

	var/storage_item_needed
	var/storage_w_class
	var/storage_sound

/datum/component/hiding_cache/Initialize(w_size = SIZE_TINY, item_needed = null, use_sound = null)
	parent_object = parent

	storage_w_class = w_size
	storage_sound = use_sound

	if(item_needed)
		storage_item_needed = item_needed
	else
		setup_cache()

	var/datum/mechanic_tip/hiding_cache/cache_tip = new(src)
	parent.AddComponent(/datum/component/mechanic_desc, list(cache_tip), CALLBACK(src, PROC_REF(can_show_cache_tip)))

	RegisterSignal(parent_object, list(COMSIG_PARENT_CTRLSHIFTCLICKED), PROC_REF(try_open_cache))

	RegisterSignal(parent_object, list(COMSIG_PARENT_QDELETING), PROC_REF(on_destroyed))

/datum/component/hiding_cache/proc/setup_cache(w_size, use_sound)
	cache_storage = new(parent_object)
	cache_storage.set_slots(slots = 1, slot_size = storage_w_class)

	add_to_roundstart_cache_list()

	if(storage_sound)
		cache_storage.use_sound = storage_sound

/datum/component/hiding_cache/proc/add_to_roundstart_cache_list()
	if(SSticker.current_state >= GAME_STATE_PLAYING)
		return

	if(!is_station_level(parent_object.z))
		return

	if(!global.roundstart_caches["[storage_w_class]"])
		global.roundstart_caches["[storage_w_class]"] = list()

	global.roundstart_caches["[storage_w_class]"] += cache_storage

/datum/component/hiding_cache/proc/can_show_cache_tip(obj/item/source, mob/user)
	return parent_object.Adjacent(user)

/datum/component/hiding_cache/proc/try_open_cache(datum/source, mob/user)
	if(user.is_busy(parent_object) || user.incapacitated() || !parent_object.Adjacent(user))
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

		setup_cache()
		to_chat(user, "Тайник создан.")
		return

	if(!do_after(user, 30 , target = parent_object))
		return

	if(!cache_storage)
		to_chat(user, "Тайников не найдено.")
		return
	open_cache(user)

/datum/component/hiding_cache/proc/open_cache(mob/user)
	if(cache_storage in global.roundstart_caches["[storage_w_class]"])
		global.roundstart_caches["[storage_w_class]"] -= cache_storage
	user.SetNextMove(CLICK_CD_MELEE)
	cache_storage.open(user)

/datum/component/hiding_cache/proc/on_destroyed()
	qdel(src)

/datum/component/hiding_cache/Destroy()
	SEND_SIGNAL(parent_object, COMSIG_TIPS_REMOVE, list(HIDINGCACHE_TIP))
	UnregisterSignal(parent_object, list(COMSIG_PARENT_CTRLSHIFTCLICKED, COMSIG_PARENT_QDELETING))

	if(cache_storage in global.roundstart_caches["[storage_w_class]"])
		global.roundstart_caches["[storage_w_class]"] -= cache_storage

	cache_storage.spill()
	qdel(cache_storage)
	return ..()
