/*
	The global hud:
	Uses the same visual objects for all players.
*/

/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

// The default UI style is the first one in the list
var/global/list/available_ui_styles = list(
	"White" = 'icons/hud/screen1_White.dmi',
	"Midnight" = 'icons/hud/screen1_Midnight.dmi',
	"old" = 'icons/hud/screen1_old.dmi',
	"Orange" = 'icons/hud/screen1_Orange.dmi'
	)

/proc/ui_style2icon(ui_style)
	return global.available_ui_styles[ui_style] || global.available_ui_styles[global.available_ui_styles[1]]

/datum/hud
	var/mob/mymob

	var/hud_shown = FALSE					//Used for the HUD toggle (F12)
	var/hud_version = HUD_STYLE_STANDARD	//Current displayed version of the HUD
	var/inventory_shown = FALSE				//the inventory
	var/hotkey_ui_hidden = FALSE			//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/list/main = list()
	var/list/adding = list()
	var/list/hotkeybuttons = list()
	var/list/complex = list()

	var/atom/movable/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0
	var/list/atom/movable/screen/plane_master/plane_masters = list() // see "appearance_flags" in the ref, assoc list of "[plane]" = object
	///Assoc list of controller groups, associated with key string group name with value of the plane master controller ref
	var/list/atom/movable/plane_master_controller/plane_master_controllers = list()

	// subtypes can override this to force a specific UI style
	var/ui_style
	var/ui_color
	var/ui_alpha

/datum/hud/New(mob/owner)
	mymob = owner

	if (!ui_style)
		// will fall back to the default if any of these are null
		ui_style = ui_style2icon(mymob.client?.prefs?.UI_style)

	for(var/mytype in subtypesof(/atom/movable/screen/plane_master))
		var/atom/movable/screen/plane_master/instance = new mytype()
		plane_masters["[instance.plane]"] = instance
		instance.backdrop(mymob)

	for(var/mytype in subtypesof(/atom/movable/plane_master_controller))
		var/atom/movable/plane_master_controller/controller_instance = new mytype(null, src)
		plane_master_controllers[controller_instance.name] = controller_instance

	instantiate()

/datum/hud/Destroy()
	main = null
	adding = null
	hotkeybuttons = null
	complex = null
	hide_actions_toggle = null
	mymob = null
	QDEL_LIST_ASSOC_VAL(plane_masters)
	QDEL_LIST_ASSOC_VAL(plane_master_controllers)
	return ..()

/datum/hud/proc/hidden_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		if(H.handcuffed)
			H.handcuffed.screen_loc = null	//no handcuffs in my UI!
		if(inventory_shown && hud_shown)
			H.shoes?.screen_loc = ui_shoes
			H.gloves?.screen_loc = ui_gloves
			H.l_ear?.screen_loc = ui_l_ear
			H.r_ear?.screen_loc = ui_r_ear
			H.glasses?.screen_loc = ui_glasses
			H.w_uniform?.screen_loc = ui_iclothing
			H.wear_suit?.screen_loc = ui_oclothing
			H.wear_mask?.screen_loc = ui_mask
			H.head?.screen_loc = ui_head
		else
			H.shoes?.screen_loc = null
			H.gloves?.screen_loc = null
			H.l_ear?.screen_loc = null
			H.r_ear?.screen_loc = null
			H.glasses?.screen_loc = null
			H.w_uniform?.screen_loc = null
			H.wear_suit?.screen_loc = null
			H.wear_mask?.screen_loc = null
			H.head?.screen_loc = null


/datum/hud/proc/persistant_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		if(hud_shown)
			H.s_store?.screen_loc = ui_sstore1
			H.wear_id?.screen_loc = ui_id
			H.belt?.screen_loc = ui_belt
			H.back?.screen_loc = ui_back
			H.l_store?.screen_loc = ui_storage1
			H.r_store?.screen_loc = ui_storage2
		else
			H.s_store?.screen_loc = null
			H.wear_id?.screen_loc = null
			H.belt?.screen_loc = null
			H.back?.screen_loc = null
			H.l_store?.screen_loc = null
			H.r_store?.screen_loc = null


/datum/hud/proc/instantiate()
	if(!ismob(mymob) || !mymob.client)
		return FALSE

	var/client/client = mymob.client

	// reset client screen
	client.screen = list()

	mymob.add_to_hud(src)

	if(client.void)
		client.screen += client.void

	return TRUE

//Version denotes which style should be displayed. blank or FALSE means "next version"   //khem, what? return is not used anywhere
/datum/hud/proc/show_hud(version = 0)
	if(!ismob(mymob) || !mymob.client)
		return FALSE

	if(!version)	//If 0 or blank, display the next hud version
		version = hud_version + 1
	if(version > HUD_VERSIONS)	//If the requested version number is greater than the available versions, reset back to the first version
		version = 1
	if(!main.len && version == HUD_STYLE_REDUCED) // skip reduced version if no main hud exists
		version = HUD_STYLE_NOHUD

	var/screen = mymob.client.screen
	var/hud_slots_shown = NONE
	hud_shown = FALSE

	switch(version)
		if(HUD_STYLE_STANDARD)
			hud_shown = TRUE
			hud_slots_shown = ALL
			mymob.action_intent?.set_screen_loc(initial(mymob.action_intent.screen_loc)) //Restore intent selection to the original position
		if(HUD_STYLE_REDUCED)
			hud_slots_shown = HUD_SLOT_MAIN
			mymob.action_intent?.set_screen_loc(ui_acti_alt) //move this to the alternative position, where zone_select usually is.

	if(hud_slots_shown & HUD_SLOT_ADDING)
		screen += adding
	else
		screen -= adding

	if(hud_slots_shown & HUD_SLOT_HOTKEYS && !hotkey_ui_hidden)
		screen += hotkeybuttons
	else
		screen -= hotkeybuttons

	for(var/atom/movable/screen/complex/C as anything in complex)
		if(C.shown)
			if(hud_slots_shown & C.hud_slot)
				screen += C.screens
			else
				screen -= C.screens

	if(hud_slots_shown & HUD_SLOT_MAIN)
		screen += main
	else
		screen -= main

	mymob.update_action_buttons()
	reorganize_alerts()
	create_parallax()
	plane_masters_update()
	hidden_inventory_update()
	persistant_inventory_update()

	hud_version = version

/datum/hud/proc/plane_masters_update()
	// Plane masters are always shown to OUR mob, never to observers
	for(var/thing in plane_masters)
		var/atom/movable/screen/plane_master/PM = plane_masters[thing]
		PM.backdrop(mymob)
		mymob.client.screen += PM

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		hud_used.show_hud() //Shows the next hud preset
		to_chat(usr, "<span class ='info'>Switched HUD mode. Press F12 to toggle.</span>")
	else
		to_chat(usr, "<span class ='warning'>This mob type does not use a HUD.</span>")
