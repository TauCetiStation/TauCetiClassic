// Scrapheap Challenge: Space Station
// 1. Construction phase: 1 hour to build a space station (no atmos) using limited resources and disposal pipe dispensers to build warhead launchers with disposal pipes (Chute, Outlet and any other disposal pipe types).
// 2. Shelling phase: 1 hour to launch 40-50 warheads, primed with c4 detonators, using makeshift disposal delivery system (optionally: admin spawned mass drivers as additional warhead launcher type, if so - see the spawn conditions below).
// 3. Robust phase: 1 hour to completely eliminate surviving members of rival teams using melee combat (only makeshift weapons - no e-swords, no guns!).
// After the final phase has reached its time limit - the team with most surviving members wins.

// Participants options:
// Two teams on two opposite sides of the Scrapheap Challenge Arena (North-South/West-East) at least 5 team members per team, up to 10 team members per team.
// Four teams as originally intended - at least 5 team members per team, up to 10 team members per team.
// Make sure all teams has equal amount of team members!

// Optional mass driver conditions: Until it's possible for players to construct mass drivers and mass driver launch buttons - you can spawn them manually and change button/driver "id" variable in-game.
// If teams have 5 team members - one mass driver per team. If teams have 6 or more team members - two mass drivers per team. Each mass driver should have at least one, or two launch buttons in locations of players choice.
// Mass drivers and launch buttons can be spawned in any location within the allowed construction area (players can mark desired spawn locations with spray or crayons).

// Arena map itself is perfect for any space-based team challenges, including but not limited to the following game modes:
// 1. Scrapheap Challenge (as described above)
// 2. Capture the Flag (optimal if there are four participating teams)
// First phase is almost the same as SC, although improvised weapon arrays can be directed anywhere players want, but most important are the second phase differences: no warheads, teams get stun batons, iVend-o-Mat is a flag - team that steals the most "flags" within the time limit - wins.
// Sidenote for CtF: it's not allowed to surround machine with real or fake walls without building functional doorways that freely connect all rooms of the space station. Fake walls and hidden crew compartments are allowed. Door hacking - bolting and/or electrocutions are NOT allowed.
// 3. Battle of the Void (optimal if there are 20-40 participants):
// All participants form two opposing teams - instead of standard team equipment, players receive colored jumpsuits and emergency space suits (that can only prolong life for a few minutes until they breach from temperatures and pressure).
// One team gets Marauder mechs, the other gets Mauler mechs (equal stats - different look). Both teams receive identical mech modules to install on their improvised starships.
// Event locked z-layer will ensure all players will keep finding each other and flying around until only one team survives due to luck or ace piloting skills of some veterans.
// This event type is pretty entertaining thanks to mechs having very complex damage systems - a chance to randomly deflect the projectiles, as well as the ability to accumulate critical malfunctions that result in original deaths - cabin fire, oxygen leak, life support failure, navigation failure, short circuit, permanent equipment damage.
// For extra fun - try replacing mech icons with various starfighter types or even airplanes. Experiment to create balanced ship classes by playing with available equipment (e.g teams get two bombers, four interceptors, and four fighters, that look different and function differently).

//Team Challenge Satellite
//TCS is a state-of-the-art recreation facility that allows NanoTrasen employees and tourists to observe various Challenges from safe distance with comfort. For the convenience of visitors, stable energy supply is provided by CentCom.

/area/centcom/teamchallenge
	name = "Team Challenge Satellite"
	icon_state = "observatory"
	looped_ambience = 'sound/ambience/loop_regular.ogg'

//Adds Control Room ambience without making it separate area, as well as gives common sense advice for beginner event masters.

/obj/effect/landmark/teamchallenge
	name = "Control Room"
	icon_state = "x3"
	var/melody = 'sound/ambience/tcomms.ogg'
	var/message = "<b><span class='notice'>Before you press anything - make sure an equally balanced teams have been formed and fully equipped! Also inform the teams about your plans in advance to minimize the initial chaos. Let's get the show going!</span></b>"
	var/active = 1
	var/lchannel = 999

