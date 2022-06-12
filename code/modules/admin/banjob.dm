//returns a reason if M is banned from rank, returns 0 otherwise
/proc/jobban_isbanned(mob/M, rank)
	if(!M || !istype(M) || !M.ckey)
		return FALSE

	if(!M.client) //no cache. fallback to a DBQuery
		var/DBQuery/query = dbcon.NewQuery("SELECT reason FROM erro_ban WHERE ckey = '[ckey(M.ckey)]' AND job = '[sanitize_sql(rank)]' AND (bantype = 'JOB_PERMABAN'  OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")
		if(!query.Execute())
			return
		if(query.NextRow())
			var/reason = query.item[1]
			return reason ? reason : TRUE //we don't want to return "" if there is no ban reason, as that would evaluate to false
		else
			return FALSE

	if(!M.client.jobbancache)
		jobban_buildcache(M.client)

	if(rank in M.client.jobbancache)
		var/reason = M.client.jobbancache[rank]["reason"]
		return (reason) ? reason : TRUE //see above for why we need to do this

	return FALSE

/proc/jobban_buildcache(client/C)
	if(C && istype(C))
		C.jobbancache = list()
		var/DBQuery/query = dbcon.NewQuery("SELECT job, bantime, bantype, reason, duration, expiration_time, a_ckey, round_id FROM erro_ban WHERE ckey = '[ckey(C.ckey)]' AND (bantype = 'JOB_PERMABAN'  OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")
		if(!query.Execute())
			return
		while(query.NextRow())
			C.jobbancache[query.item[1]] = list(
			"bantime" = query.item[2],
			"bantype" = query.item[3],
			"reason" = query.item[4],
			"duration" = query.item[5],
			"expiration" = query.item[6],
			"ackey" = query.item[7],
			"rid" = text2num(query.item[8])
			)

/proc/ban_unban_log_save(formatted_log)
	text2file(formatted_log,"data/ban_unban_log.txt")
