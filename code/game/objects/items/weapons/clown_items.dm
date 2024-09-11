/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Soap
 *		Bike Horns
 */

/*
 * Banana Peals
 */

/obj/item/weapon/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = SIZE_TINY
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/bananapeel/atom_init()
	. = ..()
	AddComponent(/datum/component/slippery, 2)

/obj/item/weapon/bananapeel/honk
	name = "Clowny banana peel"
	desc = "A peel from a banana for Clown."
	icon = 'icons/obj/items.dmi'
	icon_state = "h-banana_peel"
	item_state = "h-banana_peel"
	w_class = SIZE_TINY
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/bananapeel/honk/atom_init()
	. = ..()
	AddComponent(/datum/component/slippery, 3, SLIDE | GALOSHES_DONT_HELP)

/*
 * Soap
 */

/obj/item/weapon/reagent_containers/food/snacks/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	item_state_world = "soap_world"
	w_class = SIZE_TINY
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	filling_color = "#ff1c1c"
	bitesize = 3
	list_reagents = list("cleaner" = 5)

/obj/item/weapon/reagent_containers/food/snacks/soap/atom_init()
	. = ..()
	AddComponent(/datum/component/slippery, 2)

/obj/item/weapon/reagent_containers/food/snacks/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of phoron."
	icon_state = "soapnt"
	item_state_world = "soapnt_world"

/obj/item/weapon/reagent_containers/food/snacks/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of condoms."
	icon_state = "soapdeluxe"
	item_state_world = "soapdeluxe_world"

/obj/item/weapon/reagent_containers/food/snacks/soap/syndie
	desc = "An untrustworthy bar of soap. Smells of fear."
	icon_state = "soapsyndie"
	item_state_world = "soapsyndie_world"
	list_reagents = list("cleaner" = 3, "cyanide" = 2)

/obj/item/weapon/reagent_containers/food/snacks/soap/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity || ishuman(target)) return
	// I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	// So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		to_chat(user, "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>")
	else if(istype(target,/obj/effect/decal/cleanable))
		to_chat(user, "<span class='notice'>You scrub \the [target.name] out.</span>")
		qdel(target)
	else
		to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
		target.clean_blood()
	return

