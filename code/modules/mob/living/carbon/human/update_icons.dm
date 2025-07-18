	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/*
NOTE: no one updates these hidden guides, better to check code for more up to date information
todo: remove this and add commentaries for procs

Calling this  a system is perhaps a bit trumped up. It is essentially update_clothing dismantled into its
core parts. The key difference is that when we generate overlays we do not generate either lying or standing
versions. Instead, we generate both and store them in two fixed-length lists, both using the same list-index
(The indexes are in update_icons.dm): Each list for humans is (at the time of writing) of length 19.
This will hopefully be reduced as the system is refined.

	var/overlays_lying[19]			//For the lying down stance
	var/overlays_standing[19]		//For the standing stance

When we call update_icons, the 'lying' variable is checked and then the appropriate list is assigned to our overlays!
That in itself uses a tiny bit more memory (no more than all the ridiculous lists the game has already mind you).

On the other-hand, it should be very CPU cheap in comparison to the old system.
In the old system, we updated all our overlays every life() call, even if we were standing still inside a crate!
or dead!. 25ish overlays, all generated from scratch every second for every xeno/human/monkey and then applied.
More often than not update_clothing was being called a few times in addition to that! CPU was not the only issue,
all those icons had to be sent to every client. So really the cost was extremely cumulative. To the point where
update_clothing would frequently appear in the top 10 most CPU intensive procs during profiling.

Another feature of this new system is that our lists are indexed. This means we can update specific overlays!
So we only regenerate icons when we need them to be updated! This is the main saving for this system.

In practice this means that:
	everytime you fall over, we just switch between precompiled lists. Which is fast and cheap.
	Everytime you do something minor like take a pen out of your pocket, we only update the in-hand overlay
	etc...


There are several things that need to be remembered:

>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src) )
	You will need to call the relevant update_inv_* proc:
		update_inv_head()
		update_inv_wear_suit()
		update_inv_gloves()
		update_inv_shoes()
		update_inv_w_uniform()
		update_inv_glasse()
		update_inv_l_hand()
		update_inv_r_hand()
		update_inv_belt()
		update_inv_wear_id()
		update_inv_ears()
		update_inv_s_store()
		update_inv_pockets()
		update_inv_back()
		update_inv_handcuffed()
		update_inv_wear_mask()

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.


>	There are also these special cases:
		update_mutations()	//handles updating your appearance for certain mutations.  e.g TK head-glows
		UpdateDamageIcon()	//handles damage overlays for brute/burn damage //(will rename this when I geta round to it)
		update_body()	//Handles updating your mob's icon to reflect their gender/race/complexion etc
		update_hair()	//Handles updating your hair overlay (used to be update_face, but mouth and
																			...eyes were merged into update_body)
		update_targeted() // Updates the target overlay when someone points a gun at you

>	All of these procs update our overlays_lying and overlays_standing, and then call update_icons() by default.
	If you wish to update several overlays at once, you can set the argument to 0 to disable the update and call
	it manually:
		e.g.
		update_inv_head()
		update_inv_l_hand()
		update_inv_r_hand()		//<---calls update_icons()

	or equivillantly:
		update_inv_head()
		update_inv_l_hand()
		update_inv_r_hand()
		update_icons()

>	If you need to update all overlays you can use regenerate_icons(). it works exactly like update_clothing used to.

>	I reimplimented an old unused variable which was in the code called (coincidentally) var/update_icon
	It can be used as another method of triggering regenerate_icons(). It's basically a flag that when set to non-zero
	will call regenerate_icons() at the next life() call and then reset itself to 0.
	The idea behind it is icons are regenerated only once, even if multiple events requested it.

This system is confusing and is still a WIP. It's primary goal is speeding up the controls of the game whilst
reducing processing costs. So please bear with me while I iron out the kinks. It will be worth it, I promise.
If I can eventually free var/lying stuff from the life() process altogether, stuns/death/status stuff
will become less affected by lag-spikes and will be instantaneous! :3

If you have any questions/constructive-comments/bugs-to-report/or have a massivly devestated butt...
Please contact me on #coderbus IRC. ~Carn x
*/

