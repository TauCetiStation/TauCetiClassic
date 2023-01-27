/datum/digital/file/program/secrecords
	name = "Security Records"
	fileicon = "vcard"

	var/authenticated = null
	var/datum/data/record/show_record = null

	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending

	var/static/icon/mugshot = icon('icons/obj/mugshot.dmi', "background") //records photo background

/datum/digital/file/program/secrecords/New(newtype, newname,  newcontent, newicon, drive, newfolder_id)
	. = ..()

/datum/digital/file/program/secrecords/open(datum/digital/file/File)

/datum/digital/file/program/secrecords/close()

/datum/digital/file/program/secrecords/process_data(list/data, mob/user)
	var/list/records_to_front = list()

	if(!isnull(data_core.general))
		for(var/datum/data/record/Rec in sortRecord(global.data_core.general, sortBy, order))
			records_to_front += list(list("name" = Rec.fields["name"], "id" = Rec.fields["id"], "rank" = Rec.fields["rank"], "fingerprint" = Rec.fields["fingerprint"], "criminal" = Rec.fields["criminal"]))
	data["records_list"] = records_to_front

	if(show_record)
		data["record_content"] = show_record.fields
	else
		data["record_content"] = null

	return data

/datum/digital/file/program/secrecords/act(action, list/params, mob/user)
	switch(action)
		if("select_record")
			var/record_id = sanitize(params["select_record_id"])
			if(isnum(record_id))
				for(var/datum/data/record/Rec in global.data_core.general)
					if(Rec.fields["id"] == record_id)
						show_record = Rec

						var/icon/front = show_record.fields["photo_f"]
						front.Blend(mugshot,ICON_UNDERLAY,1,1)
						var/icon/side = show_record.fields["photo_s"]
						side.Blend(mugshot,ICON_UNDERLAY,1,1)

						user << browse_rsc(front, "record_photo_front.png")
						user << browse_rsc(side, "record_photo_side.png")
						break
			return
		if("change_order")
			order = -order
			return
		if("sort_by")
			var/sort_by = sanitize(params["records_sort_by"])
			if(sort_by)
				sortBy = sort_by
			return

