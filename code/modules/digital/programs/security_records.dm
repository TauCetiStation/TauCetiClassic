/datum/digital/file/program/secrecords
	name = "Security Records"
	fileicon = "vcard"

	var/authenticated = null
	var/datum/data/record/show = null

	var/sortBy = "name"

	var/a_id = null
	var/temp = null
	var/can_change_id = 0
	var/list/Perp
	var/tempname = null
	//Sorting Variables
	var/order = 1 // -1 = Descending - 1 = Ascending
	var/static/icon/mugshot = icon('icons/obj/mugshot.dmi', "background") //records photo background
	var/next_print = 0
	var/docname

/datum/digital/file/program/secrecords/New(newtype, newname,  newcontent, newicon, drive, newfolder_id)
	. = ..()

/datum/digital/file/program/secrecords/open(datum/digital/file/File)

/datum/digital/file/program/secrecords/close()

/datum/digital/file/program/secrecords/process_data(list/data, mob/user)
	var/list/records_to_front = list()

	if(!isnull(data_core.general))
		for(var/datum/data/record/Rec in sortRecord(data_core.general, sortBy, order))
			break
	data["records_list"] = records_to_front

	return data

/datum/digital/file/program/secrecords/act(action, list/params, mob/user)
	return