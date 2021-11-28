import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Flex } from '../components';
import { Window } from '../layouts';

export const SpawnersMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const spawners = data.spawners;
  return (
    <Window title="Spawners Menu" width={700} height={525}>
      <Window.Content scrollable>
        <Flex>
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
                  {spawner.short_desc && (
                    <LabeledList.Item label="Описание">
                      {spawner.short_desc}
                    </LabeledList.Item>
                  )}
                  {spawner.flavor_text && (
                    <LabeledList.Item label="Дополнительно">
                      {spawner.flavor_text}
                    </LabeledList.Item>
                  )}
                  {spawner.important_info && (
                    <LabeledList.Item label="Важная информация">
                      {spawner.important_info}
                    </LabeledList.Item>
                  )}
                </LabeledList>
              </Section>
            </Flex.Item>
          ))}
        </Flex>
      </Window.Content>
    </Window>
  );
};
