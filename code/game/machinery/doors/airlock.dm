#define AIRLOCK_WIRE_IDSCAN 1
#define AIRLOCK_WIRE_MAIN_POWER1 2
#define AIRLOCK_WIRE_MAIN_POWER2 3
#define AIRLOCK_WIRE_DOOR_BOLTS 4
#define AIRLOCK_WIRE_BACKUP_POWER1 5
#define AIRLOCK_WIRE_BACKUP_POWER2 6
#define AIRLOCK_WIRE_OPEN_DOOR 7
#define AIRLOCK_WIRE_AI_CONTROL 8
#define AIRLOCK_WIRE_ELECTRIFY 9
#define AIRLOCK_WIRE_SAFETY 10
#define AIRLOCK_WIRE_SPEED 11
#define AIRLOCK_WIRE_LIGHT 12

/*
#Z1
AI wire control revamp.
Now you need to mend "AI control" wire back. You can't anymore hack the door software to regain control permamently, while "AI control" wire is cut.
So, call engi_borg or engineer to fix this wire.
Also, pulse now disables "AI control" until AI or Borg hacks the door software.
*/

/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	isWireColorCut - returns 1 if that color wire is cut, or 0 if not
	isWireCut - returns 1 if that wire (e.g. AIRLOCK_WIRE_DOOR_BOLTS) is cut, or 0 if not
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
	hasPower - 1 if the main or backup power are functioning, 0 if not.
	requiresIDs - 1 if the airlock is requiring IDs, 0 if not
	isAllPowerCut - 1 if the main and backup power both have cut wires.
	regainMainPower - handles the effect of main power coming back on.
	loseMainPower - handles the effect of main power going offline. Usually (if one isn't already running) spawn a thread to count down how long it will be offline - counting down won't happen if main power was completely cut along with backup power, though, the thread will just sleep.
	loseBackupPower - handles the effect of backup power going offline.
	regainBackupPower - handles the effect of main power coming back on.
	shock - has a chance of electrocuting its target.
*/

//This generates the randomized airlock wire assignments for the game.
/proc/RandomAirlockWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/wires = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	airlockIndexToFlag = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	airlockIndexToWireColor = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	airlockWireColorToIndex = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	var/flagIndex = 1
	for (var/flag=1, flag<4096, flag+=flag)
		var/valid = 0
		var/list/colorList = list(AIRLOCK_WIRE_IDSCAN, AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2, AIRLOCK_WIRE_DOOR_BOLTS,
		AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2, AIRLOCK_WIRE_OPEN_DOOR, AIRLOCK_WIRE_AI_CONTROL, AIRLOCK_WIRE_ELECTRIFY,
		AIRLOCK_WIRE_SAFETY, AIRLOCK_WIRE_SPEED, AIRLOCK_WIRE_LIGHT)

		while (!valid)
			var/colorIndex = pick(colorList)
			if(wires[colorIndex]==0)
				valid = 1
				wires[colorIndex] = flag
				airlockIndexToFlag[flagIndex] = flag
				airlockIndexToWireColor[flagIndex] = colorIndex
				airlockWireColorToIndex[colorIndex] = flagIndex
				colorList -= colorIndex
		flagIndex+=1
	return wires

/* Example:
Airlock wires color -> flag are { 64, 128, 256, 2, 16, 4, 8, 32, 1 }.
Airlock wires color -> index are { 7, 8, 9, 2, 5, 3, 4, 6, 1 }.
Airlock index -> flag are { 1, 2, 4, 8, 16, 32, 64, 128, 256 }.
Airlock index -> wire color are { 9, 4, 6, 7, 5, 8, 1, 2, 3 }.
*/


#define AIRLOCK_DEFAULT  0
#define AIRLOCK_CLOSED   1
#define AIRLOCK_CLOSING  2
#define AIRLOCK_OPEN     3
#define AIRLOCK_OPENING  4
#define AIRLOCK_DENY     5
#define AIRLOCK_EMAG     6
var/list/airlock_overlays = list()

/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "closed"
	explosion_resistance = 15

	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = 0 // if 1, this door can't be hacked by the AI
	var/secondsMainPowerLost = 0 //The number of seconds until power is restored.
	var/secondsBackupPowerLost = 0 //The number of seconds until power is restored.
	var/spawnPowerRestoreRunning = 0
	var/welded = null
	var/locked = 0
	var/lights = 1 // bolt lights show by default
	var/wires = 4095
	secondsElectrified = 0 //How many seconds remain until the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/aiDisabledIdScanner = 0
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther = null
	var/closeOtherId = null
	var/list/signalers[12]
	var/lockdownbyai = 0
	autoclose = 1
	var/assembly_type = /obj/structure/door_assembly
	var/mineral = null
	var/justzap = 0
	var/safe = 1
	normalspeed = 1
	var/obj/item/weapon/airlock_electronics/electronics = null
	var/hasShocked = 0 //Prevents multiple shocks from happening
	var/pulseProof = 0 //#Z1 AI hacked this door after previous pulse?
	var/shockedby = list()
	var/close_timer_id = null

	var/inner_material = null //material of inner filling; if its an airlock with glass, this should be set to "glass"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'

	var/image/old_frame_overlay //keep those in order to prevent unnecessary updating
	var/image/old_filling_overlay
	var/image/old_lights_overlay
	var/image/old_panel_overlay
	var/image/old_weld_overlay
	var/image/old_sparks_overlay

	door_open_sound          = 'sound/machines/airlock/airlockToggle.ogg'
	door_close_sound         = 'sound/machines/airlock/airlockToggle.ogg'
	var/door_deni_sound      = 'sound/machines/airlock/airlockDenied.ogg'
	var/door_bolt_up_sound   = 'sound/machines/airlock/airlockBoltsUp.ogg'
	var/door_bolt_down_sound = 'sound/machines/airlock/airlockBoltsDown.ogg'
	var/door_forced_sound    = 'sound/machines/airlock/airlockForced.ogg'

/obj/machinery/door/airlock/New(loc, dir = null)
	..()
	if(src.closeOtherId != null)
		spawn (5)
			for (var/obj/machinery/door/airlock/A in machines)
				if(A.closeOtherId == src.closeOtherId && A != src)
					src.closeOther = A
					break
	if(glass && !inner_material)
		inner_material = "glass"
	if(dir)
		src.dir = dir
	update_icon()

/obj/machinery/door/airlock/Destroy()
	if(electronics)
		qdel(electronics)
		electronics = null
	closeOther = null
	return ..()

/*
About the new airlock wires panel:
*	An airlock wire dialog can be accessed by the normal way or by using wirecutters or a multitool on the door while the wire-panel is open. This would show the following wires, which you can either wirecut/mend or send a multitool pulse through. There are 9 wires.
*		one wire from the ID scanner. Sending a pulse through this flashes the red light on the door (if the door has power). If you cut this wire, the door will stop recognizing valid IDs. (If the door has 0000 access, it still opens and closes, though)
*		two wires for power. Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter). Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be \red open, but bolts-raising will not work. Cutting these wires may electrocute the user.
*		one wire for door bolts. Sending a pulse through this drops door bolts (whether the door is powered or not) or raises them (if it is). Cutting this wire also drops the door bolts, and mending it does not raise them. If the wire is cut, trying to raise the door bolts will not work.
*		two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter). Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
*		one wire for opening the door. Sending a pulse through this while the door has power makes it open the door if no access is required.
*		one wire for AI control. Sending a pulse through this blocks AI control for a second or so (which is enough to see the AI control light on the panel dialog go off and back on again). Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
*		one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds. Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted. (Currently it is also STAYING electrified until someone mends the wire)
*		one wire for controling door safetys.  When active, door does not close on someone.  When cut, door will ruin someone's shit.  When pulsed, door will immedately ruin someone's shit.
*		one wire for controlling door speed.  When active, dor closes at normal rate.  When cut, door does not close manually.  When pulsed, door attempts to close every tick.
*/

/obj/machinery/door/airlock/bumpopen(mob/living/user) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(!issilicon(usr))
		if(src.isElectrified())
			if(!src.justzap)
				if(src.shock(user, 100))
					src.justzap = 1
					spawn (10)
						src.justzap = 0
					return
			else /*if(src.justzap)*/
				return
		else if(user.hallucination > 50 && prob(10) && src.operating == 0)
			to_chat(user, "\red <B>You feel a powerful shock course through your body!</B>")
			user.halloss += 10
			user.stunned += 10
			return
	..(user)

/obj/machinery/door/airlock/bumpopen(mob/living/simple_animal/user)
	..(user)


/obj/machinery/door/airlock/proc/pulse(wireColor)
	//var/wireFlag = airlockWireColorToFlag[wireColor] //not used in this function
	var/wireIndex = airlockWireColorToIndex[wireColor]
	switch(wireIndex)
		if(AIRLOCK_WIRE_IDSCAN)
			//Sending a pulse through this disables emergency access and flashes the red light on the door (if the door has power).
			if(hasPower())
				do_animate("deny")
				if(src.emergency)
					src.emergency = 0
					src.update_icon()
		if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
			//Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter).
			src.loseMainPower()
		if(AIRLOCK_WIRE_DOOR_BOLTS)
			//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
			//raises them if they are down (only if power's on)
			if(!src.locked)
				bolt()
				for(var/mob/M in range(1,src))
					to_chat(M, "You hear a click from the bottom of the door.")
				src.updateUsrDialog()
			else
				if(hasPower()) //only can raise bolts if power's on
					unbolt()
					for(var/mob/M in range(1,src))
						to_chat(M, "You hear a click from the bottom of the door.")
					src.updateUsrDialog()
			update_icon()

		if(AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			//two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter).
			src.loseBackupPower()
		if(AIRLOCK_WIRE_AI_CONTROL)
//#Z1
			if(src.pulseProof == 0)
				if(src.aiControlDisabled == 0)
					src.aiControlDisabled = 1
				else if(src.aiControlDisabled == 1)
					src.aiControlDisabled = 0
				src.updateUsrDialog()
				//src.updateDialog()
/*
			if(src.aiControlDisabled == 0)
				src.aiControlDisabled = 1
			else if(src.aiControlDisabled == -1)
				src.aiControlDisabled = 2
			src.updateDialog()
			spawn(10)
				if(src.aiControlDisabled == 1)
					src.aiControlDisabled = 0
				else if(src.aiControlDisabled == 2)
					src.aiControlDisabled = -1
				src.updateDialog()
*/
//##Z1
		if(AIRLOCK_WIRE_ELECTRIFY)
			//one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds.
			if(src.secondsElectrified==0)
				shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>")
				src.secondsElectrified = 30
				spawn(10)
					//TODO: Move this into process() and make pulsing reset secondsElectrified to 30
					while (src.secondsElectrified>0)
						src.secondsElectrified-=1
						if(src.secondsElectrified<0)
							src.secondsElectrified = 0
//						src.updateUsrDialog()  //Commented this line out to keep the airlock from clusterfucking you with electricity. --NeoFite
						sleep(10)
		if(AIRLOCK_WIRE_OPEN_DOOR)
			//tries to open the door without ID
			//will succeed only if the ID wire is cut or the door requires no access
			if(!src.requiresID() || src.check_access(null))
				if(density)	open()
				else		close()
		if(AIRLOCK_WIRE_SAFETY)
			safe = !safe
			if(!src.density)
				close()
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_SPEED)
			normalspeed = !normalspeed
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_LIGHT)
			lights = !lights
			src.updateUsrDialog()


