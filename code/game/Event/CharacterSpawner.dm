/obj/structure/character_spawner
	name = "СТАРТ"
	desc = "Нажми на меня если закончил выбор внешности и прочитал все таблички."
	anchored = TRUE
	icon = 'icons/turf/areas.dmi'
	icon_state = "start"
	var/outfit = null
	var/ready = null
	var/area/A
	var/list/turf/possible_tile
	var/target
/obj/structure/character_spawner/attack_hand(mob/user)
	ready = tgui_alert(user, "Готовы войти в игру? Убедитесь что прочитали все подсказки и закончили выбор своей внешности.",, list("Да","Нет"))
	if(ready == "Нет")
		return
	var/mob/living/carbon/human/H = user
	for(var/obj/item/W in H)
		H.drop_from_inventory(W)
		qdel(W)
	H.equipOutfit(outfit)
	possible_tile = get_area_turfs(get_area_by_type(A))
	target = pick(possible_tile)
	H.loc = target

/obj/structure/character_spawner/peasant
	outfit = /datum/outfit/job/hub/peasant
	A =/area/custom/start_homm/peasant

/obj/structure/character_spawner/smith
	outfit = /datum/outfit/job/hub/smith
	A =/area/custom/start_homm/smith

/obj/structure/character_spawner/miner
	outfit = /datum/outfit/job/hub/miner
	A =/area/custom/start_homm/miner

/obj/structure/character_spawner/helper
	outfit = /datum/outfit/job/hub/helper
	A =/area/custom/start_homm/helper

/obj/structure/character_spawner/knight
	outfit = /datum/outfit/job/hub/knight
	A = /area/custom/start_homm/knight

/obj/structure/character_spawner/human_hero
	outfit = /datum/outfit/job/hub/human_hero
	A = /area/custom/start_homm/human_hero

/obj/structure/character_spawner/monk
	outfit = /datum/outfit/job/hub/monk
	A = /area/custom/start_homm/monk

/obj/structure/character_spawner/monk/attack_hand(mob/user)
	ready = tgui_alert(user, "Готовы войти в игру? Убедитесь что прочитали все подсказки и закончили выбор своей внешности.",, list("Да","Нет"))
	if(ready == "Нет")
		return
	var/mob/living/carbon/human/H = user
	for(var/obj/item/W in H)
		H.drop_from_inventory(W)
		qdel(W)
	H.equipOutfit(outfit)
	possible_tile = get_area_turfs(get_area_by_type(A))
	target = pick(possible_tile)
	H.loc = target
	INVOKE_ASYNC(global.chaplain_religion, /datum/religion/chaplain.proc/create_by_chaplain, H)
	H.AddSpell(new /obj/effect/proc_holder/spell/in_hand/arcane_barrage)
	H.mutations.Add(TK)
	H.update_mutations()