#define POSE_NORM 1
#define POSE_SIT  2
#define POSE_REST 4
#define POSE_STAT 8

/mob/living/carbon/ian
	name = "Ian"
	real_name = "Ian"
	icon = 'icons/mob/corgi.dmi'
	icon_state = "corgi"
	gender = MALE
	desc = "It's a corgi."

	var/response_help  = "pets"
	var/response_disarm = "bops"
	var/response_harm   = "kicks"

	var/list/speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	var/list/emote_hear = list("barks", "woofs", "yaps","pants")
	var/list/emote_see = list("shakes its head", "shivers")
	var/speak_chance = 1

	var/turns_per_move = 10
	var/turns_since_move = 0
	var/stop_automated_movement = FALSE
	var/stop_automated_movement_when_pulled = TRUE
	var/turns_since_scan = 0
	var/wander = TRUE
	var/obj/movement_target

	universal_speak = FALSE
	universal_understand = FALSE
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/corgi = 5)

	var/obj/item/weapon/card/id/wear_id = null

	var/dodged = FALSE
	var/unlock_mouth = FALSE        // Whitelist related, blocks attack_paw() usage.
	var/ian_action = IAN_STANDARD   // Overrides click logic, holds special abilities.
	var/soap_eaten = 0              // It looks like bool, but its not (i have no idea how to name it properly). Actually it contains number of ticks.
	var/nose_last_sniff = 0         // Used as cooldown, holds "last use" time.
	var/nose_memory = null          // Holds single smell, which we are looking for.
	var/list/nose_database = list() // Holds all smells which we know.

	var/facehugger = FALSE
	var/pose_prev = 0
	var/pose_last = 0

/mob/living/carbon/ian/atom_init()
	reagents = new(1000)
	reagents.my_atom = src

	dna = new
	dna.real_name = real_name
	dna.ResetSE()
	dna.ResetUI()
	dna.unique_enzymes = md5(name)
	dna.SetUIState(DNA_UI_GENDER)

	. = ..()

	verbs += /mob/living/carbon/proc/crawl

/mob/living/carbon/ian/UnarmedAttack(atom/A)
	..()
	if(ian_action)
		if(isHandsBusy)
			return
		isHandsBusy = TRUE

		face_atom(A)
/*
	TONGUE <-
	NOSE
	NORMAL ATTACK
*/
		switch(ian_action)
			if(IAN_LICK)
				if(!do_after(src, 15, target = A))
					isHandsBusy = FALSE
					return

				var/message = "<span class='notice'>[src] licks [A].</span>"
				if(istype(A, /turf/simulated/floor))
					var/turf/simulated/S = A
					S.make_wet_floor(soap_eaten ? LUBE_FLOOR : WATER_FLOOR)
				else if(isliving(A))
					var/expression = pick("amused","annoyed","confused","resentful","happy","excited")
					message = "<span class='notice'>[src] licks [A], \he looks [expression]!</span>"
					if(iscarbon(A))
						var/mob/living/carbon/C = A
						var/list/items = C.get_equipped_items()
						if(items.len)
							var/obj/item/I = pick(items)
							if(I)
								I.make_wet()
					else if(ismouse(A))
						var/mob/living/simple_animal/mouse/M = A
						if(M.stat == DEAD)
							message = "<span class='notice'>[src] looks [expression] while eating [A].</span>"
							M.gib()
						else
							message = "<span class='notice'>[src] licks [A], then ate \him. In last moments of life, [A] was [expression]!</span>"
							M.health = 0
							M.loc = src
							addtimer(CALLBACK(src, .proc/ate_mouse), rand(250, 1200))
					else if(iscorgi(A))
						adjustBruteLoss(-1)
						adjustFireLoss(-1)
				else if(istype(A, /obj/item/weapon/soap))
					var/expression = pick("amused","annoyed","confused")
					message = "<span class='notice'>[src] ate [A] and looks [expression]!</span>"
					qdel(A)
					soap_eaten += 200
				else if(istype(A, /obj/item))
					var/obj/item/I = A
					I.make_wet()
				visible_message(message)
