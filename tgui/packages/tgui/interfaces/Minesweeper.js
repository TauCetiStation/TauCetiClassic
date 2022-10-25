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
  const num_to_color = {
    " ": "#ffffff",
    "1": "#0092cc",
    "2": "#779933",
    "3": "#ff3333",
    "4": "#087099",
    "5": "#cc3333",
    "6": "#A6B2EC",
    "7": "#600095",
    "8": "#E5E5E5",
  };
  return (
    <Window width={width} height={height+34} theme="minesweeper" title={mines}>
      <Window.Content fitted="1">
        {grid.map(line => (
          <>
            {line.map((butn, index) => (
              <Button key={index}
                disabled={butn.state === 'empty' ? 1 : 0}
                textColor={num_to_color[butn.nearest]}
                content={butn.nearest}
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
