/proc/get_smooth_noise(seed, width, height, octave)
	var/list/smooth = new/list(width, height)

	var/samplePeriod = 1 << octave
	var/sampleFreq = (1.0 / samplePeriod)

	for (var/k in 1 to width)
		var/_i0 = FLOOR(k / samplePeriod, 1) * samplePeriod
		var/_i1 = (_i0 + samplePeriod) % width
		var/h_blend = (k - _i0) * sampleFreq

		for (var/l in 1 to  height)
			var/_j0 = FLOOR(l / samplePeriod, 1) * samplePeriod
			var/_j1 = (_j0 + samplePeriod) % height
			var/v_blend = (l - _j0) * sampleFreq

			var/top = noise_hash(seed, _i0+1, _j0+1) * (1 - h_blend) + h_blend * noise_hash(seed, _i1+1, _j0+1)
			var/bottom = noise_hash(seed, _i0+1, _j1+1) * (1 - h_blend) + h_blend * noise_hash(seed, _i1+1, _j1+1)

			smooth[k][l] = FLOOR((top * (1 - v_blend) + v_blend * bottom) * 255, 1)

	return smooth

// Noise source: codepen.io/yutt/pen/rICHm
/proc/get_perlin_noise(seed, width, height, persistance = 0.5, amplitude = 1.0, octave = 6)
	var/list/perlin_noise = new/list(width, height)

	var/totalAmp = 0.0
	var/list/smooth

	for(var/o in octave to 1 step -1)
		smooth = get_smooth_noise(seed, width, height, o)
		amplitude = amplitude * persistance
		totalAmp += amplitude
		for(var/i in 1 to width)
			for(var/j in 1 to height)
				if(!isnum(perlin_noise[i][j]))
					perlin_noise[i][j] = 0
				perlin_noise[i][j] += (smooth[i][j] * amplitude)

	for(var/i in 1 to width)
		for(var/j in 1 to height)
			perlin_noise[i][j] = FLOOR(perlin_noise[i][j] / totalAmp, 1)

	return perlin_noise

/proc/get_voronoi_noise(seed, width, height, grid_x, grid_y, max_distance)
	var/list/voronoi_noise = new/list(width, height)
	max_distance = max_distance ** 2

	var/cell_width = FLOOR(width/grid_x, 1)
	var/cell_height = FLOOR(height/grid_y, 1)

	var/list/voronoi_grid = new/list(grid_x, grid_y)
	for(var/i in 1 to grid_x)
		for(var/j in 1 to grid_y)
			voronoi_grid[i][j] = list((i - 1) * cell_width + FLOOR(cell_width * noise_hash(seed, i, j), 1), (j - 1) * cell_height + FLOOR(cell_height * noise_hash(1 - seed, i, j), 1))

	for(var/i in 1 to width)
		for(var/j in 1 to height)
			var/nearest = null
			var/second_to_nearest = null
			var/cell_x = min(FLOOR(i/cell_width, 1) + 1, grid_x)
			var/cell_y = min(FLOOR(j/cell_height, 1) + 1, grid_y)
			for(var/c_i in max(cell_x - 1, 1) to min(cell_x + 1, grid_x))
				for(var/c_j in max(cell_y - 1, 1) to min(cell_y + 1, grid_y))
					var/list/cell = voronoi_grid[c_i][c_j]
					var/distance_squared = ((cell[1] - i) ** 2) + ((cell[2] - j) ** 2)
					if(isnull(nearest) || (nearest > distance_squared))
						second_to_nearest = nearest
						nearest = distance_squared
					else if(isnull(second_to_nearest) || (second_to_nearest > distance_squared))
						second_to_nearest = distance_squared

			voronoi_noise[i][j] = FLOOR(min(255, 255 * nearest / min(max_distance, (second_to_nearest + nearest) / 2)), 1)

	return voronoi_noise

/datum/map_generator_module/flora
	spawnableTurfs = list()
	spawnableAtoms = list()

	var/turf_type
	var/persistance = 0.5

	var/list/perlin_map

/datum/map_generator_module/flora/New()
	var/width = world.maxx
	var/height = world.maxy
	perlin_map = get_perlin_noise(rand(), width, height, persistance)

/datum/map_generator_module/flora/checkPlaceAtom(turf/T)
	if(!istype(T, turf_type))
		return FALSE
	if(T.density)
		return FALSE
	if(istype(T.loc, /area/shuttle)) // prevent placing flora under shuttles
		return FALSE
	for(var/atom/A in T)
		if(A.density)
			return FALSE
	return TRUE

/datum/map_generator_module/flora/proc/place_flora(turf/T, noise)
	return FALSE

/datum/map_generator_module/flora/place(turf/T)
	if(!checkPlaceAtom(T))
		return FALSE

	return place_flora(T, perlin_map[T.x][T.y])
