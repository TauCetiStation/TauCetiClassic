	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/*
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
		update_mutantrace()	//handles updating your appearance after setting the mutantrace var
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

//Human Overlays Indexes/////////
#define BODY_LAYER				27
#define MUTANTRACE_LAYER		26
#define MUTATIONS_LAYER			25
#define DAMAGE_LAYER			24
#define SURGERY_LAYER			23		//bs12 specific.
#define BANDAGE_LAYER			22
#define UNIFORM_LAYER			21
#define ID_LAYER				20
#define SHOES_LAYER				19
#define TAIL_LAYER				18		//bs12 specific. this hack is probably gonna come back to haunt me
#define GLOVES_LAYER			17
#define EARS_LAYER				16
#define SUIT_LAYER				15
#define GLASSES_LAYER			14
#define BELT_LAYER				13		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		12
#define BACK_LAYER				11
#define HAIR_LAYER				10		//TODO: make part of head layer?
#define FACEMASK_LAYER			9
#define HEAD_LAYER				8
#define COLLAR_LAYER			7
#define HANDCUFF_LAYER			6
#define LEGCUFF_LAYER			5
#define L_HAND_LAYER			4
#define R_HAND_LAYER			3
#define TARGETED_LAYER			2		//BS12: Layer for the target overlay from weapon targeting system
#define FIRE_LAYER				1
#define TOTAL_LAYERS			27
//////////////////////////////////
//Human Limb Overlays Indexes/////
#define LIMB_HEAD_LAYER			7
#define LIMB_TORSO_LAYER		6
#define LIMB_L_ARM_LAYER		5
#define LIMB_R_ARM_LAYER		4
#define LIMB_GROIN_LAYER		3
#define LIMB_L_LEG_LAYER		2
#define LIMB_R_LEG_LAYER		1
#define TOTAL_LIMB_LAYERS		7
//////////////////////////////////

/obj/item/proc/get_standing_overlay(mob/living/carbon/human/H, def_icon_path, sprite_sheet_slot, layer, bloodied_icon_state = null, icon_state_appendix = null)
	var/icon_path = def_icon_path

	var/t_state
	if(sprite_sheet_slot == SPRITE_SHEET_HELD || sprite_sheet_slot == SPRITE_SHEET_GLOVES || sprite_sheet_slot == SPRITE_SHEET_BELT)
		t_state = item_state
		if(!icon_custom)
			icon_state_appendix = null

	if(sprite_sheet_slot == SPRITE_SHEET_UNIFORM || sprite_sheet_slot == SPRITE_SHEET_UNIFORM_FAT)
		t_state = item_color

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
		if (istype(src, /obj/item/clothing) && H.species)
			var/obj/item/clothing/C = src
			var/list/avaiable_icon_states = C.get_sprite_sheet_icon_list(H.species.name, sprite_sheet_slot)
			if("[t_state][icon_state_appendix]" in avaiable_icon_states)
				icon_path = S.sprite_sheets[sprite_sheet_slot]
		else
			icon_path = S.sprite_sheets[sprite_sheet_slot]

	var/image/I = image(icon = icon_path, icon_state = "[t_state][icon_state_appendix]", layer = layer)
	I.color = color

	if(dirt_overlay && bloodied_icon_state)
		var/image/bloodsies = image(icon = 'icons/effects/blood.dmi', icon_state = bloodied_icon_state)
		bloodsies.color = dirt_overlay.color
		I.add_overlay(bloodsies)

	return I

/mob/living/carbon/human
	var/list/overlays_standing[TOTAL_LAYERS]
	var/list/overlays_damage[TOTAL_LIMB_LAYERS]

/mob/living/carbon/human/proc/apply_overlay(cache_index)
	var/image/I = overlays_standing[cache_index]
	if(I)
		add_overlay(I)

/mob/living/carbon/human/proc/remove_overlay(cache_index)
	if(overlays_standing[cache_index])
		cut_overlay(overlays_standing[cache_index])
		overlays_standing[cache_index] = null

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
	remove_damage_overlay(BP.limb_layer)
	if(species.damage_mask && (BP in bodyparts))
		var/image/standing = image("icon" = 'icons/mob/human_races/damage_overlays.dmi', "icon_state" = "[BP.body_zone]_[BP.damage_state]", "layer" = -DAMAGE_LAYER)
		standing.color = BP.damage_state_color()
		overlays_damage[BP.limb_layer] = standing
		apply_damage_overlay(BP.limb_layer)


//BASE MOB SPRITE
/mob/living/carbon/human/proc/update_body()
	remove_overlay(BODY_LAYER)
	var/list/standing = list()

	var/fat = HAS_TRAIT(src, TRAIT_FAT) ? "fat" : null
	var/g = (gender == FEMALE ? "f" : "m")

	for(var/obj/item/organ/external/BP in bodyparts)
		if(BP.is_stump)
			continue

		standing += BP.get_icon(BODY_LAYER)

	//Underwear
	if((underwear > 0) && (underwear < 12) && species.flags[HAS_UNDERWEAR])
		if(!fat)
			standing += mutable_appearance('icons/mob/human.dmi', "underwear[underwear]_[g]_s", -BODY_LAYER)

	if((undershirt > 0) && (undershirt < undershirt_t.len) && species.flags[HAS_UNDERWEAR])
		if(!fat)
			standing += mutable_appearance('icons/mob/human_undershirt.dmi', "undershirt[undershirt]_s", -BODY_LAYER)

	if(!fat && socks > 0 && socks < socks_t.len && species.flags[HAS_UNDERWEAR])
		var/obj/item/organ/external/r_foot = bodyparts_by_name[BP_R_LEG]
		var/obj/item/organ/external/l_foot = bodyparts_by_name[BP_L_LEG]
		if(r_foot && !r_foot.is_stump && l_foot && !l_foot.is_stump)
			standing += mutable_appearance('icons/mob/human_socks.dmi', "socks[socks]_s", -BODY_LAYER)

	update_tail_showing()
	overlays_standing[BODY_LAYER] = standing
	apply_overlay(BODY_LAYER)



//HAIR OVERLAY
/mob/living/carbon/human/proc/update_hair()
	//Reset our hair
	remove_overlay(HAIR_LAYER)

	var/obj/item/organ/external/head/BP = bodyparts_by_name[BP_HEAD]
	if(!BP || (BP.is_stump))
		return

	//masks and helmets can obscure our hair.
	if((HUSK in mutations) || (head && (head.flags & BLOCKHAIR)) || (wear_mask && (wear_mask.flags & BLOCKHAIR)) || (wear_suit && (wear_suit.flags & BLOCKHAIR)))
		return

	//base icons
	var/list/standing = list()

	if(f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if(facial_hair_style && facial_hair_style.species_allowed && (BP.species.name in facial_hair_style.species_allowed))
			var/mutable_appearance/facial_s = mutable_appearance(facial_hair_style.icon, "[facial_hair_style.icon_state]_s", -HAIR_LAYER)
			if(facial_hair_style.do_colouration)
				if(!facial_painted)
					facial_s.color = RGB_CONTRAST(r_facial, g_facial, b_facial)
				else
					facial_s.color = RGB_CONTRAST(dyed_r_facial, dyed_g_facial, dyed_b_facial)
					var/obj/item/organ/external/head = bodyparts_by_name[BP_HEAD]
					head.recolor()
			standing += facial_s

	if(h_style && !(head && (head.flags & BLOCKHEADHAIR)))
		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if(hair_style && hair_style.species_allowed && (BP.species.name in hair_style.species_allowed))
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration)
				var/icon/grad_s = new/icon("icon" = 'icons/mob/hair_gradients.dmi', "icon_state" = hair_gradients[grad_style])
				grad_s.Blend(hair_s, ICON_AND)
				if(!hair_painted)
					hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_AND)
					grad_s.Blend(rgb(r_grad, g_grad, b_grad), ICON_AND)
				else
					hair_s.Blend(rgb(dyed_r_hair, dyed_g_hair, dyed_b_hair), ICON_AND)
					grad_s.Blend(rgb(dyed_r_hair, dyed_g_hair, dyed_b_hair), ICON_AND)
					var/obj/item/organ/external/head = bodyparts_by_name[BP_HEAD]
					head.recolor()
				hair_s.Blend(grad_s, ICON_OVERLAY)

			standing += mutable_appearance(hair_s, "[hair_style.icon_state]_s", -HAIR_LAYER)

	if(standing.len)
		overlays_standing[HAIR_LAYER]	= standing

	if(istype(wear_suit, /obj/item/clothing/suit/wintercoat))
		var/obj/item/clothing/suit/wintercoat/W = wear_suit
		if(W.hooded) // used for coat hood due to hair layer viewed over the suit
			overlays_standing[HAIR_LAYER]   = null

	apply_overlay(HAIR_LAYER)


/mob/living/carbon/human/update_mutations()
	remove_overlay(MUTATIONS_LAYER)

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
	for(var/mut in mutations)
		switch(mut)
			/*
			if(HULK)
				if(fat)
					standing.underlays	+= "hulk_[fat]_s"
				else
					standing.underlays	+= "hulk_[g]_s"
			if(COLD_RESISTANCE)
				standing.underlays	+= "fire[fat]_s"
			if(TK)
				standing.underlays	+= "telekinesishead[fat]_s"
			*/
			if(LASEREYES)
				standing	+= image("icon"='icons/effects/genetics.dmi', "icon_state"="lasereyes_s", "layer"=-MUTATIONS_LAYER)
	if(standing.len)
		overlays_standing[MUTATIONS_LAYER]	= standing

	apply_overlay(MUTATIONS_LAYER)