/obj/item/proc/get_standing_overlay(mob/living/carbon/human/H, def_icon_path, sprite_sheet_slot, layer, bloodied_icon_state = null, icon_state_appendix = null)
	var/icon_path = def_icon_path

	var/t_state
	if(sprite_sheet_slot in list(SPRITE_SHEET_HELD, SPRITE_SHEET_GLOVES, SPRITE_SHEET_BELT, SPRITE_SHEET_UNIFORM, SPRITE_SHEET_UNIFORM_FAT, SPRITE_SHEET_EARS))
		t_state = item_state
		if(!icon_custom)
			icon_state_appendix = null

	if(!t_state)
		t_state = icon_state

	var/datum/species/S = H.species

	if(icon_custom)
		if(sprite_sheet_slot != SPRITE_SHEET_HELD)
			icon_state_appendix = "_mob"
		icon_path = icon_custom
	else if(icon_override)
		icon_path = icon_override
	else if(S.sprite_sheets[sprite_sheet_slot])
		icon_path = S.sprite_sheets[sprite_sheet_slot]

	if(icon_path != def_icon_path && !icon_exists(icon_path, "[t_state][icon_state_appendix]"))
		icon_path = def_icon_path

	var/fem = ""
	if(H.gender == FEMALE && S.gender_limb_icons)
		if(t_state != null)
			if(icon_exists(icon_path, "[t_state]_fem"))
				fem = "_fem"

	var/mutable_appearance/I = mutable_appearance(icon = icon_path, icon_state = "[t_state][fem][icon_state_appendix]", layer = layer)
	I.color = color

	if(dirt_overlay && bloodied_icon_state)
		var/mutable_appearance/bloodsies = mutable_appearance(icon = 'icons/effects/blood.dmi', icon_state = bloodied_icon_state)
		bloodsies.color = dirt_overlay.color
		I.add_overlay(bloodsies)

	return I

/mob/living/carbon/human
	overlays_standing = new /list(TOTAL_LAYERS)
	var/list/overlays_damage[TOTAL_LIMB_LAYERS]

/mob/living/carbon/human/proc/apply_damage_overlay(cache_index)
	var/image/I = overlays_damage[cache_index]
	if(I)
		add_overlay(I)

/mob/living/carbon/human/proc/remove_damage_overlay(cache_index)
	if(overlays_damage[cache_index])
		cut_overlay(overlays_damage[cache_index])
		overlays_damage[cache_index] = null

//UPDATES OVERLAYS FROM OVERLAYS_LYING/OVERLAYS_STANDING
//this proc is messy as I was forced to include some old laggy cloaking code to it so that I don't break cloakers
//I'll work on removing that stuff by rewriting some of the cloaking stuff at a later date.
/mob/living/carbon/human/update_icons()
	update_hud()		//TODO: remove the need for this


//DAMAGE OVERLAYS
/mob/living/carbon/human/UpdateDamageIcon(obj/item/organ/external/BP)
	if(!BP.limb_layer) // some limbs don't have damage overlays
		return
	remove_damage_overlay(BP.limb_layer)
	// todo: make set of pre-backed fulltile perlin noise masks and use SUBTRACT blending
	// currently it's hard to keep masks up to date with all respites and new body parts
	if(BP.damage_state == "00") // don't add empty overlays for damage
		return
	if(species.damage_mask && (BP in bodyparts))
		var/image/standing = image("icon" = 'icons/mob/human/masks/damage_overlays.dmi', "icon_state" = "[BP.body_zone]_[BP.damage_state]", "layer" = -DAMAGE_LAYER)
		standing.color = BP.damage_state_color()
		standing = update_height(standing)
		overlays_damage[BP.limb_layer] = standing
		apply_damage_overlay(BP.limb_layer)



/mob/living/carbon/human/proc/update_render_flags(render_flags)
	if(render_flags & HIDE_TAIL)
		update_body(BP_TAIL)
	if(render_flags & HIDE_WINGS)
		update_body(BP_WINGS)
	if(render_flags & (HIDE_TOP_HAIR | HIDE_FACIAL_HAIR))
		update_body(BP_HEAD)
	//if(render_flags & HIDE_UNIFORM) // update_inv_w_uniform should be called by equip anyway
	//	update_inv_w_uniform()

//BASE MOB SPRITE
/mob/living/carbon/human/proc/update_body(bodypart_index, update_preferences = FALSE)
	remove_standing_overlay(BODY_LAYER)

	if(bodypart_index)
		var/obj/item/organ/external/BP = bodyparts_by_name[bodypart_index]
		if(BP && !BP.is_stump)
			bodypart_overlays_standing[bodypart_index] = BP.generate_appearances(update_preferences)
		else
			bodypart_overlays_standing -= bodypart_index
	else // regenerate all sprites
		bodypart_overlays_standing = list()

		for(var/obj/item/organ/external/BP in bodyparts)
			if(BP.is_stump)
				continue
			bodypart_overlays_standing[BP.body_zone] = BP.generate_appearances(update_preferences)

	// group overlays by layer so we can save on filters count

	var/list/mutable_appearance/grouped_by_layer = list() // alist, some day
	var/list/standing = list()

	for(var/index in bodypart_overlays_standing)
		for(var/mutable_appearance/overlay in bodypart_overlays_standing[index])
			if(!grouped_by_layer["[overlay.layer]"])
				grouped_by_layer["[overlay.layer]"] = list()
			grouped_by_layer["[overlay.layer]"] += overlay

	for(var/layer in grouped_by_layer)
		var/mutable_appearance/MA = new()
		MA.appearance_flags = KEEP_TOGETHER // or height filters will ignore our overlays
		MA.layer = text2num(layer)
		MA.overlays = grouped_by_layer[layer]

		// update height offsets and filters
		switch(MA.layer)
			if(-HAIR_LAYER) // shift hair instead of filter
				MA = human_update_offset(MA, TRUE)
			if(ABOVE_LIGHTING_LAYER) // glowing eyes. Fuck, this looks so bad.
				MA = human_update_offset(MA, TRUE)
			//if(BODY_INFRONT_LAYER, BODY_BEHIND_LAYER) // todo: need to choice between filter and offset
			//	MA = human_update_offset(MA)
			else
				MA = update_height(MA)

		standing += MA

	// BODY_LAYER just used here as a cache index, keep in mind that it can contain overlays with any other layer
	overlays_standing[BODY_LAYER] = standing
	apply_standing_overlay(BODY_LAYER)

