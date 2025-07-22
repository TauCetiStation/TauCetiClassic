import { useBackend } from '../backend';
import { Box, Button, Icon } from '../components';
import { Window } from '../layouts';

export const Excavation = (props, context) => {
  const { act, data } = useBackend(context);
  const { width, height, grid, n_title } = data;
  return (
    <Window
      width={width}
      height={height + 32}
      title={n_title}
      className="Excavation__Window">
      <Window.Content fitted height={height + 32}>
        {grid.map((line) => (
          <>
            {line.map((butn, index) => (
              <Button
                key={index}
                className={`Excavation__Button ${butn.state === 'fossil_revealed' ? "Excavation__Button--fossil-revealed" : ""}`}
                disabled={butn.state === 'empty' ? 1 : 0}
                onClick={() =>
                  act('button_press', { choice_x: butn.x, choice_y: butn.y })
                }
              />
            ))}
            <br />
          </>
        ))}
      </Window.Content>
    </Window>
  );
};
