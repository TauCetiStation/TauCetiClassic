/obj/item/clothing/under/pj/red
	name = "red pj's"
	desc = "Sleepwear."
	icon_state = "red_pyjamas"
	item_state = "red_pyjamas"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/pj/blue
	name = "blue pj's"
	desc = "Sleepwear."
	icon_state = "blue_pyjamas"
	item_state = "blue_pyjamas"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/captain_fly
	name = "rogue captains uniform"
	desc = "For the man who doesn't care because he's still free."
	icon_state = "captain_fly"
	item_state = "captain_fly"

/obj/item/clothing/under/scratch
	name = "white suit"
	desc = "A white suit, suitable for an excellent host."
	icon_state = "scratch"
	item_state = "scratch"

/obj/item/clothing/under/sl_suit
	desc = "It's a very amish looking suit."
	name = "amish suit"
	icon_state = "sl_suit"

/obj/item/clothing/under/waiter
	name = "waiter's outfit"
	desc = "It's a very smart uniform with a special pocket for tip."
	icon_state = "waiter"
	item_state = "waiter"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/tourist
	name = "hawaiian shirt"
	desc = "How gauche."
	icon_state = "tourist"
	item_state = "tourist"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/rank/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	item_state = "mailman"

/obj/item/clothing/under/sexyclown
	name = "sexy-clown suit"
	desc = "It makes you look HONKable!"
	icon_state = "sexyclown"
	item_state = "sexyclown"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/rank/vice
	name = "vice officer's jumpsuit"
	desc = "It's the standard issue pretty-boy outfit, as seen on Holo-Vision."
	icon_state = "vice"
	item_state = "vice"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/rank/centcom_officer
	desc = "It's a jumpsuit worn by CentCom Officers."
	name = "CentCom officer's jumpsuit"
	icon_state = "officer"
	item_state = "officer"

/obj/item/clothing/under/rank/centcom_commander
	desc = "It's a jumpsuit worn by CentCom's highest-tier Commanders."
	name = "CentCom officer's jumpsuit"
	icon_state = "centcom"
	item_state = "centcom"

/obj/item/clothing/under/ert
	name = "ERT tactical uniform"
	desc = "A short-sleeved black uniform, paired with grey digital-camo cargo pants. It looks very tactical."
	icon_state = "ert_uniform"
	item_state = "ert_uniform"

/obj/item/clothing/under/space
	name = "NASA jumpsuit"
	desc = "It has a NASA logo on it and is made of space-proofed materials."
	icon_state = "black"
	item_state = "black"
	w_class = SIZE_NORMAL//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS //Needs gloves and shoes with cold protection to be fully protected.
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/under/acj
	name = "administrative cybernetic jumpsuit"
	icon_state = "syndicate"
	item_state = "syndicate"
	desc = "it's a cybernetically enhanced jumpsuit used for administrative duties."
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list(melee = 100, bullet = 100, laser = 100,energy = 100, bomb = 100, bio = 100, rad = 100)
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0

/obj/item/clothing/under/owl
	name = "owl uniform"
	desc = "A jumpsuit with owl wings. Photorealistic owl feathers! Twooooo!"
	icon_state = "owl"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/johnny
	name = "johnny~~ jumpsuit"
	desc = "Johnny~~"
	icon_state = "johnny"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/rainbow
	name = "rainbow"
	desc = "rainbow"
	icon_state = "rainbow"
	item_state = "rainbow"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/psysuit
	name = "dark undersuit"
	desc = "A thick, layered grey undersuit lined with power cables. Feels a little like wearing an electrical storm."
	icon_state = "psysuit"
	item_state = "psysuit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/under/gentlesuit
	name = "gentlemans suit"
	desc = "A silk black shirt with a white tie and a matching gray vest and slacks. Feels proper."
	icon_state = "gentlesuit"
	item_state = "gentlesuit"

