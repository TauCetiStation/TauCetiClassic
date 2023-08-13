/obj/structure/blob/factory
	name = "factory blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_factory"
	max_integrity = 100
	fire_resist = 2
	var/list/spores = list()
	var/max_spores = 3
	var/spore_delay = 0
	var/mob/living/simple_animal/hostile/blob/blobbernaut/naut = null

/obj/structure/blob/factory/Destroy()
	for(var/mob/living/simple_animal/hostile/blob/blobspore/spore as anything in spores)
		if(spore.factory == src)
			spore.factory = null
	if(naut)
		naut.factory = null
		to_chat(naut, "<span class='danger'>Your factory was destroyed! You feel yourself dying!</span>")
		naut.throw_alert("nofactory", /atom/movable/screen/alert/nofactory)
	if(OV)
		OV.factory_blobs -= src
	return ..()

/obj/structure/blob/factory/run_action()
	if(naut)
		return
	if(spores.len >= max_spores)
		return
	if(spore_delay > world.time)
		return

	spore_delay = world.time + 100 // 10 seconds
	PulseAnimation()

	var/mob/living/simple_animal/hostile/blob/blobspore/S = new (loc, src)
	if(OV) //if we don't have an overmind, we don't need to do anything but make a spore
		S.overmind = OV
		OV.blob_mobs.Add(S)

////////////////
// BASE TYPE //
////////////////

//Do not spawn
/mob/living/simple_animal/hostile/blob
	icon = 'icons/mob/blob.dmi'
	pass_flags = PASSBLOB
	speak_emote = null //so we use verb_yell/verb_say/etc
	minbodytemp = 0
	maxbodytemp = INFINITY
	pass_flags = PASSBLOB
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	faction = "blob"
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 360
	var/mob/camera/blob/overmind = null
	var/obj/structure/blob/factory/factory = null
	var/independent = FALSE

/mob/living/simple_animal/hostile/blob/Login()
	. = ..()
	if(!client)
		return
	var/datum/faction/blob_conglomerate/C = find_faction_by_type(/datum/faction/blob_conglomerate)
	if(!C)
		return FALSE
	for(var/datum/role/blob_overmind/M in C.members)
		var/datum/role/R = M
		if(!R.antag.current)
			return
		if(!isovermind(R.antag.current))
			continue
		var/mob/camera/blob/O = R.antag.current
		client.images |= O.ghostimage

/mob/living/simple_animal/hostile/blob/Destroy()
	if(overmind)
		overmind.blob_mobs.Remove(src)
		overmind = null
		factory = null
	return ..()

/mob/living/simple_animal/hostile/blob/Stat()
	..()
	if(statpanel("Status") && !independent)
		if(overmind)
			if(overmind.blob_core)
				stat(null, "Core Health: [overmind.blob_core.get_integrity()]")
			stat(null, "Progress: [blobs.len]/[overmind.b_congl.blobwincount]")

/mob/living/simple_animal/hostile/blob/blob_act(/obj/structure/blob/B)
	if(stat != DEAD && health < maxHealth)
		health += maxHealth*0.0125

/mob/living/simple_animal/hostile/blob/fire_act(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature)
		adjustFireLoss(clamp(0.01 * exposed_temperature, 1, 5))
	else
		adjustFireLoss(5)

/mob/living/simple_animal/hostile/blob/Process_Spacemove(movement_dir = 0)
	for(var/obj/structure/blob/B in range(1, src))
		return 1
	return ..()

/mob/living/simple_animal/hostile/blob/say(message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat != CONSCIOUS)
		return

	message = sanitize(message)

	if (!message)
		return

	log_say("[key_name(src)] : [message]")

	message = "<span class='say_quote'>says,</span> \"<span class='body'>[message]</span>\""
	message = "<span style='color:#EE4000'><i><span class='game say'>Blob Telepathy, <span class='name'>[name]</span> <span class='message'>[message]</span></span></i></span>"

	for(var/M in mob_list)
		if(isovermind(M) || istype(M, /mob/living/simple_animal/hostile/blob))
			to_chat(M, message)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [message]")

