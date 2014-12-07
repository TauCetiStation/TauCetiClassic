#define MELEE 1
#define RANGED 2

#define POD_INT_FIRE 1
#define POD_INT_TEMP_CONTROL 2
#define POD_INT_SHORT_CIRCUIT 4
#define POD_INT_TANK_BREACH 8
#define POD_INT_CONTROL_LOST 16
#define POD_INT_THRUSTER 32

/obj/spacecraft
	name = "Spacecraft"
	desc = ""
	icon = 'tauceti/modules/_spacecraft/spacecraft.dmi'
	icon_state = "test"
	density = 1
	opacity = 1
	unacidable = 1
	anchored = 1
	bounds = "64,64"
	layer = MOB_LAYER  //Нужно посмотреть
	var/mob/living/carbon/pilot = null //Оператор аппарата
	var/state = 0
	//Движение
	var/can_turn = 1 //может ли повернуть
	var/can_move = 0
	var/speed = 0 //Текущая скорость
	var/last_relay = 0
	var/turn_energy_drain = 5
	var/turn_slow_rate = 2 //степень замедления при повороте

	var/obj/item/weapon/cell/cell //энергоячейка
	var/online = 0 //есть питание/нет питания
	//Двигло
	var/obj/item/spacecraft_parts/engine/engine = null
	var/engine_on = 0
	var/cooling_rate = 3 //степень охлаждения
	//итераторы
	var/datum/global_iterator/pr_inertial_movement //итератор инерционного движения в космосе
	var/datum/global_iterator/pr_speed_increment //увеличение скорости
	var/datum/global_iterator/pr_cooling //охлаждение подсистем
	var/datum/global_iterator/pr_int_temp_processor //normalizes internal air mixture temperature
	var/datum/global_iterator/pr_give_air //moves air from tank to cabin
	var/datum/global_iterator/pr_internal_damage //processes internal damage

	//Health
	var/health = 300 //health is health
	var/deflect_chance = 10 //chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	//the values in this list show how much damage will pass through, not how much will be absorbed.
	var/list/damage_absorption = list("brute"=0.8,"fire"=1.2,"bullet"=0.9,"laser"=1,"energy"=1,"bomb"=1)
	var/max_temperature = 25000
	var/internal_damage_threshold = 50 //health percentage below which internal damage is possible
	var/internal_damage = 0 //contains bitflags

	//Атмос
	var/use_internal_tank = 0
	var/internal_tank_valve = ONE_ATMOSPHERE
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/datum/gas_mixture/cabin_air
	//эффекты
	var/datum/effect/effect/system/jet_trail_follow/jet_trail
	var/datum/effect/effect/system/spark_spread/spark_system = new

	var/class = "test"
	var/list/log = new

	//Оборудование
	var/list/equipment = new
	var/list/equipment_wing = new
	var/max_equip = 3
	var/max_equip_wing = 1
	var/obj/item/spacecraft_parts/spacecraft_equipment/selected
	var/list/special_equipment = new

	var/wreckage

	var/obj/machinery/spacecraft_refill_station/connected_port = null //станция зарядки
	var/icon/C = 'tauceti/modules/_spacecraft/spacecraft_bay.dmi'
	//Освещение
	var/lights = 0
	var/lights_power = 6
	//Радио
	var/obj/item/device/radio/radio = null
	//Доступ
	var/list/operation_req_access = list()//уровень допуска для пилотирования
	var/list/internals_req_access = list(access_engine,access_robotics)//уроваень допуска для техобслуживания
	var/add_req_access = 1
	var/maint_access = 1

	New()
		..()
		add_iterators()
		engine = new /obj/item/spacecraft_parts/engine(src)
		add_cell()
		add_airtank()
		add_cabin()
		add_radio()
		pr_cooling.stop()
		pr_int_temp_processor.stop()
		pr_give_air.stop()
		src.jet_trail = new /datum/effect/effect/system/jet_trail_follow()
		src.jet_trail.set_up(src)
		spark_system.set_up(2, 0, src)
		spark_system.attach(src)
		src.verbs -= /obj/spacecraft/verb/disconnect_from_port
		src.verbs -= /atom/movable/verb/pull
		src.verbs -= /obj/spacecraft/verb/toggle_engine
		src.verbs -= /obj/spacecraft/verb/view_stats
//		var/obj/spacecraft_parts/spacecraft_equipment/L = new /obj/item/spacecraft_parts/spacecraft_equipment
//		L.attach(src)

		return

	Del()
		src.go_out()
		..()
		return

//////HELPERS///////
/obj/spacecraft/proc/removeVerb(verb_path)
	verbs -= verb_path

/obj/spacecraft/proc/addVerb(verb_path)
	verbs += verb_path

/obj/spacecraft/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)  	//Внутренний бак с воздухом
	return internal_tank

/obj/spacecraft/proc/add_cabin()															//Кокпит,а точнее, её атмосфера
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.oxygen = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.nitrogen = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	return cabin_air

/obj/spacecraft/proc/add_radio()
	radio = new(src)
	radio.name = "[src] radio"
	radio.icon = icon
	radio.icon_state = icon_state
	radio.subspace_transmission = 1

