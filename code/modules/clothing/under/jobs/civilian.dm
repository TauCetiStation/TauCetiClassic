//Alphabetical order of civilian jobs.

/obj/item/clothing/under/rank/bartender
	desc = "It looks like it could use some more flair."
	name = "bartender's uniform"
	icon_state = "ba_suit"
	item_state = "ba_suit"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/rank/bartender/alt
	icon_state = "alt_ba_suit"
	item_state = "alt_ba_suit"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/rank/captain //Alright, technically not a 'civilian' but its better then giving a .dm file for a single define.
	desc = "It's a blue jumpsuit with some gold markings denoting the rank of \"Captain\"."
	name = "captain's jumpsuit"
	icon_state = "captain"
	item_state = "captain"
	flags = ONESIZEFITSALL|HEAR_TALK


/obj/item/clothing/under/rank/cargo
	name = "quartermaster's jumpsuit"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	item_state = "qm"
	flags = ONESIZEFITSALL|HEAR_TALK


/obj/item/clothing/under/rank/cargotech
	name = "cargo technician's jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear!"
	icon_state = "cargotech"
	item_state = "cargo"
	flags = ONESIZEFITSALL|HEAR_TALK
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/recycler
	name = "recycler's jumpsuit"
	desc = "Stinks."
	icon_state = "recycler"
	item_state = "recycler"
	flags = ONESIZEFITSALL|HEAR_TALK
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/recyclercasual
	name = "recycler's casual jumpsuit"
	desc = "Stinks."
	icon_state = "recyclercasual"
	item_state = "recyclercasual"
	flags = ONESIZEFITSALL|HEAR_TALK
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/rank/chaplain
	desc = "It's a dark robe, often worn by religious folk."
	name = "chaplain's dark robe"
	icon_state = "chaplain_dark"
	item_state = "chaplain_dark"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/rank/chaplain/light
	desc = "It's a light robe, often worn by religious folk."
	name = "chaplain's light robe"
	icon_state = "chaplain_light"
	item_state = "chaplain_light"


/obj/item/clothing/under/rank/chef
	desc = "It's an apron which is given only to the most <b>hardcore</b> chefs in space."
	name = "chef's uniform"
	icon_state = "chef_uniform"
	item_state = "chef_uniform"
	flags = ONESIZEFITSALL|HEAR_TALK

//Chef
/obj/item/clothing/under/rank/chef/sushi
	name = "sushi master robe"
	desc = "The one who wears this clearly knows a lot about fish, rice and perfectly understands the moonspeak."
	icon_state = "sushirobe"
	item_state = "sushirobe"


/obj/item/clothing/under/rank/clown
	name = "clown suit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown"
	item_state = "clown"
	flags = ONESIZEFITSALL|HEAR_TALK


/obj/item/clothing/under/rank/head_of_personnel
	desc = "It's a jumpsuit worn by someone who works in the position of \"Head of Personnel\"."
	name = "head of personnel's jumpsuit"
	icon_state = "hop"
	item_state = "hop"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/rank/head_of_personnel_whimsy
	desc = "A blue jacket and red tie, with matching red cuffs! Snazzy. Wearing this makes you feel more important than your job title does."
	name = "head of personnel's suit"
	icon_state = "hopwhimsy"
	item_state = "hopwhimsy"
	flags = ONESIZEFITSALL|HEAR_TALK


/obj/item/clothing/under/rank/hydroponics
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards."
	name = "botanist's jumpsuit"
	icon_state = "hydroponics"
	item_state = "hydroponics"
	permeability_coefficient = 0.50
	flags = ONESIZEFITSALL|HEAR_TALK


/obj/item/clothing/under/rank/internalaffairs
	desc = "The plain, professional attire of an Internal Affairs Agent. The collar is <i>immaculately</i> starched."
	name = "internal affairs uniform"
	icon_state = "internalaffairs"
	item_state = "internalaffairs"
	flags = ONESIZEFITSALL|HEAR_TALK


/obj/item/clothing/under/rank/janitor
	desc = "It's the official uniform of the station's janitor. It has minor protection from biohazards."
	name = "janitor's jumpsuit"
	icon_state = "janitor"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	flags = ONESIZEFITSALL|HEAR_TALK
	can_get_wet = FALSE


/obj/item/clothing/under/lawyer
	desc = "Slick threads."
	name = "lawyer suit"


/obj/item/clothing/under/lawyer/black
	icon_state = "lawyer_black"
	item_state = "lawyer_black"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/lawyer/female
	icon_state = "black_suit_neck"
	item_state = "black_suit_neck"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/lawyer/red
	icon_state = "lawyer_red"
	item_state = "lawyer_red"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/lawyer/bluesuit
	name = "blue suit"
	desc = "A classy suit and tie."
	icon_state = "bluesuit"
	item_state = "bluesuit"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/lawyer/purpsuit
	name = "purple suit"
	icon_state = "lawyer_purp"
	item_state = "lawyer_purp"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/lawyer/oldman
	name = "old man's suit"
	desc = "A classic suit for the older gentleman with built in back support."
	icon_state = "oldman"
	item_state = "oldman"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/librarian
	name = "sensible suit"
	desc = "It's very... sensible."
	icon_state = "red_suit"
	item_state = "red_suit"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/mime
	name = "mime's outfit"
	desc = "It's not very colourful."
	icon_state = "mimesuit"
	item_state = "mimesuit"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/rank/miner
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	name = "shaft miner's jumpsuit"
	icon_state = "miner"
	item_state = "miner"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/rank/barber
	desc = "A fancy pink shirt paired with light-catching white pants. Yet to be blood- and puke-stained."
	name = "barber's uniform"
	icon_state = "barber"
	item_state = "barber"
	flags = ONESIZEFITSALL|HEAR_TALK