/obj/machinery/door/airlock/proc/cut(wireColor)
	var/wireFlag = airlockWireColorToFlag[wireColor]
	var/wireIndex = airlockWireColorToIndex[wireColor]
	wires &= ~wireFlag
	switch(wireIndex)
		if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
			//Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be crowbarred open, but bolts-raising will not work. Cutting these wires may electocute the user.
			src.loseMainPower()
			src.shock(usr, 50)
			src.updateUsrDialog()
		if(AIRLOCK_WIRE_DOOR_BOLTS)
			//Cutting this wire also drops the door bolts, and mending it does not raise them. (This is what happens now, except there are a lot more wires going to door bolts at present)
			if(src.locked!=1)
				bolt()
			src.updateUsrDialog()
		if(AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			//Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
			src.loseBackupPower()
			src.shock(usr, 50)
			src.updateUsrDialog()
		if(AIRLOCK_WIRE_AI_CONTROL)
			//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
			//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
//#Z1
			if(src.aiControlDisabled == 0)
				src.aiControlDisabled = 1
			src.updateUsrDialog()
/*
			if(src.aiControlDisabled == 0)
				src.aiControlDisabled = 1
			else if(src.aiControlDisabled == -1)
				src.aiControlDisabled = 2
			src.updateUsrDialog()
*/
//##Z1
		if(AIRLOCK_WIRE_ELECTRIFY)
			//Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted.
			if(src.secondsElectrified != -1)
				shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>")
				src.secondsElectrified = -1
		if (AIRLOCK_WIRE_SAFETY)
			safe = 0
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_SPEED)
			autoclose = 0
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_LIGHT)
			lights = 0
			src.updateUsrDialog()

