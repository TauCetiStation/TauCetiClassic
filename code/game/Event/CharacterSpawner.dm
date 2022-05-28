/obj/structure/character_spawner
	name = "СТАРТ"
	desc = "Нажми на меня если закончил выбор внешности и прочитал все таблички."
	anchored = TRUE
	icon = 'icons/turf/areas.dmi'
	icon_state = "start"
	var/list/turf/possible_tile
	var/outfit = null
	var/ready = null
	var/area/A
	var/target
	var/selecting_job = FALSE
	var/arrive_sound

/obj/structure/character_spawner/attack_hand(mob/living/carbon/human/user)
	if(!selecting_job)
		selecting_job = TRUE
		ready = tgui_alert(user, "Готовы войти в игру? Убедитесь что прочитали все подсказки и закончили выбор своей внешности.",, list("Да","Нет"))
	else
		return
	if(ready == "Нет")
		selecting_job = FALSE
		return
	for(var/obj/item/W in user)
		user.drop_from_inventory(W)
		qdel(W)
	user.equipOutfit(outfit)
	possible_tile = get_area_turfs(get_area_by_type(A))
	target = pick(possible_tile)
	user.isHubMan = FALSE
	user.loc = target
	selecting_job = FALSE
	if(arrive_sound)
		playsound(user,arrive_sound, VOL_EFFECTS_MASTER)

// ЭРАФИЯ

/obj/structure/character_spawner/peasant
	outfit = /datum/outfit/job/hub/peasant
	A =/area/custom/start_homm/peasant
	arrive_sound = 'sound/Event/peasant.ogg'

/obj/structure/character_spawner/smith
	outfit = /datum/outfit/job/hub/smith
	A =/area/custom/start_homm/smith
	arrive_sound = 'sound/Event/smith.ogg'

/obj/structure/character_spawner/miner
	outfit = /datum/outfit/job/hub/miner
	A =/area/custom/start_homm/miner
	arrive_sound = 'sound/Event/miner.ogg'

/obj/structure/character_spawner/helper
	outfit = /datum/outfit/job/hub/helper
	A =/area/custom/start_homm/helper
	arrive_sound = 'sound/Event/helper.ogg'

/obj/structure/character_spawner/doctor
	outfit = /datum/outfit/job/hub/plague_doctor
	A =/area/custom/start_homm/doctor
	arrive_sound = 'sound/Event/doctor.ogg'


/obj/structure/character_spawner/headman
	outfit = /datum/outfit/job/hub/headman
	A =/area/custom/start_homm/headman
	arrive_sound = 'sound/Event/headman.ogg'

/obj/structure/character_spawner/innkeeper
	outfit = /datum/outfit/job/hub/innkeeper
	A =/area/custom/start_homm/innkeeper
	arrive_sound = 'sound/Event/innkeeper.ogg'

/obj/structure/character_spawner/knight
	outfit = /datum/outfit/job/hub/knight
	A = /area/custom/start_homm/knight
	arrive_sound = 'sound/Event/knight.ogg'

/obj/structure/character_spawner/monk
	outfit = /datum/outfit/job/hub/monk
	A = /area/custom/start_homm/monk

/obj/structure/character_spawner/monk/attack_hand(mob/user)
	..()
	if(ready == "Нет")
		selecting_job = FALSE
		return
	INVOKE_ASYNC(global.chaplain_religion, /datum/religion/chaplain.proc/create_by_chaplain, user)
	user.AddSpell(new /obj/effect/proc_holder/spell/in_hand/arcane_barrage)
	user.mutations.Add(TK)
	user.verbs += /mob/living/carbon/human/proc/remotesay
	user.verbs += /mob/proc/toggle_telepathy_hear
	user.verbs += /mob/proc/telepathy_say
	user.update_mutations()

/obj/structure/character_spawner/human_hero
	outfit = /datum/outfit/job/hub/human_hero
	A = /area/custom/start_homm/human_hero
	arrive_sound = 'sound/Event/hero.ogg'

/obj/structure/character_spawner/human_hero/attack_hand(mob/user)
	..()
	if(ready == "Нет")
		selecting_job = FALSE
		return
	new/obj/vehicle/space/spacebike/horse/(user.loc)


//НЕЙТРАЛЫ
/obj/structure/character_spawner/lepr
	outfit = /datum/outfit/job/hub/lepr
	A =/area/custom/start_homm/lepr
	arrive_sound = 'sound/Event/headman.ogg'

/obj/structure/character_spawner/lepr/attack_hand(mob/living/carbon/human/user) // only a human can become lepr
	..()
	if(ready == "Нет")
		selecting_job = FALSE
		return
	user.mutations.Add(SMALLSIZE)
	user.regenerate_icons()
	user.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/lepr_escape)
	user.AddSpell(new /obj/effect/proc_holder/spell/targeted/lepr_hivemind)
	user.see_invisible = 34 // so he can see the tree of greed
	user.homm_species = "lepr"
	cameranet.cameras += user
	cameranet.addCamera(user)
	cameranet.updateVisibility(user, 0)
