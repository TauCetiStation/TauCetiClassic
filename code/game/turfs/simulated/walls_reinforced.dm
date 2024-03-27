/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "Огромный кусок укрепленного металла для разделения комнат."
	icon = 'icons/turf/walls/has_false_walls/reinforced.dmi'
	opacity = 1
	density = TRUE

	damage_cap = 200
	max_temperature = 20000

	explosive_resistance = 5

	sheet_type = /obj/item/stack/sheet/plasteel

	seconds_to_melt = 60

	var/d_state = INTACT

/turf/simulated/wall/r_wall/yellow
	icon = 'icons/turf/walls/has_false_walls/reinforced_yellow.dmi'

/turf/simulated/wall/r_wall/red
	icon = 'icons/turf/walls/has_false_walls/reinforced_red.dmi'

/turf/simulated/wall/r_wall/purple
	icon = 'icons/turf/walls/has_false_walls/reinforced_purple.dmi'

/turf/simulated/wall/r_wall/green
	icon = 'icons/turf/walls/has_false_walls/reinforced_green.dmi'

/turf/simulated/wall/r_wall/beige
	icon = 'icons/turf/walls/has_false_walls/reinforced_beige.dmi'

/turf/simulated/wall/r_wall/change_color(color)
	var/new_type
	switch(color)
		if("blue")
			new_type = /turf/simulated/wall/r_wall
		if("yellow")
			new_type = /turf/simulated/wall/r_wall/yellow
		if("red")
			new_type = /turf/simulated/wall/r_wall/red
		if("purple")
			new_type = /turf/simulated/wall/r_wall/purple
		if("green")
			new_type = /turf/simulated/wall/r_wall/green
		if("beige")
			new_type = /turf/simulated/wall/r_wall/beige
		else
			stack_trace("Color [color] does not exist")
	if(new_type && new_type != type)
		ChangeTurf(/turf/simulated/wall/r_wall)