/obj/spacecraft/proc/add_cell(var/obj/item/weapon/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.charge = 15000
	cell.maxcharge = 15000


/obj/spacecraft/proc/add_iterators()														//Итераторы
	pr_int_temp_processor = new /datum/global_iterator/spacecraft_preserve_temp(list(src))
	pr_give_air = new /datum/global_iterator/spacecraft_tank_give_air(list(src))
	pr_internal_damage = new /datum/global_iterator/spacecraft_internal_damage(list(src),0)
	pr_inertial_movement = new /datum/global_iterator/spacecraft_inertial_movement(list(src),0)
	pr_speed_increment = new /datum/global_iterator/spacecraft_speed_increment(list(src),0)
	pr_cooling = new /datum/global_iterator/spacecraft_cooling(list(src))

/obj/spacecraft/proc/enter_after(delay as num, var/mob/user as mob, var/numticks = 5)
	var/delayfraction = delay/numticks
	var/turf/T = user.loc
	for(var/i = 0, i<numticks, i++)
		sleep(delayfraction)
		if(!src || !user || !user.canmove || !(user.loc == T))
			return 0
	return 1

/obj/spacecraft/proc/inspace()
	if(istype(src.loc, /turf/space))
		return 1
	return 0

/obj/spacecraft/examine()
	set src in view()
	..()
	var/integrity = health/initial(health)*100
	switch(integrity)
		if(85 to 100)
			usr << "It's fully intact."
		if(65 to 85)
			usr << "It's slightly damaged."
		if(45 to 65)
			usr << "It's badly damaged."
		if(25 to 45)
			usr << "It's heavily damaged."
		else
			usr << "It's falling apart."
	if(equipment && equipment.len)
		usr << "It's equipped with:"
		for(var/obj/item/spacecraft_parts/spacecraft_equipment/SE in equipment)
			usr << "\icon[SE] [SE]"
	return

/obj/spacecraft/proc/update_damage_icon()
	var/integrity = health/initial(health)*100
	if(src)
		switch(integrity)
			if(85 to 100)
				src.icon_state = "[src.class]"
			if(65 to 85)
				src.icon_state = "[src.class]-damage1"
			if(45 to 65)
				src.icon_state = "[src.class]-damage2"
			if(25 to 45)
				src.icon_state = "[src.class]-damage3"
			else
				src.icon_state = "[src.class]-damage4"

/obj/spacecraft/proc/connect(obj/machinery/spacecraft_refill_station/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_sc || src.dir != new_port.dir)
		return 0
	//Make sure are close enough for a valid connection
	if(new_port.loc != src.loc)
		return 0
	if(src.engine_on)
		src.occupant_message("<font color='red'>Engine must be turned off!</font>")
		return 0
	//Perform the connection
	connected_port = new_port
	connected_port.connected_sc = src
	src.overlays += image('tauceti/modules/_spacecraft/spacecraft_bay.dmi', icon_state = "cables_[src.class]")
	usr << "Connected to port"
	return 1

/obj/spacecraft/proc/disconnect()
	if(!connected_port)
		return 0
	src.overlays -= image('tauceti/modules/_spacecraft/spacecraft_bay.dmi', icon_state = "cables_[src.class]")
	connected_port.connected_sc = null
	connected_port = null
	usr << "Disconnected from port"
	return 1

////////////////////////
///////Actions/////////
/obj/spacecraft/proc/click_action(atom/target,mob/user)
	if(!src.pilot || src.pilot != user ) return
	if(user.stat) return
	if(state)
		occupant_message("<font color='red'>Maintenance protocols in effect</font>")
		return
	if(!get_charge()) return
	if(src == target) return
	var/dir_to_target = get_dir(src,target)
	if(dir_to_target && !(dir_to_target & src.dir))//wrong direction
		return
	if(hasInternalDamage(POD_INT_CONTROL_LOST))
		target = safepick(view(3,target))
		if(!target)
			return
	var/turf/upperleft = locate(src.x,src.y+2,src.z)
	var/turf/upperright = locate(src.x+1,src.y+2,src.z)
//	for(var/turf/T in block(upperleft,upperright))
	if(selected && selected.is_melee())
		if(((target.x == upperleft.x) && (target.y == upperleft.y)) || ((target.x == upperright.x) && (target.y == upperright.y)))
			world << "opa, [src.x],[src.y],[target.x],[target.y],[upperleft.x],[upperleft.y],[upperright.x],[upperright.y]"
			selected.action(target)
	if(get_dist(src, target)>1)
		if(selected && selected.is_ranged())
			selected.action(target)
	else if(selected && selected.is_melee())
		selected.action(target)
	else
		src.melee_action(target)
	return

/obj/spacecraft/proc/melee_action(atom/target)
	return

/obj/spacecraft/proc/range_action(atom/target)
	return


//////VERBS////////
/obj/spacecraft/verb/move_inside()
	set category = "Object"
	set name = "Enter spacecraft's cockpit"
	set src in oview(1)
	if (usr.stat || !ishuman(usr))
		return
	src.log_message("[usr] tries to move in.")
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C.handcuffed)
			usr << "\red Kinda hard to climb in while handcuffed don't you think?"
			return
	if (src.pilot)
		usr << "\blue <B>The [src.name] is already occupied!</B>"
		src.log_append_to_last("Permission denied.")
		return

	var/passed
	if(src.operation_allowed(usr))
		passed = 1
	if(!passed)
		usr << "\red Access denied"
		src.log_append_to_last("Permission denied.")
		return

	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			usr << "You're too busy getting your life sucked out of you."
			return
	usr << "You start climbing into [src.name]"

	visible_message("\blue [usr] starts to climb into [src.name]")

	if(enter_after(40,usr))
		if(!src.pilot)
			moved_inside(usr)
		else if(src.pilot != usr)
			usr << "[src.pilot] was faster. Try better next time, loser."
	else
		usr << "You stop entering the spacecraft."
	return

/obj/spacecraft/proc/moved_inside(var/mob/living/carbon/human/H as mob)
	if(H && H.client && H in range(1))
		H.reset_view(src)
		H.stop_pulling()
		H.forceMove(src)
		src.pilot = H
		src.add_fingerprint(H)
		src.forceMove(src.loc)
		src.log_append_to_last("[H] moved in as pilot.")

	//	playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
	//	if(!hasInternalDamage())
	//		src.occupant << sound('sound/mecha/nominal.ogg',volume=50)
		return 1
	else
		return 0

/obj/spacecraft/verb/eject()
	set name = "Eject"
	set category = "Spacecraft Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr != src.pilot)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/spacecraft/proc/go_out()
	if(!src.pilot) return
	var/atom/movable/mob_container
	mob_container = src.pilot
	if(mob_container.forceMove(src.loc))//ejecting mob container
		src.log_message("[mob_container] moved out.")
		pilot.reset_view()
		src.pilot << browse(null, "window=spacecraft")
		src.pilot = null
	return

/obj/spacecraft/verb/Debug()
	set name = "Debug"
	set category = "Spacecraft Interface"
	set src = usr.loc
	set popup_menu = 0
	var/tank_pressure = internal_tank ? round(internal_tank.return_pressure(),0.01) : "None"
	if(usr!=pilot)	return
	usr << "[get_charge()], , [src.loc], [get_fuel()], [get_oxidiser()], [engine.cur_heat_capacity], [tank_pressure], Current speed: [get_current_speed()], Desired speed: [get_desired_speed()]"
	usr << "[world.time-last_relay]"

/obj/spacecraft/verb/toggle_engine()
	set name = "Toggle spacecraft's main engine."
	set category = "Spacecraft Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.pilot)
		return
	if(!src.engine)
		return
	if(src.engine.health <= 0)
		src.occupant_message("<font color='red'>The [src.engine] is damaged!</font>")
		return
	if(online)
		engine_on = !engine_on
		if(engine_on)
			engine_start()
		else
			engine_stop()
	else
		src.occupant_message("<font color='red'>No power!</font>")

/obj/spacecraft/verb/toggle_power()
	set name = "Toggle spacecraft's power system."
	set category = "Spacecraft Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.pilot)
		return
	online = !online
	if(online)
		use_internal_tank = 1
		if(!hasInternalDamage(POD_INT_TEMP_CONTROL))
			src.pr_int_temp_processor.start(list(src))
		src.pr_give_air.start(list(src))
		src.pr_cooling.start()
		src.occupant_message("<font color='red'>All systems engaged</font>")
		src.pilot << sound('sound/mecha/nominal.ogg',volume=50)
		src.verbs += /obj/spacecraft/verb/toggle_engine
		src.verbs += /obj/spacecraft/verb/view_stats
	else
		use_internal_tank = 0
		engine_on = 0
//		can_move = 1
		engine_stop()
		src.pr_int_temp_processor.stop()
		src.pr_cooling.stop()
		src.pr_give_air.stop()
		src.occupant_message("<font color='red'>All systems offline</font>")
		src.verbs -= /obj/spacecraft/verb/toggle_engine
		src.verbs -= /obj/spacecraft/verb/view_stats

/obj/spacecraft/verb/connect_to_port()
	set name = "Connect to port"
	set category = "Spacecraft Interface"
	set src = usr.loc
	set popup_menu = 0
	if(!src.pilot) return
	if(usr!=src.pilot)
		return
	var/obj/machinery/spacecraft_refill_station/possible_port = locate(/obj/machinery/spacecraft_refill_station) in loc
	if(possible_port)
		if(connect(possible_port))
			possible_port.connected(src)
			src.occupant_message("\blue [name] connects to the port.")
			src.verbs += /obj/spacecraft/verb/disconnect_from_port
			src.verbs -= /obj/spacecraft/verb/connect_to_port
			return
		else
			src.occupant_message("\red [name] failed to connect to the port.")
			return
	else
		src.occupant_message("Nothing happens")


/obj/spacecraft/verb/disconnect_from_port()
	set name = "Disconnect from port"
	set category = "Spacecraft Interface"
	set src = usr.loc
	set popup_menu = 0
	if(!src.pilot) return
	if(usr!=src.pilot)
		return
	var/obj/machinery/spacecraft_refill_station/port = locate(/obj/machinery/spacecraft_refill_station) in loc
	if(disconnect())
		port.disconnected()
		src.occupant_message("\blue [name] disconnects from the port.")
		src.verbs -= /obj/spacecraft/verb/disconnect_from_port
		src.verbs += /obj/spacecraft/verb/connect_to_port
	else
		src.occupant_message("\red [name] is not connected to the port at the moment.")

