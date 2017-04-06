	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/*
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

	All of these are named after the variable they update from. They are defined at the mob/ level
	so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.

>	There are also these special cases:
		update_mutations()	//handles updating your appearance for certain mutations.  e.g TK head-glows
		update_mutantrace()	//handles updating your appearance after setting the mutantrace var
		update_bodypart()	//handles updating your mob's icon to reflect their gender/race/complexion etc and
								...damage overlays for brute/burn damage
		update_body()	// Handles updating your underwear, socks, eyes and lips + colors.
		update_hair()	//Handles updating your hair overlay (used to be update_face, but mouth and
																			...eyes were merged into update_body)
		update_targeted() // Updates the target overlay when someone points a gun at you

>	If you need to update all overlays you can use regenerate_icons().

>	I reimplimented an old unused variable which was in the code called (coincidentally) var/update_icon
	It can be used as another method of triggering regenerate_icons(). It's basically a flag that when set to non-zero
	will call regenerate_icons() at the next life() call and then reset itself to 0.
	The idea behind it is icons are regenerated only once, even if multiple events requested it.

*/

//Human Overlays Indexes/////////
#define BODYPARTS_LAYER			28
#define BODY_LAYER				27
#define MUTANTRACE_LAYER		26
#define MUTATIONS_LAYER			25
#define DAMAGE_LAYER			24
#define SURGERY_LAYER			23		//bs12 specific.
#define BANDAGE_LAYER			22
#define UNIFORM_LAYER			21
#define TAIL_LAYER				20		//bs12 specific. this hack is probably gonna come back to haunt me
#define ID_LAYER				19
#define SHOES_LAYER				18
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
#define TOTAL_LAYERS			28
//////////////////////////////////
//Human BodyParts Overlays Indexes/////
#define BP_HEAD_LAYER		7
#define BP_TORSO_LAYER		6
#define BP_L_ARM_LAYER		5
#define BP_R_ARM_LAYER		4
#define BP_GROIN_LAYER		3
#define BP_L_LEG_LAYER		2
#define BP_R_LEG_LAYER		1
#define TOTAL_BP_LAYERS		7
//////////////////////////////////

/*
	*** list/human_icon_cache ***
	Global associative list for caching humanoid icons.
	Index format m or f, followed by a string of 0 and 1 to represent bodyparts followed by husk fat hulk skeleton 1 or 0.
	TODO: Proper documentation
	icon_key is [species.race_key][g][husk][fat][hulk][s_tone][r_tone]
*/
/mob/living/carbon
	var/static/list/human_icon_cache = list()
	var/list/overlays_standing[TOTAL_LAYERS]
	//var/list/overlays_damage[TOTAL_BP_LAYERS]
	var/list/overlays_bodypart = list()

