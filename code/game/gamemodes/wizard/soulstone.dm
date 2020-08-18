/obj/item/device/soulstone
	name = "Soul Stone Shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artefacts power."
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "bluespace=4;materials=4"
	var/imprinted = "empty"


//////////////////////////////Capturing////////////////////////////////////////////////////////

/obj/item/device/soulstone/attack(mob/living/carbon/human/M, mob/user)
	if(!istype(M, /mob/living/carbon/human))//If target is not a human.
		return ..()
	if(istype(M, /mob/living/carbon/human/dummy))
		return..()

	if(M.has_brain_worms()) //Borer stuff - RR
		to_chat(user, "<span class='warning'>This being is corrupted by an alien intelligence and cannot be soul trapped.</span>")
		return..()

	M.log_combat(user, "soul-captured via [name]")

	transfer_soul("VICTIM", M, user)
	return

///////////////////Options for using captured souls///////////////////////////////////////

/obj/item/device/soulstone/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = ""
	for(var/mob/living/simple_animal/shade/A in src)
		dat += "Captured Soul: [A.name]<br>"
		dat += {"<A href='byond://?src=\ref[src];choice=Summon'>Summon Shade</A>"}
		dat += "<br>"
		dat += {"<a href='byond://?src=\ref[src];choice=Close'> Close</a>"}

	var/datum/browser/popup = new(user, "window=aicard", "Soul Stone", ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()

/obj/item/device/soulstone/Topic(href, href_list)
	var/mob/U = usr
	if (!in_range(src, U)||U.machine!=src)
		U << browse(null, "window=aicard")
		U.unset_machine()
		return

	add_fingerprint(U)
	U.set_machine(src)

	switch(href_list["choice"])//Now we switch based on choice.
		if ("Close")
			U << browse(null, "window=aicard")
			U.unset_machine()
			return

		if ("Summon")
			for(var/mob/living/simple_animal/shade/A in src)
				A.status_flags &= ~GODMODE
				A.canmove = 1
				to_chat(A, "<b>You have been released from your prison, but you are still bound to [U.name]'s and his allies will. Help them suceed in their goals at all costs.</b>")
				A.loc = U.loc
				A.cancel_camera()
				src.icon_state = "soulstone"
	attack_self(U)

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive."

/obj/structure/constructshell/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/device/soulstone))
		O.transfer_soul("CONSTRUCT",src,user)


////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////


