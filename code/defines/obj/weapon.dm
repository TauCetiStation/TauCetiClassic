/obj/item/weapon/phone
	name = "red phone"
	desc = "Should anything ever go wrong..."
	icon = 'icons/obj/items.dmi'
	icon_state = "red_phone"
	flags = CONDUCT
	force = 3.0
	throwforce = 2.0
	throw_speed = 1
	throw_range = 4
	w_class = SIZE_TINY
	attack_verb = list("called", "rang")
	hitsound = list('sound/weapons/ring.ogg')

/obj/item/weapon/rsp
	name = "Rapid-Seed-Producer (RSP)"
	desc = "A device used to rapidly deploy seeds."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = FALSE
	anchored = FALSE
	var/matter = 0
	var/mode = 1
	w_class = SIZE_SMALL

/obj/item/weapon/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "corncob"
	item_state = "corncob"
	w_class = SIZE_TINY
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/c_tube
	name = "cardboard tube"
	desc = "A tube... of cardboard."
	icon = 'icons/obj/items.dmi'
	icon_state = "c_tube"
	throwforce = 1
	w_class = SIZE_TINY
	throw_speed = 4
	throw_range = 5


/obj/item/weapon/cane
	name = "cane"
	desc = "A cane used by a true gentlemen. Or a clown."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "cane"
	item_state = "stick"
	flags = CONDUCT
	force = 5.0
	throwforce = 7.0
	w_class = SIZE_TINY
	m_amt = 50
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")

/obj/item/weapon/cane/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.can_push = TRUE
	SCB.can_pull = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/gift
	name = "gift"
	desc = "A wrapped item."
	icon = 'icons/obj/items.dmi'
	icon_state = "gift3"
	item_state = "gift"
	w_class = SIZE_SMALL
	var/size = SIZE_SMALL
	var/sender = FALSE
	var/recipient = FALSE

/obj/item/weapon/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_TINY
	attack_verb = list("warned", "cautioned", "smashed")

/obj/item/weapon/caution/cone
	desc = "This cone is trying to warn you of something!"
	name = "warning cone"
	icon_state = "cone"

/obj/item/weapon/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'icons/obj/items.dmi'
	icon_state = "rack_parts"
	flags = CONDUCT
	m_amt = 3750

	max_integrity = 100
	resistance_flags = CAN_BE_HIT

// base shard object
/obj/item/weapon/shard
	name = "shard"
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	item_state_world = "large_world"
	var/item_state_base = ""
	sharp = 1
	edge = 1
	desc = "Could probably be used as ... a throwing weapon?"
	w_class = SIZE_TINY
	force = 5.0
	throwforce = 8.0
	item_state = "shard-glass"
	g_amt = 3750
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	var/on_step_sound = 'sound/effects/glass_step.ogg'

/obj/item/weapon/shard/atom_init()
	var/icon_variant = pick("large", "medium", "small")
	item_state_base = "[item_state_base][icon_variant]"
	item_state_world = "[item_state_base]_world"

	switch(icon_variant)
		if("small")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("medium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("large")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)

	return ..()

/obj/item/weapon/shard/update_icon()
	if((flags_2 & IN_INVENTORY || flags_2 & IN_STORAGE) && icon_state == item_state_world)
		icon_state = item_state_base
	else if(icon_state != item_state_world)
		icon_state = item_state_world

/obj/item/weapon/shard/update_world_icon()
	update_icon()

/obj/item/weapon/shard/Bump()
	if(prob(20))
		force = 15
	else
		force = 4
	..()

/obj/item/weapon/shard/attackby(obj/item/I, mob/user, params)
	if(iswelding(I))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.use(0, user))
			var/obj/item/stack/sheet/glass/NG = new (user.loc)
			for(var/obj/item/stack/sheet/glass/G in user.loc)
				if(G==NG)
					continue
				if(G.get_amount() >= G.max_amount)
					continue
				G.attackby(NG, user)
				to_chat(usr, "You add the newly-formed glass to the stack. It now contains [NG.get_amount()] sheets.")
			qdel(src)

	else
		return ..()