/obj/item/clothing/under/gimmick/rank/captain/suit
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	item_state = "green_suit"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/gimmick/rank/head_of_personnel/suit
	name = "head of personnel's suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit"
	item_state = "teal_suit"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/suit_jacket
	name = "black suit"
	desc = "A black suit and red tie. Very formal."
	icon_state = "black_suit"
	item_state = "black_suit"

/obj/item/clothing/under/suit_jacket/reinforced //armored jackets for special agents
	name = "black suit"
	desc = "A black suit and red tie. Very formal. This one looks a bit stronger than others."
	icon_state = "black_suit"
	item_state = "black_suit"
	body_parts_covered = UPPER_TORSO|ARMS
	armor = list(melee = 18, bullet = 12, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/suit_jacket/really_black
	name = "executive suit"
	desc = "A formal black suit and red tie, intended for the station's finest."
	icon_state = "really_black_suit"
	item_state = "really_black_suit"

/obj/item/clothing/under/suit_jacket/female
	name = "executive suit"
	desc = "A formal trouser suit for women, intended for the station's finest."
	icon_state = "black_suit_neck"
	item_state = "black_suit_neck"

/obj/item/clothing/under/suit_jacket/red
	name = "red suit"
	desc = "A red suit and blue tie. Somewhat formal."
	icon_state = "red_suit"
	item_state = "red_suit"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/suit_jacket/charcoal
	name = "charcoal suit"
	desc = "A charcoal suit and red tie. Very professional."
	icon_state = "charcoal_suit"
	item_state = "charcoal_suit"

/obj/item/clothing/under/suit_jacket/navy
	name = "navy suit"
	desc = "A navy suit and red tie, intended for the station's finest."
	icon_state = "navy_suit"
	item_state = "navy_suit"

/obj/item/clothing/under/suit_jacket/burgundy
	name = "burgundy suit"
	desc = "A burgundy suit and black tie. Somewhat formal."
	icon_state = "burgundy_suit"
	item_state = "burgundy_suit"

/obj/item/clothing/under/suit_jacket/checkered
	name = "checkered suit"
	desc = "That's a very nice suit you have there. Shame if something were to happen to it, eh?"
	icon_state = "checkered_suit"
	item_state = "checkered_suit"

/obj/item/clothing/under/suit_jacket/tan
	name = "tan suit"
	desc = "A tan suit with a yellow tie. Smart, but casual."
	icon_state = "tan_suit"
	item_state = "tan_suit"

/obj/item/clothing/under/suit_jacket/white
	name = "white suit"
	desc = "A white suit and jacket with a blue shirt. You wanna play rough? OKAY!."
	icon_state = "white_suit"
	item_state = "white_suit"

/obj/item/clothing/under/suit_jacket/rouge
	name = "rogue jacket"
	desc = "A  suit and jacket with a jeans. For the bad guy!"
	icon_state = "rogue_jacket"
	item_state = "rogue_jacket"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/blackskirt
	name = "black skirt"
	desc = "A black skirt, very fancy!"
	icon_state = "blackskirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/schoolgirl
	name = "schoolgirl uniform"
	desc = "It's just like one of my Japanese animes!"
	icon_state = "schoolgirl"
	item_state = "schoolgirl"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	item_state = "overalls"

/obj/item/clothing/under/pirate
	name = "pirate outfit"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS

/obj/item/clothing/under/soviet
	name = "soviet uniform"
	desc = "For the Motherland!"
	icon_state = "soviet"
	item_state = "soviet"

/obj/item/clothing/under/redcoat
	name = "redcoat uniform"
	desc = "Looks old."
	icon_state = "redcoat"
	item_state = "redcoat"

/obj/item/clothing/under/kilt
	name = "kilt"
	desc = "Includes shoes and plaid."
	icon_state = "kilt"
	item_state = "kilt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/sexymime
	name = "sexy mime outfit"
	desc = "The only time when you DON'T enjoy looking at someone's rack."
	icon_state = "sexymime"
	item_state = "sexymime"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/gladiator
	name = "gladiator uniform"
	desc = "Are you not entertained? Is that not why you are here?"
	icon_state = "gladiator"
	item_state = "gladiator"
	body_parts_covered = LOWER_TORSO

//dress
/obj/item/clothing/under/dress
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/dress/dress_fire
	name = "flame dress"
	desc = "A small black dress with blue flames print on it."
	icon_state = "dress_fire"

/obj/item/clothing/under/dress/dress_green
	name = "green dress"
	desc = "A simple, tight fitting green dress."
	icon_state = "dress_green"

/obj/item/clothing/under/dress/dress_orange
	name = "orange dress"
	desc = "A fancy orange gown for those who like to show leg."
	icon_state = "dress_orange"

/obj/item/clothing/under/dress/dress_pink
	name = "pink dress"
	desc = "A simple, tight fitting pink dress."
	icon_state = "dress_pink"

/obj/item/clothing/under/dress/dress_yellow
	name = "yellow dress"
	desc = "A flirty, little yellow dress."
	icon_state = "dress_yellow"

/obj/item/clothing/under/dress/dress_purple
	name = "purple dress"
	desc = "A nicely tailored purple dress made for the taller woman."
	icon_state = "dress_purple"

/obj/item/clothing/under/dress/dress_saloon
	name = "saloon girl dress"
	desc = "A old western inspired gown for the girl who likes to drink."
	icon_state = "dress_saloon"

/obj/item/clothing/under/dress/dress_summer
	name = "summer dress"
	desc = "Ruffle your way through the season in this sweet, sunshine green dress."
	icon_state = "dress_summer"

/obj/item/clothing/under/dress/dress_vintage
	name = "vintage dress"
	desc = "Take a swan dive into vintage love, dames!"
	icon_state = "dress_vintage"

/obj/item/clothing/under/dress/dress_evening
	name = "elegant evening dress"
	desc = "A stylish gown perfect for a wedding-guest dress, ball gown or your next formal celebration."
	icon_state = "dress_evening"

/obj/item/clothing/under/dress/dress_party
	name = "party dress"
	desc = "The party doesn't start 'til you walk in, so make an entrance no one can ignore."
	icon_state = "dress_party"


/obj/item/clothing/under/dress/dress_cap
	name = "captain dress uniform"
	desc = "Feminine fashion for the style concious captain."
	icon_state = "dress_cap"
	flags = ONESIZEFITSALL|HEAR_TALK
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/dress/dress_hop
	name = "head of personal dress uniform"
	desc = "Feminine fashion for the style concious HoP."
	icon_state = "dress_hop"
	flags = ONESIZEFITSALL|HEAR_TALK
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/dress/dress_hr
	name = "human resources director uniform"
	desc = "Superior class for the nosy H.R. Director."
	icon_state = "huresource"
	flags = ONESIZEFITSALL|HEAR_TALK
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/dress/cheongsam // Mai Yang's pretty pretty dress.
	name = "white cheongsam"
	desc = "It is a white cheongsam dress."
	icon_state = "cheongsam"
	item_state = "cheongsam"

/obj/item/clothing/under/dress/maid
	name = "maid suit"
	desc = "For your dirty ERP needs."
	icon_state = "maid"
	item_state = "maid"

/obj/item/clothing/under/dress/maid/sakuya
	desc = "For women who like to throw knives."
	icon_state = "sakuya"
	item_state = "sakuya"

/obj/item/clothing/under/dress/plaid_blue
	name = "blue plaid skirt"
	desc = "A preppy blue skirt with a white blouse."
	icon_state = "plaid_blue"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/dress/plaid_red
	name = "red plaid skirt"
	desc = "A preppy red skirt with a white blouse."
	icon_state = "plaid_red"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/dress/plaid_purple
	name = "blue purple skirt"
	desc = "A preppy purple skirt with a white blouse."
	icon_state = "plaid_purple"
	flags = ONESIZEFITSALL|HEAR_TALK

//wedding stuff
/obj/item/clothing/under/wedding
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS

/obj/item/clothing/under/wedding/bride_orange
	name = "orange wedding dress"
	desc = "A big and puffy orange dress."
	icon_state = "bride_orange"
	flags_inv = HIDESHOES

/obj/item/clothing/under/wedding/bride_purple
	name = "purple wedding dress"
	desc = "A big and puffy purple dress."
	icon_state = "bride_purple"
	flags_inv = HIDESHOES

/obj/item/clothing/under/wedding/bride_blue
	name = "blue wedding dress"
	desc = "A big and puffy blue dress."
	icon_state = "bride_blue"
	flags_inv = HIDESHOES

/obj/item/clothing/under/wedding/bride_red
	name = "red wedding dress"
	desc = "A big and puffy red dress."
	icon_state = "bride_red"
	flags_inv = HIDESHOES

/obj/item/clothing/under/wedding/bride_white
	name = "silky wedding dress"
	desc = "A white wedding gown made from the finest silk."
	icon_state = "bride_white"
	flags_inv = HIDESHOES
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/sundress
	name = "sundress"
	desc = "Makes you want to frolic in a field of daisies."
	icon_state = "sundress"
	item_state = "sundress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/rank/cadet
	desc = ""
	name = "security cadet's uniform"
	icon_state = "cadet"
	item_state = "cadet"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/rank/cadet/skirt
	name = "security cadet's jumpskirt"
	icon_state = "skirt_cadet"
	item_state = "skirt_cadet"

/obj/item/clothing/under/rank/cargo_fem
	name = "quartermaster's dress"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm_f"
	item_state = "qm_f"

/obj/item/clothing/under/rank/head_of_security_fem
	desc = "It's a jumpsuit worn by those few with the dedication to achieve the position of \"Head of Security\". It has additional armor to protect the wearer."
	name = "head of security's dress"
	icon_state = "hos_f"
	item_state = "hos_f"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.8

/obj/item/clothing/under/rank/warden_fem
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for more robust protection. It has the word \"Warden\" written on the shoulders."
	name = "warden's dress"
	icon_state = "warden_f"
	item_state = "warden_f"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/roboticist_fem
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	name = "roboticist's female jumpsuit"
	icon_state = "roboticist_f"
	item_state = "roboticist_f"

/obj/item/clothing/under/rank/hydroponics_fem
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards."
	name = "botanist's female jumpsuit"
	icon_state = "hydroponics_f"
	item_state = "hydroponics_f"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/bartender_fem
	desc = "It looks like it could use some more flair."
	name = "bartender's female uniform"
	icon_state = "bar_f"
	item_state = "bar_f"

/obj/item/clothing/under/blacktango
	name = "black tango dress"
	desc = "Filled with latin fire."
	icon_state = "tango"
	item_state = "tango"

//Mafia
/obj/item/clothing/under/mafia
	name = "mafia outfit"
	desc = "The business of the mafia is business."
	icon_state = "mafia"
	item_state = "mafia"

/obj/item/clothing/under/mafia/vest
	name = "mafia vest"
	desc = "Extreme problems often require extreme solutions."
	icon_state = "mafia_vest"
	item_state = "mafia_vest"

/obj/item/clothing/under/mafia/white
	name = "white mafia outfit"
	desc = "The best defense against the treacherous is treachery."
	icon_state = "mafia_white"
	item_state = "mafia_white"

/obj/item/clothing/under/mafia/sue
	name = "mafia vest"
	desc = "The business is born into."
	icon_state = "sue_vest"
	item_state = "sue_vest"

/obj/item/clothing/under/mafia/tan
	name = "leather mafia outfit"
	desc = "The big drum sounds good only from a distance."
	icon_state = "mafia_tan"
	item_state = "mafia_tan"

/obj/item/clothing/under/rank/capcamsole
	desc = "It's a blue feminine camisole with some gold markings denoting the rank of \"Captain\" and gold aquila on it."
	name = "captain's camisole"
	icon_state = "capcamisole"
	item_state = "capcamisole"

/obj/item/clothing/under/rank/goodman_shirt
	name = "head of personnel's suit"
	desc = "A good suit for good men."
	icon_state = "gmshirt"
	item_state = "gmshirt"

/obj/item/clothing/under/rank/centcom/representative
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Ensign\" and bears \"N.C.V. Fearless CV-286\" on the left shounder."
	name = "NanoTrasen navy uniform"
	icon_state = "officer"
	item_state = "officer"

/obj/item/clothing/under/rank/centcom/officer
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Lieutenant Commander\" and bears \"N.C.V. Fearless CV-286\" on the left shounder."
	name = "NanoTrasen officers uniform"
	icon_state = "officer"
	item_state = "officer"

/obj/item/clothing/under/rank/centcom/captain
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Captain\" and bears \"N.C.V. Fearless CV-286\" on the left shounder."
	name = "NanoTrasen captains uniform"
	icon_state = "centcom"
	item_state = "centcom"

/obj/item/clothing/under/roman
	name = "roman armor"
	desc = "Ancient Roman armor. Made of metallic and leather straps."
	icon_state = "roman"
	item_state = "roman"

/obj/item/clothing/under/patient_gown
	name = "patient gown"
	desc = "A long loose piece of clothing worn in a hospital by someone doing or having an operation. It can be used as clothing for bedridden patients."
	icon_state = "patient_gown"
	body_parts_covered = 0

/obj/item/clothing/under/pretty_dress
	name = "pretty dress"
	desc = "An Enchanting blue dress."
	icon_state = "pretty_dress"

/obj/item/clothing/under/sukeban_pants
	name = "sukeban pants"
	desc = "A white shirt with wide baggy pants"
	icon_state = "sukeban_pants"

/obj/item/clothing/under/sukeban_dress
	name = "sukeban dress"
	desc = "A Dress of Japanese schoolgirls"
	icon_state = "sukeban_dress"

/obj/item/clothing/under/karate
	name = "karate underwear"
	icon_state = "karate"

/obj/item/clothing/under/smoking
	name = "smoking"
	icon_state = "smoking_new"

/obj/item/clothing/under/popking
	name = "popking suit"
	desc = "Classic costume of the King of Pop. A great choice if you want to twist again, watching Pretty Woman."
	icon_state = "popking"

/obj/item/clothing/under/popking/alternate
	icon_state = "popking2"

/obj/item/clothing/under/pinkpolo
	name = "pink polo"
	desc = "The classic image of an American gangster 80. Hello from Miami."
	icon_state = "pinkpolo"

/obj/item/clothing/under/bathrobe
	name = "bath robe"
	icon_state = "bathrobe"

/obj/item/clothing/under/bathtowel
	name = "bath towel"
	icon_state = "bathtowel"
	has_sensor = 0
	slot_flags = SLOT_FLAGS_HEAD | SLOT_FLAGS_ICLOTHING

/obj/item/clothing/under/bathtowel/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot == SLOT_W_UNIFORM)
		body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	else if(slot == SLOT_HEAD)
		body_parts_covered = HEAD

