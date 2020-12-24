/obj/structure/cult/tech_table
	name = "scientific altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "talismanaltar"
	light_color = "#2f0e0e"
	light_power = 2
	light_range = 3

	var/images_gen = FALSE
	var/static/list/aspects_image
	var/researching = FALSE
	var/research_time = 20 MINUTES
	var/end_research_time

/obj/structure/cult/tech_table/Destroy()
	QDEL_LIST_ASSOC(aspects_image)
	return ..()

/obj/structure/cult/tech_table/examine(mob/user, distance)
	..()
	if(!user.mind.holy_role || !user.my_religion || user.my_religion.aspects.len == 0)
		return

	to_chat(user, "<span class='notice'>Aspects and his power in your religion:</span>")
	for(var/name in user.my_religion.aspects)
		var/datum/aspect/A = user.my_religion.aspects[name]
		to_chat(user, "\t<font color='[A.color]'>[name]</font> with power of <font size='[1+A.power]'><i>[A.power]</i></font>")

/obj/structure/cult/tech_table/attack_hand(mob/living/user)
	if(!user.mind.holy_role || !user.my_religion)
		return

	if(researching)
		to_chat(user, "<span class='warning'>There are [round((end_research_time - world.time) * 0.1)] seconds left until the end of studying the aspect.</span>")
		return

	if(!images_gen)
		to_chat(user, "<span class='notice'>The forge was set up.</span>")
		gen_images()
		images_gen = TRUE

	// Generates a name with the power of an aspect and upgrade cost
	for(var/datum/aspect/A in aspects_image)
		var/datum/aspect/in_religion = user.my_religion.aspects[initial(A.name)]
		A.name = "[initial(A.name)], power: [in_religion ? in_religion.power : "0"], upgrade piety cost: [get_upgrade_cost(in_religion)]"

	var/datum/aspect/choosed_aspect = show_radial_menu(user, src, aspects_image, tooltips = TRUE, require_near = TRUE)
	if(!choosed_aspect)
		return
	var/datum/aspect/in_religion = user.my_religion.aspects[initial(choosed_aspect.name)]
	if(!user.my_religion.check_costs(null, get_upgrade_cost(in_religion), user))
		return

	to_chat(user, "<span class='notice'>You started to [in_religion ? "upgrade" : "explore"] the [initial(choosed_aspect.name)].</span>")

	researching = TRUE
	end_research_time = world.time + research_time
	addtimer(CALLBACK(src, .proc/upgrade_aspect, user.my_religion, choosed_aspect), research_time)

/obj/structure/cult/tech_table/proc/upgrade_aspect(datum/religion/R, datum/aspect/aspect_to_upgrade)
	if(initial(aspect_to_upgrade.name) in R)
		var/datum/aspect/A = R.aspects[initial(aspect_to_upgrade.name)]
		A.power += 1
	else
		R.add_aspects(list(aspect_to_upgrade.type = 1))

	researching = FALSE

/obj/structure/cult/tech_table/proc/get_upgrade_cost(datum/aspect/in_religion)
	if(!in_religion)
		return 300
	else
		return in_religion.power * 50

/obj/structure/cult/tech_table/proc/gen_images()
	var/list/aspects = subtypesof(/datum/aspect)
	aspects_image = list()
	for(var/type in aspects)
		var/datum/aspect/A = new type
		if(!A.name)
			qdel(A)
			continue
		aspects_image[A] = image(icon = A.icon, icon_state = A.icon_state)
