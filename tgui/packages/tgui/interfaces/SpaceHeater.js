import { useBackend } from '../backend';
import { Box, Button, Knob } from '../components';
import { Icon } from '../components/Icon';
import { Battery } from '../components/Battery';
import { SegmentDisplay } from '../components/SegmentDisplay';
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
        <Box backgroundColor="#696C72" width="300px" height="245px" position="fixed" className="SpaceHeater__Background_1">
          <Box backgroundColor="#696C72" width="300px" height="90px" position="fixed" top="185px" className="SpaceHeater__Background_2" />
            
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
            <Box width="75px" height="30px" backgroundColor="#461f16" position="fixed" top="160px" left="42px" className="SpaceHeater__Concave_Box">
              <SegmentDisplay position="relative" left="-1px" top="1px" display_width={5} display_height={20} display_text={(targetTemp > 0 ? "+" : "")+targetTemp+"C°"} />
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
            <Icon name="cog" color="#4A4D55" size="2.5" position="absolute" left="-19px" top="68px" />
            <Icon name="power-off" color="#4A4D55" size="2.5" position="absolute" left="-19px" top="-17px" />
            <Icon name="sun" color="#4A4D55" size="2.6" position="absolute" left="67px" top="-17px" />
            <Icon name="snowflake-o" color="#4A4D55" size="2.6" position="absolute" left="68px" top="68px" />
          </Box>
            
          <Box width="130px" height="42px" backgroundColor="#461f16" position="fixed" top="195px" left="15px" className="SpaceHeater__Concave_Box">
            <SegmentDisplay position="relative" left="0px" top="1px" display_width={6} display_height={30} display_text={currentTemp < 1000 && currentTemp > -1000 ? ((currentTemp > 0 ? "+" : "")+currentTemp+"C°") : "ОШИБКА"} />
          </Box>
          
          <Box width="130px" height="42px" backgroundColor="#4A4D55" position="fixed" top="195px" left="155px" className="SpaceHeater__Concave_Box">
            <Battery charge={powerLevel} battery_width={120} battery_height={30} border_color="#aaaaaa" />
          </Box>

        </Box>
      </Window.Content>
    </Window>
  );
};