/obj/item/clothing/under/rank/postal_dude_shirt
	name = "blue shirt"
	desc = "A blue shirt with image of alien in front."
	icon_state = "dude_shirt"
	item_state = "dude_shirt"

/obj/item/clothing/under/sport
	name = "white and black sport uniform"
	desc = "No pain - no gain."
	icon_state = "DDR_sport"
	item_state = "DDR_sport"

/obj/item/clothing/under/sport/blue
	name = "blue sport uniform"
	icon_state = "blue_sport"
	item_state = "blue_sport"

/obj/item/clothing/under/sport/black
	name = "black sport uniform"
	icon_state = "black_sport"
	item_state = "black_sport"

/obj/item/clothing/under/M35_Jacket
	name = "M35 Filde Jacket"
	desc = "Standart wehrmacht field uniform."
	icon_state = "M35_Filde_Jacket"
	item_state = "M35_Filde_Jacket"
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 5, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/M35_Jacket_Oficer
	name = "M35 Filde Oficer Jacket"
	desc = "Werhmacht officer jacket uniform."
	icon_state = "M35_Filde_Jacket_Officer"
	item_state = "M35_Filde_Jacket_Officer"
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 5, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/jackbros
	name = "jack bros outfit"
	desc = "For when it's time to hee some hos."
	icon_state = "JackFrostUniform"
	item_state = "JackFrostUniform"

