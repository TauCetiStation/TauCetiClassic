/**********************Mining exotic furnace**************************/
/obj/machinery/exotic_furnace
	name = "exotic furnace"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "exotic_off"
	density = 1
	anchored = 1

	var/min_temperature = 20
	var/max_temperature = 4000
	var/current_temperature = 20

	var/potential_heat = 0

	var/loaded_silver = 0
	var/loaded_gold = 0
	var/loaded_uranium = 0
	var/loaded_metal = 0
	var/loaded_diamond = 0
	var/loaded_hivelord_core = 0
	var/loaded_goliath_plate = 0

	var/melted_silver = 0
	var/melted_gold = 0
	var/melted_uranium = 0
	var/melted_metal = 0
	var/melted_diamond = 0
	var/melted_hivelord_core = 0
	var/melted_goliath_plate = 0

	#define hivelord_core_melting_temperature	237
	#define silver_melting_temperature			962
	#define gold_melting_temperature			1064
	#define uranium_melting_temperature			1132
	#define metal_melting_temperature			1300
	#define goliath_plate_melting_temperature	2400
	#define diamond_melting_temperature			3700

/obj/machinery/exotic_furnace/attackby(O, mob/user)
	var/obj/item/stack/sheet/M = O

	if(istype(M, /obj/item/stack/sheet/mineral/phoron))
		potential_heat += 200 * M.get_amount() // 1 phoron sheet = +200°C potential temperature
		playsound(user, 'sound/items/exc_furnace_in.ogg', VOL_EFFECTS_MASTER)
		qdel(M)

	if(istype(M, /obj/item/stack/sheet/mineral/silver))
		loaded_silver += 1000 * M.get_amount()
		playsound(user, 'sound/items/exc_furnace_in.ogg', VOL_EFFECTS_MASTER)
		qdel(M)

	if(istype(M, /obj/item/stack/sheet/mineral/gold))
		loaded_gold += 1000 * M.get_amount()
		playsound(user, 'sound/items/exc_furnace_in.ogg', VOL_EFFECTS_MASTER)
		qdel(M)

	if(istype(M, /obj/item/stack/sheet/mineral/uranium))
		loaded_uranium += 1000 * M.get_amount()
		playsound(user, 'sound/items/exc_furnace_in.ogg', VOL_EFFECTS_MASTER)
		qdel(M)

	if(istype(M, /obj/item/stack/sheet/metal))
		loaded_metal += 1000 * M.get_amount()
		playsound(user, 'sound/items/exc_furnace_in.ogg', VOL_EFFECTS_MASTER)
		qdel(M)

	if(istype(M, /obj/item/stack/sheet/mineral/diamond))
		loaded_diamond += 1000 * M.get_amount()
		playsound(user, 'sound/items/exc_furnace_in.ogg', VOL_EFFECTS_MASTER)
		qdel(M)

	if(istype(M, /obj/item/asteroid/goliath_hide))
		loaded_goliath_plate += 1000
		playsound(user, 'sound/items/exc_furnace_in.ogg', VOL_EFFECTS_MASTER)
		qdel(M)

	if(istype(M, /obj/item/asteroid/hivelord_core))
		loaded_hivelord_core += 1000
		playsound(user, 'sound/items/exc_furnace_in.ogg', VOL_EFFECTS_MASTER)
		qdel(M)


/obj/machinery/exotic_furnace/get_current_temperature()
	return current_temperature

