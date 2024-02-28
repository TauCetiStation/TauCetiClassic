/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"

	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	invisibility = INVISIBILITY_OBSERVER
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF

	pass_flags = PASSBLOB
	faction = "blob"

	var/obj/structure/blob/core/blob_core = null // The blob overmind's core
	var/list/blob_mobs = list()
	var/list/factory_blobs = list()
	var/blob_points = 0
	var/max_blob_points = 100
	var/victory_in_progress = FALSE
	var/image/ghostimage = null

	var/datum/faction/blob_conglomerate/b_congl

/mob/camera/blob/atom_init()
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	ghostimage = image(icon, src, icon_state)
	ghost_sightless_images |= ghostimage //so ghosts can see the blob eye when they disable ghost sight
	updateallghostimages()
	. = ..()

/mob/camera/blob/Login()
	..()
	sync_mind()
	update_health_hud()
	add_points(0)
	blob_help()

/mob/camera/blob/proc/blob_help()
	to_chat(src, "<span class='notice'>Вы являетесь сверхразумом.</span>")
	to_chat(src, "Вы можете контролировать блоба, расширяться и атаковать тех, кто пытается помешать вам! С помощью спор вы сможете делать себе прислужников, взывая их к телам павших врагов.")
	to_chat(src, "<b>Нормальный блоб</b> является вашей основной частью для расширения, которую можно будет улучшить.")
	to_chat(src, "<b>Укреплённый блоб</b> является укрепленной версией нормального блоба. Он невосприимчив к огню, используйте это в свою пользу. Улучшите эту часть снова, чтобы получить отражающую версию, способную отражать лазеры.")
	to_chat(src, "<b>Ресурсная ячейка</b> является основным способом добычи ресурсов, постройте их как можно больше в начале, чтобы всегда иметь достаточно ресурсов. Оно улучшается от нахождения рядом с ядром или узлом; если расположить его очень далеко, то ресурсы воспроизводиться не будут.")
	to_chat(src, "<b>Узел блоба</b> подобно ядру, может расширяться. Однако, он сам не производит ресурсы, но может повысить эффективность ближних к ней ячеек")
	to_chat(src, "<b>Производящая ячейка</b> создаёт споры. Генерация ускоряется от нахождения рядом с ядром или узлом ; если расположить её очень далеко, то споры воспроизводиться не будут.")
	to_chat(src, "<b>Блоббернауты</b> могут быть созданы из производящей ячейки, их тяжело убить, они сильно бьют и обладают средней мобильностью. Ячейка, которая была использована для производства единицы, временно не сможет производить споры и станет более хрупкой.")
	to_chat(src, "<b>Хоткеи:</b> Click = расширить блоба / CTRL Click =  удалить ИЛИ переименовать узел блоба / Shift Click = улучшение блоба / Middle Mouse Click = призыв спор / Alt Click = создание щита")

/mob/camera/blob/proc/update_health_hud()
	if(blob_core && hud_used)
		healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(blob_core.get_integrity())]</font></div>"
		for(var/mob/living/simple_animal/hostile/blob/blobbernaut/B in blob_mobs)
			if(B.hud_used && B.pwr_display)
				B.pwr_display.maptext = healths.maptext

/mob/camera/blob/proc/add_points(points)
	blob_points = clamp(blob_points + points, 0, max_blob_points)
	if(hud_used)
		pwr_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[round(src.blob_points)]</font></div>"

/mob/camera/blob/say(message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "Вы не можете говорить.")
			return
		if (client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat != CONSCIOUS)
		return

	blob_talk(message)

/mob/camera/blob/proc/blob_talk(message)
	message = sanitize(message)

	log_say("[key_name(src)] : [message]")

	if (!message)
		return

	message = "<span class='say_quote'>says,</span> \"<span class='body'>[message]</span>\""
	message = "<span style='color:#EE4000'><i><span class='game say'>Телепатическая связь, <span class='name'>[name]</span> <span class='message'>[message]</span></span></i></span>"

	for(var/M in mob_list)
		if(isovermind(M) || istype(M, /mob/living/simple_animal/hostile/blob))
			to_chat(M, message)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [message]")

/mob/camera/blob/blob_act()
	return

/mob/camera/blob/Stat()
	..()
	if(statpanel("Status"))
		if(blob_core)
			stat(null, "Здоровье ядра: [blob_core.get_integrity()]")
		stat(null, "Сохранено энергии: [blob_points]/[max_blob_points]")
		stat(null, "Прогресс: [blobs.len]/[b_congl.blobwincount]")
		stat(null, "Количество узлов блоба: [blob_nodes.len]")
		stat(null, "Всего ядер: [blob_cores.len]")

/mob/camera/blob/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = FALSE
	var/obj/structure/blob/B = locate() in range(3, NewLoc)
	if(NewLoc && B)
		loc = NewLoc
		return TRUE

/mob/camera/blob/Destroy()
	if(ghostimage)
		ghost_sightless_images -= ghostimage
		QDEL_NULL(ghostimage)
		updateallghostimages()

	for(var/mob/living/simple_animal/hostile/blob/BLO in blob_mobs)
		BLO.overmind = null
	blob_mobs = null

	for(var/obj/structure/blob/factory/F in factory_blobs)
		F.OV = null
	factory_blobs = null

	return ..()
