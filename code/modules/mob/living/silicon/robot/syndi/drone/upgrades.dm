/obj/item/device/drone_uplink
    var/points = 20
    var/list/upgrades = list()

/obj/item/device/drone_uplink/atom_init()
    . = ..()
    for(var/up in typesof(/datum/drone_upgrade))
        upgrades += new up()
    for(var/datum/drone_upgrade/upgrade in upgrades)
        if(!upgrade.name)
            upgrades.Remove(upgrade)

/obj/item/device/drone_uplink/interact(mob/user)
    . = ..()
    var/dat = ""
    dat += "<B>Drone upgrade menu</B><BR>"
    dat += "Tele-Crystals left: [src.points]<BR>"
    dat += "<HR>"
    dat += "<B>Install upgrade:</B><BR>"
    dat += "<I>Each upgrade costs a number of tele-crystals as indicated by the number following their name.</I><br><BR>"

    var/category = ""
    var/i = 0
    for(var/datum/drone_upgrade/upgrade in upgrades)
        i++
        if(upgrade.category != category)
            dat += "<b>[upgrade.category]</b><br>"
            category = upgrade.category
        if(upgrade.can_install(user, FALSE))
            dat += "<A href='byond://?src=\ref[src];buy_item=[i];'>[upgrade.name]</A> [upgrade.cost] "
        else
            dat += "<span class='disabled'>[upgrade.name] [upgrade.cost]</span>"
        if(upgrade.desc)
            dat += "<span class='spoiler'><input type='checkbox' id='[upgrade.name]'>"
            dat += "<label for='[upgrade.name]'><b>\[?\]</b></label>"
            dat += "<div>[upgrade.desc]</div>"
            dat += "</span>"
            dat += "<br>"
    dat += "<HR>"

    var/datum/browser/popup = new(user, "hidden", "Syndicate Uplink", 450, 550, ntheme = CSS_THEME_SYNDICATE)
    popup.set_content(dat)
    popup.open()
    return

/obj/item/device/drone_uplink/Topic(href, href_list)
    ..()
    var/item = text2num(href_list["buy_item"])
    if(item)
        if(upgrades && upgrades.len >= item)
            var/datum/drone_upgrade/I = upgrades[item]
            if(I)
                I.install(usr)
                interact(usr)

//==========Datums==========
/datum/drone_upgrade
    var/name = null
    var/category = "upgrade category"
    var/desc = "upgrade description"
    var/list/items = null
    var/cost = 0
    var/single_use = TRUE //whether it's possible to install this multiple times
    var/installed = FALSE

/datum/drone_upgrade/proc/can_install(mob/living/silicon/robot/drone/syndi/D, chat_warning = TRUE)
    if(D.stat == DEAD)
        if(chat_warning)
            to_chat(D, "<span class='warning'>You can't be upgraded while you're dead!</span>")
        return FALSE

    if(cost > D.uplink.points)
        if(chat_warning)
            to_chat(D, "<span class='warning'>You have insufficient TK for upgrade!</span>")
        return FALSE

    if(single_use && installed)
        if(chat_warning)
            to_chat(D, "<span class='warning'>You can't install this upgrade twice!</span>")
        return FALSE

    return TRUE


/datum/drone_upgrade/proc/install(mob/living/silicon/robot/drone/syndi/D)
    if(!can_install(D))
        return FALSE

    if(!items.len)
        return FALSE
    for(var/item_type in items)
        D.module.modules += new item_type(D.module)

    D.uplink.points -= cost
    installed = TRUE
    return TRUE
//========DEVICE AND TOOLS========
/datum/drone_upgrade/device_tools
    category = "Device and tools"

/datum/drone_upgrade/device_tools/toolkit
    name = "Toolkit"
    desc = "Standard engineering toolkit. Magnetic gripper is included!"
    cost = 5
    items = list(
        /obj/item/weapon/gripper,
        /obj/item/weapon/screwdriver,
        /obj/item/weapon/wrench,
        /obj/item/weapon/weldingtool,
        /obj/item/weapon/crowbar/red,
        /obj/item/weapon/wirecutters,
        /obj/item/device/multitool
    )

/datum/drone_upgrade/device_tools/emag
    name = "Cryptographic Sequencer"
    desc = "The emag is a small card that unlocks hidden functions in electronic devices, \
        subverts intended functions and characteristically breaks security mechanisms."
    items = list(/obj/item/weapon/card/emag)
    cost = 8
    single_use = FALSE

