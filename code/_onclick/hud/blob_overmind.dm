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
	name = "Blob Help"
	desc = "Help on playing blob!"
	screen_loc = "WEST:6,NORTH:-3"

/atom/movable/screen/blob/blob_help/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.blob_help()

/atom/movable/screen/blob/jump_to_node
	icon_state = "ui_tonode"
	name = "Jump to Node"
	desc = "Moves your camera to a selected blob node."
	screen_loc = ui_inventory

/atom/movable/screen/blob/jump_to_node/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.jump_to_node()

/atom/movable/screen/blob/jump_to_core
	icon_state = "ui_tocore"
	name = "Jump to Core"
	desc = "Moves your camera to your blob core."
	screen_loc = ui_zonesel

/atom/movable/screen/blob/jump_to_core/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		flash_color(B, "#187914", 20)
		B.abstract_move(get_turf(B.blob_core))

/atom/movable/screen/blob/shield
	icon_state = "ui_shield"
	name = "Upgrade blob to shield (10)"
	desc = "Create a shield blob. <br>Use it again on existing shield blob to upgrade it into a reflective blob."
	screen_loc = ui_id

/atom/movable/screen/blob/shield/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_shield(get_turf(B))

/atom/movable/screen/blob/resource_blob
	icon_state = "ui_resource"
	name = "Produce Resource Blob (40)"
	desc = "Produces a resource blob for 40 resources.<br>Resource blobs will give you resources every few seconds."
	screen_loc = ui_belt

/atom/movable/screen/blob/resource_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_resource(get_turf(B))

/atom/movable/screen/blob/node_blob
	icon_state = "ui_node"
	name = "Produce Node Blob (60)"
	desc = "Produces a node blob for 60 resources.<br>Node blobs will expand and activate nearby resource and factory blobs."
	screen_loc = ui_back

/atom/movable/screen/blob/node_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_node(get_turf(B))

/atom/movable/screen/blob/factory_blob
	icon_state = "ui_factory"
	name = "Produce Factory Blob (60)"
	desc = "Produces a factory blob for 60 resources.<br>Factory blobs will produce spores every few seconds."
	screen_loc = ui_rhand

/atom/movable/screen/blob/factory_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_factory(get_turf(B))

/atom/movable/screen/blob/blobbernaut
	icon_state = "ui_blobbernaut"
	name = "Produce Blobbernaut (40)"
	desc = "Produces a strong, smart blobbernaut from a factory blob for (40) resources.<br>The factory blob used will become fragile and unable to produce spores."
	screen_loc = ui_lhand

/atom/movable/screen/blob/blobbernaut/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_blobbernaut()

/atom/movable/screen/blob/rally_spores
	icon_state = "ui_spore"
	name = "Rally Spores (5)"
	desc = "Rally the spores to move to your location"
	screen_loc = ui_storage1

/atom/movable/screen/blob/rally_spores/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.rally_spores(get_turf(B))

/atom/movable/screen/blob/relocate_core
	icon_state = "ui_swap"
	name = "Relocate Core (80)"
	desc = "Swaps a node and your core for 80 resources."
	screen_loc = ui_storage2

/atom/movable/screen/blob/relocate_core/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.relocate_core()
