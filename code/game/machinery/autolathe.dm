/datum/autolathe_recipe
	var/name
	var/result_type
	var/metal_amount = 0
	var/glass_amount = 0

/datum/autolathe_recipe/stack
	var/max_res_amount = 50

/proc/path_to_ar(obj/path)
	var/obj/P = path
	var/amount = 1
	var/datum/autolathe_recipe/recipe
	if(ispath(path, /obj/item/stack))
		recipe = new /datum/autolathe_recipe/stack
		var/datum/autolathe_recipe/stack/S = recipe
		var/obj/item/stack/PS = path
		S.max_res_amount = initial(PS.max_amount)
	else
		recipe = new /datum/autolathe_recipe
		if(ispath(path, /obj/item/ammo_box))
			var/obj/item/ammo_box/ammobox = path
			amount = initial(ammobox.max_ammo)
			P = initial(ammobox.ammo_type)
	recipe.name = initial(path.name)
	recipe.result_type = path
	recipe.metal_amount = initial(P.m_amt) * amount
	recipe.glass_amount = initial(P.g_amt) * amount
	return recipe

#define R(path) path_to_ar(path)
var/global/list/datum/autolathe_recipe/autolathe_recipes = list(
	R(/obj/item/weapon/reagent_containers/glass/bucket),
	R(/obj/item/weapon/crowbar),
	R(/obj/item/device/flashlight),
	R(/obj/item/weapon/reagent_containers/spray/extinguisher),
	R(/obj/item/device/multitool),
	R(/obj/item/device/t_scanner),
	R(/obj/item/device/analyzer),
	R(/obj/item/device/plant_analyzer),
	R(/obj/item/device/healthanalyzer),
	R(/obj/item/weapon/weldingtool),
	R(/obj/item/weapon/screwdriver),
	R(/obj/item/weapon/wirecutters),
	R(/obj/item/weapon/wrench),
	R(/obj/item/clothing/head/welding),
	R(/obj/item/weapon/stock_parts/console_screen),
	R(/obj/item/weapon/airlock_electronics),
	R(/obj/item/weapon/airalarm_electronics),
	R(/obj/item/weapon/firealarm_electronics),
	R(/obj/item/weapon/module/power_control),
	R(/obj/item/stack/sheet/metal),
	R(/obj/item/stack/sheet/glass),
	R(/obj/item/stack/sheet/rglass),
	R(/obj/item/stack/rods),
	R(/obj/item/weapon/rcd_ammo),
	R(/obj/item/weapon/kitchenknife),
	R(/obj/item/weapon/scalpel),
	R(/obj/item/weapon/circular_saw),
	R(/obj/item/weapon/surgicaldrill),
	R(/obj/item/weapon/retractor),
	R(/obj/item/weapon/cautery),
	R(/obj/item/weapon/hemostat),
	R(/obj/item/weapon/reagent_containers/glass/beaker),
	R(/obj/item/weapon/reagent_containers/glass/beaker/large),
	R(/obj/item/weapon/reagent_containers/glass/beaker/vial),
	R(/obj/item/weapon/reagent_containers/syringe),
	R(/obj/item/ammo_box/eight_shells/beanbag),
	R(/obj/item/ammo_box/magazine/c45r),
	R(/obj/item/ammo_box/magazine/m9mm_2/rubber),
	R(/obj/item/device/taperecorder),
	R(/obj/item/device/assembly/igniter),
	R(/obj/item/device/assembly/signaler),
	R(/obj/item/device/radio/headset),
	R(/obj/item/device/assembly/voice),
	R(/obj/item/device/radio/off),
	R(/obj/item/device/assembly/infra),
	R(/obj/item/device/assembly/timer),
	R(/obj/item/device/assembly/prox_sensor),
	R(/obj/item/weapon/light/tube),
	R(/obj/item/weapon/light/bulb),
	R(/obj/item/ashtray/glass),
	R(/obj/item/weapon/camera_assembly),
	R(/obj/item/weapon/shovel),
	R(/obj/item/weapon/minihoe),
	R(/obj/item/weapon/hand_labeler),
	R(/obj/item/device/destTagger),
	R(/obj/item/toy/gun),
	R(/obj/item/toy/ammo/gun),
	R(/obj/item/weapon/game_kit/random),
	R(/obj/item/newscaster_frame),
	R(/obj/item/device/tabletop_assistant),
)

var/global/list/datum/autolathe_recipe/autolathe_recipes_hidden = list(
	R(/obj/item/weapon/flamethrower/full),
	R(/obj/item/weapon/rcd),
	R(/obj/item/device/radio/electropack),
	R(/obj/item/weapon/weldingtool/largetank),
	R(/obj/item/weapon/handcuffs),
	R(/obj/item/ammo_box/a357),
	R(/obj/item/ammo_box/magazine/c45m),
	R(/obj/item/ammo_box/magazine/m9mm_2),
	R(/obj/item/ammo_box/eight_shells),
	R(/obj/item/ammo_box/eight_shells/dart),
	R(/obj/item/ammo_box/eight_shells/buckshot),
	R(/obj/item/device/harmonica),
	R(/obj/item/weapon/bell),
)
#undef R
var/global/list/datum/autolathe_recipe/autolathe_recipes_all = autolathe_recipes + autolathe_recipes_hidden

