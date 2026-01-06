
/datum/spawner/instagib
	name = "Forsaken Sinner"
	desc = "Искупите свои грехи."

	spawn_landmark_name = "Sinner Spawn"
	lobby_spawner = TRUE
	positions = INFINITY

	var/datum/map_module/instagib/map_module
	var/list/sinner_outfits

/datum/spawner/instagib/New(datum/map_module/instagib/MM)
	. = ..()
	map_module = MM
	sinner_outfits = subtypesof(/datum/outfit/instagib)

/datum/spawner/instagib/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()
	var/client/C = spectator.client
	var/mob/living/carbon/human/H = new(spawnloc)
	H.key = C.key
	H.real_name = C.key
	H.name = C.key

	map_module.assign_to_faction(H)
	H.equipOutfit(pick(sinner_outfits))
	H.makeSkeleton()
	H.revive()
	H.regenerate_icons()
	H.put_in_hands(new /obj/item/weapon/gun/energy/laser/devil_dagger)
