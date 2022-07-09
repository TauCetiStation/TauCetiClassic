/obj/item/rig_module/device/flash
	name = "hardsuit mounted flash"
	desc = "You are the law."
	icon_state = "flash"
	interface_name = "mounted flash"
	interface_desc = "Disorientates your target by blinding them with a bright light."
	device_type = /obj/item/device/flash
	origin_tech = "combat=2"

/obj/item/rig_module/grenade_launcher
	name = "hardsuit mounted grenade launcher"
	desc = "A shoulder-mounted micro-explosive dispenser."
	selectable = TRUE
	icon_state = "grenadelauncher"
	suit_overlay = "grenade"
	use_power_cost = 500
	mount_type = MODULE_MOUNT_GRENADELAUNCHER
	origin_tech = "combat=3"

	interface_name = "integrated grenade launcher"
	interface_desc = "Discharges loaded grenades against the wearer's location."

	var/fire_range = 5
	var/fire_speed = 2

/obj/item/rig_module/grenade_launcher/init_charges()
	charges = list()
	charges["flashbang"]   = new /datum/rig_charge("flashbang",   /obj/item/weapon/grenade/flashbang,  3)
	charges["smoke bomb"]  = new /datum/rig_charge("smoke bomb",  /obj/item/weapon/grenade/smokebomb,  3)
	charges["EMP grenade"] = new /datum/rig_charge("EMP grenade", /obj/item/weapon/grenade/empgrenade, 3)

/obj/item/rig_module/grenade_launcher/accepts_item(obj/item/input_device, mob/living/user)

	if(!istype(input_device) || !istype(user))
		return FALSE

	var/datum/rig_charge/accepted_item
	for(var/charge in charges)
		var/datum/rig_charge/charge_datum = charges[charge]
		if(input_device.type == charge_datum.product_type)
			accepted_item = charge_datum
			break

	if(!accepted_item)
		return FALSE

	if(accepted_item.charges >= 5)
		to_chat(user, "<span class='danger'>Another grenade of that type will not fit into the module.</span>")
		return FALSE

	to_chat(user, "<span class='bold notice'>You slot \the [input_device] into the suit module.</span>")
	qdel(input_device)
	accepted_item.charges++
	return TRUE

/obj/item/rig_module/grenade_launcher/engage(atom/target)
	if(!isturf(holder.wearer.loc) && target)
		return FALSE

	if(!..())
		return FALSE

	if(!target)
		return FALSE

	var/mob/living/carbon/human/H = holder.wearer

	if(damage > MODULE_NO_DAMAGE && prob(50))
		to_chat(holder.wearer, "<span class='warning'>[name] malfunctions and ignores your command!</span>")
		return TRUE

	if(!charge_selected)
		to_chat(H, "<span class='danger'>You have not selected a grenade type.</span>")
		return FALSE

	var/datum/rig_charge/charge = charges[charge_selected]

	if(!charge)
		return FALSE

	if(charge.charges <= 0)
		to_chat(H, "<span class='danger'>Insufficient grenades!</span>")
		return FALSE

	charge.charges--
	var/obj/item/weapon/grenade/new_grenade = new charge.product_type(get_turf(H))
	H.visible_message("<span class='danger'>[H] launches \a [new_grenade]!</span>")
	msg_admin_attack("[H] fired a grenade ([new_grenade.name]) from a rigsuit grenade launcher.", H)
	new_grenade.activate(H)
	new_grenade.throw_at(target,fire_range,fire_speed)

/obj/item/rig_module/grenade_launcher/cleaner
	name = "hardsuit mounted cleaning grenade launcher"
	interface_name = "cleaning grenade launcher"
	desc = "A shoulder-mounted micro-explosive dispenser designed only to accept standard cleaning foam grenades."

/obj/item/rig_module/grenade_launcher/cleaner/init_charges()
	charges = list()
	charges["cleaning grenade"] = new /datum/rig_charge("cleaning grenade", /obj/item/weapon/grenade/chem_grenade/cleaner, 9)

