/*
	The global hud:
	Uses the same visual objects for all players.
*/

/datum/hud/var/obj/screen/grab_intent
/datum/hud/var/obj/screen/hurt_intent
/datum/hud/var/obj/screen/disarm_intent
/datum/hud/var/obj/screen/help_intent

/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	var/mob/mymob

	var/hud_shown = 1			//Used for the HUD toggle (F12)
	var/hud_version = 1			//Current displayed version of the HUD
	var/inventory_shown = 1		//the inventory
	var/show_intent_icons = 0
	var/hotkey_ui_hidden = 0	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/screen/lingchemdisplay
	var/obj/screen/lingstingdisplay
	var/obj/screen/blobpwrdisplay
	var/obj/screen/blobhealthdisplay
	var/obj/screen/action_intent
	var/obj/screen/move_intent
	var/obj/screen/staminadisplay

	var/list/adding
	var/list/other
	var/list/obj/screen/hotkeybuttons
	var/list/visible_elements_while_reduced

	var/obj/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0
	var/list/obj/screen/plane_master/plane_masters = list() // see "appearance_flags" in the ref, assoc list of "[plane]" = object

/datum/hud/New(mob/owner)
	mymob = owner
	for(var/mytype in subtypesof(/obj/screen/plane_master))
		var/obj/screen/plane_master/instance = new mytype()
		plane_masters["[instance.plane]"] = instance
	instantiate()
	..()

/datum/hud/Destroy()
	grab_intent = null
	hurt_intent = null
	disarm_intent = null
	help_intent = null
	lingchemdisplay = null
	blobpwrdisplay = null
	blobhealthdisplay = null
	action_intent = null
	move_intent = null
	adding = null
	other = null
	hotkeybuttons = null
	visible_elements_while_reduced = null
	hide_actions_toggle = null
	mymob = null
	if(plane_masters.len)
		for(var/thing in plane_masters)
			qdel(plane_masters[thing])
		plane_masters.Cut()
	return ..()

/datum/hud/proc/hidden_inventory_update()
	if(!mymob)
		return

	if(iscarbon(mymob))
		var/mob/living/carbon/C = mymob
		for(var/obj/item/bodypart/BP in C.bodyparts)
			for(var/slot in BP.item_in_slot)
				var/obj/item/I = BP.item_in_slot[slot]
				if(I)
					if(!BP.inv_box_data[slot]["other"])
						continue
					if(inventory_shown && hud_shown)
						I.screen_loc = BP.inv_box_data[slot]["screen_loc"]
					else
						I.screen_loc = null

/datum/hud/proc/persistent_inventory_update()
	if(!mymob)
		return

	if(iscarbon(mymob))
		var/mob/living/carbon/C = mymob
		for(var/obj/item/bodypart/BP in C.bodyparts)
			for(var/slot in BP.item_in_slot)
				var/obj/item/I = BP.item_in_slot[slot]
				if(I)
					if(!BP.inv_box_data[slot]["persistent_hud"])
						continue
					if(hud_shown)
						I.screen_loc = BP.inv_box_data[slot]["screen_loc"]
					else
						I.screen_loc = null

/datum/hud/proc/instantiate()
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0

	var/ui_style = ui_style2icon(mymob.client.prefs.UI_style)
	var/ui_color = mymob.client.prefs.UI_style_color
	var/ui_alpha = mymob.client.prefs.UI_style_alpha

	if(ishuman(mymob))
		human_hud(ui_style, ui_color, ui_alpha) // Pass the player the UI style chosen in preferences
	else if(isIAN(mymob))
		ian_hud()
	else if(ismonkey(mymob))
		monkey_hud(ui_style)
	else if(isbrain(mymob))
		brain_hud(ui_style)
	else if(isfacehugger(mymob))
		facehugger_hud()
	else if(islarva(mymob))
		larva_hud()
	else if(isalien(mymob))
		alien_hud()
	else if(isAI(mymob))
		ai_hud()
	else if(isrobot(mymob))
		robot_hud()
	else if(isobserver(mymob))
		ghost_hud()
	else if(isovermind(mymob))
		blob_hud()

	if(istype(mymob.loc,/obj/mecha))
		show_hud(HUD_STYLE_REDUCED)

	if(plane_masters.len)
		for(var/thing in plane_masters)
			mymob.client.screen += plane_masters[thing]
	create_parallax()

