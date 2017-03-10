//In here: Hatch and Ascendance
var/list/possibleShadowlingNames = list("U'ruan", "Y`shej", "Nex", "Hel-uae", "Noaey'gief", "Mii`mahza", "Amerziox", "Gyrg-mylin", "Kanet'pruunance", "Vigistaezian")
/mob/living/carbon/human/proc/shadowling_hatch()
	set category = "Shadowling Evolution"
	set name = "Hatch"

	if(usr.stat)
		return
	usr.verbs -= /mob/living/carbon/human/proc/shadowling_hatch
	switch(alert("Are you sure you want to hatch? You cannot undo this!",,"Yes","No"))
		if("No")
			to_chat(usr, "<span class='warning'>You decide against hatching for now.")
			usr.verbs += /mob/living/carbon/human/proc/shadowling_hatch
			return
		if("Yes")
			if(!istype(usr.loc, /turf))
				to_chat(usr, "<span class='warning'>You can't hatch here.")
				usr.verbs += /mob/living/carbon/human/proc/shadowling_hatch
				return
			usr.notransform = 1
			usr.visible_message("<span class='warning'>[usr]'s things suddenly slip off. They hunch over and vomit up a copious amount of purple goo which begins to shape around them!</span>", \
								"<span class='shadowling'>You remove any equipment which would hinder your hatching and begin regurgitating the resin which will protect you.</span>")

			usr.Stun(34)
			for(var/obj/item/I in usr) //drops all items
				usr.drop_from_inventory(I)
			usr.regenerate_icons()

			sleep(50)
			var/turf/simulated/floor/F
			var/turf/shadowturf = get_turf(usr)
			for(F in orange(1, usr))
				new /obj/effect/alien/resin/wall/shadowling(F)
			//for(var/obj/structure/alien/resin/wall/shadowling/R in shadowturf) //extremely hacky
			for(var/obj/effect/alien/resin/wall/shadowling/R in shadowturf)
				qdel(R)
				//new /obj/structure/alien/weeds/node(shadowturf) //Dim lighting in the chrysalis -- removes itself with the chrysalis
				new /obj/structure/alien/weeds/node(shadowturf)

			usr.visible_message("<span class='warning'>A chrysalis forms around [usr], sealing them inside.</span>", \
								"<span class='shadowling'>You create your chrysalis and begin to contort within.</span>")

			sleep(100)
			usr.visible_message("<span class='warning'><b>The skin on [usr]'s back begins to split apart. Black spines slowly emerge from the divide.</b></span>", \
								"<span class='shadowling'>Spines pierce your back. Your claws break apart your fingers. You feel excruciating pain as your true form begins its exit.</span>")

			sleep(90)
			usr.visible_message("<span class='warning'><b>[usr], skin shifting, begins tearing at the walls around them.</b></span>", \
							"<span class='shadowling'>Your false skin slips away. You begin tearing at the fragile membrane protecting you.</span>")

			sleep(80)
			playsound(usr.loc, 'sound/weapons/slash.ogg', 25, 1)
			to_chat(usr, "<i><b>You rip and slice.</b></i>")
			sleep(10)
			playsound(usr.loc, 'sound/weapons/slashmiss.ogg', 25, 1)
			to_chat(usr, "<i><b>The chrysalis falls like water before you.</b></i>")
			sleep(10)
			playsound(usr.loc, 'sound/weapons/slice.ogg', 25, 1)
			to_chat(usr, "<i><b>You are free!</b></i>")

			sleep(10)
			playsound(usr.loc, 'sound/effects/ghost.ogg', 100, 1)

			usr.notransform = 0

			to_chat(usr, "<i><b><font size=3>YOU LIVE!!!</i></b></font>")

			for(var/obj/effect/alien/resin/wall/shadowling/W in orange(usr, 1))
				playsound(W, 'sound/effects/splat.ogg', 50, 1)
				qdel(W)
			for(var/obj/structure/alien/weeds/node/N in shadowturf)
				qdel(N)
			usr.visible_message("<span class='warning'>The chrysalis explodes in a shower of purple flesh and fluid!</span>")

			var/mob/living/carbon/human/H = new /mob/living/carbon/human(usr.loc)

			var/newNameId = pick(possibleShadowlingNames)
			possibleShadowlingNames.Remove(newNameId)
			H.real_name = newNameId
			H.name = usr.real_name

			H.underwear = 0
			H.undershirt = 0
			//M.faction |= "faithless"
			H.faction = "faithless"

			H.equip_to_slot_or_del(new /obj/item/clothing/under/shadowling(usr), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/shadowling(usr), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(usr), slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(usr), slot_head)
			H.equip_to_slot_or_del(new /obj/item/clothing/gloves/shadowling(usr), slot_gloves)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/shadowling(usr), slot_wear_mask)
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/shadowling(usr), slot_glasses)
			//hardset_dna(usr, null, null, null, null, /datum/species/shadow/ling) //can't be a shadowling without being a shadowling
			H.set_species("Shadowling")
			H.dna.mutantrace = "shadowling"
			H.update_mutantrace()
			H.regenerate_icons()
			usr.mind.transfer_to(H)
			ticker.mode.update_all_shadows_icons()

			to_chat(H, "<span class='shadowling'><b><i>Your powers are awoken. You may now live to your fullest extent. Remember your goal. Cooperate with your thralls and allies.</b></i></span>")
			H.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind
			H.spell_list += new /obj/effect/proc_holder/spell/targeted/enthrall
			H.spell_list += new /obj/effect/proc_holder/spell/targeted/glare
			H.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/veil
			H.spell_list += new /obj/effect/proc_holder/spell/targeted/shadow_walk
			H.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/flashfreeze
			H.spell_list += new /obj/effect/proc_holder/spell/targeted/collective_mind
			H.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_regenarmor

			qdel(usr)