////////////////
// BLOB SPORE //
////////////////
/mob/living/simple_animal/hostile/blob/blobspore
	name = "blob spore"
	desc = "Some blob thing."
	icon_state = "blobpod"
	icon_living = "blobpod"
	pass_flags = PASSBLOB
	health = 40
	maxHealth = 40
	melee_damage = 3
	attacktext = "attack"
	attack_sound = list('sound/weapons/genhit1.ogg')
	var/is_zombie = 0

/mob/living/simple_animal/hostile/blob/blobspore/blob_act()
	return

/mob/living/simple_animal/hostile/blob/blobspore/CanPass(atom/movable/mover, turf/target, height=0)
	if(isblob(mover))
		return TRUE
	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/atom_init(mapload, obj/structure/blob/factory/linked_node)
	if(istype(linked_node))
		factory = linked_node
		factory.spores += src
	. = ..()

/mob/living/simple_animal/hostile/blob/blobspore/Life()

	if(!is_zombie && isturf(src.loc))
		for(var/mob/living/carbon/human/H in oview(src,1)) //Only for corpse right next to/on same tile
			if(H.stat == DEAD)
				Zombify(H)
				break
	..()

/mob/living/simple_animal/hostile/blob/blobspore/proc/Zombify(mob/living/carbon/human/H)
	if(H.wear_suit)
		var/obj/item/clothing/suit/armor/A = H.wear_suit
		if(A.armor && A.armor[MELEE])
			maxHealth += A.armor[MELEE] //That zombie's got armor, I want armor!
	maxHealth += 40
	health = maxHealth
	name = "blob zombie"
	desc = "A shambling corpse animated by the blob."
	melee_damage = 13
	icon = H.icon
	icon_state = "husk_s"
	H.h_style = null
	H.update_hair()
	copy_overlays(H, TRUE)
	add_overlay(image('icons/mob/blob.dmi', icon_state = "blob_head"))
	H.loc = src
	is_zombie = 1
	loc.visible_message("<span class='warning'> The corpse of [H.name] suddenly rises!</span>")

/mob/living/simple_animal/hostile/blob/blobspore/death()
// On death, create a small smoke of harmful gas (s-Acid)
	var/datum/effect/effect/system/smoke_spread/chem/S = new
	var/turf/location = get_turf(src)

	// Create the reagents to put into the air, s-acid is yellow and stings a little
	create_reagents(25)
	reagents.add_reagent("spore", 25)

	// Attach the smoke spreader and setup/start it.
	S.attach(location)
	S.set_up(reagents, 1, 1, location, 15, 1) // only 1-2 smoke cloud
	S.start()
	..()

	qdel(src)

/mob/living/simple_animal/hostile/blob/blobspore/Destroy()
	if(factory)
		factory.spores -= src
	if(contents)
		for(var/mob/M in contents)
			M.loc = src.loc
	return ..()

/datum/reagent/toxin/spore
	name = "Spore Toxin"
	id = "spore"
	description = "A toxic spore cloud which blocks vision when ingested."
	color = "#9acd32"
	toxpwr = 0.5

/datum/reagent/toxin/spore/on_general_digest(mob/living/M)
	..()
	M.damageoverlaytemp = 60
	M.blurEyes(15)

/////////////////
// BLOBBERNAUT //
/////////////////

/mob/living/simple_animal/hostile/blob/blobbernaut
	name = "blobbernaut"
	desc = "A hulking, mobile chunk of blobmass."
	icon_state = "blobbernaut"
	icon_living = "blobbernaut"
	icon_dead = "blobbernaut_dead"
	health = 300
	maxHealth = 300
	attacktext = "slams"
	melee_damage = 20
	attack_sound = 'sound/effects/blobattack.ogg'
	environment_smash = 1
	speed = 2
	sight = SEE_TURFS | SEE_MOBS

