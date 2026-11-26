import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Table,
  Divider,
} from '../components';
import { Window } from '../layouts';

export const Menu_Customer = (properties, context) => {
  const { act, data, static_data } = useBackend(context);
  const { mode, menu, items_to_order, payment_timer } = data;

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  let dishes = menu
    ? Object.entries(menu).filter(([entry]) =>
        entry.toLowerCase().includes(searchText.toLowerCase())
      )
    : null;

  let sum = items_to_order
    ? Object.entries(items_to_order).reduce(
        (acc, arr) => acc + arr[1] * menu[arr[0]],
        0
      )
    : 0;

  return (
    <Window width={450} height={300}>
      <Window.Content>
        {payment_timer ? (
          <Section
            fill
            textAlign="center"
            scrollable
            height="85%"
            title="Приложите карту к терминалу">
            <b>
              Отмена транзакции через: {Math.round(payment_timer / 10)} с<br />
              <br />
            </b>
            {mode === 'Mode_EnterPin' && (
              <b>
                Введите ПИН-код
                <NumberInput
                  width={'80%'}
                  animated={0}
                  step={1}
                  minValue={1111}
                  maxValue={9999}
                  stepPixelSize={1}
                  value={1111}
                  onChange={(_, value) =>
                    act('enterpin', {
                      pin: value,
                    })
                  }
                />
              </b>
            )}
          </Section>
        ) : (
          <>
            <Section
              fill
              scrollable
              height="85%"
              title={
                <Flex direction="row" width="100%">
                  <Flex.Item width="50%">Доступные блюда</Flex.Item>
                  <Flex.Item width="50%">
                    <Input
                      placeholder="Поиск..."
                      autoFocus
                      fluid
                      value={''}
                      onInput={(_, value) => setSearchText(value)}
                    />
                  </Flex.Item>
                </Flex>
              }>
              <Table>
                <Table.Row header>
                  <Table.Cell
                    width="50%"
                    verticalAlign="middle"
                    bold="1"
                    textAlign="center">
                    Блюдо
                  </Table.Cell>
                  <Table.Cell
                    width="10%"
                    verticalAlign="middle"
                    bold="1"
                    textAlign="center">
                    Цена
                  </Table.Cell>
                  <Table.Cell
                    width="50%"
                    verticalAlign="middle"
                    bold="1"
                    textAlign="center">
                    Кол-во
                  </Table.Cell>
                </Table.Row>
                {dishes.map((dish, dish_index) => (
                  <Table.Row height="25px" key={`${dish[0]}:${dish_index}`}>
                    <Table.Cell verticalAlign="middle" textAlign="center">
                      {dish[0]}
                    </Table.Cell>
                    <Table.Cell verticalAlign="middle" textAlign="center">
                      {dish[1]}$
                    </Table.Cell>
                    <Table.Cell verticalAlign="middle" textAlign="center">
                      <Button
                        icon="minus"
                        onClick={() =>
                          act('remove_from_oders', { item_name: dish[0] })
                        }
                      />
                      <b>
                        {items_to_order[dish[0]] ? items_to_order[dish[0]] : 0}
                      </b>
                      <Button
                        icon="plus"
                        onClick={() =>
                          act('add_to_orders', { item_name: dish[0] })
                        }
                      />
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
            <Section textAlign="center">
              <Flex direction="row" width="100%" justify="space-around">
                <Flex.Item>
                  <b>Итого: {sum}$</b>
                </Flex.Item>
                <Flex.Item>
                  <Button
                    content="Оплатить"
                    icon="shopping-cart"
                    onClick={() => act('order')}
                  />
                </Flex.Item>
              </Flex>
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
