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
		output += "<td><a class='small' href='?src=\ref[src];editrights=get_new_rights;ckey=[adm_ckey]'>[rights]</a></td>"
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
		to_chat(usr, "<span class='alert'>You do not have permission to do this!</span>")
		return
	var/adm_ckey = ckey(input(usr,"New admin's ckey","Admin ckey", null) as text|null)
	if(!adm_ckey)
		return
	if(adm_ckey in admin_datums)
		to_chat(usr, "<span class='alert'>Error: Topic 'editrights': [adm_ckey] is already an admin</span>")
		return
	if(adm_ckey in mentor_ckeys)
		remove_mentor(adm_ckey)
	edit_rank(adm_ckey)

/datum/admins/proc/remove_admin(adm_ckey)
	if(!usr.client)
		return
	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "<span class='alert'>You do not have permission to do this!</span>")
		return
	if(!adm_ckey)
		to_chat(usr, "<span class='alert'>Error: Topic 'editrights': No valid ckey</span>")
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
		to_chat(usr, "<span class='alert'>You do not have permission to do this!</span>")
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
			new_rank = sanitize(input("Please input a new rank", "New custom rank", null, null) as null|text)
			if(!new_rank)
				to_chat(usr, "<span class='alert'>Error: Topic 'editrights': Invalid rank</span>")
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


/datum/admins/proc/get_new_rights(adm_ckey)
	if(!usr.client)
		return
	if(!adm_ckey)
		return
	var/datum/admins/D = admin_datums[adm_ckey]
	if(!D)
		return
	var/output = {"<!DOCTYPE html>
<html>
<head>
<title>Permissions modification panel</title>
<script>
function send_rights() {
var elements = document.getElementsByName('rights');
	var new_rights = 0;
	for (var i = 0; i < elements.length; i++) {
		if(elements\[i\].checked) {
			new_rights |= 1 << i;
		}
	}
	window.location='?src=\ref[src];editrights=permissions;ckey=[adm_ckey];new_rights='+new_rights+';'
}
</script>
</head>
<fieldset>
<legend>Check all needed flags.</legend>
<br>
<span style="font-size: 12px;">"}
	for(var/i=1, i<=R_MAXPERMISSION, i<<=1)
		output += {"<input "}
		if(D.rights & i)
			output += {"checked "}
		output += {"type="checkbox" name="rights" />[rights2text(i)]<br>"}
	output += {"<br></span>
</fieldset>
<input type="button" value="Apply" onclick="send_rights()" />
</html>
"}
	usr << browse(output,"window=change_permissions;size=250x380;")


/datum/admins/proc/change_permissions(adm_ckey, new_rights)
	if(!usr.client)
		return
	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "<span class='alert'>You do not have permission to do this!</span>")
		return
	if(!adm_ckey)
		return
	if(!new_rights)
		return
	var/datum/admins/D = admin_datums[adm_ckey]
	if(!D)
		return
	var/added_rights = ""
	var/removed_rights = ""
	for(var/mask = 1, mask <= R_MAXPERMISSION, mask <<= 1)
		var/masked_newrights = new_rights & mask
		var/masked_oldrights = D.rights & mask
		if(masked_newrights == masked_oldrights)
			continue
		if(masked_newrights)
			added_rights += rights2text(mask," ")
		else
			removed_rights += rights2text(mask," ")
	D.rights = new_rights
	if(added_rights)
		message_admins("[key_name_admin(usr)] added[added_rights] permissions of [adm_ckey]")
		log_admin("[key_name(usr)] added[added_rights] permission of [adm_ckey]")
	if(removed_rights)
		message_admins("[key_name_admin(usr)] removed[removed_rights] permissions of [adm_ckey]")
		log_admin("[key_name(usr)] removed[removed_rights] permission of [adm_ckey]")

	establish_db_connection()
	if(!dbcon.IsConnected())
		to_chat(usr, "<span class='alert'>Failed to establish database connection</span>")
		return
	adm_ckey = ckey(adm_ckey)
	if(!istext(adm_ckey) || !isnum(new_rights))
		return
	var/DBQuery/select_query = dbcon.NewQuery("SELECT id FROM erro_admin WHERE ckey = '[adm_ckey]'")
	select_query.Execute()
	var/admin_id
	while(select_query.NextRow())
		admin_id = text2num(select_query.item[1])
	if(!admin_id)
		return
	var/DBQuery/insert_query = dbcon.NewQuery("UPDATE `erro_admin` SET flags = [new_rights] WHERE id = [admin_id]")
	insert_query.Execute()
	if(removed_rights)
		var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `erro_admin_log` (`id`, `datetime`, `round_id`, `adminckey`, `adminip`, `log`) VALUES (NULL, NOW( ), [round_id], '[sanitize_sql(usr.ckey)]', '[sanitize_sql(usr.client.address)]', 'Removed permission[removed_rights] to admin [adm_ckey]');")
		log_query.Execute()
		to_chat(usr, "<span class='notice'>Permissions removed.</span>")
	if(added_rights)
		var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `erro_admin_log` (`id`, `datetime`, `round_id`, `adminckey`, `adminip`, `log` ) VALUES (NULL, NOW( ), [round_id], '[sanitize_sql(usr.ckey)]', '[sanitize_sql(usr.client.address)]', 'Added permission[added_rights] to admin [adm_ckey]')")
		log_query.Execute()
		to_chat(usr, "<span class='notice'>Permissions added.</span>")

/datum/admins/proc/add_mentor()
	if(!usr.client)
		return
	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "<span class='alert'>You do not have permission to do this!</span>")
		return
	var/ment_ckey = ckey(input(usr,"New mentor's ckey","Mentor ckey", null) as text|null)
	if(!ment_ckey)
		return
	if(ment_ckey in mentor_ckeys)
		to_chat(usr, "<span class='alert'>Error: Topic 'editmentorlist': [ment_ckey] is already a mentor.</span>")
		return
	if(ment_ckey in admin_datums)
		remove_admin(ment_ckey)
	mentor_ckeys += ment_ckey
	mentors += directory[ment_ckey]
	message_admins("[key_name_admin(usr)] added [ment_ckey] to the mentors list")
	log_admin("[key_name(usr)] added [ment_ckey] to the mentors list")

	establish_db_connection()
	if(!dbcon.IsConnected())
		to_chat(usr, "<span class='alert'>Failed to establish database connection</span>")
		return
	ment_ckey = ckey(ment_ckey)
	var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO `erro_mentor` (`id`, `ckey`) VALUES (null, '[ment_ckey]');")
	insert_query.Execute()
	var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `erro_admin_log` (`id` ,`datetime` , `round_id` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , [round_id], '[sanitize_sql(usr.ckey)]', '[sanitize_sql(usr.client.address)]', 'Added new mentor [ment_ckey].');")
	log_query.Execute()
	to_chat(usr, "<span class='notice'>New mentor added.</span>")

