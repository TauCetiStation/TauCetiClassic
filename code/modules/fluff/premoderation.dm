/datum/premoderation_item
	var/item_name
	var/author_ckey

/proc/custom_item_premoderation_add(player_ckey, itemname)
	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/"
	var/list/moderation_items = null
	customItemsCache["premoderation"] >> moderation_items
	if(!moderation_items)
		moderation_items = list()

	for(var/datum/premoderation_item/entry in moderation_items)
		if(ckey(entry.item_name) == ckey(itemname) && ckey(player_ckey) == entry.author_ckey)
			return

	var/datum/premoderation_item/new_entry = new /datum/premoderation_item()
	new_entry.item_name = itemname
	new_entry.author_ckey = ckey(player_ckey)
	moderation_items += new_entry

	customItemsCache["premoderation"] << moderation_items

/proc/custom_item_premoderation_list()
	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/"
	var/list/moderation_items = null
	customItemsCache["premoderation"] >> moderation_items
	if(!moderation_items)
		moderation_items = list()
	return moderation_items

/proc/custom_item_premoderation_accept(player_ckey, itemname)
	itemname = ckey(itemname)
	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/"
	var/list/moderation_items = null
	customItemsCache["premoderation"] >> moderation_items
	if(!moderation_items)
		moderation_items = list()

	for(var/datum/premoderation_item/entry in moderation_items)
		if(ckey(entry.item_name) == itemname && ckey(player_ckey) == entry.author_ckey)
			moderation_items -= entry
			break

	customItemsCache["premoderation"] << moderation_items

	custom_item_changestatus(player_ckey, itemname, "accepted")

/proc/custom_item_premoderation_reject(player_ckey, itemname, reason)
	itemname = ckey(itemname)
	var/savefile/customItemsCache = new /savefile(FLUFF_FILE_PATH)
	customItemsCache.cd = "/"
	var/list/moderation_items = null
	customItemsCache["premoderation"] >> moderation_items
	if(!moderation_items)
		moderation_items = list()

	for(var/datum/premoderation_item/entry in moderation_items)
		if(ckey(entry.item_name) == itemname && ckey(player_ckey) == entry.author_ckey)
			moderation_items -= entry
			break

	customItemsCache["premoderation"] << moderation_items

	custom_item_changestatus(player_ckey, itemname, "rejected", reason)

/datum/admins/proc/customitemspremoderation_panel()
	set category = "Server"
	set name = "Whitelist Custom Items"
	set desc = "Allows you to review and accept custom items."

	src = usr.client.holder
	customitemsview_panel()

/datum/admins/proc/customitemsview_panel(player_ckey = null)
	src = usr.client.holder
	if(!check_rights(R_PERMISSIONS))
		return

	var/output = {"<!DOCTYPE html>
<html>
<head>
<title>Custom Items Panel</title>
<script type='text/javascript' src='search.js'></script>
<link rel='stylesheet' type='text/css' href='panels.css'>
</head>
<body onload='selectTextField();updateSearch();'>

<div id='main'><table id='searchable' cellspacing='0'>
<a class='small' href='?src=\ref[src];custom_items=moderation_viewbyckey'>View items by ckey</a><br>
<a class='small' href='?src=\ref[src];custom_items=moderation_viewpremoderation'>View premoderation list</a>
<tr class='title'>
<th text-align:center;'>Item (click to preview)</th>
<th text-align:center;'>Author ckey</th>
<th text-align:center;'>Buttons</th>
</tr>
"}

	if(player_ckey)
		player_ckey = ckey(player_ckey)
		var/list/items = get_custom_items(player_ckey)
		for(var/itemname in items)
			var/datum/custom_item/item = items[itemname]
			output += "<tr>"
			output += "<td style='text-align:center;'><a class='small' href='?src=\ref[src];custom_items=moderation_view;ckey=[player_ckey];itemname=[ckey(item.name)]'>[item.name] ([item.status])</a></td>"
			output += "<td style='text-align:center;'>[player_ckey]</td>"
			output += "<td style='text-align:center;'><a class='small' href='?src=\ref[src];custom_items=moderation_accept;ckey=[player_ckey];itemname=[ckey(item.name)];viewthis=1'>Accept</a> <a class='small' href='?src=\ref[src];custom_items=moderation_reject;ckey=[player_ckey];itemname=[ckey(item.name)];viewthis=1'>Deny</a></td>"
			output += "</tr>"
	else
		var/list/premoderations = custom_item_premoderation_list()
		for(var/datum/premoderation_item/item in premoderations)
			output += "<tr>"
			output += "<td style='text-align:center;'><a class='small' href='?src=\ref[src];custom_items=moderation_view;ckey=[item.author_ckey];itemname=[ckey(item.item_name)]'>[item.item_name]</a></td>"
			output += "<td style='text-align:center;'>[item.author_ckey]</td>"
			output += "<td style='text-align:center;'><a class='small' href='?src=\ref[src];custom_items=moderation_accept;ckey=[item.author_ckey];itemname=[ckey(item.item_name)]'>Accept</a> <a class='small' href='?src=\ref[src];custom_items=moderation_reject;ckey=[item.author_ckey];itemname=[ckey(item.item_name)]'>Deny</a></td>"
			output += "</tr>"

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(output,"window=customitems_moderation;size=600x500")