/obj/machinery/autolathe
	name = "Autolathe"
	desc = "It produces items using metal and glass."
	icon_state = "autolathe"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	allowed_checks = ALLOWED_CHECK_TOPIC

	var/m_amount = 0.0
	var/max_m_amount = 150000.0

	var/g_amount = 0.0
	var/max_g_amount = 75000.0

	var/operating = 0.0

	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/datum/wires/autolathe/wires = null

	var/busy = 0
	var/prod_coeff

/obj/machinery/autolathe/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/autolathe(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

	wires = new(src)

/obj/machinery/autolathe/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/autolathe/RefreshParts()
	..()
	var/tot_rating = 0
	prod_coeff = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		tot_rating += MB.rating
	tot_rating *= 25000
	max_m_amount = tot_rating * 3
	max_g_amount = tot_rating * 3
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		prod_coeff += M.rating - 1

/obj/machinery/autolathe/ui_interact(mob/user)
	if(disabled)
		return

	var/coeff = 2 ** prod_coeff
	var/dat

	dat = "<B>Metal Amount:</B> [m_amount] cm<sup>3</sup> (MAX: [max_m_amount])<BR>\n<span class='blue'><B>Glass Amount:</B></span> [g_amount] cm<sup>3</sup> (MAX: [max_g_amount])<HR>"
	dat += "<div class='Section'>"
	dat += "<table>"
	var/list/datum/autolathe_recipe/recipes

	if(hacked)
		recipes = autolathe_recipes_all
	else
		recipes = autolathe_recipes

	for(var/datum/autolathe_recipe/r in recipes)
		dat += "<tr>"
		dat += {"<td><span class="autolathe32x32 [replacetext(replacetext("[r.result_type]", "[/obj/item]/", ""), "/", "-")]"></span></td>"}
		dat += "<td>"
		if(istype(r, /datum/autolathe_recipe/stack))
			var/title = "[r.name] ([r.metal_amount] m /[r.glass_amount] g)"
			if(m_amount < r.metal_amount || g_amount < r.glass_amount)
				dat += title
				continue
			dat += "<A href='?src=\ref[src];make=\ref[r]'>[title]</A>"

			var/datum/autolathe_recipe/stack/S = r
			var/max_multiplier = min(S.max_res_amount, S.metal_amount ? round(m_amount / S.metal_amount) : INFINITY, S.glass_amount ? round(g_amount / S.glass_amount) : INFINITY)
			if(max_multiplier > 1)
				dat += " |"
			if(max_multiplier > 10)
				dat += " <A href='?src=\ref[src];make=\ref[r];multiplier=[10]'>x[10]</A>"
			if(max_multiplier > 25)
				dat += " <A href='?src=\ref[src];make=\ref[r];multiplier=[25]'>x[25]</A>"
			if(max_multiplier > 1)
				dat += " <A href='?src=\ref[src];make=\ref[r];multiplier=[max_multiplier]'>x[max_multiplier]</A>"
		else
			var/title = "[r.name] ([r.metal_amount / coeff] m /[r.glass_amount / coeff] g)"
			if(m_amount < r.metal_amount / coeff || g_amount < r.glass_amount / coeff)
				dat += title
				continue
			dat += "<A href='?src=\ref[src];make=\ref[r]'>[title]</A>"
		dat += "</td>"
		dat += "</tr>"
	dat += "</table>"
	dat += "</div>"

	var/datum/browser/popup = new(user, "window=autolathe_regular", "Autolathe")
	popup.add_stylesheet(get_asset_datum(/datum/asset/spritesheet/autolathe))
	popup.set_content(dat)
	popup.open()


/obj/machinery/autolathe/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

/obj/machinery/autolathe/interact(mob/user)
	if(shocked && !issilicon(user) && !isobserver(user))
		shock(user,50)
	if(disabled)
		to_chat(user, "<span class='warning'>You press the button, but nothing happens.</span>")
		return
	..()

/obj/machinery/autolathe/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/pai_cable))
		return
	if(busy)
		to_chat(user, "<span class='warning'>The autolathe is busy. Please wait for completion of previous operation.</span>")
		return 1

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", I))
		updateUsrDialog()
		return

	if(exchange_parts(user, I))
		return

	if(panel_open)
		if(iscrowbar(I))
			if(m_amount >= 3750)
				new /obj/item/stack/sheet/metal(loc, round(m_amount / 3750))
			if(g_amount >= 3750)
				new /obj/item/stack/sheet/glass(loc, round(g_amount / 3750))
			default_deconstruction_crowbar(I)
			return 1
		else if(is_wire_tool(I))
			wires.interact(user)
			return 1

	if(stat)
		return 1

	var/amount = 1
	var/obj/item/stack/stack
	var/m_amt = I.m_amt
	var/g_amt = I.g_amt
	if(istype(I, /obj/item/stack))
		stack = I
		amount = stack.get_amount()
		if(m_amt)
			amount = min(amount, round((max_m_amount - m_amount) / m_amt))
			flick("autolathe_o",src)//plays metal insertion animation
		if(g_amt)
			amount = min(amount, round((max_g_amount - g_amount) / g_amt))
			flick("autolathe_r",src)//plays glass insertion animation
	else if(istype(I, /obj/item/ammo_box))
		m_amt = 0
		g_amt = 0
		var/obj/item/ammo_box/ammobox = I
		if(ammobox.stored_ammo.len)
			for(var/obj/item/ammo_casing/ammo_type in ammobox.stored_ammo)
				m_amt += ammo_type.m_amt
				g_amt += ammo_type.g_amt
	m_amt *= amount
	g_amt *= amount

	if((m_amount + m_amt > max_m_amount) || (g_amount + g_amt > max_g_amount))
		to_chat(user, "<span class='warning'>The autolathe is full. Please remove metal from the autolathe in order to insert more.</span>")
		return 1
	if(m_amt == 0 && g_amt == 0)
		to_chat(user, "<span class='warning'>This object does not contain significant amounts of metal or glass, or cannot be accepted by the autolathe due to size or hazardous materials.</span>")
		return 1

	take_item(I, amount)
	icon_state = "autolathe"
	busy = 1
	use_power(max(1000, (m_amt + g_amt) * amount / 10))
	m_amount += m_amt
	g_amount += g_amt
	to_chat(user, "You insert [amount] sheet[amount>1 ? "s" : ""] to the autolathe.")
	if(I && I.loc == src)
		qdel(I)
	busy = 0
	updateUsrDialog()

