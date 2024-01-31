/datum/continuity_object/barrels
	filename = "Preservation_Barrels"

/datum/continuity_object/barrels/proc/spawn_maintenance_barrel()
	var/turf/T = pick(global.maintenance_barrels_landmarks)
	new /obj/structure/preservation_barrel/maintenance(T)

/datum/continuity_object/barrels/load(savefile/S)
	spawn_maintenance_barrel()

	var/params_holder
	S["Barrels_Save"] >> params_holder
	if(!params_holder)
		return

	var/list/barrels_saves = params2list(params_holder)
	for(var/save_id in barrels_saves)
		barrels_saves[save_id] = params2list(barrels_saves[save_id])

	for(var/obj/structure/preservation_barrel/Barrel in global.preservation_barrels)
		if(!barrels_saves[Barrel.save_id])
			continue
		var/barrel_record = pick(barrels_saves[Barrel.save_id])
		if(barrel_record)
			Barrel.continuity_read(params2list(barrel_record))
			barrels_saves[Barrel.save_id] -= barrel_record

/datum/continuity_object/barrels/save(savefile/S)
	var/list/barrels_saves = list()

	for(var/obj/structure/preservation_barrel/Barrel in global.preservation_barrels)
		var/barrel_record = Barrel.continuity_write()

		if(!barrels_saves[Barrel.save_id])
			barrels_saves[Barrel.save_id] = list(barrel_record)
		else
			barrels_saves[Barrel.save_id] += barrel_record

	for(var/save_id in barrels_saves)
		barrels_saves[save_id] = list2params(barrels_saves[save_id])

	S["Barrels_Save"] << list2params(barrels_saves)


/datum/continuity_object/tables
	filename = "Preservation_Tables"

/datum/continuity_object/tables/load(savefile/S)
	var/params_holder
	S["Tables_Save"] >> params_holder
	if(!params_holder)
		return

	var/list/tables_saves = params2list(params_holder)
	for(var/save_id in tables_saves)
		tables_saves[save_id] = params2list(tables_saves[save_id])

	for(var/obj/structure/preservation_table/Table in global.preservation_tables)
		var/table_record = pick(tables_saves[Table.save_id])
		if(table_record)
			Table.continuity_read(params2list(table_record))
			tables_saves[Table.save_id] -= table_record

/datum/continuity_object/tables/save(savefile/S)
	var/list/tables_saves = list()

	for(var/obj/structure/preservation_table/Table in global.preservation_tables)
		var/table_record = Table.continuity_write()

		if(!tables_saves[Table.save_id])
			tables_saves[Table.save_id] = list(table_record)
		else
			tables_saves[Table.save_id] += table_record

	for(var/save_id in tables_saves)
		tables_saves[save_id] = list2params(tables_saves[save_id])

	S["Tables_Save"] << list2params(tables_saves)


/datum/continuity_object/boxes
	filename = "Preservation_Boxes"

/datum/continuity_object/boxes/load(savefile/S)
	var/params_holder
	S["Boxes_Save"] >> params_holder
	if(!params_holder)
		return

	var/list/boxes_saves = params2list(params_holder)
	for(var/save_id in boxes_saves)
		boxes_saves[save_id] = params2list(boxes_saves[save_id])

	for(var/obj/structure/preservation_box/Box in global.preservation_boxes)
		var/box_record = pick(boxes_saves[Box.save_id])
		if(box_record)
			Box.continuity_read(params2list(box_record))
			boxes_saves[Box.save_id] -= box_record

/datum/continuity_object/boxes/save(savefile/S)
	var/list/boxes_saves = list()

	for(var/obj/structure/preservation_box/Box in global.preservation_boxes)
		var/box_record = Box.continuity_write()

		if(!boxes_saves[Box.save_id])
			boxes_saves[Box.save_id] = list(box_record)
		else
			boxes_saves[Box.save_id] += box_record

	for(var/save_id in boxes_saves)
		boxes_saves[save_id] = list2params(boxes_saves[save_id])

	S["Boxes_Save"] << list2params(boxes_saves)


/datum/continuity_object/composters
	filename = "Preservation_Composters"

/datum/continuity_object/composters/load(savefile/S)
	var/params_holder
	S["Composters_Save"] >> params_holder
	if(!params_holder)
		return

	var/list/composters_saves = params2list(params_holder)
	for(var/save_id in composters_saves)
		composters_saves[save_id] = params2list(composters_saves[save_id])

	for(var/obj/structure/composter/Comp in global.composters)
		var/composter_record = pick(composters_saves[Comp.save_id])
		if(composter_record)
			Comp.continuity_read(params2list(composter_record))
			composters_saves[Comp.save_id] -= composter_record

/datum/continuity_object/composters/save(savefile/S)
	var/list/composters_saves = list()

	for(var/obj/structure/composter/Comp in global.composters)
		var/composter_record = Comp.continuity_write()

		if(!composters_saves[Comp.save_id])
			composters_saves[Comp.save_id] = list(composter_record)
		else
			composters_saves[Comp.save_id] += composter_record

	for(var/save_id in composters_saves)
		composters_saves[save_id] = list2params(composters_saves[save_id])

	S["Composters_Save"] << list2params(composters_saves)