/obj/effect/landmark/teamchallenge/Crossed(mob/M)
	if(!active) return
	if(istype(M, /mob/living/carbon))
		M.playsound_local(null, melody, VOL_EFFECTS_MASTER, 20, FALSE, channel = lchannel, wait = TRUE, ignore_environment = TRUE)

//2558 Space Olympics by Uboaaaaaa

/obj/structure/sign/velocity_overlay/reklama/retro //If you are cleaning up the code, add it to general poster collection under var/global/list/legitposters
	name = "- 2558 Space Olympics"
	desc = "A poster glorifying forgotten Olympic champion - a golden medalist of 2558 in Robusting. Signed for a faithful fan, a champion's signature reads 'Katie'."
	icon = 'code/modules/teamchallenge/challenge.dmi'
	icon_state = "poster58_legit"

//Glowing arrow direction affects decal color: Red - north. Yellow - east. Green - south. Blue - west.

/obj/effect/decal/cleanable/glowingarrow
	name = "glowing arrow"
	desc = "Your space station weapon arrays shall be directed this way! You can remove this arrow with soap."
	density = 0
	anchored = 1
	layer = 2
	light_range = 3
	icon = 'code/modules/teamchallenge/challenge.dmi'
	icon_state = "arrow"

//Fake shield barrier preventing teams from attacking each other during construction phase. After first phase has concluded - use Del-all, or make a proper code for a switch.

/obj/effect/decal/teamchallenge
	name = "force field"
	desc = "It prevents teams from attacking each other too early."
	density = 1
	anchored = 1
	layer = 2
	light_range = 3
	icon = 'icons/effects/effects.dmi'
	icon_state = "energyshield"

//Colorful lights

/obj/machinery/light/small/green
	name = "green light fixture"
	desc = "A small green lighting fixture."
	brightness_range = 4
	brightness_power = 2
	brightness_color = "#00cc00"
	light_color = "#00cc00"
	nightshift_light_color = "#00cc00"

/obj/machinery/light/small/ultramarine
	name = "ultramarine light fixture"
	desc = "A small ultramarine lighting fixture... For the Emprah!"
	brightness_range = 4
	brightness_power = 2
	brightness_color = "#0000ff"
	light_color = "#0000ff"
	nightshift_light_color = "#0000ff"

/obj/machinery/light/small/purple
	name = "purple light fixture"
	desc = "A small purple lighting fixture."
	brightness_range = 4
	brightness_power = 2
	brightness_color = "#ff00ff"
	light_color = "#ff00ff"
	nightshift_light_color = "#ff00ff"

//Team warheads - robust explosive fuel tanks, they don't beep and can't be detected unless seen directly. C4 primer adds random factor and fun calculations to it.

/obj/structure/reagent_dispensers/fueltank/warhead
	name = "warhead"
	desc = "Attach c4 to prime the explosion. Keep away from fire!"
	icon = 'code/modules/teamchallenge/challenge.dmi'
	icon_state = "warhead"

/obj/structure/reagent_dispensers/fueltank/warhead/explode()
	explosion(src.loc,3,4,5)
	if(src)
		qdel(src)

/obj/structure/reagent_dispensers/fueltank/warhead/red
	name = "red warhead"
	icon_state = "redwarhead"

/obj/structure/reagent_dispensers/fueltank/warhead/yellow
	name = "yellow warhead"
	icon_state = "yellowwarhead"

/obj/structure/reagent_dispensers/fueltank/warhead/green
	name = "green warhead"
	icon_state = "greenwarhead"

/obj/structure/reagent_dispensers/fueltank/warhead/blue
	name = "blue warhead"
	icon_state = "bluewarhead"

