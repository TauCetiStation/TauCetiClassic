/obj/structure/cult
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/cult.dmi'
	var/can_unwrench = TRUE
	var/health = 3000

/obj/structure/cult/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	playsound(src, 'sound/effects/hit_statue.ogg', VOL_EFFECTS_MASTER)
	healthcheck()
	return PROJECTILE_ACTED

/obj/structure/cult/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W) && can_unwrench)
		to_chat(user, "<span class='notice'>You begin [anchored ? "unwrenching" : "wrenching"] the [src].</span>")
		if(W.use_tool(src, user, 20, volume = 50))
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
		return FALSE

	. = ..()
	if(!.)
		return FALSE

	if(length(W.hitsound))
		playsound(src, pick(W.hitsound), VOL_EFFECTS_MASTER)
	else
		playsound(src, 'sound/effects/hit_statue.ogg', VOL_EFFECTS_MASTER)

	health -= W.force
	healthcheck()

/obj/structure/cult/attack_hand(mob/living/carbon/human/user)
	user.SetNextMove(CLICK_CD_MELEE)
	user.visible_message("<span class='userdanger'>[user] kicks [src] unsuccessfully.</span>", "<span class='userdanger'>You feel pain of hitting [src] hard with your fist.</span>")
	var/obj/item/organ/external/BP = user.bodyparts_by_name[user.hand ? BP_L_ARM : BP_R_ARM]
	BP.take_damage(3, 0, 0, "stone")
	playsound(src, 'sound/effects/hit_statue.ogg', VOL_EFFECTS_MASTER)

/obj/structure/cult/attack_animal(mob/living/simple_animal/user)
	. = ..()
	health -= user.melee_damage
	playsound(src, 'sound/effects/hit_statue.ogg', VOL_EFFECTS_MASTER)
	healthcheck()

/obj/structure/cult/attack_paw(mob/living/user)
	if(ishuman(user))
		return attack_hand(user)
	user.SetNextMove(CLICK_CD_MELEE)
	playsound(src, 'sound/effects/hit_statue.ogg', VOL_EFFECTS_MASTER)

/obj/structure/cult/proc/healthcheck()
	if(health <= 0)
		qdel(src)

/obj/structure/cult/tome
	name = "desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	light_color = "#cc9338"
	light_power = 2
	light_range = 3

/obj/structure/cult/pylon
	name = "pylon"
	desc = "A floating crystal that hums with an unearthly energy."
	icon_state = "pylon"
	light_color = "#ff9595"
	light_power = 2
	light_range = 6
	pass_flags = PASSTABLE
	health = 200

/obj/structure/cult/pylon/Destroy()
	new /obj/structure/cult/pylon_platform(loc)
	new /obj/item/stack/sheet/metal(loc)
	return ..()

/obj/structure/cult/pylon/proc/activate(time_to_stop, datum/religion/R)
	var/mob/living/simple_animal/hostile/pylon/charged = new(loc)
	charged.maxHealth = health
	charged.health = health
	forceMove(charged)

	if(time_to_stop)
		charged.timer = addtimer(CALLBACK(charged, /mob/living/simple_animal/hostile/pylon.proc/deactivate), time_to_stop, TIMER_STOPPABLE)

	if(R)
		charged.RegisterSignal(R, COMSIG_REL_ADD_MEMBER,  /mob/living/simple_animal/hostile/pylon.proc/add_friend)
	return charged

/obj/structure/cult/pylon_platform
	name = "pylon platform"
	desc = "Useless."
	icon_state = "pylon_platform"
	health = 50
	density = FALSE

// For operations
/obj/machinery/optable/torture_table
	name = "torture table"
	desc = "For tortures"
	icon = 'icons/obj/cult.dmi'
	icon_state = "table2-idle"
	can_buckle = TRUE
	buckle_lying = TRUE

	var/datum/religion/cult/religion
	var/charged = FALSE

	var/image/belt
	var/belt_icon = 'icons/obj/cult.dmi'
	var/belt_icon_state = "torture_restraints"

/obj/machinery/optable/torture_table/atom_init()
	. = ..()
	belt = image(belt_icon, belt_icon_state, layer = FLY_LAYER)

/obj/machinery/optable/torture_table/Destroy()
	religion?.torture_tables -= src
	return ..()

/obj/machinery/optable/torture_table/attackby(obj/item/W, mob/user, params)
	if(!charged && istype(W, /obj/item/weapon/storage/bible/tome))
		var/obj/item/weapon/storage/bible/tome/T = W
		if(T.religion && istype(T.religion, /datum/religion/cult))
			var/datum/religion/cult/C = T.religion
			C.torture_tables += src
			religion = C
			name = "charged [initial(name)]"
			add_filter("torture_outline", 2, outline_filter(1, "#990066"))
			charged = TRUE
			new /obj/effect/temp_visual/cult/sparks(loc)
			return FALSE

	if(iswrench(W))
		to_chat(user, "<span class='notice'>You begin [anchored ? "unwrenching" : "wrenching"] the [src].</span>")
		if(W.use_tool(src, user, 20, volume = 50))
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
		return FALSE

	return ..()