/mob/living/carbon/human/proc/update_mutantrace()
	remove_overlay(MUTANTRACE_LAYER)

	var/list/standing = list()
	var/fat = HAS_TRAIT(src, TRAIT_FAT) ? "fat" : null

	if(dna)
		switch(dna.mutantrace)
			if("golem" , "shadow")
				standing += image('icons/effects/genetics.dmi', null, "[dna.mutantrace][fat]_[gender]_s", -MUTANTRACE_LAYER)

	if(species.name == SHADOWLING && head)
		var/image/eyes = image('icons/mob/shadowling.dmi', null, "[dna.mutantrace]_ms_s", LIGHTING_LAYER + 1)
		eyes.plane = LIGHTING_PLANE + 1
		standing += eyes

	if(iszombie(src) && stat != DEAD)
		var/image/eyes = image(species.icobase, null, "zombie_ms_s", LIGHTING_LAYER + 1)
		eyes.plane = LIGHTING_PLANE + 1
		standing += eyes

	if(!dna || !(dna.mutantrace == "golem"))
		update_body()

	if(standing.len)
		overlays_standing[MUTANTRACE_LAYER]	= standing

	if(species.flags[HAS_HAIR] || !(HUSK in mutations))
		update_hair()

	apply_overlay(MUTANTRACE_LAYER)


