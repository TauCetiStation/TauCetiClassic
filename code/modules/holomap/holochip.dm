/*
Files of holomap module:
code/modules/holomap/holochip.dm
code/datums/components/holomap.dm
code/modules/holomap/holochips.dm
*/
/obj/item/holochip
	name = "Holomap chip"
	desc = "A small holomap module, attached to helmets."
	icon = 'icons/holomaps/holochips.dmi'
	icon_state = "holochip"
	///Add any item to this list so it can be modified.
	var/list/allowed_items = list(/obj/item/clothing/head/helmet)

	///Holochip works only as a holder of actual holomap component, all acutal mapping logic on other side
	var/datum/component/holomap/map

/obj/item/holochip/atom_init(obj/item/I, my_holder)
	. = ..()
	map = AddComponent(/datum/component/holomap)
	if(is_type_in_list(I, allowed_items)) //You can basically add any atom here and it will do everything else
		map.holder = I
		RegisterSignal(map.holder, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
		RegisterSignal(map.holder, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
		RegisterSignal(map.holder, COMSIG_PARENT_QDELETING, PROC_REF(on_qdel))
		RegisterSignal(map.holder, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))

/obj/item/holochip/proc/on_qdel()
	SIGNAL_HANDLER
	map = null
	map.deactivate_holomap()
	qdel(map)

/obj/item/holochip/proc/on_equip(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	if(slot == SLOT_HEAD)
		if(user.hud_used) //NPCs don't need a map
			user.hud_used.init_screen(/atom/movable/screen/holomap)
		map.add_action(user)
		map.update_freq(map.frequency)

/obj/item/holochip/proc/on_drop(obj/item/source, mob/user)
	SIGNAL_HANDLER
	map.remove_action(user)
	map.deactivate_holomap()

/obj/item/holochip/proc/on_attackby(datum/source, obj/item/I, mob/living/user)
	SIGNAL_HANDLER
	if(!isscrewing(I))
		return
	map.remove_action(user)
	map.holder = null
	if(!user.put_in_hands(src))
		forceMove(get_turf(src))
	playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
	to_chat(user, "<span class='notice'>You remove the [src] from the [source]</span>")
	UnregisterSignal(map.holder, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(map.holder, COMSIG_ITEM_DROPPED)
	UnregisterSignal(map.holder, COMSIG_PARENT_QDELETING)
	UnregisterSignal(map.holder, COMSIG_PARENT_ATTACKBY)
	return COMPONENT_NO_AFTERATTACK

/obj/item/holochip/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(istype(target, /obj/item/clothing/head/helmet))
		if(target.flags & ABSTRACT)
			return    //You can't insert holochip in abstract item.
		var/obj/item/holochip/HC = locate(/obj/item/holochip) in target
		if(HC)
			to_chat(user, "<span class='notice'>The [target] is already modified with the [HC]</span>")
			return
		user.drop_from_inventory(src, target)
		map.holder = target
		var/mob/living/carbon/human/H = user
		if(istype(H) && H.head == target)
			on_equip()
		playsound(target, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You modify the [target] with the [src]</span>")
		RegisterSignal(map.holder, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
		RegisterSignal(map.holder, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
		RegisterSignal(map.holder, COMSIG_PARENT_QDELETING, PROC_REF(on_qdel))
		RegisterSignal(map.holder, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))

/obj/item/holochip/proc/add_action(mob/living/carbon/human/wearer)
	map.holomap_toggle_action.Grant(wearer)
	map.holomap_toggle_action.UpdateButtonIcon()

/obj/item/holochip/proc/remove_action(mob/living/carbon/human/wearer)
	map.holomap_toggle_action.Remove(wearer)

/obj/item/holochip/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/num_frequency = text2num(map.frequency)
	var/dat = {"<TT>
				<B>Transport layer</B> for holochip:<BR>
				Frequency:
				<A href='byond://?src=\ref[src];num_frequency=-10'>-</A>
				<A href='byond://?src=\ref[src];num_frequency=-1'>-</A>
				[format_frequency(num_frequency)]
				<A href='byond://?src=\ref[src];num_frequency=1'>+</A>
				<A href='byond://?src=\ref[src];num_frequency=10'>+</A><BR>
				Encryption:
				<A href='byond://?src=\ref[src];encryption=-100'>---</A>
				<A href='byond://?src=\ref[src];encryption=-50'>--</A>
				<A href='byond://?src=\ref[src];encryption=-10'>-</A>
				<A href='byond://?src=\ref[src];encryption=-1'>-</A>
				[map.encryption]
				<A href='byond://?src=\ref[src];encryption=1'>+</A>
				<A href='byond://?src=\ref[src];encryption=10'>+</A>
				<A href='byond://?src=\ref[src];encryption=50'>++</A>
				<A href='byond://?src=\ref[src];encryption=100'>+++</A><BR>
				</TT>"}
	map.frequency = num2text(num_frequency)

	var/datum/browser/popup = new(user, "holochip")
	popup.set_content(dat)
	popup.open()
	return ..()

/obj/item/holochip/Topic(href, href_list)
	if(usr.incapacitated() || !Adjacent(usr) || !ishuman(usr))
		usr << browse(null, "window=holochip")
		onclose(usr, "holochip")
		return

	if (href_list["frequency"])
		var/new_frequency = (map.frequency + text2num(href_list["frequency"]))
		if(new_frequency < 1200)
			new_frequency = 1200
		else if(new_frequency > 1600)
			new_frequency = 1600
		map.frequency = new_frequency

	if(href_list["encryption"])
		map.encryption += text2num(href_list["encryption"])
		map.encryption = round(map.encryption)
		map.encryption = min(1000, map.encryption)
		map.encryption = max(1, map.encryption)
	attack_self(usr)
	map.update_freq(map.frequency)

	updateUsrDialog()