/*
	TONGUE
	NOSE <-
	NORMAL ATTACK
*/
			if(IAN_SNIFF)
				if(A == src) //Resets current smell in memory.
					nose_memory = null
					to_chat(src, "<span class='notice'>Dropped current smell.</span>")
					isHandsBusy = FALSE
					return

				if(isturf(A)) //Visualize smells in X range around us.
					if(nose_last_sniff > world.time)
						to_chat(src, "<span class='warning'>Nose is on cooldown.</span>")
					else
						visible_message("<span class='notice'>[src] sniffs around.</span>")
						sniff_around()
					isHandsBusy = FALSE
					return

				if(!do_after(src, 10, target = A))
					isHandsBusy = FALSE
					return

				var/smell
				if(ishuman(A)) //If human - just add his smell to database as known or compare it with nose_smell.
					var/mob/living/carbon/human/H = A
					if(!istype(H.dna, /datum/dna))
						to_chat(src, "<span class='warning'>This humanoid has no smell at all!</span>")
					else
						smell = md5(H.dna.uni_identity)
						nose_database[smell] = H.real_name
						if(nose_memory == smell)
							to_chat(src, "<span class='warning'>Memorized smell matches this humanoid!</span>")
				else
					var/found_match = FALSE

					if(A.blood_DNA && islist(A.blood_DNA) && A.blood_DNA.len)
						if(nose_memory)
							if(nose_memory in A.blood_DNA)
								if(A.blood_DNA.len > 1)
									to_chat(src, "<span class='warning'>I found memorized smell among others here!</span>")
								else
									to_chat(src, "<span class='warning'>I found memorized smell here!</span>")
								found_match = TRUE
						else
							if(A.blood_DNA.len > 1)
								to_chat(src, "<span class='warning'>There is more than one smell, nose picked up one randomly.</span>")
							smell = pick(A.blood_DNA)

					if(A.fingerprints && A.fingerprints.len)
						if(nose_memory)
							if(!found_match && (nose_memory in A.fingerprints))
								if(A.fingerprints.len > 1)
									to_chat(src, "<span class='warning'>I found memorized smell among others here!</span>")
								else
									to_chat(src, "<span class='warning'>I found memorized smell here!</span>")
						else if(!smell)
							if(A.fingerprints.len > 1)
								to_chat(src, "<span class='warning'>There is more than one smell, nose picked up one randomly.</span>")
							smell = pick(A.fingerprints)

				if(smell && !nose_memory)
					nose_memory = smell
					if(!(smell in nose_database))
						nose_database[smell] = "Unknown"
						to_chat(src, "<span class='warning'>My nose picked up an unknown smell.</span>")
					else if(nose_database[smell] == "Unknown")
						to_chat(src, "<span class='warning'>I don't know this smell yet, but smells familiar.</span>")
					else
						to_chat(src, "<span class='warning'>This smell belongs to [nose_database[smell]].</span>")

				visible_message("<span class='notice'>[src] sniffs [A].</span>")

		isHandsBusy = FALSE
/*
	TONGUE
	NOSE
	NORMAL ATTACK <-
*/
	else if(unlock_mouth)
		A.attack_paw(src)

/mob/living/carbon/ian/proc/ate_mouse()
	var/mob/living/simple_animal/mouse/M = locate() in src
	if(!M)
		return

	visible_message("<span class='warning'>[src] throws up [M].</span>")
	M.loc = loc
	M.gib()

/mob/living/carbon/ian/proc/hiccup()
	soap_eaten = max(0, soap_eaten - 1)
	if(prob(33))
		new /obj/effect/bubble_ian(loc, src)

/obj/effect/bubble_ian
	name = "Bubble"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bubble"
	anchored = TRUE

/obj/effect/bubble_ian/atom_init(loc, mob/M)
	. = ..()
	playsound(src, 'sound/effects/bubble_spawn.ogg', 50, 1)
	switch(M.dir)
		if(WEST)
			pixel_x = -20
		if(EAST)
			pixel_x = 20

	var/atom/movable/AM = pick(subtypesof(/obj/item))
	var/image/I = image("icon" = initial(AM.icon), "icon_state" = initial(AM.icon_state))
	I.alpha = 180
	underlays.Add(I)

	var/matrix/Mx = matrix()
	Mx.Scale(rand(60,80) / 100)
	transform = Mx

	var/end_in = rand(26,43)
	animate(src, pixel_y = rand(28,66) , time = end_in, easing = SINE_EASING)
	addtimer(CALLBACK(src, .proc/pop), end_in + 3)

/obj/effect/bubble_ian/proc/pop()
	if(prob(3)) // There is too many of them!
		for(var/mob/living/carbon/C in view(1,src))
			C.Stun(1)
			C.Weaken(1)
	playsound(src, 'sound/effects/bubble_pop.ogg', 50, 1)
	underlays.Cut()
	qdel(src)

