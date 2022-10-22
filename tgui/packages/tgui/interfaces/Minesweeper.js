import { useBackend } from '../backend';
import { Button, Section } from '../components';
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
        <Section>
          {grid.map(line => (
            <>
			  {line.map((butn, index) => (
                <Button key={index}
                  width={1.75}
                  heigth={1}
                  content={index}
                  onClick={() => act('button_press', { choice_x: butn.x, choice_y: butn.y })}
                />
              ))}
              <br />
            </>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
