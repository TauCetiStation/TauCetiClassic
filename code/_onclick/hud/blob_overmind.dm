//Buttons of overmind
/mob/camera/blob/add_to_hud(datum/hud/hud)
	hud.ui_style = 'icons/hud/blob.dmi'
	hud.init_screens(list(
		/atom/movable/screen/blob_power,
		/atom/movable/screen/health/blob,
		/atom/movable/screen/blob/shield,
		/atom/movable/screen/blob/blob_help,
		/atom/movable/screen/blob/node_blob,
		/atom/movable/screen/blob/blobbernaut,
		/atom/movable/screen/blob/rally_spores,
		/atom/movable/screen/blob/factory_blob,
		/atom/movable/screen/blob/jump_to_node,
		/atom/movable/screen/blob/jump_to_core,
		/atom/movable/screen/blob/relocate_core,
		/atom/movable/screen/blob/resource_blob,
	))

// Special elemets of huds
/atom/movable/screen/health/blob
	name = "blob health"
	icon = 'icons/hud/blob.dmi' //Override health gen
	icon_state = "corehealth"
	screen_loc = ui_internal
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/health/blob/blobbernaut //Basically reverts icon
	icon_state = "block"

/atom/movable/screen/blob_power
	name = "blob power"
	icon_state = "block"
	screen_loc = ui_health
	plane = ABOVE_HUD_PLANE

	copy_flags = NONE

/atom/movable/screen/blob_power/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.pwr_display = src

/atom/movable/screen/blob_power/blobbernaut //Actually core healths
	name = "core healths"
	icon_state = "corehealth"

// Template
/atom/movable/screen/blob
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/blob/MouseEntered(location,control,params)
	. = ..()
	openToolTip(usr, src, params, title = name, content = desc, theme = "blob")

/atom/movable/screen/blob/MouseExited()
	closeToolTip(usr)

/atom/movable/screen/blob/blob_help
	icon_state = "ui_help"
	name = "Руководство для игры"
	desc = "Помогите! Я не умею играть на этом..."
	screen_loc = "WEST:6,NORTH:-3"

/atom/movable/screen/blob/blob_help/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.blob_help()

/atom/movable/screen/blob/jump_to_node
	icon_state = "ui_tonode"
	name = "Перемещение к узлу"
	desc = "Вы перемещаетесь к выбранному узлу."
	screen_loc = ui_inventory

/atom/movable/screen/blob/jump_to_node/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.jump_to_node()

/atom/movable/screen/blob/jump_to_core
	icon_state = "ui_tocore"
	name = "Перемещение к ядру"
	desc = "Вы перемещаетесь к своему ядру."
	screen_loc = ui_zonesel

/atom/movable/screen/blob/jump_to_core/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		flash_color(B, "#187914", 20)
		B.abstract_move(get_turf(B.blob_core))

/atom/movable/screen/blob/shield
	icon_state = "ui_shield"
	name = "Укрепить блоба (10)"
	desc = "Создаёт укрепленного блоба. <br>Используйте снова на укреплённом блобе для улучшения в отражающего блоба."
	screen_loc = ui_id

/atom/movable/screen/blob/shield/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_shield(get_turf(B))

/atom/movable/screen/blob/resource_blob
	icon_state = "ui_resource"
	name = "Создать ресурсную ячейку (40)"
	desc = "Создаёт ресурсную ячейку блоба.<br>Ячейка создаёт ресурсы раз в несколько секунд."
	screen_loc = ui_belt

/atom/movable/screen/blob/resource_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_resource(get_turf(B))

/atom/movable/screen/blob/node_blob
	icon_state = "ui_node"
	name = "Создать узел блоба (60)"
	desc = "Создаёт узел блоба.<br>Узел ускоряет работу производящих и ресурсных ячеек, в то же время захватывая пространство возле себя."
	screen_loc = ui_back

/atom/movable/screen/blob/node_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_node(get_turf(B))

/atom/movable/screen/blob/factory_blob
	icon_state = "ui_factory"
	name = "Создать производящую ячейку (60)"
	desc = "Создаёт производящую ячейку.<br>Производящие ячейки создают споры блоба раз в несколько секунд."
	screen_loc = ui_rhand

/atom/movable/screen/blob/factory_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_factory(get_turf(B))

/atom/movable/screen/blob/blobbernaut
	icon_state = "ui_blobbernaut"
	name = "Создать блоббернаута (40)"
	desc = "Создаёт крепкого и умного блоббернаута.<br>Производящая ячейка, создавшая блоббернаута, становится неактивной и хрупкой до смерти блоббернаута."
	screen_loc = ui_lhand

/atom/movable/screen/blob/blobbernaut/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_blobbernaut()

/atom/movable/screen/blob/rally_spores
	icon_state = "ui_spore"
	name = "Призыв спор (5)"
	desc = "Призовите споры в выбранную локацию."
	screen_loc = ui_storage1

/atom/movable/screen/blob/rally_spores/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.rally_spores(get_turf(B))

/atom/movable/screen/blob/relocate_core
	icon_state = "ui_swap"
	name = "Перемещение ядра (80)"
	desc = "Выбранный узел меняется с ядром местами."
	screen_loc = ui_storage2

/atom/movable/screen/blob/relocate_core/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.relocate_core()
