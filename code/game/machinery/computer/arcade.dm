/obj/machinery/computer/arcade
	name = "arcade machine"
	desc = "Does not support Pin ball."
	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"
	circuit = /obj/item/weapon/circuitboard/arcade
	var/enemy_name = "Space Villian"
	var/temp = "Winners Don't Use Spacedrugs" //Temporary message, for attack messages, etc
	var/player_hp = 30 //Player health/attack points
	var/player_mp = 10
	var/enemy_hp = 45 //Enemy health/attack points
	var/enemy_mp = 20
	var/gameover = 0
	var/blocked = 0 //Player cannot attack/heal while set
	var/list/prizes = list(	/obj/item/weapon/storage/box/snappops			= 2,
							/obj/item/toy/blink								= 2,
							/obj/item/clothing/under/syndicate/tacticool	= 2,
							/obj/item/toy/sword								= 2,
							/obj/item/toy/gun								= 2,
							/obj/item/toy/crossbow							= 2,
							/obj/item/clothing/suit/syndicatefake			= 2,
							/obj/item/weapon/storage/fancy/crayons			= 2,
							/obj/item/toy/spinningtoy						= 2,
							/obj/item/toy/prize/ripley						= 1,
							/obj/item/toy/prize/fireripley					= 1,
							/obj/item/toy/prize/deathripley					= 1,
							/obj/item/toy/prize/gygax						= 1,
							/obj/item/toy/prize/durand						= 1,
							/obj/item/toy/prize/honk						= 1,
							/obj/item/toy/prize/marauder					= 1,
							/obj/item/toy/prize/seraph						= 1,
							/obj/item/toy/prize/mauler						= 1,
							/obj/item/toy/prize/odysseus					= 1,
							/obj/item/toy/prize/phazon						= 1,
							/obj/item/toy/waterflower						= 1,
							/obj/item/toy/nuke								= 1,
							/obj/item/toy/minimeteor						= 2,
							/obj/item/toy/carpplushie						= 2,
							/obj/item/toy/owl								= 2,
							/obj/item/toy/griffin							= 2,
							/obj/item/toy/figure/cmo						= 1,
							/obj/item/toy/figure/assistant					= 1,
							/obj/item/toy/figure/atmos						= 1,
							/obj/item/toy/figure/bartender					= 1,
							/obj/item/toy/figure/borg						= 1,
							/obj/item/toy/figure/botanist					= 1,
							/obj/item/toy/figure/captain					= 1,
							/obj/item/toy/figure/cargotech					= 1,
							/obj/item/toy/figure/ce							= 1,
							/obj/item/toy/figure/chaplain					= 1,
							/obj/item/toy/figure/chef						= 1,
							/obj/item/toy/figure/chemist					= 1,
							/obj/item/toy/figure/clown						= 1,
							/obj/item/toy/figure/ian						= 1,
							/obj/item/toy/figure/detective					= 1,
							/obj/item/toy/figure/dsquad						= 1,
							/obj/item/toy/figure/engineer					= 1,
							/obj/item/toy/figure/geneticist					= 1,
							/obj/item/toy/figure/hop						= 1,
							/obj/item/toy/figure/hos						= 1,
							/obj/item/toy/figure/qm							= 1,
							/obj/item/toy/figure/janitor					= 1,
							/obj/item/toy/figure/lawyer						= 1,
							/obj/item/toy/figure/librarian					= 1,
							/obj/item/toy/figure/md							= 1,
							/obj/item/toy/figure/mime						= 1,
							/obj/item/toy/figure/ninja						= 1,
							/obj/item/toy/figure/wizard						= 1,
							/obj/item/toy/figure/rd							= 1,
							/obj/item/toy/figure/roboticist					= 1,
							/obj/item/toy/figure/scientist					= 1,
							/obj/item/toy/figure/syndie						= 1,
							/obj/item/toy/figure/secofficer					= 1,
							/obj/item/toy/figure/virologist					= 1,
							/obj/item/toy/figure/warden						= 1,
							/obj/item/toy/prize/poly/polyclassic			= 1,
							/obj/item/toy/prize/poly/polypink				= 1,
							/obj/item/toy/prize/poly/polydark				= 1,
							/obj/item/toy/prize/poly/polywhite				= 1,
							/obj/item/toy/prize/poly/polyalien				= 1,
							/obj/item/toy/prize/poly/polyjungle				= 1,
							/obj/item/toy/prize/poly/polyfury				= 1,
							/obj/item/toy/prize/poly/polysky				= 1,
							/obj/item/toy/prize/poly/polysec				= 1,
							/obj/item/toy/prize/poly/polycompanion			= 1,
							/obj/item/toy/prize/poly/polygold				= 1,
							/obj/item/toy/prize/poly/polyspecial			= 1,
							/obj/item/toy/eight_ball						= 3,
							/obj/item/toy/eight_ball/conch					= 2,
							/obj/item/toy/carpplushie						= 1,
							/obj/item/toy/carpplushie						= 1,
							/obj/item/toy/carpplushie						= 1,
							/obj/item/toy/carpplushie						= 1,
							/obj/item/toy/carpplushie						= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1,
							/obj/random/plushie								= 1
							)

	light_color = "#00ff00"

