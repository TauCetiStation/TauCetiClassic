import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Flex } from '../components';
import { Window } from '../layouts';
import { formatTime } from '../format';

export const SpawnersMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const spawners = data.spawners;
  return (
    <Window title="Меню специальных ролей" width={700} height={525}>
      <Window.Content scrollable>
        <Flex direction="column">
          {!spawners.length && (
            <Flex.Item fontSize="14px" textAlign="center">
              <Section>Ролей нет, но не печалься, они скоро будут!</Section>
            </Flex.Item>
          )}
          {spawners.map(spawner => (
            <Flex.Item key={spawner.ref}>
              <Section
                title={toTitleCase(spawner.name)}
                buttons={(
                  <>
                    <Button
                      content="Осмотреться"
                      onClick={() =>
                        act('jump', {
                          ref: spawner.ref,
                        })}
                    />
                    <Button
                      content={!spawner.register_only
                        ? "Появиться"
                        : (!spawner.checked ? "Заявить" : "Отменить")}
                      selected={spawner.checked}
                      blocked={spawner.blocked}
                      onClick={() =>
                        act('spawn', {
                          ref: spawner.ref,
                        })}
                    />
                  </>
                )}>
                <LabeledList>
                  {spawner.time_left && (
                    <LabeledList.Item
                      label={spawner.time_type === 1 ? "Регистрация" : "Доступно"}
                      color={spawner.time_type === 1 ? "green" : "red"}
                    >
                      {formatTime(spawner.time_left)}
                    </LabeledList.Item>
                  )}
                  {!!spawner.register_only && (
                    <LabeledList.Item color="green" label="Кандидатов">
                      {spawner.registered_candidates}
                    </LabeledList.Item>
                  )}
                  <LabeledList.Item color="green" label="Позиций свободно">
                    {spawner.positions}
                  </LabeledList.Item>
                  {spawner.playing > 0 && (
                    <LabeledList.Item color="green" label="Играет">
                      {spawner.playing}
                    </LabeledList.Item>
                  )}
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
                      <a href="{spawner.wiki_ref}" target="_blank">{spawner.wiki_ref}</a>
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
