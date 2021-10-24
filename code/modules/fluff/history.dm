/datum/custom_items_history
	var/ckey
	var/admin_ckey
	var/reason
	var/amount

/proc/get_custom_items_history(ckey)
	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/"
	var/list/slots = null
	customItemsCache["slots_history"] >> slots
	if(!slots)
		slots = list()
	if(!slots[ckey])
		return list()
	return slots[ckey]

/proc/add_custom_items_history(player_ckey, admin_ckey, reason, amount)
	player_ckey = ckey(player_ckey)
	admin_ckey = ckey(admin_ckey)

	amount = round(amount)

	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/"
	var/list/slots = null
	customItemsCache["slots_history"] >> slots
	if(!slots)
		slots = list()

	var/datum/custom_items_history/entry = new /datum/custom_items_history()
	entry.ckey = player_ckey
	entry.admin_ckey = admin_ckey
	entry.reason = reason
	entry.amount = amount

	if(!slots[player_ckey])
		slots[player_ckey] = list()

	slots[player_ckey] += entry
	customItemsCache["slots_history"] << slots

	custom_items_calculate_slots(player_ckey)

/proc/remove_custom_items_history(player_ckey, index)
	player_ckey = ckey(player_ckey)

	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/"
	var/list/slots = null
	customItemsCache["slots_history"] >> slots
	if(!slots || !slots[player_ckey])
		return

	var/list/history = slots[player_ckey]
	if(index < 1 || index > history.len)
		return

	slots[player_ckey] -= slots[player_ckey][index]
	customItemsCache["slots_history"] << slots

	custom_items_calculate_slots(player_ckey)


/proc/custom_items_calculate_slots(player_ckey)
	var/list/history = get_custom_items_history(player_ckey)
	var/amount = 0
	for(var/datum/custom_items_history/entry in history)
		amount += entry.amount

	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/"
	var/list/slots = null
	customItemsCache["slots"] >> slots
	if(!slots)
		slots = list()

	if(!(player_ckey in slots))
		slots[player_ckey] = 0

	slots[player_ckey] = amount

	customItemsCache["slots"] << slots

/proc/get_custom_items_slot_all()
	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/"
	var/list/slots = null
	customItemsCache["slots"] >> slots
	if(!slots)
		slots = list()
	return slots