/obj/item/weapon/reagent_containers/food/snacks/soap/attack(mob/target, mob/user, def_zone)
	if(user.a_intent == INTENT_HARM)
		..()
	else if(target && user && ishuman(target) && ishuman(user) && user.stat == CONSCIOUS && user.zone_sel && !user.is_busy())
		var/mob/living/carbon/human/H = target
		var/body_part_name
		switch(def_zone)
			if(BP_L_LEG, BP_R_LEG)
				body_part_name = "legs"
			if(BP_L_ARM, BP_R_ARM)
				body_part_name = "arms"
			else
				body_part_name = def_zone
		if(target == user)
			user.visible_message("<span class='notice'>\the [user] starts to clean \his [body_part_name] out with soap.</span>")
		else
			user.visible_message("<span class='notice'>\the [user] starts to clean \the [target]'s [body_part_name] out with soap.</span>")
		if(do_after(user, 15, target = H) && src)
			switch(body_part_name)
				if("mouth")
					return
				if("groin")
					if(H.belt)
						H.belt.clean_blood()
				if("head")
					if(H.head)
						var/washmask = !(H.head.flags_inv & HIDEMASK)
						var/washears = !((H.head.flags_inv & HIDEEARS) || (H.wear_mask && H.wear_mask.flags_inv & HIDEEARS))
						var/washglasses = !((H.head.flags_inv & HIDEEYES) || (H.wear_mask && H.wear_mask.flags_inv & HIDEEYES))
						if(!(washmask && H.wear_mask && H.wear_mask.clean_blood()))
							H.lip_style = null
							H.update_body()
						if(H.glasses && washglasses)
							H.glasses.clean_blood()
						if(H.l_ear && washears)
							H.l_ear.clean_blood()
						if(H.r_ear && washears)
							H.r_ear.clean_blood()
						H.head.clean_blood()
				if("chest")
					if(!(H.wear_suit && H.wear_suit.clean_blood()) && H.w_uniform)
						H.w_uniform.clean_blood()
					if(H.belt)
						H.belt.clean_blood()
				if("eyes")
					if(!(H.head && (H.head.flags_inv & HIDEEYES)))
						if(H.glasses)
							H.glasses.clean_blood()
						else
							H.blurEyes(5)
							H.eye_blind = max(H.eye_blind, 1)
							to_chat(H, "<span class='warning'>Ouch! That hurts!</span>")
				if("legs")
					var/obj/item/organ/external/l_foot = H.bodyparts_by_name[BP_L_LEG]
					var/obj/item/organ/external/r_foot = H.bodyparts_by_name[BP_R_LEG]
					var/no_legs = FALSE
					if((!l_foot || (l_foot && (l_foot.is_stump))) && (!r_foot || (r_foot && (r_foot.is_stump))))
						no_legs = TRUE
					if(!no_legs)
						if(!(H.shoes && H.shoes.clean_blood()))
							H.feet_blood_DNA = null  // blood mechanic (feet_blood_DNA, feet_dirt_color, etc) should be fused into organ item objects on mob instead of mob itself,
							H.feet_dirt_color = null // so we can refer to that info in update_icons.dm to draw blood and do more advanced stuff which is much harder when its hardcoded to mob while actually tied to limbs.
							H.update_inv_slot(SLOT_SHOES)
					else
						to_chat(user, "<span class='red'>There is nothing to clean!</span>")
						return
				if("arms")
					var/obj/item/organ/external/r_hand = H.bodyparts_by_name[BP_L_ARM]
					var/obj/item/organ/external/l_hand = H.bodyparts_by_name[BP_R_ARM]
					if((l_hand && !(l_hand.is_stump)) && (r_hand && !(r_hand.is_stump)))
						if(H.gloves && H.gloves.clean_blood())
							H.gloves.germ_level = 0
						else
							if(H.dirty_hands_transfers)
								H.dirty_hands_transfers = 0
								H.update_inv_slot(SLOT_GLOVES)
							H.germ_level = 0
			H.clean_blood()
			if(target == user)
				user.visible_message("<span class='notice'>\the [user] cleans \his [body_part_name] out with soap.</span>")
			else
				user.visible_message("<span class='notice'>\the [user] cleans \the [target]'s [body_part_name] out with soap.</span>")
			playsound(src, 'sound/misc/slip.ogg', VOL_EFFECTS_MASTER)
			return
		else
			user.visible_message("<span class='red'>\the [user] fails to clean \the [target]'s [body_part_name] out with soap.</span>")
			return


/*
 * Bike Horns
 */

/obj/item/weapon/bikehorn/gold
	name = "golden bike horn"
	desc = "Golden? Clearly, it's made with bananium! Honk!"
	icon = 'icons/obj/golden_bikehorn.dmi'
	icon_state = "gold_horn"
	item_state = "bike_horn"
	COOLDOWN_DECLARE(golden_horn_cooldown)

/obj/item/weapon/bikehorn/gold/honk(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, golden_horn_cooldown))
		return
	var/turf/T = get_turf(src)
	for(var/mob/living/M in ohearers(7, T))
		M.SpinAnimation(7, 1)
	COOLDOWN_START(src, golden_horn_cooldown, 1 SECONDS)

/obj/item/weapon/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = 3
	w_class = SIZE_MINUSCULE
	throw_speed = 3
	throw_range = 15
	attack_verb = list("HONKED")
	var/cooldown = FALSE

/obj/item/weapon/bikehorn/proc/honk(mob/user)
	playsound(src, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MISC)
	if(user.can_waddle())
		user.waddle(pick(-14, 0, 14), 4)

/obj/item/weapon/bikehorn/attack(mob/target, mob/user, def_zone)
	. = ..()
	honk(user)

/obj/item/weapon/bikehorn/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = world.time + 8
		honk(user)
		add_fingerprint(user)

