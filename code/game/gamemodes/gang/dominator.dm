/obj/machinery/dominator
	name = "dominator"
	desc = "A visibly sinister device. Looks like you can break it if you hit it enough."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = 1
	anchored = 1.0
	layer = 3.6
	interact_offline = TRUE
	var/maxhealth = 200
	var/health = 200
	var/gang
	var/operating = 0

/obj/machinery/dominator/tesla_act()
	qdel(src)

/obj/machinery/dominator/atom_init()
	. = ..()
	if(!istype(SSticker.mode, /datum/game_mode/gang))
		return INITIALIZE_HINT_QDEL
	set_light(2)
	poi_list += src

/obj/machinery/dominator/examine(mob/user)
	..()
	if(operating == -1)
		to_chat(user, "<span class='danger'>It looks completely busted.</span>")
		return

	var/datum/game_mode/gang/mode = SSticker.mode
	var/time = null
	if(gang == "A")
		if(isnum(mode.A_timer))
			time = max(mode.A_timer, 0)
	if(gang == "B")
		if(isnum(mode.B_timer))
			time = max(mode.B_timer, 0)
	if(isnum(time))
		if(time > 0)
			to_chat(user, "<span class='notice'>Hostile Takeover in progress. Estimated [time] seconds remain.</span>")
		else
			to_chat(user, "<span class='notice'>Hostile Takeover of [station_name()] successful. Have a great day.</span>")
	else
		to_chat(user, "<span class='notice'>System on standby.</span>")
	to_chat(user, "<span class='danger'>System Integrity: [round((health/maxhealth)*100,1)]%</span>")

/obj/machinery/dominator/process()
	..()
	var/datum/game_mode/gang/mode = SSticker.mode
	if(gang && (isnum(mode.A_timer) || isnum(mode.B_timer)))
		if(((gang == "A") && mode.A_timer) || ((gang == "B") && mode.B_timer))
			playsound(src, 'sound/items/timer.ogg', VOL_EFFECTS_MASTER, 30, FALSE)
	else
		return PROCESS_KILL

/obj/machinery/dominator/proc/healthcheck(damage)
	var/iconname = "dominator"
	if(gang)
		iconname += "-[gang]"
		set_light(3)

	var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread

	health -= damage

	if(health > (maxhealth/2))
		if(prob(damage*2))
			sparks.set_up(5, 1, src)
			sparks.start()
	else
		sparks.set_up(5, 1, src)
		sparks.start()
		iconname += "-damaged"

	if(operating != -1)
		if(health <= 0)
			set_broken()
		else
			icon_state = iconname

	if(health <= -100)
		new /obj/item/stack/sheet/plasteel(loc)
		qdel(src)

/obj/machinery/dominator/proc/set_broken()
	var/datum/game_mode/gang/mode = SSticker.mode
	if(gang == "A")
		mode.A_timer = "OFFLINE"
	if(gang == "B")
		mode.B_timer = "OFFLINE"
	if(gang)
		//SSshuttle.emergencyNoEscape = 0
		//if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
		//SSshuttle.location!=0
		if(!isnum(mode.A_timer) && !isnum(mode.B_timer))

			//if(SSshuttle.direction == 1)
			//	SSshuttle.settimeleft(0)
				//SSshuttle.emergency.mode = SHUTTLE_DOCKED
				//SSshuttle.emergency.timer = world.time
				//priority_announce("Hostile enviroment resolved. You have 3 minutes to board the Emergency Shuttle.", null,, "Priority")
				//captain_announce("Hostile enviroment resolved. You have 3 minutes to board the Emergency Shuttle.")
			//else
				//priority_announce("All hostile activity within station systems have ceased.","Network Alert")
				//captain_announce("All hostile activity within station systems have ceased.")
			if(get_security_level() == "delta")
				set_security_level("red")

		SSticker.mode.message_gangtools(((gang=="A") ? SSticker.mode.A_tools : SSticker.mode.B_tools),"Hostile takeover cancelled: Dominator is no longer operational.",1,1)

	set_light(0)
	icon_state = "dominator-broken"
	operating = -1
	STOP_PROCESSING(SSmachines, src)

/obj/machinery/dominator/Destroy()
	if(!(stat & BROKEN))
		set_broken()
	poi_list -= src
	return ..()

