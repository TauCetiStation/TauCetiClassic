#define MECHA_INT_FIRE 1
#define MECHA_INT_TEMP_CONTROL 2
#define MECHA_INT_SHORT_CIRCUIT 4
#define MECHA_INT_TANK_BREACH 8
#define MECHA_INT_CONTROL_LOST 16

#define MECHA_TIME_TO_ENTER 4 SECOND
#define TIME_TO_RECALIBRATION 10 SECOND

#define RANGE_MELEE 1
#define RANGED 2


/obj/mecha
	name = "Mecha"
	desc = "Exosuit."
	icon = 'icons/mecha/mecha.dmi'
	flags = HEAR_TALK
	density = TRUE //Dense. To raise the heat.
	opacity = 1 ///opaque. Menacing.
	anchored = TRUE //no pulling around.
	unacidable = 1 //and no deleting hoomans inside
	layer = MOB_LAYER //icon draw layer
	infra_luminosity = 15 //byond implementation is bugged.
	hud_possible = list(DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD)
	w_class = SIZE_MASSIVE
	var/initial_icon = null //Mech type for resetting icon. Only used for reskinning kits (see custom items)
	var/can_move = 1
	var/mob/living/carbon/occupant = null
	var/step_in = 10 //make a step in step_in/10 sec.
	var/dir_in = 2//What direction will the mech face when entered/powered on? Defaults to South.
	var/step_energy_drain = 10
	var/health = 300 //health is health
	var/maxhealth = 300
	var/deflect_chance = 10 //chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	//the values in this list show how much damage will pass through, not how much will be absorbed.
	var/list/damage_absorption = list(BRUTE=0.8,BURN=1.2,BULLET=0.9,LASER=1,ENERGY=1,BOMB=1)
	var/obj/item/weapon/stock_parts/cell/cell
	var/state = 0
	var/list/log = new
	var/last_message = 0
	var/add_req_access = 1
	var/maint_access = 1
	var/dna	//dna-locking the mech
	var/list/proc_res = list() //stores proc owners, like proc_res["functionname"] = owner reference
	var/datum/effect/effect/system/spark_spread/spark_system = new
	var/lights = 0
	var/lights_power = 6
	var/last_user_hud = 1 // used to show/hide the mecha hud while preserving previous preference

	//inner atmos
	var/use_internal_tank = 0
	var/internal_tank_valve = ONE_ATMOSPHERE
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port = null

	var/obj/item/device/radio/radio = null

	var/max_temperature = 25000
	var/internal_damage_threshold = 50 //health percentage below which internal damage is possible
	var/internal_damage = 0 //contains bitflags

	var/list/operation_req_access = list()//required access level for mecha operation
	var/list/internals_req_access = list(access_engine,access_robotics)//required access level to open cell compartment

	var/wreckage

	var/list/equipment = new
	var/obj/item/mecha_parts/mecha_equipment/selected
	var/max_equip = 3
	var/datum/events/events

	//Action datums
	var/datum/action/innate/mecha/mech_eject/eject_action = new
	var/datum/action/innate/mecha/mech_toggle_internals/internals_action = new
	var/datum/action/innate/mecha/mech_cycle_equip/cycle_action = new
	var/datum/action/innate/mecha/mech_toggle_lights/lights_action = new
	var/datum/action/innate/mecha/mech_view_stats/stats_action = new
	var/datum/action/innate/mecha/strafe/strafing_action = new

	//Action var
	var/strafe = FALSE

	var/prev_move_dir = 0

	var/nextsmash = 0
	var/smashcooldown = 3	//deciseconds

	var/occupant_sight_flags = 0 //sight flags to give to the occupant (e.g. mech mining scanner gives meson-like vision)
	var/mouse_pointer

	hud_possible = list(DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD)
	var/list/speed_skills = list(/datum/skill/civ_mech = SKILL_LEVEL_TRAINED)
	var/list/interface_skills = list(/datum/skill/civ_mech = SKILL_LEVEL_TRAINED)

/obj/mecha/atom_init()
	. = ..()
	events = new
	icon_state += "-open"
	add_radio()
	add_cabin()
	add_airtank()
	spark_system.set_up(2, 0, src)
	spark_system.attach(src)
	add_cell()
	START_PROCESSING(SSobj, src)
	log_message("[src.name] created.")
	loc.Entered(src)
	mechas_list += src //global mech list
	maxhealth = health
	prepare_huds()
	var/datum/atom_hud/data/diagnostic/diag_hud = global.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_to_hud(src)
	diag_hud_set_mechhealth()
	diag_hud_set_mechcell()
	diag_hud_set_mechstat()

/obj/mecha/Destroy()
	go_out()
	for(var/mob/M in src)
		M.loc = get_turf(src)
		M.loc.Entered(M)
		step_rand(M)
	STOP_PROCESSING(SSobj, src)

	QDEL_NULL(eject_action)
	QDEL_NULL(internals_action)
	QDEL_NULL(cycle_action)
	QDEL_NULL(lights_action)
	QDEL_NULL(stats_action)
	QDEL_NULL(strafing_action)
	mechas_list -= src //global mech list
	return ..()

////////////////////////
////// Helpers /////////
////////////////////////

/obj/mecha/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