/mob/living/carbon/proc/apply_overlay(cache_index)
	var/image/I = overlays_standing[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/proc/remove_overlay(cache_index)
	if(overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null
/*
/mob/living/carbon/proc/apply_damage_overlay(cache_index)
	var/image/I = overlays_damage[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/proc/remove_damage_overlay(cache_index)
	if(overlays_damage[cache_index])
		overlays -= overlays_damage[cache_index]
		overlays_damage[cache_index] = null
*/
/mob/living/carbon/proc/apply_bodypart_overlay(cache_index)
	var/image/I = overlays_bodypart[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/proc/remove_bodypart_overlay(cache_index)
	if(overlays_bodypart[cache_index])
		overlays -= overlays_bodypart[cache_index]
		overlays_bodypart[cache_index] = null

/mob/living/carbon/update_icons()
	update_hud()		//TODO: remove the need for this


/mob/living/carbon/proc/update_bodypart(body_zone)
	remove_bodypart_overlay(body_zone)

	var/obj/item/bodypart/BP = bodyparts_by_name[body_zone]

	if(!BP)
		return

	BP.update_limb()

	if(!BP.icon_state)
		return

	overlays_bodypart[body_zone] = BP.get_icon()
	apply_bodypart_overlay(body_zone)

/mob/living/carbon/proc/update_bodyparts()
	for(var/obj/item/bodypart/BP in bodyparts)
		update_bodypart(BP.body_zone)

//BASE MOB SPRITE
/mob/living/carbon/proc/update_body()
	remove_overlay(BODY_LAYER)

	if(!species)
		return

	update_bodyparts() // TODO remove this
	update_tail_showing() // TODO remove this

	var/g = (gender == FEMALE ? "f" : "m")
	var/fat = (FAT in src.mutations)
	var/hulk = (HULK in src.mutations)

	var/list/standing = list()

	//Underwear
	if(!fat)
		var/obj/item/bodypart/groin = get_bodypart(BP_GROIN)
		if(groin && !groin.is_stump() && (underwear > 0) && (underwear < 12) && species.flags[HAS_UNDERWEAR])
			standing += image(icon = 'icons/mob/human.dmi', icon_state = "underwear[underwear]_[g]_s", layer = -BODY_LAYER)

		if((undershirt > 0) && (undershirt < undershirt_t.len) && species.flags[HAS_UNDERWEAR])
			standing += image(icon = 'icons/mob/human_undershirt.dmi', icon_state = "undershirt[undershirt]_s", layer = -BODY_LAYER)

	if((socks > 0) && (socks < socks_t.len) && species.flags[HAS_UNDERWEAR])
		if(!fat && bodyparts_by_name[BP_R_LEG] && bodyparts_by_name[BP_L_LEG]) //shit
			var/obj/item/bodypart/r_leg = bodyparts_by_name[BP_R_LEG]
			var/obj/item/bodypart/l_leg = bodyparts_by_name[BP_L_LEG]
			if( r_leg && l_leg && !r_leg.is_stump() && !l_leg.is_stump() )
				standing += image(icon = 'icons/mob/human_socks.dmi', icon_state = "socks[socks]_s", layer = -BODY_LAYER)

	var/obj/item/bodypart/BP = get_bodypart(BP_HEAD)
	if(BP && !BP.is_stump())
		//Eyes
		var/image/img_eyes_s = image(icon = 'icons/mob/human_face.dmi', icon_state = species.eyes, layer = -BODY_LAYER)
		img_eyes_s.color = hulk ? "#ff0000" : rgb(r_eyes, g_eyes, b_eyes)
		standing += img_eyes_s

		//Mouth	(lipstick!)
		if(lip_style && (species && species.flags[HAS_LIPS]))	//skeletons are allowed to wear lipstick no matter what you think, agouri.
			var/image/lips = image(icon = 'icons/mob/human_face.dmi', icon_state = "lips_[lip_style]_s", layer = -BODY_LAYER)
			lips.color = lip_color
			standing += lips

	overlays_standing[BODY_LAYER] = standing
	apply_overlay(BODY_LAYER)



//HAIR OVERLAY
/mob/living/carbon/proc/update_hair()
	//Reset our hair
	remove_overlay(HAIR_LAYER)

	var/obj/item/bodypart/head/BP = get_bodypart(BP_HEAD)
	if(!BP || BP.is_stump())
		return

	//masks and helmets can obscure our hair.
	if((HUSK in mutations) || (head && (head.flags & BLOCKHAIR)) || (wear_mask && (wear_mask.flags & BLOCKHAIR)) || (wear_suit && (wear_suit.flags & BLOCKHAIR)))
		return

	//base icons
	var/list/standing	= list()

	if(f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if(facial_hair_style && facial_hair_style.species_allowed && (species.name in facial_hair_style.species_allowed))
			var/image/facial_s = image("icon"=facial_hair_style.icon, "icon_state"="[facial_hair_style.icon_state]_s", "layer"=-HAIR_LAYER)
			if(facial_hair_style.do_colouration)
				facial_s.color = list(1,0,0, 0,1,0, 0,0,1, r_facial/255,g_facial/255,b_facial/255)//rgb(r_facial, g_facial, b_facial)
			standing	+= facial_s

	if(h_style && !(head && (head.flags & BLOCKHEADHAIR)))
		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if(hair_style && hair_style.species_allowed && (species.name in hair_style.species_allowed))
			var/image/hair_s = image("icon"=hair_style.icon, "icon_state"="[hair_style.icon_state]_s", "layer"=-HAIR_LAYER)
			if(hair_style.do_colouration)
				hair_s.color = list(1,0,0, 0,1,0, 0,0,1, r_hair/255,g_hair/255,b_hair/255)//rgb(r_hair,g_hair,b_hair)
			standing	+= hair_s

	if(standing.len)
		overlays_standing[HAIR_LAYER]	= standing

	apply_overlay(HAIR_LAYER)


/mob/living/carbon/update_mutations()
	remove_overlay(MUTATIONS_LAYER)
	var/fat
	if(FAT in mutations)
		fat = "fat"

	var/list/standing	= list()
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
			if(MUT_LASER)
				standing	+= image("icon"='icons/effects/genetics.dmi', "icon_state"="lasereyes_s", "layer"=-MUTATIONS_LAYER)
	if(standing.len)
		overlays_standing[MUTATIONS_LAYER]	= standing

	apply_overlay(MUTATIONS_LAYER)


/mob/living/carbon/proc/update_mutantrace()
	remove_overlay(MUTANTRACE_LAYER)

	var/fat
	if(FAT in mutations)
		fat = "fat"

	var/list/standing	= list()
	if(dna)
		switch(dna.mutantrace)
			if("slime")
				standing	+= image("icon"='icons/effects/genetics.dmi', "icon_state"="[dna.mutantrace][fat]_[gender]_[species.name]_s", "layer"=-MUTANTRACE_LAYER)
			if("golem","shadow","adamantine")
				standing	+= image("icon"='icons/effects/genetics.dmi', "icon_state"="[dna.mutantrace][fat]_[gender]_s", "layer"=-MUTANTRACE_LAYER)
			if(S_SHADOWLING)
				var/image/eyes = image("icon"='icons/mob/shadowling.dmi', "icon_state"="[dna.mutantrace]_ms_s", "layer"=GLASSES_LAYER)
				var/image/body = image("icon"='icons/mob/shadowling.dmi', "icon_state"="[dna.mutantrace]_s", "layer"=-MUTANTRACE_LAYER)
				eyes.plane = LIGHTING_PLANE + 1
				standing	+= eyes
				standing	+= body

	if(!dna || !(dna.mutantrace == "golem"))
		update_body()

	if(standing.len)
		overlays_standing[MUTANTRACE_LAYER]	= standing

	update_hair()

	apply_overlay(MUTANTRACE_LAYER)


//Call when target overlay should be added/removed
/mob/living/carbon/update_targeted()
	remove_overlay(TARGETED_LAYER)

	if(targeted_by && target_locked)
		overlays_standing[TARGETED_LAYER]	= image("icon"=target_locked, "layer"=-TARGETED_LAYER)
	else if (!targeted_by && target_locked)
		qdel(target_locked)

	apply_overlay(TARGETED_LAYER)


/mob/living/carbon/update_fire() //TG-stuff, fire layer
	remove_overlay(FIRE_LAYER)

	if(on_fire)
		overlays_standing[FIRE_LAYER]	= image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing", "layer"=-FIRE_LAYER)

	apply_overlay(FIRE_LAYER)


/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/regenerate_icons()
	..()
	if(monkeyizing)		return
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
	update_bodyparts()
	update_icons()
	update_transform()
	//Hud Stuff
	update_hud()


/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/update_inv_w_uniform()
	remove_overlay(UNIFORM_LAYER)

	if(istype(w_uniform, /obj/item/clothing/under))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				w_uniform.screen_loc = ui_iclothing //...draw the item in the inventory screen
			client.screen += w_uniform				//Either way, add the item to the HUD

		var/obj/item/clothing/under/U = w_uniform
		var/t_color = U.item_color
		if(!t_color)		t_color = icon_state
		var/image/standing = image("icon_state"="[t_color]_s", "layer"=-UNIFORM_LAYER)
		if(!U.icon_custom || U.icon_override || species.sprite_sheets["uniform"])
			standing.icon	= (U.icon_override ? U.icon_override : (species.sprite_sheets["uniform"] ? species.sprite_sheets["uniform"] : 'icons/mob/uniform.dmi'))
		else
			standing = image("icon"=U.icon_custom, "icon_state"="[t_color]_mob", "layer"=-UNIFORM_LAYER)
		standing.color = U.color
		overlays_standing[UNIFORM_LAYER] = standing

		if(U.blood_DNA)
			var/image/bloodsies	= image("icon"='icons/effects/blood.dmi', "icon_state"="uniformblood")
			bloodsies.color		= U.blood_color
			standing.overlays	+= bloodsies

		if(U.hastie)
			var/tie_color = U.hastie.item_color
			if(!tie_color) tie_color = U.hastie.icon_state
			var/image/tie
			if(U.hastie.icon_custom)
				tie = image("icon"=U.hastie.icon_custom, "icon_state"="[tie_color]_mob", "layer"=-UNIFORM_LAYER)
			else
				tie = image("icon"='icons/mob/ties.dmi', "icon_state"="[tie_color]", "layer"=-UNIFORM_LAYER)
			tie.color = U.hastie.color
			standing.overlays += tie
		if(FAT in mutations)
			if(U.flags & ONESIZEFITSALL)
				standing.icon	= 'icons/mob/uniform_fat.dmi'
			else
				to_chat(src, "\red You burst out of \the [U]!")
				drop_from_inventory(U)
				return

	else
		// Automatically drop anything in store / id / belt if you're not wearing a uniform.	//CHECK IF NECESARRY
		for(var/obj/item/thing in list(r_store, l_store, wear_id, belt))						//
			drop_from_inventory(thing)

	apply_overlay(UNIFORM_LAYER)


/mob/living/carbon/update_inv_wear_id()
	remove_overlay(ID_LAYER)
	if(wear_id)
		wear_id.screen_loc = ui_id
		if(client && hud_used)
			client.screen += wear_id

		overlays_standing[ID_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="id", "layer"=-ID_LAYER)

	hud_updateflag |= 1 << ID_HUD
	hud_updateflag |= 1 << WANTED_HUD

	apply_overlay(ID_LAYER)


/mob/living/carbon/update_inv_gloves()
	remove_overlay(GLOVES_LAYER)
	if(gloves)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				gloves.screen_loc = ui_gloves		//...draw the item in the inventory screen
			client.screen += gloves					//Either way, add the item to the HUD

		var/t_state = gloves.item_state
		if(!t_state)	t_state = gloves.icon_state
		var/image/standing
		if(!gloves:icon_custom || gloves.icon_override || species.sprite_sheets["gloves"])
			standing = image("icon"=((gloves.icon_override) ? gloves.icon_override : (species.sprite_sheets["gloves"] ? species.sprite_sheets["gloves"] : 'icons/mob/hands.dmi')), "icon_state"="[t_state]", "layer"=-GLOVES_LAYER)
		else
			standing = image("icon"=gloves:icon_custom, "icon_state"="[t_state]_mob", "layer"=-GLOVES_LAYER)
		standing.color = gloves.color
		overlays_standing[GLOVES_LAYER]	= standing

		if(gloves.blood_DNA)
			var/image/bloodsies	= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands")
			bloodsies.color = gloves.blood_color
			standing.overlays	+= bloodsies
	else
		if(blood_DNA)
			var/image/bloodsies	= image("icon"='icons/effects/blood.dmi', "icon_state"="bloodyhands")
			bloodsies.color = hand_blood_color
			overlays_standing[GLOVES_LAYER]	= bloodsies

	apply_overlay(GLOVES_LAYER)


/mob/living/carbon/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)

	if(glasses)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
			client.screen += glasses				//Either way, add the item to the HUD
		var/image/standing
		if(!glasses:icon_custom || glasses.icon_override || species.sprite_sheets["eyes"])
			standing = image("icon"=((glasses.icon_override) ? glasses.icon_override : (species.sprite_sheets["eyes"] ? species.sprite_sheets["eyes"] : 'icons/mob/eyes.dmi')), "icon_state"="[glasses.icon_state]", "layer"=-GLASSES_LAYER)
		else
			standing = image("icon"=glasses:icon_custom, "icon_state"="[glasses.icon_state]_mob", "layer"=-GLASSES_LAYER)
		standing.color = glasses.color
		overlays_standing[GLASSES_LAYER] = standing

	apply_overlay(GLASSES_LAYER)


/mob/living/carbon/update_inv_ears()
	remove_overlay(EARS_LAYER)

	if(l_ear || r_ear)
		if(l_ear)
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)			//if the inventory is open ...
					l_ear.screen_loc = ui_l_ear			//...draw the item in the inventory screen
				client.screen += l_ear					//Either way, add the item to the HUD
			var/image/standing
			if(!l_ear:icon_custom || l_ear.icon_override || species.sprite_sheets["ears"])
				standing = image("icon"=((l_ear.icon_override) ? l_ear.icon_override : (species.sprite_sheets["ears"] ? species.sprite_sheets["ears"] : 'icons/mob/ears.dmi')), "icon_state"="[l_ear.icon_state]", "layer"=-EARS_LAYER)
			else
				standing = image("icon"=l_ear:icon_custom, "icon_state"="[l_ear.icon_state]_mob", "layer"=-EARS_LAYER)
			standing.color = l_ear.color
			overlays_standing[EARS_LAYER] = standing
		if(r_ear)
			if(client && hud_used && hud_used.hud_shown)
				if(hud_used.inventory_shown)		//if the inventory is open ...
					r_ear.screen_loc = ui_r_ear		//...draw the item in the inventory screen
				client.screen += r_ear				//Either way, add the item to the HUD
			var/image/standing
			if(!r_ear:icon_custom || r_ear.icon_override || species.sprite_sheets["ears"])
				standing = image("icon"=((r_ear.icon_override) ? r_ear.icon_override : (species.sprite_sheets["ears"] ? species.sprite_sheets["ears"] : 'icons/mob/ears.dmi')), "icon_state"="[r_ear.icon_state]", "layer"=-EARS_LAYER)
			else
				standing = image("icon"=r_ear:icon_custom, "icon_state"="[r_ear.icon_state]_mob", "layer"=-EARS_LAYER)
			standing.color = r_ear.color
			overlays_standing[EARS_LAYER] = standing

	apply_overlay(EARS_LAYER)


/mob/living/carbon/update_inv_shoes()
	remove_overlay(SHOES_LAYER)

	if(shoes)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				shoes.screen_loc = ui_shoes			//...draw the item in the inventory screen
			client.screen += shoes					//Either way, add the item to the HUD

		var/image/standing
		if(!shoes:icon_custom || shoes.icon_override || species.sprite_sheets["feet"])
			standing = image("icon"=((shoes.icon_override) ? shoes.icon_override : (species.sprite_sheets["feet"] ? species.sprite_sheets["feet"] : 'icons/mob/feet.dmi')), "icon_state"="[shoes.icon_state]", "layer"=-SHOES_LAYER)
		else
			standing = image("icon"=shoes:icon_custom, "icon_state"="[shoes.icon_state]_mob", "layer"=-SHOES_LAYER)
		standing.color = shoes.color
		overlays_standing[SHOES_LAYER] = standing

		if(shoes.blood_DNA)
			var/image/bloodsies = image("icon"='icons/effects/blood.dmi', "icon_state"="shoeblood")
			bloodsies.color = shoes.blood_color
			standing.overlays += bloodsies
	else
		if(feet_blood_DNA)
			var/image/bloodsies = image("icon"='icons/effects/blood.dmi', "icon_state"="shoeblood")
			bloodsies.color = feet_blood_color
			overlays_standing[SHOES_LAYER] = bloodsies

	apply_overlay(SHOES_LAYER)


/mob/living/carbon/update_inv_s_store()
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


/mob/living/carbon/update_inv_head()
	remove_overlay(HEAD_LAYER)

	if(head)
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				head.screen_loc = ui_head			//...draw the item in the inventory screen
			client.screen += head					//Either way, add the item to the HUD

		var/image/standing
		if(istype(head,/obj/item/clothing/head/kitty))
			var/obj/item/clothing/head/kitty/K = head
			standing	= image("icon"=K.mob, "layer"=-HEAD_LAYER)
		else
			if(!head:icon_custom || head.icon_override || species.sprite_sheets["head"])
				standing = image("icon"=((head.icon_override) ? head.icon_override : (species.sprite_sheets["head"] ? species.sprite_sheets["head"] : 'icons/mob/head.dmi')), "icon_state"="[head.icon_state]", "layer"=-HEAD_LAYER)
			else
				standing = image("icon"=head:icon_custom, "icon_state"="[head.icon_state]_mob", "layer"=-HEAD_LAYER)
		standing.color = head.color
		overlays_standing[HEAD_LAYER]	= standing

		if(head.blood_DNA)
			var/image/bloodsies = image("icon"='icons/effects/blood.dmi', "icon_state"="helmetblood")
			bloodsies.color = head.blood_color
			standing.overlays	+= bloodsies

	apply_overlay(HEAD_LAYER)


/mob/living/carbon/update_inv_belt()
	remove_overlay(BELT_LAYER)

	if(belt)
		belt.screen_loc = ui_belt
		if(client && hud_used)
			client.screen += belt

		var/t_state = belt.item_state
		if(!t_state)	t_state = belt.icon_state
		var/image/standing
		if(!belt:icon_custom || belt.icon_override || species.sprite_sheets["belt"])
			standing = image("icon"=((belt.icon_override) ? belt.icon_override : (species.sprite_sheets["belt"] ? species.sprite_sheets["belt"] : 'icons/mob/belt.dmi')), "icon_state"="[t_state]", "layer"=-BELT_LAYER)
		else
			standing = image("icon"=belt:icon_custom, "icon_state"="[belt.icon_state]_mob", "layer"=-BELT_LAYER)
		standing.color = belt.color
		overlays_standing[BELT_LAYER] = standing
	apply_overlay(BELT_LAYER)


/mob/living/carbon/update_inv_wear_suit()
	remove_overlay(SUIT_LAYER)

	if(istype(wear_suit, /obj/item/clothing/suit))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				wear_suit.screen_loc = ui_oclothing	//...draw the item in the inventory screen
			client.screen += wear_suit				//Either way, add the item to the HUD

		var/image/standing
		if(!wear_suit:icon_custom || wear_suit.icon_override || species.sprite_sheets["suit"])
			standing = image("icon"=((wear_suit.icon_override) ? wear_suit.icon_override : (species.sprite_sheets["suit"] ? species.sprite_sheets["suit"] : 'icons/mob/suit.dmi')), "icon_state"="[wear_suit.icon_state]", "layer"=-SUIT_LAYER)
		else
			standing = image("icon"=wear_suit:icon_custom, "icon_state"="[wear_suit.icon_state]_mob", "layer"=-SUIT_LAYER)
		standing.color = wear_suit.color
		overlays_standing[SUIT_LAYER]	= standing

		if(istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			drop_from_inventory(handcuffed)
			drop_l_hand()
			drop_r_hand()

		if(wear_suit.blood_DNA)
			var/obj/item/clothing/suit/S = wear_suit
			var/image/bloodsies = image("icon"='icons/effects/blood.dmi', "icon_state"="[S.blood_overlay_type]blood")
			bloodsies.color = wear_suit.blood_color
			standing.overlays	+= bloodsies

		if(FAT in mutations)
			if(!(wear_suit.flags & ONESIZEFITSALL))
				to_chat(src, "\red You burst out of \the [wear_suit]!")
				drop_from_inventory(wear_suit)
				return

		if(istype(wear_suit,/obj/item/clothing/suit/wintercoat))
			var/obj/item/clothing/suit/wintercoat/W = wear_suit
			if(W.hooded) //used for coat hood due to hair layer viewed over the suit
				overlays_standing[HAIR_LAYER]   = null
				overlays_standing[HEAD_LAYER]	= null

		update_inv_shoes()

	update_tail_showing()
	update_collar()

	apply_overlay(SUIT_LAYER)


/mob/living/carbon/update_inv_pockets()
	if(l_store)
		l_store.screen_loc = ui_storage1
		if(client && hud_used)
			client.screen += l_store
	if(r_store)
		r_store.screen_loc = ui_storage2
		if(client && hud_used)
			client.screen += r_store


/mob/living/carbon/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)

	if(istype(wear_mask, /obj/item/clothing/mask) || istype(wear_mask, /obj/item/clothing/tie))
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				wear_mask.screen_loc = ui_mask		//...draw the item in the inventory screen
			client.screen += wear_mask				//Either way, add the item to the HUD

		var/image/standing
		if(!wear_mask:icon_custom || wear_mask.icon_override || species.sprite_sheets["mask"])
			standing = image("icon"=((wear_mask.icon_override) ? wear_mask.icon_override : (species.sprite_sheets["mask"] ? species.sprite_sheets["mask"] : 'icons/mob/mask.dmi')), "icon_state"="[wear_mask.icon_state]", "layer"=-FACEMASK_LAYER)
		else
			standing = image("icon"=wear_mask:icon_custom, "icon_state"="[wear_mask.icon_state]_mob", "layer"=-FACEMASK_LAYER)
		standing.color = wear_mask.color
		overlays_standing[FACEMASK_LAYER]	= standing

		if(wear_mask.blood_DNA && !istype(wear_mask, /obj/item/clothing/mask/cigarette))
			var/image/bloodsies = image("icon"='icons/effects/blood.dmi', "icon_state"="maskblood")
			bloodsies.color = wear_mask.blood_color
			standing.overlays	+= bloodsies

	apply_overlay(FACEMASK_LAYER)


/mob/living/carbon/update_inv_back()
	remove_overlay(BACK_LAYER)

	if(back)
		back.screen_loc = ui_back
		if(client && hud_used && hud_used.hud_shown)
			client.screen += back
		var/image/standing
		if(!back:icon_custom || back.icon_override || species.sprite_sheets["back"])
			standing = image("icon"=((back.icon_override) ? back.icon_override : (species.sprite_sheets["back"] ? species.sprite_sheets["back"] : 'icons/mob/back.dmi')), "icon_state"="[back.icon_state]", "layer"=-BACK_LAYER)
		else
			standing = image("icon"=back:icon_custom, "icon_state"="[back.icon_state]_mob", "layer"=-BACK_LAYER)
		standing.color = back.color
		overlays_standing[BACK_LAYER] = standing
	apply_overlay(BACK_LAYER)


/mob/living/carbon/update_hud()	//TODO: do away with this if possible
	if(client)
		client.screen |= contents
		if(hud_used)
			hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar


/mob/living/carbon/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)

	if(handcuffed)
		drop_r_hand()
		drop_l_hand()
		stop_pulling()	//TODO: should be handled elsewhere
		overlays_standing[HANDCUFF_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="handcuff1", "layer"=-HANDCUFF_LAYER)
	apply_overlay(HANDCUFF_LAYER)


/mob/living/carbon/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)

	if(legcuffed)
		if(src.m_intent != "walk")
			src.m_intent = "walk"
			if(src.hud_used && src.hud_used.move_intent)
				src.hud_used.move_intent.icon_state = "walking"

		overlays_standing[LEGCUFF_LAYER]	= image("icon"='icons/mob/mob.dmi', "icon_state"="legcuff1", "layer"=-LEGCUFF_LAYER)

	apply_overlay(LEGCUFF_LAYER)


