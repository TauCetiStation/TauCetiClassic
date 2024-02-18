// Point controlling procs

/mob/camera/blob/proc/can_buy(cost = 15)
	if(blob_points < cost)
		to_chat(src, "<span class='warning'>Не хватает ресурсов.</span>")
		return FALSE
	add_points(-cost)
	return TRUE

// Power verbs

/mob/camera/blob/verb/transport_core()
	set category = "Blob"
	set name = "Перемещение к ядру"
	set desc = "Перемещение к ядру."

	if(blob_core)
		flash_color(src, "#187914", 20)
		src.loc = blob_core.loc

/mob/camera/blob/verb/jump_to_node()
	set category = "Blob"
	set name = "Перемещение к ноде"
	set desc = "Перемещение к выбранной ноде."

	if(blob_nodes.len)
		var/list/nodes = list()
		for(var/obj/structure/blob/node/N in blob_nodes)
			nodes[N.given_name] = N
		var/node_name = input(src, "Выберите узел для перехода.", "Перемещение между узлами") in nodes
		var/obj/structure/blob/node/chosen_node = nodes[node_name]
		if(chosen_node)
			flash_color(src, "#187914", 20)
			src.loc = chosen_node.loc

/mob/camera/blob/verb/create_shield_power()
	set category = "Blob"
	set name = "Создать укрепленного блоба (10)"
	set desc = "Создать укрепленного блоба. Используйте снова для получения рефлективной версии."

	var/turf/T = get_turf(src)
	create_shield(T)

/mob/camera/blob/proc/create_shield(turf/T)

	var/obj/structure/blob/B = locate() in T

	if(!B)//We are on a blob
		to_chat(src, "Это место не захвачено!")
		return

	if(!isblobnormal(B) && !isblobshield(B)) //Not special blob nor shield to upgrade
		to_chat(src, "Этого блоба использовать нельзя. Найдите другого.")
		return

	if(!can_buy(10))
		return

	if(isblobshield(B))
		if(B.get_integrity() < B.max_integrity / 2)
			to_chat(src, "<span class='warning'>Этот укрепленный блоб слишком поврежден для улучшения!</span>")
			return
		B.change_to(/obj/structure/blob/shield/reflective, src)
	else
		B.change_to(/obj/structure/blob/shield)

/mob/camera/blob/verb/relocate_core_power()
	set category = "Blob"
	set name = "Перемещение ядра (70)"
	set desc = "Меняет местами ядро и узел."

	relocate_core()

/mob/camera/blob/proc/relocate_core()
	var/turf/T = get_turf(src)
	var/obj/structure/blob/node/B = locate() in T
	if(!B)
		to_chat(src, "<span class='warning'>Вы должны быть на узле!</span>")
		return
	if(isspaceturf(T))
		to_chat(src, "<span class='warning'>Вы не можете переместить сюда своё ядро!</span>")
		return
	if(!can_buy(70))
		return
	var/turf/old_turf = get_turf(blob_core)
	blob_core.forceMove(T)
	B.forceMove(old_turf)

/mob/camera/blob/verb/blobbernaut_power()
	set category = "Blob"
	set name = "Создать блоббернаута (40)"
	set desc = "Создаёт мощного и умного блоббернаута."

	create_blobbernaut()

