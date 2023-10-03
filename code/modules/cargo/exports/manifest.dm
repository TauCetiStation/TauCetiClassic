// Approved manifest.
/datum/export/manifest_correct
	cost = CARGO_MANIFEST_COST
	unit_name = "approved manifest"
	export_types = list(/obj/item/weapon/paper/manifest)

/datum/export/manifest_correct/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/weapon/paper/manifest/M = O
	if(M.is_approved() && !M.errors)
		return TRUE
	return FALSE


// Correctly denied manifest.
/datum/export/manifest_error_denied
	cost = CARGO_MANIFEST_COST
	unit_name = "correctly denied manifest"
	export_types = list(/obj/item/weapon/paper/manifest)

/datum/export/manifest_error_denied/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/weapon/paper/manifest/M = O
	if(M.is_denied() && M.errors)
		return TRUE
	return FALSE


// Erroneously approved manifest.
/datum/export/manifest_error
	cost = -CARGO_MANIFEST_COST
	unit_name = "erroneously approved manifest"
	export_types = list(/obj/item/weapon/paper/manifest)

/datum/export/manifest_error/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/weapon/paper/manifest/M = O
	if(M.is_approved() && M.errors)
		return TRUE
	return FALSE


// Erroneously denied manifest.
/datum/export/manifest_correct_denied
	cost = -CARGO_MANIFEST_COST
	unit_name = "erroneously denied manifest"
	export_types = list(/obj/item/weapon/paper/manifest)

/datum/export/manifest_correct_denied/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/weapon/paper/manifest/M = O
	if(M.is_denied() && !M.errors)
		return TRUE
	return FALSE
