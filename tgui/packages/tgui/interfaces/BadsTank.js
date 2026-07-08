import { useBackend } from '../backend';
import { Box, NoticeBox, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const BadsTank = (_, context) => {
  const { data } = useBackend(context);
  const { bads_amount, max_bads, clones_possible } = data;

  return (
    <Window width={400} height={200}>
      <Window.Content>
        <Section title="Bio-BADs Tank">
          <ProgressBar
            maxValue={max_bads}
            value={bads_amount}
            ranges={{
              good: [250, Infinity],
              average: [50, 250],
              bad: [-Infinity, 50],
            }}
          />
          <Box mt={1} textAlign="center">
            Enough for {clones_possible} clone(s).
          </Box>
        </Section>
        <NoticeBox danger mt={1}>
          Heads of staff should use this resource sparingly — it contains a
          special additive essential for the cloning process and cannot be
          refilled.
        </NoticeBox>
      </Window.Content>
    </Window>
  );
};