/turf/simulated/wall/r_wall/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if(HULK in user.mutations) //#Z2
		if(user.a_intent == INTENT_HARM)
			to_chat(user, text("<span class='notice'>Вы бьете укрепленную стену.</span>"))
			take_damage(rand(5, 25))
			if(prob(25))
				user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			if(prob(5))
				playsound(user, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/BP = H.bodyparts_by_name[user.hand ? BP_L_ARM : BP_R_ARM]
				BP.take_damage(rand(5, 15), used_weapon = "Reinforced wall")
				to_chat(user, text("<span class='warning'>Ауч!!</span>"))
			else
				playsound(user, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
			return //##Z2

	if(rotting)
		to_chat(user, "<span class='notice'>Стена кажется не очень крепкой.</span>")
		return

	/*user << "<span class='notice'>You push the wall but nothing happens!</span>"
	playsound(src, 'sound/weapons/Genhit.ogg', VOL_EFFECTS_MASTER, 25)
	add_fingerprint(user)*/ //this code is in standard wall attack_hand proc
	..()
	return


/turf/simulated/wall/r_wall/attackby(obj/item/W, mob/user)
	//get the user's location
	if(!isturf(user.loc))
		return	//can't do this stuff whilst inside objects and such
	user.SetNextMove(CLICK_CD_MELEE)
	if(user.is_busy()) return

	if(rotting)
		if(iswelding(W))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.use(0,user))
				to_chat(user, "<span class='notice'>Вы сжигаете грибок сваркой.</span>")
				playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER, 10)
				for(var/obj/effect/E in src) if(E.name == "Wallrot")
					qdel(E)
				rotting = 0
				return
		else if(!W.is_sharp() && W.force >= 10 || W.force >= 20)
			to_chat(user, "<span class='notice'>Укрепленная стена рассыпется от удара [W.name].</span>")
			dismantle_wall()
			return

	//THERMITE related stuff. Calls thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite)
		if(iswelding(W))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.use(0,user))
				thermitemelt(user, seconds_to_melt)
				return

		else if(istype(W, /obj/item/weapon/melee/energy/blade))
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			to_chat(user, "<span class='notice'>Вы бьете укрепленную стену энергетическим мечом; термит вспыхивает!</span>")
			playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
			playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)

			thermitemelt(user, seconds_to_melt)
			return

	else if(istype(W, /obj/item/weapon/melee/energy/blade))
		to_chat(user, "<span class='notice'>Эта стена слишком толстая. Лучше найти другой способ.</span>")
		return

	if(damage && iswelding(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.use(0,user))
			to_chat(user, "<span class='notice'>Вы начинаете ремонтировать укрепленную стену.</span>")
			if(W.use_tool(src, user, max(5, damage / 5), volume = 100))
				to_chat(user, "<span class='notice'>Вы закончили ремонтировать укрепленную стену.</span>")
				take_damage(-damage)
			return
		else
			to_chat(user, "<span class='warning'>Нужно больше топлива.</span>")
			return

	if(istype(W, /obj/item/weapon/airlock_painter))
		var/obj/item/weapon/airlock_painter/A = W
		if(!A.can_use(user, 1))
			return
		var/new_color = tgui_input_list(user, "Выберите цвет", "Цвет", WALLS_COLORS)
		if(!new_color)
			return
		if(!A.use_tool(src, user, 10, 1))
			return
		change_color(new_color)
		return

	var/turf/T = user.loc	//get user's location for delay checks
	//DECONSTRUCTION
	switch(d_state)
		if(INTACT)
			if (iscutter(W))
				if(!handle_fumbling(user, src, SKILL_TASK_TOUGH, list(/datum/skill/engineering = SKILL_LEVEL_PRO),"<span class='notice'>You fumble around figuring out how to cut the outer grille.</span>"))
					return
				playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
				d_state = SUPPORT_LINES
				update_icon()
				new /obj/item/stack/rods(src)
				to_chat(user, "<span class='notice'>Вы срезаете внешнюю решетку.</span>")
				return

		if(SUPPORT_LINES)
			if (isscrewing(W))
				to_chat(user, "<span class='notice'>Вы начинаете удалять поддерживающие ряды.</span>")
				playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)

				if(W.use_tool(src, user, SKILL_TASK_AVERAGE, volume = 100, required_skills_override = list(/datum/skill/engineering = SKILL_LEVEL_PRO)))
					if(!istype(src, /turf/simulated/wall/r_wall) || !T)
						return

					if(d_state == SUPPORT_LINES && user.loc == T && user.get_active_hand() == W)
						d_state = COVER
						update_icon()
						to_chat(user, "<span class='notice'>Вы удаляете поддерживающие ряды.</span>")
				return

			//REPAIRING (replacing the outer grille for cosmetic damage)
			else if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/O = W
				if(!O.use(1))
					return
				if(!handle_fumbling(user, src, SKILL_TASK_AVERAGE, list(/datum/skill/engineering = SKILL_LEVEL_PRO),"<span class='notice'>You fumble around figuring out how to replace the outer grille.</span>"))
					return
				d_state = INTACT
				update_icon()
				to_chat(user, "<span class='notice'>Вы заменяете внешнюю решетку.</span>")
				return

		if(COVER)
			if(iswelding(W))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.use(0,user))

					to_chat(user, "<span class='notice'>Вы начинаете разрезать металлическое покрытие.</span>")
					if(WT.use_tool(src, user, SKILL_TASK_TOUGH, volume = 100, required_skills_override = list(/datum/skill/engineering = SKILL_LEVEL_PRO)))
						if(!istype(src, /turf/simulated/wall/r_wall) || !T)
							return

						if(d_state == COVER && user.loc == T && user.get_active_hand() == WT)
							d_state = CUT_COVER
							update_icon()
							to_chat(user, "<span class='notice'>Вы сильно давите на покрытие, смещая его.</span>")
				else
					to_chat(user, "<span class='notice'>Нужно больше топлива.</span>")
				return

			if(istype(W, /obj/item/weapon/gun/energy/laser/cutter))
				to_chat(user, "<span class='notice'>Вы начинаете разрезать металлическое покрытие.</span>")
				if(W.use_tool(src, user, SKILL_TASK_TOUGH, volume = 100, required_skills_override = list(/datum/skill/engineering = SKILL_LEVEL_PRO)))
					if(!istype(src, /turf/simulated/wall/r_wall) || !T)
						return

					if(d_state == COVER && user.loc == T && user.get_active_hand() == W)
						d_state = CUT_COVER
						update_icon()
						to_chat(user, "<span class='notice'>Вы сильно давите на покрытие, смещая его.</span>")
				return

		if(CUT_COVER)
			if (isprying(W))
				to_chat(user, "<span class='notice'>Вы пытаетесь отделить покрытие.</span>")
				if(W.use_tool(src, user, SKILL_TASK_DIFFICULT, volume = 100,  required_skills_override = list(/datum/skill/engineering = SKILL_LEVEL_PRO)))
					if(!istype(src, /turf/simulated/wall/r_wall) || !T)
						return

					if(d_state == CUT_COVER && user.loc == T && user.get_active_hand() == W)
						d_state = ANCHOR_BOLTS
						update_icon()
						to_chat(user, "<span class='notice'>Вы отделили покрытие.</span>")
				return

		if(ANCHOR_BOLTS)
			if (iswrenching(W))

				to_chat(user, "<span class='notice'>Вы ослабляете болты, закрепляющие поддерживающие балки.</span>")
				if(W.use_tool(src, user, SKILL_TASK_AVERAGE, volume = 100, required_skills_override = list(/datum/skill/engineering = SKILL_LEVEL_PRO)))
					if(!istype(src, /turf/simulated/wall/r_wall) || !T)
						return

					if(d_state == ANCHOR_BOLTS && user.loc == T && user.get_active_hand() == W)
						d_state = SUPPORT_RODS
						update_icon()
						to_chat(user, "<span class='notice'>Вы ослабили болты, закрепляющие поддерживающие балки.</span>")
				return

		if(SUPPORT_RODS)
			if(iswelding(W))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.use(0,user))

					to_chat(user, "<span class='notice'>Вы разрезаете поддерживающие балки.</span>")
					if(W.use_tool(src, user, SKILL_TASK_DIFFICULT, volume = 100,  required_skills_override = list(/datum/skill/engineering = SKILL_LEVEL_PRO)))
						if(!istype(src, /turf/simulated/wall/r_wall) || !T)
							return

						if(d_state == SUPPORT_RODS && user.loc == T && user.get_active_hand() == WT)
							d_state = SHEATH
							update_icon()
							new /obj/item/stack/rods(src)
							to_chat(user, "<span class='notice'>Вы убрали поддерживающие балки.</span>")
				else
					to_chat(user, "<span class='notice'>Нужно больше топлива.</span>")
				return

			if(istype(W, /obj/item/weapon/gun/energy/laser/cutter))

				to_chat(user, "<span class='notice'>Вы разрезаете поддерживающие балки.</span>")
				if(W.use_tool(src, user, SKILL_TASK_TOUGH, volume = 100, required_skills_override = list(/datum/skill/engineering = SKILL_LEVEL_PRO)))
					if(!istype(src, /turf/simulated/wall/r_wall) || !T)
						return

					if(d_state == SUPPORT_RODS && user.loc == T && user.get_active_hand() == W)
						d_state = SHEATH
						update_icon()
						new /obj/item/stack/rods(src)
						to_chat(user, "<span class='notice'>Вы убрали поддерживающие балки.</span>")
				return

		if(SHEATH)
			if(isprying(W))

				to_chat(user, "<span class='notice'>Вы отделяете внешнюю обшивку.</span>")
				if(W.use_tool(src, user, SKILL_TASK_DIFFICULT, volume  = 100,  required_skills_override = list(/datum/skill/engineering = SKILL_LEVEL_PRO)))
					if(!istype(src, /turf/simulated/wall/r_wall) || !T)
						return

					if(d_state == SHEATH && user.loc == T && user.get_active_hand() == W)
						to_chat(user, "<span class='notice'>Вы отделили внешнюю обшивку.</span>")
						dismantle_wall()
				return