/obj/item/weapon/shard/Crossed(atom/movable/AM)
	if(ismob(AM) && !HAS_TRAIT(AM, TRAIT_LIGHT_STEP))
		var/mob/M = AM
		to_chat(M, "<span class='warning'><B>You step on the [src]!</B></span>")
		playsound(src, on_step_sound, VOL_EFFECTS_MASTER)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.species.flags[IS_SYNTHETIC])
				return

			if(H.wear_suit && (H.wear_suit.body_parts_covered & LEGS) && H.wear_suit.pierce_protection & LEGS)
				return

			if(H.species.flags[NO_MINORCUTS])
				return

			if(H.buckled)
				return

			if(!H.shoes)
				var/obj/item/organ/external/BP = H.bodyparts_by_name[pick(BP_L_LEG , BP_R_LEG)]
				if(BP.is_robotic())
					return
				BP.take_damage(5, 0)
				if(!H.species.flags[NO_PAIN])
					H.Stun(1)
					H.Weaken(3)
				H.updatehealth()
	. = ..()

/obj/item/weapon/shard/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is slitting \his wrists with the shard of glass! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is slitting \his throat with the shard of glass! It looks like \he's trying to commit suicide.</span>"))
	return (BRUTELOSS)

/obj/item/weapon/shard/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(isturf(target))
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves && !H.species.flags[NO_MINORCUTS]) //specflags please..
			to_chat(H, "<span class='warning'>[src] cuts into your hand!</span>")
			var/obj/item/organ/external/BP = H.bodyparts_by_name[H.hand ? BP_L_ARM : BP_R_ARM]
			BP.take_damage(force / 2, null, damage_flags())
	else if(ismonkey(user))
		var/mob/living/carbon/monkey/M = user
		var/datum/species/S = all_species[M.get_species()]
		if(S && S.flags[NO_MINORCUTS])
			return
		to_chat(M, "<span class='warning'>[src] cuts into your hand!</span>")
		M.adjustBruteLoss(force / 2)

// phoron shard object
/obj/item/weapon/shard/phoron
	name = "phoron shard"
	desc = "A shard of phoron glass. Considerably tougher then normal glass shards. Apparently not tough enough to be a window."
	force = 8.0
	throwforce = 15.0
	icon_state = "phoronlarge"
	item_state_world = "phoronlarge_world"
	item_state_base = "phoron"
	sharp = 1
	edge = 1

/obj/item/weapon/shard/phoron/attackby(obj/item/I, mob/user, params)
	if(iswelding(I))
		var/obj/item/weapon/weldingtool/WT = I
		user.SetNextMove(CLICK_CD_INTERACT)
		if(WT.use(0, user))
			new /obj/item/stack/sheet/glass/phoronglass(user.loc, , TRUE)
			qdel(src)
			return
	return ..()

// shrapnel shard object
/obj/item/weapon/shard/shrapnel
	name = "shrapnel"
	icon = 'icons/obj/shards.dmi'
	icon_state = "shrapnellarge"
	item_state_world = "shrapnellarge_world"
	item_state_base = "shrapnel"
	desc = "A bunch of tiny bits of shattered metal."
	on_step_sound = 'sound/effects/metalstep.ogg'

/obj/item/weapon/SWF_uplink
	name = "station-bounced radio"
	desc = "used to comunicate it appears."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	var/temp = null
	var/uses = 4.0
	var/selfdestruct = 0.0
	var/traitor_frequency = 0.0
	var/obj/item/device/radio/origradio = null
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	item_state = "radio"
	throwforce = 5
	w_class = SIZE_TINY
	throw_speed = 4
	throw_range = 20
	m_amt = 100
	origin_tech = "magnets=1"

/obj/item/weapon/staff
	name = "wizards staff"
	desc = "Apparently a staff used by the wizard."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	force = 3.0
	hitsound = list('sound/effects/magic.ogg')
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_TINY
	attack_verb = list("bludgeoned", "whacked", "disciplined")

/obj/item/weapon/staff/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.can_push = TRUE
	SCB.can_pull = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/staff/broom
	name = "broom"
	desc = "Used for sweeping, and flying into the night while cackling. Black cat not included."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "broom"

/obj/item/weapon/staff/broom/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.can_push = TRUE
	SCB.can_pull = TRUE

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/staff/gentcane
	name = "Gentlemans Cane"
	desc = "An ebony can with an ivory tip."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "cane"
	item_state = "stick"

/obj/item/weapon/staff/stick
	name = "stick"
	desc = "A great tool to drag someone else's drinks across the bar."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "stick"
	item_state = "stick"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_TINY