/obj/machinery/exotic_furnace/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/machinery/exotic_furnace/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/machinery/exotic_furnace/process()

	if((potential_heat) && (current_temperature < max_temperature))
		current_temperature += 20
		potential_heat -= 20
		icon_state = "exotic_on"

	else if(current_temperature > min_temperature)
		current_temperature -= 2 // heat loss due to downtime.
		icon_state = "exotic_off"

	if((loaded_silver) && (current_temperature > silver_melting_temperature))
		melted_silver += 200
		loaded_silver -= 200

	if((loaded_gold) && (current_temperature > gold_melting_temperature))
		melted_gold += 200
		loaded_gold -= 200

	if((loaded_uranium) && (current_temperature > uranium_melting_temperature))
		melted_uranium += 200
		loaded_uranium -= 200

	if((loaded_metal) && (current_temperature > metal_melting_temperature))
		melted_metal += 200
		loaded_metal -= 200

	if((loaded_diamond) && (current_temperature > diamond_melting_temperature))
		melted_diamond += 200
		loaded_diamond -= 200

	if((loaded_hivelord_core) && (current_temperature > hivelord_core_melting_temperature))
		melted_hivelord_core += 200
		loaded_hivelord_core -= 200

	if((loaded_goliath_plate) && (current_temperature > goliath_plate_melting_temperature))
		melted_goliath_plate += 200
		loaded_goliath_plate -= 200

/obj/machinery/exotic_furnace/ui_interact(mob/user)
	var/dat

	dat += "<hr><table>"

	dat += "<h3>Melting temperature:</h3>"
	dat += "<div class='statusDisplay'>"
	dat += "Hivelord core: [hivelord_core_melting_temperature]°C<BR>"
	dat += "Silver:        [silver_melting_temperature]°C<BR>"
	dat += "Gold:          [gold_melting_temperature]°C<BR>"
	dat += "Uranium:       [uranium_melting_temperature]°C<BR>"
	dat += "Metal:         [metal_melting_temperature]°C<BR>"
	dat += "Goliath plate: [goliath_plate_melting_temperature]°C<BR>"
	dat += "Diamond:       [diamond_melting_temperature]°C<BR>"
	dat += "</div>"

	dat += "Current temperature:<font color='yellow'> [current_temperature]°C</font><BR>"

	dat += "</table><hr>"


	dat += "<hr><table>"

	dat += "<h3>Current material:</h3>"
	dat += "<div class='statusDisplay'>"
	dat += "Melted silver:        <font color='green'>[melted_silver]</font> / Loaded silver:               <font color='red'>[loaded_silver]</font><BR>"
	dat += "Melted gold:          <font color='green'>[melted_gold]</font> / Loaded gold:                   <font color='red'>[loaded_gold]</font><BR>"
	dat += "Melted uranium:       <font color='green'>[melted_uranium]</font> / Loaded uranium:             <font color='red'>[loaded_uranium]</font><BR>"
	dat += "Melted metal:         <font color='green'>[melted_metal]</font> / Loaded metal:                 <font color='red'>[loaded_metal]</font><BR>"
	dat += "Melted diamond:       <font color='green'>[melted_diamond]</font> / Loaded diamond:             <font color='red'>[loaded_diamond]</font><BR>"
	dat += "Melted hivelord core: <font color='green'>[melted_hivelord_core]</font> / Loaded hivelord core: <font color='red'>[loaded_hivelord_core]</font><BR>"
	dat += "Melted goliath plate: <font color='green'>[melted_goliath_plate]</font> / Loaded goliath plate: <font color='red'>[loaded_goliath_plate]</font><BR>"
	dat += "</div>"

	dat += "Sledgehammer: <A href='?src=\ref[src];item=sledgehammer'>Make</A><BR>"
	dat += "Cost: 2000 melted gold, 3000 melted silver, 4000 melted goliath plate.<BR>"


	var/datum/browser/popup = new(user, "window=exotic_furnace", "Mining exotic furnace", 400, 600)
	popup.set_content(dat)
	popup.open()


/obj/machinery/exotic_furnace/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	create_product(href_list["item"])

/obj/machinery/exotic_furnace/proc/create_product(item)
	switch(item)
		if("sledgehammer")
			if(melted_silver >= 3000 && melted_gold >= 2000 && melted_goliath_plate >= 4000)
				melted_silver -= 3000
				melted_gold -= 2000
				melted_goliath_plate -= 4000
				new /obj/item/weapon/twohanded/sledgehammer(src.loc)
				playsound(src, 'sound/items/exc_furnace_drop.ogg', VOL_EFFECTS_MASTER)






#undef silver_melting_temperature
#undef gold_melting_temperature
#undef uranium_melting_temperature
#undef metal_melting_temperature
#undef diamond_melting_temperature