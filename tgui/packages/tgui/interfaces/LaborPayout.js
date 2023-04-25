import { useBackend } from "../backend";
import { Box, Button, NoticeBox, LabeledList, Section, AnimatedNumber } from "../components";
import { Window } from "../layouts";

export const LaborPayout = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window width={400} height={500}>
      <Window.Content scrollable>
        <NoticeBox success={data.has_id}>
          {data.has_id ? (
            <>
              <Box
                display="inline-block"
                verticalAlign="middle"
                style={{
                  float: 'left',
                }}>
                Logged in as {data.id.name}.<br />
                You have {data.id.credits.toLocaleString('en-US')} credits.
              </Box>
              <Button
                icon="eject"
                content="Eject ID"
                style={{
                  float: 'right',
                }}
                onClick={() => act('logoff')}
              />
              <Box
                style={{
                  clear: "both",
                }}
              />
            </>
          ) : (
            <Box>
              <Button
                icon="arrow-right"
                mr={1}
                onClick={() => act("insert")}>
                Insert ID
              </Button>
              in order to receive payout.
            </Box>
          )}
        </NoticeBox>
        <LabeledList>
          <LabeledList.Item label="Current unclaimed payout" buttons={
            <Button
              disabled={data.unclaimedPayout < 1 || !data.has_id}
              icon="download"
              onClick={() => act("claim")}>
              Claim
            </Button>
          }>
            <AnimatedNumber value={data.unclaimedPayout} />
          </LabeledList.Item>
          {!!data.has_id && data.id.sentence > 0 && (
            <LabeledList.Item label={"Your labor sentence in credits"} buttons={
              <Button
                disabled={data.id.sentence > data.id.credits}
                icon="lock-open"
                onClick={() => act("release")}>
                Request release
              </Button>
            }>
              <AnimatedNumber value={data.id.sentence} />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
