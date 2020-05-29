//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/global/list/autolathe_recipes = list( \
		/* screwdriver removed*/ \
		new /obj/item/weapon/reagent_containers/glass/bucket(), \
		new /obj/item/weapon/crowbar(), \
		new /obj/item/device/flashlight(), \
		new /obj/item/weapon/reagent_containers/spray/extinguisher(), \
		new /obj/item/device/multitool(), \
		new /obj/item/device/t_scanner(), \
		new /obj/item/device/analyzer(), \
		new /obj/item/device/plant_analyzer(), \
		new /obj/item/device/healthanalyzer(), \
		new /obj/item/weapon/weldingtool(), \
		new /obj/item/weapon/screwdriver(), \
		new /obj/item/weapon/wirecutters(), \
		new /obj/item/weapon/wrench(), \
		new /obj/item/clothing/head/welding(), \
		new /obj/item/weapon/stock_parts/console_screen(), \
		new /obj/item/weapon/airlock_electronics(), \
		new /obj/item/weapon/airalarm_electronics(), \
		new /obj/item/weapon/firealarm_electronics(), \
		new /obj/item/weapon/module/power_control(), \
		new /obj/item/stack/sheet/metal(), \
		new /obj/item/stack/sheet/glass(), \
		new /obj/item/stack/sheet/rglass(), \
		new /obj/item/stack/rods(), \
		new /obj/item/weapon/rcd_ammo(), \
		new /obj/item/weapon/kitchenknife(), \
		new /obj/item/weapon/scalpel(), \
		new /obj/item/weapon/circular_saw(), \
		new /obj/item/weapon/surgicaldrill(),\
		new /obj/item/weapon/retractor(),\
		new /obj/item/weapon/cautery(),\
		new /obj/item/weapon/hemostat(),\
		new /obj/item/weapon/reagent_containers/glass/beaker(), \
		new /obj/item/weapon/reagent_containers/glass/beaker/large(), \
		new /obj/item/weapon/reagent_containers/glass/beaker/vial(), \
		new /obj/item/weapon/reagent_containers/syringe(), \
		new /obj/item/ammo_casing/shotgun/beanbag(), \
		new /obj/item/ammo_box/c45r(), \
		new /obj/item/ammo_box/c9mmr(), \
		new /obj/item/device/taperecorder(), \
		new /obj/item/device/assembly/igniter(), \
		new /obj/item/device/assembly/signaler(), \
		new /obj/item/device/radio/headset(), \
		new /obj/item/device/assembly/voice(), \
		new /obj/item/device/radio/off(), \
		new /obj/item/device/assembly/infra(), \
		new /obj/item/device/assembly/timer(), \
		new /obj/item/device/assembly/prox_sensor(), \
		new /obj/item/weapon/light/tube(), \
		new /obj/item/weapon/light/bulb(), \
		new /obj/item/ashtray/glass(), \
		new /obj/item/weapon/camera_assembly(), \
		new /obj/item/weapon/shovel(), \
		new /obj/item/weapon/minihoe(), \
		new /obj/item/weapon/hand_labeler(), \
		new /obj/item/device/destTagger(), \
		new /obj/item/toy/gun(), \
		new /obj/item/toy/ammo/gun(), \
		new /obj/item/weapon/game_kit/random(), \
		new /obj/item/newscaster_frame(),
		new /obj/item/device/tabletop_assistant()
	)