//vv OK, we weren't performing a valid deconstruction step or igniting thermite,let's check the other possibilities vv

	//DRILLING
	//fulldestruct to walls when
	if(istype(W,/obj/item/weapon/melee/changeling_hammer) && !rotting)
		var/obj/item/weapon/melee/changeling_hammer/hammer = W
		//slowdown, user. No need destruct all walls without debuff
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.shock_stage += 5
		user.do_attack_animation(src)
		user.visible_message("<span class='warning'><B>[user]</B> бьет укрепленную стену!</span>",
						"<span class='warning'>Вы пытаетесь снести укрепленную стену!</span>",
						"<span class='userdanger'>Вы слышите ужасающий грохот!</span>")
		playsound(user, pick(hammer.hitsound), VOL_EFFECTS_MASTER)
		take_damage(hammer.get_object_damage())
		return

	else if (istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))

		to_chat(user, "<span class='notice'>Вы бурите сквозь укрепленную стену.</span>")

		if(W.use_tool(src, user, SKILL_TASK_FORMIDABLE, volume = 50))
			if(!istype(src, /turf/simulated/wall/r_wall) || !T)
				return

			if(user.loc == T && user.get_active_hand() == W)
				to_chat(user, "<span class='notice'>Вы пробурили последнюю укрепленную пластину.</span>")
				dismantle_wall()

	//REPAIRING
	else if(istype(W, /obj/item/stack/sheet/metal) && d_state)
		var/obj/item/stack/sheet/metal/MS = W

		to_chat(user, "<span class='notice'>Вы ремонтируете укрепленную стену металлом.</span>")

		if(W.use_tool(src, user, (max(20*d_state,100)), volume = 100))	//time taken to repair is proportional to the damage! (max 10 seconds)
			if(!istype(src, /turf/simulated/wall/r_wall) || !T)
				return

			if(user.loc == T && user.get_active_hand() == MS && d_state)
				if(!MS.use(1))
					return
				d_state = INTACT
				update_icon()
				queue_smooth(src)	//call smoothwall stuff
				to_chat(user, "<span class='notice'>Вы отремонтировали укрепленную стену.</span>")

	//APC
	else if(istype(W,/obj/item/apc_frame))
		var/obj/item/apc_frame/AH = W
		AH.try_build(src)

	else if(istype(W,/obj/item/newscaster_frame))     //Be damned the man who thought only mobs need attack() and walls dont need inheritance, hitler incarnate
		var/obj/item/newscaster_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/alarm_frame))
		var/obj/item/alarm_frame/AH = W
		AH.try_build(src)

	else if(istype(W,/obj/item/firealarm_frame))
		var/obj/item/firealarm_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/light_fixture_frame))
		var/obj/item/light_fixture_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/light_fixture_frame/small))
		var/obj/item/light_fixture_frame/small/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/door_control_frame))
		var/obj/item/door_control_frame/AH = W
		AH.try_build(src)
		return

	// why is all of this here help me
	else if(istype(W, /obj/item/noticeboard_frame))
		var/obj/item/noticeboard_frame/NF = W
		NF.try_build(user, src)

	else if(istype(W,/obj/item/painting_frame))
		var/obj/item/painting_frame/AH = W
		AH.try_build(src)
		return

	//Poster stuff
	else if(istype(W,/obj/item/weapon/poster))
		place_poster(W,user)
		return
	else if((istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/weapon/paper_bundle) || istype(W, /obj/item/weapon/photo)) && (get_dir(user,src) in global.cardinal))
		user.drop_from_inventory(W)
		W.pixel_x = X_OFFSET(24, get_dir(user, src))
		W.pixel_y = Y_OFFSET(24, get_dir(user, src))
		RegisterSignal(W, COMSIG_MOVABLE_MOVED, CALLBACK(src, PROC_REF(tied_object_reset_pixel_offset), W))
		RegisterSignal(W, COMSIG_PARENT_QDELETING, CALLBACK(src, PROC_REF(tied_object_reset_pixel_offset), W))
		return
	else if((istype(W, /obj/item/wallclock) || istype(W, /obj/item/portrait)) && (get_dir(user,src) in global.cardinal))
		user.drop_from_inventory(W)
		W.pixel_x = X_OFFSET(32, get_dir(user, src))
		W.pixel_y = Y_OFFSET(32, get_dir(user, src))
		W.anchored = TRUE
		RegisterSignal(W, COMSIG_MOVABLE_MOVED, CALLBACK(src, PROC_REF(tied_object_reset_pixel_offset), W, TRUE))
		RegisterSignal(W, COMSIG_PARENT_QDELETING, CALLBACK(src, PROC_REF(tied_object_reset_pixel_offset), W, TRUE))

	//Finally, CHECKING FOR FALSE WALLS if it isn't damaged
	else if(!d_state)
		return attack_hand(user)
	return

/turf/simulated/wall/r_wall/update_icon()
	if(d_state != INTACT)
		smooth = SMOOTH_FALSE
		icon_state = "r_wall-[d_state]"
	else
		smooth = SMOOTH_TRUE
		queue_smooth_neighbors(src)
		queue_smooth(src)

/turf/simulated/wall/r_wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()