/obj/spacecraft/verb/toggle_lights()
	set name = "Toggle Lights"
	set category = "Spacecraft Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=pilot)	return
	lights = !lights
	if(lights)	SetLuminosity(luminosity + lights_power)
	else	SetLuminosity(luminosity - lights_power)
	src.occupant_message("Toggled lights [lights?"on":"off"].")
	log_message("Toggled lights [lights?"on":"off"].")
	return

/obj/spacecraft/verb/view_stats()
	set name = "Main computer"
	set category = "Spacecraft Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.pilot)
		return
	src.pilot << browse(src.get_stats_html(), "window=spacecraft")
	return


/////MOVEMENT///////
/obj/spacecraft/relaymove(mob/user,direction)
	spawn()
		if(user != src.pilot) //While not "realistic", this piece is player friendly.
			user.forceMove(get_turf(src))
			user << "You climb out from [src]"
			return 0
		if(connected_port)
			usr << "Unable to move while connected to the port"
			return 0
		if(state)
			occupant_message("<font color='red'>Maintenance protocols in effect</font>")
			return

		if(world.time-last_relay<1)
			return 0
		if(!can_move || engine.health <=0 || !online)
			return 0

		last_relay = world.time
		var/speed_change = 0
		pr_inertial_movement:min_delay = src.engine.max_speed
		pr_inertial_movement:max_delay = src.engine.min_speed
		if(direction & NORTH)
			if(!engine.oxidiser_tank)
				if(!has_fuel(engine.fuel_drain) || !has_charge(engine.power_drain))
					return
				else
					use_fuel(engine.fuel_drain)
					use_power(engine.power_drain)

			else
				if(!has_fuel(engine.fuel_drain) || !has_oxidiser(engine.oxidiser_drain) || !has_charge(engine.power_drain))
					return
				else
					if(pr_inertial_movement:desired_delay == pr_inertial_movement:min_delay)
						return
					else
						use_fuel(engine.fuel_drain)
						use_oxidiser(engine.oxidiser_drain)
						use_power(engine.power_drain)
						engine.cur_heat_capacity += engine.heating
						pr_inertial_movement:desired_delay = between(pr_inertial_movement:min_delay, pr_inertial_movement:desired_delay-1, pr_inertial_movement:max_delay)
						speed_change = 1
		else if (direction & SOUTH)
			if(!has_charge(engine.power_drain))
				return
			else
				if(pr_inertial_movement:desired_delay == pr_inertial_movement:max_delay)
					return
				else
					use_power(engine.power_drain)
					engine.cur_heat_capacity += (engine.heating/2)
					pr_inertial_movement:desired_delay = between(pr_inertial_movement:min_delay, pr_inertial_movement:desired_delay+1, pr_inertial_movement:max_delay)
					speed_change = 1
		else if (src.can_turn && direction & 4)
			if(!has_charge(turn_energy_drain))
				return
			else
				use_power(turn_energy_drain)
				use_fuel(engine.fuel_drain/3)
				use_oxidiser(engine.oxidiser_drain/3)
				if(pr_inertial_movement:desired_delay <= pr_inertial_movement:max_delay)
					pr_inertial_movement:desired_delay += turn_slow_rate
					pr_inertial_movement:cur_delay += turn_slow_rate
				src.dir = turn(src.dir, -90.0)
		else if (src.can_turn && direction & 8)
			if(!has_charge(turn_energy_drain))
				return
			else
				use_fuel(engine.fuel_drain/3)
				use_oxidiser(engine.oxidiser_drain/3)
				use_power(turn_energy_drain)
				if(pr_inertial_movement:desired_delay <= pr_inertial_movement:max_delay)
					pr_inertial_movement:desired_delay += turn_slow_rate
					pr_inertial_movement:cur_delay += turn_slow_rate
				src.dir = turn(src.dir, 90)
		if(speed_change)
		//	src.pr_speed_increment.start()
			speed_increment(src)
			src.pr_inertial_movement.start()
			src.engine_check()
	return


/obj/spacecraft/proc/get_desired_speed()
	return (pr_inertial_movement:max_delay-pr_inertial_movement:desired_delay)/(pr_inertial_movement:max_delay-pr_inertial_movement:min_delay)*100

/obj/spacecraft/proc/get_current_speed()
	return (pr_inertial_movement:max_delay-pr_inertial_movement:cur_delay)/(pr_inertial_movement:max_delay-pr_inertial_movement:min_delay)*100

/obj/spacecraft/proc/speed_increment(var/obj/spacecraft/SC as obj)
	if(SC.pr_inertial_movement:desired_delay != SC.pr_inertial_movement:cur_delay)
		var/delta = SC.pr_inertial_movement:desired_delay - SC.pr_inertial_movement:cur_delay
		SC.pr_inertial_movement:cur_delay += delta>0?1:-1
	return


////ENGINE//////
/obj/spacecraft/proc/engine_start()
	playsound(src, 'tauceti/modules/_spacecraft/sounds/engineon.ogg', 50, 0)
	src.occupant_message("<font color='red'>Starting up main engine...</font>")
	sleep(80)
	src.occupant_message("<font color='red'>Engine is online</font>")
	src.engine_overlay()
	can_move = 1
	src.jet_trail.start()


/obj/spacecraft/proc/engine_stop()
	src.occupant_message("<font color='red'>Engine is offline</font>")
	src.engine_overlay()
	can_move = 0
	src.jet_trail.stop()

/obj/spacecraft/proc/engine_check()
	if(!src.engine)
		return
	if(src.engine.cur_heat_capacity >= src.engine.max_heat_capacity-100)
		src.occupant_message("<font color='red'>Warning, [src.engine] is overheated!</font>")
	if(src.engine.cur_heat_capacity >= src.engine.max_heat_capacity)
		src.engine.health -= 10
	if(src.engine.health == 0)
		src.occupant_message("<font color='red'>[src.engine] has been damaged!</font>")
		can_move = 0
		src.engine_on = 0
		src.jet_trail.stop()
		src.engine_overlay()

/obj/spacecraft/proc/engine_overlay()
	var/I = image('tauceti/modules/_spacecraft/spacecraft.dmi', loc = src, icon_state = "[src.class]-flame")
	if(src.engine_on)
		src.overlays += I
	else
		src.overlays -= I
	return


////////  Internal damage  ////////
/obj/spacecraft/proc/check_for_internal_damage(var/list/possible_int_damage,var/ignore_threshold=null)
	if(!islist(possible_int_damage) || isemptylist(possible_int_damage)) return
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
			var/obj/item/spacecraft_parts/spacecraft_equipment/destr = safepick(equipment)
			if(destr)
				destr.destroy()
	return

/obj/spacecraft/proc/hasInternalDamage(int_dam_flag=null)
	return int_dam_flag ? internal_damage&int_dam_flag : internal_damage

/obj/spacecraft/proc/setInternalDamage(int_dam_flag)
	internal_damage |= int_dam_flag
	pr_internal_damage.start()
	log_append_to_last("Internal damage of type [int_dam_flag].",1)
	pilot << sound('sound/machines/warning-buzzer.ogg',wait=0)
	return

/obj/spacecraft/proc/clearInternalDamage(int_dam_flag)
	internal_damage &= ~int_dam_flag
	switch(int_dam_flag)
		if(POD_INT_TEMP_CONTROL)
			occupant_message("<font color='blue'><b>Life support system reactivated.</b></font>")
			pr_int_temp_processor.start()
		if(POD_INT_FIRE)
			occupant_message("<font color='blue'><b>Internal fire extinquished.</b></font>")
		if(POD_INT_TANK_BREACH)
			occupant_message("<font color='blue'><b>Damaged internal tank has been sealed.</b></font>")
