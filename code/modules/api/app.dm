var/global/list/routes = list(
	"/api/v1/knowledgebase" = ROUTE(
		process_knowledgebase_request,
		list(
			"ckey" = CKEY_PARAM,
			"name" = STRING_PARAM,
			"index" = INTEGER_PARAM(1, MAX_SAVE_SLOTS, 1)
		)
	)
)

/proc/process_knowledgebase_request(ckey, name, index)
	return
