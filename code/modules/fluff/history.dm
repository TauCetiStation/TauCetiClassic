/datum/custom_items_history
	var/ckey
	var/admin_ckey
	var/reason
	var/ammount

/proc/get_custom_items_history(ckey)
	customItemsCache.cd = "/"
	var/list/slots = null
	customItemsCache["slots_history"] >> slots
	if(!slots)
		slots = list()
	if(!slots[ckey])
		return list()
	return slots[ckey]

/proc/add_custom_items_history(player_ckey, admin_ckey, reason, ammount)
	player_ckey = ckey(player_ckey)
	admin_ckey = ckey(admin_ckey)

	ammount = round(ammount)
	if(ammount < 0)
		ammount = 0

	customItemsCache.cd = "/"
	var/list/slots = null
	customItemsCache["slots_history"] >> slots
	if(!slots)
		slots = list()

	var/datum/custom_items_history/entry = new /datum/custom_items_history()
	entry.ckey = player_ckey
	entry.admin_ckey = admin_ckey
	entry.reason = reason
	entry.ammount = ammount

	if(!slots[player_ckey])
		slots[player_ckey] = list()

	slots[player_ckey] += entry
	customItemsCache["slots_history"] << slots

	custom_items_calculate_slots(player_ckey)

/proc/remove_custom_items_history(player_ckey, index)
	player_ckey = ckey(player_ckey)

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
	var/ammount = 0
	for(var/datum/custom_items_history/entry in history)
		ammount += entry.ammount

	customItemsCache.cd = "/"
	var/list/slots = null
	customItemsCache["slots"] >> slots
	if(!slots)
		slots = list()

	if(!(player_ckey in slots))
		slots[player_ckey] = 0

	slots[player_ckey] = ammount
	if(slots[player_ckey] < 0)
		slots[player_ckey] = 0

	customItemsCache["slots"] << slots

/proc/get_custom_items_slot_all()
	customItemsCache.cd = "/"
	var/list/slots = null
	customItemsCache["slots"] >> slots
	if(!slots)
		slots = list()
	return slots

/client/proc/add_custom_item_slot(ammount = 1)
	customItemsCache.cd = "/"
	var/list/slots = null
	customItemsCache["slots"] >> slots
	if(!slots)
		slots = list()

	if(!(ckey in slots))
		slots[ckey] = 0

	slots[ckey] += ammount
	if(slots[ckey] < 0)
		slots[ckey] = 0

	customItemsCache["slots"] << slots