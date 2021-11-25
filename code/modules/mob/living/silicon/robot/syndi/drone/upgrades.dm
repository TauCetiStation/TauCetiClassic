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
        if(upgrade.cost <= points && !(upgrade.single_use && upgrade.installed))
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
    var/single_use = FALSE //whether it's possible to install this multiple times
    var/installed = FALSE

/datum/drone_upgrade/proc/install(mob/living/silicon/robot/drone/syndi/D)
    if(!items.len)
        return FALSE
    if(D.stat == DEAD)
        to_chat(D, "<span class='warning'>You can't be upgraded while you're dead!</span>")
        return FALSE
    for(var/item_type in items)
        D.module.modules += new item_type(D.module)
    D.uplink.points -= cost
    return TRUE

//==========UPGRADES==========
/datum/drone_upgrade/internal
    category = "Chassis and internal upgrades"

/datum/drone_upgrade/internal/ai
    name = "AI control"
    desc = "Downloads personality to control the drone. Use your Syndicate Encryption Key if you want to give orders remotely."
    cost = 2

/datum/drone_upgrade/internal/ai/install(mob/living/silicon/robot/drone/syndi/D)
    if(D.stat == DEAD)
        to_chat(D, "<span class='warning'>You can't be upgraded while you're dead!</span>")
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

/datum/drone_upgrade/internal/speed_boost
    name = "Maneuverability booster"
    desc = "Speeds up your servos to increase your maneuverability for a short time. Due to overheating your optical sensor will turn red and your curcuits will likely melt a little bit. High energy drain."
    cost = 3
    single_use = TRUE

/datum/drone_upgrade/internal/speed_boost/install(mob/living/silicon/robot/drone/syndi/D)
    if(D.stat == DEAD)
        to_chat(D, "<span class='warning'>You can't be upgraded while you're dead!</span>")
        return FALSE
    if(installed)
        to_chat(D, "<span class='warning'>You can't install this upgrade twice!</span>")
        return FALSE

    D.AddSpell(new /obj/effect/proc_holder/spell/no_target/drone_boost())
    installed = TRUE
    D.uplink.points -= cost
    return TRUE