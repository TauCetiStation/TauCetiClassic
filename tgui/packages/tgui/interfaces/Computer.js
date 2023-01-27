import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Icon, Knob, LabeledControls, LabeledList, Section, Tooltip } from '../components';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';
import { App } from '../components/App.js';

export const Computer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    broken,
    power,
    program,
    folder_files,
    stationTime,
    minimized_programs,
  } = data;
  return (
    <Window
      width={700}
      height={500}>
      <Window.Content fitted={1}>
        <Box className="Computer__Desktop">
          <img src="https://catherineasquithgallery.com/uploads/posts/2021-02/1612673274_118-p-kot-zelenii-fon-176.jpg" className="Computer__Wallpaper" />
          {program ? (<App context={context} />) : (
            folder_files.map((file, index) => (
              <Button key={index}
                className="Computer__File"
                content={
                  <>
                    <Icon name={file.file_icon} className="Computer__File-Icon" />
                    <Box color="#11111" className="Computer__File-Name">
                      {file.name}
                    </Box>
                  </>
                }
                onClick={() => act('open_file', { file_id: file.file_id })}
              />
            ))
          )}
        </Box>
        <Box className="Computer__BottomBar">
          <Button className="Computer__BottomBar-Button" icon="power-off" onClick={() => act()} />
          {!!minimized_programs && (
            minimized_programs.map((prog, index) => (
              <Button key={index}
                className="Computer__BottomBar-Minimized"
                icon={prog.file_icon}
                content={prog.file_name}
                onClick={() => act('maximize_file', { maximize_program_id: prog.file_id })}
              />
            ))
          )}
          {stationTime}
        </Box>
      </Window.Content>
    </Window>
  );
};