var/global/list/autolathe_recipes_hidden = list( \
		new /obj/item/weapon/flamethrower/full(), \
		new /obj/item/weapon/rcd(), \
		new /obj/item/device/radio/electropack(), \
		new /obj/item/weapon/weldingtool/largetank(), \
		new /obj/item/weapon/handcuffs(), \
		new /obj/item/ammo_box/a357(), \
		new /obj/item/ammo_box/c45(), \
		new /obj/item/ammo_box/c9mm(), \
		new /obj/item/ammo_casing/shotgun(), \
		new /obj/item/ammo_casing/shotgun/dart(), \
		new /obj/item/ammo_casing/shotgun/buckshot(), \
		new /obj/item/device/harmonica(), \
		new /obj/item/weapon/bell()
	)

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

	var/list/L
	var/list/LL
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

	L = autolathe_recipes
	LL = autolathe_recipes_hidden

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

	dat = "<B>Metal Amount:</B> [src.m_amount] cm<sup>3</sup> (MAX: [max_m_amount])<BR>\n<FONT color='#24b6bbff'><B>Glass Amount:</B></FONT> [src.g_amount] cm<sup>3</sup> (MAX: [max_g_amount])<HR>"
	dat += "<div class='statusDisplay'>"
	dat += "<table>"
	var/list/objs = list()
	objs += src.L
	if (src.hacked)
		objs += src.LL
	for(var/obj/t in objs)
		dat += "<tr>"
		dat += {"<td><span class="autolathe32x32 [replacetext(replacetext("[t.type]", "/obj/item/", ""), "/", "-")]"></span></td>"}
		dat += "<td>"
		if (istype(t, /obj/item/stack))
			var/title = "[t.name] ([t.m_amt] m /[t.g_amt] g)"
			if (m_amount<t.m_amt || g_amount<t.g_amt)
				dat += title
				continue
			dat += "<A href='?src=\ref[src];make=\ref[t]'>[title]</A>"

			var/obj/item/stack/S = t
			var/max_multiplier = min(S.max_amount, S.m_amt?round(m_amount/S.m_amt):INFINITY, S.g_amt?round(g_amount/S.g_amt):INFINITY)
			if (max_multiplier>1)
				dat += " |"
			if (max_multiplier>10)
				dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[10]'>x[10]</A>"
			if (max_multiplier>25)
				dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[25]'>x[25]</A>"
			if (max_multiplier>1)
				dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[max_multiplier]'>x[max_multiplier]</A>"
		else
			var/title = "[t.name] ([t.m_amt/coeff] m /[t.g_amt/coeff] g)"
			if (m_amount<t.m_amt/coeff || g_amount<t.g_amt/coeff)
				dat += title
				continue
			dat += "<A href='?src=\ref[src];make=\ref[t]'>[title]</A>"
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
	if (electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

/obj/machinery/autolathe/interact(mob/user)
	if (shocked && !issilicon(user) && !isobserver(user))
		shock(user,50)
	if (disabled)
		to_chat(user, "<span class='warning'>You press the button, but nothing happens.</span>")
		return
	..()

/obj/machinery/autolathe/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/pai_cable))
		return
	if (busy)
		to_chat(user, "<span class='warning'>The autolathe is busy. Please wait for completion of previous operation.</span>")
		return 1

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", I))
		updateUsrDialog()
		return

	if(exchange_parts(user, I))
		return

	if (panel_open)
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

	if (stat)
		return 1

	if (src.m_amount + I.m_amt > max_m_amount)
		to_chat(user, "<span class='warning'>The autolathe is full. Please remove metal from the autolathe in order to insert more.</span>")
		return 1
	if (src.g_amount + I.g_amt > max_g_amount)
		to_chat(user, "<span class='warning'>The autolathe is full. Please remove glass from the autolathe in order to insert more.</span>")
		return 1
	if (I.m_amt == 0 && I.g_amt == 0)
		to_chat(user, "<span class='warning'>This object does not contain significant amounts of metal or glass, or cannot be accepted by the autolathe due to size or hazardous materials.</span>")
		return 1

	var/amount = 1
	var/obj/item/stack/stack
	var/m_amt = I.m_amt
	var/g_amt = I.g_amt
	if (istype(I, /obj/item/stack))
		stack = I
		amount = stack.get_amount()
		if (m_amt)
			amount = min(amount, round((max_m_amount-src.m_amount)/m_amt))
			flick("autolathe_o",src)//plays metal insertion animation
		if (g_amt)
			amount = min(amount, round((max_g_amount-src.g_amount)/g_amt))
			flick("autolathe_r",src)//plays glass insertion animation
		stack.use(amount)
	else
		usr.remove_from_mob(I)
		I.loc = src
	icon_state = "autolathe"
	busy = 1
	use_power(max(1000, (m_amt+g_amt)*amount/10))
	src.m_amount += m_amt * amount
	src.g_amount += g_amt * amount
	to_chat(user, "You insert [amount] sheet[amount>1 ? "s" : ""] to the autolathe.")
	if (I && I.loc == src)
		qdel(I)
	busy = 0
	src.updateUsrDialog()

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
		var/obj/item/template = null
		var/attempting_to_build = locate(href_list["make"])

		if(!attempting_to_build)
			return FALSE

		if(locate(attempting_to_build, src.L) || locate(attempting_to_build, src.LL)) // see if the requested object is in one of the construction lists, if so, it is legit -walter0o
			template = attempting_to_build

		else // somebody is trying to exploit, alert admins -walter0o

			var/turf/LOC = get_turf(usr)
			message_admins("[key_name_admin(usr)] tried to exploit an autolathe to duplicate <a href='?_src_=vars;Vars=\ref[attempting_to_build]'>[attempting_to_build]</a> ! ([LOC ? "[ADMIN_JMP(LOC)]" : "null"])", 0)
			log_admin("EXPLOIT : [key_name(usr)] tried to exploit an autolathe to duplicate [attempting_to_build] !")
			return FALSE

		// now check for legit multiplier, also only stacks should pass with one to prevent raw-materials-manipulation -walter0o

		var/multiplier = text2num(href_list["multiplier"])

		if (!multiplier) multiplier = 1
		var/max_multiplier = 1

		if(istype(template, /obj/item/stack)) // stacks are the only items which can have a multiplier higher than 1 -walter0o
			var/obj/item/stack/S = template
			max_multiplier = min(S.max_amount, S.m_amt?round(m_amount/S.m_amt):INFINITY, S.g_amt?round(g_amount/S.g_amt):INFINITY)  // pasta from regular_win() to make sure the numbers match -walter0o

		if( (multiplier > max_multiplier) || (multiplier <= 0) ) // somebody is trying to exploit, alert admins-walter0o

			var/turf/LOC = get_turf(usr)
			message_admins("[key_name_admin(usr)] tried to exploit an autolathe with multiplier set to <u>[multiplier]</u> on <u>[template]</u>  ! ([LOC ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[LOC.x];Y=[LOC.y];Z=[LOC.z]'>JMP</a>" : "null"])" , 0)
			log_admin("EXPLOIT : [key_name(usr)] tried to exploit an autolathe with multiplier set to [multiplier] on [template]  !")
			return FALSE

		var/power = max(2000, (template.m_amt+template.g_amt)*multiplier/5)
		if(src.m_amount >= template.m_amt*multiplier/coeff && src.g_amount >= template.g_amt*multiplier/coeff)
			busy = 1
			use_power(power)
			icon_state = "autolathe"
			flick("autolathe_n",src)
			spawn(32/coeff)
				if(istype(template, /obj/item/stack))
					src.m_amount -= template.m_amt*multiplier
					src.g_amount -= template.g_amt*multiplier
					var/obj/new_item = new template.type(T)
					var/obj/item/stack/S = new_item
					S.set_amount(multiplier)
				else
					src.m_amount -= template.m_amt/coeff
					src.g_amount -= template.g_amt/coeff
					var/obj/new_item = new template.type(T)
					new_item.m_amt /= coeff
					new_item.g_amt /= coeff
				if(src.m_amount < 0)
					src.m_amount = 0
				if(src.g_amount < 0)
					src.g_amount = 0
				busy = 0
	src.updateUsrDialog()
