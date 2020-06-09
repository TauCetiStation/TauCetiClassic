/**
 * A Star pathfinding algorithm
 *
 * Returns a list of tiles forming a path from A to B, taking dense objects as well as walls, and the orientation of
 * windows along the route into account.
 *
 * Use:
 * > your_list = AStar(start location, end location, moving atom, distance proc, max nodes, maximum node depth, minimum distance to target, adjacent proc, atom id, turfs to exclude, check only simulated)
 *
 * Optional extras to add on (in order):
 * - Distance proc : the distance used in every A* calculation (length of path and heuristic)
 * - MaxNodes: The maximum number of nodes the returned path can be (0 = infinite)
 * - Maxnodedepth: The maximum number of nodes to search (default: 30, 0 = infinite)
 * - Mintargetdist: Minimum distance to the target before path returns, could be used to get
 *   near a target, but not right to it - for an AI mob with a gun, for example.
 * - Adjacent proc : returns the turfs to consider around the actually processed node
 * - Simulated only : whether to consider unsimulated turfs or not (used by some Adjacent proc)
 *
 * Also added 'exclude' turf to avoid travelling over; defaults to null
 *
 * Actual Adjacent procs :
 * - /turf/proc/reachableAdjacentTurfs : returns reachable turfs in cardinal directions (uses simulated_only)
 */

/////////////////
//PathNode object
/////////////////

/PathNode
	var/turf/source       // Turf associated with the PathNode
	var/PathNode/prevNode // Link to the parent PathNode

	var/f    // A* Node weight (f = g + h)
	var/g    // A* movement cost variable
	var/h    // A* heuristic variable
	var/nt   // Count the number of Nodes traversed

/PathNode/New(source, prevNode, g, h, nt)
	src.source = source
	src.prevNode = prevNode

	src.f = g + h
	src.g = g
	src.h = h
	src.nt = nt

/PathNode/proc/calc_f()
	f = g + h

//////////
//A* procs
//////////

/**
 * The weighting function, used in the A* algorithm
 */
/proc/PathWeightCompare(PathNode/a, PathNode/b)
	return a.f - b.f

/**
 * Reversed so that the Heap is a MinHeap rather than a MaxHeap
 */
/proc/HeapPathWeightCompare(PathNode/a, PathNode/b)
	return b.f - a.f

/**
 * Wrapper that returns an empty list if A* failed to find a path
 */
/proc/get_path_to(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id=null, turf/exclude=null, simulated_only = 1)
	var/list/path = AStar(caller, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent,id, exclude, simulated_only)
	if(!path)
		path = list()
	return path

/**
 * The actual A* algorithm
 */
/proc/AStar(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id=null, turf/exclude=null, simulated_only = 1)
	var/list/pnodelist = list()

	// Sanitation
	var/start = get_turf(caller)
	if(!start)
		CRASH("Unable to get turf from caller")

	if(maxnodes)
		// If start turf is farther than maxnodes from end turf, no need to do anything
		if(call(start, dist)(end) > maxnodes)
			return

		maxnodedepth = maxnodes  // No need to consider path longer than maxnodes

	var/Heap/open = new /Heap(/proc/HeapPathWeightCompare)  // The open list
	var/list/closed = list()                                // The closed list

	var/list/path = null  // The returned path, if any
	var/PathNode/cur      // Current processed turf

	// Initialization
	open.Insert(new /PathNode(start,null,0,call(start,dist)(end),0))

	// Then run the main loop
	while(!open.IsEmpty() && !path)
		cur = open.Pop()      // Get the lower f turf in the open list
		closed += cur.source  // And tell we've processed it

		// If we only want to get near the target, check if we're close enough
		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.source,dist)(end) <= mintargetdist

		// If too many steps, abandon that path
		if(maxnodedepth && (cur.nt > maxnodedepth))
			continue

		// Found the target turf (or close enough), let's create the path to it
		if(cur.source == end || closeenough)
			path = list()
			path += cur.source

			while(cur.prevNode)
				cur = cur.prevNode
				path += cur.source

			break

		// Get adjacents turfs using the adjacent proc, checking for access with id
		var/list/L = call(cur.source,adjacent)(caller,id, simulated_only)
		for(var/turf/T in L)
			if(T == exclude || (T in closed))
				continue

			var/newg = cur.g + call(cur.source,dist)(T)

			var/PathNode/P = pnodelist[T]
			if(!P)
				// Is not already in open list, so add it
				var/PathNode/newnode = new /PathNode(T,cur,newg,call(T,dist)(end),cur.nt+1)
				open.Insert(newnode)
				pnodelist[T] = newnode
			else
				// Is already in open list, check if it's a better way from the current turf
				if(newg < P.g)
					P.prevNode = cur
					P.g = (newg * L.len / 9)
					P.calc_f()
					P.nt = cur.nt + 1
					open.ReSort(P)  // Reorder the changed element in the list
		CHECK_TICK


	// Cleaning after us
	pnodelist = null

	// Reverse the path to get it from start to finish
	if(path)
		for(var/i in 1 to (path.len / 2))
			path.Swap(i, path.len - i + 1)

	return path

/**
 * Returns adjacent turfs in cardinal directions that are reachable
 * `simulated_only` controls whether only simulated turfs are considered or not
 */
/turf/proc/reachableAdjacentTurfs(caller, ID, simulated_only)
	var/list/L = list()

	for(var/dir in cardinal)
		var/turf/T = get_step(src, dir)

		if(simulated_only && !istype(T))
			continue

		if(!T.density && !LinkBlockedWithAccess(T, caller, ID))
			L += T
	return L

/turf/proc/LinkBlockedWithAccess(turf/T, caller, ID)
	var/adir = get_dir(src, T)
	var/rdir = get_dir(T, src)

	for(var/obj/structure/window/W in src)
		if(!W.CanAStarPass(ID, adir))
			return TRUE

	for(var/obj/machinery/door/window/W in src)
		if(!W.CanAStarPass(ID, adir))
			return TRUE

	for(var/obj/O in T)
		if(!O.CanAStarPass(ID, rdir, caller))
			return TRUE

	return FALSE