/mob/living/carbon/update_inv_r_hand()
	remove_overlay(R_HAND_LAYER)

	if(r_hand)
		r_hand.screen_loc = ui_rhand
		if(client && hud_used)
			client.screen += r_hand

		var/t_state = r_hand.item_state
		if(!t_state)
			t_state = r_hand.icon_state
		var/image/standing
		if(!r_hand:icon_custom || r_hand.icon_override || species.sprite_sheets["held"])
			if(r_hand.icon_override || species.sprite_sheets["held"]) t_state = "[t_state]_r"
			standing = image("icon"=((r_hand.icon_override) ? r_hand.icon_override : (species.sprite_sheets["held"] ? species.sprite_sheets["held"] : r_hand.righthand_file)), "icon_state"="[t_state]", "layer"=-R_HAND_LAYER)
		else
			standing = image("icon"=r_hand:icon_custom, "icon_state"="[t_state]_r", "layer"=-R_HAND_LAYER)
		standing.color = r_hand.color
		overlays_standing[R_HAND_LAYER] = standing
		if(handcuffed)
			drop_r_hand()

	apply_overlay(R_HAND_LAYER)


/mob/living/carbon/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)

	if(l_hand)
		l_hand.screen_loc = ui_lhand
		if(client && hud_used)
			client.screen += l_hand

		var/t_state = l_hand.item_state
		if(!t_state)
			t_state = l_hand.icon_state
		var/image/standing
		if(!l_hand:icon_custom || l_hand.icon_override || species.sprite_sheets["held"])
			if(l_hand.icon_override || species.sprite_sheets["held"]) t_state = "[t_state]_l"
			standing = image("icon"=((l_hand.icon_override) ? l_hand.icon_override : (species.sprite_sheets["held"] ? species.sprite_sheets["held"] : l_hand.lefthand_file)), "icon_state"="[t_state]", "layer"=-L_HAND_LAYER)
		else
			standing = image("icon"=l_hand:icon_custom, "icon_state"="[t_state]_l", "layer"=-L_HAND_LAYER)
		standing.color = l_hand.color
		overlays_standing[L_HAND_LAYER] = standing
		if(handcuffed)
			drop_l_hand()

	apply_overlay(L_HAND_LAYER)


