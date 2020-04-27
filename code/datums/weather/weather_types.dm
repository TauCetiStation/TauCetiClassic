//Different types of weather.

/datum/weather/floor_is_lava //The Floor is Lava: Makes all turfs damage anyone on them unless they're standing on a solid object.
	name = "the floor is lava"
	desc = "The ground turns into surprisingly cool lava, lightly damaging anything on the floor."

	telegraph_message = "<span class='warning'>Waves of heat emanate from the ground...</span>"
	telegraph_duration = 150

	weather_message = "<span class='userdanger'>The floor is lava! Get on top of something!</span>"
	weather_duration_lower = 300
	weather_duration_upper = 600
	weather_overlay = "lava"

	end_message = "<span class='danger'>The ground cools and returns to its usual form.</span>"
	end_duration = 0

	area_type = /area
	protected_areas = list(/area/space)
	target_ztrait = ZTRAIT_STATION

	overlay_layer = 2.1 //Covers floors only
	immunity_type = "lava"

/datum/weather/floor_is_lava/impact(mob/living/L)
	for(var/obj/structure/O in L.loc)
		if(O.density)
			return
	if(L.loc.density)
		return
	if(!L.client) //Only sentient people are going along with it!
		return
	L.adjustFireLoss(3)





/datum/weather/advanced_darkness //Advanced Darkness: Restricts the vision of all affected mobs to a single tile in the cardinal directions.
	name = "advanced darkness"
	desc = "Everything in the area is effectively blinded, unable to see more than a foot or so around itself."

	telegraph_message = "<span class='warning'>The lights begin to dim... is the power going out?</span>"
	telegraph_duration = 150

	weather_message = "<span class='userdanger'>This isn't your average everday darkness... this is <i>advanced</i> darkness!</span>"
	weather_duration_lower = 300
	weather_duration_upper = 300
	overlay_layer = 10
	end_message = "<span class='danger'>At last, the darkness recedes.</span>"
	end_duration = 0

	area_type = /area
	target_ztrait = ZTRAIT_STATION

/datum/weather/advanced_darkness/update_areas()
	for(var/V in impacted_areas)
		var/area/A = V
		if(stage == MAIN_STAGE)
			A.invisibility = 0
			A.set_opacity(TRUE)
			A.layer = overlay_layer
			A.icon = 'icons/effects/weather_effects.dmi'
			A.icon_state = "darkness"
		else
			A.invisibility = INVISIBILITY_MAXIMUM
			A.set_opacity(FALSE)


/datum/weather/scrap_storm //Ash Storms: Common happenings on lavaland. Heavily obscures vision and deals heavy fire damage to anyone caught outside.
	name = "scrap storm"
	desc = "An intense atmospheric storm lifts ash off of the planet's surface and billows it down across the area, dealing intense fire damage to the unprotected."

	telegraph_message = "<span class='boldwarning'>An eerie moan rises on the wind. Sheets of sand blacken the horizon. Seek shelter.</span>"
	telegraph_duration = 300
	telegraph_sound = 'sound/ambience/specific/ash_storm_windup.ogg'
	telegraph_overlay = "light_ash"

	weather_message = "<span class='userdanger'><i>Smoldering clouds of scorching trash billow down around you! Get inside!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_sound = 'sound/ambience/specific/ash_storm_start.ogg'
	weather_overlay = "ash_storm"
	weather_alpha = 170
	overlay_layer = 10
	end_message = "<span class='boldannounce'>The shrieking wind whips away the last of the ash and falls to its usual murmur. It should be safe to go outside now.</span>"
	end_duration = 300
	end_sound = 'sound/ambience/specific/ash_storm_end.ogg'
	end_overlay = "light_ash"
	area_type = /area/awaymission/junkyard
	target_ztrait = ZTRAIT_JUNKYARD

	immunity_type = "ash"
	var/spawn_tornadoes = 1
	var/list/tornados = list()
	probability = 10

/datum/weather/scrap_storm/proc/is_scrap_immune(mob/living/L)
	if(istype(L.loc, /obj/mecha)) //Mechs are immune
		return TRUE
	if(istype(L.loc, /mob/living) && L.loc != L) //Matryoshka check
		return is_scrap_immune(L.loc)
	return FALSE //RIP you

/datum/weather/scrap_storm/start()
	..()
	if(spawn_tornadoes)
		var/area/A = locate(area_type)
		for(var/obj/item/weapon/scrap_lump/C in A)
			qdel(C)
		var/list/turfs = get_area_turfs(area_type)
		for(var/i = 1 to 4)
			var/turf/wheretospawn = pick(turfs)
			if(!wheretospawn.density)
				var/obj/singularity/scrap_ball/new_tornado = new /obj/singularity/scrap_ball(wheretospawn)
				tornados += new_tornado

/datum/weather/scrap_storm/end()
	for(var/obj/singularity/scrap_ball/del_tornado in tornados)
		qdel(del_tornado)
	..()

/datum/weather/scrap_storm/impact(mob/living/L)
	if(is_scrap_immune(L))
		return
	L.take_overall_damage(1, 0)
	L.apply_effect(1.5,AGONY,0)

