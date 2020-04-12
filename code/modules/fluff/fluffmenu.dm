/datum/preferences/proc/ShowFluffMenu(mob/user)
	//custom_items_fixnames(user.client.ckey)
	var/list/custom_items = get_custom_items(user.client.ckey)

	. += "<table align='center' width='570px'>"
	. += "<tr><td colspan=3><center><b>Custom items slots: <font color='#E67300'>[user.client.get_custom_items_slot_count()]</font></b><br>\[<a href='?_src_=prefs;preference=fluff;show_info=1'>Information and how to get more</a>\]</center></td></tr>"

	for(var/item_name in custom_items)
		var/datum/custom_item/item = custom_items[item_name]
		if(item.status == "submitted")
			. += "<tr><td colspan=3><center><a href='?_src_=prefs;preference=fluff;edit_item=[ckey(item.name)]'>[item.name]</a> <font color='#E67300'>(Awating premoderation)</font></center></td></tr>"
		if(item.status == "accepted")
			. += "<tr><td colspan=3><center><a href='?_src_=prefs;preference=fluff;edit_item=[ckey(item.name)]'>[item.name]</a> <font color='#267F00'>(Accepted)</font></center></td></tr>"
		if(item.status == "rejected")
			. += "<tr><td colspan=3><center><a href='?_src_=prefs;preference=fluff;edit_item=[ckey(item.name)]'>[item.name]</a> <font color='#FF0000'>(Rejected)</font>[item.moderator_message? " <a href='?_src_=prefs;preference=fluff;read_reason=[ckey(item.name)]'>Reason</a>" : ""]</center></td></tr>"

	. += "<tr><td colspan=3><center><a href='?_src_=prefs;preference=fluff;add_item=1'>Create new</a></center></td></tr>"

	. += "</table>"

