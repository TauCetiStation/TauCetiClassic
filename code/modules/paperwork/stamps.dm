#define STAMP_OFFSET_DOTS_X 5
#define STAMP_OFFSET_DOTS_Y 5
#define STAMP_OFFSET_CIRCLE_X 2
#define STAMP_OFFSET_CIRCLE_Y 2

/obj/item/weapon/stamp
	name = "rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp"
	item_state = "stamp"
	throwforce = 0
	w_class = SIZE_MINUSCULE
	throw_speed = 4
	throw_range = 15
	m_amt = 60
	hitsound = list('sound/effects/stamp.ogg') //taken from Baystation build
	var/dye_color = DYE_CARGO
	attack_verb = list("stamped")
	var/stamp_message = "Stamp"
	var/stamp_color = "#b25266"
	var/stamp_border_color = "#753643"
	var/stamp_border_style = "solid"
	var/stamp_paper_overlay = "paper_stamp-dots"
	var/stamp_big = FALSE
	var/stamp_handle_colored = FALSE
	var/stamp_max_offset_x = STAMP_OFFSET_DOTS_X
	var/stamp_max_offset_y = STAMP_OFFSET_DOTS_Y

/obj/item/weapon/stamp/update_icon()
	cut_overlays()
	if (stamp_handle_colored)
		var/image/handle_overlay = image("icon" = icon, "icon_state" = "stamp_handle")
		handle_overlay.color = stamp_color
		add_overlay(handle_overlay)

	var/image/pad_overlay = image("icon" = icon, "icon_state" = "stamp_pad")
	pad_overlay.color = stamp_color
	add_overlay(pad_overlay)

	var/image/pad_border_overlay = image("icon" = icon, "icon_state" = "stamp_pad-border")
	pad_border_overlay.color = stamp_border_color
	add_overlay(pad_border_overlay)

/obj/item/weapon/stamp/atom_init()
	. = ..()
	update_icon()

/obj/item/weapon/stamp/cap
	name = "captain's rubber stamp"
	dye_color = DYE_CAPTAIN
	stamp_message = "Captain"
	stamp_color = "#2b4e95"
	stamp_border_color = "#1c3362"
	stamp_paper_overlay = "paper_stamp-circle"
	stamp_big = TRUE
	stamp_handle_colored = TRUE
	stamp_max_offset_x = STAMP_OFFSET_CIRCLE_X
	stamp_max_offset_y = STAMP_OFFSET_CIRCLE_Y

/obj/item/weapon/stamp/cap/atom_init()
	. = ..()
	stamp_message = "[station_name()]"

/obj/item/weapon/stamp/hop
	name = "head of personnel's rubber stamp"
	dye_color = DYE_HOP
	stamp_message = "Head of Personnel"
	stamp_color = "#2789cd"
	stamp_border_color = "#1a5a87"
	stamp_handle_colored = TRUE

/obj/item/weapon/stamp/sec
	name = "security rubber stamp"
	dye_color = DYE_HOS
	stamp_message = "Security"
	stamp_color = "#b9451d"
	stamp_border_color = "#7a2d13"

/obj/item/weapon/stamp/sec/hos
	name = "head of security's rubber stamp"
	stamp_message = "Head of Security"
	stamp_handle_colored = TRUE

/obj/item/weapon/stamp/eng
	name = "engineering rubber stamp"
	dye_color = DYE_CE
	stamp_message = "Engineering"
	stamp_color = "#d39741"
	stamp_border_color = "#8b632b"

/obj/item/weapon/stamp/eng/ce
	name = "chief engineer's rubber stamp"
	stamp_message = "Chief Engineer"
	stamp_handle_colored = TRUE

/obj/item/weapon/stamp/sci
	name = "research division rubber stamp"
	dye_color = DYE_RD
	stamp_message = "Research Division"
	stamp_color = "#7864c6"
	stamp_border_color = "#4f4282"

/obj/item/weapon/stamp/sci/rd
	name = "research director's rubber stamp"
	stamp_message = "Research Director"
	stamp_handle_colored = TRUE

/obj/item/weapon/stamp/med
	name = "medbay rubber stamp"
	dye_color = DYE_CMO
	stamp_message = "Medbay"
	stamp_color = "#42bfe8"
	stamp_border_color = "#2b7e99"

/obj/item/weapon/stamp/med/cmo
	name = "chief medical officer's rubber stamp"
	stamp_message = "Chief Medical Officer"
	stamp_handle_colored = TRUE

/obj/item/weapon/stamp/cargo
	name = "supply rubber stamp"
	dye_color = DYE_QM
	stamp_message = "Supply"
	stamp_color = "#b25266"
	stamp_border_color = "#753643"