/mob/living/simple_animal/hostile/blob/blobbernaut/atom_init()
	. = ..()
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name

/mob/living/simple_animal/hostile/blob/blobbernaut/add_to_hud(datum/hud/hud, add_health=FALSE)
	. = ..()
	hud.init_screens(list(
		/atom/movable/screen/health/blob/blobbernaut,
		/atom/movable/screen/blob_power/blobbernaut,
		))

/mob/living/simple_animal/hostile/blob/blobbernaut/Login()
	..()
	update_hud()

	var/datum/faction/blob_conglomerate/C = find_faction_by_type(/datum/faction/blob_conglomerate)
	if(!C)
		return FALSE
	var/datum/role/blobbernaut/R = SSticker.mode.CreateRole(/datum/role/blobbernaut, src)
	C.HandleRecruitedRole(R)

/mob/living/simple_animal/hostile/blob/blobbernaut/update_health_hud() //ONLY healths
	if(!hud_used) //Yes, we really need it
		return
	if(healths)
		healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(health)]</font></div>"

/mob/living/simple_animal/hostile/blob/blobbernaut/update_hud() //Basically called only once per join
	if(!hud_used) //Yes, we really need it
		return
	if(healths)
		healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(health)]</font></div>"
		healths.name = "Healths"
	if(independent) //Was it with blob or not
		return
	if(overmind.blob_core && pwr_display) //Just in case, otherwise it is looped runtime
		pwr_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(overmind.blob_core.get_integrity())]</font></div>"

/mob/living/simple_animal/hostile/blob/blobbernaut/attack_animal(mob/user)
	if(faction == user.faction) //To avoid blobbernaut vs blobbernaut and spore's kills
		return
	..()

/mob/living/simple_animal/hostile/blob/blobbernaut/adjustBruteLoss(damage) //I hate it. Where is my AdjustHealth?
	. = ..()
	update_health_hud()
/mob/living/simple_animal/hostile/blob/blobbernaut/adjustFireLoss(damage)
	. = ..()
	update_health_hud()
/mob/living/simple_animal/hostile/blob/blobbernaut/ex_act(severity)
	. = ..()
	update_health_hud()

/mob/living/simple_animal/hostile/blob/blobbernaut/blob_act()
	if(!factory)
		return
	..()

/mob/living/simple_animal/hostile/blob/blobbernaut/Life()
	. = ..()
	if(stat == DEAD)
		return //No funny ressurections
	if(independent)
		return // strong independent blobbernaut that don't need blob
	var/list/blobs_in_area = range(2, src)
	var/damagesources = 0
	if(!(locate(/obj/structure/blob) in blobs_in_area))
		damagesources++

	if(!factory)
		damagesources++
	else
		if(locate(/obj/structure/blob/core) in blobs_in_area)
			health += maxHealth*0.07
			update_health_hud()
		if(locate(/obj/structure/blob/node) in blobs_in_area)
			health += maxHealth*0.03
			update_health_hud()

	if(damagesources)
		health -= maxHealth * 0.04 * damagesources //take 2.5% of max health as damage when not near the blob or if the naut has no factory, 5% if both
		update_health_hud()
		var/image/I = new('icons/mob/blob.dmi', src, "nautdamage", MOB_LAYER+0.01)
		I.appearance_flags = RESET_COLOR
		flick_overlay_view(I, src, 8)

		return 1

/mob/living/simple_animal/hostile/blob/blobbernaut/death(gibbed)
	..(gibbed)
	if(factory)
		factory.naut = null //remove this naut from its factory
		factory.max_integrity = initial(max_integrity)
	flick("blobbernaut_death", src)

/mob/living/simple_animal/hostile/blob/blobbernaut/independent
	independent = TRUE