/mob/camera/blob/proc/create_blobbernaut()
	var/turf/T = get_turf(src)
	var/obj/structure/blob/factory/B = locate() in T
	if(!B)
		to_chat(src, "<span class='warning'>Вы должны быть на производящей ячейке!</span>")
		return
	if(B.naut) //if it already made a blobbernaut, it can't do it again
		to_chat(src, "<span class='warning'>Эта ячейка уже производит блоббернаута.</span>")
		return
	if(B.get_integrity() < B.max_integrity * 0.5)
		to_chat(src, "<span class='warning'>Эта ячейка слишком повреждена для производства блоббернаута.</span>")
		return
	if(blob_points < 40)
		to_chat(src, "<span class='warning'>Вы не можете себе этого позволить.</span>")
		return FALSE

	B.naut = TRUE //temporary placeholder to prevent creation of more than one per factory.
	to_chat(src, "<span class='notice'>Вы начинаете создание блоббернаута.</span>")
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Вы хотите стать блоббернаутом?", ROLE_BLOB, ROLE_BLOB, 50) //players must answer rapidly
	if(candidates.len) //if we got at least one candidate, they're a blobbernaut now.
		B.max_integrity = B.max_integrity * 0.25 //factories that produced a blobbernaut have much lower health
		B.visible_message("<span class='warning'><b>Блоббернаут [pick("вырывается", "выплевывается", "выходит")] из ячейки!</b></span>")
		playsound(B.loc, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER, 50)
		var/mob/living/simple_animal/hostile/blob/blobbernaut/blobber = new /mob/living/simple_animal/hostile/blob/blobbernaut(get_turf(B))
		flick("blobbernaut_produce", blobber)
		B.naut = blobber
		blobber.factory = B
		blobber.overmind = src
		blobber.update_icons()
		blobber.health = blobber.maxHealth * 0.5
		blob_mobs += blobber
		var/mob/dead/observer/C = pick(candidates)
		blobber.key = C.key
		playsound(blobber, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
		to_chat(blobber, "<b>Вы - блоббернаут!</b> \
		<br>Вы сильны и выносливы. Вы восстанавливаетесь при нахождении рядом с ячейками, <span class='danger'но медленно умираете, если не находитесь рядом с блобом </span> или если фабрика, которая создала вас - уничтожена. \
		<br>You can communicate with other blobbernauts and overminds<BR>")
		add_points(-40)
	else
		to_chat(src, "<span class='warning'>Вы не смогли произвести блоббернаута. Ваши очки возвращены. Попробуйте позже.</span>")
		B.naut = null

/mob/camera/blob/verb/create_resource_power()
	set category = "Blob"
	set name = "Создать ресурсную ячейку (40)"
	set desc = "Создать ресурсную ячейку, которая производит ресурсы раз в секунду."


	var/turf/T = get_turf(src)
	create_resource(T)

/mob/camera/blob/proc/create_resource(turf/T)
	if(!T)
		return

	var/obj/structure/blob/B = locate() in T

	if(!B)//We are on a blob
		to_chat(src, "Это место не захвачено!")
		return

	if(!isblobnormal(B))
		to_chat(src, "Этого блоба использовать нельзя. Найдите другого.")
		return

	for(var/obj/structure/blob/resource/blob in orange(4, T))
		to_chat(src, "Здесь уже есть ресурсная ячейка, поставьте другую на 4 клетки дальше от ближайшей")
		return

	if(!can_buy(40))
		return

	B.change_to(/obj/structure/blob/resource, src)


/mob/camera/blob/verb/create_node_power()
	set category = "Blob"
	set name = "Создать узел блоба (60)"
	set desc = "Создать узел блоба."


	var/turf/T = get_turf(src)
	create_node(T)

/mob/camera/blob/proc/create_node(turf/T)
	if(!T)
		return

	var/obj/structure/blob/B = locate() in T

	if(!B)//We are on a blob
		to_chat(src, "Здесь нет блоба!")
		return

	if(!isblobnormal(B))
		to_chat(src, "Этого блоба использовать нельзя. Найдите другого.")
		return

	for(var/obj/structure/blob/node/blob in orange(5, T))
		to_chat(src, "Здесь уже есть узел, поставьте другой на 5 плиток дальше!")
		return

	if(!can_buy(60))
		return


	B.change_to(/obj/structure/blob/node)

/mob/camera/blob/verb/create_factory_power()
	set category = "Blob"
	set name = "Создать производящую ячейку (60)"
	set desc = "Создать производящую ячейку."


	var/turf/T = get_turf(src)
	create_factory(T)

/mob/camera/blob/proc/create_factory(turf/T)
	if(!T)
		return

	var/obj/structure/blob/B = locate() in T
	if(!B)
		to_chat(src, "!")
		return

	if(!isblobnormal(B))
		to_chat(src, "Этого блоба использовать нельзя. Найдите другого.")
		return

	for(var/obj/structure/blob/factory/blob in orange(7, T))
		to_chat(src, "Здесь уже есть производящая ячейка, поставьте другую на 7 плиток дальше!!")
		return

	if(!can_buy(60))
		return

	var/obj/structure/blob/factory/F = B.change_to(/obj/structure/blob/factory)
	F.OV = src
	factory_blobs += F

/mob/camera/blob/verb/revert()
	set category = "Blob"
	set name = "Удалить блоба"
	set desc = "Удаляет блоба."

	var/turf/T = get_turf(src)
	remove_blob(T)

/mob/camera/blob/verb/remove_blob(turf/T)
	var/obj/structure/blob/B = locate() in T
	if(!B)
		to_chat(src, "Здесь нет блоба!")
		return

	if(isblobcore(B))
		to_chat(src, "Невозможно удалить этого блоба.")
		return

	qdel(B)


/mob/camera/blob/verb/expand_blob_power()
	set category = "Blob"
	set name = "Расширение (5)"
	set desc = "Попытка создать нового блоба. При нахождении на плитке предмета, он будет разрушен и будет медленно поглощаться."

	var/turf/T = get_turf(src)
	expand_blob(T)

/mob/camera/blob/proc/expand_blob(turf/T)
	if(!T)
		return

	var/obj/structure/blob/B = locate() in T
	if(B)
		to_chat(src, "Здесь уже есть блоб!")
		return

	var/obj/structure/blob/OB = locate() in circlerange(T, 1)
	if(!OB)
		to_chat(src, "Здесь нет блоба поблизости.")
		return

	if(!can_buy(5))
		return
	OB.expand(T, 0)
	return


/mob/camera/blob/verb/rally_spores_power()
	set category = "Blob"
	set name = "Призыв спор (5)"
	set desc = "Призыв спор на указанную локацию."

	var/turf/T = get_turf(src)
	rally_spores(T)

/mob/camera/blob/proc/rally_spores(turf/T)

	if(!can_buy(5))
		return

	to_chat(src, "Вы  призвали споры на указанную локацию.")

	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return

	for(var/mob/living/simple_animal/hostile/blob/blobspore/BS in blob_mobs)
		if(isturf(BS.loc) && get_dist(BS, T) <= 35 && !BS.stop_automated_movement)
			BS.LoseTarget()
			BS.Goto(pick(surrounding_turfs), BS.move_to_delay)
	return

/mob/camera/blob/verb/rename_node(obj/structure/blob/node/target in view())
	set category = "Blob"
	set name = "Переименовать узел"
	set desc = "Переименовать узел"

	if(!target)
		return

	var/new_name = sanitize(input(src, "Введите новое имя для этого узла:", "Переименовать узел", target.given_name) as text|null)
	if(new_name)
		target.given_name = new_name

/mob/camera/blob/proc/prompt_upgrade(obj/structure/blob/B)
	var/list/datum/callback/blob_upgrade = list(
		"Resource" = CALLBACK(src, PROC_REF(create_resource)),
		"Node"     = CALLBACK(src, PROC_REF(create_node)),
		"Factory"  = CALLBACK(src, PROC_REF(create_factory)),
	)
	var/static/list/icon/upgrade_icon = list(
		"Resource" = icon('icons/mob/blob.dmi', "radial_resource"),
		"Node"     = icon('icons/mob/blob.dmi', "radial_node"),
		"Factory"  = icon('icons/mob/blob.dmi', "radial_factory"),
	)
	var/choice = show_radial_menu(src, B, upgrade_icon)
	var/datum/callback/CB = blob_upgrade[choice]
	CB?.Invoke(get_turf(B))