//Call when target overlay should be added/removed
/mob/living/carbon/human/update_targeted()
	remove_overlay(TARGETED_LAYER)

	if(targeted_by && target_locked)
		overlays_standing[TARGETED_LAYER]	= image("icon"=target_locked, "layer"=-TARGETED_LAYER)
	else if (!targeted_by && target_locked)
		qdel(target_locked)

	apply_overlay(TARGETED_LAYER)


/mob/living/carbon/human/update_fire() //TG-stuff, fire layer
	remove_overlay(FIRE_LAYER)

	if(on_fire)
		overlays_standing[FIRE_LAYER]	= image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing", "layer"=-FIRE_LAYER)

	apply_overlay(FIRE_LAYER)


/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	..()
	if(notransform)
		return
	update_hair()
	update_mutations()
	update_mutantrace()
	update_inv_w_uniform()
	update_inv_wear_id()
	update_inv_gloves()
	update_inv_glasses()
	update_inv_ears()
	update_inv_shoes()
	update_inv_s_store()
	update_inv_wear_mask()
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
	remove_overlay(UNIFORM_LAYER)

	var/default_path = 'icons/mob/uniform.dmi'
	var/uniform_sheet = SPRITE_SHEET_UNIFORM
	if(istype(w_uniform, /obj/item/clothing/under))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				w_uniform.screen_loc = ui_iclothing //...draw the item in the inventory screen
			client.screen += w_uniform				//Either way, add the item to the HUD

		var/obj/item/clothing/under/U = w_uniform
		if (wear_suit && (wear_suit.flags & BLOCKUNIFORM)) // Skip uniform overlay on suit full cover
			return

		if(HAS_TRAIT(src, TRAIT_FAT))
			if(U.flags & ONESIZEFITSALL)
				default_path = 'icons/mob/uniform_fat.dmi'
				uniform_sheet = SPRITE_SHEET_UNIFORM_FAT
			else
				to_chat(src, "<span class='warning'>You burst out of \the [U]!</span>")
				drop_from_inventory(U)
				return
		var/image/standing = U.get_standing_overlay(src, default_path, uniform_sheet, -UNIFORM_LAYER, "uniformblood", "_s")
		overlays_standing[UNIFORM_LAYER] = standing

		if(U.accessories.len)
			for(var/obj/item/clothing/accessory/A in w_uniform:accessories)
				var/tie_color = A.item_color
				if(!tie_color)
					tie_color = A.icon_state
				var/image/tie
				if(A.icon_custom)
					tie = image("icon" = A.icon_custom, "icon_state" = "[tie_color]_mob", "layer" = -UNIFORM_LAYER + A.layer_priority)
				else
					tie = image("icon" = 'icons/mob/accessory.dmi', "icon_state" = "[tie_color]", "layer" = -UNIFORM_LAYER + A.layer_priority)
				tie.color = A.color
				standing.add_overlay(tie)
	else
		// Automatically drop anything in store / id / belt if you're not wearing a uniform.	//CHECK IF NECESARRY
		for(var/obj/item/thing in list(r_store, l_store, wear_id, belt))						//
			drop_from_inventory(thing)

	apply_overlay(UNIFORM_LAYER)


