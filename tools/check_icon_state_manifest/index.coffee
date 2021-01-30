# index.coffee
# Verify the project contains icon_state listed in a manifest file

extract = require "png-chunks-extract"
fs = require "fs"
{inflateSync} = require "zlib"
path = require "path"

DEQUOTE_RE = /^"(.*)"$/
EQUAL_RE = /^(\t*)([^=]+)=(.*)$/

checkManifest = ->
    # figure out where we're starting from
    projectRoot = process.argv[2]
    process.stdout.write "Checking icon manifest against #{projectRoot}\n"

    # read the icon manifest
    manifest = fs.readFileSync "icon_state.manifest", {encoding: "utf8"}

    # filter the lines of the icon manifest
    lines = manifest.split "\n"
    lines = (line.trim() for line in lines)
    lines = (line for line in lines when line.length > 0)
    lines = lines.filter (x) -> not x.startsWith "#"
    process.stdout.write "There are #{lines.length} manifest entries\n"

    # parse the lines of the icon manifest
    maniStates = []
    for line in lines
        cols = line.split ":"
        cols = (x.trim() for x in cols)
        maniStates.push
            path: cols[0]
            iconState: cols[1]
            hash: cols[2]

    # process each of the manifest entries
    icons = {}
    for maniState in maniStates
        iconPath = path.join projectRoot, maniState.path
        exists = fs.existsSync iconPath
        if exists
            if not icons[maniState.path]?
                icons[maniState.path] = loadIconStates iconPath
        else
            process.stdout.write "ERROR: Missing icon file: #{maniState.path}\n"
            process.exitCode = 1

    # bail if we identified any errors
    return if process.exitCode is 1

    # check to see that the icon states exist
    for maniState in maniStates
        if maniState.iconState not in icons[maniState.path]
            process.stdout.write "ERROR: Missing icon_state: '#{maniState.iconState}' in #{maniState.path}\n"
            process.exitCode = 1

    # bail if we identified any errors
    return if process.exitCode is 1

    # otherwise send a nice message
    process.stdout.write "All manifest entries are verified as present\n"
    process.exitCode = 0

deQuote = (text) ->
    # remove double-quotes if present, otherwise no-op
    quotedText = DEQUOTE_RE.exec text
    return quotedText[1] if quotedText?
    return text

extractDescription = (buffer) ->
    # extract the compressed text (zTXt) chunk of a PNG file
    chunks = extract buffer
    for chunk in chunks
        if chunk.name is "zTXt"
            pngZippedText = chunk.data
            metaText = inflateSync getDeflate pngZippedText
            return metaText.toString "utf8"
    return ""

findKeywordEndIndex = (data) ->
    # basically strlen(), but don't tell anybody
    index = 0
    while data[index] isnt 0
        index++
    return index

getDeflate = (data) ->
    # slice off the uncompressed header of the chunk data
    index = findKeywordEndIndex data
    return data.slice index+2

loadIconStates = (iconPath) ->
    # extract and parse the metadata from the icon file
    buffer = fs.readFileSync iconPath
    metadata = extractDescription buffer
    lines = metadata.split "\n"
    lines = (x for x in lines when x.startsWith "state")
    # return an array of icon_state names
    states = (parseEqualLine x for x in lines)
    stateNames = (x.rhs for x in states)
    return stateNames

parseEqualLine = (line) ->
    # parse a metadata line like:
    #     state = "soapark"
    #
    # into an object like:
    #     {
    #         level: 0,
    #         lhs: "state",
    #         rhs: "soapark"
    #     }
    #
    # note the input data contains double-quotes, but the output data does NOT
    parsed = EQUAL_RE.exec line
    return null if not parsed?
    return
        level: parsed[1].length
        lhs: parsed[2].trim()
        rhs: deQuote parsed[3].trim()

do ->
    # where the rubber meets the road; check the codebase icons against
    # the manifest file for icon states
    checkManifest()
