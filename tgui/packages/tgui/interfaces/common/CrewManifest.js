import { useBackend } from "../../backend";
import { Box, Section, Table } from "../../components";
import { decodeHtmlEntities } from 'common/string';
import { COLORS } from "../../constants";


const deptCols = COLORS.department;

const HeadRoles = [
  "Captain",
  "Head of Security",
  "Chief Engineer",
  "Chief Medical Officer",
  "Research Director",
  "Head of Personnel",
];
// Head colour check. Abbreviated to save on 80 char
const HCC = role => {
  // Return green if they are the head
  if (HeadRoles.indexOf(role) !== -1) {
    return "green";
  }
  // Return yellow if its the qm
  if (role === "Quartermaster") {
    return "yellow";
  }
  // Return orange if its a regular person
  return "orange";
};

// Head bold check. Abbreviated to save on 80 char
const HBC = role => {
  // Return true if they are a head, or a QM
  if ((HeadRoles.indexOf(role) !== -1) || role === "Quartermaster") {
    return true;
  } else {
    return false;
  }
};

const ManifestTable = group => {
  return (
    group > 0 && (
      <Table>
        <Table.Row header color="white">
          <Table.Cell width="50%">Name</Table.Cell>
          <Table.Cell width="35%">Rank</Table.Cell>
          <Table.Cell width="15%">Active</Table.Cell>
        </Table.Row>
        {group.map(person => (
          <Table.Row
            color={HCC(person.rank)}
            key={person.name + person.rank}
            bold={HBC(person.rank)}>
            <Table.Cell>{decodeHtmlEntities(person.name)}</Table.Cell>
            <Table.Cell>{decodeHtmlEntities(person.rank)}</Table.Cell>
            <Table.Cell>{person.active}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    )
  );
};

export const CrewManifest = (props, context) => {
  const { act } = useBackend(context);
  let finalData;
  if (props.data) {
    finalData = props.data;
  } else {
    let { data } = useBackend(context);
    finalData = data;
  }

  const {
    manifest,
  } = finalData;

  const {
    heads,
    sec,
    eng,
    med,
    sci,
    civ,
    misc,
  } = manifest;

  return (
    <Box>
      <Section
        title={(
          <Box backgroundColor={deptCols.captain} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Command
            </Box>
          </Box>
        )}
        level={2}>
        {ManifestTable(heads)}
      </Section>
      <Section
        title={(
          <Box backgroundColor={deptCols.security} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Security
            </Box>
          </Box>
        )}
        level={2}>
        {ManifestTable(sec)}
      </Section>
      <Section
        title={(
          <Box backgroundColor={deptCols.engineering} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Engineering
            </Box>
          </Box>
        )}
        level={2}>
        {ManifestTable(eng)}
      </Section>
      <Section
        title={(
          <Box backgroundColor={deptCols.medbay} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Medical
            </Box>
          </Box>
        )}
        level={2}>
        {ManifestTable(med)}
      </Section>
      <Section
        title={(
          <Box backgroundColor={deptCols.science} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Science
            </Box>
          </Box>
        )}
        level={2}>
        {ManifestTable(sci)}
      </Section>
      <Section
        title={(
          <Box backgroundColor={deptCols.other} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Civilian
            </Box>
          </Box>
        )}
        level={2}>
        {ManifestTable(civ)}
      </Section>
      <Section
        title={(
          <Box m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Misc
            </Box>
          </Box>
        )}
        level={2}>
        {ManifestTable(misc)}
      </Section>
    </Box>
  );
};
