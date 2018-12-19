@Grab(group='org.codehaus.groovy.modules.http-builder', module='http-builder', version='0.7.1' )
@Grab(group = 'org.jsoup', module = 'jsoup', version = '1.11.3')
import org.jsoup.Jsoup
import groovyx.net.http.HTTPBuilder
import static groovyx.net.http.ContentType.JSON
import static groovyx.net.http.Method.GET

ORG = 'TauCetiStation'
REPO = 'TauCetiClassic'
CHANGELOG_PATH = '../../html/changelog.html'

println 'Test merge changelog generation started'
println "PRs to process: $args"
args.each {
    print "Creating test merge changelog for PR#${it}..."
    mergeChangelogWithChangelog(it)
    println ' Done!'
}
println 'Finished!'

void mergeChangelogWithChangelog(prNumber) {
    def changelogFile = new File(CHANGELOG_PATH)
    def changelog = readChangelog(prNumber)

    def changelogDoc = Jsoup.parse(changelogFile.text)
    def testChangelogs = changelogDoc.getElementById('tm-changelogs')

    if (testChangelogs.childNodes().isEmpty())
        testChangelogs.append('<div class="row"><div class="col-lg-12"><h3 class="row-header">Test Merge:</h3></div></div>')

    def columnAddTo = testChangelogs.getElementsByClass('col-lg-12').first()
    columnAddTo.append("<div data-pr=\"$prNumber\"><h4 class=\"author\">${changelog.author}, <a href=\"${changelog.prLink}\">PR #$prNumber</a></h4><ul class=\"changelog\"></ul></div>")

    def elementToAddChangelogRows = columnAddTo.getElementsByAttributeValue('data-pr', String.valueOf(prNumber)).first()
    def changelogElement = elementToAddChangelogRows.getElementsByClass('changelog').first()

    changelog.rows.each { row -> 
        changelogElement.append("<li class=\"${row.className}\">${row.text}</li>")
    }

    changelogFile.withWriter('UTF-8') { it.println changelogDoc.toString() }
}

def readChangelog(number) {
    def changelog = null
    def token = new File('token').text.trim()
    new HTTPBuilder("https://api.github.com/repos/$ORG/$REPO/issues/$number").request(GET, JSON) { req ->
        headers.'User-Agent' = 'SS13-TestMerge-Changelog-Script'
        headers.'Authorization' = "token $token"

        response.success = { resp, json ->
            changelog = createChangelog(json.user.login, json.html_url, json.body)
        }
    }
    return changelog
}

def createChangelog(prAuthor, prLink, body) {
    def sanitizedBody = body.replaceAll('(?s)<!--.*?-->', '').replaceAll(/\r\n/, '\n')
    def clMatcher = (sanitizedBody =~ /:cl:((?:.|\n|\r)*+)|\uD83C\uDD91((?:.|\n|\r)*+)/)
    def clText = clMatcher[0][1] ?: clMatcher[0][2]

    def changelog = new Changelog()
    changelog.prLink = prLink
    changelog.author = clText.substring(0, clText.indexOf('\n')).trim()

    if (changelog.author.isEmpty())
        changelog.author = prAuthor

    clText.eachLine { line ->
        def rowMatcher = (line =~ /[-*]\s(\w+)(\[link])?:\s(.*)/)
        if (rowMatcher.find() && rowMatcher.hasGroup()) {
            def changelogRow = new ChangelogRow()
            changelogRow.className = rowMatcher.group(1)

            def changeText = rowMatcher.group(3).trim().capitalize()
            def lastChar = changeText[changeText.length() - 1]
            if (lastChar != '.' && lastChar != '?' && lastChar != '!')
                changeText += '.'

            changelogRow.text = changeText
            changelog.rows << changelogRow
        }
    }

    return changelog
}

class Changelog {
    String prLink
    String author = ''
    List<ChangelogRow> rows = []
}

class ChangelogRow {
    String className
    String text
}