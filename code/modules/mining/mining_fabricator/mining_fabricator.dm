/obj/machinery/mecha_part_fabricator/mining_fabricator
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	name = "Mining fabricator"
	desc = "Nothing is being built."
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	active_power_usage = 25000
	req_access = list(access_mining)
	build_type = MINEFAB
	allowed_checks = ALLOWED_CHECK_TOPIC
	resources = list(
						MAT_METAL=0,
						MAT_GLASS=0,
						MAT_DIAMOND=0,
						MAT_GOLD=0,
						MAT_PHORON=0,
						MAT_SILVER=0,
						MAT_URANIUM=0,
						MAT_PLASTIC=0
						)
	part_sets = list(
						"Spacesuit",
						"Tools",
						"Support",
						"Misc"
						)

/obj/machinery/mecha_part_fabricator/mining_fabricator/New_parts()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/minefab(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()


/obj/machinery/mecha_part_fabricator/mining_fabricator/update_queue_on_page()
	send_byjax(usr,"mine_fabricator.browser","queue",list_queue())
	return


/obj/machinery/mecha_part_fabricator/mining_fabricator/interact(mob/user)
	var/dat, left_part
	user.set_machine(src)
	var/turf/exit = get_step(src,(dir))
	if(exit.density)
		visible_message("[bicon(src)] <b>\The [src]</b> beeps, \"Error! Part outlet is obstructed.\"")
		return
	if(temp)
		left_part = temp
	else if(being_built)
		var/obj/I = being_built.build_path
		left_part = {"<TT>Building [initial(I.name)].<BR>
							Please wait until completion...</TT>"}
	else
		switch(screen)
			if("main")
				left_part = output_available_resources()+"<hr>"
				left_part += "<a href='?src=\ref[src];sync=1'>Sync with R&D servers</a><hr>"
				for(var/part_set in part_sets)
					left_part += "<a href='?src=\ref[src];part_set=[part_set]'>[part_set]</a> - \[<a href='?src=\ref[src];partset_to_queue=[part_set]'>Add all parts to queue\]<br>"
			if("parts")
				left_part += output_parts_list(part_set)
				left_part += "<hr><a href='?src=\ref[src];screen=main'>Return</a>"
	dat = {"<html>
			  <head>
			  <title>[name]</title>
				<style>
				.res_name {font-weight: bold; text-transform: capitalize;}
				.red {color: #f00;}
				.part {margin-bottom: 10px;}
				.arrow {text-decoration: none; font-size: 10px;}
				body, table {height: 100%;}
				td {vertical-align: top; padding: 5px;}
				html, body {padding: 0px; margin: 0px;}
				h1 {font-size: 18px; margin: 5px 0px;}
				</style>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				</script>
				</head><body>
				<body>
				<table style='width: 100%;'>
				<tr>
				<td style='width: 65%; padding-right: 10px;'>
				[left_part]
				</td>
				<td style='width: 35%; background: #ccc;' id='queue'>
				[list_queue()]
				</td>
				<tr>
				</table>
				</body>
				</html>"}
	user << browse(dat, "window=mine_fabricator;size=1000x430")
	onclose(user, "mine_fabricator")
	return


/obj/machinery/mecha_part_fabricator/mining_fabricator/remove_material(mat_string, amount)
	if(resources[mat_string] < MINERAL_MATERIAL_AMOUNT) //not enough mineral for a sheet
		return -1
	var/type
	switch(mat_string)
		if(MAT_METAL)
			type = /obj/item/stack/sheet/metal
		if(MAT_GLASS)
			type = /obj/item/stack/sheet/glass
		if(MAT_GOLD)
			type = /obj/item/stack/sheet/mineral/gold
		if(MAT_SILVER)
			type = /obj/item/stack/sheet/mineral/silver
		if(MAT_DIAMOND)
			type = /obj/item/stack/sheet/mineral/diamond
		if(MAT_PHORON)
			type = /obj/item/stack/sheet/mineral/phoron
		if(MAT_URANIUM)
			type = /obj/item/stack/sheet/mineral/uranium
		if(MAT_PLASTIC)
			type = /obj/item/stack/sheet/mineral/plastic
		else
			return 0
	var/result = 0

	while(amount > 50)
		new type(get_turf(src),50)
		amount -= 50
		result += 50
		resources[mat_string] -= 50 * MINERAL_MATERIAL_AMOUNT

	var/total_amount = round(resources[mat_string]/MINERAL_MATERIAL_AMOUNT)
	if(total_amount)//if there's still enough material for sheets
		var/obj/item/stack/sheet/res = new type(get_turf(src),min(amount,total_amount))
		resources[mat_string] -= res.get_amount()*MINERAL_MATERIAL_AMOUNT
		result += res.get_amount()

	return result


/obj/machinery/mecha_part_fabricator/mining_fabricator/attackby(obj/W, mob/user, params)

	if(default_deconstruction_screwdriver(user, "fab-o", "fab-idle", W))
		return

	if(exchange_parts(user, W))
		return

	if(panel_open)
		if(iscrowbar(W))
			for(var/material in resources)
				remove_material(material, resources[material]/MINERAL_MATERIAL_AMOUNT)
			default_deconstruction_crowbar(W)
			return 1
		else
			to_chat(user, "<span class='warning'>You can't load \the [name] while it's opened!</span>")
			return 1

	if(istype(W, /obj/item/stack))
		var/material
		switch(W.type)
			if(/obj/item/stack/sheet/mineral/gold)
				material = MAT_GOLD
			if(/obj/item/stack/sheet/mineral/silver)
				material = MAT_SILVER
			if(/obj/item/stack/sheet/mineral/diamond)
				material = MAT_DIAMOND
			if(/obj/item/stack/sheet/mineral/phoron)
				material = MAT_PHORON
			if(/obj/item/stack/sheet/metal)
				material = MAT_METAL
			if(/obj/item/stack/sheet/glass)
				material = MAT_GLASS
			if(/obj/item/stack/sheet/mineral/uranium)
				material = MAT_URANIUM
			if(/obj/item/stack/sheet/mineral/plastic)
				material = MAT_PLASTIC
			else
				return ..()

		if(being_built)
			to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
			return
		if(res_max_amount - resources[material] < MINERAL_MATERIAL_AMOUNT) //overstuffing the fabricator
			to_chat(user, "<span class='warning'>\The [src] [material2name(material)] storage is full!</span>")
			return
		var/obj/item/stack/sheet/stack = W
		var/sname = "[stack.name]"
		if(resources[material] < res_max_amount)
			add_overlay("fab-load-[material2name(material)]")//loading animation is now an overlay based on material type. No more spontaneous conversion of all ores to metal. -vey

			var/transfer_amount = min(stack.get_amount(), round((res_max_amount - resources[material])/MINERAL_MATERIAL_AMOUNT,1))
			resources[material] += transfer_amount * MINERAL_MATERIAL_AMOUNT
			stack.use(transfer_amount)
			to_chat(user, "<span class='notice'>You insert [transfer_amount] [sname] sheet\s into \the [src].</span>")
			sleep(10)
			updateUsrDialog()
			cut_overlay("fab-load-[material2name(material)]") //No matter what the overlay shall still be deleted
		else
			to_chat(user, "<span class='warning'>\The [src] cannot hold any more [sname] sheet\s!</span>")
		return