var/list/editing_item_list = list() // stores the item that is currently being edited for each player
var/list/editing_item_oldname_list = list()
/proc/edit_custom_item_panel(datum/preferences/prefs, mob/user, readonly = FALSE, adminview = FALSE)
	if(!user)
		return
	var/datum/custom_item/editing_item = editing_item_list[user.client.ckey]
	var/editing_item_oldname = editing_item_oldname_list[user.client.ckey]

	var/dat = "<html><body link='#045EBE' vlink='045EBE' alink='045EBE'>"
	dat += "<style type='text/css'><!--A{text-decoration:none}--></style>"
	dat += "<style type='text/css'>a.white, a.white:link, a.white:visited, a.white:active{color: #40628a;text-decoration: none;background: #ffffff;border: 1px solid #161616;padding: 1px 4px 1px 4px;margin: 0 2px 0 0;cursor:default;}</style>"
	dat += "<style>body{background-color: #F5ECDD}</style>"

	var/icon/preview_icon = icon('icons/effects/effects.dmi', "nothing")
	var/icon/preview_icon_mob = null
	preview_icon.Scale(150, 70)
	if(editing_item.icon && editing_item.icon_state)
		var/icon/I = new(editing_item.icon,icon_state = editing_item.icon_state,dir = SOUTH)
		preview_icon.Blend(I, ICON_OVERLAY, 13, 22)

		I = new(editing_item.icon,icon_state = editing_item.icon_state,dir = NORTH)
		preview_icon.Blend(I, ICON_OVERLAY, 109, 19)

		I = new(editing_item.icon,icon_state = editing_item.icon_state,dir = WEST)
		preview_icon.Blend(I, ICON_OVERLAY, 60, 18)

		if("[editing_item.icon_state]_mob" in icon_states(editing_item.icon))
			var/mob_icon_state = "[editing_item.icon_state]_mob"

			preview_icon_mob = icon('icons/effects/effects.dmi', "nothing")
			preview_icon_mob.Scale(150, 70)

			I = new(editing_item.icon,icon_state = mob_icon_state,dir = SOUTH)
			preview_icon_mob.Blend(I, ICON_OVERLAY, 13, 22)

			I = new(editing_item.icon,icon_state = mob_icon_state,dir = NORTH)
			preview_icon_mob.Blend(I, ICON_OVERLAY, 109, 19)

			I = new(editing_item.icon,icon_state = mob_icon_state,dir = WEST)
			preview_icon_mob.Blend(I, ICON_OVERLAY, 60, 18)

	user << browse_rsc(preview_icon, "itempreviewicon.png")
	user << browse_rsc('html/prefs/dossier_photos.png')
	user << browse_rsc('html/prefs/fluff_photos.png')
	if(preview_icon_mob)
		user << browse_rsc(preview_icon_mob, "itempreviewicon2.png")

	dat += "<div id='main'>"
	dat += "<table cellspacing='0' width='100%'>"
	dat += "<tr>"
	dat += "<td>"
	dat += "<td background='dossier_photos.png' style='background-repeat: no-repeat'>"
	dat += "<img style='-ms-interpolation-mode:nearest-neighbor' src=itempreviewicon.png width=[preview_icon.Width() * 2] height=[preview_icon.Height() * 2]>"
	dat += "</td>"
	dat += "</tr>"
	if(preview_icon_mob)
		dat += "<tr>"
		dat += "<td>"
		dat += "<td background='fluff_photos.png' style='background-repeat: no-repeat'>"
		dat += "<img style='-ms-interpolation-mode:nearest-neighbor' src=itempreviewicon2.png width=[preview_icon_mob.Width() * 2] height=[preview_icon_mob.Height() * 2]>"
		dat += "</td>"
		dat += "</tr>"
	dat += "</table>"

	dat += "<table cellspacing='0' width='100%'>"
	dat += "<tr>"
	dat += "<td width=110>Type</td>"
	dat += "<td>[readonly?"<b>[editing_item.item_type]</b>":"<a class='small' href='?_src_=prefs;preference=fluff;change_type=1'>[editing_item.item_type]</a>"]</td>"
	dat += "</tr>"
	dat += "<tr>"
	dat += "<td>Name</td>"
	dat += "<td>[readonly?"<b>[editing_item.name]</b>":"<a class='small' href='?_src_=prefs;preference=fluff;change_name=1'>[editing_item.name]</a>"]</td>"
	dat += "</tr>"
	dat += "<tr>"
	dat += "<td>Description</td>"
	dat += "<td>[readonly?"<b>[editing_item.desc]</b>":"<a class='small' href='?_src_=prefs;preference=fluff;change_desc=1'>[editing_item.desc]</a>"]</td>"
	dat += "</tr>"
	if(!readonly)
		dat += "<tr>"
		dat += "<td>Icon</td>"
		dat += "<td><a class='small' href='?_src_=prefs;preference=fluff;upload_icon=1'>Upload Icon</a></td>"
		dat += "</tr>"
	dat += "<tr>"
	dat += "<td>Icon name</td>"
	dat += "<td>[readonly?"<b>[editing_item.icon_state]</b>":"<a class='small' href='?_src_=prefs;preference=fluff;change_iconname=1'>[editing_item.icon_state]</a>"]</td>"
	dat += "</tr>"
	dat += "<tr>"
	dat += "<td>Sprite author<a class='small' href='?_src_=prefs;preference=fluff;author_info=1'>\[?\]</a></td>"
	dat += "<td>[readonly?"<b>[editing_item.sprite_author ? editing_item.sprite_author : "no author"]</b>":"<a class='small' href='?_src_=prefs;preference=fluff;change_author=1'>[editing_item.sprite_author ? editing_item.sprite_author : "no author"]</a>"]</td>"
	dat += "</tr>"
	dat += "<tr>"
	dat += "<td>OOC Info<a class='small' href='?_src_=prefs;preference=fluff;ooc_info=1'>\[?\]</a></td>"
	dat += "<td>[readonly?"<b>[editing_item.info ? editing_item.info : "no info"]</b>":"<a class='small' href='?_src_=prefs;preference=fluff;change_oocinfo=1'>[editing_item.info ? editing_item.info : "no info"]</a>"]</td>"
	dat += "</tr>"
	dat += "</table></div>"

	if(!readonly)
		dat += "<br><b><font color='#FF4444'>Your item will be pre-moderated by admins before you can use it</font></b><br>"
		dat += "<a class='small' href='?_src_=prefs;preference=fluff;submit=1'>Submit</a>"

		if(editing_item_oldname)
			dat += " <a class='small' href='?_src_=prefs;preference=fluff;delete=1'>Delete</a>"
	else if(adminview)
		dat += " <a class='small' href='?_src_=prefs;preference=fluff;download=1'>Download icon</a>"

	dat += "</body></html>"
	user << browse(dat, "window=edit_custom_item;size=400x600;can_minimize=0;can_maximize=0;can_resize=0")