#define BODY_ICON(icon, fat_icon, icon_state) (!fat) ? mutable_appearance(icon, icon_state, -UNDERWEAR_LAYER) : mutable_appearance(fat_icon, icon_state, -UNDERWEAR_LAYER)

/mob/living/carbon/human/proc/update_underwear()
	remove_standing_overlay(UNDERWEAR_LAYER)

	var/fat = HAS_TRAIT(src, TRAIT_FAT) ? "fat" : null
	var/g = (gender == FEMALE ? "f" : "m")

	var/list/standing = list()

	if(species.name == VOX)
		var/mutable_appearance/tatoo = mutable_appearance('icons/mob/human.dmi', "[vox_rank]_s", -UNDERWEAR_LAYER)
		tatoo.color = rgb(r_eyes, g_eyes, b_eyes)
		tatoo = update_height(tatoo)
		tatoo.pixel_x += species.offset_features[OFFSET_UNIFORM][1]
		tatoo.pixel_y += species.offset_features[OFFSET_UNIFORM][2]
		standing += tatoo

	//Underwear
	if((underwear > 0) && (underwear < 12) && species.flags[HAS_UNDERWEAR])
		var/mutable_appearance/MA = BODY_ICON('icons/mob/human_underwear.dmi', 'icons/mob/human_underwear_fat.dmi', "underwear[underwear]_[g]_s")
		MA.pixel_x += species.offset_features[OFFSET_UNIFORM][1]
		MA.pixel_y += species.offset_features[OFFSET_UNIFORM][2]
		MA = update_height(MA)
		standing += MA

	if((undershirt > 0) && (undershirt < undershirt_t.len) && species.flags[HAS_UNDERWEAR])
		var/mutable_appearance/MA = BODY_ICON('icons/mob/human_undershirt.dmi', 'icons/mob/human_undershirt_fat.dmi', "undershirt[undershirt]_s_[g]")
		MA.pixel_x += species.offset_features[OFFSET_UNIFORM][1]
		MA.pixel_y += species.offset_features[OFFSET_UNIFORM][2]
		MA = update_height(MA)
		standing += MA

	if(socks > 0 && socks < socks_t.len && species.flags[HAS_UNDERWEAR])
		var/obj/item/organ/external/r_foot = bodyparts_by_name[BP_R_LEG]
		var/obj/item/organ/external/l_foot = bodyparts_by_name[BP_L_LEG]
		if(r_foot && !r_foot.is_stump && l_foot && !l_foot.is_stump)
			var/mutable_appearance/MA = BODY_ICON('icons/mob/human_socks.dmi', 'icons/mob/human_socks_fat.dmi', "socks[socks]_s_[g]")
			MA.pixel_x += species.offset_features[OFFSET_SHOES][1]
			MA.pixel_y += species.offset_features[OFFSET_SHOES][2]
			MA = update_height(MA)
			standing += MA

	overlays_standing[UNDERWEAR_LAYER] = standing
	apply_standing_overlay(UNDERWEAR_LAYER)

#undef BODY_ICON

/mob/living/carbon/human/update_mutations()
	remove_standing_overlay(MUTATIONS_LAYER)

	var/list/standing = list()
	var/fat = HAS_TRAIT(src, TRAIT_FAT) ? "fat" : null
	var/g = (gender == FEMALE) ? "f" : "m"

	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(gene.is_active(src))
			var/image/underlay = image("icon"='icons/effects/genetics.dmi', "icon_state"=gene.OnDrawUnderlays(src,g,fat), "layer"=-MUTATIONS_LAYER)
			if(underlay)
				standing += underlay
	if(standing.len)
		for(var/image/I in standing)
			I = update_height(I)
		overlays_standing[MUTATIONS_LAYER]	= standing

	apply_standing_overlay(MUTATIONS_LAYER)

//Call when target overlay should be added/removed
/mob/living/carbon/human/update_targeted()
	remove_standing_overlay(TARGETED_LAYER)

	if(targeted_by && target_locked)
		overlays_standing[TARGETED_LAYER]	= image("icon"=target_locked, "layer"=-TARGETED_LAYER)
	else if (!targeted_by && target_locked)
		qdel(target_locked)

	apply_standing_overlay(TARGETED_LAYER)