/obj/item/proc/transfer_soul(choice, target, mob/U)
	switch(choice)
		if("VICTIM")
			var/mob/living/carbon/human/T = target
			var/obj/item/device/soulstone/C = src
			if(C.imprinted != "empty")
				to_chat(U, "<span class='warning'><b>Capture failed!</b>:</span> The soul stone has already been imprinted with [C.imprinted]'s mind!")
			else
				if (T.stat == CONSCIOUS)
					to_chat(U, "<span class='warning'><b>Capture failed!</b>:</span> Kill or maim the victim first!")
				else
					if(T.client == null)
						to_chat(U, "<span class='warning'><b>Capture failed!</b>:</span> The soul has already fled it's mortal frame.")
					else
						if(C.contents.len)
							to_chat(U, "<span class='warning'><b>Capture failed!</b>:</span> The soul stone is full! Use or free an existing soul to make room.")
						else
							for(var/obj/item/W in T)
								T.drop_from_inventory(W)
							new /obj/effect/decal/remains/human(T.loc) //Spawns a skeleton
							T.invisibility = 101
							var/atom/movable/overlay/animation = new /atom/movable/overlay( T.loc )
							animation.icon_state = "blank"
							animation.icon = 'icons/mob/mob.dmi'
							animation.master = T
							flick("dust-h", animation)
							qdel(animation)
							var/mob/living/simple_animal/shade/S = new /mob/living/simple_animal/shade( T.loc )
							S.loc = C //put shade in stone
							S.status_flags |= GODMODE //So they won't die inside the stone somehow
							S.canmove = 0//Can't move out of the soul stone
							S.name = "Shade of [T.real_name]"
							S.real_name = "Shade of [T.real_name]"
							if (T.client)
								T.client.mob = S
							S.cancel_camera()
							C.icon_state = "soulstone2"
							C.name = "Soul Stone: [S.real_name]"
							to_chat(S, "Your soul has been captured! You are now bound to [U.name]'s and his allies will, help them suceed in their goals at all costs.")
							to_chat(U, "<span class='notice'><b>Capture successful!</b>:</span> [T.real_name]'s soul has been ripped from their body and stored within the soul stone.")
							to_chat(U, "The soulstone has been imprinted with [S.real_name]'s mind, it will no longer react to other souls.")
							C.imprinted = "[S.name]"
							qdel(T)
		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			var/obj/item/device/soulstone/C = src
			if (T.stat == DEAD)
				to_chat(U, "<span class='warning'><b>Capture failed!</b>:</span> The shade has already been banished!")
			else
				if(C.contents.len)
					to_chat(U, "<span class='warning'><b>Capture failed!</b>:</span> The soul stone is full! Use or free an existing soul to make room.")
				else
					if(T.name != C.imprinted)
						to_chat(U, "<span class='warning'><b>Capture failed!</b>:</span> The soul stone has already been imprinted with [C.imprinted]'s mind!")
					else
						T.loc = C //put shade in stone
						T.status_flags |= GODMODE
						T.canmove = 0
						T.health = T.maxHealth
						C.icon_state = "soulstone2"
						to_chat(T, "Your soul has been recaptured by the soul stone, its arcane energies are reknitting your ethereal form")
						to_chat(U, "<span class='notice'><b>Capture successful!</b>:</span> [T.name]'s has been recaptured and stored within the soul stone.")
		if("CONSTRUCT")
			var/obj/structure/constructshell/T = target
			var/obj/item/device/soulstone/C = src
			var/mob/living/simple_animal/shade/A = locate() in C
			if(A)
				var/construct_class = alert(U, "Please choose which type of construct you wish to create.",,"Juggernaut","Wraith","Artificer")
				switch(construct_class)
					if("Juggernaut")
						var/mob/living/simple_animal/construct/armoured/Z = new /mob/living/simple_animal/construct/armoured (get_turf(T.loc))
						Z.key = A.key
						if(iscultist(U))
							if(SSticker.mode.name == "cult")
								SSticker.mode:add_cultist(Z.mind)
							else
								SSticker.mode.cult+=Z.mind
							SSticker.mode.update_all_cult_icons()
						qdel(T)
						to_chat(Z, "<B>You are playing a Juggernaut. Though slow, you can withstand extreme punishment, and rip apart enemies and walls alike.</B>")
						to_chat(Z, "<B>You are still bound to serve your creator and his allies, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						qdel(C)

					if("Wraith")
						var/mob/living/simple_animal/construct/wraith/Z = new /mob/living/simple_animal/construct/wraith (get_turf(T.loc))
						Z.key = A.key
						if(iscultist(U))
							if(SSticker.mode.name == "cult")
								SSticker.mode:add_cultist(Z.mind)
							else
								SSticker.mode.cult+=Z.mind
							SSticker.mode.update_all_cult_icons()
						qdel(T)
						to_chat(Z, "<B>You are playing a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>")
						to_chat(Z, "<B>You are still bound to serve your creator and his allies, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						qdel(C)

					if("Artificer")
						var/mob/living/simple_animal/construct/builder/Z = new /mob/living/simple_animal/construct/builder (get_turf(T.loc))
						Z.key = A.key
						if(iscultist(U))
							if(SSticker.mode.name == "cult")
								SSticker.mode:add_cultist(Z.mind)
							else
								SSticker.mode.cult+=Z.mind
							SSticker.mode.update_all_cult_icons()
						qdel(T)
						to_chat(Z, "<B>You are playing an Artificer. You are incredibly weak and fragile, but you are able to construct fortifications, repair allied constructs (by clicking on them), and even create new constructs</B>")
						to_chat(Z, "<B>You are still bound to serve your creator and his allies, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						qdel(C)
			else
				to_chat(U, "<span class='warning'><b>Creation failed!</b>:</span> The soul stone is empty! Go kill someone!")
	return