//		if(POD_INT_THRUSTER)
//			occupant_message("<font color='blue'><b>Damaged main thruster has been repaired.</b></font>")
//			src.flight_in = initial(flight_in)
	return

////////  Health related procs  ////////
/obj/spacecraft/proc/take_damage(amount, type="brute")
	if(amount)
		var/damage = absorbDamage(amount,type)
		health -= damage
		update_health()
		update_damage_icon()
		log_append_to_last("Took [damage] points of damage. Damage type: \"[type]\".",1)
	return

/obj/spacecraft/proc/absorbDamage(damage,damage_type)
	return damage*(listgetindex(damage_absorption,damage_type) || 1)

/obj/spacecraft/proc/update_health()
	if(src.health > 0)
		src.spark_system.start()
	else
		src.destroy()
	return

/obj/spacecraft/proc/destroy()
	spawn()
		go_out()
		var/turf/T = get_turf(src)
		tag = "\ref[src]" //better safe then sorry
		if(loc)
			loc.Exited(src)
		loc = null
		if(T)
/*			if(istype(src, /obj/mecha/working/ripley/))
				var/obj/mecha/working/ripley/R = src
				if(R.cargo)
					for(var/obj/O in R.cargo) //Dump contents of stored cargo
						O.loc = T
						R.cargo -= O
						T.Entered(O) */


			explosion(T, 0, 0, 1, 3)
			spawn(0)
				if(wreckage)
					var/obj/effect/decal/spacecraft_wreckage/PR = new wreckage(T)
			/*		for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
						if(E.salvageable && prob(30))
							WR.crowbar_salvage += E
							E.forceMove(WR)
							E.equip_ready = 1
							E.reliability = round(rand(E.reliability/3,E.reliability))
						else
							E.forceMove(T)
							E.destroy()
					if(cell)
						WR.crowbar_salvage += cell
						cell.forceMove(WR)
						cell.charge = rand(0, cell.charge)
					if(internal_tank)
						WR.crowbar_salvage += internal_tank
						internal_tank.forceMove(WR) */
				else
					for(var/obj/item/spacecraft_parts/spacecraft_equipment/E in equipment)
						E.forceMove(T)
						E.destroy()
		spawn(0)
			del(src)
	return

/obj/spacecraft/attack_alien(mob/user as mob)
	src.log_message("Attack by xenomorph. Attacker - [user].",1)
	if(!prob(90))
		src.take_damage(10)
//		src.check_for_internal_damage(list(POD_INT_TEMP_CONTROL,POD_INT_TANK_BREACH,POD_INT_CONTROL_LOST))
		playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1, -1)
		user << "\red You slash at the spacecraft!"
		visible_message("\red The [user] slashes at [src.name]'s armor!")
	else
		src.log_append_to_last("Armor saved.")
		playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1, -1)
		user << "\green Your claws had no effect!"
		src.occupant_message("\blue The [user]'s claws are stopped by the armor.")
		visible_message("\blue The [user] rebounds off [src.name]'s armor!")
	return

/obj/spacecraft/attack_animal(mob/living/simple_animal/user as mob)
	src.log_message("Attack by simple animal. Attacker - [user].",1)
	if(user.melee_damage_upper == 0)
		user.emote("[user.friendly] [src]")
	else
		if(!prob(90))
			var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
			src.take_damage(damage)
//			src.check_for_internal_damage(list(POD_INT_TEMP_CONTROL,POD_INT_TANK_BREACH,POD_INT_CONTROL_LOST))
			visible_message("\red <B>[user]</B> [user.attacktext] [src]!")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
		else
			src.log_append_to_last("Armor saved.")
			playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1, -1)
			src.occupant_message("\blue The [user]'s attack is stopped by the armor.")
			visible_message("\blue The [user] rebounds off [src.name]'s armor!")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
	return

/obj/spacecraft/bullet_act(var/obj/item/projectile/Proj) //wrapper
	src.log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).",1)
	if(prob(src.deflect_chance))
		src.occupant_message("\blue The armor deflects incoming projectile.")
		src.visible_message("The [src.name] armor deflects the projectile")
		src.log_append_to_last("Armor saved.")
		return
	var/ignore_threshold
	if(Proj.flag == "taser")
		return
	if(istype(Proj, /obj/item/projectile/beam/pulse))
		ignore_threshold = 1
	src.take_damage(Proj.damage,Proj.flag)
	src.check_for_internal_damage(list(POD_INT_FIRE,POD_INT_TEMP_CONTROL,POD_INT_TANK_BREACH,POD_INT_CONTROL_LOST,POD_INT_SHORT_CIRCUIT),ignore_threshold)
	Proj.on_hit(src)
	return

/obj/spacecraft/ex_act(severity)
	src.log_message("Affected by explosion of severity: [severity].",1)
	if(prob(src.deflect_chance))
		severity++
		src.log_append_to_last("Armor saved, changing severity to [severity].")
	switch(severity)
		if(1.0)
			src.destroy()
		if(2.0)
			if (prob(30))
				src.destroy()
			else
				src.take_damage(initial(src.health)/2)
				src.check_for_internal_damage(list(POD_INT_FIRE,POD_INT_TEMP_CONTROL,POD_INT_TANK_BREACH,POD_INT_CONTROL_LOST,POD_INT_SHORT_CIRCUIT,POD_INT_THRUSTER),1)
		if(3.0)
			if (prob(5))
				src.destroy()
			else
				src.take_damage(initial(src.health)/5)
				src.check_for_internal_damage(list(POD_INT_FIRE,POD_INT_TEMP_CONTROL,POD_INT_TANK_BREACH,POD_INT_CONTROL_LOST,POD_INT_SHORT_CIRCUIT,POD_INT_THRUSTER),1)
	return

/obj/spacecraft/meteorhit()
	return ex_act(rand(1,3))//should do for now

/obj/spacecraft/emp_act(severity)
	if(get_charge())
		use_power((cell.charge/2)/severity)
		take_damage(50 / severity,"energy")
	src.log_message("EMP detected",1)
	check_for_internal_damage(list(POD_INT_FIRE,POD_INT_TEMP_CONTROL,POD_INT_CONTROL_LOST,POD_INT_SHORT_CIRCUIT),1)
	return
/*
/obj/pod/proc/dynattackby(obj/item/weapon/W as obj, mob/user as mob)
	src.log_message("Attacked by [W]. Attacker - [user]")
	if(prob(90))
		user << "\red The [W] bounces off [src.name] armor."
		src.log_append_to_last("Armor saved.")
	else
		src.occupant_message("<font color='red'><b>[user] hits [src] with [W].</b></font>")
		user.visible_message("<font color='red'><b>[user] hits [src] with [W].</b></font>", "<font color='red'><b>You hit [src] with [W].</b></font>")
		src.take_damage(W.force,W.damtype)
		src.check_for_internal_damage(list(POD_INT_TEMP_CONTROL,POD_INT_TANK_BREACH,POD_INT_CONTROL_LOST))
	return
*/

//////////////////////
////// AttackBy //////
//////////////////////

