@Grab(group = 'io.github.spair', module = 'byond-dmm-util', version = '0.2.1')

import io.github.spair.byond.dmm.MapRegion
import io.github.spair.byond.dmm.parser.DmmParser
import io.github.spair.byond.dmm.render.DmmRender
import io.github.spair.byond.dmm.render.FilterMode
import io.github.spair.byond.dme.parser.DmeParser
import io.github.spair.byond.dme.Dme

import groovy.swing.SwingBuilder
import groovy.beans.Bindable

import java.awt.Font
import java.awt.Color
import javax.swing.UIManager
import javax.swing.JFileChooser
import javax.swing.filechooser.FileFilter
import java.awt.BorderLayout as BL
import javax.imageio.ImageIO

import static javax.swing.JFrame.EXIT_ON_CLOSE

STATUS_LABEL = null
STATUS_SPINNER = null

MODEL = new Model()

new SwingBuilder().edt {
    lookAndFeel UIManager.systemLookAndFeelClassName
    BOLD_FONT = new Font(null, Font.BOLD, 12)
	
    STATUS_LABEL = label()
    STATUS_SPINNER = label(font: BOLD_FONT, foreground: Color.RED) {
         doLater {
            Thread.start {
                def spinner = ['/', '-', '\\', '|'] as String[]
                int i = 0
                while (true) {
                    sleep(150)
                    STATUS_SPINNER.text = "${spinner[i++ % spinner.length]}"
                }
            }
        }
    }
    
    def mapChooser = fileChooser(
        dialogTitle: 'Choose a dmm file',
        fileSelectionMode: JFileChooser.FILES_ONLY,
        fileFilter: [
            getDescription: { 'DMM Files (*.dmm or *.dmm.backup)' },
            accept: { file -> file.name.endsWith('.dmm') || file.name.endsWith('.dmm.backup') || file.isDirectory() }
        ] as FileFilter,
        currentDirectory: new File('../../maps')
    )

    frame(title: 'Map Render', size: [340, 375], show: true, locationRelativeTo: null, defaultCloseOperation: EXIT_ON_CLOSE) {
        panel(constraints: BL.NORTH) {
            borderLayout()
            panel(constraints: BL.WEST) {
                label('Status: ', font: BOLD_FONT)
                widget(STATUS_LABEL)
                widget(STATUS_SPINNER)
            }
        }

        panel(constraints: BL.CENTER, border: compoundBorder([emptyBorder(5), titledBorder('Render config:')])) {
            borderLayout()

            panel(constraints: BL.WEST, border: emptyBorder(2)) {
                tableLayout(cellpadding: 5) {
                    tr {
                        td { label('Map:', font: BOLD_FONT) }
                        td { 
                            button(label: 'Select file...', enabled: bind { MODEL.isSelectEnabled }, actionPerformed: {
                                if (mapChooser.showOpenDialog() == JFileChooser.APPROVE_OPTION) {
                                    MODEL.mapFile = mapChooser.selectedFile
                                    it.source.label = mapChooser.selectedFile.name
                                }
                            })
                        }
                    }
                    tr {
                        td { label('Mode:', font: BOLD_FONT) }
                        td { comboBox(items: ['NONE', 'IGNORE', 'INCLUDE', 'EQUAL'], actionPerformed: { MODEL.filterModeName = it.source.selectedItem }) }
                    }
                    tr {
                        td { label('Region:', font: BOLD_FONT) }
                        td { textField(columns: 15, keyReleased: { MODEL.regionText = it.source.text }) }
                    }
                    tr {
                        td(colspan: 2) { label('Types to filter:', font: BOLD_FONT) }
                    }
                    tr {
                        td(colspan: 2) {
                            scrollPane(preferredSize: [275, 100]) {
                                textArea(lineWrap: true, font: new Font(null, Font.PLAIN, 12), keyReleased: { MODEL.typesToFilterText = it.source.text })
                            }
                        }
                    }
                }
            }
        }

        panel(constraints: BL.SOUTH) {
            button(text: 'Render', enabled: bind { MODEL.isRenderEnabled && MODEL.mapFile }, actionPerformed: { renderDmm() })
        }
    }

    doOutside {
        setBusyStatus('Parsing project, please wait')

        MODEL.parsedDme = DmeParser.parse(new File('../../taucetistation.dme'))
        MODEL.isRenderEnabled = true

        setReadyStatus()
    }
}

class Model {

    @Bindable boolean isRenderEnabled = false
    @Bindable boolean isSelectEnabled = true

    @Bindable File mapFile = null

    Dme parsedDme = null

    String filterModeName = 'NONE'
    String regionText = ''
    String typesToFilterText = ''
}

void renderDmm() {
    Thread.start {
        setBusyStatus(/Rendering "${MODEL.mapFile.name}"/)
        MODEL.isRenderEnabled = false
        MODEL.isSelectEnabled = false

        def dmm = DmmParser.parse(MODEL.mapFile, MODEL.parsedDme)

        def filterMode = FilterMode.valueOf(MODEL.filterModeName)
        def typesToFilter = !MODEL.typesToFilterText.empty ? MODEL.typesToFilterText.split(/\n+|\s+/) : [] as String[]
        def mapRegion = extractRegion(dmm.maxX, dmm.maxY)

        new File('map_images').mkdir()

        def image = DmmRender.render(dmm, mapRegion, filterMode, typesToFilter)
        def file = new File("map_images/${MODEL.mapFile.name}_${System.currentTimeMillis()}.png")
        ImageIO.write(image, 'png', file)

        MODEL.isRenderEnabled = true
        MODEL.isSelectEnabled = true
        setReadyStatus()
    }
}

MapRegion extractRegion(int maxX, int maxY) {
    def defaultRegion = MapRegion.of(1, 1, maxX, maxY)

    if (MODEL.regionText.empty)
        return defaultRegion

    def regions = MODEL.regionText.split(/\s+/)

    switch (regions.size()) {
        case 2:
            return MapRegion.of(regions[0] as int, regions[1] as int)
        case 4:
            return MapRegion.of(regions[0] as int, regions[1] as int, regions[2] as int, regions[3] as int)
        default:
            return defaultRegion
    }
}

void setBusyStatus(text) {
	STATUS_LABEL.text = text
	STATUS_LABEL.foreground = Color.RED
	STATUS_SPINNER.visible = true
}

void setReadyStatus(text = 'Project "taucetistation.dme" is ready') {
	STATUS_LABEL.text = text
	STATUS_LABEL.foreground = Color.GREEN.darker().darker()
	STATUS_SPINNER.visible = false
}