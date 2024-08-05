var/global/mob/Jonesy

// alien fraction
/datum/faction/alien
	name = F_XENOMORPH
	ID = F_XENOMORPH
	logo_state = "alien-logo"
	required_pref = ROLE_ALIEN

	initroletype = /datum/role/alien

	min_roles = 0
	max_roles = 1

/datum/faction/alien/can_setup(num_players)
	if(!..())
		return FALSE
	if(xeno_spawn.len >= 1)
		return TRUE
	return FALSE

/datum/faction/alien/check_win()
	return check_crew(for_alien = TRUE) == 0

/datum/faction/alien/OnPostSetup()
	var/datum/role/role = pick(members)
	var/start_point = pick(xeno_spawn)

	if(start_point && role)
		var/mob/living/carbon/human/H = new (get_turf(start_point))
		H.equip_to_slot_or_del(new /obj/item/clothing/under/color/white, SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white, SLOT_SHOES)
		H.name = "Gilbert Kane"
		H.real_name = "Gilbert Kane"
		H.voice_name = "Gilbert Kane"

		var/mob/living/carbon/xenomorph/larva/lone/new_xeno = new(H)
		role.antag.transfer_to(new_xeno)
		QDEL_NULL(role.antag.original)
		var/obj/item/weapon/larva_bite/auto/G = new(new_xeno, H)
		new_xeno.put_in_active_hand(G)
		G.last_bite = world.time - 20
		G.synch()

	return ..()

#define F_NOSTROMO_CREW		"Nostromo Crew"
#define NOSTROMO_CREWMATE	"Nostromo Crewmate"
#define NOSTROMO_CAT		"Nostromo Cat"
#define NOSTROMO_ANDROID	"Nostromo Android"

// crew fraction
/datum/faction/nostromo_crew
	name = F_NOSTROMO_CREW
	ID = F_NOSTROMO_CREW
	logo_state = "nostromo-logo"

	accept_latejoiners = TRUE
	initroletype = /datum/role/nostromo_crewmate
	min_roles = 0
	max_roles = 6

	var/dead_crew = 0
	vav/obj/machinery/nuclearbomb/nostromo/NB
	var/list/supply_crate_packs = list(
		list(
			/obj/item/weapon/flamethrower/full,
			/obj/item/weapon/flamethrower/full,
			/obj/item/weapon/tank/phoron/full,
			/obj/item/weapon/tank/phoron/full,
			/obj/item/weapon/legcuffs/bola/tactical,
			/obj/item/weapon/legcuffs/bola/tactical,
			/obj/item/weapon/reagent_containers/spray/extinguisher),
		list(
			/obj/item/weapon/gun/projectile/shotgun/incendiary,
			/obj/item/weapon/gun/projectile/shotgun/incendiary,
			/obj/item/ammo_box/eight_shells/incendiary,
			/obj/item/ammo_box/eight_shells/incendiary,
			/obj/item/clothing/suit/armor/vest/fullbody,
			/obj/item/clothing/suit/armor/vest/fullbody,
			/obj/item/clothing/head/helmet,
			/obj/item/clothing/head/helmet,
			/obj/item/weapon/shield/riot),
		list(
			/obj/item/weapon/crossbow,
			/obj/item/weapon/crossbow,
			/obj/item/stack/rods/ten,
			/obj/item/weapon/wirecutters,
			/obj/item/weapon/stock_parts/cell/super,
			/obj/item/weapon/stock_parts/cell/super,
			/obj/item/clothing/glasses/night,
			/obj/item/clothing/glasses/night,
			/obj/item/clothing/suit/armor/syndilight,
			/obj/item/clothing/suit/armor/syndilight,
			/obj/item/clothing/head/helmet/syndilight,
			/obj/item/clothing/head/helmet/syndilight),
		list(
			/obj/item/weapon/sledgehammer,
			/obj/item/weapon/pickaxe/drill/jackhammer,
			/obj/item/weapon/gun/energy/laser/cutter,
			/obj/item/weapon/gun/energy/laser/cutter,
			/obj/item/clothing/suit/space/globose/mining,
			/obj/item/clothing/suit/space/globose/mining,
			/obj/item/clothing/head/helmet/space/globose/mining,
			/obj/item/clothing/head/helmet/space/globose/mining,
			/obj/item/weapon/storage/box/autoinjector/stimpack),
		list(
			/obj/item/weapon/claymore,
			/obj/item/weapon/claymore,
			/obj/item/weapon/shield/riot/roman,
			/obj/item/weapon/shield/riot/roman,
			/obj/item/clothing/suit/armor/crusader,
			/obj/item/clothing/suit/armor/crusader,
			/obj/item/clothing/head/helmet/crusader,
			/obj/item/clothing/head/helmet/crusader,
			/obj/item/clothing/accessory/bronze_cross)
	)

