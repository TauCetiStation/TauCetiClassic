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
    minTemp,
    maxTemp,
    targetTemp,
    currentTemp,
  } = data;
  return (
    <Window width={300} height={275} title="Обогреватель">
      <Window.Content fitted width="300" height="275">
        <Box backgroundColor="#696C72" width="300px" height="245px" position="fixed"
          style={{
            'border-bottom': '50px solid #4A4D55',
            'border-top': '5px solid #959595',
          }}>
          <Box backgroundColor="#696C72" width="300px" height="90px" position="fixed" top="185px"
            style={{
              'border-bottom': '15px solid #4A4D55',
              'border-radius': '500px',
            }} />
            
          <Box position="fixed" left="20px" top="75px">
            <Knob
              className="SpaceHeater__Knob"
              value={targetTemp}
              minValue={minTemp}
              maxValue={maxTemp}
              step="1"
              stepPixelSize="2"
              onDrag={(e, value) => act('temp-change', { value: value })} />
            <svg
              width="120"
              height="120">
              <path d="M 29 0 A 64 58 25 1 1 120 0 M 30 0 A 48 48 0 1 1 90 0" stroke="#4A4D55" fill="#4A4D55" fill-rule="evenodd" stroke-width="1" />

            </svg>
            <Box backgroundColor="#461f16" width="55px" height="30px" position="absolute" left="32px" top="85px" fontSize="20px" fontFamily="Consolas" bold={1} textColor="#D0330f"
              style={{
                'border-top': '3px solid #25272b',
                'border-bottom': '3px solid #666666',
              }}>
              {targetTemp > 0 ? "+" : "-"}{targetTemp}C°
            </Box>
          </Box>
            
          <Box position="fixed" left="175px" top="75px">
            <Knob
              className="SpaceHeater__Knob"
              value={mode}
              minValue="10"
              maxValue="40"
              step="1"
              stepPixelSize="3"
              onDrag={(e, value) => act('mode-change', { value: value })} />
            <Icon name="cog" color="#4A4D55" size="2.5" position="absolute" left="-20px" top="70px" />
            <Icon name="power-off" color="#4A4D55" size="2.5" position="absolute" left="-22px" top="-13px" />
            <Icon name="sun" color="#4A4D55" size="2.5" position="absolute" left="69px" top="-13px" />
            <Icon name="snowflake-o" color="#4A4D55" size="2.5" position="absolute" left="70px" top="70px" />
          </Box>
            
          <Box width="130px" height="42px" backgroundColor="#4A4D55" position="fixed" top="195px" left="15px" textAlign="center" textColor="#666666" fontFamily="Consolas" bold={1} fontSize="19px"
            style={{
              'border': '5px inset #aaaaaa',
              'border-top-color': '#25272b',
              'border-left-color': '#25272b',
            }}>
            <Box backgroundColor="#461f16" width="120px" height="32px" fontSize="25px" textColor="#D0330f"
              style={{
                'border-top': '3px solid #25272b',
                'border-bottom': '3px solid #666666',
              }}>
              {currentTemp > 0 ? "+" : ""}{currentTemp}C°
            </Box>
          </Box>
          
          <Box width="130px" height="42px" backgroundColor="#4A4D55" position="fixed" top="195px" left="155px" textAlign="center" textColor="#666666" fontFamily="Consolas" bold={1} fontSize="19px"
            style={{
              'border': '5px inset #aaaaaa',
              'border-top-color': '#25272b',
              'border-left-color': '#25272b',
            }}>
            <Battery charge={powerLevel} battery_width={120} battery_height={30} border_color="#aaaaaa" />
          </Box>

        </Box>
      </Window.Content>
    </Window>
  );
};
