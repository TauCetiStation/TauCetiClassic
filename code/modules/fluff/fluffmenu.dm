/datum/preferences/proc/ShowFluffMenu(mob/user)
	var/list/custom_items = user.client.get_custom_items()
	//to_chat(user, "[custom_items.len]")

	. += "<table align='center' width='570px'>"
	. += "<tr><td colspan=3><center><b>Custom items slots: <font color='#E67300'>[user.client.get_custom_items_slot_count()]</font></b> \[<a href='?_src_=prefs;preference=fluff;show_info=1'>How to get more</a>\]</center></td></tr>"

	for(var/datum/custom_item/item in custom_items)
		if(item.status == "submitted")
			. += "<tr><td colspan=3><center>[item.name] <font color='#E67300'>(Awating premoderation)</font></center></td></tr>"
		if(item.status == "accepted")
			. += "<tr><td colspan=3><center>[item.name] <font color='#267F00'>(Accepted)</font></center></td></tr>"
		if(item.status == "rejected")
			. += "<tr><td colspan=3><center>[item.name] <font color='#FF0000'>(Rejected)</font>[item.moderator_message? " <a href='?_src_=prefs;preference=fluff;read_reason=[item.name]'>Reason</a>" : ""]</center></td></tr>"

	. += "<tr><td colspan=3><center><a href='?_src_=prefs;preference=fluff;add_item=1'>Create new</a></center></td></tr>"

	. += "</table>"

var/datum/custom_item/editing_item = null
/proc/edit_custom_item_panel(datum/preferences/prefs, mob/user, readonly = FALSE)
	if(!user)
		return
	var/dat = "<html><body link='#045EBE' vlink='045EBE' alink='045EBE'>"
	dat += "<style type='text/css'><!--A{text-decoration:none}--></style>"
	dat += "<style type='text/css'>a.white, a.white:link, a.white:visited, a.white:active{color: #40628a;text-decoration: none;background: #ffffff;border: 1px solid #161616;padding: 1px 4px 1px 4px;margin: 0 2px 0 0;cursor:default;}</style>"
	dat += "<style>body{background-color: #F5ECDD}</style>"
	//dat += "<style>.main_menu{margin-left:150px;margin-top:135px}</style>"

	if(!editing_item)
		editing_item = new /datum/custom_item()
		editing_item.name = "new item"
		editing_item.desc = "description"
		editing_item.icon_state = ""
		editing_item.item_type = "normal"

		editing_item.status = "submitted"
		editing_item.moderator_message = ""

	dat += "<div id='main'><table cellspacing='0' width='100%'>"
	dat += "<tr>"
	dat += "<td>Type</td>"
	dat += "<td>[readonly?"<b>[editing_item.item_type]</b>":"<a class='small' href='?src=\ref[prefs];asd=asd;'>[editing_item.item_type]</a>"]</td>"
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
	dat += "<td>[readonly?"<b>[editing_item.icon_state]</b>":"<a class='small' href='?src=\ref[prefs];asd=asd;'>[editing_item.icon_state]</a>"]</td>"
	dat += "</tr>"
	dat += "</table></div>"

	if(!readonly)
		dat += "<br><b><font color='#FF4444'>Your item will be pre-moderated by admins before you can use it</font></b><br>"
		dat += "<a class='small' href='?_src_=prefs;preference=fluff;submit=1'>Submit</a>"

	dat += "</body></html>"
	user << browse(entity_ja(dat), "window=edit_custom_item;size=400x500;can_minimize=0;can_maximize=0;can_resize=0")

