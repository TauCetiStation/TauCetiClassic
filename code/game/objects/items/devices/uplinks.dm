//This could either be split into the proper DM files or placed somewhere else all together, but it'll do for now -Nodrak

/*

A list of items and costs is stored under the datum of every game mode, alongside the number of crystals, and the welcoming message.

*/
//TG-stuff
/obj/item/device/uplink
	var/welcome = "Syndicate Uplink Console:"					// Welcoming menu message
	var/uses = 20 						// Numbers of crystals
	// List of items not to shove in their hands.
	var/active = 0
	var/uplink_type = "traitor" //0 - traitor uplink, 1 - nuke
	var/list/uplink_items = list()
	var/list/extra_purchasable = list()

// Interaction code. Gathers a list of items purchasable from the paren't uplink and displays it. It also adds a lock button.
/obj/item/device/uplink/interact(mob/user)
	var/dat = ""
	dat += "<B>[src.welcome]</B><BR>"
	dat += "Tele-Crystals left: [src.uses]<BR>"
	dat += "<HR>"
	dat += "<B>Request item:</B><BR>"
	dat += "<I>Each item costs a number of tele-crystals as indicated by the number following their name.</I><br><BR>"

	if(uplink_items.len)
		uplink_items.Cut()
	var/list/buyable_items = get_uplink_items(src)

	// Loop through categories
	var/index = 0
	for(var/category in buyable_items)

		index++
		dat += "<b>[category]</b><br>"

		var/i = 0

		// Loop through items in category
		for(var/datum/uplink_item/item in buyable_items[category])
			i++
			var/cost_text = ""
			if(item.cost > 0)
				cost_text = "([item.cost])"
			if(item.cost <= uses)
				dat += "<A href='byond://?src=\ref[src];buy_item=[category]:[i];'>[item.name]</A> [cost_text] "
			else
				dat += "<span class='disabled'>[item.name] [cost_text]</span>"
			if(item.desc)
				dat += "<span class='spoiler'><input type='checkbox' id='[item.name]'>"
				dat += "<label for='[item.name]'><b>\[?\]</b></label>"
				dat += "<div>[item.desc]</div>"
				dat += "</span>"
			dat += "<br>"

		// Break up the categories, if it isn't the last.
		if(buyable_items.len != index)
			dat += "<br>"

	dat += "<HR>"
	dat += "<A href='byond://?src=\ref[src];lock=1'>Lock</a>"

	var/datum/browser/popup = new(user, "hidden", "Syndicate Uplink", 450, 550, ntheme = CSS_THEME_SYNDICATE)
	popup.set_content(dat)
	popup.open()
	return


/obj/item/device/uplink/Topic(href, href_list)
	..()

	if(!active)
		return

	if (href_list["buy_item"])

		var/item = href_list["buy_item"]
		var/list/split = splittext(item, ":") // throw away variable

		if(split.len == 2)
			// Collect category and number
			var/category = split[1]
			var/number = text2num(split[2])

			var/list/buyable_items = get_uplink_items(src)
			var/list/uplink = buyable_items[category]
			if(uplink && uplink.len >= number)
				var/datum/uplink_item/I = uplink[number]
				if(I)
					I.buy(src, usr)
					if(I.limited_stock)
						buyable_items -= I
						extra_purchasable -= I
					interact(usr)


// HIDDEN UPLINK - Can be stored in anything but the host item has to have a trigger for it.
/* How to create an uplink in 3 easy steps!

 1. All obj/item 's have a hidden_uplink var. By default it's null. Give the item one with "new(src)", it must be in it's contents. Feel free to add "uses".

 2. Code in the triggers. Use check_trigger for this, I recommend closing the item's menu with "usr << browse(null, "window=windowname") if it returns true.
 The var/value is the value that will be compared with the var/target. If they are equal it will activate the menu.

 3. If you want the menu to stay until the users locks his uplink, add an active_uplink_check(mob/user as mob) in your interact/attack_hand proc.
 Then check if it's true, if true return. This will stop the normal menu appearing and will instead show the uplink menu.
*/

