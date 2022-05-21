/obj/effect/portal/hub
	name = "В Хаб"
	var/area/A =/area/custom/hub
	var/list/turf/possible_tile
	icon = 'icons/obj/objects.dmi'
	icon_state = "bluespace_wormhole_enter"
	failchance = 0

/obj/effect/portal/hub/atom_init()
	possible_tile = get_area_turfs(get_area_by_type(A))
	target = pick(possible_tile)

/obj/effect/portal/hub/human
	A =/area/custom/human_hub
	name = "Фракция Замок"
	desc = "Королевство людей в центральной части Антагарича. Самое крупное государство материка. С самого основания королевства им правила династия Грифонхартов"

/obj/effect/portal/hub/wizard
	A =/area/custom/wizard_hub
	name = "Фракция Башня"
	desc = ""

/obj/effect/portal/hub/krigan
	A =/area/custom/krigan_hub
	name = "Фракция Инферно"
	desc = ""

/obj/effect/portal/hub/neutral
	A =/area/custom/neutral
	name = "Нейтралы"
	desc = "Слишком разные чтобы описать одним предложением.."

/obj/effect/portal/hub/job_room
	var/job_count = 0
	var/solo = FALSE
	var/global/list/portals = list()

/obj/effect/portal/hub/job_room/atom_init()
	..()
	portals += src

/obj/effect/portal/hub/job_room/Bumped(mob/M)
	if(solo)
		if(job_count > 0)
			to_chat(M, "<span class='notice'>Эта профессия уникальна и уже занята</span>")
			return
	job_count += 1
		..()

//ЭРАФИЯ

// Тир 1
/obj/effect/portal/hub/job_room/peasant
	A = /area/custom/peasant_hub
	name = "Крестьянин"
	desc = ""

/obj/effect/portal/hub/job_room/miner
	A = /area/custom/miner_hub
	name = "Шахтер"
	desc = ""

/obj/effect/portal/hub/job_room/helper
	A = /area/custom/helper_hub
	name = "Поcлушник"
	desc = ""

/obj/effect/portal/hub/job_room/doctor
	A = /area/custom/plague_doctor_hub
	name = "Врачеватель"
	desc = ""
	solo = TRUE

/obj/effect/portal/hub/job_room/headman
	A = /area/custom/headman_hub
	name = "Староста"
	desc = ""
	solo = TRUE

/obj/effect/portal/hub/job_room/innkeeper
	A = /area/custom/innkeeper_hub
	name = "Трактирщик"
	desc = ""
	solo = TRUE

/obj/effect/portal/hub/job_room/whitelist_room
	var/obj/effect/portal/hub/job_room/room_to_check
	var/obj/effect/portal/hub/job_room/my_room
	var/threshold = 0 // Сколько нужно для разблокировки
	var/mod = 0
	var/number_of_players = 0
	var/list/debug = list()

/obj/effect/portal/hub/job_room/whitelist_room/atom_init()
	..()
	mod = threshold
	for(var/P in portals)
		debug += P
		if(ispath(room_to_check,P))
			my_room = P

/obj/effect/portal/hub/job_room/whitelist_room/Bumped(mob/M)
	if(solo)
		if(job_count > 0)
			to_chat(M, "<span class='notice'>Эта профессия уникальна и уже занята</span>")
			return
	number_of_players = my_room.job_count
	if(number_of_players < threshold)
		to_chat(M, "<span class='notice'> Недостаточно низкоранговых профессий  для разблокировки этой комнаты.</span>")
		return
	else
		INVOKE_ASYNC(src, .proc/teleport, M)
		threshold += mod
		job_count += 1

// Тир 2
/obj/effect/portal/hub/job_room/whitelist_room/knight
	A = /area/custom/knight_hub
	name = "Рыцарь"
	desc = ""
	room_to_check =/obj/effect/portal/hub/job_room/peasant
	threshold = 3

/obj/effect/portal/hub/job_room/whitelist_room/monk
	A = /area/custom/monk_hub
	name = "Монах"
	desc = ""
	room_to_check =/obj/effect/portal/hub/job_room/helper
	threshold = 3

/obj/effect/portal/hub/job_room/whitelist_room/smith
	A = /area/custom/smith_hub
	name = "Кузнец"
	desc = ""
	room_to_check =/obj/effect/portal/hub/job_room/miner
	threshold = 3

/obj/effect/portal/hub/job_room/whitelist_room/h_hero
	A = /area/custom/human_hero
	name = "Герой"
	desc = ""
	room_to_check =/obj/effect/portal/hub/job_room/whitelist_room/knight
	threshold = 3
	solo = TRUE

//НЕЙТРАЛЫ
/obj/effect/portal/hub/job_room/lepr
	A = /area/custom/lepr
	name = "Лепрекон"
	desc = ""