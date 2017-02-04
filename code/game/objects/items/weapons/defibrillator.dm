//from old nanotrasen
/obj/item/weapon/defibrillator
	name = "defibrillator"
	desc = "Device to treat ventricular fibrillation or pulseless ventricular tachycardia."
	//icon_state = "Defibunit"
	item_state = "defibunit"
	icon_state = "defibunit"
	var/state_on = "defibunit_on"
	action_button_name = "Switch Defibrillator"
	w_class = 3.0
	damtype = "brute"
	force = 4
	var/charged = 0
	var/charges = 8
	origin_tech = "combat=2;biotech=2"

	attack_self(mob/user)
		if(!charged)
			if(charges)
				user.visible_message("[user] charges their [src].", "You charge your [src].</span>", "You hear electrical zap.")
				sleep(30)
				playsound(src, 'sound/items/defib_charge.ogg', 50, 1, 1)
				charged = 1
				spawn(25)
					if(wet)
						var/turf/T = get_turf(src)
						T.visible_message("<span class='wet'>Some wet device has been discharged!</span>")
						var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
						if(W)
							W.electrocute_act(150)
						else if(istype(loc, /mob/living))
							var/mob/living/L = loc
							L.Weaken(6)
							var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
							s.set_up(3, 1, src)
							s.start()
						discharge()
						return
					charged = 2
					//icon_state = "Defibunit_on"
					icon_state = state_on
					damtype = "fire"
					force = 20
			else
				to_chat(user, "Internal battery worn out. Recharge needed.")

	proc/discharge()
		//icon_state = "Defibunit"
		icon_state = initial(icon_state)
		damtype = "brute"
		charged = 0
		force = initial(force)
		charges--

	attack(mob/M, mob/user)
		if(charged == 2 && istype(M,/mob/living/carbon))
			var/mob/living/carbon/C = M
			playsound(src, 'sound/items/defib_zap.ogg', 50, 1, 1)
			user.visible_message("[user] shocks [M] with [src].", "You shock [M] with [src].</span>", "You hear electricity zaps flesh.")
			user.attack_log += "\[[time_stamp()]\]<font color='red'> Shock [M.name] ([M.ckey]) with [src.name]</font>"
			msg_admin_attack("[user.name] ([user.ckey]) shock [M.name] ([M.ckey]) with [src.name] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

			if((world.time - C.timeofdeath) < 3600 || C.stat != DEAD)	//if he is dead no more than 6 minutes
				if(!(NOCLONE in C.mutations))
					if(C.health<=config.health_threshold_crit || prob(10))
						var/suff = min(C.getOxyLoss(), 20)
						C.adjustOxyLoss(-suff)
					else
						C.adjustFireLoss(5)
					C.updatehealth()
					if(C.stat == DEAD && C.health > config.health_threshold_dead)
						C.stat = UNCONSCIOUS
						return_to_body_dialog(C)
						reanimate_body(C)

				if(wet)
					var/turf/T = get_turf(src)
					T.visible_message("<span class='wet'>Some wet device has been discharged!</span>")
					var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
					if(W)
						W.electrocute_act(150)
					else if(istype(loc, /mob/living))
						var/mob/living/L = loc
						L.Weaken(6)
						var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
						s.set_up(3, 1, src)
						s.start()

			discharge()
			C.apply_effect(4, STUN, 0)
			C.apply_effect(4, WEAKEN, 0)
			C.apply_effect(4, STUTTER, 0)
			if(C.jitteriness<=100)
				C.make_jittery(150)
			else
				C.make_jittery(50)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, C)
			s.start()
		else return ..(M,user)

	proc/return_to_body_dialog(mob/living/carbon/returnable)
		if (returnable.key) //in body?
			returnable << 'sound/misc/mario_1up.ogg'
		else if(returnable.mind)
			for(var/mob/dead/observer/ghost in player_list)
				if(ghost.mind == returnable.mind && ghost.can_reenter_corpse)
					ghost << 'sound/misc/mario_1up.ogg'
					var/answer = alert(ghost,"You have been reanimated. Do you want to return to body?","Reanimate","Yes","No")
					if(answer == "Yes")
						ghost.reenter_corpse()
					break

		return

	proc/reanimate_body(mob/living/carbon/returnable)
		returnable.tod = null
		returnable.timeofdeath = 0
		dead_mob_list -= returnable
		returnable.update_health_hud()

		return