/mob/living/carbon/human/update_fire() //TG-stuff, fire layer
	remove_standing_overlay(FIRE_LOWER_LAYER)
	remove_standing_overlay(FIRE_UPPER_LAYER)

	if(on_fire)
		var/image/under = image('icons/mob/OnFire.dmi', "[species.specie_suffix_fire_icon]_underlay", layer = -FIRE_LOWER_LAYER)
		var/image/over = image('icons/mob/OnFire.dmi', "[species.specie_suffix_fire_icon]_overlay", layer = -FIRE_UPPER_LAYER)
		under = update_height(under)
		over = update_height(over)
		over.plane = LIGHTING_LAMPS_PLANE
		overlays_standing[FIRE_LOWER_LAYER] = under
		overlays_standing[FIRE_UPPER_LAYER] = over

	apply_standing_overlay(FIRE_LOWER_LAYER)
	apply_standing_overlay(FIRE_UPPER_LAYER)


/* --------------------------------------- */
//For legacy support.
// direct calls for update_* is more preferable, but currently there is no other methods to update height filters everywhere
// update_body_preferences is for when you want bodyparts to pull new mob settings like hair or skin color (but it can break implanted bodyparts that keep old owner preferences)
/mob/living/carbon/human/regenerate_icons(update_body_preferences = FALSE)
	..()
	if(notransform)
		return
	update_mutations()
	update_body(update_preferences = update_body_preferences)
	update_underwear()
	update_inv_w_uniform()
	update_inv_wear_id()
	update_inv_gloves()
	update_inv_glasses()
	update_inv_r_ear()
	update_inv_l_ear()
	update_inv_shoes()
	update_inv_s_store()
	update_inv_wear_mask()
	update_inv_neck()
	update_inv_head()
	update_inv_belt()
	update_inv_back()
	update_inv_wear_suit()
	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_handcuffed()
	update_inv_legcuffed()
	update_inv_pockets()
	update_surgery()
	update_bandage()
	for(var/obj/item/organ/external/BP in bodyparts)
		UpdateDamageIcon(BP)
	update_icons()
	update_transform()
	//Hud Stuff
	update_hud()


/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform()
	remove_standing_overlay(UNIFORM_LAYER)

	var/default_path = 'icons/mob/uniform.dmi'
	var/uniform_sheet = SPRITE_SHEET_UNIFORM
	if(isunder(w_uniform))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				w_uniform.screen_loc = ui_iclothing //...draw the item in the inventory screen
			client.screen += w_uniform				//Either way, add the item to the HUD

		var/obj/item/clothing/under/U = w_uniform
		if (wear_suit?.render_flags & HIDE_UNIFORM) // Skip uniform overlay on suit full cover
			return

		if(HAS_TRAIT(src, TRAIT_FAT))
			if(U.flags & ONESIZEFITSALL)
				default_path = 'icons/mob/uniform_fat.dmi'
				uniform_sheet = SPRITE_SHEET_UNIFORM_FAT
			else
				to_chat(src, "<span class='warning'>You burst out of \the [U]!</span>")
				drop_from_inventory(U)
				return
		var/image/standing = U.get_standing_overlay(src, default_path, uniform_sheet, -UNIFORM_LAYER, "uniformblood")
		standing = update_height(standing)
		standing.pixel_x += species.offset_features[OFFSET_UNIFORM][1]
		standing.pixel_y += species.offset_features[OFFSET_UNIFORM][2]
		overlays_standing[UNIFORM_LAYER] = standing

		for(var/obj/item/clothing/accessory/A in U.accessories)
			var/t_state = A.icon_state
			var/icon_path = 'icons/mob/accessory.dmi'

			if(A.icon_custom)
				t_state += "_mob"
				icon_path = A.icon_custom

			if(gender == FEMALE && species.gender_limb_icons)
				if(icon_exists(icon_path, "[t_state]_fem"))
					t_state += "_fem"

			var/image/accessory
			accessory = image("icon" = icon_path, "icon_state" = t_state, "layer" = -UNIFORM_LAYER + A.layer_priority)
			accessory.color = A.color
			accessory = human_update_offset(accessory, TRUE)
			standing.add_overlay(accessory)
	else
		// Automatically drop anything in store / id / belt if you're not wearing a uniform.	//CHECK IF NECESARRY
		for(var/obj/item/thing in list(r_store, l_store, wear_id, belt))						//
			drop_from_inventory(thing)

	apply_standing_overlay(UNIFORM_LAYER)


/mob/living/carbon/human/update_inv_wear_id()
	remove_standing_overlay(ID_LAYER)
	if(wear_id)
		wear_id.screen_loc = ui_id
		if(client && hud_used)
			client.screen += wear_id
		var/image/standing = image("icon"='icons/mob/mob.dmi', "icon_state"="id", "layer"=-ID_LAYER)
		standing = human_update_offset(standing, TRUE)
		standing.pixel_x += species.offset_features[OFFSET_ID][1]
		standing.pixel_y += species.offset_features[OFFSET_ID][2]
		overlays_standing[ID_LAYER]	= standing

	apply_standing_overlay(ID_LAYER)