/obj/spacecraft/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/turf/T = user.loc


	if(istype(W, /obj/item/spacecraft_parts/spacecraft_equipment))
		var/obj/item/spacecraft_parts/spacecraft_equipment/E = W
		spawn()
			if(E.can_attach(src))
				user.drop_item()
				E.attach(src)
				user.visible_message("[user] attaches [W] to [src]", "You attach [W] to [src]")
			else
				user << "You were unable to attach [W] to [src]"
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
				user << "\red Invalid ID: Access denied."
		else
			user << "\red Maintenance protocols disabled by operator."
	else if(istype(W, /obj/item/weapon/wrench))
		if(state==1)
			state = 2
			user << "You undo the securing bolts."
		else if(state==2)
			state = 1
			user << "You tighten the securing bolts."
		else if(state == 3 && engine)
			user << "You begin unwrenching [src.engine]."
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			sleep(40)
			if( !istype(src, /obj/spacecraft) || !user || !W || !T )	return
			if( user.loc == T && user.get_active_hand() == W )
				src.engine.forceMove(src.loc)
				src.engine = null
			user << "You remove engine from [src]."
		return
	else if(istype(W, /obj/item/weapon/crowbar))
		if(state==2)
			state = 3
			user << "You open the maintenance hatch."
		else if(state==3)
			state=2
			user << "You close the maintenance hatch."
		return
/*	else if(istype(W, /obj/item/weapon/cable_coil))
		if(state == 3 && hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
			var/obj/item/weapon/cable_coil/CC = W
			if(CC.amount > 1)
				CC.use(2)
				clearInternalDamage(MECHA_INT_SHORT_CIRCUIT)
				user << "You replace the fused wires."
			else
				user << "There's not enough wire to finish the task."
		return
	else if(istype(W, /obj/item/weapon/screwdriver))
		if(hasInternalDamage(MECHA_INT_TEMP_CONTROL))
			clearInternalDamage(MECHA_INT_TEMP_CONTROL)
			user << "You repair the damaged temperature controller."
		else if(state==3 && src.cell)
			src.cell.forceMove(src.loc)
			src.cell = null
			state = 4
			user << "You unscrew and pry out the powercell."
			src.log_message("Powercell removed")
		else if(state==4 && src.cell)
			state=3
			user << "You screw the cell in place"
		return

	else if(istype(W, /obj/item/weapon/cell))
		if(state==4)
			if(!src.cell)
				user << "You install the powercell"
				user.drop_item()
				W.forceMove(src)
				src.cell = W
				src.log_message("Powercell installed")
			else
				user << "There's already a powercell installed."
		return

	else if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent != "hurt")
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0,user))
			if (hasInternalDamage(MECHA_INT_TANK_BREACH))
				clearInternalDamage(MECHA_INT_TANK_BREACH)
				user << "\blue You repair the damaged gas tank."
		else
			return
		if(src.health<initial(src.health))
			user << "\blue You repair some damage to [src.name]."
			src.health += min(10, initial(src.health)-src.health)
		else
			user << "The [src.name] is at full integrity"
		return

	else if(istype(W, /obj/item/mecha_parts/mecha_tracking))
		user.drop_from_inventory(W)
		W.forceMove(src)
		user.visible_message("[user] attaches [W] to [src].", "You attach [W] to [src]")
		return

	else if(istype(W, /obj/item/weapon/paintkit))

		if(occupant)
			user << "You can't customize a mech while someone is piloting it - that would be unsafe!"
			return

		var/obj/item/weapon/paintkit/P = W
		var/found = null

		for(var/type in P.allowed_types)
			if(type==src.initial_icon)
				found = 1
				break

		if(!found)
			user << "That kit isn't meant for use on this class of exosuit."
			return

		user.visible_message("[user] opens [P] and spends some quality time customising [src].")

		src.name = P.new_name
		src.desc = P.new_desc
		src.initial_icon = P.new_icon
		src.reset_icon()

		user.drop_item()
		del(P)

	else
		call((proc_res["dynattackby"]||src), "dynattackby")(W,user)
/*
		src.log_message("Attacked by [W]. Attacker - [user]")
		if(prob(src.deflect_chance))
			user << "\red The [W] bounces off [src.name] armor."
			src.log_append_to_last("Armor saved.")
/*
			for (var/mob/V in viewers(src))
				if(V.client && !(V.blinded))
					V.show_message("The [W] bounces off [src.name] armor.", 1)
*/
		else
			src.occupant_message("<font color='red'><b>[user] hits [src] with [W].</b></font>")
			user.visible_message("<font color='red'><b>[user] hits [src] with [W].</b></font>", "<font color='red'><b>You hit [src] with [W].</b></font>")
			src.take_damage(W.force,W.damtype)
			src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
*/
	return



/*
/obj/mecha/attack_ai(var/mob/living/silicon/ai/user as mob)
	if(!istype(user, /mob/living/silicon/ai))
		return
	var/output = {"<b>Assume direct control over [src]?</b>
						<a href='?src=\ref[src];ai_take_control=\ref[user];duration=3000'>Yes</a><br>
						"}
	user << browse(output, "window=mecha_attack_ai")
	return
*/

*/
////FUEL STUFF//////
/obj/spacecraft/proc/has_fuel(amount)
	return (get_fuel()>=amount)

/obj/spacecraft/proc/get_fuel()
	if(!src.engine.fuel_tank) return
	return max(0, src.engine.fuel_tank.reagents.get_reagent_amount(src.engine.fuel_tank.reagent_type))

/obj/spacecraft/proc/use_fuel(amount)
	if(get_fuel())
		src.engine.fuel_tank.reagents.remove_reagent(src.engine.fuel_tank.reagent_type, amount)
		return 1
	return 0

/obj/spacecraft/proc/has_oxidiser(amount)
	return (get_oxidiser()>=amount)

/obj/spacecraft/proc/get_oxidiser()
	if(!src.engine.oxidiser_tank) return
	return max(0, src.engine.oxidiser_tank.reagents.get_reagent_amount(src.engine.oxidiser_tank.reagent_type))

/obj/spacecraft/proc/use_oxidiser(amount)
	if(get_oxidiser())
		src.engine.oxidiser_tank.reagents.remove_reagent(src.engine.oxidiser_tank.reagent_type, amount)
		return 1
	return 0

/////POWER STUFF/////
/obj/spacecraft/proc/has_charge(amount)
	return (get_charge()>=amount)

/obj/spacecraft/proc/get_charge()
	if(!src.cell) return
	return max(0, src.cell.charge)

/obj/spacecraft/proc/use_power(amount)
	if(get_charge())
		cell.use(amount)
		return 1
	return 0

/obj/spacecraft/proc/give_power(amount)
	if(!isnull(get_charge()))
		cell.give(amount)
		return 1
	return 0
/*
/obj/mecha/proc/reset_icon()
	if (initial_icon)
		icon_state = initial_icon
	else
		icon_state = initial(icon_state)
	return icon_state
	*/

////// Access stuff /////
/obj/spacecraft/proc/operation_allowed(mob/living/carbon/human/H)
	for(var/ID in list(H.get_active_hand(), H.wear_id, H.belt))
		if(src.check_access(ID,src.operation_req_access))
			return 1
	return 0

/obj/spacecraft/proc/internals_access_allowed(mob/living/carbon/human/H)
	for(var/atom/ID in list(H.get_active_hand(), H.wear_id, H.belt))
		if(src.check_access(ID,src.internals_req_access))
			return 1
	return 0

/obj/spacecraft/check_access(obj/item/weapon/card/id/I, list/access_list)
	if(!istype(access_list))
		return 1
	if(!access_list.len) //no requirements
		return 1
	if(istype(I, /obj/item/device/pda))
		var/obj/item/device/pda/pda = I
		I = pda.id
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

//////////////////////////////////
/*****ATMOS WORKS****************/
//////////////////////////////////
/obj/spacecraft/proc/get_turf_air()
	var/turf/T = get_turf(src)
	if(T)
		. = T.return_air()
	return

/obj/spacecraft/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	else
		var/turf/T = get_turf(src)
		if(T)
			return T.remove_air(amount)
	return

/obj/spacecraft/return_air()
	if(use_internal_tank)
		return cabin_air
	return get_turf_air()