/mob/living/carbon/human/update_inv_wear_id()
	remove_overlay(ID_LAYER)
	if(wear_id)
		wear_id.screen_loc = ui_id
		if(client && hud_used)
			client.screen += wear_id

		overlays_standing[ID_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="id", "layer"=-ID_LAYER)

	hud_updateflag |= 1 << ID_HUD
	hud_updateflag |= 1 << WANTED_HUD

	apply_overlay(ID_LAYER)


/mob/living/carbon/human/update_inv_gloves()
	remove_overlay(GLOVES_LAYER)
	if(gloves)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				gloves.screen_loc = ui_gloves		//...draw the item in the inventory screen
			client.screen += gloves					//Either way, add the item to the HUD

		var/image/standing = gloves.get_standing_overlay(src, 'icons/mob/hands.dmi', SPRITE_SHEET_GLOVES, -GLOVES_LAYER, "bloodyhands")
		overlays_standing[GLOVES_LAYER] = standing
	else
		if(blood_DNA)
			var/image/bloodsies	= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands")
			bloodsies.color = hand_dirt_datum.color
			overlays_standing[GLOVES_LAYER]	= bloodsies

	apply_overlay(GLOVES_LAYER)


/mob/living/carbon/human/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)

	if(glasses)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
			client.screen += glasses				//Either way, add the item to the HUD

		var/image/standing = glasses.get_standing_overlay(src, 'icons/mob/eyes.dmi', SPRITE_SHEET_EYES, -GLASSES_LAYER)
		overlays_standing[GLASSES_LAYER] = standing

	apply_overlay(GLASSES_LAYER)