/obj/item/weapon/stamp/cargo/qm
	name = "quartermaster's rubber stamp"
	stamp_message = "Quartermaster"
	stamp_handle_colored = TRUE

/obj/item/weapon/stamp/approve
	name = "APPROVED rubber stamp"
	dye_color = DYE_GREENCOAT
	stamp_message = "APPROVED"
	stamp_color = "#61a53f"
	stamp_border_color = "#406d2a"
	stamp_paper_overlay = "paper_stamp-check"
	stamp_big = TRUE
	stamp_max_offset_x = STAMP_OFFSET_CIRCLE_X - 1

/obj/item/weapon/stamp/denied
	name = "DENIED rubber stamp"
	dye_color = DYE_REDCOAT
	stamp_message = "DENIED"
	stamp_color = "#bd1039"
	stamp_border_color = "#7d0b26"
	stamp_paper_overlay = "paper_stamp-x"
	stamp_big = TRUE

/obj/item/weapon/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	dye_color = DYE_CLOWN
	stamp_message = "HONK!"
	stamp_color = "#f500f5"
	stamp_border_color = "#bf3fbf"
	stamp_paper_overlay = "paper_stamp-honk"
	stamp_big = TRUE
	stamp_max_offset_x = 3
	stamp_max_offset_y = 5

/obj/item/weapon/stamp/law
	name = "lawyer's rubber stamp"
	dye_color = DYE_REDCOAT
	stamp_message = "Lawyer"
	stamp_color = "#8aa1f6"
	stamp_border_color = "#5b6aa2"
	stamp_paper_overlay = "paper_stamp-circle"
	stamp_big = TRUE
	stamp_max_offset_x = STAMP_OFFSET_CIRCLE_X
	stamp_max_offset_y = STAMP_OFFSET_CIRCLE_Y

/obj/item/weapon/stamp/iaa
	name = "internal affairs rubber stamp"
	dye_color = DYE_IAA
	stamp_message = "Internal Affairs"
	stamp_color = "#323232"
	stamp_border_color = "#212121"
	stamp_paper_overlay = "paper_stamp-circle"
	stamp_big = TRUE
	stamp_handle_colored = TRUE
	stamp_max_offset_x = STAMP_OFFSET_CIRCLE_X
	stamp_max_offset_y = STAMP_OFFSET_CIRCLE_Y

/obj/item/weapon/stamp/centcomm
	name = "centcomm rubber stamp"
	dye_color = DYE_CENTCOMM
	stamp_message = "Central Command"
	stamp_color = "#61a53f"
	stamp_border_color = "#406d2a"
	stamp_paper_overlay = "paper_stamp-circle"
	stamp_big = TRUE
	stamp_handle_colored = TRUE
	stamp_max_offset_x = STAMP_OFFSET_CIRCLE_X
	stamp_max_offset_y = STAMP_OFFSET_CIRCLE_Y

/obj/item/weapon/stamp/fakecentcomm
	name = "cantcom rubber stamp"
	dye_color = DYE_FAKECENTCOM
	stamp_message = "Central Compound"
	stamp_color = "#61a53f"
	stamp_border_color = "#61a53f"
	stamp_paper_overlay = "paper_stamp-circle"
	stamp_big = TRUE
	stamp_handle_colored = TRUE
	stamp_max_offset_x = STAMP_OFFSET_CIRCLE_X
	stamp_max_offset_y = STAMP_OFFSET_CIRCLE_Y

/obj/item/weapon/stamp/syndicate
	name = "syndicate rubber stamp"
	dye_color = DYE_SYNDICATE
	stamp_message = "Syndicate Command"
	stamp_color = "#bd1039"
	stamp_border_color = "#7d0b26"
	stamp_paper_overlay = "paper_stamp-s"
	stamp_big = TRUE
	stamp_handle_colored = TRUE
	stamp_max_offset_x = 6
	stamp_max_offset_y = 2

/obj/item/weapon/stamp/cargo_industries
	name = "cargo industries rubber stamp"
	stamp_message = "Cargo Industries"
	stamp_color = "#b25266"
	stamp_border_color = "#753643"
	stamp_paper_overlay = "paper_stamp-circle"
	stamp_big = TRUE
	stamp_handle_colored = TRUE
	stamp_max_offset_x = STAMP_OFFSET_CIRCLE_X
	stamp_max_offset_y = STAMP_OFFSET_CIRCLE_Y

