/datum/preferences/proc/ShowFluffMenu(mob/user)
	var/list/custom_items = user.client.get_custom_items()
	//to_chat(user, "[custom_items.len]")

	. += "<table align='center' width='570px'>"
	. += "<tr><td colspan=3><center><b>Custom items slots: <font color='#E67300'>[user.client.get_custom_items_slot_count()]</font></b> \[<a href='?_src_=prefs;preference=fluff;show_info=1'>How to get more</a>\]</center></td></tr>"

	for(var/item in custom_items)
		var/item_name = item["name"]
		. += "<tr><td colspan=3><center>[item_name]</center></td></tr>"

	. += "<tr><td colspan=3><center><a href='?_src_=prefs;preference=fluff;add_item=1'>Create new</a></center></td></tr>"

	. += "</table>"

/datum/preferences/proc/process_link_fluff(mob/user, list/href_list)
	if(href_list["show_info"])
		if(alert(user, "You can get custom item slots by supporting the project, monetary or through contributions like coding and spriting", "Info", "Show Donation Links", "OK") == "Show Donation Links")
			if(config.donate_info_url)
				to_chat(user, "<a href='[config.donate_info_url]'>Support project</a>")
			if(config.allow_byond_membership)
				to_chat(user, "<a href='http://www.byond.com/membership'>Become Byond Member</a>")
			if(!config.donate_info_url && !config.allow_byond_membership)
				to_chat(user, "Server is not configured, go annoy admins")

	if(href_list["add_item"])
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

		user.client.add_custom_item(new_item_name, new_item_desc, new_item_icon, new_item_iconname)

	ShowChoices(user)

/datum/preferences/proc/FluffLoadout(mob/user)
	. += "<tr><td colspan=3><hr></td></tr>"
	. += "<tr><td colspan=3><b><center>Custom items</center></b></td></tr>"
	. += "<tr><td colspan=3><hr></td></tr>"

	var/list/all_custom_items = user.client.get_custom_items()
	for(var/item in all_custom_items)
		var/item_name = item["name"]
		var/item_desc = item["desc"]
		var/ticked = (item_name in custom_items)
		. += "<tr style='vertical-align:top;'><td width=15%><a style='white-space:normal;' [ticked ? "style='font-weight:bold' " : ""]href='?_src_=prefs;preference=loadout;toggle_custom_gear=[item_name]'>[item_name]</a></td>"
		. += "<td width = 5% style='vertical-align:top'>1</td>"
		. += "<td><font size=2><i>[item_desc]</i></font></td>"
		. += "</tr>"

	. += "</table>"