/mob/living/carbon/ian/proc/sniff_around()
	if(!client)
		return

	if(nose_memory)
		nose_last_sniff = world.time + 65

		for(var/atom/A in oview(4, src))
			var/image/I
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(istype(H.dna, /datum/dna))
					var/their_smell = md5(H.dna.uni_identity)
					if(nose_memory == their_smell)
						I = image('icons/mob/screen_corgi.dmi', A, "smell")
			else
				if(A.fingerprints && (nose_memory in A.fingerprints))
					I = image('icons/mob/screen_corgi.dmi', A, "smell")
				else if(A.blood_DNA && islist(A.blood_DNA) && (nose_memory in A.blood_DNA))
					I = image('icons/mob/screen_corgi.dmi', A, "smell")

			if(I)
				if((nose_memory in nose_database) && nose_database[nose_memory] == "Unknown")
					I.color = list(1.438,-0.062,-0.062,0.122,1.378,-0.122,0.016,-0.016,1.483,-0.03,0.05,-0.02)
				client.images += I
				addtimer(CALLBACK(src, .proc/unvisualize_smell, I), rand(30, 60))

/mob/living/carbon/ian/proc/unvisualize_smell(image/I)
	if(!client)
		return

	client.images -= I

//Standard procs, etc.
/mob/living/carbon/ian/IsAdvancedToolUser()
	return FALSE

