/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit. The workhorse of the exosuit world."
	name = "APLU \"Ripley\""
	icon_state = "ripley"
	initial_icon = "ripley"
	step_in = 6
	max_temperature = 20000
	health = 200
	wreckage = /obj/effect/decal/mecha_wreckage/ripley
	var/list/cargo = new
	var/cargo_capacity = 15
	var/hides = 0

/obj/mecha/working/ripley/go_out()
	..()
	update_icon()

/obj/mecha/working/ripley/moved_inside(mob/living/carbon/human/H)
	..()
	update_icon()

/obj/mecha/working/ripley/mmi_moved_inside(obj/item/device/mmi/mmi_as_oc,mob/user)
	..()
	update_icon()

/obj/mecha/working/ripley/update_icon()
	..()
	if(hides)
		cut_overlays()
		if(hides < 3)
			add_overlay(image("icon" = "mecha.dmi", "icon_state" = occupant ? "ripley-g" : "ripley-g-open"))
		else
			add_overlay(image("icon" = "mecha.dmi", "icon_state" = occupant ? "ripley-g-full" : "ripley-g-full-open"))

/obj/mecha/working/ripley/firefighter
	desc = "Standart APLU chassis was refitted with additional thermal protection and cistern."
	name = "APLU \"Firefighter\""
	icon_state = "firefighter"
	initial_icon = "firefighter"
	max_temperature = 65000
	health = 250
	lights_power = 8
	damage_absorption = list("fire"=0.5,"bullet"=0.8,"bomb"=0.5)
	wreckage = /obj/effect/decal/mecha_wreckage/ripley/firefighter

/obj/mecha/working/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE!!!"
	name = "DEATH-RIPLEY"
	icon_state = "deathripley"
	initial_icon = "deathripley"
	step_in = 2
	opacity=0
	wreckage = /obj/effect/decal/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0

/obj/mecha/working/ripley/deathripley/atom_init()
	. = ..()
	if(!istype(src,/obj/mecha/working/ripley/deathripley/pirate))
		var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/tool/safety_clamp
		ME.attach(src)

/obj/mecha/working/ripley/deathripley/pirate
	name = "LOOT-RIPLEY"
	desc = "OH SHIT IT'S THE LOOTERS WE'RE ALL GONNA DIE!!!"
	step_in = 5
	step_energy_drain = 10
	health = 750
	deflect_chance = 0
	damage_absorption = list("brute"=1,"fire"=1,"bullet"=1,"laser"=1,"energy"=1,"bomb"=1)
	add_req_access = 0
	maint_access = 0
	operation_req_access = list(access_syndicate)
	internals_req_access = list(access_syndicate)
	wreckage = /obj/effect/decal/mecha_wreckage/ripley/deathripley
	max_equip = 2

/obj/mecha/working/ripley/deathripley/pirate/atom_init()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tool/drill(src)
	ME.attach(src)

/obj/mecha/working/ripley/mining
	desc = "An old, dusty mining ripley."
	name = "APLU \"Miner\""

/obj/mecha/working/ripley/mining/atom_init()
	..()
	//Attach drill
	if(prob(25)) //Possible diamond drill... Feeling lucky?
		var/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill/D = new /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
		D.attach(src)
	else
		var/obj/item/mecha_parts/mecha_equipment/tool/drill/D = new /obj/item/mecha_parts/mecha_equipment/tool/drill
		D.attach(src)

	//Attach hydrolic clamp
	var/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/HC = new /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	HC.attach(src)

	return INITIALIZE_HINT_LATELOAD

/obj/mecha/working/ripley/mining/atom_init_late()
	for(var/obj/item/mecha_parts/mecha_tracking/B in contents)//Deletes the beacon so it can't be found easily
		qdel(B)

/obj/mecha/working/ripley/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/working/ripley/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"])
		if(O && (O in src.cargo))
			src.occupant_message("<span class='notice'>You unload [O].</span>")
			O.loc = get_turf(src)
			src.cargo -= O
			var/turf/T = get_turf(O)
			if(T)
				T.Entered(O)
			src.log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - src.cargo.len]")
	return



/obj/mecha/working/ripley/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(src.cargo.len)
		for(var/obj/O in src.cargo)
			output += "<a href='?src=\ref[src];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/working/ripley/proc/drop_cargo()
	for(var/atom/movable/A in cargo)
		A.forceMove(get_turf(src))
		step_rand(A)

/obj/mecha/working/ripley/destroy()
	drop_cargo()
	..()


/obj/mecha/working/ripley/Destroy()
	drop_cargo()
	return ..()
