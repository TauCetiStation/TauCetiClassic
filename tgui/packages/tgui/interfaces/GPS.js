import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Icon, Input, LabeledList, Section,
  Table } from '../components';
import { Window } from '../layouts';

const vectorText = vector => vector ? "(" + vector.join(", ") + ")" : "ERROR";

const rad2deg = rad => rad * (180 / Math.PI);
const distanceToPoint = (from, to) => {
  if (!from || !to) {
    return;
  }

  // Different Z-level
  if (from[2] !== to[2]) {
    return null;
  }

  const angle = Math.atan2(to[1] - from[1], to[0] - from[0]);
  const dist = Math.sqrt(Math.pow(to[1] - from[1], 2)
  + Math.pow(to[0] - from[0], 2));
  return { angle: rad2deg(angle), distance: dist };
};
var mouseX = 0;
var mouseY = 0;

var mouseovered = false;

const handleMouseOver = (e) => {
	mouseovered = true;
}
const handleMouseOut = (e) => {
	mouseovered = false;
}
const handleMouseMove = (e) => {
  mouseX = Math.round(255/e.target.offsetWidth * (e.clientX - e.target.offsetLeft))-15;
  mouseY = 255-(Math.round(255/e.target.offsetWidth * (e.clientY - e.target.offsetTop))-69);
};