/obj/item/clothing/under/yakuza
	name = "tojo clan pants"
	desc = "For those long nights under the traffic cone."
	icon_state = "MajimaPants"
	item_state = "MajimaPants"

/obj/item/clothing/suit/dutch
	name = "dutch's jacket"
	desc = "For those long nights on the beach in Tahiti."
	icon_state = "DutchJacket"
	body_parts_covered = ARMS
	item_state = "DutchJacket"

/obj/item/clothing/under/dutch
	name = "dutch's suit"
	desc = "You can feel a <b>god damn plan</b> coming on."
	icon_state = "DutchUniform"
	item_state = "DutchUniform"

/obj/item/clothing/head/spacepolice
	name = "police cap"
	desc = "A blue cap for patrolling the daily beat."
	icon_state = "police_cap"

/obj/item/clothing/under/henchmen
	name = "henchmen jumpsuit"
	desc = "A very gaudy jumpsuit for a proper Henchman. Guild regulations, you understand."
	icon_state = "henchmen"
	item_state = "henchmen"
	flags = HEADCOVERSEYES|BLOCKHAIR
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HEAD
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEEARS|HIDEEYES

/obj/item/clothing/shoes/yakuza
	name = "tojo clan shoes"
	desc = "Steel-toed and intimidating."
	icon_state = "MajimaShoes"

