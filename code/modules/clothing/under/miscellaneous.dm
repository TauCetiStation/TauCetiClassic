/obj/item/clothing/under/pj/red
	name = "red pj's"
	desc = "Sleepwear."
	icon_state = "red_pyjamas"
	item_color = "red_pyjamas"
	item_state = "w_suit"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/pj/blue
	name = "blue pj's"
	desc = "Sleepwear."
	icon_state = "blue_pyjamas"
	item_color = "blue_pyjamas"
	item_state = "w_suit"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/captain_fly
	name = "rogue captains uniform"
	desc = "For the man who doesn't care because he's still free."
	icon_state = "captain_fly"
	item_state = "captain_fly"
	item_color = "captain_fly"

/obj/item/clothing/under/scratch
	name = "white suit"
	desc = "A white suit, suitable for an excellent host."
	icon_state = "scratch"
	item_state = "scratch"
	item_color = "scratch"

/obj/item/clothing/under/sl_suit
	desc = "It's a very amish looking suit."
	name = "amish suit"
	icon_state = "sl_suit"
	item_color = "sl_suit"

/obj/item/clothing/under/waiter
	name = "waiter's outfit"
	desc = "It's a very smart uniform with a special pocket for tip."
	icon_state = "waiter"
	item_state = "waiter"
	item_color = "waiter"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/tourist
	name = "hawaiian shirt"
	desc = "How gauche."
	icon_state = "tourist"
	item_state = "tourist"
	item_color = "tourist"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/rank/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	item_state = "b_suit"
	item_color = "mailman"

/obj/item/clothing/under/sexyclown
	name = "sexy-clown suit"
	desc = "It makes you look HONKable!"
	icon_state = "sexyclown"
	item_state = "sexyclown"
	item_color = "sexyclown"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/rank/vice
	name = "vice officer's jumpsuit"
	desc = "It's the standard issue pretty-boy outfit, as seen on Holo-Vision."
	icon_state = "vice"
	item_state = "gy_suit"
	item_color = "vice"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/rank/centcom_officer
	desc = "It's a jumpsuit worn by CentCom Officers."
	name = "CentCom officer's jumpsuit"
	icon_state = "officer"
	item_state = "g_suit"
	item_color = "officer"

/obj/item/clothing/under/rank/centcom_commander
	desc = "It's a jumpsuit worn by CentCom's highest-tier Commanders."
	name = "CentCom officer's jumpsuit"
	icon_state = "centcom"
	item_state = "dg_suit"
	item_color = "centcom"

/obj/item/clothing/under/ert
	name = "ERT tactical uniform"
	desc = "A short-sleeved black uniform, paired with grey digital-camo cargo pants. It looks very tactical."
	icon_state = "ert_uniform"
	item_state = "bl_suit"
	item_color = "ert_uniform"

/obj/item/clothing/under/space
	name = "NASA jumpsuit"
	desc = "It has a NASA logo on it and is made of space-proofed materials."
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "black"
	w_class = ITEM_SIZE_LARGE//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS //Needs gloves and shoes with cold protection to be fully protected.
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/under/acj
	name = "administrative cybernetic jumpsuit"
	icon_state = "syndicate"
	item_state = "bl_suit"
	item_color = "syndicate"
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
	item_color = "owl"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/johnny
	name = "johnny~~ jumpsuit"
	desc = "Johnny~~"
	icon_state = "johnny"
	item_color = "johnny"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/rainbow
	name = "rainbow"
	desc = "rainbow"
	icon_state = "rainbow"
	item_state = "rainbow"
	item_color = "rainbow"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/psysuit
	name = "dark undersuit"
	desc = "A thick, layered grey undersuit lined with power cables. Feels a little like wearing an electrical storm."
	icon_state = "psysuit"
	item_state = "psysuit"
	item_color = "psysuit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/under/gentlesuit
	name = "gentlemans suit"
	desc = "A silk black shirt with a white tie and a matching gray vest and slacks. Feels proper."
	icon_state = "gentlesuit"
	item_state = "gentlesuit"
	item_color = "gentlesuit"

