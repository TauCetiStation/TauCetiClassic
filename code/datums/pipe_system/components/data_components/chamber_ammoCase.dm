/datum/pipe_system/component/data/chamber_ammoCase
	id_component = AMMO_FIRE
	id_data = AMMO_FIRE

/datum/pipe_system/component/data/chamber_ammoCase/New(datum/P, obj/item/ammo_casing/ammo)

	if(!ammo)
		return ..()

	value = ammo
	. = ..()

/datum/pipe_system/component/data/chamber_ammoCase/IsValid()
	if(!..())
		return FALSE

	if(isnull(value))
		return FALSE

	if(!istype(value, /obj/item/ammo_casing))
		return FALSE

	return TRUE

