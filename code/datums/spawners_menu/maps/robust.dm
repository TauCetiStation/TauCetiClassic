/datum/spawner/robust
	name = "Robust Visitor"
	desc = "Добро пожаловать на внегалактический Робаст Турнир!"

	lobby_spawner = TRUE
	positions = INFINITY

	cooldown_type = /datum/spawner/robust
	cooldown = 1 MINUTES

	spawn_landmark_name = "Robust Visitor"

	var/outfit = /datum/outfit/job/assistant

	var/datum/map_module/robust/map_module

/datum/spawner/robust/New(datum/map_module/robust/MM)
	. = ..()
	map_module = MM

/datum/spawner/robust/pick_spawn_location()
	var/new_spawn_landmark_name = spawn_landmark_name
	if(map_module.station_size == "Big")
		new_spawn_landmark_name = spawn_landmark_name += " Big Station"
	if(!length(landmarks_list[new_spawn_landmark_name]))
		CRASH("[src.type] attempts to pick spawn location \"[new_spawn_landmark_name]\", but can't find one!")

	return pick_landmarked_location(new_spawn_landmark_name)

/datum/spawner/robust/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()

	var/client/C = spectator.client

	var/mob/living/carbon/human/H = new(spawnloc)
	H.key = C.key

	equip(H)

	C.create_human_apperance(H, H.key)

/datum/spawner/robust/proc/equip(mob/living/carbon/human/H)
	H.equipOutfit(outfit)
	H.mind.skills.add_available_skillset(/datum/skillset/max)
	H.mind.skills.maximize_active_skills()

	//give everyone cash to gamble with
	for (var/i in 1 to 8)
		var/obj/item/weapon/spacecash/c50/C = new(H.loc)
		H.equip_or_collect(C, SLOT_IN_BACKPACK)

/datum/spawner/robust/doctor
	name = "Robust Doctor"
	desc = "Лечите бойцов после матчей."
	positions = 0

	ranks = /datum/job/doctor

	spawn_landmark_name = "Robust Doctor"

	outfit = /datum/outfit/job/doctor

/datum/spawner/robust/doctor/equip(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/weapon/strangetool/robust/ST = new(H)
	H.equip_or_collect(ST, SLOT_L_HAND)

	var/obj/item/weapon/card/id/med/V = new(H)
	V.rank = "Robust Doctor"
	V.assignment = V.rank
	V.assign(H.real_name)
	V.access = list(access_medical)
	H.equip_or_collect(V, SLOT_WEAR_ID)

/datum/spawner/robust/janitor
	name = "Robust Janitor"
	desc = "Убирайте окровавленную арену после каждого боя."

	positions = 0

	ranks = /datum/job/janitor

	spawn_landmark_name = "Robust Janitor"

	outfit = /datum/outfit/job/janitor

/datum/spawner/robust/janitor/equip(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/weapon/card/id/civ/V = new(H)
	V.rank = "Robust Janitor"
	V.assignment = V.rank
	V.assign(H.real_name)
	V.access = list(access_janitor)
	H.equip_or_collect(V, SLOT_WEAR_ID)

/datum/spawner/robust/commentator
	name = "Robust Commentator"
	desc = "Комментируйте бои."

	lobby_spawner = FALSE
	positions = 0

	spawn_landmark_name = "Robust Commentator"

	outfit = /datum/outfit/job/captain

/datum/spawner/robust/commentator/equip(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/weapon/card/id/centcom/V = new(H)
	V.rank = "Robust Commentator"
	V.assignment = V.rank
	V.assign(H.real_name)
	var/datum/job/captain/J = SSjob.GetJob("Captain")
	V.access = J.get_access()
	H.equip_or_collect(V, SLOT_WEAR_ID)

/datum/spawner/robust/chef
	name = "Robust Kitchen Chef"
	desc = "Готовьте еду для голодных болельщиков в элитном ресторане."

	positions = 0

	spawn_landmark_name = "Robust Kitchen Chef"

	outfit = /datum/outfit/job/chef

/datum/spawner/robust/chef/equip(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/weapon/card/id/civ/V = new(H)
	V.rank = "Robust Chef"
	V.assignment = V.rank
	V.assign(H.real_name)
	V.access = list(access_kitchen)
	H.equip_or_collect(V, SLOT_WEAR_ID)

/datum/spawner/robust/bartender
	name = "Robust Bartender"
	desc = "Спивайте самых резвых болельщиков."

	positions = 0

	spawn_landmark_name = "Robust Bartender"

	outfit = /datum/outfit/job/bartender

/datum/spawner/robust/bartender/equip(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/weapon/card/id/civ/V = new(H)
	V.rank = "Robust Bartender"
	V.assignment = V.rank
	V.assign(H.real_name)
	V.access = list(access_bar)
	H.equip_or_collect(V, SLOT_WEAR_ID)

/datum/spawner/robust/clown
	name = "Robust Clown"
	desc = "И здесь ты?!"

	positions = 0

	spawn_landmark_name = "Robust Clown"

	outfit = /datum/outfit/job/clown

/datum/spawner/robust/clown/equip(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/weapon/card/id/clown/V = new(H)
	V.rank = "Robust Clown"
	V.assignment = V.rank
	V.assign(H.real_name)
	V.access = list(access_clown)
	H.equip_or_collect(V, SLOT_WEAR_ID)

/datum/spawner/robust/janitorborg
	name = "Robust Janitor Borg"
	desc = "Убирайте станцию быстрее и эффективнее, чем ваш кожаный коллега."

	positions = 0

	spawn_landmark_name = "Robust Janitor Borg"

/datum/spawner/robust/janitorborg/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()

	var/client/C = spectator.client

	var/mob/living/silicon/robot/R = new(spawnloc)
	R.key = C.key
	to_chat(C, "<span class='warning'>Не забудьте выбрать модуль уборщика!</span>")

/datum/spawner/robust/engineer
	name = "Robust Engineer"
	desc = "Чините станцию, меняйте лампочки."

	positions = 0

	spawn_landmark_name = "Robust Engineer"

	outfit = /datum/outfit/job/engineer

/datum/spawner/robust/engineer/equip(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/weapon/card/id/eng/V = new(H)
	V.rank = "Robust Engineer"
	V.assignment = V.rank
	V.assign(H.real_name)
	var/datum/job/captain/J = SSjob.GetJob("Captain")
	V.access = J.get_access()
	H.equip_or_collect(V, SLOT_WEAR_ID)

/datum/spawner/robust/security
	name = "Robust Security"
	desc = "Следите за порядком на станции."

	positions = 0

	spawn_landmark_name = "Robust Security"

	outfit = /datum/outfit/job/officer

/datum/spawner/robust/security/equip(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/weapon/card/id/secGold/V = new(H)
	V.rank = "Robust Security"
	V.assignment = V.rank
	V.assign(H.real_name)
	var/datum/job/captain/J = SSjob.GetJob("Captain")
	V.access = J.get_access()
	H.equip_or_collect(V, SLOT_WEAR_ID)
