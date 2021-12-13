import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Flex, TimeDisplay } from '../components';
import { Window } from '../layouts';

export const SpawnersMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const spawners = data.spawners;
  return (
    <Window title="Spawner Menu" width={700} height={525}>
      <Window.Content scrollable>
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
                      Мест: {spawner.amount_left}
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        content="Осмотреться"
                        onClick={() =>
                          act('jump', {
                            type: spawner.type,
                          })}
                      />
                      <Button
                        content="Появиться"
                        onClick={() =>
                          act('spawn', {
                            type: spawner.type,
                          })}
                      />
                    </Flex.Item>
                  </Flex>
                }>
                <LabeledList>
                  <LabeledList.Item label="Описание">
                    {spawner.short_desc}
                  </LabeledList.Item>
                  {spawner.flavor_text && (
                    <LabeledList.Item label="Дополнительно">
                      {spawner.flavor_text}
                    </LabeledList.Item>
                  )}
                  {spawner.important_warning && (
                    <LabeledList.Item label="Важная информация">
                      {spawner.important_warning}
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