/obj/machinery/dominator/emp_act(severity)
	healthcheck(100)
	..()

/obj/machinery/dominator/ex_act(severity, target)
	if(target == src)
		qdel(src)
		return
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			healthcheck(120)
		if(3.0)
			healthcheck(30)
	return

/obj/machinery/dominator/bullet_act(obj/item/projectile/Proj)
	if(Proj.damage)
		if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
			var/damage = Proj.damage
			//if(Proj.forcedodge)
			//	damage *= 0.5
			playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER)
			visible_message("<span class='danger'>[src] was hit by [Proj].</span>")
			healthcheck(damage)
	..()

/obj/machinery/dominator/blob_act()
	healthcheck(110)

/obj/machinery/dominator/attackby(I, user, params)
	return

/obj/machinery/dominator/attack_hand(mob/user)
	if(..())
		return

	if(operating)
		user.examinate(src)
		return

	var/datum/game_mode/gang/mode = SSticker.mode
	var/gang_territory
	var/timer

	var/tempgang
	if(user.mind in (SSticker.mode.A_gang|SSticker.mode.A_bosses))
		tempgang = "A"
		gang_territory = SSticker.mode.A_territory.len
		timer = mode.A_timer
	else if(user.mind in (SSticker.mode.B_gang|SSticker.mode.B_bosses))
		tempgang = "B"
		gang_territory = SSticker.mode.B_territory.len
		timer = mode.B_timer

	if(!tempgang)
		user.examinate(src)
		return

	if(isnum(timer))
		to_chat(user, "<span class='warning'>Error: Hostile Takeover is already in progress.</span>")
		return

	if(tempgang == "A" ? !mode.A_dominations : !mode.B_dominations)
		to_chat(user, "<span class='warning'>Error: Unable to breach station network. Firewall has logged our signature and is blocking all further attempts.</span>")
		return

	var/time = max(300,900 - ((round((gang_territory/start_state.num_territories)*200, 1) - 60) * 15))
	if(alert(user,"With [round((gang_territory/start_state.num_territories)*100, 1)]% station control, a takeover will require [time] seconds.\nYour gang will be unable to gain influence while it is active.\nThe entire station will likely be alerted to it once it starts.\nYou have [tempgang == "A" ? mode.A_dominations : mode.B_dominations] attempt(s) remaining. Are you ready?","Confirm","Ready","Later") == "Ready")
		if ((!in_range(src, user) || !istype(src.loc, /turf)))
			return 0
		gang = tempgang
		if(gang == "A")
			mode.A_dominations --
		else
			mode.B_dominations --
		mode.domination(gang,1,src)
		src.name = "[gang_name(gang)] Gang [src.name]"
		healthcheck(0)
		operating = 1
		SSticker.mode.message_gangtools(((gang=="A") ? SSticker.mode.A_tools : SSticker.mode.B_tools),"Hostile takeover in progress: Estimated [time] seconds until victory.")
		START_PROCESSING(SSmachines, src)

/obj/machinery/dominator/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER)
	user.visible_message("<span class='danger'>[user] smashes against [src] with its claws.</span>",\
	"<span class='danger'>You smash against [src] with your claws.</span>",\
	"<span class='italics'>You hear metal scraping.</span>")
	healthcheck(15)

/obj/machinery/dominator/attack_animal(mob/living/simple_animal/attacker)
	..()
	if(attacker.melee_damage > 0)
		healthcheck(attacker.melee_damage)

//obj/machinery/dominator/mech_melee_attack(obj/mecha/M)
//	if(M.damtype == "brute")
//		playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER)
//		visible_message("<span class='danger'>[M.name] has hit [src].</span>")
//		healthcheck(M.force)
//	return

//obj/machinery/dominator/attack_hulk(mob/user)
//	playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER)
//	user.visible_message("<span class='danger'>[user] smashes [src].</span>",\
//	"<span class='danger'>You punch [src].</span>",\
//	"<span class='italics'>You hear metal being slammed.</span>")
//	healthcheck(5)

/obj/machinery/dominator/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	playsound(src, 'sound/weapons/smash.ogg', VOL_EFFECTS_MASTER)
	if(I.damtype == BURN || I.damtype == BRUTE)
		healthcheck(I.force)