/obj/item/weapon/bikehorn/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM) && cooldown <= world.time)
		cooldown = world.time + 8
		honk(AM)

/obj/item/weapon/bikehorn/dogtoy
	name = "dog toy"
	desc = "This adorable toy is made with super soft plush and has a squeaker inside for added entertainment."	//Woof!
	icon = 'icons/obj/items.dmi'
	icon_state = "dogtoy"
	item_state = "dogtoy"

//////////////////////////////////////////////////////
//					 Sound Button   				//
//////////////////////////////////////////////////////

/obj/item/toy/sound_button
	name = "sound button"
	desc = "It's a perfect adding to the bad joke."
	icon = 'icons/obj/toy.dmi'
	icon_state = "sound_button_on"
	var/cooldown = FALSE
	var/cooldown_max = 60
	var/click_radius = -4
	w_class = SIZE_TINY
	var/actions
	var/pos_sounds

/obj/item/toy/sound_button/atom_init()
	. = ..()
	init_soundboard()

/obj/item/toy/sound_button/proc/init_soundboard()
	actions = list(
		"Laugh" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "clown"),
		"Weapon shot" = image(icon = 'icons/obj/gun.dmi', icon_state = "taser"),
		"Melee weapon" = image(icon = 'icons/obj/items.dmi', icon_state = "fire_extinguisher0"),
		"Effects" = image(icon = 'icons/obj/drinks.dmi', icon_state = "ice_tea_can"),
		"Screams of pain" = image(icon = 'icons/obj/objects.dmi', icon_state = "monkey")
		)

	pos_sounds = list(
		"Laugh" = list('sound/voice/fake_laugh/laugh1.ogg',
						'sound/voice/fake_laugh/laugh2.ogg',
						'sound/voice/fake_laugh/laugh3.ogg'),

		"Weapon shot" = list('sound/weapons/blaster.ogg',
						'sound/weapons/pyrometr_shot.ogg',
						'sound/weapons/guns/gunpulse.ogg',
						'sound/weapons/guns/gunpulse2.ogg',
						'sound/weapons/guns/gunpulse3.ogg',
						'sound/weapons/guns/gunpulse_emitter2.ogg',
						'sound/weapons/guns/gunpulse_laser.ogg',
						'sound/weapons/guns/gunpulse_laser3.ogg',
						'sound/weapons/guns/gunpulse_laser4.ogg',
						'sound/weapons/guns/gunpulse_railgun.ogg',
						'sound/weapons/guns/gunpulse_stunrevolver.ogg',
						'sound/weapons/guns/gunpulse_Taser.ogg',
						'sound/weapons/guns/gunpulse_taser2.ogg',
						'sound/weapons/guns/gunpulse_wave.ogg',
						'sound/weapons/guns/Gunshot.ogg',
						'sound/weapons/guns/Gunshot3.ogg',
						'sound/weapons/guns/gunshot_acm38.ogg',
						'sound/weapons/guns/gunshot_ak74.ogg',
						'sound/weapons/guns/gunshot_cannon.ogg',
						'sound/weapons/guns/gunshot_colt1911.ogg',
						'sound/weapons/guns/gunshot_heavy.ogg',
						'sound/weapons/guns/gunshot_light.ogg',
						'sound/weapons/guns/gunshot_m79.ogg',
						'sound/weapons/guns/gunshot_medium.ogg',
						'sound/weapons/guns/gunshot_pneumaticgun.ogg',
						'sound/weapons/guns/kenetic_accel.ogg',
						'sound/weapons/guns/lasercannonfire.ogg',
						'sound/weapons/guns/lasertag.ogg',
						'sound/weapons/guns/marauder.ogg',
						'sound/weapons/guns/plasma10_hit.ogg',
						'sound/weapons/guns/plasma10_overcharge_massive_shot.ogg',
						'sound/weapons/guns/resonator_blast.ogg'),

		"Melee weapon" = list('sound/items/drill_hit.ogg',
						'sound/items/sledgehammer_hit.ogg',
						'sound/items/trayhit1.ogg',
						'sound/items/trayhit2.ogg',
						'sound/items/misc/balloon_big-hit.ogg',
						'sound/items/misc/balloon_small-hit.ogg',
						'sound/items/misc/belt-slap.ogg',
						'sound/items/misc/glove-slap.ogg',
						'sound/items/tools/cable-slap.ogg',
						'sound/items/tools/crowbar-hit.ogg',
						'sound/items/tools/tool-hit.ogg',
						'sound/items/tools/toolbox-hit.ogg',
						'sound/items/tools/wirecutters-pinch.ogg',
						'sound/misc/desceration-01.ogg',
						'sound/weapons/blade1.ogg',
						'sound/weapons/bladeslice.ogg',
						'sound/weapons/captainwhip.ogg',
						'sound/weapons/circsawhit.ogg',
						'sound/weapons/Egloves.ogg',
						'sound/weapons/genhit1.ogg',
						'sound/weapons/metal_shield_hit.ogg',
						'sound/effects/mob/hits/medium_1.ogg',
						'sound/effects/mob/hits/heavy_1.ogg',
						'sound/effects/mob/hits/veryheavy_1.ogg',
						'sound/weapons/smash.ogg',
						'sound/weapons/slash.ogg'),

		"Effects" = list('sound/effects/air_release.ogg',
						'sound/effects/ArterialBleed.ogg',
						'sound/effects/bamf.ogg',
						'sound/effects/bang.ogg',
						'sound/effects/blobattack.ogg',
						'sound/effects/bodyfall1.ogg',
						'sound/effects/bonebreak1.ogg',
						'sound/effects/bubble_spawn.ogg',
						'sound/effects/bubbles.ogg',
						'sound/effects/can_open2.ogg',
						'sound/effects/clang.ogg',
						'sound/effects/clownstep1.ogg',
						'sound/effects/curtain.ogg',
						'sound/effects/shovel_digging.ogg',
						'sound/effects/electric_shock.ogg',
						'sound/effects/EMPulse.ogg',
						'sound/effects/Explosion1.ogg',
						'sound/effects/extinguish.ogg',
						'sound/effects/extinguish_mob.ogg',
						'sound/effects/forcefield_destroy.ogg',
						'sound/effects/forcefield_hit2.ogg',
						'sound/effects/fultext_launch.ogg',
						'sound/effects/ghost2.ogg',
						'sound/effects/Glassbr2.ogg',
						'sound/effects/glasses_on.ogg',
						'sound/effects/Glasshit.ogg',
						'sound/effects/grillehit.ogg',
						'sound/effects/hits_to_w_shield.ogg',
						'sound/effects/hulk_attack.ogg',
						'sound/effects/hulk_hit_wall.ogg',
						'sound/effects/hulk_step.ogg',
						'sound/effects/inflate.ogg',
						'sound/effects/light-break.ogg',
						'sound/effects/magic.ogg',
						'sound/effects/meteorimpact.ogg',
						'sound/effects/phasein.ogg',
						'sound/effects/refill.ogg',
						'sound/effects/scary_honk.ogg',
						'sound/effects/shieldbash.ogg',
						'sound/effects/supermatter.ogg'),

		"Screams of pain" = list('sound/voice/mob/pain/male/heavy_1.ogg',
						'sound/voice/mob/pain/male/heavy_2.ogg',
						'sound/voice/mob/pain/male/heavy_3.ogg',
						'sound/voice/mob/pain/male/heavy_4.ogg',
						'sound/voice/mob/pain/male/heavy_5.ogg',
						'sound/voice/mob/pain/male/heavy_6.ogg',
						'sound/voice/mob/pain/male/heavy_7.ogg',
						'sound/voice/mob/pain/male/heavy_8.ogg',
						'sound/voice/mob/pain/male/light_1.ogg',
						'sound/voice/mob/pain/male/light_2.ogg',
						'sound/voice/mob/pain/male/light_3.ogg',
						'sound/voice/mob/pain/male/light_4.ogg',
						'sound/voice/mob/pain/male/light_5.ogg',
						'sound/voice/mob/pain/male/light_6.ogg',
						'sound/voice/mob/pain/male/light_7.ogg',
						'sound/voice/mob/pain/male/light_8.ogg',
						'sound/voice/mob/pain/male/passive_whiner_1.ogg',
						'sound/voice/mob/pain/male/passive_whiner_2.ogg',
						'sound/voice/mob/pain/male/passive_whiner_3.ogg',
						'sound/voice/mob/pain/male/passive_whiner_4.ogg')
						)

