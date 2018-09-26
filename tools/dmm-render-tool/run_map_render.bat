@echo off

echo Info:
echo  - Map is what to render
echo  - Mode:
echo    * NONE    - no atom filter will be applied
echo    * IGNORE  - all types and subtypes of them WILL NOT be rendered
echo    * INCLUDE - provided types and subtypes of them WILL BE rendered
echo    * EQUAL   - only provided types will be rendered
echo  - Region is the area to render represented by int values.
echo    Could be provided in two forms:
echo      - lowerPoint and upperPoint
echo      - lowerX and lowerY, and upperX and upperY
echo    Values should be separated by space. (example: '5 10' or '5 10 7 12')
echo  - Types to filter: types used during filtration.
echo    Should be separated by space or new line. (example: '/area /obj/item')

java -Xms256m -Xmx768m -jar ../.groovy-shell/groovy-shell.jar ./script/map-render.groovy