/obj/mecha/proc/add_cell(obj/item/weapon/stock_parts/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.name = "high-capacity power cell"
	cell.charge = 15000
	cell.maxcharge = 15000

/obj/mecha/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.adjust_multi("oxygen", O2STANDARD * cabin_air.volume / (R_IDEAL_GAS_EQUATION * cabin_air.temperature), "nitrogen", N2STANDARD * cabin_air.volume / (R_IDEAL_GAS_EQUATION * cabin_air.temperature))
	return cabin_air

/obj/mecha/proc/add_radio()
	radio = new(src)
	radio.name = "[src] radio"
	radio.icon = icon
	radio.icon_state = icon_state


/obj/mecha/proc/enter_after(delay, mob/user, numticks = 5)
	var/delayfraction = delay/numticks

	var/turf/T = user.loc

	for(var/i = 0, i<numticks, i++)
		sleep(delayfraction)
		if(!src || !user || !user.canmove || !(user.loc == T))
			return 0

	return 1

/obj/mecha/examine(mob/user)
	..()
	var/integrity = health/initial(health)*100
	switch(integrity)
		if(85 to 100)
			to_chat(user, "It's fully intact.")
		if(65 to 85)
			to_chat(user, "It's slightly damaged.")
		if(45 to 65)
			to_chat(user, "It's badly damaged.")
		if(25 to 45)
			to_chat(user, "It's heavily damaged.")
		else
			to_chat(user, "It's falling apart.")
	if(equipment && equipment.len)
		to_chat(user, "It's equipped with:")
		for(var/obj/item/mecha_parts/mecha_equipment/ME in equipment)
			to_chat(user, "[bicon(ME)] [ME]")

/obj/mecha/proc/drop_item()//Derpfix, but may be useful in future for engineering exosuits.
	return

/obj/mecha/hear_talk(mob/M, text)
	if(M==occupant && radio.broadcasting)
		radio.talk_into(M, text)
	return

/obj/mecha/proc/click_action(atom/target,mob/user)
	if(!src.occupant || src.occupant != user ) return
	if(user.stat != CONSCIOUS) return
	if(state)
		occupant_message("<font color='red'>Maintenance protocols in effect</font>")
		return
	if(!get_charge()) return
	if(src == target) return
	var/dir_to_target = get_dir(src,target)
	if(dir_to_target && !(dir_to_target & src.dir))//wrong direction
		return
	if(hasInternalDamage(MECHA_INT_CONTROL_LOST))
		target = safepick(view(3,target))
		if(!target)
			return
	if(!target.Adjacent(src))
		if(selected && selected.is_ranged())
			selected.action(target)
	else if(selected && selected.is_melee())
		selected.action(target)
	else
		melee_action(target)
	return


/obj/mecha/proc/melee_action(atom/target)
	return

/obj/mecha/proc/range_action(atom/target)
	return


//////////////////////////////////
////////  Movement procs  ////////
//////////////////////////////////

/obj/mecha/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()

	if(moving_diagonally)
		return .

	if(.)
		events.fireEvent("onMove",get_turf(src))

/obj/mecha/Process_Spacemove(movement_dir = 0)
	if(occupant)
		return occupant.Process_Spacemove(movement_dir) //We'll just say you used the clamp to grab the wall
	return ..()

/obj/mecha/relaymove(mob/user,direction)
	if(user != src.occupant) //While not "realistic", this piece is player friendly.
		user.forceMove(get_turf(src))
		to_chat(user, "You climb out from [src]")
		return 0
	if(connected_port)
		if(world.time - last_message > 20)
			occupant_message("Unable to move while connected to the air system port")
			last_message = world.time
		return 0
	if(state)
		occupant_message("<font color='red'>Maintenance protocols in effect</font>")
		return
	return domove(direction)

/obj/mecha/proc/domove(direction)
	return call((proc_res["dyndomove"]||src), "dyndomove")(direction)

/obj/mecha/proc/dyndomove(direction)
	if(!can_move)
		return 0
	if(!Process_Spacemove(direction))
		return 0
	if(!has_charge(step_energy_drain))
		return 0
	var/move_result = 0
	if(hasInternalDamage(MECHA_INT_CONTROL_LOST))
		move_result = mechsteprand()
	else if(strafe)
		move_result	= mechstep(direction)
	else if(direction == dir || direction == prev_move_dir)
		move_result = mechstep(dir)
	else if(ISDIAGONALDIR(direction))
		if(dir & NORTH_SOUTH)
			move_result = mechturn(direction & EAST_WEST)
		else
			move_result = mechturn(direction & NORTH_SOUTH)
	else
		move_result = mechturn(direction)
	prev_move_dir = direction
	if(move_result)
		can_move = 0
		VARSET_IN(src, can_move, TRUE, apply_skill_bonus(occupant, step_in, speed_skills, -0.2) * move_result) // -20% to step_in for each level
		return 1
	return 0

/obj/mecha/proc/check_fumbling(fumble_text)
	return handle_fumbling(occupant, occupant, SKILL_TASK_VERY_EASY, interface_skills, fumble_text, can_move = TRUE, check_busy = FALSE)

/obj/mecha/proc/mechturn(direction)
	set_dir(direction)
	use_power(step_energy_drain)
	playsound(src, 'sound/mecha/Mech_Rotation.ogg', VOL_EFFECTS_MASTER, 40)
	return 1

/obj/mecha/proc/mechstep(direction)
	var/old_loc = loc
	var/current_dir = dir
	var/result = step(src, direction)
	if(strafe)
		set_dir(current_dir)
	if(result)
		playsound(src, 'sound/mecha/Mech_Step.ogg', VOL_EFFECTS_MASTER, 40)
		use_power(step_energy_drain)
		direction = get_dir(src, old_loc)
		if(ISDIAGONALDIR(direction))
			return 2
	return result

/obj/mecha/proc/mechsteprand()
	var/result = step_rand(src)
	if(result)
		playsound(src, 'sound/mecha/Mech_Step.ogg', VOL_EFFECTS_MASTER, 40)
		use_power(step_energy_drain)
	return result

/obj/mecha/Bump(atom/obstacle, non_native_bump)
	if(non_native_bump)
		if(throwing)
			..()
			return
		if(istype(obstacle, /obj/machinery/disposal/deliveryChute))
			return
		obstacle.Bumped(src)
		if(istype(obstacle, /obj))
			var/obj/O = obstacle
			if(!O.anchored)
				step(obstacle, dir)
		else if(istype(obstacle, /mob))
			step(obstacle, dir)

///////////////////////////////////
////////  Internal damage  ////////
///////////////////////////////////

/obj/mecha/proc/check_for_internal_damage(list/possible_int_damage,ignore_threshold=null)
	if(!islist(possible_int_damage) || isemptylist(possible_int_damage))
		return
	if(prob(20))
		if(ignore_threshold || src.health*100/initial(src.health)<src.internal_damage_threshold)
			for(var/T in possible_int_damage)
				if(internal_damage & T)
					possible_int_damage -= T
			var/int_dam_flag = safepick(possible_int_damage)
			if(int_dam_flag)
				setInternalDamage(int_dam_flag)
	if(prob(5))
		if(ignore_threshold || src.health*100/initial(src.health)<src.internal_damage_threshold)
			var/obj/item/mecha_parts/mecha_equipment/destr = safepick(equipment)
			if(destr)
				qdel(destr)
	return

/obj/mecha/proc/hasInternalDamage(int_dam_flag=null)
	return int_dam_flag ? internal_damage&int_dam_flag : internal_damage


/obj/mecha/proc/setInternalDamage(int_dam_flag)
	internal_damage |= int_dam_flag
	log_append_to_last("Internal damage of type [int_dam_flag].",1)
	if(occupant)
		occupant.playsound_local(null, 'sound/machines/warning-buzzer.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	diag_hud_set_mechstat()
	return

/obj/mecha/proc/clearInternalDamage(int_dam_flag)
	if(internal_damage & int_dam_flag)
		switch(int_dam_flag)
			if(MECHA_INT_TEMP_CONTROL)
				occupant_message("<span class='boldnotice'>Life support system reactivated.</span>")
			if(MECHA_INT_FIRE)
				occupant_message("<span class='boldnotice'>Internal fire extinquished.</span>")
			if(MECHA_INT_TANK_BREACH)
				occupant_message("<span class='boldnotice'>Damaged internal tank has been sealed.</span>")
	internal_damage &= ~int_dam_flag

	diag_hud_set_mechstat()
	return


////////////////////////////////////////
////////  Health related procs  ////////
////////////////////////////////////////

/obj/mecha/take_damage(amount, type=BRUTE) // TODO port tg mechs
	if(amount)
		var/damage = absorbDamage(amount,type)
		health -= damage
		update_health()
		log_append_to_last("Took [damage] points of damage. Damage type: \"[type]\".",1)
	return

/obj/mecha/proc/absorbDamage(damage,damage_type)
	return call((proc_res["dynabsorbdamage"]||src), "dynabsorbdamage")(damage,damage_type)

/obj/mecha/proc/dynabsorbdamage(damage,damage_type)
	return damage*(listgetindex(damage_absorption,damage_type) || 1)


/obj/mecha/proc/update_health()
	if(src.health > 0)
		spark_system.start()
		diag_hud_set_mechhealth()
	else
		destroy()
	return

/obj/mecha/attack_hand(mob/user)
	log_message("Attack by hand/paw. Attacker - [user].",1)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)

	if ((HULK in user.mutations) && !prob(src.deflect_chance))
		take_damage(15)
		check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		user.visible_message("<font color='red'><b>[user] hits [src.name], doing some damage.</b></font>", "<font color='red'><b>You hit [src.name] with all your might. The metal creaks and bends.</b></font>")
	else
		user.visible_message("<font color='red'><b>[user] hits [src.name]. Nothing happens</b></font>","<font color='red'><b>You hit [src.name] with no visible effect.</b></font>")
		log_append_to_last("Armor saved.")
	return

/obj/mecha/attack_paw(mob/user)
	return attack_hand(user)

/obj/mecha/proc/toggle_strafe()
	if(!check_fumbling("<span class='notice'>You fumble around, figuring out how to toggle strafing mode [!strafe?"on":"off"].</span>"))
		return
	strafe = !strafe
	prev_move_dir = 0

	occupant_message("<span class='notice'>Toggled strafing mode [strafe?"on":"off"].</span>")
	log_message("Toggled strafing mode [strafe?"on":"off"].")


/obj/mecha/attack_alien(mob/user)
	log_message("Attack by alien. Attacker - [user].",1)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	if(!prob(src.deflect_chance))
		take_damage(40)
		check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		playsound(src, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='warning'>You slash at the armored suit!</span>")
		visible_message("<span class='warning'>The [user] slashes at [src.name]'s armor!</span>")
	else
		log_append_to_last("Armor saved.")
		playsound(src, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>Your claws had no effect!</span>")
		occupant_message("<span class='notice'>The [user]'s claws are stopped by the armor.</span>")
		visible_message("<span class='notice'>The [user] rebounds off [src.name]'s armor!</span>")
	return


/obj/mecha/attack_animal(mob/living/simple_animal/attacker)
	log_message("Attack by simple animal. Attacker - [attacker].",1)
	..()

	if(attacker.melee_damage == 0)
		attacker.me_emote("[attacker.friendly] [src]")
	else
		if(!prob(src.deflect_chance))
			var/damage = attacker.melee_damage
			take_damage(damage)
			check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
			visible_message("<span class='warning'><B>[attacker]</B> [attacker.attacktext] [src]!</span>")
			attacker.attack_log += "\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>"
		else
			log_append_to_last("Armor saved.")
			playsound(src, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER)
			occupant_message("<span class='notice'>The [attacker]'s attack is stopped by the armor.</span>")
			visible_message("<span class='notice'>The [attacker] rebounds off [src.name]'s armor!</span>")
			attacker.attack_log += "\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>"

/obj/mecha/hitby(atom/movable/AM, datum/thrownthing/throwingdatum) //wrapper
	..()
	log_message("Hit by [AM].",1)
	call((proc_res["dynhitby"]||src), "dynhitby")(AM, throwingdatum)
	return

/obj/mecha/proc/dynhitby(atom/movable/AM, datum/thrownthing/throwingdatum)
	if(istype(AM, /obj/item/mecha_parts/mecha_tracking))
		AM.forceMove(src)
		visible_message("The [AM] fastens firmly to [src].")
		return
	if(prob(src.deflect_chance) || ismob(AM))
		occupant_message("<span class='notice'>The [AM] bounces off the armor.</span>")
		visible_message("The [AM] bounces off the [src.name] armor")
		log_append_to_last("Armor saved.")
		if(isliving(AM))
			var/mob/living/M = AM
			M.take_bodypart_damage(10)
	else if(isobj(AM))
		var/obj/O = AM
		if(O.throwforce)
			take_damage(O.throwforce)
			check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	return


/obj/mecha/bullet_act(obj/item/projectile/Proj, def_zone) //wrapper
	log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).",1)
	call((proc_res["dynbulletdamage"]||src), "dynbulletdamage")(Proj) //calls equipment
	return ..()

/obj/mecha/proc/dynbulletdamage(obj/item/projectile/Proj)
	if(prob(src.deflect_chance))
		occupant_message("<span class='notice'>The armor deflects incoming projectile.</span>")
		visible_message("The [src.name] armor deflects the projectile")
		log_append_to_last("Armor saved.")
		return
	var/ignore_threshold
	if(is_type_in_list(Proj, taser_projectiles)) //taser_projectiles defined in projectile.dm
		use_power(200)
		return
	if(istype(Proj, /obj/item/projectile/beam/pulse))
		ignore_threshold = 1
	take_damage(Proj.damage,Proj.flag)
	check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),ignore_threshold)
	Proj.on_hit(src)
	return

