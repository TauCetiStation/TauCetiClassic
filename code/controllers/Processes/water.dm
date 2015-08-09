/datum/controller/process/water/setup()
	name = "water"
	schedule_interval = 10

/datum/controller/process/water/doWork()
	var/i = 0
	var/list/tmp_processing_water = processing_water.Copy()
	while(tmp_processing_water.len && i <= 1000)
		i++
		var/obj/effect/decal/cleanable/water/W = pick(tmp_processing_water)
		tmp_processing_water -= W
		W.check_flamable()
		W.spread_and_eat()
		W.update_icon()
		scheck()
	processing_water |= tmp_processing_water

	var/list/tmp_processing_drying = processing_drying.Copy()
	while(tmp_processing_drying.len)
		var/obj/item/I = pick(tmp_processing_drying)
		tmp_processing_drying -= I
		I.dry_process()
		scheck()
	processing_drying |= tmp_processing_drying

/datum/controller/process/water/getStatName()
	return ..()+"(W[processing_water.len]/D[processing_drying.len])"
