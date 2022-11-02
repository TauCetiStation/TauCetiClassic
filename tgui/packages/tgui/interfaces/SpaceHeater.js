import { useBackend } from '../backend';
import { Box, Button, Knob } from '../components';
import { Icon } from '../components/Icon';
import { Battery } from '../components/Battery';
import { Window } from '../layouts';

export const SpaceHeater = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    mode,
    powerLevel,
    targetTemp,
    currentTemp,
  } = data;
  return (
    <Window width={300} height={200} title="Обогреватель">
      <Window.Content fitted width="300" height="200">
        <Box backgroundColor="#696C72" width="300px" height="170px"
          style={{
            'position': 'fixed',
            'border-bottom': '30px solid #4A4D55',
            'border-top': '5px solid #959595',
          }}>
          <Box backgroundColor="#696C72" width="300px" height="60px"
            style={{
              'position': 'fixed',
              'top': '140px',
              'border-bottom': '15px solid #4A4D55',
              'border-radius': '500px',
            }} />
          
          <Box width="80px" height="25px"
            style={{
              'position': 'fixed',
              'top': '36px',
              'left': '14px',
              'color': '#888888',
              'font-weight': 'bold',
              'font-family': 'Consolas',
              'font-size': '19px',
              'text-shadow': '-0.5px 2.0px 1px #4A4D55,2px -0.5px 1px #4A4D55, -0.5px -2.5px 0px #999999,-2px -0.5px 0px #999999',
            }}>
            ТЕМПЕРАТУРА:
          </Box>
          <Box backgroundColor="#4A4D55" width="120px" height="60px"
            style={{
              'position': 'fixed',
              'top': '57px',
              'left': '15px',
              'border-bottom': '5px solid #959595',
              'border-top': '4px solid #25272b',
            }}>
            <Box backgroundColor="#461f16" width="45px" height="40px"
              style={{
                'position': 'fixed',
                'top': '65px',
                'left': '51px',
                'border-top': '3px solid #25272b',
                'border-bottom': '5px solid #696C72',
                'color': '#D0330f',
                'font-weight': 'bold',
                'font-size': '25px',
                'font-family': 'Consolas',
                'padding-top': '1px',
                'padding-left': '2px',
                'font-stretch': 'ultra-condensed',
              }}>
              {targetTemp > 0 ? "+" : ""}{targetTemp}
            </Box>
            <Box backgroundColor="#461f16" width="30px" height="23px"
              style={{
                'position': 'fixed',
                'top': '65px',
                'left': '101px',
                'border-top': '3px solid #25272b',
                'border-bottom': '3px solid #696C72',
                'color': '#D0330f',
                'font-weight': 'bold',
                'font-size': '15px',
                'font-family': 'Consolas',
                'padding-bottom': '6px',
                'padding-left': '2px',
                'font-stretch': 'ultra-condensed',
              }}>
              {currentTemp > 0 ? "+" : ""}{currentTemp < 100 && currentTemp > -100 ? currentTemp : currentTemp ? "!!" : ""}
            </Box>
            
            <Button className="SpaceHeater__button" width="23px" height="23px" top="+27px" left="+7px" color="#888888"
              content={
                <Box className="SpaceHeater__button-Content" style={{ 'text-shadow': '0px 0px 9px #FFFFFF' }}>
                  -                
                </Box>
              }
              onClick={() => act('temp-add', { value: "-1" })}
            />
            <Button className="SpaceHeater__button" width="23px" height="23px" top="+27px" left="+62px" color="#888888"
              content={
                <Box className="SpaceHeater__button-Content" style={{ 'text-shadow': '0px 0px 9px #FFFFFF' }}>
                  +                
                </Box>
              }
              onClick={() => act('temp-add', { value: "1" })}
            />
            
          </Box>
          
          <Box width="80px" height="25px"
            style={{
              'position': 'fixed',
              'top': '119px',
              'left': '15px',
              'color': '#888888',
              'font-weight': 'bold',
              'font-family': 'Consolas',
              'font-size': '19px',
              'text-shadow': '-0.5px 2.0px 1px #4A4D55,2px -0.5px 1px #4A4D55, -0.5px -2.5px 0px #999999,-2px -0.5px 0px #999999',
            }}>
            АККУМУЛЯТОР:
          </Box>
          <Battery charge={powerLevel} top="103px" left="15px" />
        
          <div>
            <Knob
              top="0px"
              left="70px"
              className="SpaceHeater__Knob"
              value={mode}
              minValue="10"
              maxValue="30"
              step="1"
              stepPixelSize="3"
              onDrag={(e, value) => act('mode-change', { value: value })} />
            <Icon name="power-off" color="#4A4D55" size="2.5"
              style={{
                'position': 'fixed',
                'top': '146px',
                'left': '162px',
              }} />
            <Icon name="fire" color="#4A4D55" size="2.5"
              style={{
                'position': 'fixed',
                'top': '40px',
                'left': '208px',
              }} />
            <Icon name="snowflake-o" color="#4A4D55" size="2.5"
              style={{
                'position': 'fixed',
                'top': '146px',
                'left': '252px',
              }} />
          </div>
        </Box>
      </Window.Content>
    </Window>
  );
};
