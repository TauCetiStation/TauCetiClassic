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
        if(upgrade.cost <= points)
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

//==========Upgrade types==========
/datum/drone_upgrade
    var/name = null
    var/category = "upgrade category"
    var/desc = "upgrade description"
    var/list/items = null
    var/cost = 0

/datum/drone_upgrade/proc/install(mob/living/silicon/robot/drone/syndi/D)
    if(!items.len)
        return 0
    if(D.stat == DEAD)
        to_chat(D, "You can't be upgraded while you're dead!")
        return 0
    for(var/item_type in items)
        D.module.modules += new item_type(D.module)
    D.uplink.points -= cost
    return 1