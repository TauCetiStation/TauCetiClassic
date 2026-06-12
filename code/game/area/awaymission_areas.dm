 ////////////////
 //AWAY MISSION//
 ////////////////

//Away Missions
/area/awaymission
	name = "Strange Location"
	icon_state = "away"
	dynamic_lighting = TRUE

//Example map
/area/awaymission/example
	name = "Strange Station"

//Wild West
/area/awaymission/wildwest/mines
	name = "Wild West Mines"
	icon_state = "away1"
	requires_power = 0

/area/awaymission/wildwest/mansion
	name = "Wild West Mansion"
	icon_state = "away2"
	requires_power = 0

/area/awaymission/wildwest/refinery
	name = "Wild West Refinery"
	icon_state = "away3"
	requires_power = 0

/area/awaymission/wildwest/vault
	name = "Wild West Vault"
	icon_state = "away3"

/area/awaymission/wildwest/vaultdoors
	name = "Wild West Vault Doors"  // this is to keep the vault area being entirely lit because of requires_power
	icon_state = "away2"
	requires_power = 0

//Junkyard
/area/awaymission/junkyard
	name = "Junkyard"
	icon_state = "away"
	always_unpowered = 1
	outdoors = TRUE
	var/list/mob_spawn_list = list(
		/mob/living/simple_animal/tindalos = 5,
		/mob/living/simple_animal/lizard = 4,
		/mob/living/simple_animal/mouse = 1,
		/mob/living/simple_animal/yithian = 3,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 2
	)

/area/awaymission/junkyard/medium
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath = 3,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 3,
		/mob/living/simple_animal/hostile/asteroid/hivelord = 3,
		/mob/living/simple_animal/hostile/retaliate/malf_drone/mining = 1,
	)

/area/awaymission/junkyard/hard
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/giant_spider/hunter = 1,
		/mob/living/simple_animal/hostile/giant_spider = 1
	)

/area/awaymission/junkyard/atom_init()
	. = ..()
	AddComponent(/datum/component/spawn_area,
		"junkyard",
		CALLBACK(src, PROC_REF(Spawn)),
		CALLBACK(src, PROC_REF(Despawn)),
		CALLBACK(src, PROC_REF(CheckSpawn)),
		8,
		16,
		10 SECONDS,
		1 MINUTE,
	)

/area/awaymission/junkyard/proc/Spawn(turf/T)
	var/to_spawn = pickweight(mob_spawn_list)
	var/atom/A = new to_spawn(T)
	if(A)
		return list(A)
	return null

/area/awaymission/junkyard/proc/Despawn(atom/movable/instance)
	var/mob/M = instance
	if(M.stat == DEAD)
		return
	qdel(M)

/area/awaymission/junkyard/proc/CheckSpawn(turf/T)
	if(!istype(T, /turf/simulated/floor/plating/ironsand/junkyard))
		return FALSE
	return T.is_mob_placeable(null)

/area/awaymission/BMPship1
	name = "Aft Block"
	icon_state = "away1"

/area/awaymission/BMPship2
	name = "Midship Block"
	icon_state = "away2"

/area/awaymission/BMPship3
	name = "Fore Block"
	icon_state = "away3"

/area/awaymission/spacebattle
	name = "Space Battle"
	icon_state = "away"
	requires_power = 0

/area/awaymission/spacebattle/cruiser
	name = "Nanotrasen Cruiser"

/area/awaymission/spacebattle/syndicate1
	name = "Syndicate Assault Ship 1"

/area/awaymission/spacebattle/syndicate2
	name = "Syndicate Assault Ship 2"

/area/awaymission/spacebattle/syndicate3
	name = "Syndicate Assault Ship 3"

/area/awaymission/spacebattle/syndicate4
	name = "Syndicate War Sphere 1"

/area/awaymission/spacebattle/syndicate5
	name = "Syndicate War Sphere 2"

/area/awaymission/spacebattle/syndicate6
	name = "Syndicate War Sphere 3"

/area/awaymission/spacebattle/syndicate7
	name = "Syndicate Fighter"

/area/awaymission/spacebattle/secret
	name = "Hidden Chamber"

//Labs
/area/awaymission/labs/desert
	name = "Mars"
	icon_state = "away"

/area/awaymission/labs/gateway
	name = "Labs Gateway"
	icon_state = "teleporter"

/area/awaymission/labs/militarydivision
	name = "Military Division"
	icon_state = "Tactical"

/area/awaymission/labs/researchdivision
	name = "Labs RnD"
	icon_state = "research"

/area/awaymission/labs/cave
	name = "Labs cave"
	icon_state = "mining"

/area/awaymission/labs/solars
	name = "Labs solars"
	icon_state = "panelsA"

/area/awaymission/labs/command
	name = "labs command"
	icon_state = "bridge"

/area/awaymission/labs/cargo
	name = "Labs cargo"
	icon_state = "quartstorage"

/area/awaymission/labs/civilian
	name = "Labs civilian"
	icon_state = "cafeteria"

/area/awaymission/labs/security
	name = "Labs security"
	icon_state = "security"

/area/awaymission/labs/medical
	name = "Labs medical"
	icon_state = "medbay"

//Listening Post
/area/awaymission/listeningpost
	name = "Listening Post"
	icon_state = "away"
	requires_power = 0

//Beach
/area/awaymission/beach
	name = "Beach"
	icon_state = "null"
	dynamic_lighting = FALSE
	requires_power = 0