/obj/item/weapon/stamp/velocity
	name = "velocity rubber stamp"
	stamp_message = "НТС Велосити"
	stamp_color = "#a8a8a8"
	stamp_border_color = "#4572e3"
	stamp_paper_overlay = "paper_stamp-circle"
	stamp_big = TRUE
	stamp_handle_colored = TRUE
	stamp_max_offset_x = STAMP_OFFSET_CIRCLE_X
	stamp_max_offset_y = STAMP_OFFSET_CIRCLE_Y

/obj/item/weapon/stamp/copy_correct
	name = "copy is correct rubber stamp"
	dye_color = DYE_HOP
	stamp_message = "Копия верна"
	stamp_color = "#2789cd"
	stamp_border_color = "#1a5a87"
	stamp_border_style = "dashed"

// Syndicate stamp to forge documents.
/obj/item/weapon/stamp/chameleon/attack_self(mob/user)

	var/list/stamp_types = typesof(/obj/item/weapon/stamp) - src.type // Get all stamp types except our own
	var/list/stamps = list()

	// Generate them into a list
	for(var/stamp_type in stamp_types)
		var/obj/item/weapon/stamp/S = new stamp_type
		stamps[capitalize(S.name)] = S

	var/list/show_stamps = sortList(stamps) // the list that will be shown to the user to pick from

	var/input_stamp = input(user, "Choose a stamp to disguise as.", "Choose a stamp.") as null|anything in show_stamps

	if(user && loc == user)
		var/obj/item/weapon/stamp/chosen_stamp = stamps[capitalize(input_stamp)]

		if(chosen_stamp)
			name = chosen_stamp.name
			icon_state = chosen_stamp.icon_state
			dye_color = chosen_stamp.dye_color
			stamp_message = chosen_stamp.stamp_message
			stamp_color = chosen_stamp.stamp_color
			stamp_border_color = chosen_stamp.stamp_border_color
			stamp_border_style = chosen_stamp.stamp_border_style
			stamp_paper_overlay = chosen_stamp.stamp_paper_overlay
			stamp_big = chosen_stamp.stamp_big
			stamp_handle_colored = chosen_stamp.stamp_handle_colored
			stamp_max_offset_x = chosen_stamp.stamp_max_offset_x
			stamp_max_offset_y = chosen_stamp.stamp_max_offset_y

			update_icon()

/obj/item/weapon/stamp/proc/stamp_paper(obj/item/weapon/paper/P, stamp_text)
	if (P.stamp_text && P.stamp_text != "")
		P.stamp_text += "<br>"

	var/message = stamp_text ? stamp_text : stamp_message
	if (stamp_big)
		P.stamp_text += "<div style=\"margin-top:20px;\"><font size=\"5\"><div style=\"border-color:[stamp_border_color];color:[stamp_color];display:inline;border-width:5px;border-style:double;padding:3px\">[message]</div></font></div>"
	else
		P.stamp_text += "<div style=\"margin-top:20px;margin-left:3px\"><font size=\"5\"><div style=\"border-color:[stamp_border_color];color:[stamp_color];display:inline;border-width:2px;border-style:[stamp_border_style];padding:3px\">[message]</div></font></div>"

	LAZYADD(P.stamped, type)

	var/x = rand(0, stamp_max_offset_x)
	var/y = rand(0, stamp_max_offset_y)

	var/image/stamp_overlay = image("icon" = icon, "icon_state" = stamp_paper_overlay)
	stamp_overlay.appearance_flags |= KEEP_TOGETHER
	stamp_overlay.color = stamp_color

	stamp_overlay.pixel_x = x
	stamp_overlay.pixel_y = y

	LAZYADD(P.ico, stamp_overlay)
	LAZYADD(P.offset_x, x)
	LAZYADD(P.offset_y, y)
	P.add_overlay(stamp_overlay)

	// Yes, if there is no such state, icon will be empty
	var/image/border_overlay = image("icon" = icon, "icon_state" = "[stamp_paper_overlay]-border")
	stamp_overlay.appearance_flags |= KEEP_TOGETHER
	border_overlay.color = stamp_border_color

	border_overlay.pixel_x = x
	border_overlay.pixel_y = y

	LAZYADD(P.ico, border_overlay)
	LAZYADD(P.offset_x, x)
	LAZYADD(P.offset_y, y)
	P.add_overlay(border_overlay)

/obj/item/weapon/stamp/attack_paw(mob/user)
	return attack_hand(user)

#undef STAMP_OFFSET_CIRCLE_Y
#undef STAMP_OFFSET_CIRCLE_X
#undef STAMP_OFFSET_DOTS_Y
#undef STAMP_OFFSET_DOTS_X