/obj/item/device/uplink/hidden
	name = "hidden uplink."
	desc = "There is something wrong if you're examining this."

/obj/item/device/uplink/hidden/Topic(href, href_list)
	..()
	if(href_list["lock"])
		toggle()
		usr << browse(null, "window=hidden")
		return 1

// Toggles the uplink on and off. Normally this will bypass the item's normal functions and go to the uplink menu, if activated.
/obj/item/device/uplink/hidden/proc/toggle()
	active = !active

// Directly trigger the uplink. Turn on if it isn't already.
/obj/item/device/uplink/hidden/proc/trigger(mob/user)
	if(!active)
		toggle()
	interact(user)

// Checks to see if the value meets the target. Like a frequency being a traitor_frequency, in order to unlock a headset.
// If true, it accesses trigger() and returns 1. If it fails, it returns false. Use this to see if you need to close the
// current item's menu.
/obj/item/device/uplink/hidden/proc/check_trigger(mob/user, value, target)
	if(value == target)
		trigger(user)
		return 1
	return 0

// I placed this here because of how relevant it is.
// You place this in your uplinkable item to check if an uplink is active or not.
// If it is, it will display the uplink menu and return 1, else it'll return false.
// If it returns true, I recommend closing the item's normal menu with "user << browse(null, "window=name")"
/obj/item/proc/active_uplink_check(mob/user as mob)
	// Activates the uplink if it's active
	if(src.hidden_uplink)
		if(src.hidden_uplink.active)
			hidden_uplink.trigger(user)
			return 1
	return 0

//Refund proc for the borg teleporter (later I'll make a general refund proc if there is demand for it)
/obj/item/device/radio/uplink/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/antag_spawner/borg_tele))
		var/obj/item/weapon/antag_spawner/borg_tele/S = I
		if(!S.used)
			hidden_uplink.uses += S.TC_cost
			qdel(S)
			to_chat(user, "<span class='notice'>Teleporter refunded.</span>")
		else
			to_chat(user, "<span class='notice'>This teleporter is already used.</span>")

	else
		return ..()

// PRESET UPLINKS
// A collection of preset uplinks.
//
// Includes normal radio uplink, multitool uplink,
// implant uplink (not the implant tool) and a preset headset uplink.

/obj/item/device/radio/uplink
	icon_state = "radio"

/obj/item/device/radio/uplink/atom_init()
	. = ..()
	hidden_uplink = new(src)
	hidden_uplink.uplink_type = "nuclear"

	hidden_uplink.extra_purchasable += create_uplink_sales(rand(2,3), "Discounts", TRUE, get_uplink_items(hidden_uplink))

	var/datum/faction/nuclear/F = find_faction_by_type(/datum/faction/nuclear)
	if(!F)
		return
	if(!F.team_discounts.len)
		F.team_discounts += create_uplink_sales(rand(3,5), "Team Discounts", FALSE, get_uplink_items(hidden_uplink))
	hidden_uplink.extra_purchasable += F.team_discounts

/obj/item/device/radio/uplink/attack_self(mob/user)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/radio/uplink/strike/atom_init()
	. = ..()
	hidden_uplink.uses = 10

/obj/item/device/radio/uplink/strike_leader/atom_init()
	. = ..()
	hidden_uplink.uses = 15

/obj/item/device/radio/uplink/nukeop_leader/atom_init()
	. = ..()
	hidden_uplink.uses = 75

/obj/item/device/multitool/uplink/atom_init()
	. = ..()
	hidden_uplink = new(src)

/obj/item/device/multitool/uplink/attack_self(mob/user)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/radio/headset/uplink
	traitor_frequency = 1445

/obj/item/device/radio/headset/uplink/atom_init()
	. = ..()
	hidden_uplink = new(src)
	hidden_uplink.uses = 20
