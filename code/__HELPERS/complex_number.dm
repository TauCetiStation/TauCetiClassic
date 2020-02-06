/*
Complex numbers by Zap-zapper.

Operators +, +=, -, -=, *, *=, /, /= are overloaden
Be vary, if you want to substract or sum complex number and ordinary one, first should come complex one, and then normal one. Vice verca it will not work.
It is advised to use check_complexity() before to_num(), to avoid accidentally equalizing your ordinary varable to /datum/complex

Do not forget to qdel() all complex_numbers after you finished.
*/



/datum/complex_number
	var/real_part
	var/imaginary_part

/datum/complex_number/New(var/real, var/imaginary)
	real_part = real
	imaginary_part = imaginary

//datum/complex_number/proc/complex_operation(complex_number/C)

/datum/complex_number/proc/operator+(datum/complex_number/C)
	if(istype(C))
		return new /datum/complex_number(real_part+C.real_part, imaginary_part+C.imaginary_part)
	if(isnum(C))
		return new /datum/complex_number(real_part+C, imaginary_part)
	return src

/datum/complex_number/proc/operator+=(datum/complex_number/C)
	if(istype(C))
		real_part += C.real_part
		imaginary_part += C.imaginary_part
	else if(isnum(C))
		real_part += C


/datum/complex_number/proc/operator-(datum/complex_number/C)
	if(istype(C))
		return new /datum/complex_number(real_part-C.real_part, imaginary_part-C.imaginary_part)
	if(isnum(C))
		return new /datum/complex_number(real_part-C, imaginary_part)
	return src

/datum/complex_number/proc/operator-=(datum/complex_number/C)
	if(istype(C))
		real_part -= C.real_part
		imaginary_part -= C.imaginary_part
	else if(isnum(C))
		real_part -= C


/datum/complex_number/proc/operator*(datum/complex_number/C)
	if(istype(C))
		var/real_result = real_part * C.real_part - imaginary_part * C.imaginary_part
		var/imaginary_result = real_part * C.imaginary_part + imaginary_part * C.real_part
		return new /datum/complex_number(real_result, imaginary_result)
	if(isnum(C))
		return new /datum/complex_number(real_part*C, imaginary_part*C)
	return src


/datum/complex_number/proc/operator*=(datum/complex_number/C)
	if(istype(C))
		real_part = real_part * C.real_part - imaginary_part * C.imaginary_part
		imaginary_part = real_part * C.imaginary_part + imaginary_part * C.real_part
	else if(isnum(C))
		real_part *= C
		imaginary_part *= C

/datum/complex_number/proc/operator/(datum/complex_number/C)
	if(istype(C))
		if(C.real_part == 0 && C.imaginary_part == 0)
			CRASH("Attempted division by zero!")
		var/real_result = (real_part * C.real_part + imaginary_part * C.imaginary_part)/(C.real_part*C.real_part + C.imaginary_part*C.imaginary_part)
		var/imaginary_result = (imaginary_part * C.real_part - real_part * C.imaginary_part)/(C.real_part*C.real_part + C.imaginary_part*C.imaginary_part)
		return new /datum/complex_number(real_result, imaginary_result)
	if(isnum(C))
		return new /datum/complex_number(real_part/C , imaginary_part/C)
	return src

/datum/complex_number/proc/operator/=(datum/complex_number/C)
	if(istype(C))
		if(C.real_part == 0 && C.imaginary_part == 0)
			CRASH("Attempted division by zero!")
		real_part = (real_part * C.real_part + imaginary_part * C.imaginary_part)/(C.real_part*C.real_part + C.imaginary_part*C.imaginary_part)
		imaginary_part = (imaginary_part * C.real_part - real_part * C.imaginary_part)/(C.real_part*C.real_part + C.imaginary_part*C.imaginary_part)
	if(isnum(C))
		if(C == 0)
			CRASH("Attempted division by zero!")
		real_part /=C
		imaginary_part /=C


/datum/complex_number/proc/operator~()		//Complex conjugate
	return new /datum/complex_number(real_part, -imaginary_part)

/datum/complex_number/proc/is_real()
	if(imaginary_part == 0)
		return TRUE
	else
		return FALSE

/datum/complex_number/proc/to_num()
	if(imaginary_part == 0)
		return real_part
	else
		return src


/datum/complex_number/proc/display()
	if(imaginary_part != 0)
		return ("[real_part] [imaginary_part > 0 ? "+" : "-"] [modulus(imaginary_part)]i")
	else
		return ("[real_part]")




