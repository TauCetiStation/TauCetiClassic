import { map } from 'common/collections';
import { useBackend } from '../backend';
import { Button, Flex, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const SmartFridge = (props, context) => {
  const { act, data } = useBackend(context);
  const contents = data.contents || {};
  const { locked, secure } = data;
  return (
    <Window width={520} height={640}>
      <Window.Content scrollable>
        {!!secure && (
          <NoticeBox>
            {locked === -1
              ? "Sec.re ACC_** //):securi_nt.diag=>##'or 1=1'%($..."
              : 'Secure Access: Please have your identification ready.'}
          </NoticeBox>
        )}
        <Section title="Storage">
          {contents.length ? (
            <LabeledList>
              {contents.map((item) => (
                <LabeledList.Item label="Vend" key={item.vend}>
                  <Flex align="center" justify="space-between">
                    <Flex.Item width="25%">
                      <Button
                        content="x1"
                        icon="circle-down"
                        onClick={() =>
                          act('vend', {
                            index: item.vend,
                            amount: 1,
                          })
                        }
                      />
                      {item.quantity > 5 && (
                        <Button
                          content="x5"
                          icon="circle-down"
                          onClick={() =>
                            act('vend', {
                              index: item.vend,
                              amount: 5,
                            })
                          }
                        />
                      )}
                      {item.quantity > 10 && (
                        <Button
                          content="x10"
                          icon="circle-down"
                          onClick={() =>
                            act('vend', {
                              index: item.vend,
                              amount: 10,
                            })
                          }
                        />
                      )}
                      {item.quantity > 25 && (
                        <Button
                          content="x25"
                          icon="circle-down"
                          onClick={() =>
                            act('vend', {
                              index: item.vend,
                              amount: 25,
                            })
                          }
                        />
                      )}
                      {item.quantity > 1 && (
                        <Button
                          content="All"
                          icon="circle-down"
                          onClick={() =>
                            act('vend', {
                              index: item.vend,
                              amount: item.quantity,
                            })
                          }
                        />
                      )}
                    </Flex.Item>
                    <Flex.Item>{item.display_name}</Flex.Item>
                    <Flex.Item italic width="20%" textAlign="right">
                      {item.quantity + ' available'}
                    </Flex.Item>
                  </Flex>
                  <LabeledList.Divider />
                </LabeledList.Item>
              ))}
            </LabeledList>
          ) : (
            'No products loaded.'
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