/mob/living/carbon/ian/movement_delay(tally = 0)
	if(crawling)
		tally += 5
	else if(reagents && reagents.has_reagent("hyperzine") || reagents.has_reagent("nuka_cola"))
		return -1
	else if(m_intent == "run" && a_intent == "hurt" && stamina >= 10)
		stamina = max(0, stamina - 10)
		tally -= 1

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45)
		tally += (health_deficiency / 25)

	if(pull_debuff)
		tally += pull_debuff

	if (bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75
	return tally

/mob/living/carbon/ian/SelfMove(turf/n, direct)
	if(restrained())
		to_chat(src, "<span class='red'>I feel something on my neck and cannot move!</span>")
		return FALSE

	return ..()

/mob/living/carbon/ian/attackby(obj/item/O, mob/user)
	var/chance = 0
	if(head && istype(head,/obj/item/clothing/head/helmet))
		chance += 50
	if(back && istype(back,/obj/item/clothing/suit/armor))
		chance += 50

	if(chance && prob(chance))
		user.SetNextMove(CLICK_CD_MELEE * 2) // DISMORALING HIM
		if(O.force)
			user.visible_message("<span class='warning'>[user] hits [src] with the [O], however [src] is too armored.</span>",
			                     "<span class='warning'>You can't cause [src] any damage.</span>")
		else
			user.visible_message("<span class='notice'>[user] gently taps [src] with the [O].</span>",
			                     "<span class='notice'>You can't reach its skin.</span>")
		if(prob(15) && stat == CONSCIOUS)
			var/expression = pick("an amused","an annoyed","a confused","a resentful","a happy","an excited")
			emote("me",1,"looks at [user] with [expression] expression on his face")
		return
	..()

/mob/living/carbon/ian/attack_hand(mob/living/carbon/human/M)
	if (!ticker.mode)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	if (M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == "hurt")//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.use(2500)
					if(is_armored(M, 40))
						//do nothing
					else
						apply_effects(0,0,0,0,5,0,0,150)
						M.visible_message("<span class='danger'>[src] has been touched with the stun gloves by [M]!</span>", , "<span class='red'>You hear someone fall</span>")
					var/datum/effect/effect/system/spark_spread/s = new
					s.set_up(3, 1, src)
					s.start()
					M.do_attack_animation(src)
					return
				else
					to_chat(M, "<span class='red'>Not enough charge!</span>")
					return

	switch(M.a_intent)
		if("help")
			if(health >= config.health_threshold_crit)
				help_shake_act(M)
				return
			INVOKE_ASYNC(src, .proc/perform_cpr, M)
		if ("hurt")
			M.do_attack_animation(src)
			if(is_armored(M, 35))
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				return

			var/datum/unarmed_attack/attack = M.species.unarmed
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>[response_harm] [src.name] ([src.ckey])</font>")
			attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [pick(attack.attack_verb)]ed by [M.name] ([M.ckey])</font>")
			msg_admin_attack("[key_name(M)] [response_harm] [key_name(src)]")

			var/damage = rand(0, 5)
			if(!damage)
				playsound(loc, attack.miss_sound, 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to [response_harm] [src]!</span>")
				return

			if(HULK in M.mutations)
				damage += 5

			playsound(loc, attack.attack_sound, 25, 1, -1)

			if(damage >= 5 && prob(15))
				visible_message("<span class='danger'>[M] has weakened [src]!</span>")
				Paralyse(3)

			visible_message("<span class='danger'>[M] [response_harm] [src]!</span>")
			adjustBruteLoss(damage)
			updatehealth()

		if("grab")
			if(M == src || anchored || M.lying)
				return

			for(var/obj/item/weapon/grab/G in grabbed_by)
				if(G.assailant == M)
					to_chat(M, "<span class='notice'>You already grabbed [src].</span>")
					return

			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src)
			if(buckled)
				to_chat(M, "<span class='notice'>You cannot grab [src], \he is buckled in!</span>")
			if(!G)
				return
			M.put_in_active_hand(G)
			grabbed_by += G
			G.synch()
			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='warning'>[M] has grabbed [src] passively!</span>")
		if("disarm")
			M.do_attack_animation(src)
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>Disarmed [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [M.name] ([M.ckey])</font>")
			msg_admin_attack("[key_name(M)] disarmed [src.name] ([src.ckey])")

			if(is_armored(M, 25))
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				return

			var/randn = rand(1, 100)
			switch(randn)
				if(0 to 25)
					Paralyse(2)
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] [response_disarm] [src]!</span>")
				if(26 to 60)
					var/talked = 0
					if(pulling)
						visible_message("<span class='danger'>[M] has broken [src]'s grip on [pulling]!</span>")
						talked = 1
						stop_pulling()
					if(istype(mouth, /obj/item/weapon/grab))
						var/obj/item/weapon/grab/grab = l_hand
						if(grab.affecting)
							visible_message("<span class='danger'>[M] has broken [src]'s grip on [grab.affecting]!</span>")
							talked = 1
							qdel(grab)
					if(!talked)
						drop_item()
						visible_message("<span class='danger'>[M] has disarmed [src]!</span>")
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
					visible_message("<span class='danger'>[M] attempted to disarm [src]!</span>")

/mob/living/carbon/ian/attack_facehugger(mob/living/carbon/alien/facehugger/FH)
	switch(FH.a_intent)
		if("grab")
			if(stat != DEAD)
				if(FH == src)
					return
				var/obj/item/weapon/fh_grab/G = new /obj/item/weapon/fh_grab(FH, src)
				FH.put_in_active_hand(G)
				grabbed_by += G
				G.last_upgrade = world.time - 20
				G.synch()
				LAssailant = FH
				visible_message("<span class='red'>[FH] atempts to leap at [src] face!</span>")
			else
				to_chat(FH, "<span class='red'>looks dead.</span>")

/mob/living/carbon/ian/attack_slime(mob/living/carbon/slime/M)
	if (!ticker.mode)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.Victim)
		return // can't attack while eating!

	if (stat != DEAD)
		if(is_armored(M, 35))
			return

		visible_message("<span class='danger'>The [M.name] glomps [src]!</span>")

		var/damage = rand(1, 3)

		if(istype(src, /mob/living/carbon/slime/adult))
			damage = rand(20, 40)
		else
			damage = rand(5, 35)

		adjustBruteLoss(damage)

		if(M.powerlevel > 0)
			var/stunprob = 10
			var/power = M.powerlevel + rand(0,3)

			switch(M.powerlevel)
				if(1 to 2) stunprob = 20
				if(3 to 4) stunprob = 30
				if(5 to 6) stunprob = 40
				if(7 to 8) stunprob = 60
				if(9)      stunprob = 70
				if(10)     stunprob = 95

			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				visible_message("<span class='danger'>The [M.name] has shocked [src]!</span>")

				Weaken(power)
				if (stuttering < power)
					stuttering = power
				Stun(power)

				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

				if (prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))

		updatehealth()

/mob/living/carbon/ian/meteorhit(obj/O)
	visible_message("<span class='red'>[src] has been hit by [O].</span>")
	adjustBruteLoss(30)
	updatehealth()

/mob/living/carbon/ian/emp_act(severity)
	if(neck)
		neck.emp_act(severity)
	..()

/mob/living/carbon/ian/ex_act(severity)
	if(!blinded)
		flash_eyes()

	switch(severity)
		if(1)
			gib()
		if(2)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
				updatehealth()
		if(3)
			if (stat != DEAD)
				adjustBruteLoss(30)
				updatehealth()
			if (prob(50))
				Paralyse(10)

/mob/living/carbon/ian/blob_act()
	if (stat != DEAD)
		adjustFireLoss(60)
		updatehealth()
		if (prob(50))
			Paralyse(10)
	else
		gib()