/obj/item/clothing/under/gimmick/rank/captain/suit
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	item_state = "dg_suit"
	item_color = "green_suit"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/gimmick/rank/head_of_personnel/suit
	name = "head of personnel's suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit"
	item_state = "g_suit"
	item_color = "teal_suit"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/suit_jacket
	name = "black suit"
	desc = "A black suit and red tie. Very formal."
	icon_state = "black_suit"
	item_state = "bl_suit"
	item_color = "black_suit"

/obj/item/clothing/under/suit_jacket/reinforced //armored jackets for special agents
	name = "black suit"
	desc = "A black suit and red tie. Very formal. This one looks a bit stronger than others."
	icon_state = "black_suit"
	item_state = "bl_suit"
	item_color = "black_suit"
	body_parts_covered = UPPER_TORSO|ARMS
	armor = list(melee = 18, bullet = 12, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/suit_jacket/really_black
	name = "executive suit"
	desc = "A formal black suit and red tie, intended for the station's finest."
	icon_state = "really_black_suit"
	item_state = "bl_suit"
	item_color = "black_suit"

/obj/item/clothing/under/suit_jacket/female
	name = "executive suit"
	desc = "A formal trouser suit for women, intended for the station's finest."
	icon_state = "black_suit_fem"
	item_state = "black_suit_fem"
	item_color = "black_suit_fem"

/obj/item/clothing/under/suit_jacket/red
	name = "red suit"
	desc = "A red suit and blue tie. Somewhat formal."
	icon_state = "red_suit"
	item_state = "r_suit"
	item_color = "red_suit"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/suit_jacket/charcoal
	name = "charcoal suit"
	desc = "A charcoal suit and red tie. Very professional."
	icon_state = "charcoal_suit"
	item_state = "charcoal_suit"
	item_color = "charcoal_suit"

/obj/item/clothing/under/suit_jacket/navy
	name = "navy suit"
	desc = "A navy suit and red tie, intended for the station's finest."
	icon_state = "navy_suit"
	item_state = "navy_suit"
	item_color = "navy_suit"

/obj/item/clothing/under/suit_jacket/burgundy
	name = "burgundy suit"
	desc = "A burgundy suit and black tie. Somewhat formal."
	icon_state = "burgundy_suit"
	item_state = "burgundy_suit"
	item_color = "burgundy_suit"

/obj/item/clothing/under/suit_jacket/checkered
	name = "checkered suit"
	desc = "That's a very nice suit you have there. Shame if something were to happen to it, eh?"
	icon_state = "checkered_suit"
	item_state = "checkered_suit"
	item_color = "checkered_suit"

/obj/item/clothing/under/suit_jacket/tan
	name = "tan suit"
	desc = "A tan suit with a yellow tie. Smart, but casual."
	icon_state = "tan_suit"
	item_state = "tan_suit"
	item_color = "tan_suit"

/obj/item/clothing/under/suit_jacket/white
	name = "white suit"
	desc = "A white suit and jacket with a blue shirt. You wanna play rough? OKAY!."
	icon_state = "white_suit"
	item_state = "white_suit"
	item_color = "white_suit"

/obj/item/clothing/under/suit_jacket/rouge
	name = "rogue jacket"
	desc = "A  suit and jacket with a jeans. For the bad guy!"
	icon_state = "rogue_jacket"
	item_state = "rogue_jacket"
	item_color = "rogue_jacket"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/blackskirt
	name = "black skirt"
	desc = "A black skirt, very fancy!"
	icon_state = "blackskirt"
	item_color = "blackskirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/schoolgirl
	name = "schoolgirl uniform"
	desc = "It's just like one of my Japanese animes!"
	icon_state = "schoolgirl"
	item_state = "schoolgirl"
	item_color = "schoolgirl"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	item_state = "lb_suit"
	item_color = "overalls"

/obj/item/clothing/under/pirate
	name = "pirate outfit"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	item_color = "pirate"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS

/obj/item/clothing/under/soviet
	name = "soviet uniform"
	desc = "For the Motherland!"
	icon_state = "soviet"
	item_state = "soviet"
	item_color = "soviet"

/obj/item/clothing/under/redcoat
	name = "redcoat uniform"
	desc = "Looks old."
	icon_state = "redcoat"
	item_state = "redcoat"
	item_color = "redcoat"

/obj/item/clothing/under/kilt
	name = "kilt"
	desc = "Includes shoes and plaid."
	icon_state = "kilt"
	item_state = "kilt"
	item_color = "kilt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/sexymime
	name = "sexy mime outfit"
	desc = "The only time when you DON'T enjoy looking at someone's rack."
	icon_state = "sexymime"
	item_state = "sexymime"
	item_color = "sexymime"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/gladiator
	name = "gladiator uniform"
	desc = "Are you not entertained? Is that not why you are here?"
	icon_state = "gladiator"
	item_state = "gladiator"
	item_color = "gladiator"
	body_parts_covered = LOWER_TORSO

//dress
/obj/item/clothing/under/dress
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/dress/dress_fire
	name = "flame dress"
	desc = "A small black dress with blue flames print on it."
	icon_state = "dress_fire"
	item_color = "dress_fire"

/obj/item/clothing/under/dress/dress_green
	name = "green dress"
	desc = "A simple, tight fitting green dress."
	icon_state = "dress_green"
	item_color = "dress_green"

/obj/item/clothing/under/dress/dress_orange
	name = "orange dress"
	desc = "A fancy orange gown for those who like to show leg."
	icon_state = "dress_orange"
	item_color = "dress_orange"

/obj/item/clothing/under/dress/dress_pink
	name = "pink dress"
	desc = "A simple, tight fitting pink dress."
	icon_state = "dress_pink"
	item_color = "dress_pink"

/obj/item/clothing/under/dress/dress_yellow
	name = "yellow dress"
	desc = "A flirty, little yellow dress."
	icon_state = "dress_yellow"
	item_color = "dress_yellow"

/obj/item/clothing/under/dress/dress_saloon
	name = "saloon girl dress"
	desc = "A old western inspired gown for the girl who likes to drink."
	icon_state = "dress_saloon"
	item_color = "dress_saloon"

/obj/item/clothing/under/dress/dress_summer
	name = "summer dress"
	desc = "Ruffle your way through the season in this sweet, sunshine green dress."
	icon_state = "dress_summer"
	item_color = "dress_summer"

/obj/item/clothing/under/dress/dress_vintage
	name = "vintage dress"
	desc = "Take a swan dive into vintage love, dames!"
	icon_state = "dress_vintage"
	item_color = "dress_vintage"

/obj/item/clothing/under/dress/dress_evening
	name = "elegant evening dress"
	desc = "A stylish gown perfect for a wedding-guest dress, ball gown or your next formal celebration."
	icon_state = "dress_evening"
	item_color = "dress_evening"

/obj/item/clothing/under/dress/dress_party
	name = "party dress"
	desc = "The party doesn't start 'til you walk in, so make an entrance no one can ignore."
	icon_state = "dress_party"
	item_color = "dress_party"


/obj/item/clothing/under/dress/dress_cap
	name = "captain dress uniform"
	desc = "Feminine fashion for the style concious captain."
	icon_state = "dress_cap"
	item_color = "dress_cap"
	flags = ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/dress/dress_hop
	name = "head of personal dress uniform"
	desc = "Feminine fashion for the style concious HoP."
	icon_state = "dress_hop"
	item_color = "dress_hop"
	flags = ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/dress/dress_hr
	name = "human resources director uniform"
	desc = "Superior class for the nosy H.R. Director."
	icon_state = "huresource"
	item_color = "huresource"
	flags = ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/dress/plaid_blue
	name = "blue plaid skirt"
	desc = "A preppy blue skirt with a white blouse."
	icon_state = "plaid_blue"
	item_color = "plaid_blue"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/dress/plaid_red
	name = "red plaid skirt"
	desc = "A preppy red skirt with a white blouse."
	icon_state = "plaid_red"
	item_color = "plaid_red"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/dress/plaid_purple
	name = "blue purple skirt"
	desc = "A preppy purple skirt with a white blouse."
	icon_state = "plaid_purple"
	item_color = "plaid_purple"
	flags = ONESIZEFITSALL

//wedding stuff
/obj/item/clothing/under/wedding
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS

/obj/item/clothing/under/wedding/bride_orange
	name = "orange wedding dress"
	desc = "A big and puffy orange dress."
	icon_state = "bride_orange"
	item_color = "bride_orange"
	flags_inv = HIDESHOES

/obj/item/clothing/under/wedding/bride_purple
	name = "purple wedding dress"
	desc = "A big and puffy purple dress."
	icon_state = "bride_purple"
	item_color = "bride_purple"
	flags_inv = HIDESHOES

/obj/item/clothing/under/wedding/bride_blue
	name = "blue wedding dress"
	desc = "A big and puffy blue dress."
	icon_state = "bride_blue"
	item_color = "bride_blue"
	flags_inv = HIDESHOES

/obj/item/clothing/under/wedding/bride_red
	name = "red wedding dress"
	desc = "A big and puffy red dress."
	icon_state = "bride_red"
	item_color = "bride_red"
	flags_inv = HIDESHOES

/obj/item/clothing/under/wedding/bride_white
	name = "silky wedding dress"
	desc = "A white wedding gown made from the finest silk."
	icon_state = "bride_white"
	item_color = "bride_white"
	flags_inv = HIDESHOES
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/sundress
	name = "sundress"
	desc = "Makes you want to frolic in a field of daisies."
	icon_state = "sundress"
	item_state = "sundress"
	item_color = "sundress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/rank/mecha_operator
	desc = "It's a slimming black with reinforced seams."
	name = "pilot's jumpsuit"
	icon_state = "robotics2"
	item_state = "robotics"
	item_color = "robotics2"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/rank/cadet
	desc = ""
	name = "security cadet's uniform"
	icon_state = "officertanclothes"
	item_state = "r_suit"
	item_color = "officertanclothes"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/rank/cadet/skirt
	name = "security cadet's jumpskirt"
	icon_state = "officertanskirt"
	item_color = "officertanskirt"

/obj/item/clothing/under/rank/forensic_technician
	desc = "It has a Forensics rank stripe on it."
	name = "forensics jumpsuit"
	icon_state = "forensicsred"
	item_state = "r_suit"
	item_color = "forensicsred"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/cargo_fem
	name = "quartermaster's dress"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm_f"
	item_state = "lb_suit"
	item_color = "qm_f"

/obj/item/clothing/under/rank/head_of_security_fem
	desc = "It's a jumpsuit worn by those few with the dedication to achieve the position of \"Head of Security\". It has additional armor to protect the wearer."
	name = "head of security's dress"
	icon_state = "hos_f"
	item_state = "r_suit"
	item_color = "hos_f"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.8

/obj/item/clothing/under/rank/warden_fem
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for more robust protection. It has the word \"Warden\" written on the shoulders."
	name = "warden's dress"
	icon_state = "warden_f"
	item_state = "r_suit"
	item_color = "warden_f"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/roboticist_fem
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	name = "roboticist's female jumpsuit"
	icon_state = "roboticist_f"
	item_state = "robo"
	item_color = "roboticist_f"

/obj/item/clothing/under/rank/hydroponics_fem
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards."
	name = "botanist's female jumpsuit"
	icon_state = "hydroponics_f"
	item_state = "g_suit"
	item_color = "hydroponics_f"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/bartender_fem
	desc = "It looks like it could use some more flair."
	name = "bartender's female uniform"
	icon_state = "bar_f"
	item_state = "ba_suit"
	item_color = "bar_f"

/obj/item/clothing/under/kimono
	name = "kimono"
	icon_state = "kimono"
	item_state = "kimono"
	item_color = "kimono"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/blacktango
	name = "black tango dress"
	desc = "Filled with latin fire."
	icon_state = "tango"
	item_state = "wcoat"
	item_color = "tango"

/obj/item/clothing/under/rank/centcom_officer_old
	desc = "It's a jumpsuit worn by Centcom Officers."
	name = "Centcom officer's jumpsuit"
	icon_state = "officer_old"
	item_state = "g_suit"
	item_color = "officer_old"

/obj/item/clothing/under/rank/centcom_commander_old
	desc = "It's a jumpsuit worn by Centcom's highest-tier Commanders."
	name = "Centcom officer's jumpsuit"
	icon_state = "centcom_old"
	item_state = "dg_suit"
	item_color = "centcom_old"

//Mafia
/obj/item/clothing/under/mafia
	name = "mafia outfit"
	desc = "The business of the mafia is business."
	icon_state = "mafia"
	item_state = "mafia"
	item_color = "mafia"

/obj/item/clothing/under/mafia/vest
	name = "mafia vest"
	desc = "Extreme problems often require extreme solutions."
	icon_state = "mafia_vest"
	item_state = "mafia_vest"
	item_color = "mafia_vest"

/obj/item/clothing/under/mafia/white
	name = "white mafia outfit"
	desc = "The best defense against the treacherous is treachery."
	icon_state = "mafia_white"
	item_state = "mafia_white"
	item_color = "mafia_white"

/obj/item/clothing/under/mafia/sue
	name = "mafia vest"
	desc = "The business is born into."
	icon_state = "sue_vest"
	item_state = "sue_vest"
	item_color = "sue_vest"

/obj/item/clothing/under/mafia/tan
	name = "leather mafia outfit"
	desc = "The big drum sounds good only from a distance."
	icon_state = "mafia_tan"
	item_state = "mafia_tan"
	item_color = "mafia_tan"

/obj/item/clothing/under/mafia/flappers
	name = "flappers"
	desc = "Nothing like the roaring 20s, flapping the night away on the dance floor."
	icon_state = "flapper"
	item_state = "flapper"
	item_color = "flapper"

/obj/item/clothing/under/rank/capcamsole
	desc = "It's a blue feminine camisole with some gold markings denoting the rank of \"Captain\" and gold aquila on it."
	name = "captain's camisole"
	icon_state = "capcamisole"
	item_state = "capcamisole"
	item_color = "capcamisole"

/obj/item/clothing/under/rank/goodman_shirt
	name = "head of personnel's suit"
	desc = "A good suit for good men."
	icon_state = "gmshirt"
	item_state = "gmshirt"
	item_color = "gmshirt"

/obj/item/clothing/under/rank/centcom/representative
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Ensign\" and bears \"N.C.V. Fearless CV-286\" on the left shounder."
	name = "NanoTrasen navy uniform"
	icon_state = "officer"
	item_state = "g_suit"
	item_color = "officer"
	displays_id = 0

/obj/item/clothing/under/rank/centcom/officer
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Lieutenant Commander\" and bears \"N.C.V. Fearless CV-286\" on the left shounder."
	name = "NanoTrasen officers uniform"
	icon_state = "officer"
	item_state = "g_suit"
	item_color = "officer"
	displays_id = 0

/obj/item/clothing/under/rank/centcom/captain
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Captain\" and bears \"N.C.V. Fearless CV-286\" on the left shounder."
	name = "NanoTrasen captains uniform"
	icon_state = "centcom"
	item_state = "dg_suit"
	item_color = "centcom"
	displays_id = 0

/obj/item/clothing/under/roman
	name = "roman armor"
	desc = "Ancient Roman armor. Made of metallic and leather straps."
	icon_state = "roman"
	item_state = "roman"
	item_color = "roman"

/obj/item/clothing/under/patient_gown
	name = "patient gown"
	desc = "A long loose piece of clothing worn in a hospital by someone doing or having an operation. It can be used as clothing for bedridden patients."
	icon_state = "patient_gown"
	item_color = "patient_gown"
	body_parts_covered = 0

/obj/item/clothing/under/pretty_dress
	name = "pretty dress"
	desc = "An Enchanting blue dress."
	icon_state = "pretty_dress"
	item_color = "pretty_dress"

/obj/item/clothing/under/sukeban_pants
	name = "sukeban pants"
	desc = "A white shirt with wide baggy pants"
	icon_state = "sukeban_pants"
	item_color = "sukeban_pants"

/obj/item/clothing/under/sukeban_dress
	name = "sukeban dress"
	desc = "A Dress of Japanese schoolgirls"
	icon_state = "sukeban_dress"
	item_color = "sukeban_dress"

/obj/item/clothing/under/karate
	name = "karate underwear"
	icon_state = "karate"
	item_color = "karate"

/obj/item/clothing/under/smoking
	name = "smoking"
	icon_state = "smoking_new"
	item_color = "smoking_new"

/obj/item/clothing/under/popking
	name = "popking suit"
	desc = "Classic costume of the King of Pop. A great choice if you want to twist again, watching Pretty Woman."
	icon_state = "popking"
	item_color = "popking"

/obj/item/clothing/under/popking/alternate
	icon_state = "popking2"
	item_color = "popking2"

/obj/item/clothing/under/pinkpolo
	name = "pink polo"
	desc = "The classic image of an American gangster 80. Hello from Miami."
	icon_state = "pinkpolo"
	item_color = "pinkpolo"

/obj/item/clothing/under/bathrobe
	name = "bath robe"
	icon_state = "bathrobe"
	item_color = "bathrobe"

/obj/item/clothing/under/bathtowel
	name = "bath towel"
	icon_state = "bathtowel"
	item_color = "bathtowel"
	has_sensor = 0
	slot_flags = SLOT_FLAGS_HEAD | SLOT_FLAGS_ICLOTHING

/obj/item/clothing/under/bathtowel/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot == SLOT_W_UNIFORM)
		body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	else if(slot == SLOT_HEAD)
		body_parts_covered = HEAD

