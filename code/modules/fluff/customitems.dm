var/savefile/customItemsCache = new /savefile("data/customItemsCache.sav")

/obj/item/customitem
	name = "Custom item"
	desc = "custom item."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle"
	item_state = "candle"

/client/proc/get_custom_items_slot_count()
	customItemsCache.cd = "/"
	var/list/slots = null
	customItemsCache["slots"] >> slots
	if(!slots)
		slots = list()

	var/ammount = 10 // will be 0

	if(ckey in slots)
		ammount += slots[ckey]

	//all your donator checks go here
	if(supporter)
		ammount += 1

	return ammount

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

/client/proc/add_custom_item(item_name, item_desc, item_icon, item_iconname)
	var/itemCount = 0
	var/slotCount = get_custom_items_slot_count()

	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()
	itemCount = items.len

	if(slotCount <= itemCount) // can't create, we have too much custom items
		return

	var/item = list()
	item["name"] = item_name
	item["desc"] = item_desc
	item["icon"] = item_icon
	item["iconname"] = item_iconname

	items += list(item)
	customItemsCache["items"] << items

/client/proc/get_custom_items()
	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()
	return items

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
		var/custom_item_info = null
		for(var/info in all_my_custom_items)
			if(thing == info["name"])
				custom_item_info = info
				break
		if(!custom_item_info)
			continue

		//item spawning
		var/obj/item/customitem/item = new /obj/item/customitem(null)
		item.name = custom_item_info["name"]
		item.desc = custom_item_info["desc"]
		item.icon = custom_item_info["icon"]
		item.icon_state = custom_item_info["iconname"]
		item.item_state = custom_item_info["iconname"]

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