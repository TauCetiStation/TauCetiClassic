/obj/item/device/paicard
	name = "personal AI device"
	icon = 'icons/obj/pda.dmi'
	icon_state = "pai"
	item_state_world = "paioff_world"
	item_state = "electronic"
	flags = HEAR_PASS_SAY
	w_class = SIZE_TINY
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "programming=2"
	var/obj/item/device/radio/radio
	var/looking_for_personality = 0
	var/mob/living/silicon/pai/pai
	var/searching = FALSE
	var/prev_emotion = 6

/obj/item/device/paicard/atom_init()
	. = ..()
	paicard_list += src

/obj/item/device/paicard/Destroy()
	paicard_list -= src
	//Will stop people throwing friend pAIs into the singularity so they can respawn
	if(!isnull(pai))
		pai.death(0)
	return ..()

/obj/item/device/paicard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/paper = I
		if(paper.crumpled)
			to_chat(usr, "Paper to crumpled for anything.")
			return
		var/itemname = paper.name
		var/info = paper.info
		to_chat(user, "You hold \the [itemname] up to the pAI...")
		if(pai.client && !(pai.stat == DEAD))
			to_chat(pai, "[user.name] holds \a [itemname] up to one of your camera...")

			var/datum/browser/popup = new(pai, itemname, itemname)
			popup.set_content("<TT>[info]</TT>")
			popup.open()

	else
		return ..()

