///////////////ANTIBODY SCANNER///////////////

/obj/item/device/antibody_scanner
	name = "Antibody Scanner"
	desc = "Scans living beings for antibodies in their blood."
	icon_state = "health"
	w_class = ITEM_SIZE_SMALL
	item_state = "electronic"
	flags = CONDUCT

/obj/item/device/antibody_scanner/attack(mob/M, mob/user)
	if(!istype(M,/mob/living/carbon))
		report("Scan aborted: Incompatible target.", user)
		return

	var/mob/living/carbon/C = M
	if (istype(C,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = C
		if(H.species && H.species.flags[NO_BLOOD])
			report("Scan aborted: The target does not have blood.", user)
			return

	if(!C.antibodies)
		report("Scan Complete: No antibodies detected.", user)
		return

	if (CLUMSY in user.mutations && prob(50))
		// I was tempted to be really evil and rot13 the output.
		report("Antibodies detected: [reverse_text(antigens2string(C.antibodies))]", user)
	else
		report("Antibodies detected: [antigens2string(C.antibodies)]", user)

/obj/item/device/antibody_scanner/proc/report(text, mob/user)
	to_chat(user, "<span class='notice'>[bicon(src)] \The [src] beeps, \"[text]\"</span>")

///////////////VIRUS DISH///////////////

/obj/item/weapon/virusdish
	name = "virus containment/growth dish"
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"
	var/datum/disease2/disease/virus2 = null
	//var/growth = 0
	var/info = 0
	var/analysed = 0

/obj/item/weapon/virusdish/random
	name = "virus sample"

/obj/item/weapon/virusdish/random/atom_init()
	. = ..()
	virus2 = new /datum/disease2/disease
	virus2.makerandom()
	//growth = 100//rand(5, 50)

/obj/item/weapon/virusdish/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/hand_labeler) || istype(I, /obj/item/weapon/reagent_containers/syringe))
		return

	. = ..()
	user.SetNextMove(CLICK_CD_MELEE)
	if(prob(50))
		to_chat(user, "\The [src] shatters!")
		message_admins("Virus dish shattered by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) [ADMIN_JMP(src)]")
		log_game("Virus dish shattered by [key_name(user)] in ([src.x],[src.y],[src.z])")
		if(virus2.infectionchance > 0)
			for(var/mob/living/carbon/target in view(1, get_turf(src)))
				if(airborne_can_reach(get_turf(src), get_turf(target)))
					if(get_infection_chance(target))
						infect_virus2(target,src.virus2)
		qdel(src)

/obj/item/weapon/virusdish/examine(mob/user)
	..()
	if(info)
		to_chat(user, "It has the following information about its contents:")
		to_chat(user, info)

/obj/item/weapon/ruinedvirusdish
	name = "ruined virus sample"
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"
	desc = "The bacteria in the dish are completely dead."

/obj/item/weapon/ruinedvirusdish/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/hand_labeler) || istype(I, /obj/item/weapon/reagent_containers/syringe))
		return

	. = ..()
	user.SetNextMove(CLICK_CD_MELEE)
	if(prob(50))
		to_chat(user, "\The [src] shatters!")
		qdel(src)

///////////////GNA DISK///////////////

/obj/item/weapon/diseasedisk
	name = "blank GNA disk"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk0"
	var/datum/disease2/effectholder/effect = null
	var/list/species = null
	var/stage = 1
	var/analysed = 1

/obj/item/weapon/diseasedisk/premade/atom_init()
	. = ..()
	name = "blank GNA disk (stage: [stage])"
	effect = new /datum/disease2/effectholder
	effect.effect = new /datum/disease2/effect/invisible
	effect.stage = stage
