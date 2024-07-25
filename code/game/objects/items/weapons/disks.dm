/* Nuke disk */

/obj/item/weapon/disk
	icon = 'icons/obj/disks.dmi'
	w_class = SIZE_MINUSCULE
	cases = list("дискета", "дискеты", "дискете", "дискету", "дискетой", "дискете")
	icon_state = "datadisk0"
	item_state_world = "datadisk0_world"
	item_state_inventory = "datadisk0"

/obj/item/weapon/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Лучше хранить это в безопасном месте."
	icon_state = "nucleardisk"
	item_state_world = "nucleardisk_world"
	item_state_inventory = "nucleardisk"

/obj/item/weapon/disk/nuclear/atom_init()
	. = ..()
	poi_list += src
	START_PROCESSING(SSobj, src)

/obj/item/weapon/disk/nuclear/process()
	var/turf/disk_loc = get_turf(src)
	if(!is_centcom_level(disk_loc.z) && !is_station_level(disk_loc.z))
		to_chat(get(src, /mob), "<span class='danger'>Кажется ты что-то потерял...</span>")
		qdel(src)

/obj/item/weapon/disk/nuclear/Destroy()
	SHOULD_CALL_PARENT(FALSE)

	var/turf/targetturf = pick_landmarked_location("blobstart", least_used = FALSE)
	var/turf/diskturf = get_turf(src)
	forceMove(targetturf) //move the disc, so ghosts remain orbitting it even if it's "destroyed"
	message_admins("[src] has been destroyed in ([COORD(diskturf)] - [ADMIN_JMP(diskturf)]). Moving it to ([COORD(targetturf)] - [ADMIN_JMP(targetturf)]).")
	log_game("[src] has been destroyed in [COORD(diskturf)]. Moving it to [COORD(targetturf)].")

	return QDEL_HINT_LETMELIVE //Cancel destruction regardless of success

#undef TIMER_MIN
#undef TIMER_MAX

/* Genetic disks */

/obj/item/weapon/disk/data
	name = "Cloning Data Disk"
	cases = list("ДНК-дискета", "ДНК-дискеты", "ДНК-дискете", "ДНК-дискету", "ДНК-дискетой", "ДНК-дискете")
	w_class = SIZE_TINY
	var/datum/dna2/record/buf=null
	var/read_only = 0 //Well,it's still a floppy disk

/obj/item/weapon/disk/data/examine(mob/user)
	..()
	to_chat(user, "Режим защиты от записи установлен на значение: [src.read_only ? "включён" : "отключён"].")

/obj/item/weapon/disk/data/attack_self(mob/user)
	src.read_only = !src.read_only
	to_chat(user, "Вы переключили режим защиты от записи на значение \"[src.read_only ? "включён" : "отключён"]\".")

//Disk stuff.
/obj/item/weapon/disk/data/atom_init()
	var/diskcolor = pick(0,1,2,3,4,5,6,7,8)
	icon_state = "datadisk[diskcolor]"
	item_state_world = "datadisk[diskcolor]_world"
	item_state_inventory = "datadisk[diskcolor]"
	. = ..()

/obj/item/weapon/disk/data/proc/Initialize()
	buf = new
	buf.dna=new

/obj/item/weapon/disk/data/demo
	name = "data disk - 'God Emperor of Mankind'"
	cases = list("ДНК-дискета 'Бог-Император Человечества'", "ДНК-дискеты 'Бог-Император Человечества'", "ДНК-дискете 'Бог-Император Человечества'", "ДНК-дискету 'Бог-Император Человечества'", "ДНК-дискетой 'Бог-Император Человечества'", "ДНК-дискете 'Бог-Император Человечества'")
	read_only = 1

/obj/item/weapon/disk/data/demo/atom_init()
	. = ..()
	Initialize()
	buf.types=DNA2_BUF_UE|DNA2_BUF_UI
	buf.dna.real_name="God Emperor of Mankind"
	buf.dna.unique_enzymes = md5(buf.dna.real_name)
	buf.dna.UI=list(0x066,0x000,0x033,0x000,0x000,0x000,0xAF0,0x000,0x000,0x000,0x033,0x066,0x0FF,0x4DB,0x002,0x690)
	buf.dna.UpdateUI()

/obj/item/weapon/disk/data/syndi

/obj/item/weapon/disk/telecomms
	name = "Suspicious Disk"
	desc = "Печально известная и исключительно нелегальная модель дискеты, такие часто используются корпоративными шпионами для кражи данных."
	origin_tech = "magnets=5;programming=5;syndicate=3"
	icon_state = "syndidisk"
	item_state_world = "syndidisk_world"
	item_state_inventory = "syndidisk"
	w_class = SIZE_TINY
	var/have_data = FALSE

/obj/item/weapon/disk/telecomms/examine(mob/user)
	..()
	if(have_data == TRUE)
		to_chat(user, "<span class='notice'>Память дискеты заполнена.</span>")

