import { useBackend } from '../backend';
import { Box, Button, Flex } from '../components';
import { Window } from '../layouts';

export const EmotePanelEditor = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    customEmotes,
    allHumanEmotes,
  } = data;
  return (
    <Window
      width={250}
      height={400}
      resizable>
      <Window.Content>
        <Flex direction="column">
          {allHumanEmotes.sort().map(emote => (
            <Box
              fontSize="20px"
              key={emote}>
              <Button.Checkbox
                checked={customEmotes.includes(emote)}
                onClick={() => act('switchEmote', { emote: emote })}
                content={emote} />
            </Box>
          ))}
        </Flex>
      </Window.Content>
    </Window>
  );
};