/obj/item/weapon/table_parts
	name = "table parts"
	desc = "Parts of a table. Poor table."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "table_parts"
	m_amt = 3750
	flags = CONDUCT
	attack_verb = list("slammed", "bashed", "battered", "bludgeoned", "thrashed", "whacked")
	var/table_type = /obj/structure/table
	var/list/debris = list(/obj/item/stack/sheet/metal)

	max_integrity = 100
	resistance_flags = CAN_BE_HIT

/obj/item/weapon/table_parts/reinforced
	name = "reinforced table parts"
	desc = "Hard table parts. Well...harder..."
	icon = 'icons/obj/items.dmi'
	icon_state = "reinf_tableparts"
	m_amt = 7500
	flags = CONDUCT
	table_type = /obj/structure/table/reinforced
	debris = list(/obj/item/stack/sheet/metal, /obj/item/stack/rods)

/obj/item/weapon/table_parts/stall
	name = "stall table parts"
	desc = "Stall table parts."
	icon = 'icons/obj/items.dmi'
	icon_state = "stall_tableparts"
	m_amt = 15000
	flags = CONDUCT
	table_type = /obj/structure/table/reinforced/stall
	debris = list(/obj/item/stack/sheet/metal, /obj/item/stack/rods)

/obj/item/weapon/table_parts/wood
	name = "wooden table parts"
	desc = "Keep away from fire."
	icon_state = "wood_tableparts"
	flags = null
	table_type = /obj/structure/table/woodentable
	debris = list(/obj/item/stack/sheet/wood)

/obj/item/weapon/table_parts/wood/poker
	name = "poker table parts"
	desc = "Keep away from fire, and keep near seedy dealers."
	icon_state = "poker_tableparts"
	flags = null
	table_type = /obj/structure/table/woodentable/poker
	debris = list(/obj/item/stack/sheet/wood, /obj/item/stack/tile/grass)

/obj/item/weapon/table_parts/wood/fancy
	name = "fancy table parts"
	desc = "Covered with an amazingly fancy, patterned cloth."
	icon_state = "fancy_tableparts"
	table_type = /obj/structure/table/woodentable/fancy

/obj/item/weapon/table_parts/wood/fancy/black
	icon_state = "fancyblack_tableparts"
	table_type = /obj/structure/table/woodentable/fancy/black

/obj/item/weapon/table_parts/glass
	name = "glass table parts"
	desc = "Very fragile."
	icon_state = "glass_tableparts"
	flags = null
	table_type = /obj/structure/table/glass
	debris = list(/obj/item/stack/sheet/glass)

/obj/item/weapon/wire
	desc = "This is just a simple piece of regular insulated wire."
	name = "wire"
	icon = 'icons/obj/power.dmi'
	icon_state = "item_wire"
	var/amount = 1.0
	var/laying = 0.0
	var/old_lay = null
	m_amt = 40
	attack_verb = list("whipped", "lashed", "disciplined", "tickled")

/obj/item/weapon/wire/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (OXYLOSS)

/obj/item/weapon/module
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = SIZE_TINY
	item_state = "electronic"
	flags = CONDUCT
	usesound = 'sound/items/Deconstruct.ogg'
	var/mtype = 1						// 1=electronic 2=hardware

/obj/item/weapon/module/card_reader
	name = "card reader module"
	icon_state = "card_mod"
	desc = "An electronic module for reading data and ID cards."

/obj/item/weapon/module/power_control
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."
	m_amt = 50
	g_amt = 50

/obj/item/weapon/module/id_auth
	name = "ID authentication module"
	icon_state = "id_mod"
	desc = "A module allowing secure authorization of ID cards."

/obj/item/weapon/module/cell_power
	name = "power cell regulator module"
	icon_state = "power_mod"
	desc = "A converter and regulator allowing the use of power cells."

/obj/item/weapon/module/cell_power
	name = "power cell charger module"
	icon_state = "power_mod"
	desc = "Charging circuits for power cells."

/obj/item/weapon/syntiflesh
	name = "syntiflesh"
	desc = "Meat that appears...strange..."
	icon = 'icons/obj/food.dmi'
	icon_state = "meat"
	flags = CONDUCT
	w_class = SIZE_TINY
	origin_tech = "biotech=2"

