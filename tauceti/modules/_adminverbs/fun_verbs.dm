/client/proc/epileptic_anomaly()
	set category = "Fun"
	set name = "Epileptic Anomaly(in dev!)"
	if(!check_rights(R_FUN))	return

	var/area/A
	var/color
	var/list/rand = list("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f")

	A = get_area(usr.loc)
	if(!A)
		return

	if(A.type == /area)
		usr << "<span class='warning'>You can't do it with space!</span>"
		return

	for(var/atom/O in A)
		color = "#" + pick(rand) + pick(rand) + pick(rand) + pick(rand) + pick(rand) + pick(rand)
		O.color = color

//	message_admins("[key_name_admin(src)] called color anomaly in [A]", 1)
	log_admin("[key_name(src)] called color anomaly in [A]")

/client/proc/epileptic_anomaly_cancel()
	set category = "Fun"
	set name = "Cancel Epileptic Anomaly"
	if(!check_rights(R_FUN))	return

	var/area/A
	var/color = null

	A = get_area(usr.loc)
	if(!A)
		return

	if(A.type == /area)
		usr << "<span class='warning'>You can't do it with space!</span>"
		return

	for(var/atom/O in A)
		O.color = color

//	message_admins("[key_name_admin(src)] trying cancel color anomaly in [A]", 1)
	log_admin("[key_name(src)] trying cancel color anomaly in [A]")

/client/proc/roll_dices()
	set category = "Fun"
	set name = "Roll Dice"
	if(!check_rights(R_FUN))	return

	var/sum = input("How many times we throw?") as num
	var/side = input("Select the number of sides.") as num
	if(!side)
		side = 6
	if(!sum)
		sum = 2

	var/dice = num2text(sum) + "d" + num2text(side)

	if(alert("Do you want to inform the world about your game?",,"Yes", "No") == "Yes")
		world << "<h2 style='text-color:#A50400'>The dice have been rolled by Gods!</h2>"

	var/result = roll(dice)

	if(alert("Do you want to inform the world about the result?",,"Yes", "No") == "Yes")
		world << "<h2 style='text-color:#A50400\'>Gods rolled [dice], result is [result]</h2>"

	message_admins("[key_name_admin(src)] rolled dice [dice], result is [result]", 1)