/mob/living/carbon/ian/attack_paw(mob/M)
	..()
	if (M.a_intent == "help")
		help_shake_act(M)
	else
		if (M.a_intent == "hurt" && !istype(M.wear_mask, /obj/item/clothing/mask/muzzle))
			M.do_attack_animation(src)

			if(is_armored(M, 35))
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				return

			if(prob(75))
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M.name] has bit [name]!</span>")
				var/damage = rand(1, 5)
				adjustBruteLoss(damage)
				updatehealth()
				for(var/datum/disease/D in M.viruses)
					if(istype(D, /datum/disease/jungle_fever))
						contract_disease(D,1,0)
			else
				visible_message("<span class='danger'>[M.name] has attempted to bite [name]!</span>")

/mob/living/carbon/ian/attack_alien(mob/living/carbon/alien/humanoid/M)
	if (!ticker.mode)
		to_chat(M, "<span class='warning'>You cannot attack people before the game has started.</span>")
		return

	switch(M.a_intent)
		if ("help")
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")
		if ("hurt")
			if(prob(95))
				if(is_armored(M, 25))
					playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
					return
				playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
				var/damage = rand(15, 30)
				if (damage >= 25)
					damage = rand(20, 40)
					if (paralysis < 15)
						Paralyse(rand(10, 15))
					visible_message("<span class='danger'>has wounded [name]!</span>")
				else
					visible_message("<span class='danger'>has slashed [name]!</span>")
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>has attempted to lunge at [name]!</span>")
		if ("grab")
			if (M == src || anchored || M.lying)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src)
			M.put_in_active_hand(G)
			grabbed_by += G
			G.synch()
			LAssailant = M
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='red'>has grabbed [name] passively!</span>")
		if ("disarm")
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			if(is_armored(M, 35))
				return
			var/damage = 5
			if(prob(95))
				Weaken(8)
				visible_message("<span class='danger'>[M] has tackled down [name]!</span>")
			else
				drop_item()
				visible_message("<span class='danger'>[M] has disarmed [name]!</span>")
			adjustBruteLoss(damage)
			updatehealth()

/mob/living/carbon/ian/attack_animal(mob/living/simple_animal/M)
	M.do_attack_animation(src)
	if(!M.melee_damage_upper)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		if(is_armored(M, 35))
			return
		visible_message("<span class='red'><B>[M]</B> [M.attacktext] [src]!</span>")
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/carbon/ian/bullet_act(obj/item/projectile/Proj)
	if(!Proj)
		return

	var/chance = 0
	if(head && istype(head,/obj/item/clothing/head/helmet))
		chance += 50
	if(back && istype(back,/obj/item/clothing/suit/armor))
		chance += 50

	if(chance && prob(chance) && dodged < world.time)
		dodged = world.time + 50
		if(Proj.flag == "bullet")
			visible_message("<span class='notice'>[src] catches [Proj] with his jaws.</span>")
		else
			visible_message("<span class='notice'>[src] dodges [Proj].</span>")
		if(prob(15))
			var/expression = pick("a resentful","a happy","an excited")
			emote("me",1,"looks with [expression] expression on his face and wants to play more!")
		return
	..()

/mob/living/carbon/ian/hitby(atom/movable/AM)
	if(is_armored(AM, msg = "armored"))
		return
	..()

/mob/living/carbon/ian/proc/is_armored(atom/movable/AM, luck = 50, msg = "dodges")
	var/chance = 0
	if(head && istype(head,/obj/item/clothing/head/helmet))
		chance += luck
	if(back && istype(back,/obj/item/clothing/suit/armor))
		chance += luck

	if(chance && prob(chance) && !stat)
		switch(msg)
			if("dodges")
				msg = "<span class='notice'>[src] dodges [AM]'s attack!</span>"
			if("armored")
				msg = "<span class='notice'>[src] has been hit by [AM], however [src] is too armored.</span>"
		visible_message(msg)
		if(prob(15))
			var/expression = pick("an amused","an annoyed","a confused","a resentful","a happy","an excited")
			emote("me",1,"looks at [AM] with [expression] expression on his face")
		return TRUE
	return FALSE

/mob/living/carbon/ian/toggle_throw_mode()
	return // nope.avi

/mob/living/carbon/ian/throw_mode_on()
	return

/mob/living/carbon/ian/throw_mode_off()
	return

/mob/living/carbon/ian/say(message)
	if(stat)
		return

	message = sanitize(message)

	if(copytext(message,1,2) == "*")
		return emote(copytext(message,2))

	var/verb = "says"

	if(speak_emote.len)
		verb = pick(speak_emote)

	message = capitalize(trim_left(message))

	..(message, null, verb, sanitize = 0)