/mob/living/carbon/human/update_inv_gloves()
	remove_standing_overlay(GLOVES_LAYER)
	if(gloves)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				gloves.screen_loc = ui_gloves		//...draw the item in the inventory screen
			client.screen += gloves					//Either way, add the item to the HUD

		var/image/standing = gloves.get_standing_overlay(src, 'icons/mob/hands.dmi', SPRITE_SHEET_GLOVES, -GLOVES_LAYER, "bloodyhands")
		standing = human_update_offset(standing, FALSE)
		standing.pixel_x += species.offset_features[OFFSET_GLOVES][1]
		standing.pixel_y += species.offset_features[OFFSET_GLOVES][2]
		overlays_standing[GLOVES_LAYER] = standing
	else
		if(blood_DNA)
			var/image/bloodsies = image("icon"='icons/effects/blood.dmi', "icon_state" = species.specie_hand_blood_state)
			bloodsies.color = hand_dirt_datum.color
			bloodsies = human_update_offset(bloodsies, FALSE)
			bloodsies.pixel_x += species.offset_features[OFFSET_GLOVES][1]
			bloodsies.pixel_y += species.offset_features[OFFSET_GLOVES][2]
			overlays_standing[GLOVES_LAYER]	= bloodsies

	apply_standing_overlay(GLOVES_LAYER)


/mob/living/carbon/human/update_inv_glasses()
	remove_standing_overlay(GLASSES_LAYER)

	if(glasses)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
			client.screen += glasses				//Either way, add the item to the HUD

		var/image/standing = glasses.get_standing_overlay(src, 'icons/mob/eyes.dmi', SPRITE_SHEET_EYES, -GLASSES_LAYER)
		standing = human_update_offset(standing, TRUE)
		standing.pixel_x += species.offset_features[OFFSET_GLASSES][1]
		standing.pixel_y += species.offset_features[OFFSET_GLASSES][2]
		overlays_standing[GLASSES_LAYER] = standing

	apply_standing_overlay(GLASSES_LAYER)


/mob/living/carbon/human/update_inv_l_ear()
	remove_standing_overlay(L_EAR_LAYER)
	if(l_ear)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				l_ear.screen_loc = ui_l_ear			//...draw the item in the inventory screen
			client.screen += l_ear					//Either way, add the item to the HUD

		var/image/standing = l_ear.get_standing_overlay(src, 'icons/mob/l_ear.dmi', SPRITE_SHEET_EARS, -L_EAR_LAYER)
		standing = human_update_offset(standing, TRUE)
		standing.pixel_x += species.offset_features[OFFSET_EARS][1]
		standing.pixel_y += species.offset_features[OFFSET_EARS][2]
		overlays_standing[L_EAR_LAYER] = standing

	apply_standing_overlay(L_EAR_LAYER)

/mob/living/carbon/human/update_inv_r_ear()
	remove_standing_overlay(R_EAR_LAYER)
	if(r_ear)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)		//if the inventory is open ...
				r_ear.screen_loc = ui_r_ear		//...draw the item in the inventory screen
			client.screen += r_ear				//Either way, add the item to the HUD

		var/image/standing = r_ear.get_standing_overlay(src, 'icons/mob/r_ear.dmi', SPRITE_SHEET_EARS, -R_EAR_LAYER)
		standing = human_update_offset(standing, TRUE)
		standing.pixel_x += species.offset_features[OFFSET_EARS][1]
		standing.pixel_y += species.offset_features[OFFSET_EARS][2]
		overlays_standing[R_EAR_LAYER] = standing

	apply_standing_overlay(R_EAR_LAYER)


/mob/living/carbon/human/update_inv_shoes()
	remove_standing_overlay(SHOES_LAYER)

	if(shoes)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				shoes.screen_loc = ui_shoes			//...draw the item in the inventory screen
			client.screen += shoes					//Either way, add the item to the HUD

		var/image/standing = shoes.get_standing_overlay(src, 'icons/mob/feet.dmi', SPRITE_SHEET_FEET, -SHOES_LAYER, "shoeblood")
		standing.pixel_x += species.offset_features[OFFSET_SHOES][1]
		standing.pixel_y += species.offset_features[OFFSET_SHOES][2]
		overlays_standing[SHOES_LAYER] = standing
	else
		if(feet_blood_DNA)
			var/image/bloodsies = image("icon"='icons/effects/blood.dmi', "icon_state" = species.specie_shoe_blood_state)
			bloodsies.color = feet_dirt_color.color
			bloodsies.pixel_x += species.offset_features[OFFSET_SHOES][1]
			bloodsies.pixel_y += species.offset_features[OFFSET_SHOES][2]
			overlays_standing[SHOES_LAYER] = bloodsies
		else
			overlays_standing[SHOES_LAYER] = null

	apply_standing_overlay(SHOES_LAYER)