/mob/living/carbon/proc/update_tail_showing()
	if(!species)
		return
	remove_overlay(TAIL_LAYER)

	if(species.tail && species.flags[HAS_TAIL])
		if(!wear_suit || !(wear_suit.flags_inv & HIDETAIL) && !istype(wear_suit, /obj/item/clothing/suit/space))
			var/image/tail_s = image(icon = 'icons/effects/species.dmi', icon_state = "[species.tail]_s", layer = -BODYPARTS_LAYER)
			tail_s.color = list(1,0,0, 0,1,0, 0,0,1, r_skin/255,g_skin/255,b_skin/255)
			overlays_standing[TAIL_LAYER] = tail_s

	apply_overlay(TAIL_LAYER)


//Adds a collar overlay above the helmet layer if the suit has one
//	Suit needs an identically named sprite in icons/mob/collar.dmi
/mob/living/carbon/proc/update_collar()
	remove_overlay(COLLAR_LAYER)

	if(wear_suit)
		var/icon/C = new('icons/mob/collar.dmi')
		if(wear_suit.icon_state in C.IconStates())

			var/image/standing = image("icon" = C, "icon_state" = "[wear_suit.icon_state]", "layer"=-COLLAR_LAYER)
			standing.color = wear_suit.color
			overlays_standing[COLLAR_LAYER]	= standing

	apply_overlay(COLLAR_LAYER)


