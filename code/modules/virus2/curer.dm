/obj/machinery/computer/curer
	name = "Cure Research Machine"
	icon = 'icons/obj/computer.dmi'
	icon_state = "dna"
	state_broken_preset = "crewb"
	state_nopower_preset = "crew0"
	circuit = /obj/item/weapon/circuitboard/curefab
	var/curing
	var/virusing

	var/obj/item/weapon/reagent_containers/container = null
	required_skills = list(/datum/skill/chemistry = SKILL_LEVEL_TRAINED, /datum/skill/research = SKILL_LEVEL_TRAINED, /datum/skill/medical = SKILL_LEVEL_PRO)

/obj/machinery/computer/curer/attackby(obj/I, mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers))
		var/mob/living/carbon/C = user
		if(!container)
			container = I
			C.drop_from_inventory(I, src)
		return

	if(istype(I, /obj/item/weapon/virusdish))
		if(virusing)
			to_chat(user, "<b>The pathogen materializer is still recharging..</b>")
			return
		if(!do_skill_checks(user))
			return
		var/obj/item/weapon/reagent_containers/glass/beaker/product = new(src.loc)

		var/obj/item/weapon/virusdish/Vd = I
		var/list/data = list("virus2" = virus_copylist(Vd.virus2))
		product.reagents.add_reagent("blood", 30, data)

		virusing = TRUE
		VARSET_IN(src, virusing, FALSE, 1200)

		state("The [src.name] Buzzes", "blue")
		return

	return ..()

/obj/machinery/computer/curer/ui_interact(mob/user)
	var/dat
	if(curing)
		dat = "Antibody production in progress"
	else if(virusing)
		dat = "Virus production in progress"
	else if(container)
		// see if there's any blood in the container
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in container.reagents.reagent_list

		if(B)
			dat = "Blood sample inserted."
			var/code = ""
			for(var/V in ANTIGENS)
				if(text2num(V) & B.data["antibodies"])
					code += ANTIGENS[V]
					dat += "<BR>Antibodies: [code]"
					dat += "<BR><A href='?src=\ref[src];antibody=1'>Begin antibody production</a>"
		else
			dat += "<BR>Please check container contents."
		dat += "<BR><A href='?src=\ref[src];eject=1'>Eject container</a>"
	else
		dat = "Please insert a container."

	var/datum/browser/popup = new(user, "computer", "[src.name]", 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/curer/process()
	..()

	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)

	if(curing)
		curing -= 1
		if(curing == 0)
			if(container)
				createcure(container)
	return

/obj/machinery/computer/curer/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if (href_list["antibody"])
		curing = 10
	else if(href_list["eject"])
		container.loc = src.loc
		container = null

	updateUsrDialog()


/obj/machinery/computer/curer/proc/createcure(obj/item/weapon/reagent_containers/container)
	var/obj/item/weapon/reagent_containers/glass/beaker/product = new(src.loc)

	var/datum/reagent/blood/B = locate() in container.reagents.reagent_list

	var/list/data = list()
	data["antibodies"] = B.data["antibodies"]
	product.reagents.add_reagent("antibodies",30,data)

	state("\The [src.name] buzzes", "blue")
