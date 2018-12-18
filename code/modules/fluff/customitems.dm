var/savefile/customItemsCache = new /savefile("data/customItemsCache.sav")

/obj/item/customitem
	name = "Custom item"
	desc = "custom item."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle"
	item_state = "candle"

/datum/custom_item
	var/item_type // normal, lighter
	var/name
	var/desc
	var/icon
	var/icon_state

	var/status // submitted accepted rejected
	var/moderator_message

/client/proc/get_custom_items_slot_count()
	customItemsCache.cd = "/"
	var/list/slots = null
	customItemsCache["slots"] >> slots
	if(!slots)
		slots = list()

	var/ammount = 0

	if(ckey in slots)
		ammount += slots[ckey]

	//all your donator checks go here
	if(supporter)
		ammount += 1

	return ammount

/client/proc/add_custom_item(datum/custom_item/item)
	var/itemCount = 0
	var/slotCount = get_custom_items_slot_count()

	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()
	itemCount = items.len

	if(slotCount <= itemCount) // can't create, we have too much custom items
		return FALSE

	items += item
	customItemsCache["items"] << items
	return TRUE

/client/proc/remove_custom_item(itemname)
	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()

	for(var/datum/custom_item/item in items)
		if(itemname == item.name)
			items -= item
			break

	customItemsCache["items"] << items

/client/proc/edit_custom_item(datum/custom_item/newitem, oldname)
	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()

	for(var/datum/custom_item/item in items)
		if(oldname == item.name)
			item.name = newitem.name
			item.item_type = newitem.item_type
			item.desc = newitem.desc
			item.icon = newitem.icon
			item.icon_state = newitem.icon_state

			item.status = newitem.status
			item.moderator_message = newitem.moderator_message
			break

	customItemsCache["items"] << items
	return TRUE

/client/proc/get_custom_items()
	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()
	return items

/proc/get_custom_item(ckey, itemname)
	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()

	for(var/datum/custom_item/item in items)
		if(item.name == itemname)
			return item
	return null

/proc/custom_item_changestatus(ckey, itemname, status, moderator_message = "")
	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()

	for(var/datum/custom_item/item in items)
		if(item.name == itemname)
			item.status = status
			item.moderator_message = moderator_message
			break
	customItemsCache["items"] << items

/datum/preferences/proc/toggle_custom_item(mob/user, item_name)
	if(item_name in custom_items)
		custom_items -= item_name
		//to_chat(user, "REMOVED [item_name]")
	else
		custom_items += item_name
		//to_chat(user, "ADDED [item_name]")

/proc/give_custom_items(mob/living/carbon/human/H, datum/job/job)
	if(!H.client.prefs.custom_items || !H.client.prefs.custom_items.len || job.title == "Cyborg" || job.title == "AI")
		return

	var/list/custom_items = H.client.prefs.custom_items
	var/list/all_my_custom_items = H.client.get_custom_items()
	for(var/thing in custom_items)
		var/datum/custom_item/custom_item_info = null
		for(var/datum/custom_item/info in all_my_custom_items)
			if(thing == info.name)
				custom_item_info = info
				break
		if(!custom_item_info)
			continue
		if(custom_item_info.status != "accepted")
			continue

		//item spawning
		var/obj/item/customitem/item = new /obj/item/customitem(null)
		item.name = custom_item_info.name
		item.desc = custom_item_info.desc
		item.icon = custom_item_info.icon
		item.icon_state = custom_item_info.icon_state
		item.item_state = custom_item_info.icon_state

		var/atom/placed_in = H.equip_or_collect(item)
		if(placed_in)
			to_chat(H, "<span class='notice'>Placing \the [item] in your [placed_in.name]!</span>")
			continue
		if(H.equip_to_appropriate_slot(item))
			to_chat(H, "<span class='notice'>Placing \the [item] in your inventory!</span>")
			continue
		if(H.put_in_hands(item))
			to_chat(H, "<span class='notice'>Placing \the [item] in your hands!</span>")
			continue
		to_chat(H, "<span class='danger'>Failed to locate a storage object on your mob, either you spawned with no arms and no backpack or this is a bug.</span>")
		qdel(item)