/obj/mecha/proc/destroy()
	go_out()
	var/turf/T = get_turf(src)
	if(wreckage)
		var/obj/effect/decal/mecha_wreckage/WR = new wreckage(T)
		WR.reliability = rand(33) + 15
		for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
			WR.salvage["crowbar"] += E.type
		if(cell)
			WR.salvage["crowbar"] += cell.type
			qdel(cell)
		if(internal_tank)
			WR.salvage["crowbar"] += internal_tank.type
			qdel(internal_tank)
	for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
		qdel(E)
	if(prob(60))
		explosion(T, 0, 0, 1, 3)
	qdel(src)

/obj/mecha/ex_act(severity)
	log_message("Affected by explosion of severity: [severity].",1)
	if(prob(src.deflect_chance))
		severity++
		log_append_to_last("Armor saved, changing severity to [severity].")
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(70))
				take_damage(initial(src.health)/2)
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
				return
		if(EXPLODE_LIGHT)
			if(prob(95))
				take_damage(initial(src.health)/5)
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
				return
	destroy()

/obj/mecha/blob_act()
	take_damage(30, BRUTE)
	return


/obj/mecha/emp_act(severity)
	if(get_charge())
		use_power((cell.charge/2)/severity)
		diag_hud_set_mechcell()
		take_damage(50 / severity,ENERGY)
	log_message("EMP detected",1)
	check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
	return

