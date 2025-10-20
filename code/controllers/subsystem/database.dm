SUBSYSTEM_DEF(database)
	name = "Database"
	flags = SS_NO_FIRE

/datum/controller/subsystem/database/Initialize()
	maintenance()
	return ..()

/datum/controller/subsystem/database/proc/maintenance()

	if(establish_db_connection("erro_auth_token"))
		var/DBQuery/query = dbcon.NewQuery({"DELETE FROM erro_auth_token WHERE expires_at <= NOW();"})
		query.Execute()
