/proc/get_job_department(var/job)
	if(!job)
		return

	if(job in jexp_jobs_xptable)
		return list(jexp_jobs_xptable["[job]"][1],jexp_jobs_xptable["[job]"][2])

/datum/jobs_experience
	var/list/xp_table = list(
		"command" = 0,
		"security" = 0,
		"civilian" = 0,
		"cargo" = 0,
		"medical" = 0,
		"science" = 0,
		"engineering" = 0,
		"silicon" = 0
	)

/datum/jobs_experience/New(client/C)
	if(!C) return
	load(C)

/datum/jobs_experience/proc/load(client/C)
	establish_db_connection()

	if(!dbcon.IsConnected())
		return

	var/sql_ckey = sql_sanitize_text(C.ckey)
	var/DBQuery/select_query = dbcon.NewQuery("SELECT command, security, civilian, cargo, medical, science, engineering, silicon FROM erro_playerxp WHERE ckey = '[sql_ckey]'")
	select_query.Execute()

	while(select_query.NextRow())
		xp_table["command"] = text2num(select_query.item[1])
		xp_table["security"] = text2num(select_query.item[2])
		xp_table["civilian"] = text2num(select_query.item[3])
		xp_table["cargo"] = text2num(select_query.item[4])
		xp_table["medical"] = text2num(select_query.item[5])
		xp_table["science"] = text2num(select_query.item[6])
		xp_table["engineering"] = text2num(select_query.item[7])
		xp_table["silicon"] = text2num(select_query.item[8])

/datum/jobs_experience/proc/save(mob/living/M)
	if(!M) return
	if(!isliving(M)) return
	if(!M.mind) return

	establish_db_connection()

	if(!dbcon.IsConnected())
		return

	if(M.mind.role_alt_title == "Assistant")
		for(var/x in jexp_departments)
			xp_table["[x]"] += 1

		var/sql_ckey = sql_sanitize_text(M.ckey)
		var/DBQuery/update_query = dbcon.NewQuery("UPDATE `erro_playerxp` SET command = '[xp_table["command"]]', security = '[xp_table["security"]]', civilian = '[xp_table["civilian"]]', cargo = '[xp_table["cargo"]]', medical = '[xp_table["medical"]]', science = '[xp_table["science"]]', engineering = '[xp_table["engineering"]]', silicon = '[xp_table["silicon"]]' WHERE ckey = '[sql_ckey]'")
		update_query.Execute()
	else
		var/list/depname_and_bonus = get_job_department(M.mind.role_alt_title)
		if(!depname_and_bonus || !depname_and_bonus.len)
			return

		var/department_name = depname_and_bonus[1]
		var/department_bonus = depname_and_bonus[2]

		if(!department_name || !department_bonus)
			return

		xp_table["[department_name]"] += department_bonus

		//world << "dn = [depname_and_bonus[1]] : db = [depname_and_bonus[2]]"
		//world << "1: [department_bonus]"
		//world << "2: [xp_table["[department_name]"]]"

		var/sql_ckey = sql_sanitize_text(M.ckey)
		var/DBQuery/update_query = dbcon.NewQuery("UPDATE `erro_playerxp` SET [department_name] = '[xp_table["[department_name]"]]' WHERE ckey = '[sql_ckey]'")
		update_query.Execute()

	//world << "saved"