/obj/spacecraft/proc/return_pressure()
	. = 0
	if(use_internal_tank)
		. =  cabin_air.return_pressure()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_pressure()
	return

/obj/spacecraft/proc/return_temperature()
	. = 0
	if(use_internal_tank)
		. = cabin_air.return_temperature()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_temperature()
	return


////////////////////////////////////
///// Rendering stats window ///////
////////////////////////////////////
/obj/spacecraft/proc/get_stats_html()
	var/output = {"<html>
						<head><title>[src.name] data</title>
						<style>
						body {color: #00ff00; background: #000000; font-family:"Lucida Console",monospace; font-size: 12px;}
						hr {border: 1px solid #0f0; color: #0f0; background-color: #0f0;}
						a {padding:2px 5px;;color:#0f0;}
						.wr {margin-bottom: 5px;}
						.header {cursor:pointer;}
						.open, .closed {background: #32CD32; color:#000; padding:1px 2px;}
						.links a {margin-bottom: 2px;padding-top:3px;}
						.visible {display: block;}
						.hidden {display: none;}
						</style>
						<script language='javascript' type='text/javascript'>
						[js_byjax]
						[js_dropdowns]
						function ticker() {
						    setInterval(function(){
						        window.location='byond://?src=\ref[src]&update_content=1';
						    }, 1000);
						}

						window.onload = function() {
							dropdowns();
							ticker();
						}
						</script>
						</head>
						<body>
						<div id='content'>
						[src.get_stats_part()]
						</div>
						<div id='eq_list'>
						[src.get_equipment_list()]
						</div>
						<hr>
						<div id='commands'>
						[src.get_commands()]
						</div>
						</body>
						</html>
					 "}
	return output


/obj/spacecraft/proc/report_internal_damage()
	var/output = null
	var/list/dam_reports = list(
										"[POD_INT_FIRE]" = "<font color='red'><b>INTERNAL FIRE</b></font>",
										"[POD_INT_TEMP_CONTROL]" = "<font color='red'><b>LIFE SUPPORT SYSTEM MALFUNCTION</b></font>",
										"[POD_INT_TANK_BREACH]" = "<font color='red'><b>GAS TANK BREACH</b></font>",
										"[POD_INT_CONTROL_LOST]" = "<font color='red'><b>COORDINATION SYSTEM CALIBRATION FAILURE</b></font> - <a href='?src=\ref[src];repair_int_control_lost=1'>Recalibrate</a>",
										"[POD_INT_SHORT_CIRCUIT]" = "<font color='red'><b>SHORT CIRCUIT</b></font>"
										)
	for(var/tflag in dam_reports)
		var/intdamflag = text2num(tflag)
		if(hasInternalDamage(intdamflag))
			output += dam_reports[tflag]
			output += "<br />"
	if(return_pressure() > WARNING_HIGH_PRESSURE)
		output += "<font color='red'><b>DANGEROUSLY HIGH CABIN PRESSURE</b></font><br />"
	return output


/obj/spacecraft/proc/get_stats_part()
	var/integrity = health/initial(health)*100
	var/cell_charge = get_charge()
	var/tank_pressure = internal_tank ? round(internal_tank.return_pressure(),0.01) : "None"
	var/tank_temperature = internal_tank ? internal_tank.return_temperature() : "Unknown"
	var/cabin_pressure = round(return_pressure(),0.01)
	var/output = {"[report_internal_damage()]
						[integrity<30?"<font color='red'><b>DAMAGE LEVEL CRITICAL</b></font><br>":null]
						<b>Integrity: </b> [integrity]%<br>
						<b>Powercell charge: </b>[isnull(cell_charge)?"No powercell installed":"[cell.percent()]%"]<br>
						<b>Air source: </b>[use_internal_tank?"Internal Airtank":"Environment"]<br>
						<b>Airtank pressure: </b>[tank_pressure]kPa<br>
						<b>Airtank temperature: </b>[tank_temperature]&deg;K|[tank_temperature - T0C]&deg;C<br>
						<b>Cabin pressure: </b>[cabin_pressure>WARNING_HIGH_PRESSURE ? "<font color='red'>[cabin_pressure]</font>": cabin_pressure]kPa<br>
						<b>Cabin temperature: </b> [return_temperature()]&deg;K|[return_temperature() - T0C]&deg;C<br>
						<b>Engine: </b>[engine] - [engine_on ? "On" : "Off"]<br>
						<b>Engine integrity: </b>[engine.health]<br>
						<b>Engine heat capacity: </b>[engine.cur_heat_capacity]/[engine.max_heat_capacity]<br>
						<b>Fuel tank: </b>[get_fuel()]/[engine.fuel_tank.volume]<br>
						<b>Oxidiser tank: </b>[isnull(engine.oxidiser_tank)?"No oxidiser tank installed":"[get_oxidiser()]/[engine.oxidiser_tank.volume]"]<br>
						<b>Current thrust: </b>[get_current_speed()]%<br>
						<b>Lights: </b>[lights?"on":"off"]<br>
					"}
	return output

/obj/spacecraft/proc/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Electronics</div>
						<div class='links'>
						<a href='?src=\ref[src];toggle_lights=1'>Toggle Lights</a><br>
						<b>Radio settings:</b><br>
						Microphone: <a href='?src=\ref[src];rmictoggle=1'><span id="rmicstate">[radio.broadcasting?"Engaged":"Disengaged"]</span></a><br>
						Speaker: <a href='?src=\ref[src];rspktoggle=1'><span id="rspkstate">[radio.listening?"Engaged":"Disengaged"]</span></a><br>
						Frequency:
						<a href='?src=\ref[src];rfreq=-10'>-</a>
						<a href='?src=\ref[src];rfreq=-2'>-</a>
						<span id="rfreq">[format_frequency(radio.frequency)]</span>
						<a href='?src=\ref[src];rfreq=2'>+</a>
						<a href='?src=\ref[src];rfreq=10'>+</a><br>
						<div class='wr'>
						<div class='header'>Permissions & Logging</div>
						<div class='links'>
						<a href='?src=\ref[src];toggle_id_upload=1'><span id='t_id_upload'>[add_req_access?"L":"Unl"]ock ID upload panel</span></a><br>
						<a href='?src=\ref[src];toggle_maint_access=1'><span id='t_maint_access'>[maint_access?"Forbid":"Permit"] maintenance protocols</span></a><br>
						<a href='?src=\ref[src];view_log=1'>View internal log</a><br>
						<a href='?src=\ref[src];change_name=1'>Change spacecraft name</a><br>
						</div>
						</div>
						<div id='equipment_menu'>[get_equipment_menu()]</div>
						<hr>
						[(/obj/spacecraft/verb/eject in src.verbs)?"<a href='?src=\ref[src];eject=1'>Eject</a><br>":null]
						"}
	return output

/obj/spacecraft/proc/get_equipment_menu() //outputs mecha html equipment menu
	var/output
	if(equipment_wing.len)
		output += {"<div class='wr'>
						<div class='header'>Equipment</div>
						<div class='links'>"}
		for(var/obj/item/spacecraft_parts/spacecraft_equipment/W in equipment)
			output += "[W.name] <a href='?src=\ref[W];detach=1'>Detach</a><br>"
		output += "<b>Available equipment slots:</b> [max_equip_wing-equipment_wing.len]"
		output += "</div></div>"
	return output

/obj/spacecraft/proc/get_equipment_list() //outputs mecha equipment list in html
	if(!equipment_wing.len)
		return
	var/output = "<b>Equipment:</b><div style=\"margin-left: 15px;\">"
	for(var/obj/item/spacecraft_parts/spacecraft_equipment/ST in equipment)
		output += "<div id='\ref[ST]'>[ST.get_equip_info()]</div>"
	output += "</div>"
	return output

/obj/spacecraft/proc/get_log_html()
	var/output = "<html><head><title>[src.name] Log</title></head><body style='font: 13px 'Courier', monospace;'>"
	for(var/list/entry in log)
		output += {"<div style='font-weight: bold;'>[time2text(entry["time"],"DDD MMM DD hh:mm:ss")] [game_year]</div>
						<div style='margin-left:15px; margin-bottom:10px;'>[entry["message"]]</div>
						"}
	output += "</body></html>"
	return output

/obj/spacecraft/proc/output_access_dialog(obj/item/weapon/card/id/id_card, mob/user)
	if(!id_card || !user) return
	var/output = {"<html>
						<head><style>
						h1 {font-size:15px;margin-bottom:4px;}
						body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
						a {color:#0f0;}
						</style>
						</head>
						<body>
						<h1>Following keycodes are present in this system:</h1>"}
	for(var/a in operation_req_access)
		output += "[get_access_desc(a)] - <a href='?src=\ref[src];del_req_access=[a];user=\ref[user];id_card=\ref[id_card]'>Delete</a><br>"
	output += "<hr><h1>Following keycodes were detected on portable device:</h1>"
	for(var/a in id_card.access)
		if(a in operation_req_access) continue
		var/a_name = get_access_desc(a)
		if(!a_name) continue //there's some strange access without a name
		output += "[a_name] - <a href='?src=\ref[src];add_req_access=[a];user=\ref[user];id_card=\ref[id_card]'>Add</a><br>"
	output += "<hr><a href='?src=\ref[src];finish_req_access=1;user=\ref[user]'>Finish</a> <font color='red'>(Warning! The ID upload panel will be locked. It can be unlocked only through Exosuit Interface.)</font>"
	output += "</body></html>"
	user << browse(output, "window=spacecraft_add_access")
	onclose(user, "spacecraft_add_access")
	return

/obj/spacecraft/proc/output_maintenance_dialog(obj/item/weapon/card/id/id_card,mob/user)
	if(!id_card || !user) return
	var/output = {"<html>
						<head>
						<style>
						body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
						a {padding:2px 5px; background:#32CD32;color:#000;display:block;margin:2px;text-align:center;text-decoration:none;}
						</style>
						</head>
						<body>
						[add_req_access?"<a href='?src=\ref[src];req_access=1;id_card=\ref[id_card];user=\ref[user]'>Edit operation keycodes</a>":null]
						[maint_access?"<a href='?src=\ref[src];maint_access=1;id_card=\ref[id_card];user=\ref[user]'>Initiate maintenance protocol</a>":null]
						[(state>0) ?"<a href='?src=\ref[src];set_internal_tank_valve=1;user=\ref[user]'>Set Cabin Air Pressure</a>":null]
						</body>
						</html>"}
	user << browse(output, "window=spacecraft_maint_console")
	onclose(user, "spacecraft_maint_console")
	return

/////////////////
///// Topic /////
/////////////////
/obj/spacecraft/Topic(href, href_list)
	..()
	if(href_list["update_content"])
		if(usr != src.pilot)	return
		send_byjax(src.pilot,"spacecraft.browser","content",src.get_stats_part())
		return
	if(href_list["close"])
		return
	if(usr.stat > 0)
		return
	var/datum/topic_input/filter = new /datum/topic_input(href,href_list)
	if(href_list["select_equip"])
		if(usr != src.pilot)	return
		var/obj/item/spacecraft_parts/spacecraft_equipment/equip = filter.getObj("select_equip")
		if(equip)
			src.selected = equip
			src.occupant_message("You switch to [equip]")
			send_byjax(src.pilot,"spacecraft.browser","eq_list",src.get_equipment_list())
		return
	if(href_list["eject"])
		if(usr != src.pilot)	return
		src.eject()
		return
	if(href_list["toggle_lights"])
		if(usr != src.pilot)	return
		src.toggle_lights()
		return
//	if(href_list["toggle_airtank"])
//		if(usr != src.occupant)	return
//		src.toggle_internal_tank()
//		return
	if(href_list["rmictoggle"])
		if(usr != src.pilot)	return
		radio.broadcasting = !radio.broadcasting
		send_byjax(src.pilot,"spacecraft.browser","rmicstate",(radio.broadcasting?"Engaged":"Disengaged"))
		return
	if(href_list["rspktoggle"])
		if(usr != src.pilot)	return
		radio.listening = !radio.listening
		send_byjax(src.pilot,"spacecraft.browser","rspkstate",(radio.listening?"Engaged":"Disengaged"))
		return
	if(href_list["rfreq"])
		if(usr != src.pilot)	return
		var/new_frequency = (radio.frequency + filter.getNum("rfreq"))
		if (!radio.freerange || (radio.frequency < 1200 || radio.frequency > 1600))
			new_frequency = sanitize_frequency(new_frequency)
		radio.set_frequency(new_frequency)
		send_byjax(src.pilot,"spacecraft.browser","rfreq","[format_frequency(radio.frequency)]")
		return
	if(href_list["port_disconnect"])
		if(usr != src.pilot)	return
		src.disconnect_from_port()
		return
	if (href_list["port_connect"])
		if(usr != src.pilot)	return
		src.connect_to_port()
		return
	if (href_list["view_log"])
		if(usr != src.pilot)	return
		src.pilot << browse(src.get_log_html(), "window=spacecraft_log")
		onclose(pilot, "spacecraft_log")
		return
	if (href_list["change_name"])
		if(usr != src.pilot)	return
		var/newname = strip_html_simple(input(pilot,"Choose new spacecraft name","Rename spacecraft",initial(name)) as text, MAX_NAME_LEN)
		if(newname && trim(newname))
			name = newname
		else
			alert(pilot, "nope.avi")
		return
	if (href_list["toggle_id_upload"])
		if(usr != src.pilot)	return
		add_req_access = !add_req_access
		send_byjax(src.pilot,"spacecraft.browser","t_id_upload","[add_req_access?"L":"Unl"]ock ID upload panel")
		return
	if(href_list["toggle_maint_access"])
		if(usr != src.pilot)	return
		if(state)
			occupant_message("<font color='red'>Maintenance protocols in effect</font>")
			return
		maint_access = !maint_access
		send_byjax(src.pilot,"spacecraft.browser","t_maint_access","[maint_access?"Forbid":"Permit"] maintenance protocols")
		return
	if(href_list["req_access"] && add_req_access)
		if(!in_range(src, usr))	return
		output_access_dialog(filter.getObj("id_card"),filter.getMob("user"))
		return
	if(href_list["maint_access"] && maint_access)
		if(!in_range(src, usr))	return
		var/mob/user = filter.getMob("user")
		if(user)
			if(state==0)
				state = 1
				user << "The securing bolts are now exposed."
			else if(state==1)
				state = 0
				user << "The securing bolts are now hidden."
			output_maintenance_dialog(filter.getObj("id_card"),user)
		return
	if(href_list["set_internal_tank_valve"] && state >=1)
		if(!in_range(src, usr))	return
		var/mob/user = filter.getMob("user")
		if(user)
			var/new_pressure = input(user,"Input new output pressure","Pressure setting",internal_tank_valve) as num
			if(new_pressure)
				internal_tank_valve = new_pressure
				user << "The internal pressure valve has been set to [internal_tank_valve]kPa."
	if(href_list["add_req_access"] && add_req_access && filter.getObj("id_card"))
		if(!in_range(src, usr))	return
		operation_req_access += filter.getNum("add_req_access")
		output_access_dialog(filter.getObj("id_card"),filter.getMob("user"))
		return
	if(href_list["del_req_access"] && add_req_access && filter.getObj("id_card"))
		if(!in_range(src, usr))	return
		operation_req_access -= filter.getNum("del_req_access")
		output_access_dialog(filter.getObj("id_card"),filter.getMob("user"))
		return
	if(href_list["finish_req_access"])
		if(!in_range(src, usr))	return
		add_req_access = 0
		var/mob/user = filter.getMob("user")
		user << browse(null,"window=spacecraft_add_access")
		return
	if(href_list["repair_int_control_lost"])
		if(usr != src.pilot)	return
		src.occupant_message("Recalibrating coordination system.")
		src.log_message("Recalibration of coordination system started.")
		var/T = src.loc
		if(do_after(100))
			if(T == src.loc)
				src.clearInternalDamage(POD_INT_CONTROL_LOST)
				src.occupant_message("<font color='blue'>Recalibration successful.</font>")
				src.log_message("Recalibration of coordination system finished with 0 errors.")
			else
				src.occupant_message("<font color='red'>Recalibration failed.</font>")
				src.log_message("Recalibration of coordination system failed with 1 error.",1)

	//debug
	/*
	if(href_list["debug"])
		if(href_list["set_i_dam"])
			setInternalDamage(filter.getNum("set_i_dam"))
		if(href_list["clear_i_dam"])
			clearInternalDamage(filter.getNum("clear_i_dam"))
		return
	*/

	return


//////////////////////////////////
/**********MESSAGES AND LOGS*****/
//////////////////////////////////
/obj/spacecraft/proc/occupant_message(message as text)
	if(message)
		if(src.pilot && src.pilot.client)
			src.pilot << "\icon[src] [message]"
	return

/obj/spacecraft/proc/log_message(message as text,red=null)
	log.len++
	log[log.len] = list("time"=world.timeofday,"message"="[red?"<font color='red'>":null][message][red?"</font>":null]")
	return log.len

/obj/spacecraft/proc/log_append_to_last(message as text,red=null)
	var/list/last_entry = src.log[src.log.len]
	last_entry["message"] += "<br>[red?"<font color='red'>":null][message][red?"</font>":null]"
	return

////ITERATORS///////
/datum/global_iterator/spacecraft_preserve_temp  //normalizing cabin air temperature to 20 degrees celsium. Типо кондиционер.
	delay = 20

	process(var/obj/spacecraft/SC)
		if(!SC.has_charge(0.3))
			return src.stop()
		else
			if(SC.cabin_air && SC.cabin_air.return_volume() > 0)
				var/delta = SC.cabin_air.temperature - T20C
				SC.cabin_air.temperature -= max(-10, min(10, round(delta/4,0.1)))
				SC.use_power(0.3)
			return

/datum/global_iterator/spacecraft_tank_give_air
	delay = 15
	process(var/obj/spacecraft/SC)
		if(SC.internal_tank || !SC.has_charge(0.1))
			var/datum/gas_mixture/tank_air = SC.internal_tank.return_air()
			var/datum/gas_mixture/cabin_air = SC.cabin_air

			var/release_pressure = SC.internal_tank_valve
			var/cabin_pressure = cabin_air.return_pressure()
			var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
			var/transfer_moles = 0
			if(pressure_delta > 0) //cabin pressure lower than release pressure
				if(tank_air.return_temperature() > 0)
					transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
					cabin_air.merge(removed)
			else if(pressure_delta < 0) //cabin pressure higher than release pressure
				var/datum/gas_mixture/t_air = SC.get_turf_air()
				pressure_delta = cabin_pressure - release_pressure
				if(t_air)
					pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
				if(pressure_delta > 0) //if location pressure is lower than cabin pressure
					transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
					if(t_air)
						t_air.merge(removed)
					else //just delete the cabin gas, we're in space or some shit
						del(removed)
			SC.use_power(0.1)
		else
			return stop()
		return

/datum/global_iterator/spacecraft_cooling
	delay = 20
	process(var/obj/spacecraft/SC as obj)
		if(!SC.engine)
			return stop()
		if(!SC.has_charge(SC.cooling_rate/10))
			return stop()
		else
			if(SC.engine.cur_heat_capacity > SC.cooling_rate)
				SC.engine.cur_heat_capacity -= SC.cooling_rate
				SC.use_power(SC.cooling_rate/10)
		return

/datum/global_iterator/spacecraft_internal_damage // processing internal damage
	process(var/obj/spacecraft/SC)
		if(!SC.hasInternalDamage())
			return stop()
		if(SC.hasInternalDamage(POD_INT_FIRE))
			if(!SC.hasInternalDamage(POD_INT_TEMP_CONTROL) && prob(5))
				SC.clearInternalDamage(POD_INT_FIRE)
			if(SC.internal_tank)
				if(SC.internal_tank.return_pressure()>SC.internal_tank.maximum_pressure && !(SC.hasInternalDamage(POD_INT_TANK_BREACH)))
					SC.setInternalDamage(POD_INT_TANK_BREACH)
				var/datum/gas_mixture/int_tank_air = SC.internal_tank.return_air()
				if(int_tank_air && int_tank_air.return_volume()>0) //heat the air_contents
					int_tank_air.temperature = min(6000+T0C, int_tank_air.temperature+rand(10,15))
			if(SC.cabin_air && SC.cabin_air.return_volume()>0)
				SC.cabin_air.temperature = min(6000+T0C, SC.cabin_air.return_temperature()+rand(10,15))
			//	if(SC.cabin_air.return_temperature()>SC.max_temperature/2)
			//		SC.take_damage(4/round(SC.max_temperature/SC.cabin_air.return_temperature(),0.1),"fire")
		if(SC.hasInternalDamage(POD_INT_TEMP_CONTROL)) //stop the pod_preserve_temp loop datum
			SC.pr_int_temp_processor.stop()
		if(SC.hasInternalDamage(POD_INT_TANK_BREACH)) //remove some air from internal tank
			if(SC.internal_tank)
				var/datum/gas_mixture/int_tank_air = SC.internal_tank.return_air()
				var/datum/gas_mixture/leaked_gas = int_tank_air.remove_ratio(0.10)
				if(SC.loc && hascall(SC.loc,"assume_air"))
					SC.loc.assume_air(leaked_gas)
				else
					del(leaked_gas)
		if(SC.hasInternalDamage(POD_INT_SHORT_CIRCUIT))
			if(SC.get_charge())
				SC.spark_system.start()
				SC.cell.charge -= min(20,SC.cell.charge)
				SC.cell.maxcharge -= min(20,SC.cell.maxcharge)

	//	if(pod.hasInternalDamage(POD_INT_THRUSTER))
	//		pod.flight_in = 10
		return

/datum/global_iterator/spacecraft_inertial_movement
	delay = 1
	var/min_delay = 0
	var/max_delay = 10
	var/desired_delay
	var/cur_delay
	var/last_move

	New()
		..()
		desired_delay = max_delay
		cur_delay = max_delay

	stop()
		src.cur_delay = max_delay
		src.desired_delay = max_delay
		return ..()

	process(var/obj/spacecraft/SC as obj)
		if(cur_delay >= max_delay)
			return src.stop()
		if(world.time - last_move < cur_delay)
			return
		last_move = world.time

		if(!step(SC, SC.dir) || !SC.inspace())
			src.stop()
		return

	proc/set_desired_delay(var/num as num)
		src.desired_delay = num
		return

/datum/global_iterator/spacecraft_speed_increment
	delay = 5

	process(var/obj/spacecraft/SC as obj)
		if(SC.pr_inertial_movement:desired_delay != SC.pr_inertial_movement:cur_delay)
			var/delta = SC.pr_inertial_movement:desired_delay - SC.pr_inertial_movement:cur_delay
			SC.pr_inertial_movement:cur_delay += delta>0?1:-1

			for(var/mob/M in SC)
				M << "Current speed: [SC.get_current_speed()]"

		else
			src.stop()
		return