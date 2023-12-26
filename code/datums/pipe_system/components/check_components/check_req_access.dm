/datum/pipe_system/component/check/req_access
	description = "(REQ_ACCESS_DATA, ACCESS_DATA) Проверка доступа"

/datum/pipe_system/component/check/req_access/RunTimeAction(datum/pipe_system/process/process)


	var/datum/pipe_system/component/data/req_access/req_access_data = process.GetCacheData(REQ_ACCESS_DATA)
	var/datum/pipe_system/component/data/access/access_data = process.GetCacheData(ACCESS_DATA)

	if(!req_access_data || !access_data)
		return FailCheck(process)

	if(!req_access_data.IsValid() || !access_data.IsValid())
		return FailCheck(process)

	var/list/req_access = req_access_data.value

	if(!req_access.len)
		return SuccessCheck(process)

	if(access_data.value in req_access)
		return SuccessCheck(process)

	return FailCheck(process)