/mob/living/carbon/human/proc/shadowling_ascendance()
	set category = "Shadowling Evolution"
	set name = "Ascendance"

	if(usr.stat)
		return
	usr.verbs -= /mob/living/carbon/human/proc/shadowling_ascendance
	switch(alert("It is time to ascend. Are you completely sure about this? You cannot undo this!",,"Yes","No"))
		if("No")
			to_chat(usr, "<span class='warning'>You decide against ascending for now.")
			usr.verbs += /mob/living/carbon/human/proc/shadowling_ascendance
			return
		if("Yes")
			if(!istype(usr.loc, /turf))
				to_chat(usr, "<span class='warning'>You can't evolve here.")
				usr.verbs += /mob/living/carbon/human/proc/shadowling_ascendance
				return
			usr.notransform = 1
			usr.Stun(34)
			usr.visible_message("<span class='warning'>[usr] rapidly bends and contorts, their eyes flaring a deep crimson!</span>", \
								"<span class='shadowling'>You begin unlocking the genetic vault within you and prepare yourself for the power to come.</span>")

			sleep(30)
			usr.visible_message("<span class='danger'>[usr] suddenly shoots up a few inches in the air and begins hovering there, still twisting.</span>", \
								"<span class='shadowling'>You hover into the air to make room for your new form.</span>")

			sleep(60)
			usr.visible_message("<span class='danger'>[usr]'s skin begins to pulse red in sync with their eyes. Their form slowly expands outward.</span>", \
								"<span class='shadowling'>You feel yourself beginning to mutate.</span>")

			sleep(20)
			if(!ticker.mode.shadowling_ascended)
				to_chat(usr, "<span class='shadowling'>It isn't enough. Time to draw upon your thralls.</span>")
			else
				to_chat(usr, "<span class='shadowling'>After some telepathic searching, you find the reservoir of life energy from the thralls and tap into it.</span>")

			sleep(50)
			for(var/mob/M in mob_list)
				if(is_thrall(M) && !ticker.mode.shadowling_ascended)
					M.visible_message("<span class='userdanger'>[M] trembles minutely as they collapse, black smoke pouring from their disintegrating face.</span>", \
									  "<span class='userdanger'>It's time! Your masters are ascending! Your last thoughts are happy as your body is drained of life.</span>")

					ticker.mode.thralls -= M.mind //To prevent message spam
					M.death(0)

			to_chat(usr, "<span class='userdanger'>Drawing upon your thralls, you find the strength needed to finish and rend apart the final barriers to godhood.</b></span>")

			sleep(20)
			to_chat(usr, "<span class='big'><b>Yes!</b></span>")
			sleep(10)
			to_chat(usr, "<span class='reallybig'><b>YES!</b></span>")
			sleep(10)
			to_chat(usr, "<font size=5><b><i>YE--</b></I></font>")
			sleep(1)
			for(var/mob/living/M in orange(7, src))
				M.Weaken(10)
				to_chat(M, "<span class='userdanger'>An immense pressure slams you onto the ground!</span>")
			to_chat(world, "<font size=5><span class='shadowling'><b>\"VYSHA NERADA YEKHEZET U'RUU!!\"</font></span>")
			world << 'sound/hallucinations/veryfar_noise.ogg'
			for(var/obj/machinery/power/apc/A in world)
				A.overload_lighting()
			var/mob/A = new /mob/living/simple_animal/ascendant_shadowling(usr.loc)
			A.spell_list = list()
			A.spell_list += new /obj/effect/proc_holder/spell/targeted/annihilate
			A.spell_list += new /obj/effect/proc_holder/spell/targeted/hypnosis
			A.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_phase_shift
			A.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/glacial_blast
			A.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind_ascendant
			A.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowlingAscendantTransmit
			usr.mind.transfer_to(A)
			A.name = usr.real_name
			if(A.real_name)
				A.real_name = usr.real_name
			usr.invisibility = 60 //This is pretty bad, but is also necessary for the shuttle call to function properly
			usr.flags |= GODMODE
			usr.notransform = 1
			sleep(50)
			if(!ticker.mode.shadowling_ascended)
				SSshuttle.incall(0.3)
				captain_announce("The emergency shuttle has been called. It will arrive in [round(SSshuttle.timeleft()/60)] minutes.")
				world << sound('sound/AI/shuttlecalled.ogg')
			ticker.mode.shadowling_ascended = 1
			qdel(usr)
