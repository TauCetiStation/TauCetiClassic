/*
	The global hud:
	Uses the same visual objects for all players.
*/

/datum/hud/var/obj/screen/grab_intent
/datum/hud/var/obj/screen/harm_intent
/datum/hud/var/obj/screen/push_intent
/datum/hud/var/obj/screen/help_intent

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

	var/hud_shown = 1			//Used for the HUD toggle (F12)
	var/hud_version = 1			//Current displayed version of the HUD
	var/inventory_shown = 1		//the inventory
	var/show_intent_icons = 0
	var/hotkey_ui_hidden = 0	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/screen/lingchemdisplay
	var/obj/screen/lingstingdisplay
	var/obj/screen/blobpwrdisplay
	var/obj/screen/blobhealthdisplay
	var/obj/screen/r_hand_hud_object
	var/obj/screen/l_hand_hud_object
	var/obj/screen/action_intent
	var/obj/screen/move_intent
	var/obj/screen/staminadisplay

	var/list/adding
	var/list/other
	var/list/obj/screen/hotkeybuttons

	var/obj/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0
	var/list/obj/screen/plane_master/plane_masters = list() // see "appearance_flags" in the ref, assoc list of "[plane]" = object

	// subtypes can override this to force a specific UI style
	var/ui_style

/datum/hud/New(mob/owner)
	mymob = owner

	if (!ui_style)
		// will fall back to the default if any of these are null
		ui_style = ui_style2icon(mymob.client && mymob.client.prefs && mymob.client.prefs.UI_style)

	for(var/mytype in subtypesof(/obj/screen/plane_master))
		var/obj/screen/plane_master/instance = new mytype()
		plane_masters["[instance.plane]"] = instance
		instance.backdrop(mymob)

	instantiate()

/datum/hud/Destroy()
	grab_intent = null
	harm_intent = null
	push_intent = null
	help_intent = null
	lingchemdisplay = null
	blobpwrdisplay = null
	blobhealthdisplay = null
	r_hand_hud_object = null
	l_hand_hud_object = null
	action_intent = null
	move_intent = null
	adding = null
	other = null
	hotkeybuttons = null
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
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0

	var/ui_color = mymob.client.prefs.UI_style_color
	var/ui_alpha = mymob.client.prefs.UI_style_alpha

	if(ishuman(mymob))
		human_hud(ui_color, ui_alpha) // Pass the player the UI style chosen in preferences
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
		default_hud(ui_color, ui_alpha)

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
			persistant_inventory_update()
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
			mymob.client.screen += l_hand_hud_object	//we want the hands to be visible
			mymob.client.screen += r_hand_hud_object	//we want the hands to be visible
			mymob.client.screen += action_intent		//we want the intent swticher visible
			action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.

			hidden_inventory_update()
			persistant_inventory_update()
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
			persistant_inventory_update()
			mymob.update_action_buttons()
			reorganize_alerts()
	if(plane_masters.len)
		for(var/thing in plane_masters)
			mymob.client.screen += plane_masters[thing]
	hud_version = display_hud_version
	create_parallax()
	plane_masters_update()

/datum/hud/proc/plane_masters_update()
	// Plane masters are always shown to OUR mob, never to observers
	for(var/thing in plane_masters)
		var/obj/screen/plane_master/PM = plane_masters[thing]
		PM.backdrop(mymob)
		mymob.client.screen += PM

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12(var/full = 0 as null)
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
