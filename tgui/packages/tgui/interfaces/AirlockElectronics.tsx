import { useBackend } from '../backend';
import { Button, Input, LabeledList, Section, NoticeBox } from '../components';
import { Window } from '../layouts';
import { AccessList } from './common/AccessList';

type Data = {
  oneAccess: number | boolean | null | undefined;
  unres_direction: number;
  passedName: string;
  lastOperator: string;
  regions: string[];
  accesses: string[];
};

export const AirLockMainSection = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    accesses = [],
    oneAccess,
    passedName,
    regions = [],
    unres_direction,
    lastOperator,
  } = data;

  return (
    <Section title="Main">
      <NoticeBox info>
        Last operator: {lastOperator}.
      </NoticeBox>
      <LabeledList>
        <LabeledList.Item label="Access Required">
          <Button
            icon={oneAccess ? 'unlock' : 'lock'}
            content={oneAccess ? 'One' : 'All'}
            onClick={() => act('one_access')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Unrestricted Access">
          <Button
            icon={unres_direction & 1 ? 'check-square-o' : 'square-o'}
            content="North"
            selected={unres_direction & 1}
            onClick={() =>
              act('direc_set', {
                unres_direction: '1',
              })}
          />
          <Button
            icon={unres_direction & 2 ? 'check-square-o' : 'square-o'}
            content="South"
            selected={unres_direction & 2}
            onClick={() =>
              act('direc_set', {
                unres_direction: '2',
              })}
          />
          <Button
            icon={unres_direction & 4 ? 'check-square-o' : 'square-o'}
            content="East"
            selected={unres_direction & 4}
            onClick={() =>
              act('direc_set', {
                unres_direction: '4',
              })}
          />
          <Button
            icon={unres_direction & 8 ? 'check-square-o' : 'square-o'}
            content="West"
            selected={unres_direction & 8}
            onClick={() =>
              act('direc_set', {
                unres_direction: '8',
              })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Airlock Name">
          <Input
            fluid
            maxLength={30}
            value={passedName}
            onChange={(e, value) =>
              act('passedName', {
                passedName: value,
              })}
          />
        </LabeledList.Item>
      </LabeledList>
      <AccessList
        accesses={data.regions}
        selectedList={data.accesses}
        accessMod={(ref) =>
          act('set', {
            access: ref,
          })}
        grantAll={() => act('grant_all')}
        denyAll={() => act('clear_all')}
        grantDep={ref => act('grant_region', {
          region: ref,
        })}
        denyDep={ref => act('deny_region', {
          region: ref,
        })} />
    </Section>
  );
};

export const AirlockElectronics = (props, context) => {
  return (
    <Window width={420} height={550}>
      <Window.Content>
        <AirLockMainSection />
      </Window.Content>
    </Window>
  );
};
