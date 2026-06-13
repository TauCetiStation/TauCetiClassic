import { Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  attachmentOne: string | null;
  attachmentTwo: string | null;
  valveAttachment: string | null;
  valveOpen: BooleanLike;
};

export const TransferValve = () => {
  const { act, data } = useBackend<Data>();
  const { attachmentOne, attachmentTwo, valveAttachment, valveOpen } = data;
  return (
    <Window width={400} height={180}>
      <Window.Content>
        <Section
          title="Valve"
          buttons={
            <Button
              icon={valveOpen ? 'toggle-on' : 'toggle-off'}
              tooltip={valveOpen ? 'Close' : 'Open'}
              disabled={!attachmentOne || !attachmentTwo}
              selected={valveOpen}
              onClick={() => act('open')}
            >
              {valveOpen ? 'Opened' : 'Closed'}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Left tank">
              <Button
                tooltip={!attachmentTwo ? 'Attach' : 'Detach'}
                onClick={() => act('leftTank')}
              >
                {!attachmentTwo ? 'None' : attachmentTwo}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Valve attachment">
              <Button
                tooltip={!valveAttachment ? 'Attach' : 'Detach'}
                onClick={() => act('device')}
              >
                {!valveAttachment ? 'None' : valveAttachment}
              </Button>
              {!!valveAttachment && (
                <Button
                  tooltip="View"
                  icon="gear"
                  onClick={() => act('viewDevice')}
                />
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Right tank">
              <Button
                tooltip={!attachmentOne ? 'Attach' : 'Detach'}
                onClick={() => act('rightTank')}
              >
                {!attachmentOne ? 'None' : attachmentOne}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