/obj/item/clothing/under/nt_pmc_uniform
	name = "NT PCM Uniform"
	desc = "Uniform used by the private security corporation."
	icon_state = "nt_pmc_uniform"
	item_state = "bl_suit"
	item_color = "nt_pmc_uniform"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/nt_pmc_uniform_light
	name = "NT PCM Light Uniform"
	desc = "Uniform used by the private security corporation. This one without sleeves."
	icon_state = "nt_pmc_uniform"
	item_state = "bl_suit"
	item_color = "nt_pmc_uniform_light"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/rank/postal_dude_shirt
	name = "blue shirt"
	desc = "A blue shirt with image of alien in front."
	icon_state = "dude_shirt"
	item_state = "b_suit"
	item_color = "dude_shirt"

/obj/item/clothing/under/sport
	name = "white and black sport uniform"
	desc = "No pain - no gain."
	icon_state = "DDR_sport"
	item_state = "gy_suit"
	item_color = "DDR_sport"

/obj/item/clothing/under/sport/blue
	name = "blue sport uniform"
	icon_state = "blue_sport"
	item_state = "b_suit"
	item_color = "blue_sport"

/obj/item/clothing/under/sport/black
	name = "black sport uniform"
	icon_state = "black_sport"
	item_state = "bl_suit"
	item_color = "black_sport"

/obj/item/clothing/under/M35_Jacket
	name = "M35 Filde Jacket"
	desc = "Standart wehrmacht field uniform."
	icon_state = "M35_Filde_Jacket"
	item_state = "g_suit"
	item_color = "M35_Filde_Jacket"
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 5, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/M35_Jacket_Oficer
	name = "M35 Filde Oficer Jacket"
	desc = "Werhmacht officer jacket uniform."
	icon_state = "M35_Filde_Jacket_Officer"
	item_state = "g_suit"
	item_color = "M35_Filde_Jacket_Officer"
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 5, bomb = 0, bio = 10, rad = 0)

/obj/item/clothing/under/Waffen_SS_Form
	name = "Waffen SS Form"
	desc = "A special uniform for the SS."
	icon_state = "SS_Form"
	item_state = "bl_suit"
	item_color = "SS_Form"
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 5, bomb = 0, bio = 10, rad = 0)