/obj/item/weapon/hatchet
	name = "hatchet"
	desc = "A very sharp axe blade upon a short fibremetal handle. It has a long history of chopping things, but now it is used for chopping wood."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hatchet"
	flags = CONDUCT
	force = 12.0
	hitsound = list('sound/weapons/bladeslice.ogg')
	sharp = 1
	edge = 1
	w_class = SIZE_TINY
	throwforce = 15.0
	throw_speed = 4
	throw_range = 4
	m_amt = 15000
	origin_tech = "materials=2;combat=1"
	attack_verb = list("chopped", "torn", "cut")

/obj/item/weapon/hatchet/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/obj, /turf)

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/hatchet/unathiknife
	name = "duelling knife"
	desc = "A length of leather-bound wood studded with razor-sharp teeth. How crude."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "unathiknife"
	attack_verb = list("ripped", "torn", "cut")

/obj/item/weapon/scythe
	icon_state = "scythe0"
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	force = 13.0
	throwforce = 5.0
	sharp = 1
	edge = 1
	throw_speed = 1
	throw_range = 3
	w_class = SIZE_NORMAL
	slot_flags = SLOT_FLAGS_BACK
	origin_tech = "materials=2;combat=2"
	attack_verb = list("chopped", "sliced", "cut", "reaped")

/obj/item/weapon/scythe/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/turf, /obj/effect/effect/weapon_sweep)

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/scythe/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(istype(target, /obj/structure/spacevine))
		for(var/obj/structure/spacevine/B in orange(target, 1))
			if(prob(80))
				qdel(B)
		qdel(target)

/*
/obj/item/weapon/cigarpacket
	name = "Pete's Cuban Cigars"
	desc = "The most robust cigars on the planet."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigarpacket"
	item_state = "cigarpacket"
	w_class = SIZE_MINUSCULE
	throwforce = 2
	var/cigarcount = 6
	flags = ONBELT */

/obj/item/weapon/pai_cable
	desc = "A flexible coated cable with a universal jack on one end."
	name = "data cable"
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"
	flags = NOBLUDGEON | NOATTACKANIMATION | CONDUCT
	w_class = SIZE_TINY

	var/obj/machinery/machine

///////////////////////////////////////Stock Parts /////////////////////////////////

/obj/item/weapon/storage/part_replacer
	name = "Rapid Part Exchange Device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	icon_state = "RPED"
	item_state = "RPED"
	w_class = SIZE_BIG
	can_hold = list(/obj/item/weapon/stock_parts)
	storage_slots = 50
	use_to_pickup = 1
	allow_quick_gather = 1
	allow_quick_empty = 1
	collection_mode = 1
	display_contents_with_number = 1
	max_w_class = SIZE_SMALL
	var/works_from_distance = 0
	var/pshoom_or_beepboopblorpzingshadashwoosh = 'sound/items/rped.ogg'
	var/alt_sound = null

/obj/item/weapon/storage/part_replacer/afterattack(atom/target, mob/user, proximity, params)
	if(proximity)
		return
	if(!ismachinery(target))
		return
	var/obj/machinery/T = target
	if(works_from_distance && T.component_parts)
		T.exchange_parts(user, src)
		user.Beam(T,icon_state="rped_upgrade",icon='icons/effects/effects.dmi',time=5)

/obj/item/weapon/storage/part_replacer/bluespace
	name = "bluespace rapid part exchange device"
	desc = "A version of the RPED that allows for replacement of parts and scanning from a distance, along with higher capacity for parts."
	icon_state = "BS_RPED"
	item_state = "BS_RPED"
	w_class = SIZE_SMALL
	storage_slots = 400
	max_w_class = SIZE_SMALL
	works_from_distance = 1
	pshoom_or_beepboopblorpzingshadashwoosh = 'sound/items/PSHOOM.ogg'
	alt_sound = 'sound/items/PSHOOM_2.ogg'

/obj/item/weapon/storage/part_replacer/proc/play_rped_sound()
	//Plays the sound for RPED exhanging or installing parts.
	if(alt_sound && prob(1))
		playsound(src, alt_sound, VOL_EFFECTS_MASTER)
	else
		playsound(src, pshoom_or_beepboopblorpzingshadashwoosh, VOL_EFFECTS_MASTER)

//Sorts stock parts inside an RPED by their rating.
//Only use /obj/item/weapon/stock_parts with this sort proc!
/proc/cmp_rped_sort(obj/item/weapon/stock_parts/A, obj/item/weapon/stock_parts/B)
	return B.rating - A.rating

