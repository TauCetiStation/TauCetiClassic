import { ProgressBar, NumberInput, Button, Section, Box, Flex } from '../components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Photocopier = (props, context) => {
  const { data } = useBackend(context);
  const {
    isAI,
    has_item,
  } = data;

  return (
    <Window
      title="Photocopier"
      width={240}
      height={isAI ? 309 : 234}>
      <Window.Content>
        {has_item ? (
          <Options />
        ) : (
          <Section title="Options">
            <Box color="average">
              No inserted item.
            </Box>
          </Section>
        )}
        {!!isAI && (
          <AIOptions />
        )}
      </Window.Content>
    </Window>
  );
};

const Options = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    num_copies,
  } = data;

  return (
    <Section title="Options">
      <Flex>
        <Flex.Item
          mt={0.4}
          width={11}
          color="label">
          Make copies:
        </Flex.Item>
        <Flex.Item>
          <NumberInput
            animate
            width={2.6}
            height={1.65}
            step={1}
            stepPixelSize={8}
            minValue={1}
            maxValue={10}
            value={num_copies}
            onDrag={(e, value) => act('set_copies', {
              num_copies: value,
            })} />
        </Flex.Item>
        <Flex.Item>
          <Button
            ml={0.2}
            icon="copy"
            textAlign="center"
            onClick={() => act('make_copy')}>
            Copy
          </Button>
        </Flex.Item>
      </Flex>
      <Button
        mt={0.5}
        textAlign="center"
        icon="reply"
        fluid
        onClick={() => act('remove')}>
        Remove item
      </Button>
    </Section>
  );
};

const AIOptions = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Section title="AI Options">
      <Box>
        <Button
          fluid
          icon="images"
          textAlign="center"
          onClick={() => act('ai_photo')}>
          Print photo from database
        </Button>
      </Box>
    </Section>
  );
};
