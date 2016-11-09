/client/proc/edit_admin_permissions()
	set category = "Admin"
	set name = "Permissions Panel"
	set desc = "Edit admin permissions."
	if(!check_rights(R_PERMISSIONS))
		return
	usr.client.holder.edit_admin_permissions()

/datum/admins/proc/edit_admin_permissions()
	if(!check_rights(R_PERMISSIONS))
		return

	var/output = {"<!DOCTYPE html>
<html>
<head>
<title>Permissions Panel</title>
<script type='text/javascript' src='search.js'></script>
<link rel='stylesheet' type='text/css' href='panels.css'>
</head>
<body onload='selectTextField();updateSearch();'>
<div id='main'><table id='searchable' cellspacing='0'>
<tr class='title'>
<th style='width:125px;text-align:right;'>CKEY <a class='small' href='?src=\ref[src];editrights=add'>\[+\]</a></th>
<th style='width:125px;'>RANK</th><th style='width:100%;'>PERMISSIONS</th>
</tr>
"}

	for(var/adm_ckey in admin_datums)
		var/datum/admins/D = admin_datums[adm_ckey]
		if(!D)
			continue
		var/rank = D.rank ? D.rank : "*none*"
		var/rights = rights2text(D.rights," ")
		if(!rights)
			rights = "*none*"

		output += "<tr>"
		output += "<td style='text-align:right;'>[adm_ckey] <a class='small' href='?src=\ref[src];editrights=remove_admin;ckey=[adm_ckey]'>\[-\]</a></td>"
		output += "<td><a href='?src=\ref[src];editrights=rank;ckey=[adm_ckey]'>[rank]</a></td>"
		output += "<td><a class='small' href='?src=\ref[src];editrights=permissions;ckey=[adm_ckey]'>[rights]</a></td>"
		output += "</tr>"

	for(var/ment_ckey in mentor_ckeys)
		output += "<tr>"
		output += "<td style='text-align:right;'>[ment_ckey] <a class='small' href='?src=\ref[src];editrights=remove_mentor;ckey=[ment_ckey]'>\[-\]</a></td>"
		output += "<td>Mentor</td>"
		output += "<td></td>"
		output += "</tr>"

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(output,"window=editrights;size=600x500")

/datum/admins/proc/add_admin()
	if(!usr.client)
		return
	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "\red You do not have permission to do this!")
		return
	var/adm_ckey = ckey(input(usr,"New admin's ckey","Admin ckey", null) as text|null)
	if(!adm_ckey)
		return
	if(adm_ckey in admin_datums)
		to_chat(usr, "<font color='red'>Error: Topic 'editrights': [adm_ckey] is already an admin</font>")
		return
	if(adm_ckey in mentor_ckeys)
		remove_mentor(adm_ckey)
	edit_rank(adm_ckey)

/datum/admins/proc/remove_admin(adm_ckey)
	if(!usr.client)
		return
	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "\red You do not have permission to do this!")
		return
	if(!adm_ckey)
		to_chat(usr, "<font color='red'>Error: Topic 'editrights': No valid ckey</font>")
		return
	var/datum/admins/D = admin_datums[adm_ckey]
	if(alert("Are you sure you want to remove [adm_ckey] from admins?","Message","Yes","Cancel") == "Yes")
		if(!D)
			return
		admin_datums -= adm_ckey
		D.disassociate()
		db_admin_rank_modification(adm_ckey, "Removed")
		message_admins("[key_name_admin(usr)] removed [adm_ckey] from the admins list")
		log_admin("[key_name(usr)] removed [adm_ckey] from the admins list")