//Team space suits - moded ERT rigs, but with equal stats. Suits contain medscanners to quickly evaluate if they should use their dying team member as spare mass driver projectile.

/obj/item/clothing/head/helmet/space/rig/ert/scrapheap
	name = "scrapheap team helmet"
	desc = "A helmet worn by the team members of Space Scrapheap Challenge."
	icon_state = "rig0-ert_stealth"
	item_state = "ert_stealth"
	item_color = "ert_stealth"
	armor = list(melee = 30, bullet = 20, laser = 20, energy = 20, bomb = 30, bio = 100, rad = 60)
	light_color = "#a0a080"
	action_button_name = "Toggle Helmet Visor Light"

/obj/item/clothing/suit/space/rig/ert/scrapheap
	name = "scrapheap team suit"
	desc = "A suit worn by the team members of Space Scrapheap Challenge."
	icon_state = "rig0-ert_stealth"
	item_state = "ert_stealth"
	armor = list(melee = 30, bullet = 20, laser = 20, energy = 20, bomb = 30, bio = 100, rad = 60)
	breach_threshold = 25
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/device/healthscanner)

/obj/item/clothing/head/helmet/space/rig/ert/scrapheap/red
	name = "red team helmet"
	desc = "A helmet worn by the red team members of Space Scrapheap Challenge."
	icon_state = "rig0-ert_security"
	item_state = "ert_security"
	item_color = "ert_security"

/obj/item/clothing/suit/space/rig/ert/scrapheap/red
	name = "yellow team suit"
	desc = "A suit worn by the red team members of Space Scrapheap Challenge."
	icon_state = "ert_security"
	item_state = "ert_security"

/obj/item/clothing/head/helmet/space/rig/ert/scrapheap/yellow
	name = "yellow team helmet"
	desc = "A helmet worn by the yellow team members of Space Scrapheap Challenge."
	icon_state = "rig0-ert_engineer"
	item_state = "ert_engineer"
	item_color = "ert_engineer"

/obj/item/clothing/suit/space/rig/ert/scrapheap/yellow
	name = "yellow team suit"
	desc = "A suit worn by the yellow team members of Space Scrapheap Challenge."
	icon_state = "ert_engineer"
	item_state = "ert_engineer"

/obj/item/clothing/head/helmet/space/rig/ert/scrapheap/green
	name = "green team helmet"
	desc = "A helmet worn by the white... I mean green team members of Space Scrapheap Challenge. Looks like the green paint has ran out."
	icon_state = "rig0-ert_medical"
	item_state = "ert_medical"
	item_color = "ert_medical"

/obj/item/clothing/suit/space/rig/ert/scrapheap/green
	name = "green team suit"
	desc = "A suit worn by the white... I mean green team members of Space Scrapheap Challenge. Looks like the green paint has ran out."
	icon_state = "ert_medical"
	item_state = "ert_medical"

/obj/item/clothing/head/helmet/space/rig/ert/scrapheap/blue
	name = "blue team helmet"
	desc = "A helmet worn by the blue team members of Space Scrapheap Challenge."
	icon_state = "rig0-ert_commander"
	item_state = "ert_commander"
	item_color = "ert_commander"

/obj/item/clothing/suit/space/rig/ert/scrapheap/blue
	name = "blue team suit"
	desc = "A suit worn by the blue team members of Space Scrapheap Challenge."
	icon_state = "ert_commander"
	item_state = "ert_commander"

//90 matter RCD - allows to build exactly one small sized room with an airlock.

/obj/item/weapon/rcd/scrapheap
	name = "overcharged rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor and basic airlocks."
	matter = 90

//Resource full stacks

/obj/item/stack/sheet/metal/fifty
	amount = 50

/obj/item/stack/sheet/plasteel/fifty
	amount = 50

/obj/item/stack/sheet/wood/fifty
	amount = 50

/obj/item/stack/sheet/glass/fifty
	amount = 50

//There will be no air in these haphazard space stations, so spessmen won't be able to undress and eat food without killing themselves...

