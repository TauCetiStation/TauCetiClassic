////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/pill
	name = "pill"
	desc = "a pill."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	item_state = "pill"
	possible_transfer_amounts = null
	w_class = SIZE_MINUSCULE
	volume = 50
	var/halved = FALSE // if set to TRUE pill cannot be split in halves again

/obj/item/weapon/reagent_containers/pill/atom_init()
	. = ..()
	if(!icon_state)
		icon_state = "pill[rand(1,20)]"

/obj/item/weapon/reagent_containers/pill/attack_self(mob/user)
	if(halved)
		return
	user.drop_from_inventory(src)
	var/volume_half = reagents.total_volume / 2
	for(var/part in list("top", "bottom"))
		var/obj/item/weapon/reagent_containers/pill/P = new(user.loc)
		P.name = "half of [name]"
		P.icon_state = icon_state
		P.add_filter("pill_alpha", 3, alpha_mask_filter(icon = icon(icon, "pill_half_[part]")))
		P.add_overlay(icon(icon, "pill_half_border_[part]"))
		P.halved = TRUE
		reagents.trans_to(P.reagents, volume_half)
		user.put_in_any_hand_if_possible(P)
	to_chat(user, "<span class='notice'>You split [src] in two halves.</span>")
	qdel(src)

/obj/item/weapon/reagent_containers/pill/attack(mob/living/M, mob/user, def_zone)
	if(!CanEat(user, M, src, "take")) return
	if(M == user)
		to_chat(M, "<span class='notice'>You swallow [src].</span>")
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>Swallow [src.name]. Reagents: [reagentlist(src)]</font>")
		M.drop_from_inventory(src) //icon update
		if(reagents.total_volume)
			reagents.trans_to_ingest(M, reagents.total_volume)
			qdel(src)
		else
			qdel(src)
		return 1

	else
		user.visible_message("<span class='warning'>[user] attempts to force [M] to swallow [src].</span>")

		var/ingestion_time = apply_skill_bonus(user, SKILL_TASK_TOUGH, list(/datum/skill/medical = SKILL_LEVEL_NOVICE), -0.2)
		if(!do_mob(user, M, ingestion_time))
			return

		user.drop_from_inventory(src) //icon update
		user.visible_message("<span class='warning'>[user] forces [M] to swallow [src].</span>")

		M.log_combat(user, "fed with [name], reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)])")

		if(reagents.total_volume)
			reagents.trans_to_ingest(M, reagents.total_volume)
			qdel(src)
		else
			qdel(src)

		return 1

/obj/item/weapon/reagent_containers/pill/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(target.is_open_container() && target.reagents)
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty. Cant dissolve pill.</span>")
			return
		to_chat(user, "<span class='notice'>You dissolve the pill in [target]</span>")

		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Spiked \a [target] with a pill. Reagents: [reagentlist(src)]</font>")
		msg_admin_attack("[user.name] ([user.ckey]) spiked \a [target] with a pill. Reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)])", user)

		reagents.trans_to(target, reagents.total_volume)
		user.visible_message("<span class='warning'>[user] puts something in \the [target].</span>", viewing_distance = 2)

		spawn(5)
			qdel(src)

	return

/obj/item/weapon/reagent_containers/pill/examine(mob/user)
	..()
	if(!is_skill_competent(user, list(/datum/skill/chemistry = SKILL_LEVEL_TRAINED)))
		return
	to_chat(user, "It contains:")
	if(reagents.reagent_list.len)
		for(var/datum/reagent/R in reagents.reagent_list)
			to_chat(user, "<span class='info'>[R.volume + R.volume * rand(-25,25) / 100] units of [R.name]</span>")

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

//Pills
/obj/item/weapon/reagent_containers/pill/dylovene
	name = "Anti-toxins pill (25u)"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"

/obj/item/weapon/reagent_containers/pill/dylovene/atom_init()
	. = ..()
	reagents.add_reagent("anti_toxin", 25)

/obj/item/weapon/reagent_containers/pill/tox
	name = "Toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5"

/obj/item/weapon/reagent_containers/pill/dermaline
	name = "Dermaline pill (15u)"
	desc = "Used to treat burns."
	icon_state = "pill11"

/obj/item/weapon/reagent_containers/pill/dermaline/atom_init()
	. = ..()
	reagents.add_reagent("dermaline", 15)

/obj/item/weapon/reagent_containers/pill/tox/atom_init()
	. = ..()
	reagents.add_reagent("toxin", 50)

/obj/item/weapon/reagent_containers/pill/cyanide
	name = "Cyanide pill"
	desc = "Don't swallow this."
	icon_state = "pill5"

/obj/item/weapon/reagent_containers/pill/cyanide/atom_init()
	. = ..()
	reagents.add_reagent("cyanide", 50)

/obj/item/weapon/reagent_containers/pill/stox
	name = "Sleeping pill (15u)"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill8"

/obj/item/weapon/reagent_containers/pill/stox/atom_init()
	. = ..()
	reagents.add_reagent("stoxin", 15)

/obj/item/weapon/reagent_containers/pill/kelotane
	name = "Kelotane pill (15u)"
	desc = "Used to treat burns."
	icon_state = "pill11"

/obj/item/weapon/reagent_containers/pill/kelotane/atom_init()
	. = ..()
	reagents.add_reagent("kelotane", 15)

/obj/item/weapon/reagent_containers/pill/paracetamol
	name = "Paracetamol pill (15u)"
	desc = "Tylenol! A painkiller for the ages. Chewables!"
	icon_state = "pill8"