/datum/admins/proc/edit_rank(adm_ckey)
	if(!usr.client)
		return
	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "\red You do not have permission to do this!")
		return
	if(!adm_ckey)
		return
	var/datum/admins/D = admin_datums[adm_ckey]
	var/new_rank
	if(admin_ranks.len)
		new_rank = input("Please select a rank", "New rank", null, null) as null|anything in (admin_ranks|"*New Rank*")
	else
		new_rank = input("Please select a rank", "New rank", null, null) as null|anything in list("Game Master","Game Admin", "Trial Admin", "Admin Observer","*New Rank*")
	var/rights = 0
	if(D)
		rights = D.rights
	switch(new_rank)
		if(null,"")
			return
		if("*New Rank*")
			new_rank = input("Please input a new rank", "New custom rank", null, null) as null|text
			if(!new_rank)
				to_chat(usr, "<font color='red'>Error: Topic 'editrights': Invalid rank</font>")
				return
	if(D)
		D.disassociate()								//remove adminverbs and unlink from client
		D.rank = new_rank								//update the rank
		D.rights = rights								//update the rights based on admin_ranks (default: 0)
	else
		D = new /datum/admins(new_rank, rights, adm_ckey)
	var/client/C = directory[adm_ckey]						//find the client with the specified ckey (if they are logged in)
	D.associate(C)											//link up with the client and add verbs
	db_admin_rank_modification(adm_ckey, new_rank)
	message_admins("[key_name_admin(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
	log_admin("[key_name(usr)] edited the admin rank of [adm_ckey] to [new_rank]")

/datum/admins/proc/change_permissions(adm_ckey)
	if(!usr.client)
		return
	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "\red You do not have permission to do this!")
		return
	if(!adm_ckey)
		return
	var/datum/admins/D = admin_datums[adm_ckey]
	if(!D)
		return
	var/list/permissionlist = list()
	for(var/i=1, i<=R_MAXPERMISSION, i<<=1)		//that <<= is shorthand for i = i << 1. Which is a left bitshift
		permissionlist[rights2text(i)] = i
	var/new_permission = input("Select a permission to turn on/off", "Permission toggle", null, null) as null|anything in permissionlist
	if(!new_permission)
		return
	D.rights ^= permissionlist[new_permission]
	message_admins("[key_name_admin(usr)] toggled the [new_permission] permission of [adm_ckey]")
	log_admin("[key_name(usr)] toggled the [new_permission] permission of [adm_ckey]")
	new_permission = permissionlist[new_permission]

	establish_db_connection()
	if(!dbcon.IsConnected())
		to_chat(usr, "\red Failed to establish database connection")
		return
	adm_ckey = ckey(adm_ckey)
	if(istext(new_permission))
		new_permission = text2num(new_permission)
	if(!istext(adm_ckey) || !isnum(new_permission))
		return
	var/DBQuery/select_query = dbcon.NewQuery("SELECT id, flags FROM erro_admin WHERE ckey = '[adm_ckey]'")
	select_query.Execute()
	var/admin_id
	var/admin_rights
	while(select_query.NextRow())
		admin_id = text2num(select_query.item[1])
		admin_rights = text2num(select_query.item[2])
	if(!admin_id)
		return
	if(admin_rights & new_permission) //This admin already has this permission, so we are removing it.
		var/DBQuery/insert_query = dbcon.NewQuery("UPDATE `erro_admin` SET flags = [admin_rights & ~new_permission] WHERE id = [admin_id]")
		insert_query.Execute()
		var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `erro_admin_log` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , '[usr.ckey]', '[usr.client.address]', 'Removed permission [rights2text(new_permission)] (flag = [new_permission]) to admin [adm_ckey]');")
		log_query.Execute()
		to_chat(usr, "\blue Permission removed.")
	else //This admin doesn't have this permission, so we are adding it.
		var/DBQuery/insert_query = dbcon.NewQuery("UPDATE `erro_admin` SET flags = '[admin_rights | new_permission]' WHERE id = [admin_id]")
		insert_query.Execute()
		var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `erro_admin_log` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , '[usr.ckey]', '[usr.client.address]', 'Added permission [rights2text(new_permission)] (flag = [new_permission]) to admin [adm_ckey]')")
		log_query.Execute()
		to_chat(usr, "\blue Permission added.")

