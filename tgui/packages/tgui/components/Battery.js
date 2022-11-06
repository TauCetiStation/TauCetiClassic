import { Box } from './Box';


export const Battery = props => {
  const {
    charge,
    battery_width,
    battery_height,
    border_color,
    ...rest
  } = props;
  
  const cap_width = battery_width * 0.05;
  const cap_height = battery_height * 0.5;

  const border_width = battery_height * 0.1;
  const border_gap = battery_height * 0.05;
  
  const element_height = battery_height * 0.75;
  const element_width = (battery_width-2*border_width-2*border_gap-cap_width) / 14.5;
  const element_gap = element_width / 2;
  
  const elements_list = [
    "#Aa1919",
    "#Aa1919",
    "#E8b327",
    "#E8b327",
    "#E8b327",
    "#43bf45",
    "#43bf45",
    "#43bf45",
    "#43bf45",
    "#4386bf",
  ];

  return (
    <Box width={battery_width+"px"} height={battery_height+"px"} position="relative" {...rest}>
      <Box width={battery_width-cap_width+"px"} height={border_width+"px"} backgroundColor={border_color} position="absolute" />
      
      <Box width={border_width+"px"} height={battery_height+"px"} backgroundColor={border_color} position="absolute" />
      
      {elements_list.map((element_color, index) => (
        <Box key={index} width={element_width+"px"} height={element_height+"px"} position="absolute" top={border_width+border_gap+"px"} left={border_width+border_gap+index*(element_width+element_gap)+"px"} backgroundColor={charge >= (index+1)*10 ? element_color : "#111111"} />
      ))}
      
      <Box width={border_width+"px"} height={battery_height+"px"} backgroundColor={border_color} position="absolute" left={battery_width-cap_width-border_width+"px"} />
      
      <Box width={cap_width+"px"} height={cap_height+"px"} backgroundColor={border_color} position="absolute" left={battery_width-cap_width+"px"} top={cap_height*0.5+"px"} />
      
      <Box width={battery_width-cap_width+"px"} height={border_width+"px"} backgroundColor={border_color} position="absolute" top={border_width+2*border_gap+element_height+"px"} />
    </Box>
  );
};
