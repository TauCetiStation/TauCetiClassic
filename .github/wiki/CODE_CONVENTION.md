## Введение
Code Convention - свод несложных правил по оформлению кода. Его наличие подразумевает, что все кто вносят свои изменения, с ним соглашаются и руководствуются им в полной мере. Обязательно прочтите всю статью, если зашли сюда в первый раз. Это очень важно.

В случае если что-то не было здесь оговорено, вы можете уточнить этот момент в конфе. Хотя скорее всего это значит, что в том, что вас интересует вы вольны думать самостоятельно.


## Пробелы и отступы
### Блоки кода
В качестве отступов для компилируемых блоков кода используются только табы. Если код относится к комментарию (то есть для примера), то выравнивать рекомендуется пробелами.

### Процедуры и функции
Между вызовом процедуры/функции и скобками не должно быть пробела.
```dm
//Плохо:
/proc/foo()
	return function (1)

//Хорошо:
/proc/foo()
	return function(1)
```

### Операторы управления (if, while, for и т.д.)
Не должны писаться одной строкой. Иногда, если так действительно будет лучше, допускается однострочные `switch` и `else if` конструкции.
```dm
//Плохо:
if(something) return TRUE

for(var/i in something) i.foo()

//Хорошо:
if(something)
	return TRUE

for(var/i in something)
	i.foo()

//Допустимо:
switch(x)
	if(case_1) foo()
	if(case_2) return FALSE
```

### Оператор членства (in)
В связи с некоторой непредсказуемостью результатов сложных выражений включающих in, любую проверку на наличие в списке стоит брать в скобки.

```dm
//Плохо:
if(foo && bar in list)

if(bar in arr and foo)

//Хорошо:
if(foo && (bar in list))

if((bar in arr) and foo)
```


### Все остальные операторы (+, -, =, &&, || и т.д.)(и in)
Один пробел перед оператором и один пробел после. Исключение - побитовые. Пробелы при их использовании вставляйте на своё усмотрение.
```dm
//Плохо:
var/a=1
var/b   = 2
var/c =a+b

//Хорошо:
var/a = 1
var/b = 2
var/c = a + b
```

### Скобки и запятые
Следуйте единому формату. Так или иначе пробел после запятой - обязателен.
```dm
//Плохо:
list( 1,2, 3, 4 ,5)

//Хорошо:
list(1, 2, 3, 4, 5)

//Допустимо:
list( 1 , 2 , 3 , 4 , 5 )
```

### Комментарии
Форматирование только через пробелы. Обратите внимание на выравнивание.
```dm
//Плохо:
#define A "something"		//	Это что-то.
#define B "anything"	//Это что угодно.

//Хорошо:
#define A "something"  // Это что-то.
#define B "anything"   // Это что угодно.
```

### Выравнивание новых строк
Например, при объявлении элементов списка - преимущественно пробелами.
```dm
//Плохо:
list(1, 2, 3,
	4, 5, 6)

//Хорошо:
list(1, 2, 3,
     4, 5, 6)

//Допустимо:
list(
	1, 2, 3,
	4, 5, 6
)
```

## Описание путей
### Абсолютные
Все пути в обязательном порядке должны быть абсолютными.
```dm
//Плохо:
obj
	var
		varname1 = 0
		varname2
	proc
		proc_name()
			code
	item
		weapon
			name = "Weapon"
			proc
				proc_name2()
					..()
					code

//Хорошо:
/obj
	var/varname1 = 0
	var/varname2

/obj/proc/proc_name()
	code

/obj/item/weapon
	name = "Weapon"

/obj/item/weapon/proc/proc_name2()
	..()
	code
```

### Должны начинаться с /
```dm
//Плохо:
mob/living

//Хорошо:
/mob/living
```

### Не описываются через текстовую строку
```dm
//Плохо:
var/path = "/obj/item/something"

//Хорошо:
var/path = /obj/item/something
```
Записывать путь объекта строкой небезопасно, так как в случае если каким-то образом тот изменится или вообще удалится из билда, компилятор не сообщит о попытке использования несуществующего типа.