/obj/item/weapon/disk/data/monkey
	name = "data disk - 'Mr. Muggles'"
	cases = list("ДНК-дискета 'Мистер Магглс'", "ДНК-дискеты 'Мистер Магглс'", "ДНК-дискете 'Мистер Магглс'", "ДНК-дискету 'Мистер Магглс'", "ДНК-дискетой 'Мистер Магглс'", "ДНК-дискете 'Мистер Магглс'")
	read_only = 1

/obj/item/weapon/disk/data/monkey/atom_init()
	. = ..()
	Initialize()
	buf.types=DNA2_BUF_SE
	var/list/new_SE=list(0x098,0x3E8,0x403,0x44C,0x39F,0x4B0,0x59D,0x514,0x5FC,0x578,0x5DC,0x640,0x6A4)
	for(var/i=new_SE.len;i<=DNA_SE_LENGTH;i++)
		new_SE += rand(1,1024)
	buf.dna.SE=new_SE
	buf.dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)

/* RND design disks */

/obj/item/weapon/disk/design_disk
	name = "Empty Disk"
	desc = "Вау, это та самая дискета с сохранением?"
	w_class = SIZE_TINY
	m_amt = 30
	g_amt = 10
	var/datum/design/blueprint

/obj/item/weapon/disk/design_disk/atom_init()
	var/diskcolor = pick(0,1,2,3,4,5,6,7,8)
	icon_state = "datadisk[diskcolor]"
	item_state_world = "datadisk[diskcolor]_world"
	item_state_inventory = "datadisk[diskcolor]"
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)
	. = ..()

/* RND tech disks */

/obj/item/weapon/disk/tech_disk
	name = "Empty Disk"
	desc = "Вау, это та самая дискета с сохранением?"
	w_class = SIZE_TINY
	m_amt = 30
	g_amt = 10
	var/datum/tech/stored

/obj/item/weapon/disk/tech_disk/atom_init()
	var/diskcolor = pick(0,1,2,3,4,5,6,7,8)
	icon_state = "datadisk[diskcolor]"
	item_state_world = "datadisk[diskcolor]_world"
	item_state_inventory = "datadisk[diskcolor]"
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)
	. = ..()

/obj/item/weapon/disk/research_points
	name = "Important Disk"
	desc = "Похоже на диске хранится важная информация. Ученые возможно знают что с этим делать."
	icon_state = "datadisk9"
	item_state_world = "datadisk9_world"
	item_state_inventory = "datadisk9"
	w_class = SIZE_TINY
	m_amt = 30
	g_amt = 10
	var/stored_points

/obj/item/weapon/disk/research_points/atom_init()
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

	stored_points = rand(1,10)*1000

/obj/item/weapon/disk/research_points/rare/atom_init()
	. = ..()

	stored_points = rand(10, 20)*1000

/* Smartlight disks */

/obj/item/weapon/disk/smartlight_programm
	name = "Smartlight upgrade programm"
	desc = "Программа для расширения возможностей для центральной консоли управления освещением."
	icon_state = "holodisk"
	item_state_world = "holodisk_world"
	item_state_inventory = "holodisk"
	w_class = SIZE_TINY
	var/light_mode = /datum/light_mode/default

/obj/item/weapon/disk/smartlight_programm/atom_init()
	var/datum/light_mode/LM = light_mode
	desc += "\nЭто содержит следующую программу: \"[initial(LM.name)] режим освещения.\""
	return ..()

/obj/item/weapon/disk/smartlight_programm/soft
	light_mode = /datum/light_mode/soft

/obj/item/weapon/disk/smartlight_programm/hard
	light_mode = /datum/light_mode/hard

/obj/item/weapon/disk/smartlight_programm/k3000
	light_mode = /datum/light_mode/k3000

/obj/item/weapon/disk/smartlight_programm/k4000
	light_mode = /datum/light_mode/k4000

/obj/item/weapon/disk/smartlight_programm/k5000
	light_mode = /datum/light_mode/k5000

/obj/item/weapon/disk/smartlight_programm/k6000
	light_mode = /datum/light_mode/k6000

/obj/item/weapon/disk/smartlight_programm/shadows_soft
	light_mode = /datum/light_mode/shadows_soft

/obj/item/weapon/disk/smartlight_programm/shadows_hard
	light_mode = /datum/light_mode/shadows_hard

/obj/item/weapon/disk/smartlight_programm/code_red
	light_mode = /datum/light_mode/code_red

/obj/item/weapon/disk/smartlight_programm/blue_night
	light_mode = /datum/light_mode/blue_night

/obj/item/weapon/disk/smartlight_programm/soft_blue
	light_mode = /datum/light_mode/soft_blue

/obj/item/weapon/disk/smartlight_programm/neon
	light_mode = /datum/light_mode/neon

/obj/item/weapon/disk/smartlight_programm/neon_dark
	light_mode = /datum/light_mode/neon_dark