/datum/faction/nostromo_crew/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/kill_alien)
	return TRUE

/datum/faction/nostromo_crew/check_win()
	var/list/list = alien_list[ALIEN_LONE_HUNTER]
	if(list.len)
		var/mob/living/L = alien_list[ALIEN_LONE_HUNTER][1]
		if(L)
			return L.stat == DEAD
	return

/datum/faction/nostromo_crew/OnPostSetup()
	..()
	for(var/datum/role/r in members)
		RegisterSignal(r.antag.current, COMSIG_MOB_DIED, PROC_REF(crewmate_died))
	NB = locate() in poi_list

/datum/faction/nostromo_crew/proc/crewmate_died()
	dead_crew++
	if(dead_crew == 2)
		spawn_crate()
		open_cargo()
	if(dead_crew == 5)
		open_evac()

/datum/faction/nostromo_crew/proc/spawn_crate()
	var/supply_point = pick(landmarks_list["Nostromo Supply Crate"])
	var/obj/structure/closet/crate/secure/gear/SC = new (get_turf(supply_point))
	SC.req_access = list(access_cargo)
	SC.anchored = 1
	var/crate_contains = pick(supply_crate_packs)
	for(var/item in crate_contains)
		new item(SC)
	give_signal("На корабль перед отлётом грузили ящики и контейнеры, где-то на складе может быть оружие!")

/datum/faction/nostromo_crew/proc/open_cargo()
	for(var/obj/BW in landmarks_list["Nostromo Cargo Blockway"])
		qdel(BW)
	var/mob/living/silicon/decoy/nostromo/N_AI = locate() in mob_list
	if(N_AI)
		N_AI.announce("cargo")

/datum/faction/nostromo_crew/proc/open_evac()
	if(NB)
		NB.can_interact = TRUE
	give_signal("Мы должны эвакуироваться! Нужно запустить механизм самоуничтожения!")

/datum/faction/nostromo_crew/proc/give_signal(message)
	for(var/mob/living/carbon/human/H as anything in human_list)
		if(H.stat != DEAD)
			var/scary_sound = pick('sound/hallucinations/scary_sound_1.ogg',
				'sound/hallucinations/scary_sound_2.ogg',
				'sound/hallucinations/scary_sound_3.ogg',
				'sound/hallucinations/scary_sound_4.ogg')
			H.playsound_local(null, scary_sound, VOL_EFFECTS_MASTER, null, FALSE)
			to_chat(H, "<span class='warning'>[message]</span>")

// android traitor fraction
/datum/faction/nostromo_android
	name = NOSTROMO_ANDROID
	ID = NOSTROMO_ANDROID
	logo_state = "nano-logo"
	required_pref = ROLE_TRAITOR

	initroletype = /datum/role/nostromo_android
	min_roles = 0
	max_roles = 1

/datum/faction/nostromo_android/OnPostSetup()
	var/datum/role/role = pick(members)
	var/mob/living/carbon/human/H = role.antag.current
	H.set_species(NOSTROMO_ANDROID)
	H.nutrition_icon.update_icon(H)
	return ..()

// kitty fraction
/datum/faction/nostromo_cat
	name = NOSTROMO_CAT
	ID = NOSTROMO_CAT
	logo_state = "cat-logo"
	initroletype = /datum/role/nostromo_cat
	min_roles = 0

/datum/faction/nostromo_cat/OnPostSetup()
	var/start_point = pick(landmarks_list["Jonesy"])
	var/mob/living/simple_animal/cat/red/jonesy/J = new (get_turf(start_point))
	global.Jonesy = J
	return ..()
