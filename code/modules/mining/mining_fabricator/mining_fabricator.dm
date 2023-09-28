/obj/machinery/mecha_part_fabricator/mining_fabricator
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab"
	name = "Mining fabricator"
	desc = "Nothing is being built."
	density = TRUE
	anchored = TRUE
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
	required_skills = list(/datum/skill/research = SKILL_LEVEL_NOVICE)

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
			  <meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
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
