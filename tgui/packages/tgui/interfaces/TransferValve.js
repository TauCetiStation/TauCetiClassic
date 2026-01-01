import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const TransferValve = (props, context) => {
  const { act, data } = useBackend(context);
  const { attachmentOne, attachmentTwo, valveAttachment, valveOpen } = data;
  return (
    <Window width={400} height={180}>
      <Window.Content>
        <Section
          title="Valve"
          buttons={
            <Button
              icon={valveOpen ? 'toggle-on' : 'toggle-off'}
              content={valveOpen ? 'Opened' : 'Closed'}
              tooltip={valveOpen ? 'Close' : 'Open'}
              disabled={!attachmentOne || !attachmentTwo}
              selected={valveOpen}
              onClick={() => act('open')}
            />
          }>
          <LabeledList>
            <LabeledList.Item label="Left tank">
              <Button
                content={!attachmentTwo ? 'None' : attachmentTwo}
                tooltip={!attachmentTwo ? 'Attach' : 'Detach'}
                onClick={() => act('leftTank')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Valve attachment">
              <Button
                content={!valveAttachment ? 'None' : valveAttachment}
                tooltip={!valveAttachment ? 'Attach' : 'Detach'}
                onClick={() => act('device')}
              />
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
                content={!attachmentOne ? 'None' : attachmentOne}
                tooltip={!attachmentOne ? 'Attach' : 'Detach'}
                onClick={() => act('rightTank')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