/obj/item/device/paicard/attack_self(mob/user)
	if (!Adjacent(user))
		return
	user.set_machine(src)
	var/dat = {"
		<!DOCTYPE html>
		<html>
			<head>
				<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
				<style>
					body {
					    margin-top:5px;
					    font-family:Verdana;
					    color:white;
					    font-size:13px;
					    background-image:url('uiBackground.png');
					    background-repeat:repeat-x;
					    background-color:#272727;
						background-position:center top;
					}
					table {
					    font-size:13px;
					    margin-left:-2px;
					}
					table.request {
					    border-collapse:collapse;
					}
					table.desc {
					    border-collapse:collapse;
					    font-size:13px;
					    border: 1px solid #161616;
					    width:100%;
					}
					table.download {
					    border-collapse:collapse;
					    font-size:13px;
					    border: 1px solid #161616;
					    width:100%;
					}
					tr.d0 td, tr.d0 th {
					    background-color: #506070;
					    color: white;
					}
					tr.d1 td, tr.d1 th {
					    background-color: #708090;
					    color: white;
					}
					tr.d2 td {
					    background-color: #00FF00;
					    color: white;
					    text-align:center;
					}
					td.button {
					    border: 1px solid #161616;
					    background-color: #40628a;
					}
					td.button {
					    border: 1px solid #161616;
					    background-color: #40628a;
					    text-align: center;
					}
					td.button_red {
					    border: 1px solid #161616;
					    background-color: #B04040;
					    text-align: center;
					}
					td.download {
					    border: 1px solid #161616;
					    background-color: #40628a;
					    text-align: center;
					}
					th {
					    text-align:left;
					    width:125px;
					}
					td.request {
					    width:140px;
					    vertical-align:top;
					}
					td.radio {
					    width:90px;
					    vertical-align:top;
					}
					td.request {
					    vertical-align:top;
					}
					a {
					    color:#4477E0;
					}
					a.button {
					    color:white;
					    text-decoration: none;
					}
					h2 {
					    font-size:15px;
					}
				</style>
				[get_browse_zoom_style(user.client)]
			</head>
			<body>
	"}

	if(pai)
		dat += {"
			<b><font size='3px'>Personal AI Device</font></b><br><br>
			<table class="request">
				<tr>
					<td class="request">Installed Personality:</td>
					<td>[pai.name]</td>
				</tr>
				<tr>
					<td class="request">Prime directive:</td>
					<td>[pai.laws.zeroth]</td>
				</tr>
				<tr>
					<td class="request">Additional directives:</td>
					<td>[jointext(pai.laws.supplied, "<br>")]</td>
				</tr>
			</table>
			<br>
		"}
		dat += {"
			<table>
				<td class="button">
					<a href='byond://?src=\ref[src];setlaws=1' class='button'>Configure Directives</a>
				</td>
			</table>
		"}
		if(!pai.master_dna || !pai.master)
			dat += {"
				<table>
					<td class="button">
						<a href='byond://?src=\ref[src];setdna=1' class='button'>Imprint Master DNA</a>
					</td>
				</table>
			"}
		dat += "<br>"
		if(radio && radio.wires)
			dat += "<b>Radio Uplink</b>"
			dat += {"
				<table class="request">
					<tr>
						<td class="radio">Transmit:</td>
						<td><a href='byond://?src=\ref[src];wires=4'>[!radio.wires.is_index_cut(RADIO_WIRE_TRANSMIT) ? "<font color=#55FF55>Enabled</font>" : "<font color=#FF5555>Disabled</font>" ]</a>

						</td>
					</tr>
					<tr>
						<td class="radio">Receive:</td>
						<td><a href='byond://?src=\ref[src];wires=2'>[!radio.wires.is_index_cut(RADIO_WIRE_RECEIVE) ? "<font color=#55FF55>Enabled</font>" : "<font color=#FF5555>Disabled</font>" ]</a>

						</td>
					</tr>
					<tr>
						<td class="radio">Signal Pulser:</td>
						<td><a href='byond://?src=\ref[src];wires=1'>[!radio.wires.is_index_cut(RADIO_WIRE_SIGNAL) ? "<font color=#55FF55>Enabled</font>" : "<font color=#FF5555>Disabled</font>" ]</a>

						</td>
					</tr>
				</table>
				<br>
			"}
		else
			dat += "<b>Radio Uplink</b><br>"
			dat += "<font color=red><i>Radio firmware not loaded. Please install a pAI personality to load firmware.</i></font><br>"
		dat += {"
			<table>
				<td class="button_red"><a href='byond://?src=\ref[src];wipe=1' class='button'>Wipe current pAI personality</a>

				</td>
			</table>
		"}
	else
		if(looking_for_personality)
			dat += {"
				<b><font size='3px'>pAI Request Module</font></b><br><br>
				<p>Requesting AI personalities from central database... If there are no entries, or if a suitable entry is not listed, check again later as more personalities may be added.</p>
				Searching for personalities, please wait...<br><br>

				<table>
					<tr>
						<td class="button">
							<a href='byond://?src=\ref[src];request=1' class="button">Refresh available personalities</a>
						</td>
					</tr>
				</table><br>
			"}
		else
			dat += {"
				<b><font size='3px'>pAI Request Module</font></b><br><br>
			    <p>No personality is installed.</p>
				<table>
					<tr>
						<td class="button"><a href='byond://?src=\ref[src];request=1' class="button">Request personality</a>
						</td>
					</tr>
				</table>
				<br>
				<p>Each time this button is pressed, a request will be sent out to any available personalities. Check back often give plenty of time for personalities to respond. This process could take anywhere from 15 seconds to several minutes, depending on the available personalities' timeliness.</p>
			"}
	user << browse(dat, "window=paicard")
	onclose(user, "paicard")
	return

/obj/item/device/paicard/Topic(href, href_list)

	if(!usr || usr.incapacitated())
		return

	if(href_list["setdna"])
		if(pai.master_dna)
			return
		var/mob/M = usr
		if(!ishuman(M))
			to_chat(usr, "<font color=blue>You don't have any DNA, or your DNA is incompatible with this device.</font>")
		else
			var/mob/living/carbon/human/H = M
			if(!H.dna.unique_enzymes)
				to_chat(H, "<span class='warning'>No DNA was found.</span>")
				return
			var/datum/dna/dna = usr.dna
			pai.master = M.real_name
			pai.master_dna = dna.unique_enzymes
			to_chat(pai, "<font color = red><h3>You have been bound to a new master.</h3></font>")
	if(href_list["request"])
		src.looking_for_personality = 1
		paiController.findPAI(src, usr)
	if(href_list["wipe"])
		var/confirm = input("Are you CERTAIN you wish to delete the current personality? This action cannot be undone.", "Personality Wipe") in list("Yes", "No")
		if(confirm == "Yes")
			for(var/mob/M in src)
				to_chat(M, "<font color = #ff0000><h2>You feel yourself slipping away from reality.</h2></font>")
				to_chat(M, "<font color = #ff4d4d><h3>Byte by byte you lose your sense of self.</h3></font>")
				to_chat(M, "<font color = #ff8787><h4>Your mental faculties leave you.</h4></font>")
				to_chat(M, "<font color = #ffc4c4><h5>oblivion... </h5></font>")
				M.death(0)
			removePersonality()
	if(href_list["wires"])
		var/t1 = text2num(href_list["wires"])
		radio.wires.cut_wire_index(t1)
	if(href_list["setlaws"])
		var/newlaws = sanitize(input("Enter any additional directives you would like your pAI personality to follow. Note that these directives will not override the personality's allegiance to its imprinted master. Conflicting directives will be ignored.", "pAI Directive Configuration", pai.laws.supplied.len ? pai.laws.supplied[1] : "") as message)
		if(newlaws)
			pai.laws.add_supplied_law(0, newlaws)
			to_chat(pai, "Your supplemental directives have been updated. Your new directives are:")
			to_chat(pai, "Prime Directive: <br>[pai.laws.zeroth]")
			to_chat(pai, "Supplemental Directives: <br>[jointext(pai.laws.supplied, "<br>")]")
	attack_self(usr)

// 		WIRE_SIGNAL = 1
//		WIRE_RECEIVE = 2
//		WIRE_TRANSMIT = 4

/obj/item/device/paicard/proc/reset_searching()
	searching = FALSE

/obj/item/device/paicard/proc/setPersonality(mob/living/silicon/pai/personality)
	src.pai = personality
	if(icon_state != item_state_world)
		prev_emotion = 1
		cut_overlays()
		add_overlay("pai-happy")
	else
		prev_emotion = 1

/obj/item/device/paicard/proc/removePersonality()
	src.pai = null
	if(icon_state != item_state_world)
		prev_emotion = 6
		cut_overlays()
		add_overlay("pai-off")
	else
		prev_emotion = 6

/obj/item/device/paicard/proc/setEmotion(emotion)
	if(pai && icon_state != item_state_world)
		cut_overlays()
		prev_emotion = emotion
		switch(emotion)
			if(1) add_overlay("pai-happy")
			if(2) add_overlay("pai-cat")
			if(3) add_overlay("pai-extremely-happy")
			if(4) add_overlay("pai-face")
			if(5) add_overlay("pai-laugh")
			if(6) add_overlay("pai-off")
			if(7) add_overlay("pai-sad")
			if(8) add_overlay("pai-angry")
			if(9) add_overlay("pai-what")
	else
		switch(emotion)
			if(1) prev_emotion = 1
			if(2) prev_emotion = 2
			if(3) prev_emotion = 3
			if(4) prev_emotion = 4
			if(5) prev_emotion = 5
			if(6) prev_emotion = 6
			if(7) prev_emotion = 7
			if(8) prev_emotion = 8
			if(9) prev_emotion = 9


/obj/item/device/paicard/proc/alertUpdate()
	visible_message("<span class='notice'>[src] flashes a message across its screen, \"Additional personalities available for download.\"</span>", "<span class='notice'>[src] bleeps electronically.</span>")

/obj/item/device/paicard/emp_act(severity)
	for(var/mob/M in src)
		M.emplode(severity)
	..()

/obj/item/device/paicard/get_listeners()
	. = list()
	if(pai)
		. += pai

/obj/item/device/paicard/dropped(mob/user)
	. = ..()
	cut_overlays()
	if(pai)
		item_state_world = "pai_world"
	else
		item_state_world = "paioff_world"

/obj/item/device/paicard/mob_pickup(mob/user, hand_index)
	. = ..()
	setEmotion(prev_emotion)
