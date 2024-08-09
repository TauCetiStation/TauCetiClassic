import { useBackend } from "../../backend";
import { Box, Section, Table } from "../../components";
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
  if (HeadRoles.indexOf(role) !== -1 || role === "Internal Affairs Agent") {
    return "green";
  }
  // Return yellow if its the qm
  if (role === "Quartermaster") {
    return "yellow";
  }
  // Return orange if its a regular person
  return "orange";
};

// Head bold check. Abbreviated to save on 80 char. Return true if they are a head, or a QM/IAA
const HBC = role => (HeadRoles.indexOf(role) !== -1 || role === "Quartermaster" || role === "Internal Affairs Agent");

const ManifestTable = group => {

  if (!group || group.length === 0) {
    return null;
  }

  return (
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
          <Table.Cell>{person.name}</Table.Cell>
          <Table.Cell>{person.rank}</Table.Cell>
          <Table.Cell>{person.active}</Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

export const CrewManifest = (props, context) => {
  const { act } = useBackend(context);
  const { manifest } = props;
  const { heads, centcom, sec, eng, med, sci, civ, misc } = manifest;
  const renderSection = (title, color, data) => (
    <Section
      title={(
        <Box backgroundColor={color} m={-1} pt={1} pb={1}>
          <Box ml={1} textAlign="center" fontSize={1.4}>
            {title}
          </Box>
        </Box>
      )}
      level={2}>
      {ManifestTable(data)}
    </Section>
  );

  return (
    <Box>
      {renderSection("Command", deptCols.captain, heads)}
      {renderSection("NanoTrasen Representatives", deptCols.ntrep, centcom)}
      {renderSection("Security", deptCols.security, sec)}
      {renderSection("Engineering", deptCols.engineering, eng)}
      {renderSection("Medical", deptCols.medbay, med)}
      {renderSection("Science", deptCols.science, sci)}
      {renderSection("Civilian", deptCols.other, civ)}
      {renderSection("Misc", null, misc)}
    </Box>
  );
};