/obj/item/toy/sound_button/attack_self(mob/user)
	if(cooldown)
		return

	var/soundtype = show_radial_menu(user, src, actions, require_near = TRUE, tooltips = TRUE)
	if(!soundtype)
		return

	playsound(src, pick(pos_sounds[soundtype]), VOL_EFFECTS_MASTER, 85, FALSE)
	flick("sound_button_down", src)
	icon_state = "sound_button_off"
	cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(release_cooldown)), cooldown_max)
	..()

/obj/item/toy/sound_button/proc/release_cooldown()
	flick("sound_button_up",src)
	icon_state = "sound_button_on"
	cooldown = FALSE
	playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER, 50, FALSE, null, click_radius)
	return

//Syndicate version

/obj/item/toy/sound_button/syndi
	name = "sound decoy"
	desc = "Can easily lure someone into your trap. Trust me!"
	cooldown_max = 40
	click_radius = -7

/obj/item/toy/sound_button/syndi/init_soundboard()
	actions = list(
		"Battle" = image(icon = 'icons/obj/cardboard_cutout.dmi', icon_state = "cutout_traitor"),
		"Mystical shit" = image(icon = 'icons/obj/cardboard_cutout.dmi', icon_state = "cutout_wizard"),
		"Xenomorph" = image(icon = 'icons/obj/cardboard_cutout.dmi', icon_state = "cutout_fukken_xeno"),
		"Make'em paranoid!" = image(icon = 'icons/obj/cardboard_cutout.dmi', icon_state = "cutout_shadowling")
	)
	pos_sounds = list(
		"Battle" = list(
			'sound/hallucinations/fake_battle_1_scaled.ogg',
			'sound/hallucinations/fake_battle_2_scaled.ogg',
			'sound/hallucinations/fake_battle_3_scaled.ogg'
			),

		"Mystical shit" = list(
			'sound/magic/Knock.ogg',
			'sound/magic/Fireball.ogg',
			'sound/magic/Teleport_diss.ogg',
			'sound/magic/Teleport_app.ogg',
			'sound/magic/MAGIC_MISSILE.ogg',
			'sound/magic/Repulse.ogg',
			'sound/effects/ghost2.ogg'),

		"Xenomorph" = list(
			'sound/voice/shriek1.ogg',
			'sound/voice/xenomorph/talk_1.ogg',
			'sound/voice/xenomorph/talk_2.ogg',
			'sound/voice/xenomorph/talk_3.ogg',
			'sound/voice/xenomorph/talk_4.ogg',
			'sound/voice/xenomorph/whimper.ogg',
			'sound/voice/xenomorph/small_roar.ogg',
			'sound/voice/xenomorph/spitacid_1.ogg',
			'sound/voice/xenomorph/spitacid_2.ogg',
			'sound/voice/xenomorph/chestburst_1.ogg',
			'sound/voice/xenomorph/chestburst_2.ogg'),

		"Make'em paranoid!" = list(
			'sound/hallucinations/behind_you1.ogg',
			'sound/hallucinations/behind_you2.ogg',
			'sound/hallucinations/far_noise.ogg',
			'sound/hallucinations/veryfar_noise.ogg',
			'sound/hallucinations/wail.ogg',
			'sound/hallucinations/i_see_you_1.ogg',
			'sound/hallucinations/im_here1.ogg',
			'sound/hallucinations/im_here2.ogg',
			'sound/hallucinations/look_up1.ogg',
			'sound/hallucinations/over_here1.ogg',
			'sound/hallucinations/turn_around1.ogg')
	)
