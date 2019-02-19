////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1
#define SYRINGE_BROKEN 2

/obj/item/weapon/reagent_containers/syringe
	name = "syringe"
	desc = "A syringe."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	g_amt = 150
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null //list(5,10,15)
	volume = 15
	w_class = 1
	sharp = 1
	var/mode = SYRINGE_DRAW

/obj/item/weapon/reagent_containers/syringe/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_self(mob/user)

	switch(mode)
		if(SYRINGE_DRAW)
			mode = SYRINGE_INJECT
		if(SYRINGE_INJECT)
			mode = SYRINGE_DRAW
		if(SYRINGE_BROKEN)
			return
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_paw()
	return attack_hand()

/obj/item/weapon/reagent_containers/syringe/attackby(obj/item/I, mob/user)
	return

/obj/item/weapon/reagent_containers/syringe/afterattack(obj/target, mob/user, proximity)
	if(!proximity) return
	if(!target.reagents) return

	if(mode == SYRINGE_BROKEN)
		to_chat(user, "\red This syringe is broken!")
		return

	if (user.a_intent == "hurt" && ismob(target))
		if((CLUMSY in user.mutations) && prob(50))
			target = user
		syringestab(target, user)
		return


	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "\red The syringe is full.")
				return

			if(ismob(target))//Blood!
				if(istype(target, /mob/living/carbon/slime))
					to_chat(user, "\red You are unable to locate any blood.")
					return
				if(src.reagents.has_reagent("blood"))
					to_chat(user, "\red There is already a blood sample in this syringe")
					return
				if(istype(target, /mob/living/carbon))//maybe just add a blood reagent to all mobs. Then you can suck them dry...With hundreds of syringes. Jolly good idea.
					var/amount = src.reagents.maximum_volume - src.reagents.total_volume
					var/mob/living/carbon/T = target
					if(!T.dna)
						to_chat(usr, "You are unable to locate any blood. (To be specific, your target seems to be missing their DNA datum)")
						return
					if(NOCLONE in T.mutations) //target done been et, no more blood in him
						to_chat(user, "\red You are unable to locate any blood.")
						return

					var/datum/reagent/B
					if(istype(T,/mob/living/carbon/human))
						var/mob/living/carbon/human/H = T
						if(H.species && H.species.flags[NO_BLOOD])
							H.reagents.trans_to(src,amount)
						else
							B = T.take_blood(src,amount)
					else
						B = T.take_blood(src,amount)

					if (B)
						src.reagents.reagent_list += B
						src.reagents.update_total()
						src.on_reagent_change()
						src.reagents.handle_reactions()
					infect_limb(user, target)
					to_chat(user, "\blue You take a blood sample from [target]")
					for(var/mob/O in viewers(4, user))
						O.show_message("\red [user] takes a blood sample from [target].", 1)

			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, "\red [target] is empty.")
					return

				if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers) && !istype(target,/obj/item/slime_extract))
					to_chat(user, "\red You cannot directly remove reagents from this object.")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, "\blue You fill the syringe with [trans] units of the solution.")
			if (reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, "\red The Syringe is empty.")
				return
			if(istype(target, /obj/item/weapon/implantcase/chem))
				return

			if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food) && !istype(target, /obj/item/slime_extract) && !istype(target, /obj/item/clothing/mask/cigarette) && !istype(target, /obj/item/weapon/storage/fancy/cigarettes))
				to_chat(user, "\red You cannot directly fill this object.")
				return
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "\red [target] is full.")
				return

			if(isliving(target))
				var/mob/living/L = target
				if(target != user)

					if(!L.try_inject(user, TRUE))
						return

					var/mob/living/M = target
					var/list/injected = list()
					for(var/datum/reagent/R in src.reagents.reagent_list)
						injected += R.name
					var/contained = english_list(injected)
					infect_limb(user, target)
					M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [src.name] by [user.name] ([user.ckey]). Reagents: [contained]</font>")
					user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to inject [M.name] ([M.key]). Reagents: [contained]</font>")
					msg_admin_attack("[user.name] ([user.ckey]) injected [M.name] ([M.key]) with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

					src.reagents.reaction(target, INGEST)
				else
					if(!L.try_inject(user, TRUE, TRUE))
						return
					src.reagents.reaction(target, INGEST)
					infect_limb(user, target)
			var/datum/reagent/blood/B
			for(var/datum/reagent/blood/d in src.reagents.reagent_list)
				B = d
				break
			var/trans
			if(B && istype(target,/mob/living/carbon))
				var/list/virus2 = B.data["virus2"]
				if(virus2.len)
					message_admins("<font color='red'>Injected blood with virus to [target] by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>Jump</a>)</font>",0,1)
					log_game("Injected blood with virus to [target] by [user.ckey]([user]) in ([user.x],[user.y],[user.z])")
				var/mob/living/carbon/C = target
				C.inject_blood(src,5)
			else
				trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'>You inject [trans] units of the solution. The syringe now contains [src.reagents.total_volume] units.</span>")
			if (reagents.total_volume <= 0 && mode == SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()

/obj/item/weapon/reagent_containers/syringe/proc/syringestab(mob/living/carbon/target, mob/living/carbon/user)

	if(target.try_inject(user, FALSE, TRUE))

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [target.name] ([target.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
		msg_admin_attack("[user.name] ([user.ckey]) attacked [target.name] ([target.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) [ADMIN_JMP(user)]")

		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/target_zone = ran_zone(check_zone(user.zone_sel.selecting, target))
			var/obj/item/organ/external/BP = H.get_bodypart(target_zone)

			if (!BP)
				return

			var/hit_area = BP.name

			if((user != target) && target.check_shields(7, "the [src.name]", get_dir(user,target)))
				return

			if (target != user && target.getarmor(target_zone, "melee") > 5 && prob(50))
				visible_message("\red <B>[user] tries to stab [target] in \the [hit_area] with [name], but the attack is deflected by armor!</B>")
				qdel(src)
				return
			infect_limb(user, target)
			BP.take_damage(3)
		else
			target.take_bodypart_damage(3)// 7 is the same as crowbar punch

		reagents.reaction(target, INGEST)
		var/syringestab_amount_transferred = rand(0, (reagents.total_volume - 5)) //nerfed by popular demand
		reagents.trans_to(target, syringestab_amount_transferred)

	user.visible_message("\red <B>[user] stabs [target] with [src.name]!</B>")

	desc += " It is broken."
	mode = SYRINGE_BROKEN
	add_blood(target)
	add_fingerprint(usr)
	update_icon()

/obj/item/weapon/reagent_containers/syringe/update_icon()
	if(mode == SYRINGE_BROKEN)
		icon_state = "broken"
		overlays.Cut()
		return
	var/rounded_vol = round(reagents.total_volume,5)
	overlays.Cut()
	if(ismob(loc))
		var/injoverlay
		switch(mode)
			if (SYRINGE_DRAW)
				injoverlay = "draw"
			if (SYRINGE_INJECT)
				injoverlay = "inject"
		overlays += injoverlay
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "syringe10")

		filling.icon_state = "syringe[rounded_vol]"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/weapon/reagent_containers/syringe/proc/infect_limb(mob/living/carbon/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/target_zone = user.zone_sel.selecting
		var/obj/item/organ/external/BP = H.get_bodypart(target_zone)

		if (!BP)
			return
		if(crit_fail)
			BP.germ_level += germ_level / 7
		else
			BP.germ_level += min(germ_level, 3)
		H.bad_bodyparts |= BP

/obj/item/weapon/reagent_containers/ld50_syringe
	name = "Lethal Injection Syringe"
	desc = "A syringe used for lethal injections."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = null //list(5,10,15)
	volume = 50
	var/mode = SYRINGE_DRAW

/obj/item/weapon/reagent_containers/ld50_syringe/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/attack_self(mob/user)
	mode = !mode
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/attack_paw()
	return attack_hand()

/obj/item/weapon/reagent_containers/ld50_syringe/attackby(obj/item/I, mob/user)
	return

/obj/item/weapon/reagent_containers/ld50_syringe/afterattack(obj/target, mob/user , flag)
	if(!target.reagents) return

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "\red The syringe is full.")
				return

			if(ismob(target))
				if(istype(target, /mob/living/carbon))//I Do not want it to suck 50 units out of people
					to_chat(usr, "This needle isn't designed for drawing blood.")
					return
			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, "\red [target] is empty.")
					return

				if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
					to_chat(user, "\red You cannot directly remove reagents from this object.")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, "\blue You fill the syringe with [trans] units of the solution.")
			if (reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, "\red The Syringe is empty.")
				return
			if(istype(target, /obj/item/weapon/implantcase/chem))
				return
			if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food))
				to_chat(user, "\red You cannot directly fill this object.")
				return
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "\red [target] is full.")
				return

			if(ismob(target) && target != user)
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red <B>[] is trying to inject [] with a giant syringe!</B>", user, target), 1)
				if(!do_mob(user, target, 300)) return
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red [] injects [] with a giant syringe!", user, target), 1)
				src.reagents.reaction(target, INGEST)
			if(ismob(target) && target == user)
				src.reagents.reaction(target, INGEST)
			spawn(5)
				var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
				to_chat(user, "\blue You inject [trans] units of the solution. The syringe now contains [src.reagents.total_volume] units.")
				if (reagents.total_volume >= reagents.maximum_volume && mode==SYRINGE_INJECT)
					mode = SYRINGE_DRAW
					update_icon()
	return


