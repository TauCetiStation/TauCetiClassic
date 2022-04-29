
import { useBackend } from '../backend';
import { NumberInput, Stack, Section, Input } from '../components';
import { Window } from '../layouts';

export const SamplerPipe = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    gases,
    nodeName,
    locked,
  } = data;
  return (
    <Window
      title="Atmospherics Alet System"
      width={300}
      height={400}>
      <Window.Content>
        <Section title={"Node name"}>
          <Input disabled={locked} fluid value={nodeName} onChange={(_, n) => act("setName", { name: n })} />
        </Section>
        <Section title={"Gases"}>
          {gases.map(gas => (
            <Section key={gas.id} title={gas.name}>
              <Stack>
                <Stack.Item grow>
                  Lower
                </Stack.Item>
                <Stack.Item>
                  <NumberInput
                    disabled={locked}
                    width={5}
                    minValue={0}
                    maxValue={1}
                    step={0.01}
                    value={gas.threshold.min}
                    onChange={(_, v) => act("setBound", { id: gas.id, bound: "min", value: v })} />
                </Stack.Item>
              </Stack>
              <Stack>
                <Stack.Item grow>
                  Upper
                </Stack.Item>
                <Stack.Item>
                  <NumberInput
                    disabled={locked}
                    width={5}
                    minValue={0}
                    maxValue={1}
                    step={0.01}
                    value={gas.threshold.max}
                    onChange={(_, v) => act("setBound", { id: gas.id, bound: "max", value: v })} />
                </Stack.Item>
              </Stack>
            </Section>
          )
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