/datum/weather/scrap_storm/emberfall //Emberfall: An ash storm passes by, resulting in harmless embers falling like snow. 10% to happen in place of an ash storm.
	name = "emberfall"
	desc = "A passing ash storm blankets the area in harmless embers."

	weather_message = "<span class='notice'>Gentle embers waft down around you like grotesque snow. The storm seems to have passed you by...</span>"
	weather_sound = 'sound/ambience/specific/ash_storm_windup.ogg'
	weather_overlay = "light_ash"

	end_message = "<span class='notice'>The emberfall slows, stops. Another layer of hardened soot to the ground beneath your feet.</span>"
	weather_alpha = 250
	aesthetic = TRUE
	spawn_tornadoes = 0
	probability = 60

/datum/weather/rad_storm
	name = "radiation storm"
	desc = "A cloud of intense radiation passes through the area dealing rad damage to those who are unprotected."

	telegraph_duration = 400
	telegraph_message = "<span class='danger'>The air begins to grow warm.</span>"

	weather_message = "<span class='userdanger'><i>You feel waves of heat wash over you! Find shelter!</i></span>"
	weather_overlay = "ash_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_color = "green"
	weather_overlay = "ash_storm"
	weather_alpha = 40
	overlay_layer = 2.1
	end_duration = 100
	end_message = "<span class='notice'>The air seems to be cooling off again.</span>"

	area_type = /area
	protected_areas = list(/area/station/maintenance, /area/station/civilian/dormitories/male, /area/station/civilian/dormitories/female, /area/station/storage/emergency, /area/station/storage/emergency2, /area/station/storage/emergency3, /area/station/storage/tech)
	target_ztrait = ZTRAIT_STATION

	immunity_type = "rad"

/datum/weather/rad_storm/telegraph()
	..()
	status_alarm("alert")


/datum/weather/rad_storm/impact(mob/living/L)
	var/resist = L.getarmor(null, "rad")
	if(prob(40))
		if(ishuman(L))
			var/mob/living/carbon/human/H = L

			if(HULK in H.mutations)
				H.try_mutate_to_hulk()

			if(H.dna && H.dna.species && !H.species.flags[IS_SYNTHETIC])
				if(prob(max(0,100-resist)) && prob(10))
					if (prob(75))
						randmutb(H) // Applies bad mutation
					else
						randmutg(H) // Applies good mutation
					domutcheck(H,null,MUTCHK_FORCED)
		L.apply_effect((rand(40,70)),IRRADIATE,0)

/datum/weather/rad_storm/end()
	if(..())
		return
	command_alert("The station has passed the radiation belt. Please report to medbay if you experience any unusual symptoms. Maintenance will lose all access again shortly.", "Anomaly Alert", "radpassed")
	if(timer_maint_revoke_id)
		deltimer(timer_maint_revoke_id)
		timer_maint_revoke_id = 0
	timer_maint_revoke_id = addtimer(CALLBACK(GLOBAL_PROC, .proc/revoke_maint_all_access, FALSE), 600, TIMER_UNIQUE|TIMER_STOPPABLE) // Want to give them time to get out of maintenance.


/datum/weather/rad_storm/proc/status_alarm(command)	//Makes the status displays show the radiation warning for those who missed the announcement.
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency)
		return

	var/datum/signal/status_signal = new
	var/obj/item/device/radio/intercom/a = new /obj/item/device/radio/intercom(null)
	status_signal.source = a
	status_signal.transmission_method = 1
	status_signal.data["command"] = "shuttle"

	if(command == "alert")
		status_signal.data["command"] = "alert"
		status_signal.data["picture_state"] = "radiation"

	frequency.post_signal(src, status_signal)


/datum/weather/acid_rain
	name = "acid rain"
	desc = "Some stay dry and others feel the pain"

	telegraph_duration = 400
	telegraph_message = "<span class='danger'>Stinging droplets start to fall upon you..</span>"
	telegraph_sound = 'sound/ambience/specific/acidrain_start.ogg'

	weather_message = "<span class='userdanger'><i>Your skin melts underneath the rain!</i></span>"
	weather_overlay = "acid_rain"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_sound = 'sound/ambience/specific/acidrain_mid.ogg'
	overlay_layer = 10
	end_duration = 100
	weather_alpha = 60
	end_message = "<span class='notice'>The rain starts to dissipate.</span>"
	end_sound = 'sound/ambience/specific/acidrain_end.ogg'
	additional_action = TRUE
	area_type = /area/awaymission/junkyard
	target_ztrait = ZTRAIT_JUNKYARD

	immunity_type = "acid" // temp

	probability = 30


/datum/weather/acid_rain/impact(mob/living/L)
	if(!istype(/turf, L.loc))
		return
	L.water_act(5)
	if(!prob(L.getarmor(null, "bio")))
		L.take_overall_damage(0, 1)

/datum/weather/acid_rain/additional_action() //Proc for other actions?
	if(prob(15))
		var/list/turfs = get_area_turfs(area_type)
		for(var/i = 1 to turfs.len / 400)
			var/turf/wheretospawn = pick(turfs)
			if(wheretospawn.density)
				continue
			var/obj/effect/fluid/F = locate() in wheretospawn
			if(!F)
				F = new(wheretospawn)
				F.set_depth(5)