/obj/machinery/autolathe/proc/take_item(obj/item/I, amount)
	if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I
		S.use(amount)
	else
		usr.remove_from_mob(I)
		I.loc = src

/obj/machinery/autolathe/Topic(href, href_list)
	if(!istype(usr, /mob/living/silicon/pai))
		. = ..()
		if(!.)
			return
	else
		var/mob/living/silicon/pai/TempUsr = usr
		if(TempUsr.hackobj != src)
			return
	if(busy)
		to_chat(usr, "<span class='warning'>The autolathe is busy. Please wait for completion of previous operation.</span>")
		return FALSE

	if(href_list["make"])
		var/coeff = 2 ** prod_coeff
		var/turf/T = get_turf(src)
		// critical exploit fix start -walter0o
		var/datum/autolathe_recipe/recipe = locate(href_list["make"])

		if(!istype(recipe))
			return FALSE

		var/list/datum/autolathe_recipe/recipes

		if(hacked)
			recipes = autolathe_recipes_all
		else
			recipes = autolathe_recipes

		if(!locate(recipe, recipes))
			return FALSE

		// now check for legit multiplier, also only stacks should pass with one to prevent raw-materials-manipulation -walter0o

		var/multiplier = text2num(href_list["multiplier"])

		if(!multiplier) multiplier = 1
		var/max_multiplier = 1

		if(istype(recipe, /datum/autolathe_recipe/stack)) // stacks are the only items which can have a multiplier higher than 1 -walter0o
			var/datum/autolathe_recipe/stack/S = recipe
			max_multiplier = min(S.max_res_amount, S.metal_amount ? round(m_amount / S.metal_amount) : INFINITY, S.glass_amount ? round(g_amount / S.glass_amount) : INFINITY)

		if((multiplier > max_multiplier) || (multiplier <= 0)) // somebody is trying to exploit, alert admins-walter0o

			var/turf/LOC = get_turf(usr)
			message_admins("[key_name_admin(usr)] tried to exploit an autolathe with multiplier set to <u>[multiplier]</u> on <u>[recipe]</u>  ! ([LOC ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[LOC.x];Y=[LOC.y];Z=[LOC.z]'>JMP</a>" : "null"])" , 0)
			log_admin("EXPLOIT : [key_name(usr)] tried to exploit an autolathe with multiplier set to [multiplier] on [recipe]  !")
			return FALSE

		var/power = max(2000, (recipe.metal_amount + recipe.glass_amount) * multiplier / 5)
		if(m_amount >= recipe.metal_amount * multiplier / coeff && g_amount >= recipe.glass_amount * multiplier / coeff)
			busy = 1
			use_power(power)
			icon_state = "autolathe"
			flick("autolathe_n",src)
			spawn(32/coeff)
				if(istype(recipe, /datum/autolathe_recipe/stack))
					m_amount -= recipe.metal_amount * multiplier
					g_amount -= recipe.glass_amount * multiplier
					var/obj/new_item = new recipe.result_type(T)
					var/obj/item/stack/S = new_item
					S.set_amount(multiplier)
				else
					m_amount -= recipe.metal_amount / coeff
					g_amount -= recipe.glass_amount / coeff
					var/obj/new_item = new recipe.result_type(T)
					new_item.m_amt /= coeff
					new_item.g_amt /= coeff
				if(m_amount < 0)
					m_amount = 0
				if(g_amount < 0)
					g_amount = 0
				busy = 0
	src.updateUsrDialog()