/mob/living/carbon/human/update_inv_s_store()
	remove_standing_overlay(SUIT_STORE_LAYER)

	if(s_store)
		s_store.screen_loc = ui_sstore1
		if(client && hud_used)
			client.screen += s_store

		var/t_state = s_store.item_state
		if(!t_state)	t_state = s_store.icon_state
		var/image/standing = image("icon"='icons/mob/belt_mirror.dmi', "icon_state"="[t_state]", "layer"=-SUIT_STORE_LAYER)
		standing.color = s_store.color
		standing = human_update_offset(standing, TRUE)
		standing.pixel_x += species.offset_features[OFFSET_S_STORE][1]
		standing.pixel_y += species.offset_features[OFFSET_S_STORE][2]
		overlays_standing[SUIT_STORE_LAYER]	= standing

	apply_standing_overlay(SUIT_STORE_LAYER)


/mob/living/carbon/human/update_inv_head()
	remove_standing_overlay(HEAD_LAYER)

	if(head)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				head.screen_loc = ui_head			//...draw the item in the inventory screen
			client.screen += head					//Either way, add the item to the HUD

		var/image/standing
		if(istype(head,/obj/item/clothing/head/kitty))
			var/obj/item/clothing/head/kitty/K = head
			standing = image("icon"=K.mob, "layer"=-HEAD_LAYER)
			standing.color = K.color

			if(K.dirt_overlay)
				var/image/bloodsies = image("icon"='icons/effects/blood.dmi', "icon_state"="helmetblood")
				bloodsies.color = K.dirt_overlay.color
				standing.overlays += bloodsies
		else
			standing = head.get_standing_overlay(src, 'icons/mob/head.dmi', SPRITE_SHEET_HEAD, -HEAD_LAYER, "helmetblood")

		standing = human_update_offset(standing, TRUE)
		standing.pixel_x += species.offset_features[OFFSET_HEAD][1]
		standing.pixel_y += species.offset_features[OFFSET_HEAD][2]
		overlays_standing[HEAD_LAYER] = standing

	apply_standing_overlay(HEAD_LAYER)


/mob/living/carbon/human/update_inv_belt()
	remove_standing_overlay(BELT_LAYER)

	if(belt)
		belt.screen_loc = ui_belt
		if(client && hud_used)
			client.screen += belt

		var/image/standing = belt.get_standing_overlay(src, 'icons/mob/belt.dmi', SPRITE_SHEET_BELT, -BELT_LAYER)
		standing = human_update_offset(standing, FALSE)
		standing.pixel_x += species.offset_features[OFFSET_BELT][1]
		standing.pixel_y += species.offset_features[OFFSET_BELT][2]
		overlays_standing[BELT_LAYER] = standing

	apply_standing_overlay(BELT_LAYER)

