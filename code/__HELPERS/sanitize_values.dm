//general stuff
/proc/sanitize_integer(number, min=0, max=1, default=0)
	if(isnum(number))
		number = round(number)
		if(min <= number && number <= max)
			return number
	return default

/proc/sanitize_text(text, default="")
	if(istext(text))
		return text
	return default

/proc/sanitize_islist(value, default)
	if(islist(value) && length(value))
		return value
	if(default)
		return default

/proc/sanitize_inlist(value, list/List, default)
	if(value in List)	return value
	if(default)			return default
	if(List && List.len)return List[1]



//more specialised stuff
/proc/sanitize_gender(gender, must_be_neuter = FALSE, default = MALE)
	if(must_be_neuter)
		return NEUTER

	if(gender == MALE || gender == FEMALE)
		return gender

	return default

/proc/sanitize_gender_voice(gender, default = MALE)
	switch(gender)
		if(MALE)
			return gender

		if(FEMALE)
			return gender

	return default

/proc/sanitize_hexcolor(color, default="#000000")
	if(!istext(color)) return default
	var/len = length(color)
	if(len != 7 && len !=4) return default
	if(text2ascii(color,1) != 35) return default	//35 is the ascii code for "#"
	. = "#"
	for(var/i=2,i<=len,i++)
		var/ascii = text2ascii(color,i)
		switch(ascii)
			if(48 to 57)	. += ascii2text(ascii)		//numbers 0 to 9
			if(97 to 102)	. += ascii2text(ascii)		//letters a to f
			if(65 to 70)	. += ascii2text(ascii+32)	//letters A to F - translates to lowercase
			else			return default
	return .

var/global/regex/IP_pattern = regex(@"^((25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])(\.(?!$)|$)){4}$")

/proc/sanitize_ip(addr)
	// Return null if IP is invalid, return a valid IP otherwwise.
	if(IP_pattern.Find(addr))
		return addr
	return null

// check long numbers in text type
/proc/sanitize_numbers(num)
	var/static/regex/num_regex = regex(@"^[0-9]*$")
	if(!istext(num) || !num_regex.Find(num))
		return FALSE
	return num
