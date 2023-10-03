
/obj/machinery/replicator
	name = "alien machine"
	desc = "It's some kind of pod with strange wires and gadgets all over it."
	icon = 'icons/obj/xenoarchaeology/artifacts.dmi'
	icon_state = "replicator"
	density = TRUE

	idle_power_usage = 100
	active_power_usage = 1000
	use_power = IDLE_POWER_USE
	interact_offline = TRUE

	var/spawn_progress_time = 0
	var/max_spawn_time = 50
	var/last_process_time = 0

	var/list/construction = list()
	var/list/spawning_types = list()
	var/list/stored_materials = list()

	var/fail_message

/obj/machinery/replicator/atom_init()
	. = ..()

	var/list/viables = list(
	/obj/random/plushie,
	/obj/random/vending/snack,
	/obj/random/vending/cola,
	/obj/random/randomfigure,
	/obj/random/randomtoy,
	/obj/random/pouch,
	/obj/random/cloth/head,
	/obj/random/cloth/hazmatsuit,
	/obj/random/cloth/shittysuit,
	/obj/random/cloth/storagesuit,
	/obj/random/cloth/spacesuit,
	/obj/random/cloth/armor,
	/obj/random/cloth/under,
	/obj/random/cloth/tie,
	/obj/random/cloth/shoes_safe,
	/obj/random/cloth/glasses_safe,
	/obj/random/cloth/gloves_safe,
	/obj/random/cloth/masks,
	/obj/random/cloth/backpack,
	/obj/random/cloth/belt,
	/obj/random/cloth/under,
	/obj/random/cloth/tie,
	/obj/random/cloth/ny_random_cloth,
	/obj/random/foods/drink_can,
	/obj/random/foods/food_snack,
	/obj/random/foods/ramens,
	/obj/random/foods/drink_bottle,
	/obj/random/foods/donuts,
	/obj/random/guns/set_9mm,
	/obj/random/meds/medical_single_item,
	/obj/random/meds/syringe,
	/obj/random/meds/chemical_bottle,
	/obj/random/meds/medkit,
	/obj/random/meds/medical_tool,
	/obj/random/meds/pills,
	/obj/random/meds/dna_injector,
	/obj/random/mobs/peacefull,
	/obj/random/mobs/moderate,
	/obj/random/mobs/dangerous,
	/obj/random/structures/common_crates,
	/obj/random/structures/vendings,
	/obj/random/structures/misc,
	/obj/random/tools/powercell,
	/obj/random/tools/technology_scanner,
	/obj/random/tools/bomb_supply,
	/obj/random/tools/toolbox,
	/obj/random/tools/tool,
	/obj/random/misc/toy,
	/obj/random/misc/lighters,
	/obj/random/misc/smokes,
	/obj/random/misc/storage,
	/obj/random/misc/book,
	/obj/random/misc/musical,
	/obj/random/misc/disk,
	/obj/random/tools/tech_supply/guaranteed,
	/obj/random/foods/food_without_garbage,
	/obj/random/science/bomb_supply,
	/obj/random/science/slimecore,
	/obj/random/science/circuit,
	/obj/random/science/stock_part,
	/obj/random/science/common_circuit
	)

	var/quantity = rand(5,15)
	for (var/i in 1 to quantity)
		var/button_desc = "a [pick("yellow", "purple", "green", "blue", "red", "orange", "white")], "
		button_desc += "[pick("round", "square", "diamond", "heart", "dog", "human")] shaped "
		button_desc += "[pick("toggle", "switch", "lever", "button", "pad", "hole")]"
		construction[button_desc] = PATH_OR_RANDOM_PATH(pick_n_take(viables))

	fail_message = "<span class='notice'>[bicon(src)] a [pick("loud", "soft", "sinister", "eery", "triumphant", "depressing", "cheerful", "angry")] \
		[pick("horn", "beep", "bing", "bleep", "blat", "honk", "hrumph", "ding")] sounds and a \
		[pick("yellow", "purple", "green", "blue", "red", "orange", "white")] \
		[pick("light", "dial", "meter", "window", "protrusion", "knob", "antenna", "swirly thing")] \
		[pick("swirls", "flashes", "whirrs", "goes schwing", "blinks", "flickers", "strobes", "lights up")] on the \
		[pick("front", "side", "top", "bottom", "rear", "inside")] of [src]. A [pick("slot", "funnel", "chute", "tube")] opens up in the \
		[pick("front", "side", "top", "bottom", "rear", "inside")].</span>"

/obj/machinery/replicator/process()
	if(spawning_types.len && powered())
		spawn_progress_time += world.time - last_process_time
		if(spawn_progress_time > max_spawn_time)
			visible_message("<span class='warning'>[bicon(src)] [src] pings!</span>")

			var/obj/source_material = pop(stored_materials)
			var/spawn_type = pop(spawning_types)
			var/obj/spawned_obj = new spawn_type(src.loc)
			if(source_material)
				if(length_char(source_material.name) < MAX_MESSAGE_LEN)
					spawned_obj.name = "[source_material] " +  spawned_obj.name
				if(length_char(source_material.desc) < MAX_MESSAGE_LEN * 2)
					if(spawned_obj.desc)
						spawned_obj.desc += " It is made of [source_material]."
					else
						spawned_obj.desc = "It is made of [source_material]."
				source_material.loc = null

			spawn_progress_time = 0
			max_spawn_time = rand(30,50)

			if(!spawning_types.len || !stored_materials.len)
				set_power_use(IDLE_POWER_USE)
				icon_state = "replicator"

		else if(prob(5))
			visible_message("<span class='warning'>[bicon(src)] [src] [pick("clicks", "whizzes", "whirrs", "whooshes", "clanks", "clongs", "clonks", "bangs")].</span>")

	last_process_time = world.time

/obj/machinery/replicator/ui_interact(mob/user)
	var/dat = "The control panel displays an incomprehensible selection of controls, many with unusual markings or text around them.<br>"
	dat += "<br>"
	for(var/index=1, index<=construction.len, index++)
		dat += "<A href='?src=\ref[src];activate=[index]'>\[[construction[index]]\]</a><br>"

	var/datum/browser/popup = new(user, "alien_replicator")
	popup.set_content(dat)
	popup.open()

/obj/machinery/replicator/attackby(obj/item/weapon/W, mob/living/user)
	if(W.flags & (NODROP | ABSTRACT | DROPDEL))
		to_chat(user, "<span class='notice'>[W] doesn't fit into [src].</span>")
		return
	user.drop_from_inventory(W, src)
	stored_materials.Add(W)
	visible_message("<span class='notice'>[user] inserts [W] into [src].</span>")

/obj/machinery/replicator/is_operational()
	return TRUE

/obj/machinery/replicator/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["activate"])
		var/index = text2num(href_list["activate"])
		if(index > 0 && index <= construction.len)
			if(stored_materials.len > spawning_types.len)
				if(spawning_types.len)
					visible_message("<span class='notice'>[bicon(src)] a [pick("light", "dial", "display", "meter", "pad")] on [src]'s front [pick("blinks", "flashes")] [pick("red", "yellow", "blue", "orange", "purple", "green", "white")].</span>")
				else
					visible_message("<span class='notice'>[bicon(src)] [src]'s front compartment slides shut.</span>")

				spawning_types.Add(construction[construction[index]])
				spawn_progress_time = 0
				set_power_use(ACTIVE_POWER_USE)
				icon_state = "replicator_active"
			else
				visible_message(fail_message)

	updateUsrDialog()
