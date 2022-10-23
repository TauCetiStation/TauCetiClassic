import { useBackend } from '../backend';
import { Box, Button, Flex, Input, Tooltip, Section, Dropdown, Icon } from "../components";
import { Window } from '../layouts';

export const Minesweeper = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    width,
    height,
    grid,
  } = data;
  return (
    <Window width={width} height={height} theme="ntos">
      <Window.Content>
        {grid.map(line => (
          <>
            {line.map((butn, index) => (
              <Button key={index}
                disabled={butn.state === 'empty' ? 1 : 0}
                width="27px"
                height="27px"
                content={butn.nearest ? butn.nearest : ' '}
                textAlign="center"
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