/datum/drone_upgrade/device_tools/emplight
    name = "EMP Flashlight"
    desc = "A small, self-charging, short-ranged EMP device disguised as a flashlight. \
        Useful for disrupting headsets, cameras, and borgs during stealth operations."
    items = list(/obj/item/device/flashlight/emp)
    cost = 10

/datum/drone_upgrade/device_tools/flash
    name = "Flash"
    desc = "Self-defence device used for blinding livebeings or stun cyborgs by overloading their optics. Has limited amount of uses."
    items = list(/obj/item/device/flash)
    cost = 5
    single_use = FALSE

/datum/drone_upgrade/device_tools/jetpack
    name = "Jetpack"
    desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas."
    items = list(/obj/item/weapon/tank/jetpack/carbondioxide)
    cost = 7

/datum/drone_upgrade/device_tools/decoy
    name = "Sound decoy"
    desc = "Can produce various sounds to distract your enemies."
    items = list(/obj/item/toy/sound_button/syndi)
    cost = 4

//========SURVEILLANCE AND OPTICS========
/datum/drone_upgrade/optics
    category = "Surveillance and optics"

/datum/drone_upgrade/optics/thermal
    name = "Thermal scanners"
    desc = "These scanners allow you to see organisms through walls by capturing the upper portion of the infrared light spectrum, \
        emitted as heat and light by objects."
    cost = 4
    items = list(/obj/item/borg/sight/thermal)

/datum/drone_upgrade/optics/meson
    name = "Optical meson scanners"
    desc = "Used for seeing walls, floors, and stuff through anything."
    cost = 2
    items = list(/obj/item/borg/sight/meson)

/datum/drone_upgrade/optics/night
    name = "Night vision"
    desc = "Special optical device for working in poorly lit areas."
    cost = 2
    items = list(/obj/item/borg/sight/night)

//========CHEMICALS========
/datum/drone_upgrade/chems_poisons
    category = "Chemical injectors and poisons"

/datum/drone_upgrade/chems_poisons/hypo //mostly for nukeops to use as in-combat medical support unit
    name = "Medical hypospray"
    desc = "Chemical synthesizer and injection system, designed for heavy-duty medical equipment."
    items = list(/obj/item/weapon/reagent_containers/borghypo)
    cost = 8

/datum/drone_upgrade/chems_poisons/medhypo //the same as above
    name = "Improved medical hypospray"
    desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment. Has more types of medicines."
    items = list(/obj/item/weapon/reagent_containers/borghypo/medical)
    cost = 12

/datum/drone_upgrade/chems_poisons/dropper
    name = "Poison delivery system"
    desc = "Integrated industrial dropper, has 10u volume. Can be filled with various poisons via uplink."
    items = list(/obj/item/weapon/reagent_containers/dropper/robot/drone)
    cost = 5

/datum/drone_upgrade/chems_poisons/dropper_refill
    single_use = FALSE
    var/reagent

/datum/drone_upgrade/chems_poisons/dropper_refill/can_install(mob/living/silicon/robot/drone/syndi/D, chat_warning)
    for(var/obj/item/I in D.module.modules)
        if(istype(I, /obj/item/weapon/reagent_containers/dropper/robot/drone))
            return ..(D, chat_warning)

    if(chat_warning)
        to_chat(D, "<span class='warning'>You have no dropper to refill!</span>")
    return FALSE

/datum/drone_upgrade/chems_poisons/dropper_refill/install(mob/living/silicon/robot/drone/syndi/D)
    if(!can_install(D))
        return FALSE

    for(var/obj/item/I in D.module.modules)
        if(istype(I, /obj/item/weapon/reagent_containers/dropper/robot/drone))
            var/obj/item/weapon/reagent_containers/dropper/robot/drone/P = I
            P.reagents.clear_reagents()
            P.reagents.add_reagent(reagent, 10)
            P.filled = 1
            P.icon_state = "[initial(P.icon_state)][P.filled]"
            to_chat(D, "<span class='notice'>Your [P.name] was refilled.</span>")
    
    D.uplink.points -= cost
    return TRUE

/datum/drone_upgrade/chems_poisons/dropper_refill/chefspecial
    name = "Chef's Special refill"
    desc = "An extremely toxic chemical that will surely end in death."
    cost = 10
    reagent = "chefspecial"

