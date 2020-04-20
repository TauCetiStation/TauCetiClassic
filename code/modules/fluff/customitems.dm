#define FLUFF_FILE_PATH "data/customItemsCache.sav"

/obj/item/customitem
	name = "Custom item"

/obj/item/weapon/lighter/zippo/custom
	name = "Custom zippo"

/obj/item/clothing/head/custom
	name = "Custom hat"
	body_parts_covered = 0

/obj/item/clothing/under/custom
	name = "Custom uniform"
	body_parts_covered = 0

/obj/item/clothing/suit/custom
	name = "Custom suit"
	body_parts_covered = 0

/obj/item/clothing/mask/custom
	name = "Custom mask"
	body_parts_covered = 0

/obj/item/clothing/glasses/custom
	name = "Custom glasses"
	body_parts_covered = 0

/obj/item/clothing/gloves/custom
	name = "Custom gloves"
	body_parts_covered = 0
	species_restricted = null

/obj/item/clothing/shoes/custom
	name = "Custom shoes"
	body_parts_covered = 0
	species_restricted = null

/obj/item/clothing/accessory/custom
	name = "Custom accessory"

/obj/item/clothing/suit/storage/labcoat/custom
	name = "Custom labcoat"


/datum/custom_item
	var/item_type // normal, small, lighter
	var/name
	var/desc
	var/icon
	var/icon_state

	var/status // submitted accepted rejected
	var/moderator_message

	var/sprite_author
	var/info

/client/proc/get_custom_items_slot_count()
	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/"
	var/list/slots = null
	customItemsCache["slots"] >> slots
	if(!slots)
		slots = list()

	var/ammount = 0

	//all your donator checks go here
	if(supporter)
		ammount += 1

	if(ckey in admin_datums)
		ammount += 1

	if(isnum(player_ingame_age) && player_ingame_age >= config.customitem_slot_by_time)
		ammount += 1

	if(ckey in slots)
		ammount += slots[ckey]

	if(ammount < 0)
		ammount = 0

	return ammount

/proc/custom_items_fixnames(ckey)
	var/list/items = get_custom_items(ckey)
	if(!items || !items.len)
		return

	var/dirty = FALSE
	for(var/old_item_name in items)
		var/datum/custom_item/item = items[old_item_name]
		if(old_item_name != ckey(item.name))
			items[ckey(item.name)] = item
			items -= old_item_name
			dirty = TRUE

	if(dirty)
		var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
		customItemsCache.cd = "/items/[ckey]"
		customItemsCache["items"] << items

/client/proc/add_custom_item(datum/custom_item/item)
	var/itemCount = 0
	var/slotCount = get_custom_items_slot_count()

	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()
	itemCount = items.len

	if(slotCount <= itemCount) // can't create, we have too much custom items
		return FALSE

	items[ckey(item.name)] = item
	customItemsCache["items"] << items
	return TRUE

/client/proc/remove_custom_item(itemname)
	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()

	items -= ckey(itemname)

	customItemsCache["items"] << items

/client/proc/edit_custom_item(datum/custom_item/newitem, oldname)
	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()

	var/datum/custom_item/item = items[oldname]
	if(!item)
		return

	items -= ckey(oldname)
	items[ckey(newitem.name)] = newitem

	customItemsCache["items"] << items
	return TRUE

/proc/get_custom_items(ckey)
	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()
	return items

/proc/get_custom_item(ckey, itemname)
	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()

	return items[ckey(itemname)]

/proc/custom_item_changestatus(ckey, itemname, status, moderator_message = "")
	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/items/[ckey]"
	var/list/items = null
	customItemsCache["items"] >> items
	if(!items)
		items = list()

	var/datum/custom_item/item = items[ckey(itemname)]
	if(!item)
		return
	item.status = status
	item.moderator_message = moderator_message

	customItemsCache["items"] << items

/datum/preferences/proc/toggle_custom_item(mob/user, item_name)
	var/datum/custom_item/item = get_custom_item(user.client.ckey, item_name)
	if(!item)
		return

	if(item_name in custom_items)
		custom_items -= item_name
	else if(item.status == "accepted")
		custom_items += ckey(item_name)

/proc/give_custom_items(mob/living/carbon/human/H, datum/job/job)
	if(!H.client.prefs.custom_items || !H.client.prefs.custom_items.len || !job.give_loadout_items)
		return

	var/list/custom_items = H.client.prefs.custom_items
	var/list/all_my_custom_items = get_custom_items(H.client.ckey)
	for(var/thing in custom_items)
		var/datum/custom_item/custom_item_info = all_my_custom_items[ckey(thing)]
		if(!custom_item_info)
			continue
		if(custom_item_info.status != "accepted")
			continue

		//item spawning
		var/obj/item/item = null

		switch(custom_item_info.item_type)
			if("normal", "small")
				item = new /obj/item/customitem()
			if("lighter")
				var/obj/item/weapon/lighter/zippo/custom/zippo = new /obj/item/weapon/lighter/zippo/custom()
				zippo.icon_on = "[custom_item_info.icon_state]_on"
				zippo.icon_off = custom_item_info.icon_state
				item = zippo
			if("hat")
				item = new /obj/item/clothing/head/custom()
			if("uniform")
				item = new /obj/item/clothing/under/custom()
			if("suit")
				item = new /obj/item/clothing/suit/custom()
			if("mask")
				item = new /obj/item/clothing/mask/custom()
			if("glasses")
				item = new /obj/item/clothing/glasses/custom()
			if("gloves")
				item = new /obj/item/clothing/gloves/custom()
			if("shoes")
				item = new /obj/item/clothing/shoes/custom()
			if("accessory")
				var/obj/item/clothing/accessory/custom/accessory = new /obj/item/clothing/accessory/custom()
				accessory.inv_overlay = image("icon" = custom_item_info.icon, "icon_state" = "[custom_item_info.icon_state]_inv")
				item = accessory
			if("labcoat")
				var/obj/item/clothing/suit/storage/labcoat/custom/labcoat = new /obj/item/clothing/suit/storage/labcoat/custom()
				if(!("[custom_item_info.icon_state]_open" in icon_states(custom_item_info.icon)))
					labcoat.can_button_up = FALSE
				labcoat.base_icon_state = custom_item_info.icon_state
				item = labcoat

		if(!item)
			continue
		item.name = custom_item_info.name
		item.desc = custom_item_info.desc
		if(custom_item_info.sprite_author)
			item.desc = "[item.desc]<br><small><span style='color:#00BFFF;'><i>sprite author:</i> [custom_item_info.sprite_author]</span></small>"
		item.icon = custom_item_info.icon
		item.icon_custom = custom_item_info.icon
		item.icon_state = custom_item_info.icon_state
		item.item_state = custom_item_info.icon_state
		item.item_color = custom_item_info.icon_state
		if(custom_item_info.item_type == "small")
			item.w_class = ITEM_SIZE_SMALL


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
		world.log << "Failed to locate a storage object for [H], either he spawned with no arms and no backpack or this is a bug"
		qdel(item)