/mob/living/carbon/human/update_inv_ears()
	remove_overlay(EARS_LAYER)

	if(l_ear || r_ear)
		if(l_ear)
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)			//if the inventory is open ...
					l_ear.screen_loc = ui_l_ear			//...draw the item in the inventory screen
				client.screen += l_ear					//Either way, add the item to the HUD

			var/image/standing = l_ear.get_standing_overlay(src, 'icons/mob/ears.dmi', SPRITE_SHEET_EARS, -EARS_LAYER)
			overlays_standing[EARS_LAYER] = standing
		if(r_ear)
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)		//if the inventory is open ...
					r_ear.screen_loc = ui_r_ear		//...draw the item in the inventory screen
				client.screen += r_ear				//Either way, add the item to the HUD

			var/image/standing = r_ear.get_standing_overlay(src, 'icons/mob/ears.dmi', SPRITE_SHEET_EARS, -EARS_LAYER)
			overlays_standing[EARS_LAYER] = standing

	apply_overlay(EARS_LAYER)


/mob/living/carbon/human/update_inv_shoes()
	remove_overlay(SHOES_LAYER)

	if(shoes)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				shoes.screen_loc = ui_shoes			//...draw the item in the inventory screen
			client.screen += shoes					//Either way, add the item to the HUD

		var/image/standing = shoes.get_standing_overlay(src, 'icons/mob/feet.dmi', SPRITE_SHEET_FEET, -SHOES_LAYER, "shoeblood")
		overlays_standing[SHOES_LAYER] = standing
	else
		if(feet_blood_DNA)
			var/image/bloodsies = image("icon"='icons/effects/blood.dmi', "icon_state"="shoeblood")
			bloodsies.color = feet_dirt_color.color
			overlays_standing[SHOES_LAYER] = bloodsies
		else
			overlays_standing[SHOES_LAYER] = null

	apply_overlay(SHOES_LAYER)


/mob/living/carbon/human/update_inv_s_store()
	remove_overlay(SUIT_STORE_LAYER)

	if(s_store)
		s_store.screen_loc = ui_sstore1
		if(client && hud_used)
			client.screen += s_store

		var/t_state = s_store.item_state
		if(!t_state)	t_state = s_store.icon_state
		var/image/standing = image("icon"='icons/mob/belt_mirror.dmi', "icon_state"="[t_state]", "layer"=-SUIT_STORE_LAYER)
		standing.color = s_store.color
		overlays_standing[SUIT_STORE_LAYER]	= standing

	apply_overlay(SUIT_STORE_LAYER)


/mob/living/carbon/human/update_inv_head()
	remove_overlay(HEAD_LAYER)

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
		overlays_standing[HEAD_LAYER] = standing

	apply_overlay(HEAD_LAYER)


/mob/living/carbon/human/update_inv_belt()
	remove_overlay(BELT_LAYER)

	if(belt)
		belt.screen_loc = ui_belt
		if(client && hud_used)
			client.screen += belt

		var/image/standing = belt.get_standing_overlay(src, 'icons/mob/belt.dmi', SPRITE_SHEET_BELT, -BELT_LAYER)
		overlays_standing[BELT_LAYER] = standing

	apply_overlay(BELT_LAYER)