/datum/preferences/proc/process_link_fluff(mob/user, list/href_list)
	if(href_list["read_reason"])
		var/itemname = href_list["read_reason"]
		var/datum/custom_item/item = get_custom_item(user.client.ckey, itemname)
		if(item)
			to_chat(user, "<span class='alert'>Rejection reason for [itemname]: [item.moderator_message]</span>")

	if(href_list["show_info"])
		if(alert(user, "You can get custom item slots by supporting the project, monetary or through contributions like coding and spriting", "Info", "Show Donation Links", "OK") == "Show Donation Links")
			if(config.donate_info_url)
				to_chat(user, "<a href='[config.donate_info_url]'>Support project</a>")
			if(config.allow_byond_membership)
				to_chat(user, "<a href='http://www.byond.com/membership'>Become Byond Member</a>")
			if(!config.donate_info_url && !config.allow_byond_membership)
				to_chat(user, "Server is not configured, go annoy admins")

	if(href_list["add_item"])
		edit_custom_item_panel(src, user)
		return

		var/new_item_name = sanitize(input("Enter item name:","Text") as null|text)
		if(!new_item_name)
			return
		var/new_item_desc = sanitize(input("Enter item desc:","Text") as null|text)
		if(!new_item_desc)
			return
		var/new_item_icon = input("Pick icon:","Icon") as null|icon
		if(!new_item_icon)
			return
		var/new_item_iconname = sanitize(input("Enter iconstate name:","Text") as null|text)
		if(!new_item_iconname)
			return

		var/datum/custom_item/item = new /datum/custom_item()
		item.item_type = "normal"
		item.name = new_item_name
		item.desc = new_item_desc
		item.icon = new_item_icon
		item.icon_state = new_item_iconname
		if(!user.client.add_custom_item(item))
			qdel(item)

	if(href_list["change_name"])
		var/new_item_name = sanitize(input("Enter item name:", "Text")  as text|null)
		if(!editing_item || !new_item_name || length(new_item_name) <= 2 || length(new_item_name) > 40)
			return
		editing_item.name = new_item_name
		edit_custom_item_panel(src, user)
		return

	if(href_list["change_desc"])
		var/new_item_desc = sanitize(input("Enter item desc:", "Text")  as text|null)
		if(!editing_item || !new_item_desc || length(new_item_desc) <= 2 || length(new_item_desc) > 100)
			return
		editing_item.desc = new_item_desc
		edit_custom_item_panel(src, user)
		return

	if(href_list["submit"])
		if(!editing_item || !editing_item.icon || !editing_item.icon_state)
			return

		editing_item.status = "submitted"
		user.client.add_custom_item(editing_item)
		custom_item_premoderation_add(user.client.ckey, editing_item)
		qdel(editing_item)
		user << browse(null, "window=edit_custom_item")
		//return

	if(href_list["upload_icon"])
		var/new_item_icon = input("Pick icon:","Icon") as null|icon
		if(!editing_item || !new_item_icon)
			return
		var/icon/I = new(new_item_icon)
		var/list/icon_states = icon_states(I)
		if(icon_states.len == 0)
			to_chat(user, "This icon has no states")
			return
		if(icon_states.len > 3)
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

	var/list/all_custom_items = user.client.get_custom_items()
	for(var/datum/custom_item/item in all_custom_items)
		var/ticked = (item.name in custom_items)
		. += "<tr style='vertical-align:top;'><td width=15%><a style='white-space:normal;' [ticked ? "style='font-weight:bold' " : ""]href='?_src_=prefs;preference=loadout;toggle_custom_gear=[item.name]'>[item.name]</a></td>"
		. += "<td width = 5% style='vertical-align:top'>1</td>"
		. += "<td><font size=2><i>[item.desc]</i></font></td>"
		. += "</tr>"

	. += "</table>"


/datum/admins/proc/customitems_panel()
	set category = "Server"
	set name = "Whitelist Custom Items"
	set desc = "Allows you to add custom items slots to people."

	src = usr.client.holder
	if(!check_rights(R_ADMIN|R_WHITELIST))
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

	usr << browse(entity_ja(output),"window=customitems;size=600x500")

/datum/admins/proc/customs_items_add(target_ckey = null)
	if(!check_rights(R_WHITELIST))
		return

	if(!target_ckey)
		target_ckey = input(usr,"type in ckey:","Add custom item slots", null) as null|text
		if(!target_ckey)
			return

	var/ammount = input(usr,"type in ammount:","Ammount", 1) as null|num
	if(!ammount)
		return
	ammount = round(ammount)
	if(ammount < 0)
		ammount = 0

	var/reason = input(usr, "([target_ckey] +[ammount]) type in reason:", "Reason") as null|text
	if(!reason)
		return

	add_custom_items_history(target_ckey, usr.ckey, reason, ammount)
	customitems_panel()
	customs_items_history(target_ckey)

/datum/admins/proc/customs_items_history(user_ckey)
	src = usr.client.holder
	if(!check_rights(R_ADMIN|R_WHITELIST))
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
		output += "<td style='text-align:center;'>[entry.reason]</td>"
		output += "<td style='text-align:center;'>[entry.admin_ckey]</td>"
		output += "</tr>"
		i++

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(entity_ja(output),"window=customitems_history;size=600x500")

/datum/admins/proc/customs_items_remove(target_ckey, index)
	if(!check_rights(R_WHITELIST))
		return

	if(!target_ckey)
		return

	if(alert(usr, "Are you sure?", "Confirm deletion", "Yes", "No") == "Yes")
		remove_custom_items_history(target_ckey, index)
		customitems_panel()
		customs_items_history(target_ckey)