/mob/living/carbon/human/update_inv_wear_suit()
	remove_standing_overlay(SUIT_LAYER)
	var/default_path = 'icons/mob/suit.dmi'

	if(istype(wear_suit, /obj/item/clothing/suit))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				wear_suit.screen_loc = ui_oclothing	//...draw the item in the inventory screen
			client.screen += wear_suit				//Either way, add the item to the HUD

		var/obj/item/clothing/suit/S = wear_suit

		var/suit_sheet = SPRITE_SHEET_SUIT
		if(HAS_TRAIT(src, TRAIT_FAT))
			if(wear_suit.flags & ONESIZEFITSALL)
				suit_sheet = SPRITE_SHEET_SUIT_FAT
				default_path = 'icons/mob/suit_fat.dmi'
			else
				to_chat(src, "<span class='warning'>You burst out of \the [wear_suit]!</span>")
				drop_from_inventory(wear_suit)
				return

		var/image/standing = S.get_standing_overlay(src, default_path, suit_sheet, -SUIT_LAYER, "[S.blood_overlay_type]blood")
		standing = update_height(standing)
		standing.pixel_x += species.offset_features[OFFSET_SUIT][1]
		standing.pixel_y += species.offset_features[OFFSET_SUIT][2]
		overlays_standing[SUIT_LAYER] = standing

		for(var/obj/item/clothing/accessory/A in S.accessories)
			var/tie_color = A.icon_state
			var/image/tie
			if(A.icon_custom)
				tie = image("icon" = A.icon_custom, "icon_state" = "[tie_color]_mob", "layer" = -SUIT_LAYER + A.layer_priority)
			else
				tie = image("icon" = 'icons/mob/accessory.dmi', "icon_state" = "[tie_color]", "layer" = -SUIT_LAYER + A.layer_priority)
			tie.color = A.color
			tie = human_update_offset(tie, TRUE)
			standing.add_overlay(tie)

		if(istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			drop_from_inventory(handcuffed)
			drop_l_hand()
			drop_r_hand()
		update_inv_shoes()

	update_inv_w_uniform()
	update_inv_neck()

	apply_standing_overlay(SUIT_LAYER)


/mob/living/carbon/human/update_inv_pockets()
	if(l_store)
		l_store.screen_loc = ui_storage1
		if(client && hud_used)
			client.screen += l_store
	if(r_store)
		r_store.screen_loc = ui_storage2
		if(client && hud_used)
			client.screen += r_store


/mob/living/carbon/human/update_inv_wear_mask()
	remove_standing_overlay(FACEMASK_LAYER)

	if(istype(wear_mask, /obj/item/clothing/mask) || istype(wear_mask, /obj/item/clothing/accessory))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				wear_mask.screen_loc = ui_mask		//...draw the item in the inventory screen
			client.screen += wear_mask				//Either way, add the item to the HUD

		var/image/standing = wear_mask.get_standing_overlay(src, 'icons/mob/mask.dmi', SPRITE_SHEET_MASK, -FACEMASK_LAYER, "maskblood")
		standing = human_update_offset(standing, TRUE)
		standing.pixel_x += species.offset_features[OFFSET_FACEMASK][1]
		standing.pixel_y += species.offset_features[OFFSET_FACEMASK][2]
		overlays_standing[FACEMASK_LAYER]	= standing

	apply_standing_overlay(FACEMASK_LAYER)

/mob/living/carbon/human/update_inv_neck()
	remove_standing_overlay(NECK_LAYER)
	if(neck)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				neck.screen_loc = ui_neck
			client.screen += neck

		var/image/standing = neck.get_standing_overlay(src, 'icons/mob/neck.dmi', SPRITE_SHEET_NECK, -NECK_LAYER)
		standing = human_update_offset(standing, TRUE)
		standing.pixel_x += species.offset_features[OFFSET_NECK][1]
		standing.pixel_y += species.offset_features[OFFSET_NECK][2]
		overlays_standing[NECK_LAYER] = standing
	apply_standing_overlay(NECK_LAYER)

/mob/living/carbon/human/update_inv_back()
	remove_standing_overlay(BACK_LAYER)

	if(back)
		back.screen_loc = ui_back
		if(client && hud_used && hud_used.hud_shown)
			client.screen += back

		var/image/standing = back.get_standing_overlay(src, 'icons/mob/back.dmi', SPRITE_SHEET_BACK, -BACK_LAYER)
		standing = human_update_offset(standing, FALSE)
		standing.pixel_x += species.offset_features[OFFSET_BACK][1]
		standing.pixel_y += species.offset_features[OFFSET_BACK][2]
		overlays_standing[BACK_LAYER] = standing
	apply_standing_overlay(BACK_LAYER)


/mob/living/carbon/human/update_hud()	//TODO: do away with this if possible
	if(client)
		client.screen |= contents
		if(hud_used)
			hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar
			reload_fullscreen()


/mob/living/carbon/human/update_inv_handcuffed()
	remove_standing_overlay(HANDCUFF_LAYER)

	if(handcuffed)
		drop_r_hand()
		drop_l_hand()
		stop_pulling()	//TODO: should be handled elsewhere
		var/image/standing = image("icon"='icons/mob/mob.dmi', "icon_state"="handcuff1", "layer"=-HANDCUFF_LAYER)
		standing = human_update_offset(standing, FALSE)
		standing.pixel_x += species.offset_features[OFFSET_GLOVES][1]
		standing.pixel_y += species.offset_features[OFFSET_GLOVES][2]
		overlays_standing[HANDCUFF_LAYER] = standing
	apply_standing_overlay(HANDCUFF_LAYER)


/mob/living/carbon/human/update_inv_legcuffed()
	remove_standing_overlay(LEGCUFF_LAYER)

	if(legcuffed)
		set_m_intent(MOVE_INTENT_WALK)
		var/image/standing = image("icon"='icons/mob/mob.dmi', "icon_state"="legcuff1", "layer"=-LEGCUFF_LAYER)
		standing.appearance_flags |= KEEP_APART
		standing.pixel_x += species.offset_features[OFFSET_SHOES][1]
		standing.pixel_y += species.offset_features[OFFSET_SHOES][2]
		overlays_standing[LEGCUFF_LAYER]	= standing

	apply_standing_overlay(LEGCUFF_LAYER)


/mob/living/carbon/human/update_inv_r_hand()
	remove_standing_overlay(R_HAND_LAYER)

	if(r_hand)
		r_hand.screen_loc = ui_rhand
		if(client && hud_used)
			client.screen += r_hand

		var/image/standing = r_hand.get_standing_overlay(src, r_hand.righthand_file, SPRITE_SHEET_HELD, -R_HAND_LAYER, icon_state_appendix = "_r")
		standing = human_update_offset(standing, FALSE)
		standing.pixel_x += species.offset_features[OFFSET_GLOVES][1]
		standing.pixel_y += species.offset_features[OFFSET_GLOVES][2]
		overlays_standing[R_HAND_LAYER] = standing
		if(handcuffed)
			drop_r_hand()

	apply_standing_overlay(R_HAND_LAYER)


/mob/living/carbon/human/update_inv_l_hand()
	remove_standing_overlay(L_HAND_LAYER)

	if(l_hand)
		l_hand.screen_loc = ui_lhand
		if(client && hud_used)
			client.screen += l_hand

		var/image/standing = l_hand.get_standing_overlay(src, l_hand.lefthand_file, SPRITE_SHEET_HELD, -L_HAND_LAYER, icon_state_appendix = "_l")
		standing = human_update_offset(standing, FALSE)
		standing.pixel_x += species.offset_features[OFFSET_GLOVES][1]
		standing.pixel_y += species.offset_features[OFFSET_GLOVES][2]
		overlays_standing[L_HAND_LAYER] = standing
		if(handcuffed)
			drop_l_hand()

	apply_standing_overlay(L_HAND_LAYER)

/mob/living/carbon/human/proc/update_surgery()
	remove_standing_overlay(SURGERY_LAYER)

	var/list/standing = list()
	for(var/obj/item/organ/external/BP in bodyparts)
		if(BP.open)
			standing += image("icon" = species.surgery_icobase, "icon_state" = "[BP.body_zone][round(BP.open)]", "layer" = -SURGERY_LAYER)

	if(standing.len)
		for(var/image/I in standing)
			I = update_height(I)
		overlays_standing[SURGERY_LAYER] = standing

	apply_standing_overlay(SURGERY_LAYER)

/mob/living/carbon/human/proc/update_bandage()
	remove_standing_overlay(BANDAGE_LAYER)

	var/list/standing = list()
	for(var/obj/item/organ/external/BP in bodyparts)
		BP.bandaged = FALSE
		if(BP.wounds.len)
			for(var/datum/wound/W in BP.wounds)
				if(W.bandaged)
					BP.bandaged = TRUE
					var/image/I = image("icon" = 'icons/mob/bandages.dmi', "icon_state" = "[BP.body_zone]", "layer" = -BANDAGE_LAYER)
					standing += I

	if(standing.len)
		for(var/image/I in standing)
			I = update_height(I)
		overlays_standing[BANDAGE_LAYER] = standing

	apply_standing_overlay(BANDAGE_LAYER)


/mob/living/carbon/human/proc/get_overlays_copy()
	var/list/out = new
	out = overlays_standing.Copy()
	return out

//Offsetting any human's overlay that we dont want to cut.
/mob/living/carbon/human/proc/human_update_offset(image/I, head = TRUE)
	var/list/L
	if(head)//If your item is upper the torso - we want to shift it more.
		L = list(
			HUMANHEIGHT_SHORTEST = -2,
			HUMANHEIGHT_SHORT = -1,
			HUMANHEIGHT_MEDIUM = 0,
			HUMANHEIGHT_TALL = 1,
			HUMANHEIGHT_TALLEST = 2,
			"gnome" = -5
		)
	else
		L = list(
			HUMANHEIGHT_SHORTEST = -1,
			HUMANHEIGHT_SHORT = -1,
			HUMANHEIGHT_MEDIUM = 0,
			HUMANHEIGHT_TALL = 1,
			HUMANHEIGHT_TALLEST = 1,
			"gnome" = -3
		)

	I.pixel_y += L[height]

	if(SMALLSIZE in mutations) //Gnome-Guy
		I.pixel_y += L["gnome"]
	return I

//Cutting any human's overlay that we dont want to offset.
/mob/living/carbon/human/proc/update_height(image/I)
	var/static/icon/cut_torso_mask = icon('icons/effects/cut.dmi',"Cut1")
	var/static/icon/cut_legs_mask = icon('icons/effects/cut.dmi',"Cut2")
	var/static/icon/lenghten_torso_mask = icon('icons/effects/cut.dmi',"Cut3")
	var/static/icon/lenghten_legs_mask = icon('icons/effects/cut.dmi',"Cut4")

	I.remove_filter(list("Cut_Torso","Cut_Legs","Lenghten_Legs","Lenghten_Torso","Gnome_Cut_Torso","Gnome_Cut_Legs"))
	switch(height)
		if(HUMANHEIGHT_SHORTEST)
			I.add_filter("Cut_Torso", 1, displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 1))
			I.add_filter("Cut_Legs", 1, displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 1))
		if(HUMANHEIGHT_SHORT)
			I.add_filter("Cut_Legs", 1, displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 1))
		if(HUMANHEIGHT_TALL)
			I.add_filter("Lenghten_Legs", 1, displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 1))
		if(HUMANHEIGHT_TALLEST)
			I.add_filter("Lenghten_Torso", 1, displacement_map_filter(lenghten_torso_mask, x = 0, y = 0, size = 1))
			I.add_filter("Lenghten_Legs", 1, displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 1))
	if(SMALLSIZE in mutations)
		I.add_filter("Gnome_Cut_Torso", 1, displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 2))
		I.add_filter("Gnome_Cut_Legs", 1, displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 3))
	return I