/obj/item/rig_module/grenade_launcher/smoke
	name = "hardsuit mounted smoke grenade launcher"
	interface_name = "smoke grenade launcher"
	desc = "A shoulder-mounted micro-explosive dispenser designed only to accept standard smoke grenades."

/obj/item/rig_module/grenade_launcher/smoke/init_charges()
	charges = list()
	charges["smoke bomb"] = new /datum/rig_charge("smoke bomb", /obj/item/weapon/grenade/smokebomb, 6)

/obj/item/rig_module/grenade_launcher/mfoam
	name = "hardsuit mounted foam grenade launcher"
	interface_name = "foam grenade launcher"
	desc = "A shoulder-mounted micro-explosive dispenser designed only to accept standard metal foam grenades."

/obj/item/rig_module/grenade_launcher/mfoam/init_charges()
	charges = list()
	charges["metal foam grenade"] = new /datum/rig_charge("metal foam grenade", /obj/item/weapon/grenade/chem_grenade/metalfoam, 4)

/obj/item/rig_module/grenade_launcher/flashbang
	name = "hardsuit mounted flashbang grenade launcher"
	interface_name = "flashbang grenade launcher"
	desc = "A shoulder-mounted micro-explosive dispenser designed only to accept standard flashbang grenades."

/obj/item/rig_module/grenade_launcher/flashbang/init_charges()
	charges = list()
	charges["flashbang"] = new /datum/rig_charge("flashbang", /obj/item/weapon/grenade/flashbang, 3)

/obj/item/rig_module/mounted
	name = "hardsuit mounted laser rifle"
	desc = "A shoulder-mounted battery-powered laser rifle mount."
	selectable = TRUE
	usable = FALSE
	module_cooldown = 0
	icon_state = "egun"
	suit_overlay = "mounted-lascannon"
	use_power_cost = 0
	mount_type = MODULE_MOUNT_SHOULDER_LEFT
	var/recharge_speed = 50
	var/charge_override = 400
	origin_tech = "combat=4"

	engage_string = "Configure"

	interface_name = "mounted laser rifle"
	interface_desc = "A shoulder-mounted cell-powered laser rifle."

	var/obj/item/weapon/gun/energy/gun = /obj/item/weapon/gun/energy/laser

/obj/item/rig_module/mounted/atom_init()
	. = ..()
	if(gun)
		gun = new gun(src)
		gun.canremove = FALSE
		gun.name = interface_name
		if(charge_override)
			gun.power_supply.maxcharge = charge_override
			gun.power_supply.charge = charge_override

/obj/item/rig_module/mounted/engage(atom/target)
	if(!isturf(holder.wearer.loc) && target)
		return FALSE

	if(!..())
		return FALSE

	if(damage > MODULE_NO_DAMAGE && prob(40))
		to_chat(holder.wearer, "<span class='warning'>[name] malfunctions and ignores your command!</span>")
		return TRUE

	if(!target)
		gun.attack_self(holder.wearer)
		return

	gun.Fire(target,holder.wearer)
	return TRUE

/obj/item/rig_module/mounted/process_module()
	if(istype(gun) && gun.power_supply)
		return gun.power_supply.give(recharge_speed)
	return passive_power_cost

/obj/item/rig_module/mounted/taser
	name = "hardsuit mounted taser"
	desc = "A palm-mounted nonlethal energy projector."
	icon_state = "taser"
	suit_overlay = "mounted-taser"
	use_power_cost = 0
	mount_type = MODULE_MOUNT_SHOULDER_RIGHT
	origin_tech = "combat=3"

	usable = TRUE

	interface_name = "mounted taser"
	interface_desc = "A palm-mounted, cell-powered taser."
	gun = /obj/item/weapon/gun/energy/taser/stunrevolver