/datum/preferences/proc/process_link_fluff(mob/user, list/href_list)
	var/datum/custom_item/editing_item = editing_item_list[user.client.ckey]
	var/editing_item_oldname = editing_item_oldname_list[user.client.ckey]

	if(href_list["read_reason"])
		var/itemname = href_list["read_reason"]
		var/datum/custom_item/item = get_custom_item(user.client.ckey, itemname)
		if(item)
			to_chat(user, "<span class='alert'>Rejection reason for [itemname]: [item.moderator_message]</span>")

	if(href_list["show_info"])
		link_with_alert(user, config.customitems_info_url)

	if(href_list["add_item"])
		var/itemCount = length(get_custom_items(user.client.ckey))
		var/slotCount = user.client.get_custom_items_slot_count()
		if(slotCount <= itemCount) // can't create, we have too much custom items
			alert(user, "You don't have free custom item slots", "Info", "OK")
			return

		editing_item_oldname_list[user.client.ckey] = null

		editing_item = new /datum/custom_item()
		editing_item.name = "new item"
		editing_item.desc = "description"
		editing_item.icon_state = ""
		editing_item.item_type = "normal"

		editing_item.status = "submitted"
		editing_item.moderator_message = ""
		editing_item_list[user.client.ckey] = editing_item

		edit_custom_item_panel(src, user)
		return

	if(href_list["edit_item"])
		editing_item_oldname = href_list["edit_item"]
		editing_item_oldname_list[user.client.ckey] = editing_item_oldname

		editing_item = get_custom_item(user.client.ckey, editing_item_oldname)
		editing_item_list[user.client.ckey] = editing_item
		if(editing_item)
			edit_custom_item_panel(src, user)
			return

	if(href_list["change_name"])
		var/new_item_name = sanitize_safe(input("Enter item name:", "Text")  as text|null, MAX_LNAME_LEN)
		if(!editing_item || !new_item_name || length(new_item_name) <= 2 || length(new_item_name) > 40)
			return
		editing_item.name = new_item_name
		edit_custom_item_panel(src, user)
		return

	if(href_list["change_desc"])
		var/new_item_desc = sanitize(input("Enter item desc:", "Text")  as text|null)
		if(!editing_item || !new_item_desc || length(new_item_desc) <= 2 || length(new_item_desc) > 500)
			return
		editing_item.desc = new_item_desc
		edit_custom_item_panel(src, user)
		return

	if(href_list["change_iconname"])
		if(!editing_item.icon || !length(icon_states(editing_item.icon)))
			return
		var/new_iconname = sanitize(input("Select Main icon name", "Text")  as null|anything in icon_states(editing_item.icon))
		if(!editing_item || !new_iconname)
			return
		editing_item.icon_state = new_iconname
		edit_custom_item_panel(src, user)
		return

	if(href_list["change_type"])
		var/new_type = sanitize(input("Select item type", "Text")  as null|anything in list("normal", "small", "lighter", "hat", "uniform", "suit", "mask", "glasses", "gloves", "shoes", "accessory", "labcoat"))
		if(!editing_item || !new_type)
			return
		editing_item.item_type = new_type
		edit_custom_item_panel(src, user)
		return

	if(href_list["author_info"])
		alert(user, "If you are submitting sprites from another build or made by another person you must first ask their permission and then give them credit by putting their name here", "Info", "OK")
		return

	if(href_list["change_author"])
		var/new_sprite_author = sanitize(input("Enter sprite author:", "Text")  as text|null)
		if(!editing_item)
			return

		if(!new_sprite_author)
			editing_item.sprite_author = null
		else if(length(new_sprite_author) > 100)
			return
		else
			editing_item.sprite_author = new_sprite_author

		edit_custom_item_panel(src, user)
		return

	if(href_list["ooc_info"])
		alert(user, "Not shown ingame. You may put here anything that you think is important about your item. Will only be visible here to you and premoderation admins", "Info", "OK")
		return

	if(href_list["change_oocinfo"])
		var/new_ooc_info = sanitize(input("Enter item ooc information:", "Text")  as text|null)
		if(!editing_item)
			return

		if(!new_ooc_info)
			editing_item.info = null
		else if(length(new_ooc_info) > 500)
			return
		else
			editing_item.info = new_ooc_info

		edit_custom_item_panel(src, user)
		return

	if(href_list["submit"])
		if(!editing_item || !editing_item.icon || !editing_item.icon_state)
			return

		var/itemCount = length(get_custom_items(user.client.ckey))
		var/slotCount = user.client.get_custom_items_slot_count()


		if(editing_item_oldname) //editing
			if(slotCount < itemCount) // can't edit, we have too much custom items
				alert(user, "You have too much custom items, remove old ones before being able to edit", "Info", "OK")
				return

			editing_item.status = "submitted"
			editing_item.moderator_message = ""
			custom_item_premoderation_reject(user.client.ckey, editing_item_oldname, "") //remove old one from premoderation
			user.client.edit_custom_item(editing_item, editing_item_oldname)
			custom_item_premoderation_add(user.client.ckey, editing_item.name)
			qdel(editing_item)
			user << browse(null, "window=edit_custom_item")
		else //adding new
			var/datum/custom_item/old_item = get_custom_item(user.client.ckey, editing_item.name)
			if(old_item)
				alert(user, "You already have an item with name [editing_item.name]", "Info", "OK")
				return
			if(slotCount <= itemCount) // can't create, we have too much custom items
				alert(user, "You don't have free custom item slots", "Info", "OK")
				return

			editing_item.status = "submitted"
			user.client.add_custom_item(editing_item)
			custom_item_premoderation_add(user.client.ckey, editing_item.name)
			qdel(editing_item)
			user << browse(null, "window=edit_custom_item")

	if(href_list["delete"])
		if(!editing_item || !editing_item.icon || !editing_item.icon_state || !editing_item_oldname)
			return

		if(alert(usr, "Are you sure?", "Item deletion confirmation", "Yes", "No") == "Yes")
			custom_item_premoderation_reject(user.client.ckey, editing_item_oldname, "")
			user.client.remove_custom_item(editing_item_oldname)
			user << browse(null, "window=edit_custom_item")

	if(href_list["download"])
		if(!editing_item || !editing_item.icon)
			return

		usr << ftp(editing_item.icon)
		return

	if(href_list["upload_icon"])
		var/new_item_icon = input("Pick icon:","Icon") as null|icon
		if(!editing_item || !new_item_icon)
			return
		var/icon/I = new(new_item_icon)
		if(!I)
			to_chat(user, "This icon is invalid")
			return
		var/list/icon_states = icon_states(I)
		if(icon_states.len == 0)
			to_chat(user, "This icon has no states")
			return
		if(icon_states.len > 6)
			to_chat(user, "This icon has too many states")
			return
		if(I.Width() != 32 || I.Height() != 32)
			to_chat(user, "This icon has incorrect size")
			return
		editing_item.icon = new_item_icon
		editing_item.icon_state = icon_states[1]
		edit_custom_item_panel(src, user)
		return

	ShowChoices(user)

