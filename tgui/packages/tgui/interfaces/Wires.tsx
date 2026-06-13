import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  wires: {
    wire: string;
    color: string;
    label?: string;
    cut: boolean;
    attached: boolean;
  }[];
  status: (
    | string
    | { label: string; act: string; act_params?: Record<string, unknown> }
  )[];
};

export const Wires = () => {
  const { act, data } = useBackend<Data>();
  const wires = data.wires || [];
  const statuses = data.status || [];
  return (
    <Window
      width={350}
      height={
        45 +
        wires.length * 25 +
        (statuses.length > 0 ? 35 : 0) +
        statuses.length * 12
      }
    >
      <Window.Content>
        <Section>
          <LabeledList>
            {wires.map((wire) => (
              <LabeledList.Item
                key={wire.color}
                className="candystripe"
                label={wire.label ? wire.label : 'Провода'}
                labelColor={wire.color}
                color={wire.color}
                buttons={
                  <>
                    <Button
                      onClick={() =>
                        act('cut', {
                          wire: wire.wire,
                        })
                      }
                    >
                      {wire.cut ? 'Соединить' : 'Перерезать'}
                    </Button>
                    <Button
                      onClick={() =>
                        act('pulse', {
                          wire: wire.wire,
                        })
                      }
                    >
                      Пульс
                    </Button>
                    <Button
                      onClick={() =>
                        act('attach', {
                          wire: wire.wire,
                        })
                      }
                    >
                      {wire.attached ? 'Отсоединить' : 'Присоединить'}
                    </Button>
                  </>
                }
              />
            ))}
          </LabeledList>
        </Section>
        {!!statuses.length && (
          <Section>
            {statuses.map((status, i) =>
              typeof status === 'string' ? (
                <Box key={status}>{status}</Box>
              ) : (
                <Button
                  key={i}
                  onClick={() =>
                    act(
                      status.act,
                      status.act_params ? status.act_params : undefined,
                    )
                  }
                >
                  {status.label}
                </Button>
              ),
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