/mob/living/carbon/proc/update_surgery()
	remove_overlay(SURGERY_LAYER)

	var/list/standing	= list()
	for(var/obj/item/bodypart/BP in bodyparts)
		if(BP.open)
			standing += image("icon"='icons/mob/surgery.dmi', "icon_state"="[BP.name][round(BP.open)]", "layer"=-SURGERY_LAYER)

	if(standing.len)
		overlays_standing[SURGERY_LAYER] = standing

	apply_overlay(SURGERY_LAYER)

/mob/living/carbon/proc/update_bandage()
	remove_overlay(BANDAGE_LAYER)

	var/list/standing	= list()
	for(var/obj/item/bodypart/BP in bodyparts)
		if(BP.wounds.len)
			for(var/datum/wound/W in BP.wounds)
				if(W.bandaged)
					standing +=	image("icon"='icons/mob/bandages.dmi', "icon_state"="[BP.name]", "layer"=-BANDAGE_LAYER)

	if(standing.len)
		overlays_standing[BANDAGE_LAYER] = standing

	apply_overlay(BANDAGE_LAYER)


/mob/living/carbon/proc/get_overlays_copy()
	var/list/out = new
	out = overlays_standing.Copy()
	return out

//Human Overlays Indexes/////////
#undef BODY_LAYER
#undef MUTANTRACE_LAYER
#undef MUTATIONS_LAYER
//#undef DAMAGE_LAYER
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