/datum/preferences/proc/FluffLoadout(mob/user)
	. += "<tr><td colspan=3><hr></td></tr>"
	. += "<tr><td colspan=3><b><center>Custom items</center></b></td></tr>"
	. += "<tr><td colspan=3><hr></td></tr>"

	var/list/all_custom_items = get_custom_items(user.client.ckey)
	for(var/item_name in all_custom_items)
		var/datum/custom_item/item = all_custom_items[item_name]
		var/ticked = (item_name in custom_items)
		var/accepted = (item.status == "accepted")
		if(accepted || ticked)
			. += "<tr style='vertical-align:top;'><td width=15%><a style='white-space:normal;' [ticked ? "style='font-weight:bold' " : ""]href='?_src_=prefs;preference=loadout;toggle_custom_gear=[ckey(item.name)]'>[item.name][accepted ? "" : " (not accepted)"]</a></td>"
			. += "<td width = 5% style='vertical-align:top'>0</td>"
			. += "<td><font size=2><i>[item.desc]</i></font></td>"
			. += "</tr>"
		else
			. += "<tr style='vertical-align:top;'><td width=15%>[item.name] (not accepted)</td>"
			. += "<td width = 5% style='vertical-align:top'>0</td>"
			. += "<td><font size=2><i>[item.desc]</i></font></td>"
			. += "</tr>"

	. += "</table>"


