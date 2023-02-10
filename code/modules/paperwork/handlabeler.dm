/obj/item/weapon/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "flight"
	m_amt = 800
	origin_tech = "materials=1"
	var/label = null
	var/labels_left = 30
	var/mode = 0	//off or on.

/obj/item/weapon/hand_labeler/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(!mode)	//if it's off, give up.
		return
	if(target == loc)	// if placing the labeller into something (e.g. backpack)
		return		// don't set a label

	if(!labels_left)
		to_chat(user, "<span class='notice'>No labels left.</span>")
		return
	if(!label || !length(label))
		to_chat(user, "<span class='notice'>No text set.</span>")
		return
	if(length(target.name) + length(label) > 64)
		to_chat(user, "<span class='notice'>Label too big.</span>")
		return
	if(ishuman(target))
		to_chat(user, "<span class='notice'>You can't label humans.</span>")
		return
	if(issilicon(target))
		to_chat(user, "<span class='notice'>You can't label cyborgs.</span>")
		return
	if(istype(target, /obj/item/weapon/reagent_containers/glass))
		to_chat(user, "<span class='notice'>The label can't stick to the [target.name].  (Try using a pen)</span>")
		return

	user.visible_message("<span class='notice'>[user] labels [target] as [label].</span>", \
						 "<span class='notice'>You label [target] as [label].</span>")
	target.name = "[target.name] ([label])"

/obj/item/weapon/hand_labeler/attack_self(mob/user)
	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		to_chat(user, "<span class='notice'>You turn on \the [src].</span>")
		//Now let them chose the text.
		var/str = sanitize_safe(input(user,"Label text?","Set label",""),MAX_NAME_LEN)
		if(!str || !length(str))
			to_chat(user, "<span class='notice'>Invalid text.</span>")
			return
		label = str
		to_chat(user, "<span class='notice'>You set the text to '[str]'.</span>")
	else
		to_chat(user, "<span class='notice'>You turn off \the [src].</span>")
