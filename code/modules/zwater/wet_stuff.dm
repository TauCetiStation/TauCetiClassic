//NextGen mechanic to make items wet
/obj/item/var/dry_inprocess = 0

/obj/item/proc/make_wet(shower = 0)
	if(!src) return
	if(src.flags & THICKMATERIAL) return

	if(shower)
		if(blood_DNA)
			if(blood_DNA.len)
				var/turf/T = get_turf(src)
				if(!istype(T, /turf/space))
					var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
					if(!W)
						W = PoolOrNew(/obj/effect/decal/cleanable/water,T)
					if(!W.blood_DNA)
						W.blood_DNA = list()
					W.blood_DNA |= blood_DNA.Copy()
					W.blood_color = blood_color
					animate(W, color = blood_color, time = 10)

	var/wet_weight = rand(18,28)
	if(wet)
		if(wet > wet_weight)
			return
		wet = wet_weight
		return
	else
		wet = wet_weight
		SSobj.drying |= src

/obj/item/Destroy()
	SSobj.drying -= src
	return ..()

/obj/item/proc/dry_process()
	if(!src) return

	if(wet < 1)
		SSobj.drying -= src
		return

	if(dry_inprocess < 1)
		dry_inprocess = rand(4,8)
		wet--
		if(prob(15))
			var/turf/T = get_turf(src)
			if(!istype(T, /turf/space))
				var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
				if(!W)
					W = PoolOrNew(/obj/effect/decal/cleanable/water,T)
				else
					W.depth = min(2, W.depth + rand(2,5)/10)
				if(blood_DNA)
					if(blood_DNA.len)
						if(!W.blood_DNA)
							W.blood_DNA = list()
						W.blood_DNA |= blood_DNA.Copy()
						W.blood_color = blood_color
						animate(W, color = blood_color, time = 10)
		if(prob(20))
			dry_discharge()
	else
		dry_inprocess--

/obj/item/proc/dry_discharge()
	var/item_to_discharge = 0
	if(istype(src, /obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = src
		if(G.cell)
			if(G.cell.charge)
				G.cell.charge = 0
				item_to_discharge = 1
				G.update_icon()
	else if(istype(src, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = src
		if(B.status)
			if(B.charges)
				B.charges = 0
				B.status = 0
				B.update_icon()
				item_to_discharge = 1
	else if(istype(src, /obj/item/weapon/melee/cattleprod))
		var/obj/item/weapon/melee/cattleprod/CP = src
		if(CP.status)
			if(CP.bcell.charge)
				CP.bcell.charge = 0
				CP.update_icon()
				item_to_discharge = 1
	if(item_to_discharge)
		var/turf/T = get_turf(src)
		T.visible_message("<span class='wet'>Some wet device has been discharged!</span>")
		var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
		if(W)
			W.electrocute_act(120)
		else if(istype(loc, /mob/living))
			var/mob/living/L = loc
			L.apply_effect(120,AGONY,0)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