/datum/admins/proc/add_mentor()
	if(!usr.client)
		return
	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "\red You do not have permission to do this!")
		return
	var/ment_ckey = ckey(input(usr,"New mentor's ckey","Mentor ckey", null) as text|null)
	if(!ment_ckey)
		return
	if(ment_ckey in mentor_ckeys)
		to_chat(usr, "<font color='red'>Error: Topic 'editmentorlist': [ment_ckey] is already a mentor.</font>")
		return
	if(ment_ckey in admin_datums)
		remove_admin(ment_ckey)
	mentor_ckeys += ment_ckey
	mentors += directory[ment_ckey]
	message_admins("[key_name_admin(usr)] added [ment_ckey] to the mentors list")
	log_admin("[key_name(usr)] added [ment_ckey] to the mentors list")

	establish_db_connection()
	if(!dbcon.IsConnected())
		to_chat(usr, "\red Failed to establish database connection")
		return
	ment_ckey = ckey(ment_ckey)
	var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO `erro_mentor` (`id`, `ckey`) VALUES (null, '[ment_ckey]');")
	insert_query.Execute()
	var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `erro_admin_log` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , '[usr.ckey]', '[usr.client.address]', 'Added new mentor [ment_ckey].');")
	log_query.Execute()
	to_chat(usr, "<font color='blue'> New mentor added.</font>")

/datum/admins/proc/remove_mentor(ment_ckey)
	if(!usr.client)
		return
	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "\red You do not have permission to do this!")
		return
	if(!ment_ckey)
		to_chat(usr, "<font color='red'>Error: Topic 'editmentorlist': [ment_ckey] is not a valid mentor.</font>")
		return
	if(alert("Are you sure you want to remove [ment_ckey] from mentors?","Message","Yes","Cancel") == "Yes")
		mentor_ckeys -= ment_ckey
		mentors -= directory[ment_ckey]
		message_admins("[key_name_admin(usr)] removed [ment_ckey] from the mentors list")
		log_admin("[key_name(usr)] removed [ment_ckey] from the mentors list")

		establish_db_connection()
		if(!dbcon.IsConnected())
			to_chat(usr, "\red Failed to establish database connection")
			return
		ment_ckey = ckey(ment_ckey)
		var/DBQuery/remove_query = dbcon.NewQuery("DELETE FROM `erro_mentor` WHERE `ckey` = '[ment_ckey]';")
		remove_query.Execute()
		var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `erro_admin_log` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , '[usr.ckey]', '[usr.client.address]', 'Removed mentor [ment_ckey].');")
		log_query.Execute()
		to_chat(usr, "<font color='blue'> Mentor removed.</font>")


/datum/admins/proc/db_admin_rank_modification(adm_ckey, new_rank)
	if(config.admin_legacy_system)
		return
	if(!usr.client)
		return
	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "\red You do not have permission to do this!")
		return
	establish_db_connection()
	if(!dbcon.IsConnected())
		to_chat(usr, "\red Failed to establish database connection")
		return
	if(!adm_ckey || !new_rank)
		return
	adm_ckey = ckey(adm_ckey)
	if(!adm_ckey)
		return
	if(!istext(adm_ckey) || !istext(new_rank))
		return
	var/DBQuery/select_query = dbcon.NewQuery("SELECT id FROM erro_admin WHERE ckey = '[adm_ckey]'")
	select_query.Execute()
	var/new_admin = 1
	var/admin_id
	while(select_query.NextRow())
		new_admin = 0
		admin_id = text2num(select_query.item[1])
	if(new_admin)
		var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO `erro_admin` (`id`, `ckey`, `rank`, `level`, `flags`) VALUES (null, '[adm_ckey]', '[new_rank]', -1, 0)")
		insert_query.Execute()
		var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `erro_admin_log` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , '[usr.ckey]', '[usr.client.address]', 'Added new admin [adm_ckey] to rank [new_rank]');")
		log_query.Execute()
		to_chat(usr, "\blue New admin added.")
	else
		if(!isnull(admin_id) && isnum(admin_id))
			var/DBQuery/insert_query = dbcon.NewQuery("UPDATE `erro_admin` SET rank = '[new_rank]' WHERE id = [admin_id]")
			insert_query.Execute()
			var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `erro_admin_log` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , '[usr.ckey]', '[usr.client.address]', 'Edited the rank of [adm_ckey] to [new_rank]');")
			log_query.Execute()
			to_chat(usr, "\blue Admin rank changed.")
