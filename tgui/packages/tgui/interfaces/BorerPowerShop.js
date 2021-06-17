import { useBackend } from '../backend';
import { Box, Button, Collapsible, Section } from '../components';
import { Window } from '../layouts';

export const BorerPowerShop = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    points,
    upgrades,
  } = data;
  return (
    <Window title={"Borer Evolution"}>
      <Window.Content scrollable>
        <Section title={`Evolution points: ${ points }`}>
          {
            upgrades.map(params => (
              <Collapsible 
	              title={`${ params.name }`} 
                color={params.bought ? "good" : null}
		            buttons={(
                  <Button 
                    content={`Buy (${ params.cost })`}
                    disabled={params.bought || !params.has_requirements}
		                onClick={() => act("buy", {name: params.name})}
                  />
              )}>
		            {(params.chemicals || params.cooldown) ? (
                  <Box>
                    {
		                  (params.chemicals ? "Chemicals: " + params.chemicals + " units." : "") + 
		                  (params.cooldown ? "Cooldown: " + (params.cooldown / 10) + " seconds." : "")
                    }
                  </Box>
		            ) : null}
                <Box>{params.desc}</Box>
                {params.requirements.length ? (
                  <Box>{`This upgrade requires ${ params.requirements.join(", ") }.`}</Box>
                ) : null}
	      </Collapsible>
            ))
          }
        </Section>
      </Window.Content>
    </Window>
  );
};