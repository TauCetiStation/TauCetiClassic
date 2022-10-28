import { useBackend } from '../backend';
import {Box, Button } from '../components';
import { Window } from '../layouts';

export const SpaceHeater = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    open,
    on,
    mode,
    powerLevel,
    targetTemp,
    minTemp,
    maxTemp,
    currentTemp,
  } = data;
  return (
    <Window width={300} height={200}>
      <Window.Content fitted width="300" height="200">
        <Box backgroundColor="#696C72" width="100%" height="85%"
          style={{
            'position':'fixed',
            'z-index':'2',
            'border-bottom': '30px solid #4A4D55',
          }}>
          <Box backgroundColor="#696C72" width="100%" height="30%"
            style={{
              'position': 'fixed',
              'bottom': '0px',
              'border-bottom': '20px solid #4A4D55',
              'border-radius': '160px',
              'z-index':'1',
          }}/>
          <Box backgroundColor="#4A4D55" width="40%" height="30%"
            style={{
              'position': 'fixed',
              'bottom': '50%',
              'left': '5%',
              'border-bottom': '5px solid #959595',
              'z-index':'1',}}
            content="88"
            text-color="#6B0C0A"
          >
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