/obj/item/weapon/reagent_containers/pill/paracetamol/atom_init()
	. = ..()
	reagents.add_reagent("paracetamol", 15)

/obj/item/weapon/reagent_containers/pill/tramadol
	name = "Tramadol pill (15u)"
	desc = "A simple painkiller."
	icon_state = "pill8"

/obj/item/weapon/reagent_containers/pill/tramadol/atom_init()
	. = ..()
	reagents.add_reagent("tramadol", 15)

/obj/item/weapon/reagent_containers/pill/methylphenidate
	name = "Methylphenidate pill (15u)"
	desc = "Improves the ability to concentrate."
	icon_state = "pill8"

/obj/item/weapon/reagent_containers/pill/methylphenidate/atom_init()
	. = ..()
	reagents.add_reagent("methylphenidate", 15)

/obj/item/weapon/reagent_containers/pill/citalopram
	name = "Citalopram pill (15u)"
	desc = "Mild anti-depressant."
	icon_state = "pill8"

/obj/item/weapon/reagent_containers/pill/citalopram/atom_init()
	. = ..()
	reagents.add_reagent("citalopram", 15)

/obj/item/weapon/reagent_containers/pill/paroxetine
	name = "Paroxetine (10u)"
	desc = "Before you swallow a bullet: try swallowing this!"
	icon_state = "pill4"

/obj/item/weapon/reagent_containers/pill/paroxetine/atom_init()
	. = ..()
	reagents.add_reagent("paroxetine", 10)

/obj/item/weapon/reagent_containers/pill/inaprovaline
	name = "Inaprovaline pill (30u)"
	desc = "Used to stabilize patients."
	icon_state = "pill20"

/obj/item/weapon/reagent_containers/pill/inaprovaline/atom_init()
	. = ..()
	reagents.add_reagent("inaprovaline", 30)

/obj/item/weapon/reagent_containers/pill/dexalin
	name = "Dexalin pill (15u)"
	desc = "Used to treat oxygen deprivation."
	icon_state = "pill16"

/obj/item/weapon/reagent_containers/pill/dexalin/atom_init()
	. = ..()
	reagents.add_reagent("dexalin", 15)

/obj/item/weapon/reagent_containers/pill/dexalin_plus
	name = "Dexalin plus pill (10u)"
	desc = "Used to treat extreme oxygen deprivation."
	icon_state = "pill16"

/obj/item/weapon/reagent_containers/pill/dexalin_plus/atom_init()
	. = ..()
	reagents.add_reagent("dexalinp", 10)

/obj/item/weapon/reagent_containers/pill/bicaridine
	name = "Bicaridine pill (20u)"
	desc = "Used to treat physical injuries."
	icon_state = "pill18"

/obj/item/weapon/reagent_containers/pill/bicaridine/atom_init()
	. = ..()
	reagents.add_reagent("bicaridine", 20)

/obj/item/weapon/reagent_containers/pill/happy
	name = "Happy pill"
	desc = "Happy happy joy joy!"
	icon_state = "pill18"

/obj/item/weapon/reagent_containers/pill/happy/atom_init()
	. = ..()
	reagents.add_reagent("space_drugs", 15)
	reagents.add_reagent("sugar", 15)

/obj/item/weapon/reagent_containers/pill/zoom
	name = "Zoom pill"
	desc = "Zoooom!"
	icon_state = "pill18"

/obj/item/weapon/reagent_containers/pill/zoom/atom_init()
	. = ..()
	reagents.add_reagent("impedrezene", 10)
	reagents.add_reagent("tramadol", 10)
	reagents.add_reagent("stimulants",5)
	reagents.add_reagent("toxin", 5)

/obj/item/weapon/reagent_containers/pill/LSD
	name = "LSD"
	desc = "Ahaha oh wow."
	icon_state = "pill9"

/obj/item/weapon/reagent_containers/pill/LSD/atom_init()
	. = ..()
	reagents.add_reagent("mindbreaker", 15)

/obj/item/weapon/reagent_containers/pill/lipozine
	name = "Lipozine (15u)"
	desc = "When you mistake whith maffin"
	icon_state = "pill18"

/obj/item/weapon/reagent_containers/pill/lipozine/atom_init()
	. = ..()
	reagents.add_reagent("lipozine", 15)

/obj/item/weapon/reagent_containers/pill/spaceacillin
	name = "Spaceacillin (10u)"
	desc = "Contains antiviral agents."
	icon_state = "pill3"

/obj/item/weapon/reagent_containers/pill/spaceacillin/atom_init()
	. = ..()
	reagents.add_reagent("spaceacillin", 15)

/obj/item/weapon/reagent_containers/pill/hyronalin
	name = "Hyronalin (7u)"
	desc = "Used to treat radiation poisoning."
	icon_state = "pill1"
/obj/item/weapon/reagent_containers/pill/hyronalin/atom_init()
	. = ..()
	reagents.add_reagent("hyronalin", 7)

/obj/item/weapon/reagent_containers/pill/antirad
	name = "AntiRad"
	desc = "Used to treat radiation poisoning."
	icon_state = "yellow"
/obj/item/weapon/reagent_containers/pill/antirad/atom_init()
	. = ..()
	reagents.add_reagent("hyronalin", 5)
	reagents.add_reagent("anti_toxin", 10)

/obj/item/weapon/reagent_containers/pill/adminordrazine
	name = "AB-X-7921 compound pill"
	desc = "Experimental chemical agent which is believed to completely heal a human being of any damage upon consumption."
	icon_state = "pillA"

/obj/item/weapon/reagent_containers/pill/adminordrazine/atom_init()
	. = ..()
	reagents.add_reagent("adminordrazine", 1)
