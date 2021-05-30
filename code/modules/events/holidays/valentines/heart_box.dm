/obj/item/weapon/storage/fancy/heart_box
	name = "heart-shaped box"
	desc = "A heart-shaped box for holding tiny chocolates. It says <span class='rose'>\"From NanoTrasen With Love\"</span> on its back.<br><i>If you look closer, you can see <span class='danger'>\"Cost of the box will be deducted from your salary.\"</span></i>"

	icon = 'icons/obj/valentines.dmi'
	icon_state = "heartbox"
	item_state = "heartbox"
	icon_type = "heart"

	storage_slots = 5
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/candyheart)

	var/opened = FALSE

/obj/item/weapon/storage/fancy/heart_box/attack_hand(mob/user)
	. = ..()
	if(!opened)
		opened = TRUE

/obj/item/weapon/storage/fancy/heart_box/atom_init()
	. = ..()
	for (var/i in 1 to storage_slots)
		new /obj/item/weapon/reagent_containers/food/snacks/candyheart(src)
	update_icon()

/obj/item/weapon/storage/fancy/heart_box/update_icon()
	if(!opened)
		cut_overlays()
		icon_state = "heartbox_full"
		item_state = "heartbox"
		return
	icon_state = "heartbox"
	var/list/candy_overlays = list()
	var/candy_position = 0
	for(var/obj/item/weapon/reagent_containers/food/snacks/candyheart/C in contents)
		candy_position ++
		var/candy_color = "pink_"
		if(C.icon_state == "candyheart_green")
			candy_color = "green_"
		if(C.icon_state == "candyheart_blue")
			candy_color = "blue_"
		if(C.icon_state == "candyheart_yellow")
			candy_color = "yellow_"
		candy_overlays += image('icons/obj/valentines.dmi', "[candy_color][candy_position]")
	add_overlay(candy_overlays)
	return

/obj/item/weapon/reagent_containers/food/snacks/candyheart
	name = "candy heart"
	icon = 'icons/obj/valentines.dmi'
	icon_state = "candyheart"
	desc = "A heart-shaped candy filled with love."
	bitesize = 3
	trash = /obj/item/weapon/paper/lovenote

/obj/item/weapon/reagent_containers/food/snacks/candyheart/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("sugar", 3)
	icon_state = pick("candyheart_pink", "candyheart_green", "candyheart_blue", "candyheart_yellow")

/obj/item/weapon/paper/lovenote
	name = "mysterious note"
	icon = 'icons/obj/valentines.dmi'
	icon_state = "lovenote"

/obj/item/weapon/paper/lovenote/atom_init()
	. = ..()
	icon_state = "lovenote"
	info = pick("Roses are red / Violets are good / One day while Andy...",
	"My love for you is like the singularity. It cannot be contained.",
	"Will you be my lusty xenomorph maid?",
	"We go together like the clown and the external airlock.",
	"Roses are red / Liches are wizards / I love you more than a whole squad of lizards.",
	"Be my valentine. Law 2.",
	"You must be a mime, because you leave me speechless.",
	"I love you like Ian loves the HoP.",
	"You're hotter than a plasma fire in toxins.",
	"Could I have all access... to your heart?",
	"Call me the doctor, because I'm here to inspect your johnson.",
	"Quick, get the defibrillator! I saw you and my heart stopped.",
	"I'm not a changeling, but you make my proboscis extend.",
	"I just can't get EI NATH of you.",
	"You must be a nuke op, because you make my heart explode.",
	"Roses are red / Botany is a farm / Not being my Valentine / causes human harm.",
	"I want you more than an assistant wants the captain's spare.",
	"Good thing I wore insulated gloves, because you're too hot to handle!",
	"If I was a security officer, I'd brig you all shift.",
	"Are you the janitor? Because I think I've fallen for you.",
	"You look as beautiful now as the last time you were cloned.",
	"If I were the warden I'd always let you into my armory.",
	"The virologist is rogue, and the only cure is a kiss from you.",
	"Would you spend some time in my upgraded sleeper?",
	"You must be a silicon, because you've unbolted my heart.",
	"Are you Nar'Sie? Because there's nar-one else I sie.",
	"If you were a taser, you'd be set to stunning.",
	"Do you have stamina damage from running through my dreams?",
	"If I were a xenomorph, would you let me hug you?",
	"My love for you is stronger than a reinforced wall.",
	"This must be the captain's office, because I see a fox.",
	"I'm no highlander, but there can only be one for me.",
	"Are you bluespace artillery? Because you blow me away.",
	"If you were an abandoned station you'd be the DEARelict.",
	"If you had an ore bag you'd be a shaft FINEr.",
	"I must be the CMO, 'cause I saw you on my CUTE sensors.",
	"Let's call the emergency CUDDLE.",
	"If you were an engineer you'd have insulated LOVEs.",
	"Could you put your DNA inside my vault?",
	"Roses are red, tide is gray, if I were an assistant I'd steal you away.",
	"Roses are red, text is green, I love you more than cleanbots clean.",
	"Roses are red, shuttles go dockside, I want to know you better than carbon dioxide.",
	"Roses are red, carnations are pink. Let's go out like the lights in a powersink.",
	"If you were a carp I'd fi-lay you.",
	"I'm a nuke op, and my pinpointer leads to your heart.",
	"Is that an esword in your pocket, or are you excited to see me?",
	"I've been chasing you like Runtime chases a laser pointer.",
	"I'm no cat, but you've got me in my feel-inids.",
	"If you were a disposal bin I'd ride you all day.",
	"You're the vomit to my flyperson.",
	"Get the ore redemptor, because I've just discovered girlfriend material.",
	"You must be liquid dark matter, because you're pulling me closer.",
	"Are you powering the station? Because you super matter to me.",
	"I wish science could make me a bag of holding you.",
	"Did you visit the medbay after you fell from heaven?",
	"Your beauty is rarer than an aurora caelus.",
	"Wanna raid my tool storage?",
	"You must be a moth, because you set my heart aflutter.")
	updateinfolinks()

/obj/item/weapon/paper/lovenote/update_icon()
	icon_state = "lovenote"
