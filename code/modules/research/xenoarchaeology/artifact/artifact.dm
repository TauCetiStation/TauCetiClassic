
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Large finds - (Potentially) active alien machinery from the dawn of time
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TO DO LIST:
// * Consider about adding constructshell back
// * Do something about hoverpod, its quite useless now. Maybe get a chance to find a space pod
// * Consider adding more big artifacts
// * Add more effects from /vg/
//

/datum/artifact_find
	var/artifact_id
	var/artifact_find_type
	var/artifact_detect_range

/datum/artifact_find/New()
	artifact_detect_range = rand(5,300)

	artifact_id = "[pick("kappa","sigma","antaeres","beta","omicron","iota","epsilon","omega","gamma","delta","tau","alpha")]-[rand(100,999)]"

	artifact_find_type = pick(\
	5;/obj/machinery/power/supermatter,\
//	5;/obj/structure/constructshell,\  //
	5;/obj/machinery/syndicate_beacon,\
	25;/obj/machinery/power/supermatter/shard,\
	50;/obj/random/mecha/wreckage,\
	100;/obj/machinery/auto_cloner,\
	100;/obj/machinery/giga_drill,\
	100;/obj/mecha/working/hoverpod,\
	100;/obj/machinery/replicator,\
	150;/obj/machinery/power/crystal,\
	1000;/obj/machinery/artifact)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Boulders - sometimes turn up after excavating turf - excavate further to try and find large xenoarch finds

/obj/structure/boulder
	name = "rocky debris"
	desc = "Leftover rock from an excavation, it's been partially dug out already but there's still a lot to go."
	icon = 'icons/obj/mining.dmi'
	icon_state = "boulder1"
	density = TRUE
	opacity = 1
	anchored = TRUE
	var/excavation_level = 0
	var/datum/geosample/geological_data
	var/datum/artifact_find/artifact_find
	var/datum/minigame/excavation/Game

/obj/structure/boulder/atom_init()
	. = ..()
	icon_state = "boulder[rand(1, 4)]"

/obj/structure/boulder/proc/setup_artifact()
	if(!artifact_find)
		return
	Game = new()
	Game.setup_game()

/obj/structure/boulder/attackby(obj/item/weapon/W, mob/user)
	user.SetNextMove(CLICK_CD_RAPID)

	if (user.is_busy(src))
		return

	if (istype(W, /obj/item/device/depth_scanner))
		var/obj/item/device/depth_scanner/C = W
		C.scan_atom(user, src)
		return

	if (istype(W, /obj/item/weapon/sledgehammer))
		var/obj/item/weapon/sledgehammer/S = W
		if(HAS_TRAIT(S, TRAIT_DOUBLE_WIELDED))
			user.do_attack_animation(src)
			shake_camera(user, 1, 0.37)
			playsound(src, 'sound/misc/sledgehammer_hit_rock.ogg', VOL_EFFECTS_MASTER)
			crumble_away(FALSE)
		else
			to_chat(user, "<span class='warning'>You need to take it with both hands to break it!</span>")

	if (istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/P = W

		to_chat(user, "<span class='warning'>You start [P.drill_verb] [src].</span>")

		if(!W.use_tool(src, user, 2 SECONDS, volume = 100))
			return

		if(artifact_find)
			to_chat(user, "<span class='notice'>Seems like there is something inside!</span>")
			tgui_interact(user)
		else
			to_chat(user, "<span class='notice'>You finish [P.drill_verb] [src].</span>")
			excavation_level += P.excavation_amount
			if(excavation_level > 100)
				crumble_away(FALSE)

/obj/structure/boulder/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Excavation")
		ui.open()

/obj/structure/boulder/tgui_data(mob/user)
	var/list/data = list()

	data["grid"] = Game.grid
	data["width"] = Game.grid_x*30
	data["height"] = Game.grid_y*30
	data["n_title"] = "Раскопка артефакта"

	return data

/obj/structure/boulder/tgui_act(action, params)
	. = ..()
	if(.)
		return
	if(action == "button_press")
		if(Game.button_press(text2num(params["choice_y"]), text2num(params["choice_x"])))
			playsound(src, 'sound/items/pickaxe.ogg', VOL_EFFECTS_MASTER, 80, TRUE)
		else
			crumble_away(FALSE)
			SStgui.close_uis(src)
			return TRUE

	if(Game.check_complete())
		crumble_away(TRUE)
		SStgui.close_uis(src)
	return TRUE

/obj/structure/boulder/proc/crumble_away(successfull = FALSE)
	if(artifact_find)
		if(successfull)
			var/spawn_type = artifact_find.artifact_find_type
			var/obj/O = new spawn_type(get_turf(src))
			if(istype(O,/obj/machinery/artifact))
				var/obj/machinery/artifact/A = O
				if(A.first_effect)
					A.first_effect.artifact_id = artifact_find.artifact_id
			visible_message("<span class='notice'>[src] suddenly crumbles away, revealing [O.name].</span>")
		else
			visible_message("<span class='danger'>[src] suddenly crumbles away.</span>",\
			"<span class='danger'>[src] has disintegrated under your onslaught, any secrets it was holding are long gone.</span>")
	else
		visible_message("<span class='warning'>[src] crumbles away.</span>")
	qdel(src)

/obj/structure/boulder/Bumped(AM)
	. = ..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(istype(H.l_hand, /obj/item/weapon/pickaxe))
			attackby(H.l_hand, H)
		else if(istype(H.r_hand, /obj/item/weapon/pickaxe))
			attackby(H.r_hand, H)

	else if(isrobot(AM))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active, /obj/item/weapon/pickaxe))
			attackby(R.module_active, R)

	else if(istype(AM, /obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected, /obj/item/mecha_parts/mecha_equipment/drill))
			M.selected.action(src)