/obj/item/clothing/shoes/jackbros
	name = "frosty boots"
	desc = "For when you're stepping on up to the plate."
	icon_state = "JackFrostShoes"

/obj/item/clothing/head/jackbros
	name = "frosty hat"
	desc = "Hee-ho!"
	icon_state = "JackFrostHat"

/obj/item/clothing/under/test_subject
	name = "NT-SID jumpsuit"
	desc = "A NanoTrasen Synthetic Intelligence Division jumpsuit, issued to 'volunteers'. On other people it looks fine, but right here a scientist has noted: on you it looks stupid."
	icon_state = "test_subject"
	item_state = "test_subject"
	has_sensor = 2
	sensor_mode = SUIT_SENSOR_TRACKING
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/indiana
	name = "leather suit"
	icon_state = "indiana"
	item_state = "indiana"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/cowboy
	name = "western suit"
	desc = "Revolver is your best friend."
	icon_state = "cowboy"
	item_state = "cowboy"

/obj/item/clothing/under/cowboy/brown
	icon_state = "cowboy_brown"
	item_state = "cowboy_brown"

/obj/item/clothing/under/cowboy/grey
	icon_state = "cowboy_grey"
	item_state = "cowboy_grey"

/obj/item/clothing/under/kung
	name = "Kung Jeans"
	desc = "Pair of old jeans combined with a red tank-top"
	icon_state = "kung_suit"
	w_class = SIZE_SMALL

/obj/item/clothing/under/durathread
	name = "durathread suit"
	desc = "Made from duratread. It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "Durauniform"
	item_state = "Durauniform"
	flags = ONESIZEFITSALL|HEAR_TALK
	siemens_coefficient = 0.8
	armor = list(melee = 5, bullet = 0, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0)
