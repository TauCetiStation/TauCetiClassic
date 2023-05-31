/proc/sql_report_death(mob/living/carbon/human/H)
	if(!config.sql_enabled)
		return
	if(!H)
		return
	if(!H.key || !H.mind)
		return

	var/turf/T = H.loc
	var/area/placeofdeath = get_area(T.loc)
	var/podname = placeofdeath.name

	var/sqlname = sanitize_sql(H.real_name)
	var/sqlkey = sanitize_sql(H.key)
	var/sqlpod = sanitize_sql(podname)
	var/sqlspecial = sanitize_sql(H.mind.special_role)
	var/sqljob = sanitize_sql(H.mind.assigned_role)
	var/laname
	var/lakey
	if(H.lastattacker_name && H.lastattacker_key)
		laname = sanitize_sql(H.lastattacker_name)
		lakey = sanitize_sql(H.lastattacker_key)
	var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/sqlcoord = sanitize_sql("[H.x], [H.y], [H.z]")

	var/sqlgender = sanitize_sql(H.gender)

	var/sqlbrute = text2num(H.getBruteLoss())
	var/sqlfire = text2num(H.getFireLoss())
	var/sqlbrain = text2num(H.brainloss)
	var/sqloxy = text2num(H.getOxyLoss())

	if(establish_db_connection("erro_death"))
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO erro_death (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord) VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[sqltime]', '[laname]', '[lakey]', '[sqlgender]', [sqlbrute], [sqlfire], [sqlbrain], [sqloxy], '[sqlcoord]')")
		query.Execute()

/proc/sql_report_cyborg_death(mob/living/silicon/robot/H)
	if(!config.sql_enabled)
		return
	if(!H)
		return
	if(!H.key || !H.mind)
		return

	var/turf/T = H.loc
	var/area/placeofdeath = get_area(T.loc)
	var/podname = placeofdeath.name

	var/sqlname = sanitize_sql(H.real_name)
	var/sqlkey = sanitize_sql(H.key)
	var/sqlpod = sanitize_sql(podname)
	var/sqlspecial = sanitize_sql(H.mind.special_role)
	var/sqljob = sanitize_sql(H.mind.assigned_role)
	var/laname
	var/lakey
	if(H.lastattacker_name && H.lastattacker_key)
		laname = sanitize_sql(H.lastattacker_name)
		lakey = sanitize_sql(H.lastattacker_key)
	var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/sqlcoord = sanitize_sql("[H.x], [H.y], [H.z]")

	var/sqlgender = sanitize_sql(H.gender)

	var/sqlbrute = text2num(H.getBruteLoss())
	var/sqlfire = text2num(H.getFireLoss())
	var/sqlbrain = text2num(H.brainloss)
	var/sqloxy = text2num(H.getOxyLoss())

	if(establish_db_connection("erro_death"))
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO erro_death (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord) VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[sqltime]', '[laname]', '[lakey]', '[sqlgender]', [sqlbrute], [sqlfire], [sqlbrain], [sqloxy], '[sqlcoord]')")
		query.Execute()

//This proc is used for feedback. It is executed at round end.
/proc/sql_commit_feedback()
	if(!blackbox)
		log_game("Round ended without a blackbox recorder. No feedback was sent to the database.")
		return

	//content is a list of lists. Each item in the list is a list with two fields, a variable name and a value. Items MUST only have these two values.
	var/list/datum/feedback_variable/content = blackbox.get_round_feedback()

	if(!content)
		log_game("Round ended without any feedback being generated. No feedback was sent to the database.")
		return

	if(establish_db_connection("erro_feedback"))
		for(var/datum/feedback_variable/item in content)
			var/variable = item.get_variable()
			var/value = item.get_value()

			var/DBQuery/query = dbcon.NewQuery("INSERT INTO erro_feedback (id, roundid, time, variable, value) VALUES (null, [global.round_id], Now(), '[sanitize_sql(variable)]', '[sanitize_sql(value)]')")
			query.Execute()
