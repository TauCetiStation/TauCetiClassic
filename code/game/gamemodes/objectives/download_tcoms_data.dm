/datum/objective/download_telecommunications_data
	explanation_text = "Скачайте важную информацию с телекоммуникационного узла на выданную вам дискету."
	required_equipment = /obj/item/weapon/disk/telecomms

/datum/objective/download_telecommunications_data/check_completion()
	var/list/items = owner.current.GetAllContents()
	for(var/obj/item/i in items)
		if(istype(i, required_equipment))
			var/obj/item/weapon/disk/telecomms/disk = i
			if(disk.have_data == TRUE)
				return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