/obj/mecha/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature>src.max_temperature)
		log_message("Exposed to dangerous temperature.",1)
		take_damage(5,BURN)
		check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL))
	return

/obj/mecha/proc/dynattackby(obj/item/weapon/W, mob/user)
	user.do_attack_animation(src)
	log_message("Attacked by [W]. Attacker - [user]")
	if(prob(src.deflect_chance))
		to_chat(user, "<span class='warning'>\The [W] bounces off [src.name].</span>")
		log_append_to_last("Armor saved.")
	else
		occupant_message("<font color='red'><b>[user] hits [src] with [W].</b></font>")
		user.visible_message("<font color='red'><b>[user] hits [src] with [W].</b></font>", "<font color='red'><b>You hit [src] with [W].</b></font>")
		playsound(src, 'sound/mecha/mecha_attacked.ogg', VOL_EFFECTS_MASTER, 100, FALSE)
		take_damage(W.force,W.damtype)
		check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	return

//////////////////////
////// AttackBy //////
//////////////////////

/obj/mecha/attackby(obj/item/weapon/W, mob/user)

	if(isMMI(W))
		if(mmi_move_inside(W,user))
			to_chat(user, "[src]-MMI interface initialized successfuly")
		else
			to_chat(user, "[src]-MMI interface initialization failed.")
		return

	if(istype(W, /obj/item/mecha_parts/mecha_equipment))
		var/obj/item/mecha_parts/mecha_equipment/E = W
		spawn()
			if(E.can_attach(src))
				user.drop_from_inventory(E, src)
				E.attach(src)
				user.visible_message("[user] attaches [W] to [src]", "You attach [W] to [src]")
			else
				to_chat(user, "You were unable to attach [W] to [src]")
		return
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(add_req_access || maint_access)
			if(internals_access_allowed(usr))
				var/obj/item/weapon/card/id/id_card
				if(istype(W, /obj/item/weapon/card/id))
					id_card = W
				else
					var/obj/item/device/pda/pda = W
					id_card = pda.id
				output_maintenance_dialog(id_card, user)
				return
			else
				to_chat(user, "<span class='warning'>Invalid ID: Access denied.</span>")
		else
			to_chat(user, "<span class='warning'>Maintenance protocols disabled by operator.</span>")
	else if(iswrenching(W))
		if(state==1)
			state = 2
			to_chat(user, "You undo the securing bolts.")
		else if(state==2)
			state = 1
			to_chat(user, "You tighten the securing bolts.")
		return
	else if(isprying(W))
		if(state==2)
			state = 3
			to_chat(user, "You open the hatch to the power unit")
		else if(state==3)
			state=2
			to_chat(user, "You close the hatch to the power unit")
		return
	else if(iscoil(W))
		if(state == 3 && hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
			var/obj/item/stack/cable_coil/CC = W
			if(!CC.use(2))
				to_chat(user, "There's not enough wire to finish the task.")
				return
			clearInternalDamage(MECHA_INT_SHORT_CIRCUIT)
			to_chat(user, "You replace the fused wires.")
		return
	else if(isscrewing(W))
		if(hasInternalDamage(MECHA_INT_TEMP_CONTROL))
			clearInternalDamage(MECHA_INT_TEMP_CONTROL)
			to_chat(user, "You repair the damaged temperature controller.")
		else if(state==3 && src.cell)
			cell.forceMove(src.loc)
			src.cell = null
			state = 4
			to_chat(user, "You unscrew and pry out the powercell.")
			log_message("Powercell removed")
		else if(state==4 && src.cell)
			state=3
			to_chat(user, "You screw the cell in place")
		diag_hud_set_mechcell()
		return

	else if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(state==4)
			if(!src.cell)
				to_chat(user, "You install the powercell")
				user.drop_from_inventory(W, src)
				src.cell = W
				log_message("Powercell installed")
			else
				to_chat(user, "There's already a powercell installed.")
			diag_hud_set_mechcell()
		return

	else if(iswelding(W) && user.a_intent != INTENT_HARM)
		var/obj/item/weapon/weldingtool/WT = W
		user.SetNextMove(CLICK_CD_MELEE)
		if (WT.use(0,user))
			if (hasInternalDamage(MECHA_INT_TANK_BREACH))
				clearInternalDamage(MECHA_INT_TANK_BREACH)
				to_chat(user, "<span class='notice'>You repair the damaged gas tank.</span>")
		else
			return
		if(src.health<initial(src.health))
			to_chat(user, "<span class='notice'>You repair some damage to [src.name].</span>")
			src.health += min(10, initial(src.health)-src.health)
			update_health()
		else
			to_chat(user, "The [src.name] is at full integrity")
		return

	else if(istype(W, /obj/item/mecha_parts/mecha_tracking))
		user.drop_from_inventory(W)
		W.forceMove(src)
		user.visible_message("[user] attaches [W] to [src].", "You attach [W] to [src]")
		return

	else if(istype(W, /obj/item/weapon/melee/changeling_hammer))
		var/obj/item/weapon/melee/changeling_hammer/hammer = W
		user.SetNextMove(CLICK_CD_MELEE)
		playsound(src, pick(hammer.hitsound), VOL_EFFECTS_MASTER)
		dynattackby(hammer, user)

	else
		user.SetNextMove(CLICK_CD_MELEE)
		call((proc_res["dynattackby"]||src), "dynattackby")(W,user)

	return


/////////////////////////////////////
////////  Atmospheric stuff  ////////
/////////////////////////////////////

/obj/mecha/proc/get_turf_air()
	var/turf/T = get_turf(src)
	if(T)
		. = T.return_air()
	return

/obj/mecha/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	else
		var/turf/T = get_turf(src)
		if(T)
			return T.remove_air(amount)
	return

/obj/mecha/return_air()
	if(use_internal_tank)
		return cabin_air
	return get_turf_air()

/obj/mecha/proc/return_pressure()
	. = 0
	if(use_internal_tank)
		. =  cabin_air.return_pressure()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_pressure()
	return

//skytodo: //No idea what you want me to do here, mate.
/obj/mecha/proc/return_temperature()
	. = 0
	if(use_internal_tank)
		. = cabin_air.temperature
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.temperature
	return

/obj/mecha/proc/connect(obj/machinery/atmospherics/components/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return 0

	//Make sure are close enough for a valid connection
	if(new_port.loc != src.loc)
		return 0

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src

	//Actually enforce the air sharing
	var/datum/pipeline/P = connected_port.returnPipenet(src)
	if(P && !(internal_tank.return_air() in P.other_airs))
		P.other_airs += internal_tank.return_air()
		P.update = 1
	log_message("Connected to gas port.")
	return 1

/obj/mecha/proc/disconnect()
	if(!connected_port)
		return 0

	var/datum/pipeline/P = connected_port.returnPipenet(src)
	if(P)
		P.other_airs -= internal_tank.return_air()

	connected_port.connected_device = null
	connected_port = null
	log_message("Disconnected from gas port.")
	return 1


/////////////////////////
////////  Verbs  ////////
/////////////////////////


/obj/mecha/proc/connect_to_port()
	if(!src.occupant)
		return

	if(usr != src.occupant)
		return

	var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
	if(possible_port)
		if(connect(possible_port))
			occupant_message("<span class='notice'>[name] connects to the port.</span>")
			return
		else
			occupant_message("<span class='warning'>[name] failed to connect to the port.</span>")
			return
	else
		occupant_message("Nothing happens")


/obj/mecha/proc/disconnect_from_port()
	if(!src.occupant) return
	if(usr != src.occupant)
		return
	if(disconnect())
		occupant_message("<span class='notice'>[name] disconnects from the port.</span>")
	else
		occupant_message("<span class='warning'>[name] is not connected to the port at the moment.</span>")

/obj/mecha/proc/toggle_lights()
	if(usr != occupant)
		return

	if(!has_charge(lights_power))
		return
	if(!check_fumbling("<span class='notice'>You fumble around, figuring out how to toggle lights [!lights?"on":"off"].</span>"))
		return
	lights = !lights
	if(lights)
		set_light(light_range + lights_power)
	else
		set_light(light_range - lights_power)
	occupant_message("Toggled lights [lights?"on":"off"].")
	log_message("Toggled lights [lights?"on":"off"].")
	return


/obj/mecha/proc/toggle_internal_tank()
	if(usr != src.occupant)
		return
	if(!check_fumbling("<span class='notice'>You fumble around, figuring out how to toggle internal tank usage [!use_internal_tank?"on":"off"].</span>"))
		return
	use_internal_tank = !use_internal_tank
	occupant_message("Now taking air from [use_internal_tank?"internal airtank":"environment"].")
	log_message("Now taking air from [use_internal_tank?"internal airtank":"environment"].")
	return

/obj/mecha/MouseDrop_T(mob/user)
	if (usr.incapacitated() || !ishuman(usr))
		return

	if (usr.buckled)
		to_chat(usr,"<span class='warning'>You can't climb into the exosuit while buckled!</span>")
		return

	log_message("[usr] tries to move in.")
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C.handcuffed)
			to_chat(usr, "<span class='warning'>Kinda hard to climb in while handcuffed don't you think?</span>")
			return
	if (src.occupant)
		to_chat(usr, "<span class='notice'><B>The [src.name] is already occupied!</B></span>")
		log_append_to_last("Permission denied.")
		return

	var/passed
	if(src.dna)
		if(usr.dna.unique_enzymes==src.dna)
			passed = 1
	else if(operation_allowed(usr))
		passed = 1
	if(!passed)
		to_chat(usr, "<span class='warning'>Access denied</span>")
		log_append_to_last("Permission denied.")
		return
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, "You're too busy getting your life sucked out of you.")
			return

	visible_message("<span class='notice'>[usr] starts to climb into [src.name]</span>")

	if(enter_after(MECHA_TIME_TO_ENTER, usr))
		if(!src.occupant)
			moved_inside(usr)
		else if(src.occupant!=usr)
			to_chat(usr, "[src.occupant] was faster. Try better next time, loser.")
	else
		to_chat(usr, "You stop entering the exosuit.")
	return

