///Process_Grab()
///Called by client/Move()
///Checks to see if you are grabbing anything and if moving will affect your grab.
/client/proc/Process_Grab()
	for(var/obj/item/weapon/grab/G in mob.GetGrabs())
		if(G.state == GRAB_KILL) //no wandering across the station/asteroid while choking someone
			mob.visible_message("<span class='warning'>[mob] lost \his tight grip on [G.affecting]'s neck!</span>")
			G.set_state(GRAB_NECK)

/obj/item/weapon/grab
	name = "grab"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "reinforce"
	flags = DROPDEL
	var/obj/screen/grab/hud = null
	var/mob/living/affecting = null
	var/mob/living/carbon/human/assailant = null
	var/state = GRAB_NONE

	var/allow_upgrade = 1
	var/last_hit_zone = 0
	var/force_down //determines if the affecting mob will be pinned to the ground
	var/dancing //determines if assailant and affecting keep looking at each other. Basically a wrestling position

	layer = 21
	abstract = 1
	item_state = "nothing"
	w_class = 5.0

/mob/proc/Grab(atom/movable/target, force_state, show_warnings = TRUE)
	if(QDELETED(src) || QDELETED(target))
		return
	if(lying || target == src || target.anchored)
		return
	if(!isturf(target.loc) || restrained())
		return
	for(var/obj/item/weapon/grab/G in GetGrabs())
		if(G.affecting == target)
			if(show_warnings)
				to_chat(src, "<span class='warning'>You already grabbed [target]</span>")
			return
	if(!target.Adjacent(src))
		return
	if(get_active_hand() && get_inactive_hand())
		if(show_warnings)
			to_chat(src, "<span class='warning'>You are holding too many stuff already.</span>")
		return
	if(ismob(target))
		var/mob/M = target
		if(!(M.status_flags & CANPUSH))
			return
		if(M.buckled)
			if(show_warnings)
				to_chat(src, "<span class='notice'>You cannot grab [M], \he is buckled in!</span>")
			return
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.w_uniform)
				H.w_uniform.add_fingerprint(src)
			if(H.pull_damage())
				if(show_warnings)
					to_chat(src, "<span class='danger'>Grabbing \the [H] in their current condition would probably be a bad idea.</span>")
		M.inertia_dir = 0

	new /obj/item/weapon/grab(src, target, force_state)

