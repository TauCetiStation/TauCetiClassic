#define ENERGY_USE_WITH_THRUSTERS 30

/obj/mecha/combat/marauder
	desc = "Heavy-duty, combat exosuit, developed after the Durand model. Rarely found among civilian populations."
	name = "Marauder"
	icon_state = "marauder"
	initial_icon = "marauder"
	step_in = 5
	health = 500
	deflect_chance = 25
	damage_absorption = list(BRUTE=0.5,BURN=0.7,BULLET=0.45,LASER=0.6,ENERGY=0.7,BOMB=0.7)
	max_temperature = 60000
	infra_luminosity = 3
	var/zoom_mode = FALSE
	var/smoke = 5
	var/smoke_ready = 1
	var/smoke_cooldown = 100
	var/datum/effect/effect/system/smoke_spread/smoke_system = new
	var/datum/action/innate/mecha/mech_smoke/smoke_action = new
	var/datum/action/innate/mecha/mech_zoom/zoom_action = new
	operation_req_access = list(access_cent_specops)
	wreckage = /obj/effect/decal/mecha_wreckage/marauder
	add_req_access = 0
	internal_damage_threshold = 25
	force = 45
	max_equip = 4
	var/thrusters_active = FALSE
	var/datum/action/innate/mecha/mech_toggle_thrusters/thrusters_action = new

/obj/mecha/combat/marauder/atom_init()
	. = ..()
	AddComponent(/datum/component/examine_research, DEFAULT_SCIENCE_CONSOLE_ID, 8000, list(DIAGNOSTIC_EXTRA_CHECK, VIEW_EXTRA_CHECK))

/obj/mecha/combat/marauder/Destroy()
	QDEL_NULL(smoke_system)
	QDEL_NULL(smoke_action)
	QDEL_NULL(zoom_action)
	QDEL_NULL(thrusters_action)
	return ..()

/obj/mecha/combat/marauder/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(.)
		return 1
	if(thrusters_active && movement_dir && use_power(ENERGY_USE_WITH_THRUSTERS))
		return 1

/obj/mecha/combat/marauder/GrantActions(mob/living/user, human_occupant = 0)
	..()
	smoke_action.Grant(user, src)
	zoom_action.Grant(user, src)
	thrusters_action.Grant(user, src)

/obj/mecha/combat/marauder/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	smoke_action.Remove(user)
	zoom_action.Remove(user)
	thrusters_action.Remove(user)

/obj/mecha/combat/marauder/seraph
	desc = "Heavy-duty, command-type exosuit. This is a custom model, utilized only by high-ranking military personnel."
	name = "Seraph"
	icon_state = "seraph"
	initial_icon = "seraph"
	operation_req_access = list(access_cent_creed)
	step_in = 3
	health = 550
	wreckage = /obj/effect/decal/mecha_wreckage/seraph
	internal_damage_threshold = 20
	force = 55
	max_equip = 5

/obj/mecha/combat/marauder/mauler
	desc = "Heavy-duty, combat exosuit, developed off of the existing Marauder model."
	name = "Mauler"
	icon_state = "mauler"
	initial_icon = "mauler"
	operation_req_access = list(access_syndicate)
	wreckage = /obj/effect/decal/mecha_wreckage/mauler

/obj/mecha/combat/marauder/mauler/atom_init()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/explosive(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster(src)
	ME.attach(src)
	smoke_system.set_up(3, 0, src)
	smoke_system.attach(src)

/obj/mecha/combat/marauder/loaded/atom_init()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/explosive(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster(src)
	ME.attach(src)
	smoke_system.set_up(3, 0, src)
	smoke_system.attach(src)

/obj/mecha/combat/marauder/seraph/atom_init()
	..()//Let it equip whatever is needed.
	return INITIALIZE_HINT_LATELOAD

/obj/mecha/combat/marauder/seraph/atom_init_late() // because of qdel() ...
	// actually, mech equipment should be made as closets with their PopulateContents proc ...
	// or any other idea. so we dont need to clean parent's equipment
	var/obj/item/mecha_parts/mecha_equipment/ME
	if(equipment.len)//Now to remove it and equip anew.
		for(ME in equipment)
			equipment -= ME
			qdel(ME)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/explosive(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster(src)
	ME.attach(src)

/obj/mecha/combat/marauder/relaymove(mob/user,direction)
	if(zoom_mode)
		if(world.time - last_message > 20)
			occupant_message("Unable to move while in zoom mode.")
			last_message = world.time
		return 0
	return ..()

/obj/mecha/combat/marauder/proc/toggle_thrusters()
	if(usr != src.occupant)
		return
	if(src.occupant)
		if(get_charge() > 0)
			if(!check_fumbling("<span class='notice'>You fumble around, figuring out how to [!thrusters_active? "en" : "dis"]able thrusters.</span>"))
				return
			thrusters_active = !thrusters_active
			log_message("Toggled thrusters.")
			occupant_message("<font color='[src.thrusters_active? "blue" : "red"]'>Thrusters [thrusters_active? "en" : "dis"]abled.</font>")
	return

/obj/mecha/combat/marauder/proc/smoke()
	if(usr != src.occupant)
		return
	if(smoke_ready && smoke>0)
		if(!check_fumbling("<span class='notice'>You fumble around, figuring out how to use smoke system.</span>"))
			return
		smoke_system.start()
		smoke--
		smoke_ready = 0
		spawn(smoke_cooldown)
			smoke_ready = 1
	return

/obj/mecha/combat/marauder/proc/zoom()
	if(usr != src.occupant)
		return
	if(src.occupant.client)
		if(!check_fumbling("<span class='notice'>You fumble around, figuring out how to [!zoom_mode?"en":"dis"]able zoom mode.</span>"))
			return
		src.zoom_mode = !src.zoom_mode
		log_message("Toggled zoom mode.")
		occupant_message("<font color='[src.zoom_mode?"blue":"red"]'>Zoom mode [zoom_mode?"en":"dis"]abled.</font>")
		if(zoom_mode)
			occupant.client.change_view(12)
			occupant.playsound_local(null, 'sound/mecha/imag_enh.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		else
			occupant.client.change_view(world.view)
	return


/obj/mecha/combat/marauder/go_out()
	if(src.occupant && src.occupant.client)
		occupant.client.change_view(world.view)
		src.zoom_mode = FALSE
	..()
	return


/obj/mecha/combat/marauder/get_stats_part()
	var/output = ..()
	output += {"<b>Thrusters: </b>[thrusters_active? "on" : "off"]<br>"}
	output += {"<b>Smoke:</b> [smoke]"}
	return output


/obj/mecha/combat/marauder/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Special</div>
						<div class='links'>
						<a href='?src=\ref[src];toggle_thrusters=1'>Toggle Thrusters</a><br>
						<a href='?src=\ref[src];toggle_zoom=1'>Toggle zoom mode</a><br>
						<a href='?src=\ref[src];smoke=1'>Smoke</a>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/mecha/combat/marauder/Topic(href, href_list)
	..()
	if(href_list["smoke"])
		smoke()
	if(href_list["toggle_zoom"])
		zoom()
	if(href_list["toggle_thrusters"])
		toggle_thrusters()
	return

#undef ENERGY_USE_WITH_THRUSTERS