/datum/admins/proc/remove_mentor(ment_ckey)
	if(!usr.client)
		return
	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "<span class='alert'>You do not have permission to do this!</span>")
		return
	if(!ment_ckey)
		to_chat(usr, "<span class='alert'>Error: Topic 'editmentorlist': [ment_ckey] is not a valid mentor.</span>")
		return
	if(alert("Are you sure you want to remove [ment_ckey] from mentors?","Message","Yes","Cancel") == "Yes")
		mentor_ckeys -= ment_ckey
		mentors -= directory[ment_ckey]
		message_admins("[key_name_admin(usr)] removed [ment_ckey] from the mentors list")
		log_admin("[key_name(usr)] removed [ment_ckey] from the mentors list")

		establish_db_connection()
		if(!dbcon.IsConnected())
			to_chat(usr, "<span class='alert'>Failed to establish database connection</span>")
			return
		ment_ckey = ckey(ment_ckey)
		var/DBQuery/remove_query = dbcon.NewQuery("DELETE FROM `erro_mentor` WHERE `ckey` = '[ment_ckey]';")
		remove_query.Execute()
		var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `erro_admin_log` (`id` ,`datetime` ,`round_id` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , [round_id], '[sanitize_sql(usr.ckey)]', '[sanitize_sql(usr.client.address)]', 'Removed mentor [ment_ckey].');")
		log_query.Execute()
		to_chat(usr, "<span class='notice'>Mentor removed.</span>")


/datum/admins/proc/db_admin_rank_modification(adm_ckey, new_rank)
	if(config.admin_legacy_system)
		return
	if(!usr.client)
		return
	if(!usr.client.holder || !(usr.client.holder.rights & R_PERMISSIONS))
		to_chat(usr, "<span class='alert'>You do not have permission to do this!</span>")
		return
	establish_db_connection()
	if(!dbcon.IsConnected())
		to_chat(usr, "<span class='alert'>Failed to establish database connection</span>")
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
		var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `erro_admin_log` (`id` ,`datetime` ,`round_id` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , [round_id], '[sanitize_sql(usr.ckey)]', '[sanitize_sql(usr.client.address)]', 'Added new admin [adm_ckey] to rank [new_rank]');")
		log_query.Execute()
		to_chat(usr, "<span class='notice'>New admin added.</span>")
	else
		if(!isnull(admin_id) && isnum(admin_id))
			var/DBQuery/insert_query = dbcon.NewQuery("UPDATE `erro_admin` SET rank = '[new_rank]' WHERE id = [admin_id]")
			insert_query.Execute()
			var/DBQuery/log_query = dbcon.NewQuery("INSERT INTO `erro_admin_log` (`id` ,`datetime` ,`round_id` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , [round_id], '[sanitize_sql(usr.ckey)]', '[sanitize_sql(usr.client.address)]', 'Edited the rank of [adm_ckey] to [new_rank]');")
			log_query.Execute()
			to_chat(usr, "<span class='notice'>Admin rank changed.</span>")
