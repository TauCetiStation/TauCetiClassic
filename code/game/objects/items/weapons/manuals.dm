/*********************MANUALS (BOOKS)***********************/

//Oh god what the fuck I am not good at computer
/obj/item/weapon/book/manual
	icon = 'icons/obj/library.dmi'
	due_date = 0 // Game time in 1/10th seconds
	unique = 1   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified

/obj/item/weapon/book/manual/wiki
	var/wiki_page = ""
	window_size = "970x710"

/obj/item/weapon/book/manual/wiki/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/book/manual/wiki/atom_init_late()
	if(config.wikiurl)
		dat = {"

			<html><head>
			<style>
				html, body, iframe {
					padding: 0px; margin: 0px;
				}
				iframe {
					display: none;
				}
			</style>
			</head>
			<body>
			<script type="text/javascript">
				function pageloaded(myframe) {
					document.getElementById("loading").style.display = "none";
					myframe.style.display = "inline";
				}
			</script>
			<p id='loading'>You start skimming through the manual...</p>
			<iframe width='100%' height='97%' onload="pageloaded(this)" src="[config.wikiurl]/[wiki_page]?printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
			</body>

			</html>

			"}
	return ..()

//Engineering

/obj/item/weapon/book/manual/wiki/basic_engineering
	name = "Basic Engineering"
	icon_state ="bookBasicEngineering"
	item_state ="book3"
	author = "Einstein Engines Inc"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "Basic Engineering"
	wiki_page = "Guide_to_Engineering"

/obj/item/weapon/book/manual/wiki/construction
	name = "Guide to Construction"
	icon_state ="bookConstruction"
	item_state ="book3"
	author = "Engineering Encyclopedia"
	title = "Guide to Construction"
	wiki_page = "Guide_to_Constructions"

/obj/item/weapon/book/manual/wiki/atmospipes
	name = "Pipes and You: Getting To Know Atmospherics"
	icon_state = "bookAtmos"
	item_state ="book3"
	author = "Einstein Engines Inc"
	title = "Pipes and You: Getting To Know Atmospherics"
	wiki_page = "Atmospherics"

/obj/item/weapon/book/manual/wiki/supermatter_engine
	name = "Supermatter Engine User's Guide"
	icon_state = "bookSupermatter"
	item_state ="book3"
	author = "Einstein Engines Inc"
	title = "Supermatter Engine User's Guide"
	wiki_page = "Supermatter_Engine"

/obj/item/weapon/book/manual/wiki/engineering_hacking
	name = "Hacking"
	icon_state ="bookHacking"
	item_state ="book3"
	author = "Einstein Engines Inc"
	title = "Hacking"
	wiki_page = "Hacking"

/obj/item/weapon/book/manual/wiki/engineering_singularity
	name = "How to set up the Singularity Engine"
	icon_state ="bookSingularityEngine"
	item_state ="book3"
	author = "Einstein Engines Inc"
	title = "How to set up the Singularity Engine"
	wiki_page = "Singularity_Engine"

/obj/item/weapon/book/manual/wiki/engineering_tesla
	name = "How to set up the Telsa Engine"
	icon_state ="bookTeslaEngine"
	item_state ="book3"
	author = "Einstein Engines Inc"
	title = "How to set up the Telsa Engine"
	wiki_page = "Tesla_Engine"

/obj/item/weapon/book/manual/wiki/engineering_solars
	name = "How to set up the Solars"
	icon_state ="bookSolars"
	item_state ="book3"
	author = "Einstein Engines Inc"
	title = "How to set up the Solars"
	wiki_page = "Solars"

//Medical

/obj/item/weapon/book/manual/wiki/medical_guide_to_medicine
	name = "Medicine Manual"
	icon_state ="bookMedical"
	item_state ="book4"
	author = "NanoTrasen"
	title = "Medicine Manual"
	wiki_page = "Guide_to_Medicine"

/obj/item/weapon/book/manual/wiki/medical_genetics
	name = "Wonders of Genetics"
	icon_state ="bookGenetics"
	item_state ="book7"
	author = "NanoTrasen"
	title = "Wonders of Genetics"
	wiki_page = "Guide_to_Genetics"

/obj/item/weapon/book/manual/wiki/medical_surgery
	name = "Guide to Surgery"
	icon_state ="bookSurgery"
	item_state ="book7"
	author = "NanoTrasen"
	title = "Guide to Surgery"
	wiki_page = "Surgery"

/obj/item/weapon/book/manual/wiki/medical_virology
	name = "Virology Protocols"
	icon_state ="bookVirology"
	item_state ="book7"
	author = "NanoTrasen"
	title = "Virology Protocols"
	wiki_page = "Guide_to_Virology"

/obj/item/weapon/book/manual/wiki/medical_chemistry
	name = "Chemical Formulas"
	icon_state ="bookChemistry"
	item_state ="book7"
	author = "NanoTrasen"
	title = "Chemical Formulas"
	wiki_page = "Guide_to_Chemistry"

//Research and Development

/obj/item/weapon/book/manual/wiki/research_and_development
	name = "Basics of Research"
	icon_state = "bookBasicsOfResearch"
	item_state ="book6"
	author = "NanoTrasen"
	title = "Basics of Research"
	wiki_page = "Guide_to_Research_and_Development"

/obj/item/weapon/book/manual/wiki/guide_to_robotics
	name = "Robotics for Dummies"
	icon_state = "bookGuideToRobotics"
	item_state ="book6"
	author = "BioTech"
	title = "Robotics for Dummies"
	wiki_page = "Guide_to_Robotics"

/obj/item/weapon/book/manual/wiki/guide_to_toxins
	name = "Study of Phoron Properties"
	icon_state = "bookGuideToToxins"
	item_state ="book6"
	author = "Cybersun Industries"
	title = "Study of Phoron Properties"
	wiki_page = "Guide_to_toxins"

/obj/item/weapon/book/manual/wiki/guide_to_xenobiology
	name = "Xenobilogy: Grow and Study"
	icon_state = "bookXenobiology"
	item_state ="book6"
	author = "NanoTrasen"
	title = "Xenobilogy: Grow and Study"
	wiki_page = "Guide_to_xenobiology"

/obj/item/weapon/book/manual/wiki/guide_to_exosuits
	name = "Exosuits Construction"
	icon_state = "bookExosuits"
	item_state ="book6"
	author = "NanoTrasen"
	title = "Exosuits Construction"
	wiki_page = "Guide_to_Exosuits"

/obj/item/weapon/book/manual/wiki/guide_to_telescience
	name = "TeleScience: Science of Time and Space"
	icon_state = "bookTelescience"
	item_state ="book6"
	author = "NanoTrasen"
	title = "TeleScience: Science of Time and Space"
	wiki_page = "Guide_To_Telescience"

//Law and Order

/obj/item/weapon/book/manual/wiki/security_space_law
	name = "Space Law"
	desc = "A set of NanoTrasen guidelines for keeping law and order on their space stations."
	icon_state = "bookSpaceLaw"
	item_state = "book2"
	author = "NanoTrasen"
	title = "Space Law"
	wiki_page = "Space Law"

/obj/item/weapon/book/manual/wiki/sop
	name = "Standard Operating Procedure"
	icon_state = "bookSOP"
	item_state = "book9"
	author = "NanoTrasen"
	title = "Standard Operating Procedure"
	wiki_page = "Standard_Operating_Procedure"

/obj/item/weapon/book/manual/detective
	name = "The Film Noir: Proper Procedures for Investigations"
	icon_state ="bookDetective"
	item_state = "book2"
	author = "NanoTrasen"
	title = "The Film Noir: Proper Procedures for Investigations"

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				body {font-size: 13px; font-family: Verdana;}
				</style>
				</head>
				<body>
				<h1>Detective Work</h1>

				Between your bouts of self-narration and drinking whiskey on the rocks, you might get a case or two to solve.<br>
				To have the best chance to solve your case, follow these directions:
				<p>
				<ol>
					<li>Go to the crime scene. </li>
					<li>Take your scanner and scan EVERYTHING (Yes, the doors, the tables, even the dog). </li>
					<li>Once you are reasonably certain you have every scrap of evidence you can use, find all possible entry points and scan them, too. </li>
					<li>Return to your office. </li>
					<li>Using your forensic scanning computer, scan your scanner to upload all of your evidence into the database.</li>
					<li>Browse through the resulting dossiers, looking for the one that either has the most complete set of prints, or the most suspicious items handled. </li>
					<li>If you have 80% or more of the print (The print is displayed), go to step 10, otherwise continue to step 8.</li>
					<li>Look for clues from the suit fibres you found on your perpetrator, and go about looking for more evidence with this new information, scanning as you go. </li>
					<li>Try to get a fingerprint card of your perpetrator, as if used in the computer, the prints will be completed on their dossier.</li>
					<li>Assuming you have enough of a print to see it, grab the biggest complete piece of the print and search the security records for it. </li>
					<li>Since you now have both your dossier and the name of the person, print both out as evidence and get security to nab your baddie.</li>
					<li>Give yourself a pat on the back and a bottle of the ship's finest vodka, you did it!</li>
				</ol>
				<p>
				It really is that easy! Good luck!

				</body>
			</html>"}

//Civilian guides

/obj/item/weapon/book/manual/wiki/chefs_recipes
	name = "Bon Appetite: Chef's Recipes"
	icon_state = "bookChefsRecipes"
	item_state = "book10"
	author = "Victoria Ponsonby"
	title = "Bon Appetite: Chef's Recipes"
	wiki_page = "Guide_to_Food"

/obj/item/weapon/book/manual/wiki/barman_recipes
	name = "Barman Recipes"
	icon_state = "bookDrinks"
	item_state = "book4"
	author = "Sir John Rose"
	title = "Barman Recipes"
	wiki_page = "Drinks"

/obj/item/weapon/book/manual/wiki/hydroponics
	name = "From Seed to Fruit: Hydroponics for dummies"
	icon_state ="bookHydroponics"
	item_state = "book5"
	author = "Farmer John"
	title = "From Seed to Fruit: Hydroponics for dummies"
	wiki_page = "Guide_to_Hydroponics"

/obj/item/weapon/book/manual/wiki/supply_crates
	name = "Supply Crates Official List"
	icon_state ="bookSupplyCrates"
	item_state = "book8"
	author = "NanoTrasen"
	title = "Supply Crates Official List"
	wiki_page = "Supply_crates"

//Other

/obj/item/weapon/book/manual/wiki/rules
	name = "Rules"
	desc = "Don't be a jerk. This is a corollary of ignore all rules, and most behavioural rules are special cases of this one."
	icon_state = "bookRules"
	item_state = "book2"
	author = "Tau Ceti Classic"
	title = "Rules"
	wiki_page = "Rules"

//Old manuals that we should keep for a while

/obj/item/weapon/book/manual/hydroponics_beekeeping
	name = "The Ins and Outs of Apiculture - A Precise Art"
	icon_state ="bookHydroponicsBees"
	item_state ="book5"
	author = "Beekeeper Dave"
	title = "The Ins and Outs of Apiculture - A Precise Art"
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				body {font-size: 13px; font-family: Verdana;}
				</style>
				</head>
				<body>
				<h1>Raising Bees</h1>

				Bees are loving but fickle creatures. Don't mess with their hive and stay away from any clusters of them, and you'll avoid their ire.
				Sometimes, you'll need to dig around in there for those delicious sweeties though - in that case make sure you wear sealed protection gear
				and carry an extinguisher or smoker with you - any bees chasing you, once calmed down, can thusly be netted and returned safely to the hive.<br.
				<br>
				BeezEez is a cure-all panacea for them, but use it too much and the hive may grow to apocalyptic proportions. Other than that, bees are excellent pets
				for all the family and are excellent caretakers of one's garden: having a hive or two around will aid in the longevity and growth rate of plants,
				and aid them in fighting off poisons and disease.

				</body>
			</html>
			"}

/obj/item/weapon/book/manual/nuclear
	name = "Fission Mailed: Nuclear Sabotage 101"
	icon_state ="bookNuclear"
	item_state = "book10"
	author = "Syndicate"
	title = "Fission Mailed: Nuclear Sabotage 101"

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 21px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				body {font-size: 13px; font-family: Verdana;}
				</style>
				</head>
				<body>
				<h1>Nuclear Explosives 101</h1>
				Hello and thank you for choosing the Syndicate for your nuclear information needs. Today's crash course will deal with the operation of a Fusion Class NanoTrasen made Nuclear Device.<br><br>

				First and foremost, DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE. Pressing any button on the compacted bomb will cause it to extend and bolt itself into place. If this is done, to unbolt it, one must completely log in, which at this time may not be possible.<br>

				<h2>To make the nuclear device functional</h2>
				<ul>
					<li>Place the nuclear device in the designated detonation zone.</li>
					<li>Extend and anchor the nuclear device from its interface.</li>
					<li>Insert the nuclear authorisation disk into the slot.</li>
					<li>Type the numeric authorisation code into the keypad. This should have been provided.<br>
					<b>Note</b>: If you make a mistake, press R to reset the device.
					<li>Press the E button to log on to the device.</li>
				</ul><br>

				You now have activated the device. To deactivate the buttons at anytime, for example when you've already prepped the bomb for detonation, remove the authentication disk OR press R on the keypad.<br><br>
				Now the bomb CAN ONLY be detonated using the timer. Manual detonation is not an option. Toggle off the SAFETY.<br>
				<b>Note</b>: You wouldn't believe how many Syndicate Operatives with doctorates have forgotten this step.<br><br>

				So use the - - and + + to set a detonation time between 5 seconds and 10 minutes. Then press the timer toggle button to start the countdown. Now remove the authentication disk so that the buttons deactivate.<br>
				<b>Note</b>: THE BOMB IS STILL SET AND WILL DETONATE<br><br>

				Now before you remove the disk, if you need to move the bomb, you can toggle off the anchor, move it, and re-anchor.<br><br>

				Remember the order:<br>
				<b>Disk, Code, Safety, Timer, Disk, RUN!</b><br><br>
				Intelligence Analysts believe that normal NanoTrasen procedure is for the Captain to secure the nuclear authentication disk.<br><br>

				Good luck!
				</body>
			</html>
			"}

/obj/item/weapon/syndcodebook
	name = "black-red book"
	desc = "Ominous book with some gabblery written on yellow pages."
	icon = 'icons/obj/library.dmi'
	icon_state ="syndicate"
	item_state ="book"

/obj/item/weapon/syndcodebook/attack_self(mob/user)
	if(user.is_busy())
		return
	user.visible_message(
		"<span class='notice'>[user] starts reading \the [src] intently...</span>",
		"<span class='notice'>You start reading \the [src]...</span>"
	)
	if(do_after(user, 40, target = user))
		user.visible_message(
			"<span class='warning'>[user] perks at \the [src] and nods. Suddenly, \the [src] burns to ashes!</span>",
			"<span class='warning'>As soon as you finish reading \the [src], you become the speaker of Sy-Code and [src] burns to ashes.</span>"
		)
		user.add_language("Sy-Code")
		new /obj/effect/decal/cleanable/ash(user.loc)
		qdel(src)
