/*
Ideas for the subtle effects of hallucination:

Light up oxygen/phoron indicators (done)
Cause health to look critical/dead, even when standing (done)
Characters silently watching you
Brief flashes of fire/space/bombs/c4/dangerous shit (done)
Items that are rare/traitorous/don't exist appearing in your inventory slots (done)
Strange audio (should be rare) (done)
Gunshots/explosions/opening doors/less rare audio (done)

*/

#define SCARY_SOUNDS pick('sound/hallucinations/scary_sound_1.ogg', \
                          'sound/hallucinations/scary_sound_2.ogg', \
                          'sound/hallucinations/scary_sound_3.ogg', \
                          'sound/hallucinations/scary_sound_4.ogg'  )
#define DEMON_SOUNDS pick('sound/hallucinations/demons_1.ogg', \
                          'sound/hallucinations/demons_2.ogg', \
                          'sound/hallucinations/demons_3.ogg', )

/mob/living/carbon
	var/image/halimage
	var/image/halbody
	var/obj/halitem
	var/hal_screwyhud = 0 //1 - critical, 2 - dead, 3 - oxygen indicator, 4 - toxin indicator
	var/handling_hal = 0
	var/hal_crit = 0

/mob/living/carbon/proc/handle_hallucinations()
	if(handling_hal) return
	handling_hal = 1
	while(client && hallucination > 20)
		sleep(rand(200, 500) / (hallucination / 25))
		switch(rand(1, 100))

        // SCREWY HUD

			if(0 to 15)
				hal_screwyhud = pick(1, 2, 3, 3, 4, 4)
				if(hal_screwyhud == 2 && prob(30))
					to_chat(src, "<span class='userdanger'>[pick("FUCK!", "FOR FUCKS SAKE, END THIS!", "")] I LOST! [pick("NNAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHH!", "DAMN THIS GAME IS SO HARD!", "I CAN'T PLAY THIS GAME ANY MORE!")]</span>")
					playsound_local(null, 'sound/hallucinations/fake_death.ogg', VOL_EFFECTS_MASTER)
				spawn(rand(100,250))
					hal_screwyhud = 0

        //STRANGE ITEMS

			if(16 to 25)
				if(!halitem && !HAS_TRAIT(src, TRAIT_STRONGMIND))
					halitem = new
					var/list/slots_free = list(ui_lhand,ui_rhand)
					if(l_hand) slots_free -= ui_lhand
					if(r_hand) slots_free -= ui_rhand
					if(istype(src,/mob/living/carbon/human))
						var/mob/living/carbon/human/H = src
						if(!H.belt) slots_free += ui_belt
						if(!H.l_store) slots_free += ui_storage1
						if(!H.r_store) slots_free += ui_storage2
					if(slots_free.len)
						halitem.screen_loc = pick(slots_free)
						halitem.layer = ABOVE_HUD_LAYER
						halitem.plane = ABOVE_HUD_PLANE
						switch(rand(1,6))
							if(1) //revolver
								halitem.icon = 'icons/obj/gun.dmi'
								halitem.icon_state = "revolver"
								halitem.name = "Revolver"
							if(2) //c4
								halitem.icon = 'icons/obj/assemblies.dmi'
								halitem.icon_state = "plastic-explosive0"
								halitem.name = "Mysterious Package"
								if(prob(25))
									halitem.icon_state = "c4small_1"
							if(3) //sword
								halitem.icon = 'icons/obj/weapons.dmi'
								halitem.icon_state = "sword1"
								halitem.name = "Sword"
							if(4) //stun baton
								halitem.icon = 'icons/obj/weapons.dmi'
								halitem.icon_state = "stunbaton"
								halitem.name = "Stun Baton"
							if(5) //emag
								halitem.icon = 'icons/obj/card.dmi'
								halitem.icon_state = "emag"
								halitem.name = "Cryptographic Sequencer"
							if(6) //flashbang
								halitem.icon = 'icons/obj/grenade.dmi'
								halitem.icon_state = "flashbang1"
								halitem.name = "Flashbang"
						if(client)
							client.screen += halitem
							if(prob(70))
								to_chat(src, "<span class='warning'>[pick("W-WHAT?", "AGAIN?!", "H-HA, HA-HA!")] [pick("IT'S TIME FOR REVENGE!", "FINALLY! I'LL SHOW THEM ALL...", "I NEED TO FIND A WORTHY OPPONENT!")]</span>")
								playsound_local(null, SCARY_SOUNDS, VOL_EFFECTS_MASTER, null, FALSE)
						spawn(rand(100,250))
							if(client)
								client.screen -= halitem
							halitem = null

        // FLASHES OF DANGER, TURFS

			if(26 to 40)
				if(!halimage && !HAS_TRAIT(src, TRAIT_STRONGMIND))
					var/list/possible_points = list()
					for(var/turf/simulated/floor/F in view(src,world.view))
						possible_points += F
					if(possible_points.len)
						var/turf/simulated/floor/target = pick(possible_points)
						switch(rand(1,3))
							if(1)
								//src << "Space"
								halimage = image('icons/turf/space.dmi',target,"[rand(1,25)]",TURF_LAYER)
							if(2)
								//src << "Fire"
								halimage = image('icons/effects/fire.dmi',target,"1",TURF_LAYER)
							if(3)
								//src << "C4"
								halimage = image('icons/obj/assemblies.dmi',target,"plastic-explosive2",OBJ_LAYER+0.01)
						if(prob(60))
							to_chat(src, "<span class='userdanger'>[pick("O-OH NO!", "SH-SHIT!", "NOT NOW! PLEASE!", "I DON'T WANT TO DIE!")] [pick("I H-HAVE TO RUN!", "QUICKLY! TO THE SHELTER", "")]</span>")
							playsound_local(null, DEMON_SOUNDS, VOL_EFFECTS_MASTER, null, FALSE)
							if(ishuman(src))
								var/mob/living/carbon/human/H = src
								if(!H.stat)
									H.emote(pick("scream", "cry", "laugh"))
						if(client)
							client.images += halimage
						spawn(rand(10,50)) //Only seen for a brief moment.
							if(client) client.images -= halimage
							halimage = null

        // STRANGE AUDIO

			if(41 to 65)
				var/list/possible_points = list()
				for(var/turf/simulated/S in view(src, world.view))
					possible_points += S
				if(!possible_points.len)
					handling_hal = 0
					return
				var/turf/simulated/target = pick(possible_points)
				switch(rand(1, 15))
					if(1) // AIRLOCKS
						var/list/hallsound = list('sound/machines/airlock/creaking.ogg',
						                          'sound/machines/airlock/open.ogg',
						                          'sound/machines/airlock/close.ogg')
						playsound_local(target, pick(hallsound), VOL_EFFECTS_MASTER)
					if(2) // EXPLOSIONS
						var/list/hallsound = list('sound/effects/explosionfar.ogg',
						                          'sound/effects/Explosion2.ogg',
						                          'sound/effects/Explosion1.ogg')
						playsound_local(target, pick(hallsound), VOL_EFFECTS_MASTER)
					if(3) // GLASS
						playsound_local(target, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
					if(4) // GROWLS
						var/list/hallsound = list('sound/voice/growl1.ogg',
						                          'sound/voice/growl2.ogg',
						                          'sound/voice/growl3.ogg')
						playsound_local(target, pick(hallsound), VOL_EFFECTS_MASTER)
					if(5) // MACHINERY
						var/list/hallsound = list('sound/machines/twobeep.ogg',
						                          'sound/misc/interference.ogg')
						playsound_local(target, pick(hallsound), VOL_EFFECTS_MASTER)
					if(6) // DEMONS & EMOTES
						if(prob(80))
							playsound_local(null, DEMON_SOUNDS, VOL_EFFECTS_MASTER, null, FALSE)
						if(ishuman(src))
							var/mob/living/carbon/human/H = src
							if(!H.stat)
								H.emote(pick("scream", "cry", "laugh"))
					if(7) // GUNSHOTS
						var/list/gunsound_list = list('sound/weapons/guns/gunshot_heavy.ogg',
						                              'sound/weapons/guns/gunshot_ak74.ogg',
						                              'sound/weapons/guns/gunshot_shotgun.ogg',
						                              'sound/weapons/guns/gunshot_medium.ogg',
						                              'sound/weapons/guns/gunshot_light.ogg',
						                              'sound/weapons/guns/gunshot_colt1911.ogg')
						var/gunsound = pick(gunsound_list)
						playsound_local(target, gunsound, VOL_EFFECTS_MASTER)
						spawn(rand(10,30))
							playsound_local(target, gunsound, VOL_EFFECTS_MASTER)
							if(prob(60))
								playsound_local(target, pick(SOUNDIN_FEMALE_HEAVY_PAIN + SOUNDIN_MALE_HEAVY_PAIN), VOL_EFFECTS_MASTER, null, FALSE)
					if(8) // MELEE
						var/list/hallsound = list('sound/weapons/smash.ogg',
						                          'sound/weapons/polkan_atk.ogg',
						                          'sound/weapons/Egloves.ogg',
						                          'sound/weapons/genhit3.ogg',
						                          'sound/weapons/armbomb.ogg')
						playsound_local(target, pick(hallsound), VOL_EFFECTS_MASTER)
					if(9) // GUNPULSES
						var/list/gunsound_list = list('sound/weapons/guns/plasma10_shot.ogg',
						                              'sound/weapons/guns/gunpulse_Taser.ogg',
						                              'sound/weapons/guns/gunpulse_laser.ogg',
						                              'sound/weapons/guns/gunpulse_stunrevolver.ogg')
						var/gunsound = pick(gunsound_list)
						playsound_local(target, gunsound, VOL_EFFECTS_MASTER)
						spawn(rand(10,30))
							playsound_local(target, gunsound, VOL_EFFECTS_MASTER)
					if(10) // GHOSTS AND FAR ROARS
						var/list/hallsound = list('sound/effects/ghost.ogg',
						                          'sound/effects/ghost2.ogg',
						                          'sound/hallucinations/veryfar_noise.ogg',
						                          'sound/hallucinations/far_noise.ogg',
						                          'sound/hallucinations/wail.ogg')
						playsound_local(target, pick(hallsound), VOL_EFFECTS_MASTER)
					if(11) // HIDDEN: SOURCE WHISPERS
						var/list/hallsound = list('sound/hallucinations/behind_you1.ogg',  'sound/hallucinations/behind_you2.ogg',
						                          'sound/hallucinations/im_here1.ogg',     'sound/hallucinations/im_here2.ogg',
						                          'sound/hallucinations/i_see_you_1.ogg',  'sound/hallucinations/i_see_you_2.ogg',
						                          'sound/hallucinations/look_up1.ogg',     'sound/hallucinations/look_up2.ogg',
						                          'sound/hallucinations/over_here1.ogg',   'sound/hallucinations/over_here2.ogg',
						                          'sound/hallucinations/over_here3.ogg',   'sound/hallucinations/turn_around1.ogg',
						                          'sound/hallucinations/turn_around2.ogg')
						playsound_local(target, pick(hallsound), VOL_EFFECTS_MASTER, null, FALSE)
					if(12) // WHISPERS
						var/list/hallsound = list('sound/hallucinations/whispers_1.ogg',
						                          'sound/hallucinations/whispers_2.ogg')
						playsound_local(null, pick(hallsound), VOL_EFFECTS_MASTER, null, FALSE)
						if(ishuman(src))
							var/mob/living/carbon/human/H = src
							H.stuttering += 15
							H.ear_deaf += 8
							H.Weaken(5)
							H.Stun(8)
							to_chat(src, "<span class='userdanger'>[pick("", "Voices in my head...", "WHY?!")] [pick("They're coming back!", "Not again...", "WHAT YOU NEED?!", "I CAN'T TAKE IT ANYMORE!", "GAAAAAAAAAAAAAH!")]</span>")
							H.emote("scream")
					if(13) // MISC
						var/list/hallsound = list('sound/effects/Heart Beat.ogg',
						                          'sound/hallucinations/liar.ogg',
						                          'sound/hallucinations/i_see_you_3.ogg',
						                          'sound/hallucinations/fake_poweroff.ogg')
						playsound_local(null, pick(hallsound), VOL_EFFECTS_MASTER, null, FALSE)
					else   // FAKE EVENTS
						var/list/hallsound = list('sound/hallucinations/fake_battle_1.ogg',
						                          'sound/hallucinations/fake_battle_2.ogg',
						                          'sound/hallucinations/fake_battle_3.ogg',
						                          'sound/hallucinations/fake_announcement.ogg')
						playsound_local(target, pick(hallsound), VOL_EFFECTS_MASTER, null, FALSE)

        // FLASHES OF DANGER, MOBS

			if(66 to 70)
				if(!halbody && !HAS_TRAIT(src, TRAIT_STRONGMIND))
					var/list/possible_points = list()
					for(var/turf/simulated/floor/F in view(src,world.view))
						possible_points += F
					if(possible_points.len)
						var/turf/simulated/floor/target = pick(possible_points)
						switch(rand(1,4))
							if(1)
								halbody = image('icons/mob/human.dmi',target,"husk_l",TURF_LAYER)
							if(2,3)
								halbody = image('icons/mob/human.dmi',target,"husk_s",TURF_LAYER)
							if(4)
								halbody = image('icons/mob/alien.dmi',target,"alienother",TURF_LAYER)
						if(client)
							client.images += halbody
							playsound_local(null, SCARY_SOUNDS, VOL_EFFECTS_MASTER, null, FALSE)
						spawn(rand(50,80)) // Only seen for a brief moment.
							if(client) client.images -= halbody
							halbody = null

			if(71 to 73)
				if(!HAS_TRAIT(src, TRAIT_STRONGMIND))
					fake_attack(src)

        // FAKE DEATH

			if(74 to 75)
				src.SetSleeping(40 SECONDS)
				hal_crit = 1
				hal_screwyhud = 1
				to_chat(src, "<span class='userdanger'>[pick("FUCK!", "FOR FUCKS SAKE, END THIS!", "", "WHY-Y-Y?!", "NOT AGAIN")] I LOST! [pick("NNAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHH!", "DAMN THIS GAME IS SO HARD!", "I CAN'T PLAY THIS GAME ANY MORE!")]</span>")
				playsound_local(null, 'sound/hallucinations/fake_death.ogg', VOL_EFFECTS_MASTER)
				spawn(rand(50,100))
					src.SetSleeping(0)
					hal_crit = 0
					hal_screwyhud = 0


	handling_hal = 0

#undef SCARY_SOUNDS
#undef DEMON_SOUNDS

/obj/effect/fake_attacker
	icon = null
	icon_state = null
	name = ""
	desc = ""
	density = 0
	anchored = 1
	opacity = 0
	var/mob/living/carbon/human/my_target = null
	var/weapon_name = null
	var/obj/item/weap = null
	var/image/currentimage = null
	var/icon/base = null
	var/s_tone
	var/mob/living/clone = null
	var/image/left
	var/image/right
	var/image/up
	var/collapse
	var/image/down

	var/health = 100

/obj/effect/fake_attacker/attackby(obj/item/weapon/P, mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	step_away(src,my_target,2)
	my_target.visible_message("<span class='warning'><B>[my_target] flails around wildly.</B></span>", self_message = "<span class='warning'><B>[src] has been attacked by [my_target] </B></span>")

	src.health -= P.force


	return

/obj/effect/fake_attacker/Crossed(atom/movable/AM)
	. = ..()
	if(AM == my_target)
		step_away(src,my_target,2)
		if(prob(30))
			for(var/mob/O in oviewers(world.view , my_target))
				to_chat(O, "<span class='warning'><B>[my_target] stumbles around.</B></span>")

/obj/effect/fake_attacker/atom_init()
	. = ..()
	QDEL_IN(src, 300)
	step_away(src,my_target,2)
	spawn attack_loop()

/obj/effect/fake_attacker/Destroy()
	if(my_target)
		my_target.hallucinations -= src
		my_target = null
	return ..()


/obj/effect/fake_attacker/proc/updateimage()
	//	qdel(src.currentimage)


	if(src.dir == NORTH)
		qdel(src.currentimage)
		src.currentimage = new /image(up,src)
	else if(src.dir == SOUTH)
		qdel(src.currentimage)
		src.currentimage = new /image(down,src)
	else if(src.dir == EAST)
		qdel(src.currentimage)
		src.currentimage = new /image(right,src)
	else if(src.dir == WEST)
		qdel(src.currentimage)
		src.currentimage = new /image(left,src)
	my_target << currentimage


/obj/effect/fake_attacker/proc/attack_loop()
	while(1)
		sleep(rand(5,10))
		if(src.health < 0)
			collapse()
			continue
		if(get_dist(src,my_target) > 1)
			src.dir = get_dir(src,my_target)
			step_towards(src,my_target)
			updateimage()
		else
			if(prob(15))
				src.do_attack_animation(my_target)
				if(weapon_name)
					my_target.playsound_local(null, pick(SOUNDIN_GENHIT), VOL_EFFECTS_MASTER)
					my_target.show_message("<span class='warning'><B>[my_target] has been attacked with [weapon_name] by [src.name] </B></span>", SHOWMSG_VISUAL)
					my_target.halloss += 8
					if(prob(20)) my_target.eye_blurry += 3
					if(prob(33))
						if(!locate(/obj/effect/overlay) in my_target.loc)
							fake_blood(my_target)
				else
					my_target.playsound_local(null, pick(SOUNDIN_PUNCH), VOL_EFFECTS_MASTER, 35)
					my_target.show_message("<span class='warning'><B>[src.name] has punched [my_target]!</B></span>", SHOWMSG_VISUAL)
					my_target.halloss += 4
					if(prob(33))
						if(!locate(/obj/effect/overlay) in my_target.loc)
							fake_blood(my_target)

		if(prob(15))
			step_away(src,my_target,2)

/obj/effect/fake_attacker/proc/collapse()
	collapse = 1
	updateimage()

/proc/fake_blood(mob/living/carbon/human/target)
	var/obj/effect/overlay/O = new/obj/effect/overlay(target.loc)

	var/datum/dirt_cover/D = new(target.species.blood_datum)
	O.name = D.name
	O.color = D.color

	var/image/I = image('icons/effects/blood.dmi',O,"mfloor[rand(1,7)]",O.dir,1)
	target << I
	spawn(300)
		qdel(O)
	return

var/list/non_fakeattack_weapons = list(/obj/item/weapon/gun/projectile, /obj/item/ammo_box/a357,\
	/obj/item/weapon/gun/energy/crossbow, /obj/item/weapon/melee/energy/sword,\
	/obj/item/weapon/storage/box/syndicate, /obj/item/weapon/storage/box/emps,\
	/obj/item/weapon/cartridge/syndicate, /obj/item/clothing/under/chameleon,\
	/obj/item/clothing/shoes/syndigaloshes, /obj/item/weapon/card/id/syndicate,\
	/obj/item/clothing/mask/gas/voice, /obj/item/clothing/glasses/thermal,\
	/obj/item/device/chameleon, /obj/item/weapon/card/emag,\
	/obj/item/weapon/storage/toolbox/syndicate, /obj/item/weapon/aiModule,\
	/obj/item/device/radio/headset/syndicate,	/obj/item/weapon/plastique,\
	/obj/item/device/powersink, /obj/item/weapon/storage/box/syndie_kit,\
	/obj/item/toy/syndicateballoon, /obj/item/weapon/gun/energy/laser/selfcharging/captain,\
	/obj/item/weapon/hand_tele, /obj/item/weapon/rcd, /obj/item/weapon/tank/jetpack,\
	/obj/item/clothing/under/rank/captain, /obj/item/device/aicard,\
	/obj/item/clothing/shoes/magboots, /obj/item/blueprints, /obj/item/weapon/disk/nuclear,\
	/obj/item/clothing/suit/space/nasavoid, /obj/item/weapon/tank)

/proc/fake_attack(mob/living/target)
//	var/list/possible_clones = new/list()
	var/mob/living/carbon/human/clone = null
	var/clone_weapon = null

	for(var/mob/living/carbon/human/H in human_list)
		if(H.incapacitated())
			continue
//		possible_clones += H
		clone = H
		break	//changed the code a bit. Less randomised, but less work to do. Should be ok, world.contents aren't stored in any particular order.

//	if(!possible_clones.len) return
//	clone = pick(possible_clones)
	if(!clone)	return

	//var/obj/effect/fake_attacker/F = new/obj/effect/fake_attacker(outside_range(target))
	var/obj/effect/fake_attacker/F = new/obj/effect/fake_attacker(target.loc)
	if(clone.l_hand)
		if(!(locate(clone.l_hand) in non_fakeattack_weapons))
			clone_weapon = clone.l_hand.name
			F.weap = clone.l_hand
	else if (clone.r_hand)
		if(!(locate(clone.r_hand) in non_fakeattack_weapons))
			clone_weapon = clone.r_hand.name
			F.weap = clone.r_hand

	F.name = clone.name
	F.my_target = target
	F.weapon_name = clone_weapon
	target.hallucinations += F


	F.left = image(clone,dir = WEST)
	F.right = image(clone,dir = EAST)
	F.up = image(clone,dir = NORTH)
	F.down = image(clone,dir = SOUTH)

	F.updateimage()