/obj/machinery/computer/arcade
	var/turtle = 0

/obj/machinery/computer/arcade/atom_init()
	. = ..()
	var/name_action
	var/name_part1
	var/name_part2

	name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ", "Pwn ", "Own ")

	name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Cuban ", "the Evil ", "the Dread King ", "the Space ", "Lord ", "the Great ", "Duke ", "General ")
	name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon", "Uhangoid", "Vhakoid", "Peteoid", "slime", "Griefer", "ERPer", "Lizard Man", "Unicorn")

	enemy_name = replacetext((name_part1 + name_part2), "the ", "")
	name = (name_action + name_part1 + name_part2)

/obj/machinery/computer/arcade/ui_interact(mob/user)
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a>"

	dat += "<center><h4>[src.enemy_name]</h4></center>"

	dat += "<br><center><h3>[src.temp]</h3></center>"
	dat += "<br><center>Health: [src.player_hp] | Magic: [src.player_mp] | Enemy Health: [src.enemy_hp]</center>"

	dat += "<center><b>"
	if (src.gameover)
		dat += "<a href='byond://?src=\ref[src];newgame=1'>New Game</a>"
	else
		dat += "<a href='byond://?src=\ref[src];attack=1'>Attack</a> | "
		dat += "<a href='byond://?src=\ref[src];heal=1'>Heal</a> | "
		dat += "<a href='byond://?src=\ref[src];charge=1'>Recharge Power</a>"

	dat += "</b></center>"

	user << browse(dat, "window=arcade")
	onclose(user, "arcade")