/obj/item/weapon/reagent_containers/ld50_syringe/update_icon()
	var/rounded_vol = round(reagents.total_volume,50)
	if(ismob(loc))
		var/mode_t
		switch(mode)
			if (SYRINGE_DRAW)
				mode_t = "d"
			if (SYRINGE_INJECT)
				mode_t = "i"
		icon_state = "[mode_t][rounded_vol]"
	else
		icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"


////////////////////////////////////////////////////////////////////////////////
/// Syringes. END
////////////////////////////////////////////////////////////////////////////////



/obj/item/weapon/reagent_containers/syringe/inaprovaline
	name = "Syringe (inaprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."

/obj/item/weapon/reagent_containers/syringe/inaprovaline/atom_init()
	. = ..()
	reagents.add_reagent("inaprovaline", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/antitoxin
	name = "Syringe (anti-toxin)"
	desc = "Contains anti-toxins."

/obj/item/weapon/reagent_containers/syringe/antitoxin/atom_init()
	. = ..()
	reagents.add_reagent("anti_toxin", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/antiviral
	name = "Syringe (spaceacillin)"
	desc = "Contains antiviral agents."

/obj/item/weapon/reagent_containers/syringe/antiviral/atom_init()
	. = ..()
	reagents.add_reagent("spaceacillin", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/choral

/obj/item/weapon/reagent_containers/ld50_syringe/choral/atom_init()
	. = ..()
	reagents.add_reagent("chloralhydrate", 50)
	mode = SYRINGE_INJECT
	update_icon()


//Robot syringes
//Not special in any way, code wise. They don't have added variables or procs.
/obj/item/weapon/reagent_containers/syringe/robot/antitoxin
	name = "Syringe (anti-toxin)"
	desc = "Contains anti-toxins."

/obj/item/weapon/reagent_containers/syringe/robot/antitoxin/atom_init()
	. = ..()
	reagents.add_reagent("anti_toxin", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/robot/inoprovaline
	name = "Syringe (inoprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."

/obj/item/weapon/reagent_containers/syringe/robot/inoprovaline/atom_init()
	. = ..()
	reagents.add_reagent("inaprovaline", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/robot/mixed
	name = "Syringe (mixed)"
	desc = "Contains inaprovaline & anti-toxins."

/obj/item/weapon/reagent_containers/syringe/robot/mixed/atom_init()
	. = ..()
	reagents.add_reagent("inaprovaline", 7)
	reagents.add_reagent("anti_toxin", 8)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/mulligan
	name = "Mulligan"
	desc = "A syringe used to completely change the users identity."
	amount_per_transfer_from_this = 1

/obj/item/weapon/reagent_containers/syringe/mulligan/atom_init()
	. = ..()
	reagents.add_reagent("mulligan", 1)
	mode = SYRINGE_INJECT
	update_icon()