/obj/item/weapon/reagent_containers/hypospray/autoinjector/junkfood
	name = "liquid junkfood autoinjector"
	desc = "A label on it reads: <i>Warning: Do not use more than one at a time, may cause nausea! Nutrition Facts: total fat 50%, total carbohydrate 30%, protein 20%</i>"
	icon_state = "auto_minig_t3"
	volume = 16

/obj/item/weapon/reagent_containers/hypospray/autoinjector/junkfood/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("nutriment", 16)
	update_icon()

//iVend-o-mat / iVent / Event-o-mat - Softheart wuz here.

/obj/machinery/vending/ivend
	name = "iVend-o-mat"
	desc = "A specialized Scrapheap Challenge construction materials and equipment vendor."
	icon = 'code/modules/teamchallenge/challenge.dmi'
	icon_state = "ivend"
	products = list(/obj/item/stack/sheet/metal/fifty = 4, /obj/item/stack/sheet/glass/fifty = 4, /obj/item/stack/sheet/wood/fifty = 4,
					/obj/item/weapon/airlock_electronics = 15 , /obj/item/weapon/stock_parts/cell/high = 15, /obj/item/weapon/module/power_control = 10,
					/obj/item/stack/cable_coil/random = 10, /obj/item/device/assembly/signaler = 10, /obj/item/device/assembly/infra = 10,
					/obj/item/device/assembly/prox_sensor = 10, /obj/item/weapon/weldpack = 5, /obj/item/weapon/storage/box/lights/mixed = 4,
					/obj/item/weapon/soap/nanotrasen = 2, /obj/item/weapon/reagent_containers/hypospray/autoinjector/junkfood = 70)
	contraband = list(/obj/random/randomfigure = 1, /obj/random/plushie = 1)
	product_ads = "It's iVend time!;iVend-o-mat - for all your iVend needs!;uBuild while iVend.;Hurry up, the time is running out!;Every iVend-o-mat unit is valuable - don't let anyone steal yours!;This iVend is sponsored by Tau Ceti branch of NanoTrasen Corporation!;iVend - a good way to get away from routine!;A new life awaits you in the Off-world colonies. The chance to begin again in a golden land of opportunity and adventure."

//Agent F

/mob/living/simple_animal/pug/frank
	name = "Frank"
	real_name = "Frank"
	desc = "It's a pug. Not at all suspicious, pug."
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "Who let the dogs out?! Woof, woof, woof, woof, woof!", "Grrrrr... Bark! Bark! Bark!", "You humans! When will you learn size doesn't matter? Just because something's important, doesn't mean it's not very small.", "How about we do the good cop, bad cop routine? You can interrogate the witness, and I'll just growl. Grrrrr...", "Listen, partner. I may look like a dog, but I'm only play one here.")
	speak_emote = list("says", "barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps", "pants", "looks around", "adjusts the skin")
	emote_see = list("shakes its head", "chases its tail", "shivers", "laughs", "pretends to be a dog", "hums a pop song")
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/xenomeat = 3)

//Team toolboxes - these look a bit different from those found on the Station.

/obj/item/weapon/storage/toolbox/scrapheap
	name = "challenge toolbox"
	desc = "It contains almost everything you need to build your own space station."
	icon_state = "syndicate"
	item_state = "toolbox_syndi"

/obj/item/weapon/storage/toolbox/scrapheap/atom_init()
	. = ..()
	new /obj/item/weapon/rcd/scrapheap(src)
	new /obj/item/weapon/stock_parts/cell/hyper(src)
	new /obj/item/weapon/module/power_control(src)
	new /obj/item/device/multitool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/weapon/extinguisher/mini(src)
	new /obj/item/weapon/airlock_painter(src)
	new /obj/item/toy/crayon/spraycan(src)

