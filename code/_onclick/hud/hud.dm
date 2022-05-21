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
	"White" = 'icons/mob/screen1_White.dmi',
	"Midnight" = 'icons/mob/screen1_Midnight.dmi',
	"old" = 'icons/mob/screen1_old.dmi',
	"Orange" = 'icons/mob/screen1_Orange.dmi'
	)

/proc/ui_style2icon(ui_style)
	return global.available_ui_styles[ui_style] || global.available_ui_styles[global.available_ui_styles[1]]

/datum/hud
	var/mob/mymob

	var/hud_shown = FALSE					//Used for the HUD toggle (F12)
	var/hud_version = HUD_STYLE_STANDARD	//Current displayed version of the HUD
	var/inventory_shown = FALSE				//the inventory
	var/hotkey_ui_hidden = FALSE			//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/atom/movable/screen/lingchemdisplay
	var/atom/movable/screen/lingstingdisplay
	var/atom/movable/screen/blobpwrdisplay
	var/atom/movable/screen/blobhealthdisplay

	var/list/main = list()
	var/list/adding = list()
	var/list/hotkeybuttons = list()
	var/list/other = list()

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
	lingchemdisplay = null
	blobpwrdisplay = null
	blobhealthdisplay = null
	main = null
	adding = null
	hotkeybuttons = null
	other = null
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
			if(H.shoes)		H.shoes.screen_loc = ui_shoes
			if(H.gloves)	H.gloves.screen_loc = ui_gloves
			if(H.l_ear)		H.l_ear.screen_loc = ui_l_ear
			if(H.r_ear)		H.r_ear.screen_loc = ui_r_ear
			if(H.glasses)	H.glasses.screen_loc = ui_glasses
			if(H.w_uniform)	H.w_uniform.screen_loc = ui_iclothing
			if(H.wear_suit)	H.wear_suit.screen_loc = ui_oclothing
			if(H.wear_mask)	H.wear_mask.screen_loc = ui_mask
			if(H.head)		H.head.screen_loc = ui_head
		else
			if(H.shoes)		H.shoes.screen_loc = null
			if(H.gloves)	H.gloves.screen_loc = null
			if(H.l_ear)		H.l_ear.screen_loc = null
			if(H.r_ear)		H.r_ear.screen_loc = null
			if(H.glasses)	H.glasses.screen_loc = null
			if(H.w_uniform)	H.w_uniform.screen_loc = null
			if(H.wear_suit)	H.wear_suit.screen_loc = null
			if(H.wear_mask)	H.wear_mask.screen_loc = null
			if(H.head)		H.head.screen_loc = null


/datum/hud/proc/persistant_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		if(hud_shown)
			if(H.s_store)	H.s_store.screen_loc = ui_sstore1
			if(H.wear_id)	H.wear_id.screen_loc = ui_id
			if(H.belt)		H.belt.screen_loc = ui_belt
			if(H.back)		H.back.screen_loc = ui_back
			if(H.l_store)	H.l_store.screen_loc = ui_storage1
			if(H.r_store)	H.r_store.screen_loc = ui_storage2
		else
			if(H.s_store)	H.s_store.screen_loc = null
			if(H.wear_id)	H.wear_id.screen_loc = null
			if(H.belt)		H.belt.screen_loc = null
			if(H.back)		H.back.screen_loc = null
			if(H.l_store)	H.l_store.screen_loc = null
			if(H.r_store)	H.r_store.screen_loc = null


/datum/hud/proc/instantiate()
	if(!ismob(mymob) || !mymob.client)
		return FALSE

	var/client/client = mymob.client

	// reset client screen
	client.screen = list()

	if(ishuman(mymob))
		 // Set the player the UI style chosen in preferences
		ui_color = client.prefs.UI_style_color
		ui_alpha = client.prefs.UI_style_alpha
		human_hud()
	else if(isIAN(mymob))
		ian_hud()
	else if(ismonkey(mymob))
		monkey_hud()
	else if(isbrain(mymob))
		brain_hud()
	else if(isfacehugger(mymob))
		facehugger_hud()
	else if(isxenolarva(mymob))
		larva_hud()
	else if(isxeno(mymob))
		alien_hud()
	else if(isAI(mymob))
		ai_hud()
	else if(isrobot(mymob))
		robot_hud()
	else if(isobserver(mymob))
		show_hud(HUD_STYLE_STANDARD)
	else if(isovermind(mymob))
		blob_hud()
	else if(isessence(mymob))
		changeling_essence_hud()
	else if(isliving(mymob))
		ui_color = client.prefs.UI_style_color
		ui_alpha = client.prefs.UI_style_alpha
		default_hud()

	client.screen += main
	client.screen += adding + hotkeybuttons
	hud_shown = TRUE

	if(client.void)
		client.screen += client.void

	if(istype(mymob.loc,/obj/mecha))
		show_hud(HUD_STYLE_REDUCED)

	reorganize_alerts()
	create_parallax()

	// See the comment from "/mob/living/carbon/human/create_mob_hud()"
	// If comment does not exist, then delete code below and this comment
	if(!ishuman(mymob))
		plane_masters_update()

	return TRUE

//Version denotes which style should be displayed. blank or FALSE means "next version"   //khem, what? return is not used anywhere
/datum/hud/proc/show_hud(version = 0)
	if(!ismob(mymob) || !mymob.client)
		return FALSE

	if(!version)	//If 0 or blank, display the next hud version
		version = hud_version + 1
	if(version > HUD_VERSIONS)	//If the requested version number is greater than the available versions, reset back to the first version
		version = 1

	switch(version)
		if(HUD_STYLE_STANDARD)	//Default HUD
			hud_shown = TRUE	//Governs behavior of other procs

			mymob.client.screen += adding

			if(inventory_shown)
				mymob.client.screen += other
			if(!hotkey_ui_hidden)
				mymob.client.screen += hotkeybuttons

			action_intent?.screen_loc = initial(action_intent.screen_loc) //Restore intent selection to the original position
			mymob.client.screen += main

		if(HUD_STYLE_REDUCED)	//Reduced HUD
			hud_shown = FALSE	//Governs behavior of other procs

			mymob.client.screen -= adding
			mymob.client.screen -= other
			mymob.client.screen -= hotkeybuttons
			
			action_intent?.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.
			mymob.client.screen += main

		if(HUD_STYLE_NOHUD)	//No HUD
			hud_shown = FALSE	//Governs behavior of other procs

			mymob.client.screen -= adding
			mymob.client.screen -= other
			mymob.client.screen -= hotkeybuttons
			mymob.client.screen -= main

	hidden_inventory_update()
	persistant_inventory_update()
	mymob.update_action_buttons()
	reorganize_alerts()

	hud_version = version
	create_parallax()
	plane_masters_update()

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
		if(ishuman(src) || isobserver(src))
			hud_used.show_hud() //Shows the next hud preset
			to_chat(usr, "<span class ='info'>Switched HUD mode. Press F12 to toggle.</span>")
		else
			to_chat(usr, "<span class ='warning'>Inventory hiding is currently only supported for human mobs, sorry.</span>")
	else
		to_chat(usr, "<span class ='warning'>This mob type does not use a HUD.</span>")