/obj/item/weapon/grab/atom_init(mapload, mob/victim, initial_state = GRAB_PASSIVE)
	. = ..()
	assailant = loc
	affecting = victim

	if(affecting.anchored)
		return INITIALIZE_HINT_QDEL

	hud = new /obj/screen/grab(src)
	hud.master = src

	victim.grabbed_by += src
	victim.LAssailant = assailant

	set_state(initial_state)
	assailant.put_in_hands(src)

	//check if assailant is grabbed by victim as well
	if(assailant.grabbed_by)
		for (var/obj/item/weapon/grab/G in assailant.grabbed_by)
			if(G.assailant == affecting && G.affecting == assailant)
				G.dancing = 1
				G.adjust_position()
				dancing = 1

	synch()
	playsound(victim, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

	if(state == GRAB_PASSIVE)
		assailant.visible_message("<span class='red'>[assailant] has grabbed [affecting] passively!</span>")
	else if(state == GRAB_AGGRESSIVE)
		visible_message("<span class='warning'><b>\The [assailant]</b> seizes [affecting] aggressively!</span>")

	START_PROCESSING(SSobj, src)

//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/weapon/grab/proc/throw_held()
	if(affecting)
		if(affecting.buckled)
			return null
		if(state >= GRAB_AGGRESSIVE)
			animate(affecting, pixel_x = 0, pixel_y = 0, 4, 1)
			return affecting
	return null


//This makes sure that the grab screen object is displayed in the correct hand.
/obj/item/weapon/grab/proc/synch()
	if(affecting)
		if(assailant.r_hand == src)
			hud.screen_loc = ui_rhand
		else if(assailant.l_hand == src)
			hud.screen_loc = ui_lhand
		else
			qdel(src)

/obj/item/weapon/grab/proc/set_state(_state)
	assailant.SetNextMove(CLICK_CD_GRAB)

	if(_state != state)
		state = _state
		switch(state)
			if(GRAB_PASSIVE)
				hud.name = "reinforce grab ([affecting])"
				hud.icon_state = "reinforce"
				icon_state = "grabbed"
			if(GRAB_AGGRESSIVE)
				hud.icon_state = "reinforce1"
				icon_state = "grabbed1"
			if(GRAB_NECK)
				hud.name = "kill ([affecting])"
				hud.icon_state = "kill"
				icon_state = "grabbed+1"
			if(GRAB_KILL)
				hud.icon_state = "kill1"
		adjust_position()

/mob/proc/StopGrabs()
	for(var/obj/item/weapon/grab/G in get_hand_slots())
		qdel(G)

/mob/proc/GetGrabs()
	. = list()
	for(var/obj/item/weapon/grab/G in get_hand_slots())
		. += G

/obj/item/weapon/grab/process()
	confirm()

	if(!assailant)
		qdel(src) // Same here, except we're trying to delete ourselves.
		return PROCESS_KILL

	if(!affecting)
		qdel(src)
		return PROCESS_KILL

	if(affecting.buckled)
		qdel(src)
		return PROCESS_KILL

	if(assailant.client)
		assailant.client.screen -= hud
		assailant.client.screen += hud

	if(assailant.pulling == affecting)
		assailant.stop_pulling()

	if(state <= GRAB_AGGRESSIVE)
		allow_upgrade = 1
		//disallow upgrading if we're grabbing more than one person
		if((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.l_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.r_hand
			if(G.affecting != affecting)
				allow_upgrade = 0

		//disallow upgrading past aggressive if we're being grabbed aggressively
		for(var/obj/item/weapon/grab/G in affecting.grabbed_by)
			if(G == src) continue
			if(G.state >= GRAB_AGGRESSIVE)
				allow_upgrade = 0

		if(allow_upgrade)
			if(state < GRAB_AGGRESSIVE)
				hud.icon_state = "reinforce"
			else
				hud.icon_state = "reinforce1"
		else
			hud.icon_state = "!reinforce"

	if(state >= GRAB_AGGRESSIVE)
		affecting.drop_l_hand()
		affecting.drop_r_hand()

		var/hit_zone = assailant.zone_sel.selecting
		var/announce = 0
		if(hit_zone != last_hit_zone)
			announce = 1
		last_hit_zone = hit_zone
		if(ishuman(affecting))
			var/mob/living/carbon/human/AH = affecting
			if(!AH.is_in_space_suit(only_helmet = TRUE))
				switch(hit_zone)
					if(O_MOUTH)
						if(announce)
							assailant.visible_message("<span class='warning'>[assailant] covers [AH]'s mouth!</span>")
						if(AH.silent < 3)
							AH.silent = 3
					if(O_EYES)
						if(announce)
							assailant.visible_message("<span class='warning'>[assailant] covers [AH]'s eyes!</span>")
						if(AH.eye_blind < 3)
							AH.eye_blind = 3
		if(force_down)
			if(affecting.loc != assailant.loc)
				force_down = 0
			else
				affecting.Weaken(2)

	if(state >= GRAB_NECK)
		affecting.Stun(1)
		if(isliving(affecting))
			var/mob/living/L = affecting
			L.adjustOxyLoss(1)

	if(state >= GRAB_KILL)
		//affecting.apply_effect(STUTTER, 5) //would do this, but affecting isn't declared as mob/living for some stupid reason.
		affecting.stuttering = max(affecting.stuttering, 5) //It will hamper your voice, being choked and all.
		affecting.Weaken(5)	//Should keep you down unless you get help.
		affecting.losebreath = max(affecting.losebreath + 2, 3)

	adjust_position()


/obj/item/weapon/grab/attack_self()
	return s_click(hud)


//Updating pixelshift, position and direction
//Gets called on process, when the grab gets upgraded or the assailant moves
/obj/item/weapon/grab/proc/adjust_position()
	if(!affecting)
		return
	if(affecting.buckled)
		animate(affecting, pixel_x = 0, pixel_y = 0, 4, 1, LINEAR_EASING)
		return
	if(affecting.lying && state != GRAB_KILL)
//		animate(affecting, pixel_x = 0, pixel_y = 0, 5, 1, LINEAR_EASING)
		if(force_down)
			affecting.set_dir(SOUTH) //face up
		return
	var/shift = 0
	var/adir = get_dir(assailant, affecting)
	affecting.layer = 4
	switch(state)
		if(GRAB_PASSIVE)
			shift = 8
			if(dancing) //look at partner
				shift = 10
				assailant.set_dir(get_dir(assailant, affecting))
		if(GRAB_AGGRESSIVE)
			shift = 12
		if(GRAB_NECK)
			shift = -10
			adir = assailant.dir
			affecting.set_dir(assailant.dir)
			affecting.loc = assailant.loc
		if(GRAB_KILL)
			shift = 0
			adir = 1
			affecting.set_dir(SOUTH) //face up
			affecting.loc = assailant.loc

	switch(adir)
		if(NORTH)
			animate(affecting, pixel_x = 0, pixel_y =-shift, 5, 1, LINEAR_EASING)
			affecting.layer = 3.9
		if(SOUTH)
			animate(affecting, pixel_x = 0, pixel_y = shift, 5, 1, LINEAR_EASING)
		if(WEST)
			animate(affecting, pixel_x = shift, pixel_y = 0, 5, 1, LINEAR_EASING)
		if(EAST)
			animate(affecting, pixel_x =-shift, pixel_y = 0, 5, 1, LINEAR_EASING)

/obj/item/weapon/grab/proc/s_click(obj/screen/S)
	if(!affecting)
		return
	if(!assailant)
		return
	if(assailant.next_move > world.time)
		return
	if(!assailant.canmove || assailant.lying)
		qdel(src)
		return

	if(state < GRAB_AGGRESSIVE)
		if(!allow_upgrade)
			return
		if(!affecting.lying)
			assailant.visible_message("<span class='warning'>[assailant] has grabbed [affecting] aggressively (now hands)!</span>")
		else
			assailant.visible_message("<span class='warning'>[assailant] pins [affecting] down to the ground (now hands)!</span>")
			force_down = 1
			affecting.Weaken(3)
			step_to(assailant, affecting)
			assailant.set_dir(EAST) //face the victim
			affecting.set_dir(SOUTH) //face up
		set_state(GRAB_AGGRESSIVE)

	else if(state < GRAB_NECK)
		if(isslime(affecting))
			to_chat(assailant, "<span class='notice'>You squeeze [affecting], but nothing interesting happens.</span>")
			return
		assailant.visible_message("<span class='warning'>[assailant] has reinforced \his grip on [affecting] (now neck)!</span>")
		assailant.set_dir(get_dir(assailant, affecting))
		affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has had their neck grabbed by [assailant.name] ([assailant.ckey])</font>"
		assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Grabbed the neck of [affecting.name] ([affecting.ckey])</font>"
		msg_admin_attack("[key_name(assailant)] grabbed the neck of [key_name(affecting)] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[assailant.x];Y=[assailant.y];Z=[assailant.z]'>JMP</A>)")
		affecting.Stun(10) //10 ticks of ensured grab
		set_state(GRAB_NECK)

	else if(state < GRAB_KILL)
		if(ishuman(affecting))
			var/mob/living/carbon/human/AH = affecting
			if(AH.is_in_space_suit())
				to_chat(assailant, "<span class='notice'>You can't strangle him, because space helmet covers [affecting]'s neck.</span>")
				return

		assailant.visible_message("<span class='danger'>[assailant] has tightened \his grip on [affecting]'s neck!</span>")
		affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been strangled (kill intent) by [assailant.name] ([assailant.ckey])</font>"
		assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Strangled (kill intent) [affecting.name] ([affecting.ckey])</font>"
		msg_admin_attack("[key_name(assailant)] strangled (kill intent) [key_name(affecting)]")

		affecting.losebreath += 1
		affecting.set_dir(WEST)

		set_state(GRAB_KILL)

//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/grab/proc/confirm()
	if(!assailant || !affecting)
		qdel(src)
		return 0

	if(affecting)
		if(!isturf(assailant.loc) || ( !isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return 0

	return 1


/obj/item/weapon/grab/attack(mob/M, mob/living/user)
	if(QDELETED(src))
		return

	if(!affecting)
		return

	if(!M.Adjacent(user))
		qdel(src)
		return

	assailant.SetNextMove(CLICK_CD_ACTION)

	if(M == affecting)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/hit_zone = assailant.zone_sel.selecting
			flick(hud.icon_state, hud)
			switch(assailant.a_intent)
				if("help")
					if(force_down)
						to_chat(assailant, "<span class='warning'>You are no longer pinning [affecting] to the ground.</span>")
						force_down = 0
						return
					if(state >= GRAB_AGGRESSIVE)
						H.apply_pressure(assailant, hit_zone)
					else
						inspect_organ(affecting, assailant, hit_zone)
				if("grab")
					if(state < GRAB_AGGRESSIVE)
						to_chat(assailant, "<span class='warning'>You require a better grab to do this.</span>")
						return
					var/obj/item/organ/external/BP = H.bodyparts_by_name[check_zone(hit_zone)]
					if(!BP)
						return
					assailant.visible_message("<span class='danger'>[assailant] [pick("bent", "twisted")] [H]'s [BP.name] into a jointlock!</span>")
					var/armor = H.run_armor_check(H, "melee")
					if(armor < 2)
						to_chat(H, "<span class='danger'>You feel extreme pain!</span>")
						H.adjustHalLoss(Clamp(0, 40 - H.halloss, 40)) //up to 40 halloss
					return
				if("hurt")

					if(hit_zone == O_EYES)
						if(state < GRAB_NECK)
							to_chat(assailant, "<span class='warning'>You require a better grab to do this.</span>")
							return
						if((affecting:head && affecting:head.flags & HEADCOVERSEYES) || \
							(affecting:wear_mask && affecting:wear_mask.flags & MASKCOVERSEYES) || \
							(affecting:glasses && affecting:glasses.flags & GLASSESCOVERSEYES))
							to_chat(assailant, "<span class='danger'>You're going to need to remove the eye covering first.</span>")
							return
						if(!affecting.has_eyes())
							to_chat(assailant, "<span class='danger'>You cannot locate any eyes on [affecting]!</span>")
							return
						assailant.visible_message("<span class='danger'>[assailant] pressed \his fingers into [affecting]'s eyes!</span>")
						to_chat(affecting, "<span class='danger'>You experience immense pain as you feel digits being pressed into your eyes!</span>")
						assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Pressed fingers into the eyes of [affecting.name] ([affecting.ckey])</font>")
						affecting.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had fingers pressed into their eyes by [assailant.name] ([assailant.ckey])</font>")
						msg_admin_attack("[key_name(assailant)] has pressed his fingers into [key_name(affecting)]'s eyes.")
						var/obj/item/organ/internal/eyes/IO = affecting:organs_by_name[O_EYES]
						IO.damage += rand(3,4)
						if (IO.damage >= IO.min_broken_damage)
							if(affecting.stat != DEAD)
								to_chat(affecting, "\red You go blind!")
//					else if(hit_zone != BP_HEAD)
//						if(state < GRAB_NECK)
//							assailant << "<span class='warning'>You require a better grab to do this.</span>"
//							return
//						if(affecting:grab_joint(assailant))
//							playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
//							return
					else
						if(affecting.lying)
							return
						assailant.visible_message("<span class='danger'>[assailant] thrusts \his head into [affecting]'s skull!</span>")
						var/damage = 20
						var/obj/item/clothing/hat = assailant.head
						if(istype(hat))
							damage += hat.force * 10
						var/armor = affecting:run_armor_check(affecting, "melee")
						affecting.apply_damage(damage*rand(90, 110)/100, BRUTE, BP_HEAD, armor)
						assailant.apply_damage(10*rand(90, 110)/100, BRUTE, BP_HEAD, assailant:run_armor_check(BP_HEAD, "melee"))
						if(!armor && prob(damage))
							affecting.apply_effect(20, PARALYZE)
							affecting.visible_message("<span class='danger'>[affecting] has been knocked unconscious!</span>")
						playsound(assailant.loc, "swing_hit", 25, 1, -1)
						assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Headbutted [affecting.name] ([affecting.ckey])</font>")
						affecting.attack_log += text("\[[time_stamp()]\] <font color='orange'>Headbutted by [assailant.name] ([assailant.ckey])</font>")
						msg_admin_attack("[key_name(assailant)] has headbutted [key_name(affecting)]")
						assailant.drop_from_inventory(src)
						src.loc = null
						qdel(src)
						return
				if("disarm")
					if(state < GRAB_AGGRESSIVE)
						to_chat(assailant, "<span class='warning'>You require a better grab to do this.</span>")
						return
					to_chat(assailant, "<span class='warning'>You start forcing [affecting] to the ground.</span>")
					if(!force_down)
						sleep(20)
						assailant.visible_message("<span class='danger'>[assailant] is forcing [affecting] to the ground!</span>")
						force_down = 1
						affecting.Weaken(3)
						affecting.lying = 1
						step_to(assailant, affecting)
						assailant.set_dir(EAST) //face the victim
						affecting.set_dir(SOUTH) //face up
						affecting.layer = 3.9
						return
					else
						to_chat(assailant, "<span class='warning'>You are already pinning [affecting] to the ground.</span>")
						return

	if(M == assailant && state >= GRAB_AGGRESSIVE)
		if( (ishuman(user) && (FAT in user.mutations) && ismonkey(affecting) ) || ( isalien(user) && iscarbon(affecting) ) )
			var/mob/living/carbon/attacker = user
			user.visible_message("<span class='danger'>[user] is attempting to devour [affecting]!</span>")
			if(istype(user, /mob/living/carbon/alien/humanoid/hunter))
				if(!do_mob(user, affecting)||!do_after(user, 30, target = affecting)) return
			else
				if(!do_mob(user, affecting)||!do_after(user, 100, target = affecting)) return
			user.visible_message("<span class='danger'>[user] devours [affecting]!</span>")
			if(isalien(user))
				if(affecting.stat == DEAD)
					affecting.gib()
					if(attacker.health >= attacker.maxHealth - attacker.getCloneLoss())
						attacker.adjustToxLoss(100)
						to_chat(attacker, "<span class='notice'>You gain some plasma.</span>")
					else
						attacker.adjustBruteLoss(-100)
						attacker.adjustFireLoss(-100)
						attacker.adjustOxyLoss(-100)
						attacker.adjustCloneLoss(-100)
						to_chat(attacker, "<span class='notice'>You feel better.</span>")
				else
					affecting.loc = user
					attacker.stomach_contents.Add(affecting)
			else
				affecting.loc = user
				attacker.stomach_contents.Add(affecting)
			qdel(src)

/obj/item/weapon/grab/Destroy()
	if(affecting)
		animate(affecting, pixel_x = 0, pixel_y = 0, 4, 1, LINEAR_EASING)
		affecting.layer = 4
		if(affecting)
			affecting.grabbed_by -= src
			affecting = null
	if(assailant)
		if(assailant.client)
			assailant.client.screen -= hud
		assailant = null
	QDEL_NULL(hud)
	return ..()

/obj/item/weapon/grab/proc/inspect_organ(mob/living/carbon/human/H, mob/user, target_zone)

	var/obj/item/organ/external/BP = H.get_bodypart(target_zone)

	if(!BP || (BP.status & ORGAN_DESTROYED))
		to_chat(user, "<span class='notice'>[H] is missing that bodypart.</span>")
		return

	user.visible_message("<span class='notice'>[user] starts inspecting [affecting]'s [BP.name] carefully.</span>")
	if(!do_mob(user,H, 30))
		to_chat(user, "<span class='notice'>You must stand still to inspect [BP] for wounds.</span>")
	else if(BP.wounds.len)
		to_chat(user, "<span class='warning'>You find [BP.get_wounds_desc()]</span>")
	else
		to_chat(user, "<span class='notice'>You find no visible wounds.</span>")

	to_chat(user, "<span class='notice'>Checking bones now...</span>")
	if(!do_mob(user, H, 60))
		to_chat(user, "<span class='notice'>You must stand still to feel [BP] for fractures.</span>")
	else if(BP.status & ORGAN_BROKEN)
		to_chat(user, "<span class='warning'>The bone in the [BP.name] moves slightly when you poke it!</span>")
		H.custom_pain("Your [BP.name] hurts where it's poked.")
	else
		to_chat(user, "<span class='notice'>The bones in the [BP.name] seem to be fine.</span>")

	to_chat(user, "<span class='notice'>Checking skin now...</span>")
	if(!do_mob(user, H, 30))
		to_chat(user, "<span class='notice'>You must stand still to check [H]'s skin for abnormalities.</span>")
	else
		var/bad = 0
		if(H.getToxLoss() >= 40)
			to_chat(user, "<span class='warning'>[H] has an unhealthy skin discoloration.</span>")
			bad = 1
		if(H.getOxyLoss() >= 20)
			to_chat(user, "<span class='warning'>[H]'s skin is unusaly pale.</span>")
			bad = 1
		if(BP.status & ORGAN_DEAD)
			to_chat(user, "<span class='warning'>[BP] is decaying!</span>")
			bad = 1
		if(!bad)
			to_chat(user, "<span class='notice'>[H]'s skin is normal.</span>")