/obj/machinery/optable/torture_table/MouseDrop_T(atom/A, mob/user)
	if(A.loc == loc)
		if(can_buckle && !buckled_mob)
			user_buckle_mob(A, user)
	else
		return ..()

/obj/machinery/optable/torture_table/buckle_mob(mob/living/M, mob/user)
	..()
	if(M.pixel_x != 0)
		M.pixel_x = 0
	if(M.pixel_y != -1)
		M.pixel_y = -1
	if(M.dir & (EAST|WEST|NORTH))
		M.dir = SOUTH
	add_overlay(belt)

/obj/machinery/optable/torture_table/unbuckle_mob(mob/user)
	..()
	cut_overlay(belt)

/obj/machinery/optable/torture_table/attack_hand(mob/living/user)
	if(user == buckled_mob)
		user.resist()
	else
		if(can_buckle && buckled_mob && istype(user))
			user_unbuckle_mob(user)

/obj/structure/mineral_door/cult
	name = "door"
	icon_state = "cult"
	health = 300
	sheetAmount = 2
	sheetType = /obj/item/stack/sheet/metal
	light_color = "#990000"
	light_range = 2
	can_unwrench = FALSE

/obj/structure/mineral_door/cult/MobChecks(mob/user)
	if(!..())
		return FALSE

	if(!user.my_religion)
		return FALSE

	return TRUE

/obj/structure/mineral_door/cult/MechChecks(obj/mecha/user)
	if(!..())
		return FALSE

	if(!user.occupant.my_religion)
		return FALSE

	return TRUE

/obj/structure/cult/portal_to_station
	name = "портал в прошлое"
	desc = "Портал псионически транслирует тебе в разум: \"Войди. Попадёшь обратно. Случайно.\"."
	icon = 'icons/obj/cult.dmi'
	icon_state = "portal"
	light_color = "#ff69b4"
	layer = INFRONT_MOB_LAYER

	can_unwrench = FALSE

/obj/structure/cult/portal_to_station/Bumped(atom/A)
	var/area/area = findEventArea()
	var/turf/target = get_turf(pick(get_area_turfs(area.type, FALSE)))
	if(ismob(A))
		var/mob/user = A
		playsound(user, 'sound/magic/Teleport_diss.ogg', VOL_EFFECTS_MASTER)
		new /obj/effect/temp_visual/cult/blood/out(user.loc)
		playsound(user, 'sound/magic/Teleport_app.ogg', VOL_EFFECTS_MASTER)
		new /obj/effect/temp_visual/cult/blood(target)
		var/list/companions = handle_teleport_grab(target, user, FALSE)
		LAZYINITLIST(companions)
		user.forceMove(target)
		user.eject_from_wall(TRUE, companions = companions)
		for(var/mob/M in companions + user)
			if(M.client)
				new /atom/movable/screen/temp/cult_teleportation(M, M)
			if(ishuman(M))
				var/mob/living/carbon/human/H = user
				H.Paralyse(5)

	else if(isitem(A))
		var/obj/item/I = A
		I.forceMove(target)

// Just trash
/obj/structure/cult/anomaly
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

/obj/structure/cult/anomaly/attackby(obj/item/weapon/W, mob/user)
	return FALSE

/obj/structure/cult/anomaly/attack_animal(mob/living/simple_animal/user)
	if(iscultist(user))
		destroying(user.my_religion)

/obj/structure/cult/anomaly/proc/async_destroying(datum/religion/cult/C)
	animate(src, 1 SECONDS, alpha = 0)
	sleep(1 SECONDS)
	qdel(src)

	C.adjust_favor(rand(1, 5))
	// statistics!
	score["destranomaly"]++

/obj/structure/cult/anomaly/proc/destroying(datum/religion/cult/C)
	INVOKE_ASYNC(src, .proc/async_destroying, C)

/obj/structure/cult/anomaly/spacewhole
	name = "abyss in space"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "space"

/obj/structure/cult/anomaly/timewhole
	name = "abyss in time"
	desc = "You feel a billion different looks when you gaze into emptiness."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = TRUE
	unacidable = 1
	anchored = TRUE
	light_color = "#550314"
	light_power = 30
	light_range = 3

/obj/structure/cult/anomaly/orb
	name = "orb"
	desc = "Strange circle."
	icon = 'icons/obj/cult.dmi'
	icon_state = "summoning_orb"

/obj/structure/cult/anomaly/shell
	name = "cursed shell"
	desc = "It looks at you."
	icon_state = "shuttlecurse"
	light_color = "#6d1616"
	light_power = 2
	light_range = 2
