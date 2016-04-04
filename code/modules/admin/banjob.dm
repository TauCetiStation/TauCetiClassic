//returns a reason if M is banned from rank, returns 0 otherwise
/proc/jobban_isbanned(mob/M, rank)
	if(!M || !istype(M) || !M.ckey)
		return 0

	if(!M.client) //no cache. fallback to a DBQuery
		var/DBQuery/query = dbcon.NewQuery("SELECT reason FROM erro_ban WHERE ckey = '[sanitizeSQL(M.ckey)]' AND job = '[sanitizeSQL(rank)]' AND (bantype = 'JOB_PERMABAN'  OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")
		if(!query.Execute())
			log_game("SQL ERROR obtaining jobbans. Error : \[[query.ErrorMsg()]\]\n")
			return
		if(query.NextRow())
			var/reason = query.item[1]
			return reason ? reason : 1 //we don't want to return "" if there is no ban reason, as that would evaluate to false
		else
			return 0

	if(!M.client.jobbancache)
		jobban_buildcache(M.client)

	if(rank in M.client.jobbancache)
		var/reason = M.client.jobbancache[rank]
		return (reason) ? reason : 1 //see above for why we need to do this

	if(config.use_ingame_minutes_restriction_for_jobs)
		if(M.client && !M.client.holder && !M.client.deadmin_holder && isnum(M.client.player_ingame_age))
			switch(rank)
				if(ROLE_TRAITOR,ROLE_CHANGELING,ROLE_OPERATIVE,ROLE_RAIDER,ROLE_DRONE,ROLE_ALIEN)
					var/available_in_minutes = max(0, 480 - M.client.player_ingame_age)
					if(available_in_minutes > 0)
						return "Not enough playtime. Available in [available_in_minutes] minutes."
				if(ROLE_CULTIST,ROLE_WIZARD,ROLE_ERT,ROLE_MEME,ROLE_REV,ROLE_BLOB)
					var/available_in_minutes = max(0, 960 - M.client.player_ingame_age)
					if(available_in_minutes > 0)
						return "Not enough playtime. Available in [available_in_minutes] minutes."
				if(ROLE_MUTINEER,ROLE_SHADOWLING,ROLE_ABDUCTOR,ROLE_MALF,ROLE_NINJA)
					var/available_in_minutes = max(0, 1200 - M.client.player_ingame_age)
					if(available_in_minutes > 0)
						return "Not enough playtime. Available in [available_in_minutes] minutes."

	return 0

/proc/jobban_buildcache(client/C)
	if(C && istype(C))
		C.jobbancache = list()
		var/DBQuery/query = dbcon.NewQuery("SELECT job, reason FROM erro_ban WHERE ckey = '[sanitizeSQL(C.ckey)]' AND (bantype = 'JOB_PERMABAN'  OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")
		if(!query.Execute())
			log_game("SQL ERROR obtaining jobbans. Error : \[[query.ErrorMsg()]\]\n")
			return
		while(query.NextRow())
			C.jobbancache[query.item[1]] = query.item[2]

/proc/ban_unban_log_save(var/formatted_log)
	text2file(formatted_log,"data/ban_unban_log.txt")
