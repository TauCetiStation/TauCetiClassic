import { useBackend } from "../backend";
import { Button, LabeledList, Section } from "../components";
import { Window } from "../layouts";

export const LaborManagment = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window width={400} height={300}>
      <Window.Content>
        <Section title="ID Cards">
          <LabeledList>
            <LabeledList.Item label="Security ID">
              <Button
                icon={data.scan_name ? 'eject' : 'id-card'}
                selected={data.scan_name}
                content={data.scan_name ? data.scan_name : '-----'}
                tooltip={data.scan_name ? "Eject ID" : "Insert ID"}
                onClick={() => act("scan")} />
            </LabeledList.Item>
            <LabeledList.Item label="Prisoner's ID">
              <Button
                icon={data.target_name ? 'eject' : 'id-card'}
                selected={data.target_name}
                content={data.target_name ? data.target_name : '-----'}
                tooltip={data.target_name ? "Eject ID" : "Insert ID"}
                onClick={() => act("target")} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!!data.target_name && (
          <Section title="Prisoner Data">
            <LabeledList>
              <LabeledList.Item label="Prisoner's name">
                <Button
                  icon="pencil-alt"
                  content={data.target_owner ? data.target_owner : "-----"}
                  disabled={!data.authenticated}
                  onClick={() => act("set_name")} />
              </LabeledList.Item>
              <LabeledList.Item label="Broken laws">
                <Button
                  icon="pencil-alt"
                  content={data.reason ? data.reason : "-----"}
                  disabled={!data.authenticated}
                  onClick={() => act("set_reason")} />
              </LabeledList.Item>
              <LabeledList.Item label="Crime details">
                <Button
                  icon="pencil-alt"
                  content={data.details ? data.details : "-----"}
                  disabled={!data.authenticated}
                  onClick={() => act("set_details")} />
              </LabeledList.Item>
              <LabeledList.Item label="Labor sentence">
                <Button
                  icon="pencil-alt"
                  content={data.target_name ? "" + data.labor_sentence : "-----"}
                  disabled={!data.authenticated || data.permanent}
                  onClick={() => act("set_sentence")} />
              </LabeledList.Item>
              <LabeledList.Item label="Permanent">
                <Button.Checkbox
                  content={data.permanent ? "Yes" : "No"}
                  checked={data.permanent}
                  disabled={!data.authenticated}
                  onClick={() => act("permanent")} />
              </LabeledList.Item>
              <LabeledList.Item label="Prisoner's balance">
                <Button
                  icon="pencil-alt"
                  content={data.target_name ? "" + data.labor_credits : "-----"}
                  disabled={!data.authenticated}
                  onClick={() => act("set_credits")} />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