/obj/item/weapon/stock_parts
	name = "stock part"
	desc = "What?"
	icon = 'icons/obj/stock_parts.dmi'
	w_class = SIZE_TINY
	var/rating = 1

/obj/item/weapon/stock_parts/atom_init()
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

//Rank 1

/obj/item/weapon/stock_parts/console_screen
	name = "console screen"
	desc = "Used in the construction of computers and other devices with a interactive console."
	icon_state = "screen"
	origin_tech = "materials=1"
	g_amt = 200

/obj/item/weapon/stock_parts/capacitor
	name = "capacitor"
	desc = "A basic capacitor used in the construction of a variety of devices."
	icon_state = "capacitor"
	origin_tech = "powerstorage=1"
	m_amt = 150
	g_amt = 150

/obj/item/weapon/stock_parts/scanning_module
	name = "scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "scan_module"
	origin_tech = "magnets=1"
	m_amt = 100
	g_amt = 120

/obj/item/weapon/stock_parts/manipulator
	name = "micro-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "micro_mani"
	origin_tech = "materials=1;programming=1"
	m_amt = 100
	g_amt = 80

/obj/item/weapon/stock_parts/micro_laser
	name = "micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "micro_laser"
	origin_tech = "magnets=1"
	m_amt = 100
	g_amt = 120

/obj/item/weapon/stock_parts/matter_bin
	name = "matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "matter_bin"
	origin_tech = "materials=1"
	m_amt = 300

//Rank 2

/obj/item/weapon/stock_parts/capacitor/adv
	name = "advanced capacitor"
	desc = "An advanced capacitor used in the construction of a variety of devices."
	icon_state = "adv_capacitor"
	origin_tech = "powerstorage=3"
	rating = 2
	m_amt = 250
	g_amt = 250

/obj/item/weapon/stock_parts/scanning_module/adv
	name = "advanced scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "adv_scan_module"
	origin_tech = "magnets=3"
	rating = 2
	m_amt = 250
	g_amt = 220

/obj/item/weapon/stock_parts/manipulator/nano
	name = "nano-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "nano_mani"
	origin_tech = "materials=3,programming=2"
	rating = 2
	m_amt = 230
	g_amt = 220

/obj/item/weapon/stock_parts/micro_laser/high
	name = "high-power micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "high_micro_laser"
	origin_tech = "magnets=3"
	rating = 2
	m_amt = 210
	g_amt = 220

/obj/item/weapon/stock_parts/matter_bin/adv
	name = "advanced matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "advanced_matter_bin"
	origin_tech = "materials=3"
	rating = 2
	m_amt = 280
	g_amt = 220

//Rating 3

/obj/item/weapon/stock_parts/capacitor/adv/super
	name = "super capacitor"
	desc = "A super-high capacity capacitor used in the construction of a variety of devices."
	icon_state = "super_capacitor"
	origin_tech = "powerstorage=5;materials=4"
	rating = 3
	m_amt = 350
	g_amt = 350

/obj/item/weapon/stock_parts/scanning_module/adv/phasic
	name = "phasic scanning module"
	desc = "A compact, high resolution phasic scanning module used in the construction of certain devices."
	icon_state = "super_scan_module"
	origin_tech = "magnets=5"
	rating = 3
	m_amt = 350
	g_amt = 320

/obj/item/weapon/stock_parts/manipulator/nano/pico
	name = "pico-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "pico_mani"
	origin_tech = "materials=5,programming=2"
	rating = 3
	m_amt = 330
	g_amt = 320

/obj/item/weapon/stock_parts/micro_laser/high/ultra
	name = "ultra-high-power micro-laser"
	icon_state = "ultra_high_micro_laser"
	desc = "A tiny laser used in certain devices."
	origin_tech = "magnets=5"
	rating = 3
	m_amt = 310
	g_amt = 320

/obj/item/weapon/stock_parts/matter_bin/adv/super
	name = "super matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "super_matter_bin"
	origin_tech = "materials=5"
	rating = 3
	m_amt = 380
	g_amt = 320

//Rating 4

/obj/item/weapon/stock_parts/capacitor/adv/super/quadratic
	name = "quadratic capacitor"
	desc = "An capacity capacitor used in the construction of a variety of devices."
	icon_state = "quadratic_capacitor"
	origin_tech = "powerstorage=6;materials=5"
	rating = 4
	m_amt = 350
	g_amt = 350