/obj/mecha/proc/moved_inside(mob/living/carbon/human/H)
	if(H && H.client && H.Adjacent(src))
		H.reset_view(src)
		H.forceMove(src)
		src.occupant = H
		add_fingerprint(H)
		forceMove(src.loc)
		log_append_to_last("[H] moved in as pilot.")
		log_admin("[key_name(H)] has moved in [src.type] with name [src.name]")
		src.icon_state = reset_icon()
		set_dir(dir_in)
		playsound(src, 'sound/machines/windowdoor.ogg', VOL_EFFECTS_MASTER)
		GrantActions(H, human_occupant = 1)
		if(!hasInternalDamage())
			occupant.playsound_local(null, 'sound/mecha/nominal.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		return 1
	else
		return 0

/obj/mecha/proc/mmi_move_inside(obj/item/device/mmi/mmi_as_oc,mob/user)
	if(!mmi_as_oc.brainmob || !mmi_as_oc.brainmob.client)
		to_chat(user, "Consciousness matrix not detected.")
		return 0
	else if(mmi_as_oc.brainmob.stat != CONSCIOUS)
		to_chat(user, "Beta-rhythm below acceptable level.")
		return 0
	else if(occupant)
		to_chat(user, "Occupant detected.")
		return 0
	else if(dna && dna!=mmi_as_oc.brainmob.dna.unique_enzymes)
		to_chat(user, "Stop it!")
		return 0

	visible_message("<span class='notice'>[usr] starts to insert an MMI into [src.name]</span>")

	if(enter_after(MECHA_TIME_TO_ENTER, user))
		if(!occupant)
			return mmi_moved_inside(mmi_as_oc,user)
		else
			to_chat(user, "Occupant detected.")
	else
		to_chat(user, "You stop inserting the MMI.")
	return 0

/obj/mecha/proc/mmi_moved_inside(obj/item/device/mmi/mmi_as_oc,mob/user)
	if(mmi_as_oc && (user in range(1)))
		if(!mmi_as_oc.brainmob || !mmi_as_oc.brainmob.client)
			to_chat(user, "Consciousness matrix not detected.")
			return 0
		else if(mmi_as_oc.brainmob.stat != CONSCIOUS)
			to_chat(user, "Beta-rhythm below acceptable level.")
			return 0
		user.drop_from_inventory(mmi_as_oc)
		var/mob/brainmob = mmi_as_oc.brainmob
		brainmob.reset_view(src)
		occupant = brainmob
		brainmob.loc = src //should allow relaymove
		brainmob.canmove = 1
		mmi_as_oc.loc = src
		Entered(mmi_as_oc)
		Move(src.loc)
		src.icon_state = reset_icon()
		set_dir(dir_in)
		GrantActions(brainmob)
		log_message("[mmi_as_oc] moved in as pilot.")
		log_admin("[key_name(mmi_as_oc)] has moved in [src.type] with name [src.name] as MMI brain by [key_name(user)]")
		if(!hasInternalDamage())
			occupant.playsound_local(null, 'sound/mecha/nominal.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		return 1
	else
		return 0

/obj/mecha/proc/view_stats()
	if(usr != src.occupant)
		return
	if(!check_fumbling("<span class='notice'>You fumble around, figuring out how to open exosuit stats.</span>"))
		return
	src.occupant << browse(get_stats_html(), "window=exosuit")
	return

/obj/mecha/proc/eject()
	if(usr != src.occupant)
		return
	go_out()
	add_fingerprint(usr)
	return

/obj/mecha/container_resist()
	go_out()

/obj/mecha/proc/go_out()
	if(!src.occupant) return
	var/atom/movable/mob_container
	if(ishuman(occupant))
		mob_container = src.occupant
		RemoveActions(occupant, human_occupant = 1)
	else if(isbrain(occupant))
		var/mob/living/carbon/brain/brain = occupant
		RemoveActions(brain)
		mob_container = brain.container
	else
		return

	mob_container.forceMove(src.loc)
	playsound(src, 'sound/mecha/mech_eject.ogg', VOL_EFFECTS_MASTER, 75, FALSE, null, -3)
	log_message("[mob_container] moved out.")
	log_admin("[key_name(mob_container)] has moved out of [src.type] with name [src.name]")
	occupant.reset_view()

	src.occupant << browse(null, "window=exosuit")
	if(src.occupant.hud_used && src.last_user_hud && !isMMI(mob_container))
		occupant.hud_used.show_hud(HUD_STYLE_STANDARD)

	if(isMMI(mob_container))
		var/obj/item/device/mmi/mmi = mob_container
		if(mmi.brainmob)
			occupant.loc = mmi
		src.occupant.canmove = 0
	src.occupant = null
	src.icon_state = reset_icon()+"-open"
	set_dir(dir_in)

/////////////////////////
////// Access stuff /////
/////////////////////////

/obj/mecha/proc/operation_allowed(mob/living/carbon/human/H)
	for(var/ID in list(H.get_active_hand(), H.wear_id, H.belt))
		if(check_access(ID,src.operation_req_access))
			return 1
	return 0


/obj/mecha/proc/internals_access_allowed(mob/living/carbon/human/H)
	for(var/atom/ID in list(H.get_active_hand(), H.wear_id, H.belt))
		if(check_access(ID,src.internals_req_access))
			return 1
	return 0


/obj/mecha/check_access(obj/item/weapon/card/id/I, list/access_list)
	if(!istype(access_list))
		return 1
	if(!access_list.len) //no requirements
		return 1
	if(istype(I, /obj/item/device/pda))
		var/obj/item/device/pda/pda = I
		I = pda.id
	if(istype(I, /obj/item/weapon/storage/wallet))
		var/obj/item/weapon/storage/wallet/wallet = I
		I = wallet.GetID()
	if(!istype(I) || !I.access) //not ID or no access
		return 0
	if(access_list==src.operation_req_access)
		for(var/req in access_list)
			if(!(req in I.access)) //doesn't have this access
				return 0
	else if(access_list==src.internals_req_access)
		for(var/req in access_list)
			if(req in I.access)
				return 1
	return 1


////////////////////////////////
/////// Messages and Log ///////
////////////////////////////////

/obj/mecha/proc/occupant_message(message)
	if(message)
		if(src.occupant && src.occupant.client)
			to_chat(src.occupant, "[bicon(src)] [message]")
	return

/obj/mecha/proc/log_message(message,red=null)
	log.len++
	log[log.len] = list("time"=world.timeofday,"message"="[red?"<font color='red'>":null][message][red?"</font>":null]")
	return log.len

/obj/mecha/proc/log_append_to_last(message,red=null)
	var/list/last_entry = src.log[src.log.len]
	last_entry["message"] += "<br>[red?"<font color='red'>":null][message][red?"</font>":null]"
	return

///////////////////////
///// Power stuff /////
///////////////////////

/obj/mecha/proc/has_charge(amount)
	return (get_charge()>=amount)

/obj/mecha/proc/get_charge()
	return call((proc_res["dyngetcharge"]||src), "dyngetcharge")()

/obj/mecha/proc/dyngetcharge()//returns null if no powercell, else returns cell.charge
	if(!src.cell) return
	return max(0, src.cell.charge)

/obj/mecha/proc/use_power(amount)
	return call((proc_res["dynusepower"]||src), "dynusepower")(amount)

/obj/mecha/proc/dynusepower(amount)
	if(get_charge())
		cell.use(amount)
		diag_hud_set_mechcell()
		return 1
	return 0

/obj/mecha/proc/give_power(amount)
	if(!isnull(get_charge()))
		cell.give(amount)
		diag_hud_set_mechcell()
		return 1
	return 0

/obj/mecha/proc/reset_icon()
	if (initial_icon)
		icon_state = initial_icon
	else
		icon_state = initial(icon_state)
	return icon_state

//////////////////////////////////////////
////////  Mecha global iterators  ////////
//////////////////////////////////////////


//processing internal damage, temperature, air regulation, alert updates, lights power use.
/obj/mecha/process()
	process_mecha_preserve_temp()
	process_mecha_tank_give_air()
	process_mecha_internal_damage()
	process_light()

/obj/mecha/proc/process_mecha_preserve_temp()
	if(cabin_air && cabin_air.volume > 0)
		var/delta = cabin_air.temperature - T20C
		cabin_air.temperature -= max(-10, min(10, round(delta/4,0.1)))
	return

/obj/mecha/proc/process_mecha_tank_give_air()
	if(!internal_tank)
		return

	var/datum/gas_mixture/tank_air = internal_tank.return_air()

	var/release_pressure = internal_tank_valve
	var/cabin_pressure = cabin_air.return_pressure()
	var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
	var/transfer_moles = 0
	if(pressure_delta > 0) //cabin pressure lower than release pressure
		if(tank_air.temperature > 0)
			transfer_moles = pressure_delta * cabin_air.volume / (cabin_air.temperature * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
			cabin_air.merge(removed)
	else if(pressure_delta < 0) //cabin pressure higher than release pressure
		var/datum/gas_mixture/t_air = get_turf_air()
		pressure_delta = cabin_pressure - release_pressure
		if(t_air)
			pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
		if(pressure_delta > 0) //if location pressure is lower than cabin pressure
			transfer_moles = pressure_delta * cabin_air.volume/(cabin_air.temperature * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
			if(t_air)
				t_air.merge(removed)
			else //just delete the cabin gas, we're in space or some shit
				qdel(removed)


/obj/mecha/proc/process_mecha_internal_damage() // processing internal damage
	if(!hasInternalDamage())
		return
	if(hasInternalDamage(MECHA_INT_FIRE))
		if(!hasInternalDamage(MECHA_INT_TEMP_CONTROL) && prob(5))
			clearInternalDamage(MECHA_INT_FIRE)
		if(internal_tank)
			if(internal_tank.return_pressure() > internal_tank.maximum_pressure && !(hasInternalDamage(MECHA_INT_TANK_BREACH)))
				setInternalDamage(MECHA_INT_TANK_BREACH)
			var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
			if(int_tank_air && int_tank_air.volume > 0) //heat the air_contents
				int_tank_air.temperature = min(6000 + T0C, int_tank_air.temperature + rand(10, 15))
		if(cabin_air && cabin_air.volume>0)
			cabin_air.temperature = min(6000 + T0C, cabin_air.temperature+rand(10, 15))
			if(cabin_air.temperature > max_temperature / 2)
				take_damage(4 / round(max_temperature / cabin_air.temperature, 0.1),BURN)
	if(hasInternalDamage(MECHA_INT_TANK_BREACH)) //remove some air from internal tank
		if(internal_tank)
			var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
			var/datum/gas_mixture/leaked_gas = int_tank_air.remove_ratio(0.10)
			if(loc && hascall(loc,"assume_air"))
				loc.assume_air(leaked_gas)
			else
				qdel(leaked_gas)
	if(hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
		if(get_charge())
			spark_system.start()
			cell.charge -= min(20, cell.charge)
			cell.maxcharge -= min(20, cell.maxcharge)
			diag_hud_set_mechcell()
	return

/obj/mecha/proc/process_light()
	if(!lights)
		return
	if(has_charge(lights_power))
		use_power(lights_power)
	else
		lights = 0
		set_light(light_range - lights_power)
	return

#undef MECHA_TIME_TO_ENTER
