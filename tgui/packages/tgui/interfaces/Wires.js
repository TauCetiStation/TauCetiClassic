import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const Wires = (props, context) => {
  const { act, data } = useBackend(context);
  const wires = data.wires || [];
  const statuses = data.status || [];
  return (
    <Window
      width={350}
      height={45 + wires.length * 25
        + (statuses.length > 0 ? 35 : 0) + statuses.length * 12}>
      <Window.Content>
        <Section>
          <LabeledList>
            {wires.map(wire => (
              <LabeledList.Item
                key={wire.color}
                className="candystripe"
                label={wire.label ? wire.label : "Wire"}
                labelColor={wire.color}
                color={wire.color}
                buttons={(
                  <>
                    <Button
                      content={wire.cut ? 'Mend' : 'Cut'}
                      onClick={() => act('cut', {
                        wire: wire.wire,
                      })} />
                    <Button
                      content="Pulse"
                      onClick={() => act('pulse', {
                        wire: wire.wire,
                      })} />
                    <Button
                      content={wire.attached ? 'Detach' : 'Attach'}
                      onClick={() => act('attach', {
                        wire: wire.wire,
                      })} />
                  </>
                )} />
            ))}
          </LabeledList>
        </Section>
        {!!statuses.length && (
          <Section>
            {statuses.map(status => (
              (typeof status === "string")
                ? (
                  <Box key={status}>
                    {status}
                  </Box>
                )
                : (
                  <Button
                    content={status.label}
                    onClick={() => act(status.act,
                      status.act_params ? status.act_params : undefined)} />
                )
            ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};