export const GPS = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    on,
    active,
    tag,
    selected_z,
    position,
    area,
    saved,
    signals,
    track_saving,
    track,
    style,
  } = data;
  return (
    <Window>
      <Window.Content fitted>
        <Box className={"GPS_"+style+"_Main"}/>
        <Box className={"GPS_"+style+"_Line"}/>
        <Button className="GPS_Top_Button" left="25px" top="0px"
          selected={on}
          onClick={() => act('toggle')}
        />
        <Button className="GPS_Top_Button" left="140px" top="0px" width="75px"
          selected={active}
          onClick={() => act('tracking')}
        />
        
        <Box className="GPS_Antenna" right="25px" top="0px"/>
        
        <Box className="GPS_Monitor" left="22px" top="65px"    width="357px" height="357px" onMouseMove={handleMouseMove} onMouseout={handleMouseOut} onMouseover={handleMouseOver}>
          <Box className="GPS_Monitor2">
            <Box className="GPS_Monitor3">
              {on ? (<div>
                <Box left="0px" top="-15px" className="GPS_Header" width="350px" height="25px">
                  -{selected_z}-
                </Box>
                {track ? (
                  track.map((dot, index) => (
                    <>
                      {dot.z == selected_z && (
                        <>
                          <Box key={index} left={1.4*dot.x-1+"px"} bottom={1.4*dot.y-21+"px"} className="GPS_TrackDot" />
                          <svg className="GPS_TrackLine">
                            {track[index-1] && track[index-1].end != 1 && (
                              <line x1={1.4*track[index-1].x+1} x2={1.4*dot.x+1} y1={1.4*track[index-1].y-19} y2={1.4*dot.y-19} stroke="rgba(255, 255, 255, .5)" />
                            )}
                          </svg>
                        </>
                      )}
                    </>
                  ))
                ) : (<div/>)}
                {saved ? (
                  <Box left={1.4*saved[0]-24+"px"} bottom={1.4*saved[1]-44+"px"} className="GPS_SavedCords">
                    <Box left="0px" top="0px" className="GPS_SavedCordsHeader">
                      СОХР.
                    </Box>
                    <Box left="22px" bottom="22px" className="GPS_SavedDot"/>
                    <Box left="-10px" bottom="3px" className="GPS_SavedCordsText">
                      {vectorText(saved)}
                    </Box>
                  </Box>
                ) : (<div/>)}
                {active ? (
                  <>
                    {signals.map(signal => ({...signal,})).map((signal, i) => (
                      <Box key={i} left={1.4*signal.position[0]-24+"px"} bottom={1.4*signal.position[1]-44+"px"} className="GPS_ForeignCords">
                        <Box left="0px" top="0px" className="GPS_ForeignCordsHeader">
                          {signal.tag}
                        </Box>
                        <Box left="22px" bottom="22px" className="GPS_ForeignDot"/>
                        <Box left="-10px" bottom="3px" className="GPS_ForeignCordsText">
                          {vectorText(signal.position)}
                        </Box>
                      </Box>
                    ))}                  
                    {position ? (
                      <Box left={1.4*position[0]-24+"px"} bottom={1.4*position[1]-44+"px"} className="GPS_MyCords">
                        <Box left="0px" top="0px" className="GPS_MyCordsHeader">
                          {tag}
                        </Box>
                        <Box left="21px" bottom="21px" className="GPS_MyDot"/>
                        <Box left="-10px" bottom="3px" className="GPS_MyCordsText">
                          {vectorText(position)}
                        </Box>
                      </Box>
                    ) : (<div/>)}
                    <Box left="0px" bottom="-15px" className="GPS_Header" width="350px" height="25px">
                      {area}
                    </Box>
                  </>
                ) : (<div/>)}
				{mouseovered && (
				  <Box left={1.4*mouseX-36+"px"} bottom={1.4*mouseY-22+"px"} className="GPS_MouseCordsText">
                    ({mouseX}, {mouseY})
                  </Box>
				)}
              </div>) : (<div/>)}
              <Box className="GPS_Monitor4"/>
            </Box>
          </Box>{on ? (<Box className="GPS_Monitor5"/>) : (<div/>)}
        </Box>
        
        <Box className="GPS_Buttons_Holder" left="70px"    bottom="10px" width="260px"    height="175px">
            <Box className="GPS_Buttons_Holder2" top="10px"    width="100%" height="155px">
                <Button className="GPS_Button" left="5px" top="0px" width="50px" height="50px"
                    selected={track_saving}
                    onClick={() => act('track_saving')}
                    content={<Box className="GPS_Button-Content"><Icon name="map" color="#cccccc" size="1"/></Box>} />
                <Button className="GPS_Button" left="5px" top="50px" width="50px" height="50px"
                    onClick={() => act('erase_data')}
                    content={<Box className="GPS_Button-Content"><Icon name="trash" color="#cccccc" size="1"/></Box>} />
                    
                <Button className="GPS_Button" left="5px" top="100px" width="50px" height="50px"
                    onClick={() => act('save_location')}
                    content={<Box className="GPS_Button-Content"><Icon name="map-marker" color="#cccccc" size="1"/></Box>} />
                    
                <Button className="GPS_Button" right="5px" top="0px" width="50px" height="50px"
                    onClick={() => act('z_level', { chosen_level: selected_z+1 })}
                    content={<Box className="GPS_Button-Content"><Icon name="arrow-up" color="#cccccc" size="1"/></Box>} />
                <Button className="GPS_Button" right="5px" top="50px" width="50px" height="50px"
                    onClick={() => act('z_level', { chosen_level: selected_z-1 })}
                    content={<Box className="GPS_Button-Content"><Icon name="arrow-down" color="#cccccc" size="1"/></Box>} />
                
                <Box position="absolute" left="60px" top="0px" width="140px" height="165px">
                    <Button className="GPS_Button" left="0px" top="0px" width="45px" height="35px" onClick={() => act('tag')} content={<Box className="GPS_Button-Content">1</Box>}/>
                    <Button className="GPS_Button" left="45px" top="0px" width="45px" height="35px" onClick={() => act('tag')} content={<Box className="GPS_Button-Content">2</Box>}/>
                    <Button className="GPS_Button" left="90px" top="0px" width="45px" height="35px" onClick={() => act('tag')} content={<Box className="GPS_Button-Content">3</Box>}/>
                    <Button className="GPS_Button" left="0px" top="35px" width="45px" height="35px" onClick={() => act('tag')} content={<Box className="GPS_Button-Content">4</Box>}/>
                    <Button className="GPS_Button" left="45px" top="35px" width="45px" height="35px" onClick={() => act('tag')} content={<Box className="GPS_Button-Content">5</Box>}/>
                    <Button className="GPS_Button" left="90px" top="35px" width="45px" height="35px" onClick={() => act('tag')} content={<Box className="GPS_Button-Content">6</Box>}/>
                    <Button className="GPS_Button" left="0px" top="70px" width="45px" height="35px" onClick={() => act('tag')} content={<Box className="GPS_Button-Content">7</Box>}/>
                    <Button className="GPS_Button" left="45px" top="70px" width="45px" height="35px" onClick={() => act('tag')} content={<Box className="GPS_Button-Content">8</Box>}/>
                    <Button className="GPS_Button" left="90px" top="70px" width="45px" height="35px" onClick={() => act('tag')} content={<Box className="GPS_Button-Content">9</Box>}/>
                    <Button className="GPS_Button" left="45px" top="105px" width="45px" height="35px" onClick={() => act('tag')} content={<Box className="GPS_Button-Content">0</Box>}/>
                </Box>
                
                <Button className="GPS_Button" right="5px" top="105px" width="100px" height="45px"
                    onClick={() => act('choose_track')}
                    content={<Box className="GPS_Button-Content"><Icon name="caret-left" color="#cccccc" size="1"/><Icon name="save" color="#cccccc" size="1"/><Icon name="caret-right" color="#cccccc" size="1"/></Box>} />
            </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