/mob/living/carbon/human/update_inv_wear_suit()
	remove_overlay(SUIT_LAYER)
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
		overlays_standing[SUIT_LAYER] = standing

		if(istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			drop_from_inventory(handcuffed)
			drop_l_hand()
			drop_r_hand()

		if(istype(wear_suit,/obj/item/clothing/suit/wintercoat))
			var/obj/item/clothing/suit/wintercoat/W = wear_suit
			if(W.hooded) //used for coat hood due to hair layer viewed over the suit
				overlays_standing[HAIR_LAYER] = null
				overlays_standing[HEAD_LAYER] = null
		update_inv_shoes()

	update_inv_w_uniform()
	update_tail_showing()
	update_collar()

	apply_overlay(SUIT_LAYER)


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
	remove_overlay(FACEMASK_LAYER)

	if(istype(wear_mask, /obj/item/clothing/mask) || istype(wear_mask, /obj/item/clothing/accessory))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				wear_mask.screen_loc = ui_mask		//...draw the item in the inventory screen
			client.screen += wear_mask				//Either way, add the item to the HUD

		var/image/standing = wear_mask.get_standing_overlay(src, 'icons/mob/mask.dmi', SPRITE_SHEET_MASK, -FACEMASK_LAYER, "maskblood")
		overlays_standing[FACEMASK_LAYER]	= standing

	apply_overlay(FACEMASK_LAYER)


/mob/living/carbon/human/update_inv_back()
	remove_overlay(BACK_LAYER)

	if(back)
		back.screen_loc = ui_back
		if(client && hud_used && hud_used.hud_shown)
			client.screen += back

		var/image/standing = back.get_standing_overlay(src, 'icons/mob/back.dmi', SPRITE_SHEET_BACK, -BACK_LAYER)
		overlays_standing[BACK_LAYER] = standing
	apply_overlay(BACK_LAYER)


/mob/living/carbon/human/update_hud()	//TODO: do away with this if possible
	if(client)
		client.screen |= contents
		if(hud_used)
			hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar
			hud_used.reload_fullscreen()


/mob/living/carbon/human/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)

	if(handcuffed)
		drop_r_hand()
		drop_l_hand()
		stop_pulling()	//TODO: should be handled elsewhere
		overlays_standing[HANDCUFF_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="handcuff1", "layer"=-HANDCUFF_LAYER)
	apply_overlay(HANDCUFF_LAYER)


/mob/living/carbon/human/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)

	if(legcuffed)
		set_m_intent(MOVE_INTENT_WALK)

		overlays_standing[LEGCUFF_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="legcuff1", "layer"=-LEGCUFF_LAYER)

	apply_overlay(LEGCUFF_LAYER)


/mob/living/carbon/human/update_inv_r_hand()
	remove_overlay(R_HAND_LAYER)

	if(r_hand)
		r_hand.screen_loc = ui_rhand
		if(client && hud_used)
			client.screen += r_hand

		var/image/standing = r_hand.get_standing_overlay(src, r_hand.righthand_file, SPRITE_SHEET_HELD, -R_HAND_LAYER, icon_state_appendix = "_r")
		overlays_standing[R_HAND_LAYER] = standing
		if(handcuffed)
			drop_r_hand()

	apply_overlay(R_HAND_LAYER)


/mob/living/carbon/human/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)

	if(l_hand)
		l_hand.screen_loc = ui_lhand
		if(client && hud_used)
			client.screen += l_hand

		var/t_state = l_hand.item_state
		if(!t_state)
			t_state = l_hand.icon_state
		var/image/standing = l_hand.get_standing_overlay(src, l_hand.lefthand_file, SPRITE_SHEET_HELD, -L_HAND_LAYER, icon_state_appendix = "_l")
		overlays_standing[L_HAND_LAYER] = standing
		if(handcuffed)
			drop_l_hand()

	apply_overlay(L_HAND_LAYER)


