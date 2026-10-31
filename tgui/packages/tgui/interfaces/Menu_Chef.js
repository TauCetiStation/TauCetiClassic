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

export const Menu_Chef = (properties, context) => {
  const { act, data, static_data } = useBackend(context);
  const {
    linked_account,
    customer_menus,
    recipes_list,
    menu_items,
    orders,
    neworders,
  } = data;

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [recipes_type, setRecipesType] = useLocalState(
    context,
    'recipes_type',
    'menu_recipes'
  );

  let recipes;

  switch (recipes_type) {
    case 'orders':
      recipes = orders ? Object.groupBy(orders, (item) => item.table) : null;
      break;
    case 'menu_recipes':
      recipes = recipes_list
        ? Object.groupBy(
            Object.values(recipes_list)
              .flat()
              .filter((recipe) => recipe.result in menu_items),
            (item) => item.result
          )
        : null;
      break;
    default:
      recipes = recipes_list
        ? Object.groupBy(recipes_list[recipes_type], (item) => item.result)
        : null;
      break;
  }

  return (
    <Window width={550} height={450}>
      <Window.Content>
        <Section height="10%">
          <Flex direction="row" width="100%">
            <Flex.Item width="100%">
              <b>
                Linked Account:
                <NumberInput
                  width={'60px'}
                  animated={0}
                  step={1}
                  minValue={111111}
                  maxValue={999999}
                  stepPixelSize={1}
                  value={linked_account}
                  onChange={(_, value) =>
                    act('new_account_number', {
                      number: value,
                    })
                  }
                />
              </b>
            </Flex.Item>
            <Flex.Item width="100%">
              <b>
                Подключенные терминалы: {customer_menus ? customer_menus : 0}
              </b>
            </Flex.Item>
          </Flex>
        </Section>
        <Flex direction="row" width="100%" height="90%">
          <Flex.Item width="25%" position="relative">
            <Section fill>
              <Flex direction="column" width="100%" height="100%">
                <Flex.Item height="80%" width="100%">
                  <Button
                    height="80%"
                    width="100%"
                    verticalAlign="middle"
                    m="0"
                    textAlign="center"
                    bold
                    content={<p>Заказы {neworders ? `(+${neworders})` : ''}</p>}
                    selected={recipes_type === 'orders'}
                    onClick={() => {
                      setRecipesType('orders');
                      act('orders_opened');
                    }}
                  />
                </Flex.Item>
                <Flex.Item height="80%" width="100%">
                  <Button
                    height="80%"
                    width="100%"
                    verticalAlign="middle"
                    m="0"
                    textAlign="center"
                    bold
                    content={<p>Блюда в меню</p>}
                    selected={recipes_type === 'menu_recipes'}
                    onClick={() => setRecipesType('menu_recipes')}
                  />
                </Flex.Item>
                <Flex.Item height="80%" width="100%">
                  <Button
                    height="80%"
                    width="100%"
                    verticalAlign="middle"
                    textAlign="center"
                    bold
                    content={<p>Микроволновка</p>}
                    selected={recipes_type === 'microwave_recipes'}
                    onClick={() => setRecipesType('microwave_recipes')}
                  />
                </Flex.Item>
                <Flex.Item height="80%" width="100%">
                  <Button
                    height="80%"
                    width="100%"
                    verticalAlign="middle"
                    textAlign="center"
                    bold
                    content={<p>Печь</p>}
                    selected={recipes_type === 'oven_recipes'}
                    onClick={() => setRecipesType('oven_recipes')}
                  />
                </Flex.Item>
                <Flex.Item height="80%" width="100%">
                  <Button
                    height="80%"
                    width="100%"
                    verticalAlign="middle"
                    textAlign="center"
                    bold
                    content={<p>Гриль</p>}
                    selected={recipes_type === 'grill_recipes'}
                    onClick={() => setRecipesType('grill_recipes')}
                  />
                </Flex.Item>
                <Flex.Item height="75%" width="100%">
                  <Button
                    height="80%"
                    width="100%"
                    verticalAlign="middle"
                    textAlign="center"
                    bold
                    content={<p>Сладости</p>}
                    selected={recipes_type === 'candy_recipes'}
                    onClick={() => setRecipesType('candy_recipes')}
                  />
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>
          <Flex.Item width="80%" height="100%" position="relative">
            {recipes_type === 'orders' ? (
              <Section fill scrollable height="100%" title="Список заказов">
                {Object.keys(recipes).map((table, table_index) => (
                  <Section
                    textAlign="center"
                    key={`${table}:${table_index}`}
                    width="100%"
                    title={`Столик ${table}`}>
                    {recipes[table].map((order) => (
                      <>
                        <Flex direction="row" textAlign="start">
                          <Flex.Item width="100%" bold>
                            Заказ №{order.id}
                          </Flex.Item>
                          <Flex.Item width="10%">
                            <Button
                              icon="trash"
                              onClick={() =>
                                act('delete_order', {
                                  order_id: order.id,
                                })
                              }
                            />
                          </Flex.Item>
                        </Flex>
                        {Object.entries(order.order).map((item, index) => (
                          <p
                            textAlign="start"
                            width="100%"
                            key={`${item[0]}:${index}`}>
                            {item[0]} - {item[1]} шт.
                          </p>
                        ))}
                        <Divider />
                      </>
                    ))}
                  </Section>
                ))}
              </Section>
            ) : (
              <Section
                fill
                scrollable
                height="100%"
                title={
                  <Flex direction="row" width="100%">
                    <Flex.Item width="50%">Список рецептов</Flex.Item>
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
                {Object.keys(recipes)
                  .filter((obj) =>
                    obj.toLowerCase().includes(searchText.toLowerCase())
                  )
                  .map((recipe_name, recipe_index) => (
                    <Section
                      key={`${recipe_name}:${recipe_index}`}
                      width="100%"
                      title={
                        <Flex direction="row" width="100%">
                          <Flex.Item width="100%">{recipe_name}</Flex.Item>
                          <Flex.Item width="50%">
                            {recipe_name in menu_items && (
                              <NumberInput
                                width={'100%'}
                                animated={0}
                                step={1}
                                minValue={0}
                                maxValue={999}
                                stepPixelSize={1}
                                unit="$"
                                value={menu_items[recipe_name]}
                                onChange={(_, value) =>
                                  act('change_price', {
                                    item_name: recipe_name,
                                    item_price: value,
                                  })
                                }
                              />
                            )}
                          </Flex.Item>
                          <Flex.Item>
                            <Button
                              icon={
                                recipe_name in menu_items ? 'star' : 'star-o'
                              }
                              selected={recipe_name in menu_items}
                              onClick={() =>
                                act('add_to_menu', { item_name: recipe_name })
                              }
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
                            Ингредиент
                          </Table.Cell>
                          <Table.Cell
                            width="50%"
                            verticalAlign="middle"
                            bold="1"
                            textAlign="center">
                            Кол-во (шт./унц.)
                          </Table.Cell>
                        </Table.Row>
                        {recipes[recipe_name].map((recipe) => (
                          <>
                            {Object.keys(recipe.ingredients).map(
                              (ingredient, index) => (
                                <Table.Row
                                  height="25px"
                                  key={`${ingredient}:${index}`}>
                                  <Table.Cell
                                    verticalAlign="middle"
                                    textAlign="center">
                                    {ingredient}
                                  </Table.Cell>
                                  <Table.Cell
                                    verticalAlign="middle"
                                    textAlign="center">
                                    {recipe.ingredients[ingredient]}
                                  </Table.Cell>
                                </Table.Row>
                              )
                            )}
                            <Table.Cell colspan="2">
                              <Divider />
                            </Table.Cell>
                          </>
                        ))}
                      </Table>
                    </Section>
                  ))}
              </Section>
            )}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