## Работа с кодом
### Объявление аргументов в процедурах
Не должно быть конструкций типа `var/` и `as ...`
```dm
//Плохо:
/proc/foo(var/atom/A as area|turf|obj|mob)

//Хорошо:
/proc/foo(atom/A)
```

### Оператор `:`
Использование запрещено. Всегда приводите объект к нужному вам типу.
```dm
//Плохо:
/proc/foo(atom/A)
	return A:some_var

//Хорошо:
/proc/foo(atom/A)
	var/obj/O = A
	return O.some_var
```
Данный оператор отрабатывает в рантайме, проходя по всем подтипам объекта в поисках запрашиваемой переменной, соответственно его использование чревато проблемами производительности. 

```proc().var``` и ```list[index].var``` - подобные конструкции равнозначны использованию ```:``` и их также не следует использовать по тем же причинам.
```dm
//Плохо:
var/count = foo().len

//Хорошо:
var/list/L = foo()
var/count = L.len
```

### Магические числа
Если не знаете что это, то прочитайте эту статью [Магическое число (программирование)](https://ru.wikipedia.org/wiki/%D0%9C%D0%B0%D0%B3%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%BE%D0%B5_%D1%87%D0%B8%D1%81%D0%BB%D0%BE_(%D0%BF%D1%80%D0%BE%D0%B3%D1%80%D0%B0%D0%BC%D0%BC%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5)). Соответственно их быть не должно. Используйте дефайны или константные переменные.
```dm
//Плохо:
/proc/foo(variable)
	switch(variable)
		if(1)
			do something
		if(2)
			return

//Хорошо:
#define CASE_1 1
#define CASE_2 2

/proc/foo(variable)
	switch(variable)
		if(CASE_1)
			do something
		if(CASE_2)
			return

#undef CASE_1
#undef CASE_2
```

### Булевский тип
Вместо 1 и 0 используйте `TRUE` и `FALSE` соответственно.

### Использование `src`
Используйте только тогда, когда это необходимо.
```dm
//Плохо:
/mob/some/class/proc/foo()
	src.some_var = some_value
	src.another_var = another_value

//Хорошо:
/mob/some/class/proc/foo()
	some_var = some_value
	another_var = another_value

//Пример необходимого использования:
/mob/some/class/proc/foo(some_var, another_var)
	src.some_var = some_var
	src.another_var =  another_var
```

### Избегайте ненужных проверок типов в циклах
Приведение типов в циклах `for(var/some/foo in bar)` содержит внутреннюю проверку `istype()`, которая отсеивает неподходящие типы, включая `null`. Ключевое слово `as anything` позволяет пропустить ненужные проверки.

Если вы знаете, что лист содержит только нужные типы, то вы бы хотели не только пропустить лишние проверки ради небольшой оптимизации, но и для обнаружения любых `null`-элементов, которые могут быть в этом листе.

Обычно, `null` в листе означает, что как-то неправильно были обработаны ссылки, что затрудняет отладку хард делов.

```dm
var/list/bag_of_atoms = list(new /obj, new /mob, new /atom, new /atom/movable, new /atom/movable)
var/highest_alpha = 0

//Плохо:
for(var/atom/thing in bag_of_atoms)
	if(thing.alpha <= highest_alpha)
		continue
	highest_alpha = thing.alpha


//Хорошо:
for(var/atom/thing as anything in bag_of_atoms)
	if(thing.alpha <= highest_alpha)
		continue
	highest_alpha = thing.alpha


//Допустимо:
for(var/atom in bag_of_atoms)
	var/atom/thing = atom
	if(thing.alpha <= highest_alpha)
		continue
	highest_alpha = thing.alpha
```

### Особенности BYOND
#### Использование `spawn()`
Не используйте. Причины:
- Первая проблема спавна - вопреки всеобщему мнению, считает в тиках процессора, а не игровых тиках.
  - spawn(10), сюрприз-сюрприз вовсе не одна секунда.
- Вторая проблема - ссылки в ассинхронном вызове. Если вы ссылаетесь на объект, который под спавном, и что-то в этом время удалит этот объект(Попытается), то внутри спавна останется ссылка на него.
- Третья проблема - отсутствие возможности профилизировать вызванный под спавном код. В профайлере он будет подписываться как "ASYNC FUNCTION CALL", или что-то подобное, что вообще ничего не говорит о том что это за функция такая.
- Четвёртая проблема - нагрузка на процессор. Спавн очень специфично "асинхронизируется". Он не только вызывает асинхронный вызов, но и решает подсчитать когда он должен закончиться.

В зависимости от того, как используется спавн есть два пути замены:
- Если **spawn(time)**:
  - Как правило, такие спавны заменяются на ```addtimer(CALLBACK(thingtocall, thingtocall_path.proc/proc_name, args), time)```
  - Если с помощью спавна лишь изменяется переменная датума, то лучше использовать ```VARSET_IN(datum, var, var_value, time)```.
- Если **spawn()** или **spawn(0)**:
  - Если спавн содержит единственный прок, то просто оберните его в ```INVOKE_ASYNC(thingtocall, thingtocall_path.proc/proc_name, args)```. Иначе перенесите всё содержимое спавна в новый прок, который уже и добавите в ```INVOKE_ASYNC(thingtocall, thingtocall_path.proc/proc_name, args)```
  - Если всё содержимое прока обернуто в спавн, то в самом проке прописать ```set waitfor = FALSE```

Примеры замен под спойлерами ниже:

<details>
	<summary>Пример замены spawn(time)</summary>

```dm
//Плохо:
/mob/some/class/proc/foo()
	code
	spawn(20)
		switch(variable)
			if(1)
				do_something
			if(2)
				return

	spawn(40)
		other_mob.do_something_crazy(a, b)

	spawn(30)
		name = "Steve"

//Хорошо:
/mob/some/class/proc/foo()
	code
	addtimer(CALLBACK(src, .proc/do_something_wrapper, variable), 20)
	addtimer(CALLBACK(other_mob, /mob.proc/do_something_crazy, a, b), 40)
	VARSET_IN(src, name, "Steve", 30)

/mob/some/class/proc/do_something_wrapper(variable)
	switch(variable)
		if(1)
			do_something
		if(2)
			return
```

</details>


<details>
	<summary>Пример замены spawn(0)</summary>

```dm
//Плохо:
/mob/some/class/proc/foo()
	spawn(0)
		switch(variable)
			if(1)
				do_something
			if(2)
				return

//Хорошо:
/mob/some/class/proc/foo()
	set waitfor = FALSE

	switch(variable)
		if(1)
			do_something
		if(2)
			return

```

```dm
//Плохо:
/mob/some/class/proc/foo()
	code
	spawn(0)
		switch(variable)
			if(1)
				do_something
			if(2)
				return

//Хорошо:
/mob/some/class/proc/foo()
	code
	INVOKE_ASYNC(src, .proc/do_something_wrapper, variable)

/mob/some/class/proc/do_something_wrapper(variable)
	switch(variable)
		if(1)
			do_something
		if(2)
			return

//Хорошо:
/mob/some/class/proc/foo()
	code
	do_something_wrapper(variable)

/mob/some/class/proc/do_something_wrapper(variable)
	set waitfor = FALSE

	switch(variable)
		if(1)
			do_something
		if(2)
			return
```
</details>


#### Работа с циклами (black magic)
Цикл вида `for(var/i = 1; i <= const_val; i++)` должен быть записан в следующей форме `for(var/i in 1 to const_val)`. Причина: второй цикл работает быстрее. Почему? Хороший вопрос, стоит задать его кодерам BYOND. У обоих видов одинаковое поведение, но у второго есть нюансы. `to` тоже самое, что и `<=`, соответственно чтобы было `<` нужно сделать `for(var/i in 1 to const_val - 1)`. Ещё важный момент - `const_val` переменная не должна быть изменена во время цикла. То есть если вы делаете проход по списку, который изменяется внутри цикла, а `const_val` размер списка, то вам нужно использовать классический, первый, вариант.
