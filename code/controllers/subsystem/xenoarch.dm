SUBSYSTEM_DEF(xenoarch)
	name = "Xenoarch"

	init_order = SS_INIT_XENOARCH

	flags = SS_NO_FIRE

	var/const/XENOARCH_SPAWN_CHANCE  = 10 // %
	var/const/DIGSITESIZE_LOWER      = 5
	var/const/DIGSITESIZE_UPPER      = 12
	var/const/ARTIFACTSPAWNNUM_LOWER = 6
	var/const/ARTIFACTSPAWNNUM_UPPER = 12

	var/list/all_animal_genesequences = list()
	var/list/all_plant_genesequences  = list()
	var/list/turfs_with_artifacts     = list()
	var/list/turfs_with_digsites      = list()

	var/list/spawn_types_animal = list(
		/mob/living/carbon/slime,
		/mob/living/simple_animal/hostile/xenomorph,
		/mob/living/simple_animal/hostile/xenomorph/drone,
		/mob/living/simple_animal/hostile/xenomorph/sentinel,
		/mob/living/simple_animal/hostile/giant_spider,
		/mob/living/simple_animal/hostile/giant_spider/hunter,
		/mob/living/simple_animal/hostile/giant_spider/nurse,
		/mob/living/simple_animal/hostile/creature,
		/mob/living/simple_animal/hostile/samak,
		/mob/living/simple_animal/hostile/diyaab,
		/mob/living/simple_animal/hostile/shantak,
		/mob/living/simple_animal/tindalos,
		/mob/living/simple_animal/yithian
	)

	var/list/spawn_types_plant = list(
		/obj/item/seeds/walkingmushroommycelium,
		/obj/item/seeds/killertomatoseed,
		/obj/item/seeds/shandseed,
		/obj/item/seeds/mtearseed,
		/obj/item/seeds/thaadra,
		/obj/item/seeds/telriis,
		/obj/item/seeds/jurlmah,
		/obj/item/seeds/amauri,
		/obj/item/seeds/gelthi,
		/obj/item/seeds/vale,
		/obj/item/seeds/surik,
		/obj/item/seeds/blackberry
	)

/datum/controller/subsystem/xenoarch/Initialize(timeofday)
	// Local lists for sonic speed.
	var/list/turfs_to_process        = list()
	var/list/artifact_spawning_turfs = list()
	var/list/digsite_spawning_turfs  = list()

	var/asteroid_zlevel = SSmapping.level_by_trait(ZTRAIT_MINING)
	if(!asteroid_zlevel)
		return

	for(var/turf/simulated/mineral/M in block(locate(1, 1, asteroid_zlevel), locate(world.maxx, world.maxy, asteroid_zlevel)))
		if(!prob(XENOARCH_SPAWN_CHANCE))
			continue

		var/list/visable_adjacent_turfs = list()
		for(var/turf/simulated/mineral/T in orange(1, M))
			if(T.finds)
				continue
			if(T in turfs_to_process)
				continue
			visable_adjacent_turfs += T

		var/target_digsite_size = rand(DIGSITESIZE_LOWER, DIGSITESIZE_UPPER)
		for(var/turf/simulated/mineral/T in visable_adjacent_turfs)
			if(prob(target_digsite_size / visable_adjacent_turfs.len))
				turfs_to_process += T
				target_digsite_size--

			if(!target_digsite_size)
				break


	while(turfs_to_process.len)
		var/turf/simulated/mineral/archeo_turf = turfs_to_process[turfs_to_process.len]
		turfs_to_process.len--

		var/digsite = get_random_digsite_type()

		if(isnull(archeo_turf.finds))
			archeo_turf.finds = list()
			if(prob(50))
				archeo_turf.finds += new /datum/find(digsite, rand(5,95))
				digsite_spawning_turfs += archeo_turf
			else if(prob(75))
				archeo_turf.finds += new /datum/find(digsite, rand(5,45))
				archeo_turf.finds += new /datum/find(digsite, rand(55,95))
			else
				archeo_turf.finds += new /datum/find(digsite, rand(5,30))
				archeo_turf.finds += new /datum/find(digsite, rand(35,75))
				archeo_turf.finds += new /datum/find(digsite, rand(75,95))

			// Sometimes a find will be close enough to the surface to show
			var/datum/find/F = archeo_turf.finds[1]
			if(F.excavation_required <= F.view_range)
				archeo_turf.archaeo_overlay = "overlay_archaeo[rand(1,3)]"
				archeo_turf.add_overlay(archeo_turf.archaeo_overlay)

		// Have a chance for an artifact to spawn here, but not in animal or plant digsites
		if(isnull(archeo_turf.artifact_find) && digsite != 1 && digsite != 2)
			artifact_spawning_turfs += archeo_turf

	// Create artifact machinery
	var/num_artifacts_spawn = rand(ARTIFACTSPAWNNUM_LOWER, ARTIFACTSPAWNNUM_UPPER)
	while(artifact_spawning_turfs.len > num_artifacts_spawn)
		pick_n_take(artifact_spawning_turfs)

	for(var/turf/simulated/mineral/artifact_turf in artifact_spawning_turfs)
		artifact_turf.artifact_find = new

	// Ref digsites and artifacts list to subsystem to be able to view it.
	turfs_with_artifacts = artifact_spawning_turfs
	turfs_with_digsites  = digsite_spawning_turfs

	// Make sure we have some prefixes for the gene sequences
	var/list/genome_prefixes = alphabet_uppercase.Copy()

	// Create animal gene sequences
	while(spawn_types_animal.len && genome_prefixes.len)
		var/datum/genesequence/new_sequence = new
		new_sequence.spawned_type = pick_n_take(spawn_types_animal)

		var/prefixletter = pick_n_take(genome_prefixes)
		while(new_sequence.full_genome_sequence.len < 5)
			new_sequence.full_genome_sequence.Add("[prefixletter][pick(alphabet_uppercase)][pick(alphabet_uppercase)][rand(0, 9)][rand(0, 9)]")

		all_animal_genesequences += new_sequence

	// Make sure we have some prefixes for the gene sequences
	genome_prefixes = alphabet_uppercase.Copy()

	//create plant gene sequences
	while(spawn_types_plant.len && genome_prefixes.len)
		var/datum/genesequence/new_sequence = new
		new_sequence.spawned_type = pick_n_take(spawn_types_plant)

		var/prefixletter = pick_n_take(genome_prefixes)
		while(new_sequence.full_genome_sequence.len < 5)
			new_sequence.full_genome_sequence.Add("[prefixletter][rand(0, 9)][rand(0, 9)][pick(alphabet_uppercase)][pick(alphabet_uppercase)]")

		all_plant_genesequences += new_sequence

	..()

/datum/controller/subsystem/xenoarch/Recover()
	flags |= SS_NO_INIT