/obj/item/weapon/stock_parts/scanning_module/adv/phasic/triphasic
	name = "triphasic scanning module"
	desc = "A compact, ultra resolution triphasic scanning module used in the construction of certain devices."
	icon_state = "triphasic_scan_module"
	origin_tech = "magnets=6"
	rating = 4
	m_amt = 350
	g_amt = 320

/obj/item/weapon/stock_parts/manipulator/nano/pico/femto
	name = "femto-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "femto_mani"
	origin_tech = "materials=6;programming=3"
	rating = 4
	m_amt = 330

/obj/item/weapon/stock_parts/micro_laser/high/ultra/quadultra
	name = "quad-ultra micro-laser"
	icon_state = "quadultra_micro_laser"
	desc = "A tiny laser used in certain devices."
	origin_tech = "magnets=6"
	rating = 4
	m_amt = 80
	g_amt = 220

/obj/item/weapon/stock_parts/matter_bin/adv/super/bluespace
	name = "bluespace matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "bluespace_matter_bin"
	origin_tech = "materials=6"
	rating = 4
	m_amt = 380

// Subspace stock parts

/obj/item/weapon/stock_parts/subspace/ansible
	name = "subspace ansible"
	icon_state = "subspace_ansible"
	desc = "A compact module capable of sensing extradimensional activity."
	origin_tech = "programming=3;magnets=5;materials=4;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/filter
	name = "hyperwave filter"
	icon_state = "hyperwave_filter"
	desc = "A tiny device capable of filtering and converting super-intense radiowaves."
	origin_tech = "programming=4;magnets=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/amplifier
	name = "subspace amplifier"
	icon_state = "subspace_amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."
	origin_tech = "programming=3;magnets=4;materials=4;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/treatment
	name = "subspace treatment disk"
	icon_state = "treatment_disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."
	origin_tech = "programming=3;magnets=2;materials=5;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/analyzer
	name = "subspace wavelength analyzer"
	icon_state = "wavelength_analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	origin_tech = "programming=3;magnets=4;materials=4;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/crystal
	name = "ansible crystal"
	icon_state = "ansible_crystal"
	desc = "A crystal made from pure glass used to transmit laser databursts to subspace."
	origin_tech = "magnets=4;materials=4;bluespace=2"
	g_amt = 50

/obj/item/weapon/stock_parts/subspace/transmitter
	name = "subspace transmitter"
	icon_state = "subspace_transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."
	origin_tech = "magnets=5;materials=5;bluespace=3"
	m_amt = 50

/obj/item/weapon/research//Makes testing much less of a pain -Sieve
	name = "research"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "capacitor"
	desc = "A debug item for research."
	origin_tech = "materials=8;engineering=8;phorontech=8;powerstorage=8;bluespace=8;biotech=8;combat=8;magnets=8;programming=8;syndicate=8"

/obj/item/weapon/broom
	name = "Broom"
	desc = "This broom is made with the branches and leaves of a tree which secretes aromatic oils."
	icon_state = "broom_sauna"

/obj/item/weapon/broom/attack(mob/living/carbon/human/M, mob/living/user, def_zone)
	if(!istype(M) || user.a_intent == INTENT_HARM)
		return ..()
	if(wet - 5 < 0)
		to_chat(user, "<span class='userdanger'>Soak this [src] first!</span>")
		return
	if(M == user)
		to_chat(user, "<span class='userdanger'>You can't birching yourself!</span>")
		return
	if(!M.lying)
		to_chat(user, "<span class='userdanger'>[M] Must be lie down first!</span>")
		return

	var/zone = check_zone(user.get_targetzone())
	var/obj/item/organ/external/BP = M.get_bodypart(zone)
	for(var/obj/item/clothing/C in M.get_equipped_items())
		if(C.body_parts_covered & BP.body_part)
			to_chat(user, "<span class='userdanger'>Take off [M]'s clothes first!</span>")
			return

	M.adjustHalLoss(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "sauna relax", /datum/mood_event/sauna)

	playsound(src, 'sound/weapons/sauna_broom.ogg', VOL_EFFECTS_MASTER)

	zone = parse_zone(zone)
	wet -= 5
	user.visible_message("<span class='notice'>A [user] lightly Birching [M]'s [zone] with [src]!</span>",
		"<span class='notice'>You lightly Birching [M]'s [zone] with [src]!</span>")