//Version denotes which style should be displayed. blank or 0 means "next version"
/datum/hud/proc/show_hud(version = 0)
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0
	var/display_hud_version = version
	if(!display_hud_version)	//If 0 or blank, display the next hud version
		display_hud_version = hud_version + 1
	if(display_hud_version > HUD_VERSIONS)	//If the requested version number is greater than the available versions, reset back to the first version
		display_hud_version = 1

	switch(display_hud_version)
		if(HUD_STYLE_STANDARD)	//Default HUD
			hud_shown = 1	//Governs behavior of other procs
			if(adding)
				mymob.client.screen += adding
			if(other && inventory_shown)
				mymob.client.screen += other
			if(hotkeybuttons && !hotkey_ui_hidden)
				mymob.client.screen += hotkeybuttons

			action_intent.screen_loc = ui_acti //Restore intent selection to the original position
			mymob.client.screen += mymob.zone_sel				//This one is a special snowflake
			mymob.client.screen += mymob.healths				//As are the rest of these.
			mymob.client.screen += mymob.healthdoll
			mymob.client.screen += mymob.internals
			mymob.client.screen += lingstingdisplay
			mymob.client.screen += lingchemdisplay
			mymob.client.screen += mymob.gun_setting_icon

			hidden_inventory_update()
			persistent_inventory_update()
			mymob.update_action_buttons()
			reorganize_alerts()
		if(HUD_STYLE_REDUCED)	//Reduced HUD
			hud_shown = 0	//Governs behavior of other procs
			if(adding)
				mymob.client.screen -= adding
			if(other)
				mymob.client.screen -= other
			if(hotkeybuttons)
				mymob.client.screen -= hotkeybuttons

			//These ones are not a part of 'adding', 'other' or 'hotkeybuttons' but we want them gone.
			mymob.client.screen -= mymob.zone_sel	//zone_sel is a mob variable for some reason.
			mymob.client.screen -= lingstingdisplay
			mymob.client.screen -= lingchemdisplay

			//These ones are a part of 'adding', 'other' or 'hotkeybuttons' but we want them to stay
			mymob.client.screen += visible_elements_while_reduced	//we want those elements to be visible
			mymob.client.screen += action_intent		//we want the intent swticher visible
			action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.

			hidden_inventory_update()
			persistent_inventory_update()
			mymob.update_action_buttons()
			reorganize_alerts()
		if(HUD_STYLE_NOHUD)	//No HUD
			hud_shown = 0	//Governs behavior of other procs
			if(adding)
				mymob.client.screen -= adding
			if(other)
				mymob.client.screen -= other
			if(hotkeybuttons)
				mymob.client.screen -= hotkeybuttons

			//These ones are not a part of 'adding', 'other' or 'hotkeybuttons' but we want them gone.
			mymob.client.screen -= mymob.zone_sel	//zone_sel is a mob variable for some reason.
			mymob.client.screen -= mymob.healths
			mymob.client.screen -= mymob.healthdoll
			mymob.client.screen -= mymob.internals
			mymob.client.screen -= lingstingdisplay
			mymob.client.screen -= lingchemdisplay
			mymob.client.screen -= mymob.gun_setting_icon

			hidden_inventory_update()
			persistent_inventory_update()
			mymob.update_action_buttons()
			reorganize_alerts()
	if(plane_masters.len)
		for(var/thing in plane_masters)
			mymob.client.screen += plane_masters[thing]
	hud_version = display_hud_version
	create_parallax()
//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12(var/full = 0 as null)
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		if(ishuman(src))
			hud_used.show_hud() //Shows the next hud preset
			to_chat(usr, "<span class ='info'>Switched HUD mode. Press F12 to toggle.</span>")
		else
			to_chat(usr, "<span class ='warning'>Inventory hiding is currently only supported for human mobs, sorry.</span>")
	else
		to_chat(usr, "<span class ='warning'>This mob type does not use a HUD.</span>")