/mob/living/carbon/human/proc/update_tail_showing()
	remove_overlay(TAIL_LAYER)

	if(species.tail && species.flags[HAS_TAIL] && !(HUSK in mutations) && bodyparts_by_name[BP_CHEST])
		if(!wear_suit || !(wear_suit.flags_inv & HIDETAIL) && !istype(wear_suit, /obj/item/clothing/suit/space))
			var/image/tail_s = image("icon" = 'icons/mob/species/tail.dmi', "icon_state" = species.tail)

			var/obj/item/organ/external/chest/BP = bodyparts_by_name[BP_CHEST]

			if(BP.status & ORGAN_DEAD)
				tail_s.color = NECROSIS_COLOR_MOD
			else if(HULK in mutations)
				tail_s.color = HULK_SKIN_COLOR
			else
				tail_s.color = RGB_CONTRAST(r_skin, g_skin, b_skin)

			overlays_standing[TAIL_LAYER] = image("icon" = tail_s, "layer" = -TAIL_LAYER)

	apply_overlay(TAIL_LAYER)


//Adds a collar overlay above the helmet layer if the suit has one
//	Suit needs an identically named sprite in icons/mob/collar.dmi
/mob/living/carbon/human/proc/update_collar()
	remove_overlay(COLLAR_LAYER)

	if(wear_suit)
		var/icon/C = new('icons/mob/collar.dmi')
		if(wear_suit.icon_state in C.IconStates())

			var/image/standing = image("icon" = C, "icon_state" = "[wear_suit.icon_state]", "layer"=-COLLAR_LAYER)
			standing.color = wear_suit.color
			overlays_standing[COLLAR_LAYER]	= standing

	apply_overlay(COLLAR_LAYER)


/mob/living/carbon/human/proc/update_surgery()
	remove_overlay(SURGERY_LAYER)

	var/list/standing = list()
	for(var/obj/item/organ/external/BP in bodyparts)
		if(BP.open)
			standing += image("icon" = 'icons/mob/surgery.dmi', "icon_state" = "[BP.body_zone][round(BP.open)]", "layer" = -SURGERY_LAYER)

	if(standing.len)
		overlays_standing[SURGERY_LAYER] = standing

	apply_overlay(SURGERY_LAYER)

/mob/living/carbon/human/proc/update_bandage()
	remove_overlay(BANDAGE_LAYER)

	var/list/standing = list()
	for(var/obj/item/organ/external/BP in bodyparts)
		BP.bandaged = FALSE
		if(BP.wounds.len)
			for(var/datum/wound/W in BP.wounds)
				if(W.bandaged)
					BP.bandaged = TRUE
					standing += image("icon" = 'icons/mob/bandages.dmi', "icon_state" = "[BP.body_zone]", "layer" = -BANDAGE_LAYER)

	if(standing.len)
		overlays_standing[BANDAGE_LAYER] = standing

	apply_overlay(BANDAGE_LAYER)


/mob/living/carbon/human/proc/get_overlays_copy()
	var/list/out = new
	out = overlays_standing.Copy()
	return out

//Human Overlays Indexes/////////
#undef BODY_LAYER
#undef MUTANTRACE_LAYER
#undef MUTATIONS_LAYER
#undef DAMAGE_LAYER
#undef SURGERY_LAYER
#undef BANDAGE_LAYER
#undef UNIFORM_LAYER
#undef TAIL_LAYER
#undef ID_LAYER
#undef SHOES_LAYER
#undef GLOVES_LAYER
#undef EARS_LAYER
#undef SUIT_LAYER
#undef GLASSES_LAYER
#undef FACEMASK_LAYER
#undef BELT_LAYER
#undef SUIT_STORE_LAYER
#undef BACK_LAYER
#undef HAIR_LAYER
#undef HEAD_LAYER
#undef COLLAR_LAYER
#undef HANDCUFF_LAYER
#undef LEGCUFF_LAYER
#undef L_HAND_LAYER
#undef R_HAND_LAYER
#undef TARGETED_LAYER
#undef FIRE_LAYER
#undef TOTAL_LAYERS
