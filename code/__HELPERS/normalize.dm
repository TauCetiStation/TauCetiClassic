// For proc which normalize something

/proc/normalize_color(inphex) //normalize hex color and convert hex2num and num2hex

	var/rhex[2] //HEX r bloc
	var/ghex[2] //HEX g bloc
	var/bhex[2] //HEX b bloc
	var/r[2] //num r bloc
	var/g[2] //num g bloc
	var/b[2] //num b bloc
	var/rgb[3] //Complete RGB num
	var/final_hex //Returned normalize HEX

	if(!inphex)
		return

	//Copytext inphex (input hex color)
	rhex[1] = copytext(inphex, 2,3)
	rhex[2] = copytext(inphex, 3,4)
	ghex[1] = copytext(inphex, 4,5)
	ghex[2] = copytext(inphex, 5,6)
	bhex[1] = copytext(inphex, 6,7)
	bhex[2] = copytext(inphex, 7,8)

	//Converted hex2num

	for(var/i = 1, i < 3, i++)
		switch(rhex[i])
			if("A" , "a")
				r[i] = 10
			if("B" , "b")
				r[i] = 11
			if("C" , "c")
				r[i] = 12
			if("D" , "d")
				r[i] = 13
			if("E" , "e")
				r[i] = 14
			if("F" , "f")
				r[i] = 15
		if(!r[i])
			r[i] = text2num(rhex[i])
		switch(ghex[i])
			if("A" , "a")
				g[i] = 10
			if("B" , "b")
				g[i] = 11
			if("C" , "c")
				g[i] = 12
			if("D" , "d")
				g[i] = 13
			if("E" , "e")
				g[i] = 14
			if("F" , "f")
				g[i] = 15
		if(!g[i])
			g[i] = text2num(ghex[i])
		switch(bhex[i])
			if("A" , "a")
				b[i] = 10
			if("B" , "b")
				b[i] = 11
			if("C" , "c")
				b[i] = 12
			if("D" , "d")
				b[i] = 13
			if("E" , "e")
				b[i] = 14
			if("F" , "f")
				b[i] = 15
		if(!b[i])
			b[i] = text2num(bhex[i])

	rgb[1] = r[1] * 16 + r[2]
	rgb[2] = g[1] * 16 + g[2]
	rgb[3] = b[1] * 16 + b[2]

	//Normalize color when RGB color shade is not less than the sum 180
	if((rgb[1] + rgb[2] +rgb[3]) < 180)
		if(rgb[1] < 60)
			rgb[1] += 60
		if(rgb[2] < 60)
			rgb[2] += 60
		if(rgb[3] < 60)
			rgb[3] += 60

	var/rbuff //1st red normalize num block
	var/gbuff //1st green normalize num block
	var/bbuff //1st blue normalize num block
	var/rhexn[2] //Red hex normalize block
	var/ghexn[2] //Green hex normalize block
	var/bhexn[2] // Blue hex nornalize block

	//Converted num2hex

	while(rgb[1] >= 16)
		rgb[1] -= 16
		rbuff++
	while(rgb[2] >= 16)
		rgb[2] -= 16
		gbuff++
	while(rgb[3] >= 16)
		rgb[3] -= 16
		bbuff++

	switch(rbuff)
		if(10)
			rhexn[1] = "a"
		if(11)
			rhexn[1] = "b"
		if(12)
			rhexn[1] = "c"
		if(13)
			rhexn[1] = "d"
		if(14)
			rhexn[1] = "e"
		if(15)
			rhexn[1] = "f"
	if(!rhexn[1])
		rhexn[1] = num2text(rbuff)
	switch(gbuff)
		if(10)
			ghexn[1] = "a"
		if(11)
			ghexn[1] = "b"
		if(12)
			ghexn[1] = "c"
		if(13)
			ghexn[1] = "d"
		if(14)
			ghexn[1] = "e"
		if(15)
			ghexn[1] = "f"
	if(!ghexn[1])
		ghexn[1] = num2text(gbuff)
	switch(bbuff)
		if(10)
			bhexn[1] = "a"
		if(11)
			bhexn[1] = "b"
		if(12)
			bhexn[1] = "c"
		if(13)
			bhexn[1] = "d"
		if(14)
			bhexn[1] = "e"
		if(15)
			bhexn[1] = "f"
	if(!bhexn[1])
		bhexn[1] = num2text(bbuff)
	switch(rgb[1])
		if(10)
			rhexn[2] = "a"
		if(11)
			rhexn[2] = "b"
		if(12)
			rhexn[2] = "c"
		if(13)
			rhexn[2] = "d"
		if(14)
			rhexn[2] = "e"
		if(15)
			rhexn[2] = "f"
	if(!rhexn[2])
		rhexn[2] = num2text(rgb[1])
	switch(rgb[2])
		if(10)
			ghexn[2] = "a"
		if(11)
			ghexn[2] = "b"
		if(12)
			ghexn[2] = "c"
		if(13)
			ghexn[2] = "d"
		if(14)
			ghexn[2] = "e"
		if(15)
			ghexn[2] = "f"
	if(!ghexn[2])
		ghexn[2] = num2text(rgb[2])
	switch(rgb[3])
		if(10)
			bhexn[2] = "a"
		if(11)
			bhexn[2] = "b"
		if(12)
			bhexn[2] = "c"
		if(13)
			bhexn[2] = "d"
		if(14)
			bhexn[2] = "e"
		if(15)
			bhexn[2] = "f"
	if(!bhexn[2])
		bhexn[2] = num2text(rgb[3])

	//Set complete normalize hex color
	final_hex = "#" + rhexn[1] + rhexn[2] + ghexn[1] + ghexn[2] + bhexn[1] + bhexn[2]

	return final_hex