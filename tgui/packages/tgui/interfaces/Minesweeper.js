import { useBackend } from '../backend';
import { Box, Button, Flex, Input, Tooltip, Section, Dropdown, Icon } from "../components";
import { Window } from '../layouts';

export const Minesweeper = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    width,
    height,
    grid,
    mines,
  } = data;
  return (
    <Window width={width} height={height+34} theme="minesweeper" title={mines}>
      <Window.Content fitted="1">
        {grid.map(line => (
          <>
            {line.map((butn, index) => (
              <Button key={index}
                disabled={butn.state === 'empty' ? 1 : 0}
                textColor={butn.nearest === '1' ? '#0092cc' : (butn.nearest === '2' ? '#779933' : (butn.nearest === '3' ? '#ff3333' : (butn.nearest === '4' ? "#087099" : (butn.nearest === '5' ? "#cc3333" : (butn.nearest === '6' ? "#A6B2EC" : (butn.nearest === '7' ? "#600095" : "#E5E5E5"))))))}
                content={butn.nearest ? butn.nearest : ' '}
                onClick={() => act('button_press', { choice_x: butn.x, choice_y: butn.y })}
              />
            ))}
            <br />
          </>
        ))}
      </Window.Content>
    </Window>
  );
};
