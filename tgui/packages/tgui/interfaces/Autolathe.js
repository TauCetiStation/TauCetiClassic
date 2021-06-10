import { round } from 'common/math';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { Fragment } from 'inferno';
import { useBackend, useSharedState } from "../backend";
import { Box, Button, Flex, Icon, Input, LabeledList, ProgressBar, Section, Dropdown } from "../components";
import { Window } from "../layouts";
import { Materials } from "./ExosuitFabricator";
import { createSearch, toTitleCase } from 'common/string';

const canBeMade = (recipe, materials) => {
  if (recipe.requirements === null) {
    return true;
  }

  let recipeRequiredMaterials = Object.keys(recipe.requirements);

  for (let mat_id of recipeRequiredMaterials) {
    let material = materials.find(val => val.name === mat_id);
    if (!material) {
      continue; // yes, if we cannot find the material, we just ignore it :V
    }
    if (material.amount < recipe.requirements[mat_id]) {
      return false;
    }
  }

  return true;
};

export const Autolathe = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    recipes,
    busy,
    materials,
    categories,
  } = data;
  
  const [category, setCategory] = useSharedState(context, "category", 0);

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, "search_text", "");

  const testSearch = createSearch(searchText, recipe => recipe.name);

  const recipesToShow = flow([
    filter(recipe => recipe.category === categories[category]),
    searchText && filter(testSearch),
    sortBy(recipe => recipe.name.toLowerCase()),
  ])(recipes);

  return (
    <Window width={550} height={700}>
      <Window.Content scrollable>
        <Section title="Materials">
          <Materials disableEject />
        </Section>
        <Section title="Recipes" buttons={
          <Dropdown
            width="190px"
            options={categories}
            selected={categories[category]}
            onSelected={val => setCategory(categories.indexOf(val))} />
        }>
          <Input
            fluid
            placeholder="Search for..."
            onInput={(e, v) => setSearchText(v)}
            mb={1} />
          {recipesToShow.map(recipe => (
            <Flex justify="space-between" align="center" key={recipe.ref}>
              <Flex.Item>
                <Button
                  color={recipe.hidden && "red" || null}
                  icon="hammer"
                  iconSpin={busy === recipe.name}
                  disabled={!canBeMade(recipe, materials)}
                  onClick={() => act("make", { make: recipe.ref })}>
                  {toTitleCase(recipe.name)}
                </Button>
              </Flex.Item>
              <Flex.Item>
                {recipe.requirements && (
                  Object
                    .keys(recipe.requirements)
                    .map(mat => toTitleCase(mat) + ": " + recipe.requirements[mat])
                    .join(", ")
                ) || (
                  <Box>
                    No resources required.
                  </Box>
                )}
              </Flex.Item>
            </Flex>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};