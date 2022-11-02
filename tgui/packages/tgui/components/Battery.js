import { Box } from './Box';
import { classes } from 'common/react';


export const Battery = props => {
  const {
    charge,
    className,
    ...rest
  } = props;
  return (
    <Box className={classes(['Battery', className])} width="120px" height="40px" {...rest}>
      <Box width="120px" height="5px" className="Battery__Highlight" top="-12px" />
      <Box width={charge/100*120+"px"} height="40px" className="Battery__Indicator" top="-20px" />
      <Box width={charge/100*120+"px"} height="5px" className="Battery__Indicator__Highlight" top="-57px" />
      <Box width="5px" height="12px" className="Battery__Cap" top="-65px" left="115px" />
      <Box width="5px" height="12px" className="Battery__Cap" top="-48px" left="115px" />
    </Box>
  );
};
