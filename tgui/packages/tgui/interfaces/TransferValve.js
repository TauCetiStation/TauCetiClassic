import { useBackend } from '../backend';
import { Button, LabeledControls, Section } from '../components';
import { Window } from '../layouts';

export const TransferValve = (props, context) => {
  const { act, data } = useBackend(context);
  const { attachmentOne, attachmentTwo, valveAttachment, valveOpen } = data;
  return (
    <Window width={400} height={150}>
      <Window.Content>
        <Section
          title="Valve"
          buttons={
            <Button
              icon={valveOpen ? 'exchange' : 'times'}
              content={valveOpen ? 'Opened' : 'Closed'}
              disabled={!attachmentOne || !attachmentTwo}
              selected={valveOpen}
              onClick={() => act('open')}
            />
          }>
          <LabeledControls>
            <LabeledControls.Item label="Left tank">
              <Button
                content={!attachmentTwo ? 'None' : attachmentTwo}
                tooltip={!attachmentTwo ? 'Attach' : 'Detach'}
                onClick={() => act('leftTank')}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Valve attachment">
              <Button
                content={!valveAttachment ? 'None' : valveAttachment}
                tooltip={!valveAttachment ? 'Attach' : 'Detach'}
                onClick={() => act('device')}
              />
              {!!valveAttachment && (
                <Button content="View" onClick={() => act('viewDevice')} />
              )}
            </LabeledControls.Item>
            <LabeledControls.Item label="Right tank">
              <Button
                content={!attachmentOne ? 'None' : attachmentOne}
                tooltip={!attachmentOne ? 'Attach' : 'Detach'}
                onClick={() => act('rightTank')}
              />
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
      </Window.Content>
    </Window>
  );
};