/obj/machinery/door/airlock/proc/mend(wireColor)
	var/wireFlag = airlockWireColorToFlag[wireColor]
	var/wireIndex = airlockWireColorToIndex[wireColor] //not used in this function
	wires |= wireFlag
	switch(wireIndex)
		if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
			if((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
				src.regainMainPower()
				src.shock(usr, 50)
				src.updateUsrDialog()
		if(AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			if((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
				src.regainBackupPower()
				src.shock(usr, 50)
				src.updateUsrDialog()
		if(AIRLOCK_WIRE_AI_CONTROL)
			//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
			//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
//#Z1
			if(src.aiControlDisabled == 1)
				src.aiControlDisabled = 0
/*
			if(src.aiControlDisabled == 1)
				src.aiControlDisabled = 0
			else if(src.aiControlDisabled == 2)
				src.aiControlDisabled = -1
			src.updateUsrDialog()
*/
		if(AIRLOCK_WIRE_ELECTRIFY)
			if(src.secondsElectrified == -1)
				src.secondsElectrified = 0

		if (AIRLOCK_WIRE_SAFETY)
			safe = 1
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_SPEED)
			autoclose = 1
			if(!src.density)
				close()
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_LIGHT)
			lights = 1
			src.updateUsrDialog()


/obj/machinery/door/airlock/proc/isElectrified()
	if(src.secondsElectrified != 0)
		return 1
	return 0

/obj/machinery/door/airlock/proc/isWireColorCut(wireColor)
	var/wireFlag = airlockWireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/door/airlock/proc/isWireCut(wireIndex)
	var/wireFlag = airlockIndexToFlag[wireIndex]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/door/airlock/proc/canAIControl()
	return ((src.aiControlDisabled!=1) && (!src.isAllPowerCut()));

/obj/machinery/door/airlock/proc/canAIHack()
	return ((src.aiControlDisabled==1) && (!hackProof) && (!src.isAllPowerCut()));

/obj/machinery/door/airlock/hasPower()
	return ((src.secondsMainPowerLost==0 || src.secondsBackupPowerLost==0) && !(stat & NOPOWER))

/obj/machinery/door/airlock/requiresID()
	return !(src.isWireCut(AIRLOCK_WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerCut()
	var/retval=0
	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1) || src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
		if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1) || src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
			retval=1
	return retval

/obj/machinery/door/airlock/proc/regainMainPower()
	if(src.secondsMainPowerLost > 0)
		src.secondsMainPowerLost = 0

/obj/machinery/door/airlock/proc/loseMainPower()
	if(src.secondsMainPowerLost <= 0)
		src.secondsMainPowerLost = 60
		if(src.secondsBackupPowerLost < 10)
			src.secondsBackupPowerLost = 10
	if(!src.spawnPowerRestoreRunning)
		src.spawnPowerRestoreRunning = 1
		spawn(0)
			var/cont = 1
			while (cont)
				sleep(10)
				cont = 0
				if(src.secondsMainPowerLost>0)
					if((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
						src.secondsMainPowerLost -= 1
						src.updateDialog()
					cont = 1

				if(src.secondsBackupPowerLost>0)
					if((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
						src.secondsBackupPowerLost -= 1
						src.updateDialog()
					cont = 1
			src.spawnPowerRestoreRunning = 0
			src.updateDialog()

/obj/machinery/door/airlock/proc/loseBackupPower()
	if(src.secondsBackupPowerLost < 60)
		src.secondsBackupPowerLost = 60

/obj/machinery/door/airlock/proc/regainBackupPower()
	if(src.secondsBackupPowerLost > 0)
		src.secondsBackupPowerLost = 0

/obj/machinery/door/airlock/proc/bolt()
	if(locked)
		return
	locked = 1
	playsound(src, door_bolt_down_sound, 30, 0, 3)
	update_icon()

/obj/machinery/door/airlock/proc/unbolt()
	if(!locked)
		return
	locked = 0
	playsound(src, door_bolt_up_sound, 30, 0, 3)
	update_icon()

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/proc/shock(mob/user, prb)
	if(!hasPower())		// unpowered, no shock
		return 0
	if(hasShocked)
		return 0	//Already shocked someone recently?
	if(!prob(prb))
		return 0 //you lucked out, no shock for you
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start() //sparks always.
	if(electrocute_mob(user, get_area(src), src))
		hasShocked = 1
		sleep(10)
		hasShocked = 0
		return 1
	else
		return 0

/obj/machinery/door/airlock/update_icon(state = AIRLOCK_DEFAULT)
	switch(state)
		if(AIRLOCK_DEFAULT)
			if(density)
				state = AIRLOCK_CLOSED
			else
				state = AIRLOCK_OPEN
			icon_state = ""
		if(AIRLOCK_OPEN, AIRLOCK_CLOSED)
			icon_state = ""
		if(AIRLOCK_DENY, AIRLOCK_OPENING, AIRLOCK_CLOSING, AIRLOCK_EMAG)
			icon_state = "nonexistenticonstate"
	set_airlock_overlays(state)

/obj/machinery/door/airlock/proc/set_airlock_overlays(state)
	var/image/frame_overlay
	var/image/filling_overlay
	var/image/lights_overlay
	var/image/panel_overlay
	var/image/weld_overlay
	var/image/sparks_overlay

	switch(state)
		if(AIRLOCK_CLOSED)
			frame_overlay = get_airlock_overlay("closed", icon)
			if(inner_material)
				filling_overlay = get_airlock_overlay("[inner_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(p_open)
				panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(lights && hasPower())
				if(locked)
					lights_overlay = get_airlock_overlay("lights_bolts", overlays_file)
				else if(emergency)
					lights_overlay = get_airlock_overlay("lights_emergency", overlays_file)

		if(AIRLOCK_DENY)
			frame_overlay = get_airlock_overlay("closed", icon)
			if(inner_material)
				filling_overlay = get_airlock_overlay("[inner_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(p_open)
				panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			lights_overlay = get_airlock_overlay("lights_denied", overlays_file)

		if(AIRLOCK_EMAG)
			frame_overlay = get_airlock_overlay("closed", icon)
			sparks_overlay = get_airlock_overlay("sparks", overlays_file)
			if(inner_material)
				filling_overlay = get_airlock_overlay("[inner_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(p_open)
				panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)

		if(AIRLOCK_CLOSING)
			frame_overlay = get_airlock_overlay("closing", icon)
			if(inner_material)
				filling_overlay = get_airlock_overlay("[inner_material]_closing", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closing", icon)
			if(lights && hasPower())
				lights_overlay = get_airlock_overlay("lights_closing", overlays_file)
			if(p_open)
				panel_overlay = get_airlock_overlay("panel_closing", overlays_file)

		if(AIRLOCK_OPEN)
			frame_overlay = get_airlock_overlay("open", icon)
			if(inner_material)
				filling_overlay = get_airlock_overlay("[inner_material]_open", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_open", icon)
			if(p_open)
				panel_overlay = get_airlock_overlay("panel_open", overlays_file)

		if(AIRLOCK_OPENING)
			frame_overlay = get_airlock_overlay("opening", icon)
			if(inner_material)
				filling_overlay = get_airlock_overlay("[inner_material]_opening", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_opening", icon)
			if(lights && hasPower())
				lights_overlay = get_airlock_overlay("lights_opening", overlays_file)
			if(p_open)
				panel_overlay = get_airlock_overlay("panel_opening", overlays_file)

	// Doesn't used overlays.Cut() for performance reasons.
	if(frame_overlay != old_frame_overlay)
		overlays -= old_frame_overlay
		overlays += frame_overlay
		old_frame_overlay = frame_overlay
	if(filling_overlay != old_filling_overlay)
		overlays -= old_filling_overlay
		overlays += filling_overlay
		old_filling_overlay = filling_overlay
	if(lights_overlay != old_lights_overlay)
		if(lights_overlay)
			lights_overlay.layer = LIGHTING_LAYER + 1
			lights_overlay.plane = LIGHTING_PLANE + 1
		overlays -= old_lights_overlay
		overlays += lights_overlay
		old_lights_overlay = lights_overlay
	if(panel_overlay != old_panel_overlay)
		overlays -= old_panel_overlay
		overlays += panel_overlay
		old_panel_overlay = panel_overlay
	if(weld_overlay != old_weld_overlay)
		overlays -= old_weld_overlay
		overlays += weld_overlay
		old_weld_overlay = weld_overlay
	if(sparks_overlay != old_sparks_overlay)
		if(sparks_overlay)
			sparks_overlay.layer = LIGHTING_LAYER + 1
			sparks_overlay.plane = LIGHTING_PLANE + 1
		overlays -= old_sparks_overlay
		overlays += sparks_overlay
		old_sparks_overlay = sparks_overlay

/proc/get_airlock_overlay(icon_state, icon_file)
	var/iconkey = "[icon_state][icon_file]"
	if(airlock_overlays[iconkey])
		return airlock_overlays[iconkey]
	airlock_overlays[iconkey] = image(icon_file, icon_state)
	return airlock_overlays[iconkey]

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			update_icon(AIRLOCK_OPENING)
		if("closing")
			update_icon(AIRLOCK_CLOSING)
		if("deny")
			update_icon(AIRLOCK_DENY)
			playsound(src, door_deni_sound, 50, 0, 3)
			sleep(6)
			update_icon(AIRLOCK_CLOSED)
			icon_state = "closed"

/obj/machinery/door/airlock/attack_ai(mob/user)
//#Z1
	if(src.isWireCut(AIRLOCK_WIRE_AI_CONTROL))
		to_chat(user, "Airlock AI control wire is cut. Please call the engineer or engiborg to fix this problem.")
		return
//##Z1
	if(!(src.canAIControl()) || IsAdminGhost(usr))
		if(src.canAIHack())
			src.hack(user)
			return
		else
			to_chat(user, "Airlock AI control has been blocked with a firewall. Unable to hack.")

	//Separate interface for the AI.
	user.set_machine(src)
	var/t1 = text("<B>Airlock Control</B><br>\n")
	if(src.secondsMainPowerLost > 0)
		if((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
			t1 += text("Main power is offline for [] seconds.<br>\n", src.secondsMainPowerLost)
		else
			t1 += text("Main power is offline indefinitely.<br>\n")
	else
		t1 += text("Main power is online.")

	if(src.secondsBackupPowerLost > 0)
		if((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
			t1 += text("Backup power is offline for [] seconds.<br>\n", src.secondsBackupPowerLost)
		else
			t1 += text("Backup power is offline indefinitely.<br>\n")
	else if(src.secondsMainPowerLost > 0)
		t1 += text("Backup power is online.")
	else
		t1 += text("Backup power is offline, but will turn on if main power fails.")
	t1 += "<br>\n"

	if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
		t1 += text("IdScan wire is cut.<br>\n")
	else if(src.aiDisabledIdScanner)
		t1 += text("IdScan disabled. <A href='?src=\ref[];aiEnable=1'>Enable?</a><br>\n", src)
	else
		t1 += text("IdScan enabled. <A href='?src=\ref[];aiDisable=1'>Disable?</a><br>\n", src)

	if(src.emergency)
		t1 += text("Emergency access override is enabled. <A href='?src=\ref[];aiDisable=11'>Disable?</a><br>\n", src)
	else
		t1 += text("Emergency access override is disabled. <A href='?src=\ref[];aiEnable=11'>Enable?</a><br>\n", src)

	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1))
		t1 += text("Main Power Input wire is cut.<br>\n")
	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
		t1 += text("Main Power Output wire is cut.<br>\n")
	if(src.secondsMainPowerLost == 0)
		t1 += text("<A href='?src=\ref[];aiDisable=2'>Temporarily disrupt main power?</a>.<br>\n", src)
	if(src.secondsBackupPowerLost == 0)
		t1 += text("<A href='?src=\ref[];aiDisable=3'>Temporarily disrupt backup power?</a>.<br>\n", src)

	if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1))
		t1 += text("Backup Power Input wire is cut.<br>\n")
	if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
		t1 += text("Backup Power Output wire is cut.<br>\n")

	if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
		t1 += text("Door bolt drop wire is cut.<br>\n")
	else if(!src.locked)
		t1 += text("Door bolts are up. <A href='?src=\ref[];aiDisable=4'>Drop them?</a><br>\n", src)
	else
		t1 += text("Door bolts are down.")
		if(src.hasPower())
			t1 += text(" <A href='?src=\ref[];aiEnable=4'>Raise?</a><br>\n", src)
		else
			t1 += text(" Cannot raise door bolts due to power failure.<br>\n")

	if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
		t1 += text("Door bolt lights wire is cut.<br>\n")
	else if(!src.lights)
		t1 += text("Door lights are off. <A href='?src=\ref[];aiEnable=10'>Enable?</a><br>\n", src)
	else
		t1 += text("Door lights are on. <A href='?src=\ref[];aiDisable=10'>Disable?</a><br>\n", src)

	if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
		t1 += text("Electrification wire is cut.<br>\n")
	if(src.secondsElectrified==-1)
		t1 += text("Door is electrified indefinitely. <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", src)
	else if(src.secondsElectrified>0)
		t1 += text("Door is electrified temporarily ([] seconds). <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", src.secondsElectrified, src)
	else
		t1 += text("Door is not electrified. <A href='?src=\ref[];aiEnable=5'>Electrify it for 30 seconds?</a> Or, <A href='?src=\ref[];aiEnable=6'>Electrify it indefinitely until someone cancels the electrification?</a><br>\n", src, src)

	if(src.isWireCut(AIRLOCK_WIRE_SAFETY))
		t1 += text("Door force sensors not responding.</a><br>\n")
	else if(src.safe)
		t1 += text("Door safeties operating normally.  <A href='?src=\ref[];aiDisable=8'> Override?</a><br>\n",src)
	else
		t1 += text("Danger.  Door safeties disabled.  <A href='?src=\ref[];aiEnable=8'> Restore?</a><br>\n",src)

	if(src.isWireCut(AIRLOCK_WIRE_SPEED))
		t1 += text("Door timing circuitry not responding.</a><br>\n")
	else if(src.normalspeed)
		t1 += text("Door timing circuitry operating normally.  <A href='?src=\ref[];aiDisable=9'> Override?</a><br>\n",src)
	else
		t1 += text("Warning.  Door timing circuitry operating abnormally.  <A href='?src=\ref[];aiEnable=9'> Restore?</a><br>\n",src)




	if(src.welded)
		t1 += text("Door appears to have been welded shut.<br>\n")
	else if(!src.locked)
		if(src.density)
			t1 += text("<A href='?src=\ref[];aiEnable=7'>Open door</a><br>\n", src)
		else
			t1 += text("<A href='?src=\ref[];aiDisable=7'>Close door</a><br>\n", src)

	t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)
	user << browse(t1, "window=airlock")
	onclose(user, "airlock")

//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 11 lift access override
//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door, 11 lift access override


/obj/machinery/door/airlock/proc/hack(mob/user)
	if(src.aiHacking==0)
		src.aiHacking=1
		spawn(20)
			//TODO: Make this take a minute
			to_chat(user, "Airlock AI control has been blocked. Beginning fault-detection.")
			sleep(50)
			if(src.canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				src.aiHacking=0
				return
			else if(!src.canAIHack())
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				src.aiHacking=0
				return
			to_chat(user, "Fault confirmed: airlock control wire disabled.")//#Z1
			sleep(20)
			to_chat(user, "Attempting to hack into airlock. This may take some time.")
			sleep(200)
			if(src.canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				src.aiHacking=0
				return
			else if(!src.canAIHack())
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				src.aiHacking=0
				return
			to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
			sleep(170)
			if(src.canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				src.aiHacking=0
				return
			else if(!src.canAIHack())
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				src.aiHacking=0
				return
			to_chat(user, "Transfer complete. Forcing airlock to execute program.")
			sleep(50)
			//disable blocked control
//#Z1
			//src.aiControlDisabled = 2
			src.aiControlDisabled = 0
			src.pulseProof = 1
//##Z1
			to_chat(user, "Receiving control information from airlock.")
			sleep(10)
			//bring up airlock dialog
			src.aiHacking = 0
			if (user)
				src.attack_ai(user)

/obj/machinery/door/airlock/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (src.isElectrified())
		if (istype(mover, /obj/item))
			var/obj/item/i = mover
			if (i.m_amt)
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
	return ..()

/obj/machinery/door/airlock/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/door/airlock/attack_paw(mob/user)
	if(istype(user, /mob/living/carbon/alien/humanoid))
		if(welded || locked)
			to_chat(user, "\red The door is sealed, it cannot be pried open.")
			return
		else if(!density)
			return
		else
			to_chat(user, "<span class='red'>You force your claws between the doors and begin to pry them open...</span>")
			playsound(src, door_forced_sound, 30, 1, -4)
			if (do_after(user,40, target = src))
				if(!src) return
				open(1)
	return

/obj/machinery/door/airlock/attack_animal(mob/user)
	if(istype(user, /mob/living/simple_animal/hulk))
		var/mob/living/simple_animal/hulk/H = user
		H.attack_hulk(src)

/obj/machinery/door/airlock/proc/door_rupture(mob/user)
	var/obj/structure/door_assembly/da = new src.assembly_type(loc)
	da.anchored = 0

	var/target = da.loc
	for(var/i in 1 to 4)
		target = get_turf(get_step(target,user.dir))
	da.throw_at(target, 200, 100, spin = FALSE)

	if(mineral)
		da.change_mineral_airlock_type(mineral)
	if(glass && da.can_insert_glass)
		da.set_glass(TRUE)
	da.state = ASSEMBLY_WIRED
	da.created_name = name
	da.update_state()

	var/obj/item/weapon/airlock_electronics/ae
	ae = new/obj/item/weapon/airlock_electronics(loc)
	if(!req_access)
		check_access()
	if(req_access.len)
		ae.conf_access = req_access
	else if (req_one_access.len)
		ae.conf_access = req_one_access
		ae.one_access = 1
	ae.loc = da
	da.electronics = ae

	qdel(src)

/obj/machinery/door/airlock/attack_hand(mob/user)
	if(!(istype(user, /mob/living/silicon) || IsAdminGhost(user)))
		if(src.isElectrified())
			if(src.shock(user, 100))
				return
	if(HULK in user.mutations) //#Z2
		..(user)
		return //##Z2

	// No. -- cib , Yes. -- zve , No. -- cib -- YES! -- zve

	if(ishuman(user) && prob(40) && src.density)
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			playsound(src, 'sound/effects/bang.ogg', 25, 1)
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				visible_message("\red [user] headbutts the airlock.")
				var/datum/organ/external/affecting = H.get_organ("head")
				H.Stun(8)
				H.Weaken(5)
				affecting.take_damage(10, 0)
			else
				visible_message("\red [user] headbutts the airlock. Good thing they're wearing a helmet.")
			return

	if(src.p_open)
		user.set_machine(src)
		var/t1 = text("<B>Access Panel</B><br>\n")

		//t1 += text("[]: ", airlockFeatureNames[airlockWireColorToIndex[9]])
		var/list/wires = list(
			"Orange" = 1,
			"Dark red" = 2,
			"White" = 3,
			"Yellow" = 4,
			"Red" = 5,
			"Blue" = 6,
			"Green" = 7,
			"Grey" = 8,
			"Black" = 9,
			"Gold" = 10,
			"Aqua" = 11,
			"Pink" = 12
		)
		for(var/wiredesc in wires)
			var/is_uncut = src.wires & airlockWireColorToFlag[wires[wiredesc]]
			t1 += "[wiredesc] wire: "
			if(!is_uncut)
				t1 += "<a href='?src=\ref[src];wires=[wires[wiredesc]]'>Mend</a>"
			else
				t1 += "<a href='?src=\ref[src];wires=[wires[wiredesc]]'>Cut</a> "
				t1 += "<a href='?src=\ref[src];pulse=[wires[wiredesc]]'>Pulse</a> "
				if(src.signalers[wires[wiredesc]])
					t1 += "<a href='?src=\ref[src];remove-signaler=[wires[wiredesc]]'>Detach signaler</a>"
				else
					t1 += "<a href='?src=\ref[src];signaler=[wires[wiredesc]]'>Attach signaler</a>"
			t1 += "<br>"

		t1 += text("<br>\n[]<br>\n[]<br>\n[]<br>\n[]<br>\n[]<br>\n[]<br>\n[]",
		(src.locked ? "The door bolts have fallen!" : "The door bolts look up."),
		(src.lights ? "The door bolt lights are on." : "The door bolt lights are off!"),
		((src.hasPower()) ? "The test light is on." : "The test light is off!"),
		(src.aiControlDisabled==0 ? "The 'AI control allowed' light is on." : "The 'AI control allowed' light is off."),
		(src.safe==0 ? "The 'Check Wiring' light is on." : "The 'Check Wiring' light is off."),
		(src.normalspeed==0 ? "The 'Check Timing Mechanism' light is on." : "The 'Check Timing Mechanism' light is off."),
		(src.emergency==0 ? "The emergency lights are off." : "The emergency lights are on."))

		t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)

		user << browse(t1, "window=airlock")
		onclose(user, "airlock")

	else
		..(user)
	return


/obj/machinery/door/airlock/Topic(href, href_list, var/no_window = 0)
	if(href_list["close"])
		usr << browse(null, "window=airlock")
		usr.unset_machine(src)
		return FALSE

	. = ..(href, href_list)
	if(!. && !(href_list["wires"] || href_list["pulse"] || href_list["signaler"] || href_list["remove-signaler"]))
		return

	if(p_open)
		if(href_list["wires"])
			var/t1 = text2num(href_list["wires"])
			if(!istype(usr.get_active_hand(), /obj/item/weapon/wirecutters))
				to_chat(usr, "You need wirecutters!")
				return FALSE
			if(isWireColorCut(t1))
				mend(t1)
			else
				cut(t1)

		else if(href_list["pulse"])
			var/t1 = text2num(href_list["pulse"])
			if(!istype(usr.get_active_hand(), /obj/item/device/multitool))
				to_chat(usr, "You need a multitool!")
				return FALSE
			if(isWireColorCut(t1))
				to_chat(usr, "You can't pulse a cut wire.")
				return FALSE
			else
				pulse(t1)

		else if(href_list["signaler"])
			var/wirenum = text2num(href_list["signaler"])
			if(!istype(usr.get_active_hand(), /obj/item/device/assembly/signaler))
				to_chat(usr, "You need a signaller!")
				return FALSE
			if(isWireColorCut(wirenum))
				to_chat(usr, "You can't attach a signaller to a cut wire.")
				return FALSE
			var/obj/item/device/assembly/signaler/R = usr.get_active_hand()
			if(R.secured)
				to_chat(usr, "This radio can't be attached!")
				return FALSE
			var/mob/M = usr
			M.drop_item()
			R.loc = src
			R.airlock_wire = wirenum
			signalers[wirenum] = R

		else if(href_list["remove-signaler"])
			var/wirenum = text2num(href_list["remove-signaler"])
			if(!signalers[wirenum])
				to_chat(usr, "There's no signaller attached to that wire!")
				return FALSE
			var/obj/item/device/assembly/signaler/R = signalers[wirenum]
			R.loc = usr.loc
			R.airlock_wire = null
			signalers[wirenum] = null

	if((istype(usr, /mob/living/silicon) && src.canAIControl()) || IsAdminGhost(usr))
		//AI
		//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 8 door safties, 9 door speed, 11 lift access override
		//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door,  8 door safties, 9 door speed, 11 lift access override
		if(href_list["aiDisable"])
			var/code = text2num(href_list["aiDisable"])
			switch (code)
				if(1)
					// Disable idscan
					if(isWireCut(AIRLOCK_WIRE_IDSCAN))
						to_chat(usr, "The IdScan wire has been cut - So, you can't disable it, but it is already disabled anyways.")
					else if(aiDisabledIdScanner)
						to_chat(usr, "You've already disabled the IdScan feature.")
					else
						aiDisabledIdScanner = 1

				if(2)
					// Disrupt main power
					if(!secondsMainPowerLost)
						loseMainPower()
					else
						to_chat(usr, "Main power is already offline.")

				if(3)
					// Disrupt backup power
					if(!secondsBackupPowerLost)
						loseBackupPower()
					else
						to_chat(usr, "Backup power is already offline.")

				if(4)
					// Drop door bolts
					if(isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						to_chat(usr, "You can't drop the door bolts - The door bolt dropping wire has been cut.")
					else if(!locked)
						bolt()

				if(5)
					// Un-electrify door
					if(isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						to_chat(usr, "Can't un-electrify the airlock - The electrification wire is cut.")
					else if(secondsElectrified == -1)
						secondsElectrified = 0
					else if(secondsElectrified > 0)
						secondsElectrified = 0

				if(7)
					// Close door
					if(welded)
						to_chat(usr, "The airlock has been welded shut!")
					else if(locked)
						to_chat(usr, "The door bolts are down!")
					else
						close()

				if(8)
					// Safeties!  We don't need no stinking safeties!
					if(isWireCut(AIRLOCK_WIRE_SAFETY))
						to_chat(usr, "Control to door sensors is disabled.")
					else if(safe)
						safe = 0
					else
						to_chat(usr, "Firmware reports safeties already overriden.")

				if(9)
					// Door speed control
					if(isWireCut(AIRLOCK_WIRE_SPEED))
						to_chat(usr, "Control to door timing circuitry has been severed.")
					else if(normalspeed)
						normalspeed = 0
					else
						to_chat(usr, "Door timing circurity already accellerated.")

				if(10)
					// Bolt lights
					if(isWireCut(AIRLOCK_WIRE_LIGHT))
						to_chat(usr, "Control to door bolt lights has been severed.")
					else if (lights)
						lights = 0
						update_icon()
					else
						to_chat(usr, "Door bolt lights are already disabled!")

				if(11)
					// Emergency access
					if(emergency)
						emergency = 0
						update_icon()
					else
						to_chat(usr, "Emergency access is already disabled!")

		else if(href_list["aiEnable"])
			var/code = text2num(href_list["aiEnable"])
			switch (code)
				if(1)
					// Enable idscan
					if(isWireCut(AIRLOCK_WIRE_IDSCAN))
						to_chat(usr, "You can't enable IdScan - The IdScan wire has been cut.")
					else if(aiDisabledIdScanner)
						aiDisabledIdScanner = 0
					else
						to_chat(usr, "The IdScan feature is not disabled.")

				if(4)
					// Raise door bolts
					if(isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						to_chat(usr, "The door bolt drop wire is cut - you can't raise the door bolts.<br>\n")
					else if(!locked)
						to_chat(usr, "The door bolts are already up.<br>\n")
					else
						if(hasPower())
							unbolt()
						else
							to_chat(usr, "Cannot raise door bolts due to power failure.<br>\n")

				if(5)
					// Electrify door for 30 seconds
					if(isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						to_chat(usr, "The electrification wire has been cut.<br>\n")
					else if(secondsElectrified == -1)
						to_chat(usr, "The door is already indefinitely electrified. You'd have to un-electrify it before you can re-electrify it with a non-forever duration.<br>\n")
					else if(secondsElectrified)
						to_chat(usr, "The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n")
					else
						shockedby += "\[[time_stamp()]\][usr](ckey:[usr.ckey])"
						usr.attack_log += "\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>"
						secondsElectrified = 30
						spawn(10)
							while(secondsElectrified > 0)
								secondsElectrified -= 1
								if(secondsElectrified < 0)
									secondsElectrified = 0
								updateUsrDialog()
								sleep(10)

				if(6)
					// Electrify door indefinitely
					if(isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						to_chat(usr, "The electrification wire has been cut.<br>\n")
					else if(secondsElectrified == -1)
						to_chat(usr, "The door is already indefinitely electrified.<br>\n")
					else if(secondsElectrified)
						to_chat(usr, "The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n")
					else
						shockedby += "\[[time_stamp()]\][usr](ckey:[usr.ckey])"
						usr.attack_log += "\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>"
						secondsElectrified = -1

				if(7)
					// Open door
					if(welded)
						to_chat(usr, "The airlock has been welded shut!")
					else if(locked)
						to_chat(usr, "The door bolts are down!")
					else
						open()

				if (8)
					// Safeties!  Maybe we do need some stinking safeties!
					if (isWireCut(AIRLOCK_WIRE_SAFETY))
						to_chat(usr, "Control to door sensors is disabled.")
					else if (!safe)
						safe = 1
					else
						to_chat(usr, "Firmware reports safeties already in place.")

				if(9)
					// Door speed control
					if(isWireCut(AIRLOCK_WIRE_SPEED))
						to_chat(usr, "Control to door timing circuitry has been severed.")
					else if (!normalspeed)
						normalspeed = 1
					else
						to_chat(usr, "Door timing circurity currently operating normally.")

				if(10)
					// Bolt lights
					if(isWireCut(AIRLOCK_WIRE_LIGHT))
						to_chat(usr, "Control to door bolt lights has been severed.")
					else if (!lights)
						lights = 1
						update_icon()
					else
						to_chat(usr, "Door bolt lights are already enabled!")

				if(11)
					// Emergency access
					if(!emergency)
						emergency = 1
						update_icon()
					else
						to_chat(usr, "Emergency access is already disabled!")

	if(!no_window)
		updateUsrDialog()

/obj/machinery/door/airlock/attackby(C, mob/user)

	if(istype(C,/obj/item/weapon/changeling_hammer) && !src.operating && src.density) // yeah, hammer ignore electrify
		var/obj/item/weapon/changeling_hammer/W = C
		user.do_attack_animation(src)
		visible_message("\red <B>[user]</B> has punched \the <B>[src]!</B>")
		playsound(loc, 'sound/effects/grillehit.ogg', 50, 1)
		if(W.use_charge(src,user) && prob(20))
			playsound(loc, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), 50, 1)
			door_rupture(user)
		return

	if(!(istype(usr, /mob/living/silicon) || IsAdminGhost(user)))
		if(src.isElectrified())
			if(src.shock(user, 75))
				return
	if(istype(C, /obj/item/device/detective_scanner) || istype(C, /obj/item/taperoll))
		return

	src.add_fingerprint(user)

	if((istype(C, /obj/item/weapon/weldingtool) && !( src.operating > 0 ) && src.density))
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0,user))
			if(!src.welded)
				src.welded = 1
			else
				src.welded = null
			src.update_icon()
			return
		else
			return
	else if(istype(C, /obj/item/weapon/screwdriver))
		src.p_open = !( src.p_open )
		src.update_icon()
	else if(istype(C, /obj/item/weapon/wirecutters))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/device/multitool))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/device/assembly/signaler))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/weapon/pai_cable))	// -- TLE
		var/obj/item/weapon/pai_cable/cable = C
		cable.plugin(src, user)
	else if(istype(C, /obj/item/weapon/crowbar) || istype(C, /obj/item/weapon/twohanded/fireaxe) )
		var/beingcrowbarred = null
		if(istype(C, /obj/item/weapon/crowbar) )
			beingcrowbarred = 1 //derp, Agouri
		else
			beingcrowbarred = 0
		if( beingcrowbarred && (operating == -1 || density && welded && operating != 1 && src.p_open && !hasPower() && !src.locked) )
			playsound(src, 'sound/items/Crowbar.ogg', 100, 1)
			user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to remove electronics from the airlock assembly.")
			if(do_after(user,40,target = src))
				to_chat(user, "\blue You removed the airlock electronics!")

				var/obj/structure/door_assembly/da = new assembly_type(src.loc)
				da.anchored = 1
				if(mineral)
					da.change_mineral_airlock_type(mineral)
				if(glass && da.can_insert_glass)
					da.set_glass(TRUE)
				da.state = ASSEMBLY_WIRED
				da.dir = src.dir
				da.created_name = src.name
				da.update_state()

				var/obj/item/weapon/airlock_electronics/ae
				if(!electronics)
					ae = new/obj/item/weapon/airlock_electronics( src.loc )
					if(!src.req_access)
						src.check_access()
					if(src.req_access.len)
						ae.conf_access = src.req_access
					else if (src.req_one_access.len)
						ae.conf_access = src.req_one_access
						ae.one_access = 1
				else
					ae = electronics
					electronics = null
					ae.loc = src.loc
				if(operating == -1)
					ae.icon_state = "door_electronics_smoked"
					ae.broken = TRUE
					operating = 0

				qdel(src)
				return
		else if(hasPower())
			to_chat(user, "<span class='notice'>The airlock's motors resist your efforts to force it.</span>")
		else if(locked)
			to_chat(user, "<span class='notice'>The airlock's bolts prevent it from being forced.</span>")
		else if( !welded && !operating )
			if(density)
				if(beingcrowbarred == 0) //being fireaxe'd
					var/obj/item/weapon/twohanded/fireaxe/F = C
					if(F:wielded)
						spawn(0)	open(1)
					else
						to_chat(user, "\red You need to be wielding the Fire axe to do that.")
				else
					spawn(0)	open(1)
			else
				if(beingcrowbarred == 0)
					var/obj/item/weapon/twohanded/fireaxe/F = C
					if(F:wielded)
						spawn(0)	close(1)
					else
						to_chat(user, "\red You need to be wielding the Fire axe to do that.")
				else
					spawn(0)	close(1)

	else if(istype(C, /obj/item/weapon/airlock_painter)) 		//airlock painter
		change_paintjob(C, user)
	else
		..()
	return

/obj/machinery/door/airlock/phoron/attackby(C, mob/user)
	if(C)
		ignite(is_hot(C))
	..()


/obj/machinery/door/airlock/open_checks()
	if(..() && !welded && !locked)
		return TRUE
	return FALSE

/obj/machinery/door/airlock/close_checks()
	if(..() && !welded && !locked)
		if(safe)
			for(var/turf/T in locs)
				if(locate(/mob/living) in T)
					autoclose()
					return FALSE
		return TRUE
	return FALSE

/obj/machinery/door/airlock/normal_open_checks()
	if(hasPower() && !isWireCut(AIRLOCK_WIRE_OPEN_DOOR))
		return TRUE
	return FALSE

/obj/machinery/door/airlock/normal_close_checks()
	if(hasPower() && !isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
		return TRUE
	return FALSE

/obj/machinery/door/airlock/do_open()
	send_status_if_allowed()
	if(closeOther != null && istype(closeOther, /obj/machinery/door/airlock/) && !closeOther.density)
		closeOther.close()
	if(hasPower())
		use_power(50)
	..()
	autoclose()

/obj/machinery/door/airlock/do_close()
	send_status_if_allowed()
	if(hasPower())
		use_power(50)
	..()

/obj/machinery/door/airlock/do_afterclose()
	for(var/turf/T in locs)
		for(var/mob/living/M in T)
			if(isrobot(M))
				M.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
			else
				M.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
				M.SetStunned(5)
				M.SetWeakened(5)
			M.visible_message("<span class='red'>[M] was crushed by the [src] door.</span>",
			                  "<span class='danger'>[src] door crushed you.</span>")

		for(var/obj/structure/window/W in T)
			W.ex_act(2)
	..()

/obj/machinery/door/airlock/proc/autoclose()
	if(autoclose)
		if(close_timer_id)
			deltimer(close_timer_id)
		close_timer_id = addtimer(src, "do_autoclose", normalspeed ? 150 : 5)

/obj/machinery/door/airlock/proc/do_autoclose()
	close_timer_id = null
	close()

/obj/machinery/door/airlock/proc/prison_open()
	unbolt()
	open()
	bolt()
	return

/obj/machinery/door/airlock/proc/change_paintjob(obj/item/C, mob/user)
	var/obj/item/weapon/airlock_painter/W
	if(istype(C, /obj/item/weapon/airlock_painter))
		W = C
	else
		to_chat(user, "If you see this, it means airlock/change_paintjob() was called with something other than an airlock painter. Check your code!")
		return

	if(!W.can_use(user))
		return

	var/list/optionlist
	if(inner_material == "glass")
		optionlist = list("Public", "Public2", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance")
	else
		optionlist = list("Public", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance", "External", "High Security")

	var/paintjob = input(user, "Please select a paintjob for this airlock.") in optionlist
	if((!in_range(src, usr) && src.loc != usr) || !W.use(user))
		return
	switch(paintjob)
		if("Public")
			icon          = 'icons/obj/doors/airlocks/station/public.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Public2")
			icon          = 'icons/obj/doors/airlocks/station2/glass.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
		if("Engineering")
			icon          = 'icons/obj/doors/airlocks/station/engineering.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Atmospherics")
			icon          = 'icons/obj/doors/airlocks/station/atmos.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Security")
			icon          = 'icons/obj/doors/airlocks/station/security.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Command")
			icon          = 'icons/obj/doors/airlocks/station/command.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Medical")
			icon          = 'icons/obj/doors/airlocks/station/medical.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Research")
			icon          = 'icons/obj/doors/airlocks/station/research.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			heat_proof    = glass
		if("Mining")
			icon          = 'icons/obj/doors/airlocks/station/mining.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Maintenance")
			icon          = 'icons/obj/doors/airlocks/station/maintenance.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("External")
			icon          = 'icons/obj/doors/airlocks/external/external.dmi'
			overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
		if("High Security")
			icon          = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
			overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
	update_icon()

/obj/structure/door_scrap
	name = "Door Scrap"
	desc = "Just a bunch of garbage."
	var/ticker = 0
	var/icon/door = icon('icons/effects/effects.dmi',"Sliced")
	//light_power = 1
	//light_color = "#cc0000"


/obj/structure/door_scrap/attackby(obj/O, mob/user)
	if(istype(O,/obj/item/weapon/wrench))
		if(ticker >= 300)
			playsound(user.loc, 'sound/items/Ratchet.ogg', 50)
			user.visible_message("[user] has disassemble these scrap...")
			new /obj/item/stack/sheet/metal(src.loc)
			new /obj/item/stack/sheet/metal(src.loc)
			qdel(src)
		else
			to_chat(user,"<span=userdanger>This is too hot to dismantle it</span>")
			if(prob(10))
				to_chat(user,"<span=userdanger>You accidentally drop your wrench in the flame</span>")
				qdel(O)
	else
		return


/obj/structure/door_scrap/New()
	var/image/fire_overlay = image("icon"='icons/effects/effects.dmi', "icon_state"="s_fire", "layer" = (LIGHTING_LAYER + 1))
	fire_overlay.plane = LIGHTING_PLANE + 1
	overlays += fire_overlay
	START_PROCESSING(SSobj, src)

/obj/structure/door_scrap/process()
	if(ticker >= 300)
		overlays.Cut()
		STOP_PROCESSING(SSobj, src)
		return
	ticker++
	var/spot = (locate(/obj/effect/decal/cleanable/water) in src.loc)
	if((spot))
		ticker +=10