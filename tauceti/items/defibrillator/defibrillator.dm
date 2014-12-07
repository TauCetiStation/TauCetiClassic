//from old nanotrasen
/obj/item/weapon/defibrillator
	name = "defibrillator"
	desc = "Device to treat ventricular fibrillation or pulseless ventricular tachycardia."
	icon = 'tauceti/items/defibrillator/defibrillator.dmi'
	var/item_icon = 'tauceti/items/defibrillator/defibrillator.dmi'
	//icon_state = "Defibunit"
	item_state = "defibunit"
	icon_state = "defibunit"
	var/state_on = "defibunit_on"
	flags = FPRINT | TABLEPASS
	w_class = 1.0
	damtype = "brute"
	force = 4
	var/charged = 0
	var/charges = 8
	origin_tech = "combat=2;biotech=2"
	m_amt = 2000
	g_amt = 50

	attack_self(mob/user as mob)
		if(!charged)
			if(charges)
				user.visible_message("[user] charges their [src].", "You charge your [src].</span>", "You hear electrical zap.")
				charged = 1
				spawn(25)
					charged = 2
					//icon_state = "Defibunit_on"
					icon_state = state_on
					damtype = "fire"
					force = 20
			else
				user<<"Internal battery worn out. Recharge needed."

	proc/discharge()
		//icon_state = "Defibunit"
		icon_state = initial(icon_state)
		damtype = "brute"
		charged = 0
		force = initial(force)
		charges--

	attack(mob/M as mob, mob/user as mob)
		if(charged == 2 && istype(M,/mob/living/carbon))
			var/mob/living/carbon/C = M
			user.visible_message("[user] shocks [M] with [src].", "You shock [M] with [src].</span>", "You hear electricity zaps flesh.")

			if((world.time - C.timeofdeath) < 3600 || C.stat != DEAD)	//if he is dead no more than 6 minutes
				if(!(NOCLONE in C.mutations))
					if(C.health<=config.health_threshold_crit || prob(10))
						var/suff = min(C.getOxyLoss(), 20)
						C.adjustOxyLoss(-suff)
						C.updatehealth()
						if(C.stat == DEAD && C.health>config.health_threshold_dead)
							C.stat = UNCONSCIOUS
					else
						C.adjustFireLoss(5)
						if(C.stat == DEAD && C.health>config.health_threshold_dead)
							C.stat = CONSCIOUS

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

datum/design/defibrillators
	name = "Defibrillators"
	desc = "Defibrillators to revive people."
	id = "defibrillators"
	req_tech = list("combat" = 2,"biotech" = 2)
	build_type = 2 //PROTOLATHE
	materials = list("$metal" = 2000, "$glass" = 50)
	build_path = "/obj/item/weapon/defibrillator"