/obj/item/weapon/storage/toolbox/scrapheap/red
	name = "red challenge toolbox"
	icon_state = "red"
	item_state = "toolbox_red"

/obj/item/weapon/storage/toolbox/scrapheap/yellow
	name = "yellow challenge toolbox"
	icon_state = "yellow"
	item_state = "toolbox_yellow"

/obj/item/weapon/storage/toolbox/scrapheap/green
	name = "green challenge toolbox"
	desc = "Wait a minute! This doesn't look green at all!"
	icon_state = "blue"
	item_state = "toolbox_blue"

/obj/item/weapon/storage/toolbox/scrapheap/blue
	name = "blue challenge toolbox"
	icon_state = "blue"
	item_state = "toolbox_blue"

//The crate that held the Ark of the Covenant following its discovery by Indiana Jones in 1936.

/obj/structure/closet/crate/secure/woodseccrate/ark
	name = "9906753"
	desc = "A secure wooden crate. There is a large black stamp on the side that reads:<b><br>TOP SECRET<br>ARMY INTEL 9906753<br>DO NOT OPEN!</b>"

//Symbolic prize - Space Station equivalent of trophy cup. Very useful if you want to combat large fire or travel in space without wasting jetpack oxygen.

/obj/item/weapon/extinguisher/golden
	name = "golden fire extinguisher"
	desc = "A revered relic of the Founding Fathers. According to the legends - it possesses divine firefighting powers, as well as its healing touch is capable of curing minor brute damage."
	icon = 'code/modules/teamchallenge/challenge.dmi'
	icon_state = "gold_extinguisher0"
	item_state = "emergency_engi"
	hitsound = list('sound/effects/pray_chaplain.ogg')
	force = -777
	attack_verb = list("blessed", "consecrated")
	max_water = 777
	spray_range = 7

//If you change camera computers networks manually in-game with VV (security, detective, entertainment and others) - the networks won't switch. So here is a dedicated telescreen that can be spawned anywhere anytime.

/obj/machinery/computer/security/telescreen/entertainment/teamchallenge
	name = "entertainment monitor"
	desc = "Hopefully that thing can broadcast something interesting."
	network = list("ERT")

/* edge teleport */
var/list/dest_teleports = list(/obj/effect/landmark/tele/one = list(), /obj/effect/landmark/tele/two = list(), /obj/effect/landmark/tele/three = list(), /obj/effect/landmark/tele/four = list())

var/portals_active = FALSE

/obj/effect/landmark/tele
	name = "teleport"
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "build"

/obj/effect/landmark/tele/atom_init()
	dest_teleports[src.type] += src
	world.log << dest_teleports[src.type]

/obj/effect/landmark/tele/Crossed(atom/movable/A)
	if(portals_active)
		var/obj/target = pick(dest_teleports[pick(dest_teleports - src.type)])
		var/target_loc = get_step(target, target.dir)

		var/throwed = A.throwing
		if(throwed)
			A.throwing = 0
		A.forceMove(target_loc)

		if(ismob(A))
			var/mob/M = A
			if(M.pulling)
				M.pulling.forceMove(get_turf(M), keep_pulling = TRUE)

		stoplag()//Let a diagonal move finish, if necessary (dunno, copypaste)
		A.newtonian_move(target.dir)

		if(throwed)
			A.throw_at(get_step(target_loc, target.dir), 3, 2)
	
/obj/effect/landmark/tele/one
	name = "teleport zone 1"

/obj/effect/landmark/tele/two
	name = "teleport zone 2"

/obj/effect/landmark/tele/three
	name = "teleport zone 3"

/obj/effect/landmark/tele/four
	name = "teleport zone 4"

/* verbs */

var/list/event_verbs = list(/client/proc/toggle_portals)

/client/proc/toggle_portals()
	set category = "Event"
	set name = "Toggle portals"

	portals_active = !portals_active

	message_admins("[key_name_admin(usr)] toggled portals [portals_active ? "on" : "off"].")
	