#define SECOND *10
#define SECONDS *10

#define MINUTE *600
#define MINUTES *600

#define HOUR *36000
#define HOURS *36000

//Returns the world time in english
/proc/worldtime2text(time = world.time)
	return "[round(time / 36000)+12]:[(time / 600 % 60) < 10 ? add_zero(time / 600 % 60, 1) : time / 600 % 60]"

/proc/time_stamp(format = "hh:mm:ss", wtime = world.timeofday)
	return time2text(wtime, format)

/proc/shuttleeta2text()
	var/timeleft = SSshuttle.timeleft()
	if(timeleft < 0)
		timeleft = 0
	return "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"

/proc/shuttleminutes2text()
	var/m = round(SSshuttle.timeleft()/60)
	return pluralize_russian(m, "[m] минута", "[m] минуты", "[m] минут")

var/global/next_duration_update = 0
var/global/round_duration_cash = 0

/proc/roundtimestamp(time = world.time)
	var/mills = global.round_start_time ? time - global.round_start_time : 0
	var/mins = round((mills % 36000) / 600)
	var/hours = round(mills / 36000)

	mins = mins < 10 ? add_zero(mins, 1) : mins
	hours = hours < 10 ? add_zero(hours, 1) : hours

	return "[hours]:[mins]"

/proc/roundduration2text()
	if(!global.round_start_time)
		return "00:00"
	if(world.time < next_duration_update)
		return global.round_duration_cash

	global.next_duration_update = world.time + 1 MINUTES
	global.round_duration_cash = global.roundtimestamp(world.time)
	return global.round_duration_cash

/* Returns TRUE if it is the selected month and day */
/proc/isDay(month, day)
	if(isnum(month) && isnum(day))
		var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
		var/DD = text2num(time2text(world.timeofday, "DD")) // get the current day
		if(month == MM && day == DD)
			return TRUE

		// Uncomment this out when debugging!
		//else
			//return TRUE

var/global/midnight_rollovers = 0
var/global/rollovercheck_last_timeofday = 0
/proc/update_midnight_rollover()
	if (world.timeofday < global.rollovercheck_last_timeofday) //TIME IS GOING BACKWARDS!
		global.midnight_rollovers++
	global.rollovercheck_last_timeofday = world.timeofday
	return midnight_rollovers

//Takes a value of time in deciseconds.
//Returns a text value of that number in hours, minutes, or seconds.
/proc/DisplayTimeText(time_value, round_seconds_to = 0.1)
	var/second = FLOOR(time_value * 0.1, round_seconds_to)
	if(!second)
		return "right now"
	if(second < 60)
		return "[second] second[(second != 1)? "s":""]"
	var/minute = FLOOR(second / 60, 1)
	second = FLOOR(MODULUS(second, 60), round_seconds_to)
	var/secondT
	if(second)
		secondT = " and [second] second[(second != 1)? "s":""]"
	if(minute < 60)
		return "[minute] minute[(minute != 1)? "s":""][secondT]"
	var/hour = FLOOR(minute / 60, 1)
	minute = MODULUS(minute, 60)
	var/minuteT
	if(minute)
		minuteT = " and [minute] minute[(minute != 1)? "s":""]"
	if(hour < 24)
		return "[hour] hour[(hour != 1)? "s":""][minuteT][secondT]"
	var/day = FLOOR(hour / 24, 1)
	hour = MODULUS(hour, 24)
	var/hourT
	if(hour)
		hourT = " and [hour] hour[(hour != 1)? "s":""]"
	return "[day] day[(day != 1)? "s":""][hourT][minuteT][secondT]"

/proc/is_leap_year(year)
	return (year && isnum(year) && (((year % 400) == 0) || ((year % 100 != 0) && (year % 4 == 0))))
