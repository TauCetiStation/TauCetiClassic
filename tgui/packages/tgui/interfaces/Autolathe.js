import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { useBackend, useSharedState } from "../backend";
import { Box, Button, Flex, Input, Tooltip, Section, Dropdown, Icon } from "../components";
import { Window } from "../layouts";
import { createSearch, toTitleCase } from 'common/string';
import { classes } from 'common/react';
import { formatSiUnit, formatMoney } from '../format';
import { toFixed } from 'common/math';

export const Autolathe = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    recipes,
    busy,
    materials,
    categories,
    coeff,
  } = data;

  const [category, setCategory] = useSharedState(context, "category", 0);

  const [searchText, setSearchText] = useSharedState(context, "searchText", "");

  const testSearch = createSearch(searchText, recipe => recipe.name);

  const recipesToShow = flow([
    filter(recipe => recipe.category === categories[category]
      || categories[category] === "All"),
    searchText && filter(testSearch),
    sortBy(recipe => recipe.name.toLowerCase()),
  ])(recipes);

  const categorieToShow = flow([
    sortBy(category => category.toLowerCase()),
  ])(categories);

  return (
    <Window width={550} height={700}>
      <Window.Content scrollable>
        <Section title="Materials">
          <Flex wrap="wrap">
            <Materials />
          </Flex>
        </Section>
        <Section title="Recipes" buttons={
          <Dropdown
            width="190px"
            options={categorieToShow}
            selected={categories[category]}
            onSelected={val => setCategory(categories.indexOf(val))} />
        }>
          <Input
            autoFocus
            fluid
            placeholder="Search for..."
            onInput={(e, v) => setSearchText(v)}
            mb={1} />
          {recipesToShow.map(recipe => (
            <Flex justify="space-between" align="center" key={recipe.ref}>
              <Flex.Item mr={1}>
                <span
                  className={classes([
                    'autolathe32x32',
                    recipe.path,
                  ])}
                  style={{
                    'vertical-align': 'middle',
                    'horizontal-align': 'middle',
                  }} />
              </Flex.Item>
              <Flex.Item grow={1}>
                <Button
                  color={recipe.hidden && "red" || null}
                  icon="hammer"
                  iconSpin={busy === recipe.name}
                  disabled={!canBeMade(recipe, materials)}
                  onClick={() => act("make", { make: recipe.ref })}>
                  {toTitleCase(recipe.name)}
                </Button>
                {recipe.max_mult > 1 && (
                  <Box as="span">
                    {[5, 10, (recipe.max_mult / 2) >> 0, recipe.max_mult]
                      .map(mult => MultButton(recipe, materials, act, mult))}
                  </Box>
                )}
              </Flex.Item>
              <Flex.Item width="30%">
                <Flex direction="row" visibility="collapse">
                  {recipe.requirements && (
                    Object
                      .keys(recipe.requirements)
                      .map(mat => (
                        <Flex width="100%" key={mat}>
                          {recipe.requirements[mat] > 0 && (
                            <MaterialAmount
                              name={mat}
                              amount={recipe.requirements[mat] / coeff}
                              formatsi
                              csspath={materials.find(val =>
                                val.name === mat).path}
                              width="50%"
                            />) || (<Flex width="50%" />)}
                        </Flex>
                      ))
                  ) || (
                    <Box>
                      No resources required.
                    </Box>
                  )}
                </Flex>
              </Flex.Item>
            </Flex>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

const MaterialAmount = (props, context) => {
  const {
    name,
    csspath,
    amount,
    color,
    style,
    direction,
    width,
    formatsi,
    formatmoney,
  } = props;

  let amountDisplay = "0";
  if (amount < 1 && amount > 0) {
    amountDisplay = toFixed(amount, 2);
  } else if (formatsi) {
    amountDisplay = formatSiUnit(amount, 0).replace(" ", "");
  } else if (formatmoney) {
    amountDisplay = formatMoney(amount);
  } else {
    amountDisplay = amount;
  }
  return (
    <Flex
      direction={direction}
      align="center"
      width={width}>
      <Flex.Item>
        <Box
          className={classes([
            'sheetmaterials32x32',
            csspath,
          ])}
          position="relative"
          style={style}>
          <Tooltip
            position="bottom"
            content={toTitleCase(name)} />
        </Box>
      </Flex.Item>
      <Flex.Item>
        <Box
          textColor={color}
          style={{ "text-align": "center" }}>
          {amountDisplay}
        </Box>
      </Flex.Item>
    </Flex>
  );
};

const canBeMade = (recipe, materials, mult = 1) => {
  if (recipe.requirements === null) {
    return true;
  }

  let recipeRequiredMaterials = Object.keys(recipe.requirements);

  for (let mat_id of recipeRequiredMaterials) {
    let material = materials.find(val => val.name === mat_id);
    if (!material) {
      continue; // yes, if we cannot find the material, we just ignore it :V
    }
    if (material.amount < (recipe.requirements[mat_id] * mult)) {
      return false;
    }
  }

  return true;
};

const MultButton = (recipe, materials, act, mult) => {
  if (mult <= recipe.max_mult) {
    return (
      <Button
        color={recipe.hidden && "red" || null}
        disabled={!canBeMade(recipe, materials, mult)}
        onClick={() => act("make", { make: recipe.ref, multiplier: mult })}>
        x{mult}
      </Button>
    );
  }
};

export const Materials = (props, context) => {
  const { data } = useBackend(context);

  const {
    displayAllMat,
  } = props;
  const materials = data.materials || [];
  let display_materials = materials.filter(mat => displayAllMat
    || mat.amount > 0);

  if (display_materials.length === 0) {
    return (
      <Box width="100%" textAlign="center">
        <Icon textAlign="center" size={5} name="inbox" />
        <br />
        <b>No Materials Loaded.</b>
      </Box>
    );
  }

  return (
    <Flex
      wrap="wrap">
      {display_materials.map(material => (
        <Flex.Item
          width="80px"
          key={material.name}>
          <MaterialAmount
            name={material.name}
            amount={material.amount}
            csspath={material.path}
            formatsi
            direction="column" />
          <Box
            mt={1}
            style={{ "text-align": "center" }} />
        </Flex.Item>
      ) || null)}
    </Flex>
  );
};
