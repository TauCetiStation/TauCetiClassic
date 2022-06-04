/datum/process_fire
    var/list/data = list()

/datum/process_fire/proc/PrepareDataList()

    LAZYINITLIST(data)

    return TRUE

/datum/process_fire/proc/CheckData(id)

    PrepareDataList()

    if(!data[id])
        return FALSE
    
    return TRUE

/datum/process_fire/proc/GetData(id)

    PrepareDataList()

    if(!CheckData(id))
        return null

    return data[id]

/datum/process_fire/proc/SetData(id, value)

    PrepareDataList()

    data[id] = value

    return TRUE

/datum/process_fire/proc/CopyData()

    PrepareDataList()

    return data.Copy