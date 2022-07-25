import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, Collapsible, LabeledList, Section, Flex, TimeDisplay } from '../components';
import { Window } from '../layouts';

export const SpawnersMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    askForRole,
    ignoredRoles,
    spawners,
  } = data;
  return (
    <Window title="Spawner Menu" width={700} height={525}>
      <Window.Content scrollable>
        <Section>
          <Collapsible title="Настройка ролей">
            <Box width="300px">
              <LabeledList>
                <LabeledList.Item label="Предлагать роли" buttons={
                  <Button
                    content={askForRole ? 'Да' : 'Нет'}
                    selected={askForRole}
                    color={askForRole ? 'good' : 'bad'}
                    onClick={() => act('askForRole')}
                  />
                } />
                <LabeledList.Item label="" buttons={
                  <Box height="20px" />
                } />
                {ignoredRoles.length && ignoredRoles.map(role => (
                  <LabeledList.Item key={role.name} label={toTitleCase(role.name)} buttons={
                    <>
                      <Button
                        content="Спрашивать"
                        selected={!role.ignored}
                        onClick={() =>
                          act('unignore', {
                            role: role.name,
                            ignore: 0,
                          })}
                      />
                      <Button
                        content="Игнорировать"
                        selected={role.ignored}
                        onClick={() =>
                          act('unignore', {
                            role: role.name,
                            ignore: 1,
                          })}
                      />
                    </>
                  } />
                ))}
              </LabeledList>
            </Box>
          </Collapsible>
        </Section>
        <Flex direction="column">
          {!spawners.length && (
            <Flex.Item fontSize="14px" bold>
              Ролей нет, но не печалься, они скоро будут!
            </Flex.Item>
          )}
          {spawners.map(spawner => (
            <Flex.Item key={spawner.type}>
              <Section
                title={toTitleCase(spawner.name)}
                buttons={
                  <Flex>
                    {spawner.time_left && (
                      <Flex.Item fontSize="14px" color="green" bold mt={0.4} mr={1}>
                        <TimeDisplay auto="down" value={spawner.time_left} />
                      </Flex.Item>
                    )}
                    <Flex.Item fontSize="14px" color="green" bold mt={0.4} mr={2}>
                      Мест: {
                        spawner.is_infinite
                          ? "∞"
                          : spawner.amount_left
                      }
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        content="Осмотреться"
                        onClick={() =>
                          act('jump', {
                            type: spawner.type,
                          })}
                      />
                      {spawner.toggleable && (
                        <Button
                          content={spawner.switched_on ? 'Отказаться' : 'Принять'}
                          selected={spawner.switched_on}
                          onClick={() =>
                            act('toggle', {
                              type: spawner.type,
                            })}
                        />
                      ) || (
                        <Button
                          content="Появиться"
                          onClick={() =>
                            act('spawn', {
                              type: spawner.type,
                            })}
                        />
                      )}
                    </Flex.Item>
                  </Flex>
                }>
                <LabeledList>
                  <LabeledList.Item label="Описание">
                    {spawner.short_desc}
                  </LabeledList.Item>
                  {spawner.important_warning && (
                    <LabeledList.Item label="Важная информация">
                      {spawner.important_warning}
                    </LabeledList.Item>
                  )}
                  {spawner.wiki_ref && (
                    <LabeledList.Item label="Вики">
                      {spawner.wiki_ref}
                    </LabeledList.Item>
                  )}
                </LabeledList>
              </Section>
              <br />
            </Flex.Item>
          ))}
        </Flex>
      </Window.Content>
    </Window>
  );
};
