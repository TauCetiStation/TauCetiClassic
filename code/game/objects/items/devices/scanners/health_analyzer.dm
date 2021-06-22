/obj/item/device/healthanalyzer
	name = "Health Analyzer"
	icon_state = "health"
	item_state = "healthanalyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 3
	w_class = SIZE_TINY
	throw_speed = 5
	throw_range = 10
	m_amt = 200
	origin_tech = "magnets=1;biotech=1"
	var/mode = TRUE
	var/output_to_chat = TRUE
	var/last_scan = ""
	var/last_scan_name = ""

/obj/item/device/healthanalyzer/attack(mob/living/M, mob/living/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.flags[IS_SYNTHETIC] || H.species.flags[IS_PLANT])
			var/message = ""
			message += "<span class = 'notice'>Analyzing Results for ERROR:\n&emsp; Overall Status: ERROR</span><br>"
			message += "&emsp; Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font><br>"
			message += "&emsp; Damage Specifics: <font color='blue'>?</font> - <font color='green'>?</font> - <font color='#FFA500'>?</font> - <font color='red'>?</font><br>"
			message += "<span class = 'notice'>Body Temperature: [H.bodytemperature-T0C]&deg;C ([H.bodytemperature*1.8-459.67]&deg;F)</span><br>"
			message += "<span class = 'warning bold'>Warning: Blood Level ERROR: --% --cl.</span><span class = 'notice bold'>Type: ERROR</span><br>"
			message += "<span class = 'notice'>Subject's pulse:</span><font color='red'>-- bpm.</font><br>"

			last_scan = message
			last_scan_name = M.name
			if(!output_to_chat)
				var/datum/browser/popup = new(user, "[M.name]_scan_report", "[M.name]'s scan results", 400, 400, ntheme = CSS_THEME_LIGHT)
				popup.set_content(message)
				popup.open()
			else
				to_chat(user, message)

			add_fingerprint(user)
			return
		else
			add_fingerprint(user)
			var/dat = health_analyze(M, user, mode, output_to_chat)
			last_scan = dat
			last_scan_name = M.name
			if(!output_to_chat)
				var/datum/browser/popup = new(user, "[M.name]_scan_report", "[M.name]'s scan results", 400, 400, ntheme = CSS_THEME_LIGHT)
				popup.set_content(dat)
				popup.open()
			else
				to_chat(user, dat)
	else
		add_fingerprint(user)
		to_chat(user, "<span class = 'warning'>Analyzing Results not compiled. Unknown anatomy detected.</span>")

/obj/item/device/healthanalyzer/attack_self(mob/user)
	var/datum/browser/popup = new(user, "[last_scan_name]_scan_report", "[last_scan_name]'s scan results", 400, 400, ntheme = CSS_THEME_LIGHT)
	popup.set_content(last_scan)
	popup.open()

/obj/item/device/healthanalyzer/verb/toggle_output()
	set name = "Toggle Output"
	set category = "Object"

	output_to_chat = !output_to_chat
	if(output_to_chat)
		to_chat(usr, "The scanner now outputs data to chat.")
	else
		to_chat(usr, "The scanner now outputs data in a seperate window.")

/obj/item/device/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	mode = !mode
	if(mode)
		to_chat(usr, "The scanner now shows specific limb damage.")
	else
		to_chat(usr, "The scanner no longer shows limb damage.")

/obj/item/device/healthanalyzer/rad_laser
	materials = list(MAT_METAL=400)
	origin_tech = "magnets=3;biotech=5;syndicate=3"
	var/irradiate = 1
	var/intensity = 10 // how much damage the radiation does
	var/wavelength = 10 // time it takes for the radiation to kick in, in seconds
	var/used = 0 // is it cooling down?

/obj/item/device/healthanalyzer/rad_laser/attack(mob/living/M, mob/living/user)
	..()
	if(!irradiate)
		return
	if(!used)
		var/cooldown = round(max(10, (intensity*5 - wavelength/4))) * 10
		used = 1
		icon_state = "health1"
		spawn(cooldown) // splits off to handle the cooldown while handling wavelength
			used = 0
			icon_state = "health"
		to_chat(user,"<span class='warning'>Successfully irradiated [M].</span>")
		M.log_combat(user, "irradiated with [name]")
		spawn((wavelength+(intensity*4))*5)
			if(M)
				if(intensity >= 5)
					M.apply_effect(round(intensity/1.5), PARALYZE)
				M.apply_effect(intensity * 10,IRRADIATE, 0)
	else
		to_chat(user,"<span class='warning'>The radioactive microlaser is still recharging.</span>")

/obj/item/device/healthanalyzer/rad_laser/attack_self(mob/user)
	interact(user)

/obj/item/device/healthanalyzer/rad_laser/interact(mob/user)
	user.set_machine(src)
	var/cooldown = round(max(10, (intensity*5 - wavelength/4)))
	var/dat = "Irradiation: <A href='?src=\ref[src];rad=1'>[irradiate ? "On" : "Off"]</A><br>"

	dat += {"
	Radiation Intensity:
	<A href='?src=\ref[src];radint=-5'>-</A><A href='?src=\ref[src];radint=-1'>-</A>
	[intensity]
	<A href='?src=\ref[src];radint=1'>+</A><A href='?src=\ref[src];radint=5'>+</A><BR>

	Radiation Wavelength:
	<A href='?src=\ref[src];radwav=-5'>-</A><A href='?src=\ref[src];radwav=-1'>-</A>
	[(wavelength+(intensity*4))]
	<A href='?src=\ref[src];radwav=1'>+</A><A href='?src=\ref[src];radwav=5'>+</A><BR>
	Laser Cooldown: [cooldown] Seconds<BR>
	"}

	var/datum/browser/popup = new(user, "radlaser", "Radioactive Microlaser Interface", 400, 240)
	popup.set_content(dat)
	popup.open()

/obj/item/device/healthanalyzer/rad_laser/Topic(href, href_list)

	usr.set_machine(src)
	if(href_list["rad"])
		irradiate = !irradiate

	else if(href_list["radint"])
		var/amount = text2num(href_list["radint"])
		amount += intensity
		intensity = max(1,(min(20,amount)))

	else if(href_list["radwav"])
		var/amount = text2num(href_list["radwav"])
		amount += wavelength
		wavelength = max(0,(min(120,amount)))

	attack_self(usr)
	add_fingerprint(usr)
	return
