#define FLUFF_FILE_PATH "data/customItemsCache.sav"

// not BLOCKHEADHAIR/BLOCKHAIR for savefile in case someone change them
// feel free to rename if more flags needed
#define FLUFF_HAIR_HIDE_NONE 0
#define FLUFF_HAIR_HIDE_HEAD 1 // BLOCKHEADHAIR
#define FLUFF_HAIR_HIDE_ALL 2 // BLOCKHAIR

#define FLUFF_HAIR_HIDE_FLAG_TO_TEXT(flag) (flag == 1 && "Head Hair" || flag == 2 && "Head & Face Hair" || "None")

// items
#define FLUFF_TYPE_NORMAL "normal"
#define FLUFF_TYPE_SMALL "small"
#define FLUFF_TYPE_LIGHTER "lighter"
#define FLUFF_TYPE_HAT "hat"
#define FLUFF_TYPE_UNIFORM "uniform"
#define FLUFF_TYPE_SUIT "suit"
#define FLUFF_TYPE_MASK "mask"
#define FLUFF_TYPE_GLASSES "glasses"
#define FLUFF_TYPE_GLOVES "gloves"
#define FLUFF_TYPE_SHOES "shoes"
#define FLUFF_TYPE_ACCESSORY "accessory"
#define FLUFF_TYPE_LABCOAT "labcoat"
#define FLUFF_TYPE_BACKPACK "backpack"
// other
//#define FLUFF_TYPE_ROBOT "robot"
#define FLUFF_TYPE_GHOST "ghost"

#define FLUFF_TYPES_LIST list(FLUFF_TYPE_NORMAL, FLUFF_TYPE_SMALL, FLUFF_TYPE_LIGHTER, FLUFF_TYPE_HAT, FLUFF_TYPE_UNIFORM, FLUFF_TYPE_SUIT, FLUFF_TYPE_MASK, FLUFF_TYPE_GLASSES, FLUFF_TYPE_GLOVES, FLUFF_TYPE_SHOES, FLUFF_TYPE_ACCESSORY, FLUFF_TYPE_LABCOAT, FLUFF_TYPE_BACKPACK, FLUFF_TYPE_GHOST)


/obj/item/customitem
	name = "Custom item"

/obj/item/weapon/lighter/zippo/custom
	name = "Custom zippo"

/obj/item/clothing/head/custom
	name = "Custom hat"
	body_parts_covered = 0

/obj/item/clothing/under/custom
	name = "Custom uniform"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

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

/obj/item/clothing/accessory/custom
	name = "Custom accessory"

/obj/item/clothing/suit/storage/labcoat/custom
	name = "Custom labcoat"

/obj/item/weapon/storage/backpack/custom
	name = "Custom backpack"


/datum/custom_item
	var/item_type // FLUFF_TYPES_LIST
	var/name
	var/desc
	var/icon
	var/icon_state

	var/hair_flags

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

	var/amount = 0

	//all your donator checks go here
	if(supporter)
		amount += 1

	if(ckey in admin_datums)
		amount += 1

	if(isnum(player_ingame_age) && player_ingame_age >= config.customitem_slot_by_time)
		amount += 1

	if(ckey in slots)
		amount += slots[ckey]

	if(amount < 0)
		amount = 0

	return amount

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

/proc/get_accepted_custom_items_by_type(ckey, type)
	. = list()

	var/list/custom_items = get_custom_items(ckey)
	for(var/item_name in custom_items)
		var/datum/custom_item/item = custom_items[item_name]
		if(item.item_type == type && item.status == "accepted")
			. += item

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

	if(item.item_type == FLUFF_TYPE_GHOST)
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
		if(custom_item_info.item_type == FLUFF_TYPE_GHOST)
			continue

		//item spawning
		var/obj/item/item = null

		switch(custom_item_info.item_type)
			if(FLUFF_TYPE_NORMAL, FLUFF_TYPE_SMALL)
				item = new /obj/item/customitem()
			if(FLUFF_TYPE_LIGHTER)
				var/obj/item/weapon/lighter/zippo/custom/zippo = new /obj/item/weapon/lighter/zippo/custom()
				zippo.icon_on = "[custom_item_info.icon_state]_on"
				zippo.icon_off = custom_item_info.icon_state
				item = zippo
			if(FLUFF_TYPE_HAT)
				item = new /obj/item/clothing/head/custom()
			if(FLUFF_TYPE_UNIFORM)
				item = new /obj/item/clothing/under/custom()
			if(FLUFF_TYPE_SUIT)
				item = new /obj/item/clothing/suit/custom()
			if(FLUFF_TYPE_MASK)
				item = new /obj/item/clothing/mask/custom()
			if(FLUFF_TYPE_GLASSES)
				item = new /obj/item/clothing/glasses/custom()
			if(FLUFF_TYPE_GLOVES)
				item = new /obj/item/clothing/gloves/custom()
			if(FLUFF_TYPE_SHOES)
				item = new /obj/item/clothing/shoes/custom()
			if(FLUFF_TYPE_BACKPACK)
				item = new /obj/item/weapon/storage/backpack/custom()
			if(FLUFF_TYPE_ACCESSORY)
				var/obj/item/clothing/accessory/custom/accessory = new /obj/item/clothing/accessory/custom()
				accessory.inv_overlay = image("icon" = custom_item_info.icon, "icon_state" = "[custom_item_info.icon_state]_inv")
				item = accessory
			if(FLUFF_TYPE_LABCOAT)
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

		switch(custom_item_info.hair_flags)
			if(FLUFF_HAIR_HIDE_HEAD)
				item.flags |= BLOCKHEADHAIR
			if(FLUFF_HAIR_HIDE_ALL)
				item.flags |= BLOCKHAIR

		if(custom_item_info.item_type == FLUFF_TYPE_SMALL)
			item.w_class = SIZE_TINY


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