/obj/machinery/computer/arcade/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if (!src.blocked && !src.gameover)
		if (href_list["attack"])
			src.blocked = 1
			var/attackamt = rand(2,6)
			playsound(src, pick('sound/machines/arcade/attack1.ogg', 'sound/machines/arcade/attack2.ogg'), VOL_EFFECTS_MASTER, 80, null, -6)
			src.temp = "You attack for [attackamt] damage!"
			src.updateUsrDialog()
			if(turtle > 0)
				turtle--

			sleep(10)
			src.enemy_hp -= attackamt
			src.arcade_action()

		else if (href_list["heal"])
			src.blocked = 1
			var/pointamt = rand(1,3)
			var/healamt = rand(6,8)
			playsound(src, pick('sound/machines/arcade/heal1.ogg', 'sound/machines/arcade/heal2.ogg'), VOL_EFFECTS_MASTER, 80 , null, -6)
			src.temp = "You use [pointamt] magic to heal for [healamt] damage!"
			src.updateUsrDialog()
			turtle++

			sleep(10)
			src.player_mp -= pointamt
			src.player_hp += healamt
			src.blocked = 1
			src.updateUsrDialog()
			src.arcade_action()

		else if (href_list["charge"])
			src.blocked = 1
			var/chargeamt = rand(4,7)
			playsound(src, pick('sound/machines/arcade/+mana1.ogg', 'sound/machines/arcade/+mana2.ogg'), VOL_EFFECTS_MASTER, 80, null, -6)
			src.temp = "You regain [chargeamt] points"
			src.player_mp += chargeamt
			if(turtle > 0)
				turtle--

			src.updateUsrDialog()
			sleep(10)
			src.arcade_action()

	if (href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=arcade")

	else if (href_list["newgame"]) //Reset everything
		temp = "New Round"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0
		turtle = 0

		if(emagged)
			src.New()
			emagged = 0

	src.updateUsrDialog()

/obj/machinery/computer/arcade/proc/arcade_action()
	if ((src.enemy_mp <= 0) || (src.enemy_hp <= 0))
		if(!gameover)
			src.gameover = 1
			playsound(src, 'sound/machines/arcade/e_death.ogg', VOL_EFFECTS_MASTER, 80, null, -6)
			src.temp = "[src.enemy_name] has fallen! Rejoice!"

			if(emagged)
				feedback_inc("arcade_win_emagged")
				new /obj/effect/spawner/newbomb/timer/syndicate(src.loc)
				new /obj/item/clothing/head/collectable/petehat(src.loc)
				message_admins("[key_name_admin(usr)] has outbombed Cuban Pete and been awarded a bomb. [ADMIN_JMP(usr)]")
				log_game("[key_name(usr)] has outbombed Cuban Pete and been awarded a bomb.")
				src.New()
				emagged = 0
			else if(!contents.len)
				feedback_inc("arcade_win_normal")
				var/prizeselect = pickweight(prizes)
				new prizeselect(src.loc)

				if(istype(prizeselect, /obj/item/toy/gun)) //Ammo comes with the gun
					new /obj/item/toy/ammo/gun(src.loc)

				else if(istype(prizeselect, /obj/item/clothing/suit/syndicatefake)) //Helmet is part of the suit
					new	/obj/item/clothing/head/syndicatefake(src.loc)

			else
				feedback_inc("arcade_win_normal")
				var/atom/movable/prize = pick(contents)
				prize.loc = src.loc

	else if (emagged && (turtle >= 4))
		var/boomamt = rand(5,10)
		playsound(src, pick('sound/machines/arcade/gethit1.ogg', 'sound/machines/arcade/gethit2.ogg'), VOL_EFFECTS_MASTER, 80, null, -6)
		src.temp = "[src.enemy_name] throws a bomb, exploding you for [boomamt] damage!"
		src.player_hp -= boomamt

	else if ((src.enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		playsound(src, pick('sound/machines/arcade/-mana1.ogg', 'sound/machines/arcade/-mana2.ogg'), VOL_EFFECTS_MASTER, 80, null, -6)
		src.temp = "[src.enemy_name] steals [stealamt] of your power!"
		src.player_mp -= stealamt
		src.updateUsrDialog()

		if (src.player_mp <= 0)
			src.gameover = 1
			sleep(10)
			playsound(src, 'sound/machines/arcade/p_death.ogg', VOL_EFFECTS_MASTER, 80, null, -6)
			src.temp = "You have been drained! GAME OVER"
			if(emagged)
				feedback_inc("arcade_loss_mana_emagged")
				usr.gib()
			else
				feedback_inc("arcade_loss_mana_normal")

	else if ((src.enemy_hp <= 10) && (src.enemy_mp > 4))
		playsound(src, pick('sound/machines/arcade/heal1.ogg', 'sound/machines/arcade/heal2.ogg'), VOL_EFFECTS_MASTER, 80, null, -6)
		src.temp = "[src.enemy_name] heals for 4 health!"
		src.enemy_hp += 4
		src.enemy_mp -= 4

	else
		var/attackamt = rand(3,6)
		playsound(src, pick('sound/machines/arcade/gethit1.ogg', 'sound/machines/arcade/gethit2.ogg'), VOL_EFFECTS_MASTER, 80, null, -6)
		src.temp = "[src.enemy_name] attacks for [attackamt] damage!"
		src.player_hp -= attackamt

	if ((src.player_mp <= 0) || (src.player_hp <= 0))
		src.gameover = 1
		playsound(src, 'sound/machines/arcade/p_death.ogg', VOL_EFFECTS_MASTER, 80, null, -6)
		src.temp = "You have been crushed! GAME OVER"
		if(emagged)
			feedback_inc("arcade_loss_hp_emagged")
			usr.gib()
		else
			feedback_inc("arcade_loss_hp_normal")

	src.blocked = 0
	return

/obj/machinery/computer/arcade/emag_act(mob/user)
	if(emagged)
		return FALSE
	temp = "If you die in the game, you die for real!"
	player_hp = 30
	player_mp = 10
	enemy_hp = 45
	enemy_mp = 20
	gameover = 0
	blocked = 0
	emagged = 1
	enemy_name = "Cuban Pete"
	name = "Outbomb Cuban Pete"
	src.updateUsrDialog()

/obj/machinery/computer/arcade/emp_act(severity)
	if(stat & (NOPOWER|BROKEN))
		..(severity)
		return
	var/empprize = null
	var/num_of_prizes = 0
	switch(severity)
		if(1)
			num_of_prizes = rand(1,4)
		if(2)
			num_of_prizes = rand(0,2)
	for(num_of_prizes; num_of_prizes > 0; num_of_prizes--)
		empprize = pickweight(prizes)
		new empprize(src.loc)

	..(severity)