/datum/admins/proc/customitems_panel()
	set category = "Server"
	set name = "Whitelist Item Slots"
	set desc = "Allows you to add custom items slots to people."

	src = usr.client.holder
	if(!check_rights(R_PERMISSIONS))
		return

	var/list/slots = get_custom_items_slot_all()

	var/output = {"<!DOCTYPE html>
<html>
<head>
<title>Custom Items Panel</title>
<script type='text/javascript' src='search.js'></script>
<link rel='stylesheet' type='text/css' href='panels.css'>
</head>
<body onload='selectTextField();updateSearch();'>
<div id='main'><table id='searchable' cellspacing='0'>
<tr class='title'>
<th text-align:center;'>CKEY <a class='small' href='?src=\ref[src];custom_items=add'>\[+\]</a></th>
<th text-align:center;'>Slot count</th>
</tr>
"}

	for(var/user_ckey in slots)
		output += "<tr>"
		output += "<td style='text-align:center;'><a class='small' href='?src=\ref[src];custom_items=history;ckey=[user_ckey]'>[user_ckey]</a></td>"
		output += "<td style='text-align:center;'>[slots[user_ckey]]</td>"
		output += "</tr>"

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(output,"window=customitems;size=600x500")

/datum/admins/proc/customs_items_add(target_ckey = null)
	if(!check_rights(R_PERMISSIONS))
		return

	if(!target_ckey)
		target_ckey = input(usr,"type in ckey:","Add custom item slots", null) as null|text
		if(!target_ckey)
			return

	var/ammount = input(usr,"type in ammount (can be negative):","Ammount", 1) as null|num
	if(!ammount)
		return
	ammount = round(ammount)

	var/reason = input(usr, "([target_ckey] [ammount > 0 ? "+" : ""][ammount]) type in reason:", "Reason") as null|text
	if(!reason)
		return

	add_custom_items_history(target_ckey, usr.ckey, reason, ammount)
	customitems_panel()
	customs_items_history(target_ckey)

/datum/admins/proc/customs_items_history(user_ckey)
	src = usr.client.holder
	if(!check_rights(R_PERMISSIONS))
		return

	var/list/history = get_custom_items_history(user_ckey)
	if(!history)
		to_chat(usr, "<span class='alert'>There is no history for [user_ckey]</span>")
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
<tr class='title'>
<th text-align:center;'>[user_ckey] <a class='small' href='?src=\ref[src];custom_items=addckey;ckey=[user_ckey]'>\[+\]</a></th>
<th text-align:center;'>Ammount</th>
<th text-align:center;'>Reason</th>
<th text-align:center;'>Added by</th>
</tr>
"}

	var/i = 1
	for(var/datum/custom_items_history/entry in history)
		output += "<tr>"
		output += "<td style='text-align:center;'><a class='small' href='?src=\ref[src];custom_items=history_remove;ckey=[user_ckey];index=[i]'>DELETE</a></td>"
		output += "<td style='text-align:center;'>[entry.ammount]</td>"
		output += "<td style='text-align:center;'>[sanitize(entry.reason)]</td>"
		output += "<td style='text-align:center;'>[entry.admin_ckey]</td>"
		output += "</tr>"
		i++

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(output,"window=customitems_history;size=600x500")

/datum/admins/proc/customs_items_remove(target_ckey, index)
	if(!check_rights(R_PERMISSIONS))
		return

	if(!target_ckey)
		return

	if(alert(usr, "Are you sure?", "Confirm deletion", "Yes", "No") == "Yes")
		remove_custom_items_history(target_ckey, index)
		customitems_panel()
		customs_items_history(target_ckey)