/datum/drone_upgrade/chems_poisons/dropper_refill/alphaamanitin
    name = "Alpha-amanitin refill"
    desc = "Deadly rapidly degrading toxin derived from certain species of mushrooms."
    cost = 5
    reagent = "alphaamanitin"

/datum/drone_upgrade/chems_poisons/dropper_refill/cyanide
    name = "Cyanide refill"
    desc = "A highly toxic chemical. May cause deth by suffocation."
    cost = 7
    reagent = "cyanide"

/datum/drone_upgrade/chems_poisons/dropper_refill/chloralhydrate
    name = "Chloral Hydrate refill"
    desc = "A powerful sedative."
    cost = 5
    reagent = "chloralhydrate"

/datum/drone_upgrade/chems_poisons/dropper_refill/
//==========UPGRADES============
/datum/drone_upgrade/internal
    category = "Chassis and internal upgrades"

/datum/drone_upgrade/internal/ai
    name = "AI control"
    desc = "Downloads personality to control the drone. Use your Syndicate Encryption Key if you want to give orders remotely."
    cost = 2

/datum/drone_upgrade/internal/ai/install(mob/living/silicon/robot/drone/syndi/D)
    if(!can_install(D))
        return FALSE

    to_chat(D, "<span class='notice'>Searching for available drone personality. Please wait 30 seconds...</span>")
    var/list/drone_candicates = pollGhostCandidates("Syndicate requesting a personality for a syndicate drone. Would you like to play as one?", ROLE_OPERATIVE)
    if(drone_candicates.len)
        var/mob/M = pick(drone_candicates)
        D.loose_control()
        D.key = M.key
        D.uplink.points -= cost
        return TRUE
    else
        to_chat(D, "<span class='notice'>Unable to connect to Syndicate Command. Please wait and try again later.</span>")
        return FALSE

/datum/drone_upgrade/internal/extra_armor
    name = "Armor upgrade"
    desc = "Additional armor plates help the drone to withstand more damage. It will even survive one laser shot!"
    cost = 4

/datum/drone_upgrade/internal/extra_armor/install(mob/living/silicon/robot/drone/syndi/D)
    if(!can_install(D))
        return FALSE

    D.maxHealth += 20
    installed = TRUE
    D.uplink.points -= cost
    return TRUE

/datum/drone_upgrade/internal/speed_boost
    name = "Maneuverability booster"
    desc = "Speeds up your servos to increase your maneuverability for a short time. \
        Due to overheating your optical sensor will turn red and your curcuits will likely melt a little bit. High energy drain."
    cost = 4

/datum/drone_upgrade/internal/speed_boost/install(mob/living/silicon/robot/drone/syndi/D)
    if(!can_install(D))
        return FALSE

    D.AddSpell(new /obj/effect/proc_holder/spell/no_target/syndi_drone/boost())
    installed = TRUE
    D.uplink.points -= cost
    return TRUE

/datum/drone_upgrade/internal/smoke
    name = "Smokescreen charges"
    desc = "Three smokescreen charges. Activate it to hide yourself and your fellows from the enemy sight."
    cost = 2
    single_use = FALSE

/datum/drone_upgrade/internal/smoke/install(mob/living/silicon/robot/drone/syndi/D)
    if(!can_install(D))
        return FALSE

    if(installed)
        for(var/obj/effect/proc_holder/spell/S in D.spell_list)
            if(istype(S, /obj/effect/proc_holder/spell/no_target/syndi_drone/smoke))
                S.charge_counter = 3
                D.uplink.points -= cost
                return TRUE

    D.AddSpell(new /obj/effect/proc_holder/spell/no_target/syndi_drone/smoke())
    installed = TRUE
    D.uplink.points -= cost
    return TRUE

/datum/drone_upgrade/internal/corporate_disguise
    name = "NanoTrasen disguise"
    desc = "A bunch of hull modifications, that make you look exactly as an NT maintenance drone. Security protocols hack is not included!"
    cost = 6

/datum/drone_upgrade/internal/corporate_disguise/install(mob/living/silicon/robot/drone/syndi/D)
    if(!can_install(D))
        return FALSE

    D.eyes_overlay = "eyes-repairbot"
    D.name = "maintenance drone " + copytext(D.name, -5)
    D.flavor_text = "It's a tiny little repair drone. The casing is stamped with an NT logo and the subscript: \
        'NanoTrasen Recursive Repair Systems: Fixing Tomorrow's Problem, Today!'"
    D.uplink.points -= cost
    installed = TRUE
    return TRUE