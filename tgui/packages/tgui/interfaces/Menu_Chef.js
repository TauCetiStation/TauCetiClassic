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
  const { mode, linked_account, customer_menus, recipes_list, menu_items, orders, neworders } = data;

  const [searchText, setSearchText] = useLocalState(context, 'searchText', "");

  const recipes = recipes_list ? Object.groupBy(recipes_list, (item) => item.result) : null;

  return (
    <Window width={550} height={450}>
      <Window.Content>
        <Section height="10%">
          <LabeledList>
            <LabeledList.Item label="Linked Account">
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
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Flex direction="row" width="100%" height="90%">
        <Flex.Item width="25%" position="relative">
        <Section fill>
          <Flex direction="column" width="100%" height="100%">
          <Flex.Item height="80%" width="100%">
          <Button
              height="80%" width="100%" verticalAlign="middle" textAlign="center" bold
              content={'Микроволновка'}
              onClick={() => act('switch_recipe_type', { recipe_type: "microwave_recipes" })}
            />
          </Flex.Item>
          <Flex.Item height="80%" width="100%">
          <Button
              height="80%" width="100%" verticalAlign="middle" textAlign="center" bold
              content={'Печь'}
              onClick={() => act('switch_recipe_type', { recipe_type: "oven_recipes" })}
            />
          </Flex.Item>
          <Flex.Item height="80%" width="100%">
          <Button
              height="80%" width="100%" verticalAlign="middle" textAlign="center" bold
              content={'Гриль'}
              onClick={() => act('switch_recipe_type', { recipe_type: "grill_recipes" })}
            />
          </Flex.Item>
          <Flex.Item height="75%" width="100%">
          <Button
              height="80%" width="100%" verticalAlign="middle" textAlign="center" bold
              content={'Сладости'}
              onClick={() => act('switch_recipe_type', { recipe_type: "candy_recipes" })}
            />
          </Flex.Item>
          </Flex>
        </Section>
        </Flex.Item>
        <Flex.Item width="80%" height="100%" position="relative">
        <Section fill scrollable height="100%" title={
                <Flex direction="row" width="100%">
                  <Flex.Item width="50%">
                    Recipes list
                  </Flex.Item>
                  <Flex.Item width="50%">
                    <Input
                placeholder="Search..."
                autoFocus
                fluid
                value={""}
                onInput={(_, value) => setSearchText(value)}
                    />
                  </Flex.Item>
                </Flex>
              }>
          {Object.keys(recipes).filter(obj => obj.toLowerCase().includes(searchText.toLowerCase())).map((recipe_name) => (
          <Section width="100%" title={
             <Flex direction="row" width="100%">
                  <Flex.Item width="100%">
                    {recipe_name}
                  </Flex.Item>
                  <Flex.Item width="50%">
                    <NumberInput
                width={"100%"}
                animated={0}
                step={1}
                minValue={0}
                maxValue={999}
                stepPixelSize={1}
                unit="$"
                value={linked_account}
                onChange={(_, value) =>
                  act('set_price', {
                    item_name: value,
                  })
                }
              />
                  </Flex.Item>
                  <Flex.Item>
                    <Button
              icon="star-o"
              onClick={() => act('add_to_menu', { item_name: {recipe_name}, item_price: 100 })}
            />
                  </Flex.Item>
                </Flex>
              }>
            <Table>
              <Table.Row header>
                <Table.Cell width="50%" verticalAlign="middle" bold="1" textAlign="center">Ингредиент</Table.Cell>
                <Table.Cell width="50%" verticalAlign="middle" bold="1" textAlign="center">Кол-во (шт./унц.)</Table.Cell>
              </Table.Row>
          {recipes[recipe_name].map((recipe, recipe_index) => (
            <>
            {Object.keys(recipe.ingredients).map((ingredient, index) => (
              <Table.Row height="25px">
                  <Table.Cell verticalAlign="middle" textAlign="center">
                    {ingredient}
                  </Table.Cell>
                  <Table.Cell verticalAlign="middle" textAlign="center">
                    {recipe.ingredients[ingredient]}
                  </Table.Cell>
              </Table.Row>
            ))}
            <Table.Cell colspan="2">
            <Divider/>
            </Table.Cell>
            </>
          ))}</Table></Section>
          ))}
        </Section>
        </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
