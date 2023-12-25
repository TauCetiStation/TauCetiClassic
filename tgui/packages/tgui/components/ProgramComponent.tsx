/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Box, BoxProps, unit } from './Box';
import { Button } from './Button';
import { Flex } from './Flex';
import { Section } from './Section';
import { LineConnector, PositionTypes } from './LineConnector';
import { Component, findDOMNode, createRef, InfernoNode, RefObject } from 'inferno';
import { Input } from './Input';
import { NumberInput } from './NumberInput';

export class ProcessProgrammComponent extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const TypeComponent = GetTypeProgramComponent(this.props.component?.id_component)
    return (
        <TypeComponent act={this.props.act} selected_component={this.props.selected_component} component = {this.props.component}/>
    )
  }
}

export class ProgramComponent extends Component {
  next_component?: ProgramComponent;
  previous_component?: ProgramComponent;
  id_component?: string;
  description?: string;
  link_component?: string;
  refProgram : RefObject<HTMLDivElement>;
  x;
  y;
  width;
  height;
  childComponentsRef;
  deleted;

  constructor(props) {
    super(props)
    this.refProgram = null;

    this.updateProgramData()

    if(this.props.getObj != null){
      this.props.getObj(this)
    }
  }

  componentDidUpdate() {
    this.updateProgramData()
  }

  componentDidMount() {
    this.updateProgramData()
  }

  updateProgramData(){

    let component = this.props.component
    this.next_component = component?.next_component;
    this.previous_component = component?.previous_component;
    this.id_component = component?.id_component;
    this.link_component = component?.link_component;
    this.description = component?.description
    this.childComponentsRef ??= new Map<string, ProgramComponent>()
    this.getChildComponents()

    this.deleted = this.link_component == null ? true : false

    if (this.refProgram != null) {

      const rect = this.refProgram.getBoundingClientRect();

      this.x = rect.left
      this.y = rect.top
      this.width = rect.width
      this.height = rect.height
    }
  }

  setRef = (element) => {
    this.refProgram = element

    if(this.props.getRef != null){
      this.props.getRef(element)
    }
  }

  setNextComponentRef = (element : ProgramComponent) => {
    this.next_component = element
  }

  getLineObject(element : ProgramComponent, position1, position2){
    if(element == null){
      return
    }

    let x1 = this.x
    let y1 = this.y
    let width1 = this.width
    let height1 = this.height

    let x2 = element.x
    let y2 = element.y
    let width2 = element.width
    let height2 = element.height

    return (
      <LineConnector x1 = {x1} y1 = {y1} width1 = {width1} height1 = {height1} pos1 = {position1}
      x2 = {x2} y2 = {y2} width2 = {width2} height2 = {height2} pos2 = {position2} color="green" stroke_width={2}/>
    )
  }

  getButtonComponent(element : ProgramComponent, text, action){
    if(element == null){
      return "None"
    }
    return (
    <Button onClick={() => this.props.act(action, {
      link_component: element?.link_component,
    })}>
      {text}
    </Button>
    )
  }

  getObjectContent(){
    return(
      <div>
        DELETED: {this.deleted ? "YES" : "NO"}
        <br></br>
        ID COMPONENT: {this.id_component}
        <br></br>
        LINK: {this.getButtonComponent(this, "Select: " + this.link_component, "select_component")}
        <br></br>
        DESCRIPTION: {this.description}
        <br></br>
        SET_FIRST_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_first_component")}
        <br></br>
        SET_TARGET_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_target_component")}
        <br></br>
        INSERT_NEXT_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "insert_next_component")}
        <br></br>
        LINK Next Component: {this.getButtonComponent(this.next_component, "Select: " + this.next_component?.link_component, "select_component")}
        <br></br>
        LINK Previous Component: {this.getButtonComponent(this.previous_component, "Select: " + this.previous_component?.link_component, "select_component")}
        <br></br>
        {this.getButtonComponent(this, "DELETE YOURSELF NOW", "self_delete")}
      </div>
    )
  }

  getRenderObject(){
    let backgroundColor = "#000000"
    if(this.props.selected_component?.link_component == this.link_component){
      backgroundColor = "#228B22"
    }

    if(this.deleted){
      backgroundColor = "#CB2C31"
    }

    return (
      <div>
        <Section fitted={false} getObj = {this.setRef} fill={false} grow={1} backgroundColor={backgroundColor} m={5}>
            {this.deleted == true ? "Компоненты не существует" : this.getObjectContent()}
        </Section>
      </div>
    )
  }

  getRenderTree(){
    return (
      <Flex direction="column">
        <Flex direction="row">
          {this.getRenderObject()}
          {this.getNextComponent()}
          {this.getLineObject(this.props.parent, this.props.connect?.parent ?? null, this.props.connect?.child ?? null)}
        </Flex>
        {this.getChildComponents().map((element : ProgramComponent) => {
          if(element != null){
            const TypeComponent = GetTypeProgramComponent(element.id_component)
            return  (
              <TypeComponent act={this.props.act} parent={this} connect={{
                parent: PositionTypes.BottomCenter,
                child: PositionTypes.TopCenter
              }} component={element} selected_component={this.props.selected_component} getObj={this.setChildComponentRef}/>
            )
          }
        })}
      </Flex>
  )
  }

  getChildComponents(){
    return []
  }

  setChildComponentRef = (element : ProgramComponent) => {
    this.childComponentsRef.set(element.link_component, element);
  }

  getNextComponent(){
    if(this.next_component != null){
      const TypeComponent = GetTypeProgramComponent(this.next_component.id_component)
      return (
        <TypeComponent act={this.props.act} getObj = {this.setNextComponentRef} connect={{
          parent: PositionTypes.RightCenter,
          child: PositionTypes.LeftCenter
        }} parent = {this} selected_component={this.props.selected_component} component = {this.next_component}/>
      )
    }

    return null
  }

  render(){
    this.updateProgramData()

    if(this.props.onlyObject){
      return this.getRenderObject()
    }

    return this.getRenderTree()
  }
}

export class AwaiterProgramComponent extends ProgramComponent {
  checker_component?;
  waiting_component?;
  timeout_component?;
  signals_list?;

  constructor(props) {
    super(props)
  }

  updateProgramData(){
    super.updateProgramData()

    let component : AwaiterProgramComponent = this.props.component as AwaiterProgramComponent
    this.checker_component = component?.checker_component;
    this.waiting_component = component?.waiting_component;
    this.timeout_component = component?.timeout_component;
    this.signals_list = this.props.component?.signals_list;
  }

  getChildComponents(){
    let listComponents = []
    listComponents.push(this.checker_component)
    listComponents.push(this.waiting_component)
    listComponents.push(this.timeout_component)
    return listComponents
  }

  getObjectContent(){
    return (
        <div>
            WAIT: {this.getButtonComponent(this.waiting_component, "Select: " + this.waiting_component?.link_component, "select_component")}
            <br></br>
            SET_WAIT_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "change_waiting_component")}
            <br></br>
            TIMEOUT: {this.getButtonComponent(this.timeout_component, "Select: " + this.timeout_component?.link_component, "select_component")}
            <br></br>
            SET_TIMEOUT_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "change_timeout_component")}
            <br></br>
            CHECKER: {this.getButtonComponent(this.checker_component, "Select: " + this.checker_component?.link_component, "select_component")}
            <br></br>
            SET_CHECKER_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "change_checker_component")}
            <br></br>
            SIGNALS: {this.signals_list?.map((element) => {
              {element}
            })}
            <br></br>
            ID COMPONENT: {this.id_component}
            <br></br>
            DESCRIPTION: {this.description}
            <br></br>
            LINK: {this.getButtonComponent(this, "Select: " + this.link_component, "select_component")}
            <br></br>
            SET_FIRST_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_first_component")}
            <br></br>
            SET_TARGET_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_target_component")}
            <br></br>
            INSERT_NEXT_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "insert_next_component")}
            <br></br>
            LINK Next Component: {this.getButtonComponent(this.next_component, "Select: " + this.next_component?.link_component, "select_component")}
            <br></br>
            LINK Previous Component: {this.getButtonComponent(this.previous_component, "Select: " + this.previous_component?.link_component, "select_component")}
            <br></br>
            {this.getButtonComponent(this, "DELETE YOURSELF NOW", "self_delete")}
        </div>
    )
  }
}

export class DataProgramComponent extends ProgramComponent {
  data?;
  id_data?;

  constructor(props) {
    super(props)
  }

  updateProgramData(){
    super.updateProgramData()

    let component : DataProgramComponent = this.props.component as DataProgramComponent
    this.data = component?.data;
    this.id_data = component?.id_data;
  }

  getObjectContent(){
    return (
        <div>
            ID_DATA: {this.id_data}
            <br></br>
            VALUE: {this.data}
            <br></br>
            ID COMPONENT: {this.id_component}
            <br></br>
            DESCRIPTION: {this.description}
            <br></br>
            LINK: {this.getButtonComponent(this, "Select: " + this.link_component, "select_component")}
            <br></br>
            SET_FIRST_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_first_component")}
            <br></br>
            SET_TARGET_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_target_component")}
            <br></br>
            INSERT_NEXT_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "insert_next_component")}
            <br></br>
            LINK Next Component: {this.getButtonComponent(this.next_component, "Select: " + this.next_component?.link_component, "select_component")}
            <br></br>
            LINK Previous Component: {this.getButtonComponent(this.previous_component, "Select: " + this.previous_component?.link_component, "select_component")}
            <br></br>
            {this.getButtonComponent(this, "DELETE YOURSELF NOW", "self_delete")}
        </div>
    )
  }
}

export class DataStringProgramComponent extends DataProgramComponent {

  constructor(props) {
    super(props)
  }

  updateProgramData(){
    super.updateProgramData()

    let component : DataStringProgramComponent = this.props.component as DataStringProgramComponent
    this.data = component?.data;
    this.id_data = component?.id_data;
  }

  getTextBoxComponent(element : ProgramComponent, text, action){
    if(element == null){
      return "None"
    }
    return (
    <Input onInput={(e, value) => this.props.act(action, {
      link_component: element?.link_component,
      data_change: value
    })}>
      {text}
    </Input>
    )
  }

  getObjectContent(){
    return (
        <div>
            ID_DATA: {this.id_data}
            <br></br>
            VALUE: {this.data}
            <br></br>
            TEXTBOX_DATA_CHANGE: {this.getTextBoxComponent(this, "", "set_data")}
            <br></br>
            ID COMPONENT: {this.id_component}
            <br></br>
            DESCRIPTION: {this.description}
            <br></br>
            LINK: {this.getButtonComponent(this, "Select: " + this.link_component, "select_component")}
            <br></br>
            SET_FIRST_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_first_component")}
            <br></br>
            SET_TARGET_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_target_component")}
            <br></br>
            INSERT_NEXT_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "insert_next_component")}
            <br></br>
            LINK Next Component: {this.getButtonComponent(this.next_component, "Select: " + this.next_component?.link_component, "select_component")}
            <br></br>
            LINK Previous Component: {this.getButtonComponent(this.previous_component, "Select: " + this.previous_component?.link_component, "select_component")}
            <br></br>
            {this.getButtonComponent(this, "DELETE YOURSELF NOW", "self_delete")}
        </div>
    )
  }
}

export class DataNumberProgramComponent extends DataProgramComponent {

  constructor(props) {
    super(props)
  }

  updateProgramData(){
    super.updateProgramData()

    let component : DataNumberProgramComponent = this.props.component as DataNumberProgramComponent
    this.data = component?.data;
    this.id_data = component?.id_data;
  }

  getNumberBoxComponent(element : ProgramComponent, text, action){
    if(element == null){
      return "None"
    }
    return (
    <NumberInput value={this.data} onChange={(e, value) => this.props.act(action, {
      link_component: element?.link_component,
      data_change: value
    })}>
      {text}
    </NumberInput>
    )
  }

  getObjectContent(){
    return (
        <div>
            ID_DATA: {this.id_data}
            <br></br>
            VALUE: {this.data}
            <br></br>
            NUMBERBOX_DATA_CHANGE: {this.getNumberBoxComponent(this, "", "set_data")}
            <br></br>
            ID COMPONENT: {this.id_component}
            <br></br>
            DESCRIPTION: {this.description}
            <br></br>
            LINK: {this.getButtonComponent(this, "Select: " + this.link_component, "select_component")}
            <br></br>
            SET_FIRST_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_first_component")}
            <br></br>
            SET_TARGET_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_target_component")}
            <br></br>
            INSERT_NEXT_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "insert_next_component")}
            <br></br>
            LINK Next Component: {this.getButtonComponent(this.next_component, "Select: " + this.next_component?.link_component, "select_component")}
            <br></br>
            LINK Previous Component: {this.getButtonComponent(this.previous_component, "Select: " + this.previous_component?.link_component, "select_component")}
            <br></br>
            {this.getButtonComponent(this, "DELETE YOURSELF NOW", "self_delete")}
        </div>
    )
  }
}

export class CheckerProgramComponent extends ProgramComponent {
  fail_component?;
  success_component?;

  constructor(props) {
    super(props)
  }

  updateProgramData(){
    super.updateProgramData()

    let component : CheckerProgramComponent = this.props.component as CheckerProgramComponent
    this.fail_component = component?.fail_component;
    this.success_component = component?.success_component;
  }

  getObjectContent(){
    return (
        <div>
            <br></br>
            ID COMPONENT: {this.id_component}
            <br></br>
            DESCRIPTION: {this.description}
            <br></br>
            LINK: {this.getButtonComponent(this, "Select: " + this.link_component, "select_component")}
            <br></br>
            SET_FIRST_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_first_component")}
            <br></br>
            SET_TARGET_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_target_component")}
            <br></br>
            INSERT_NEXT_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "insert_next_component")}
            <br></br>
            LINK Next Component: {this.getButtonComponent(this.next_component, "Select: " + this.next_component?.link_component, "select_component")}
            <br></br>
            LINK Previous Component: {this.getButtonComponent(this.previous_component, "Select: " + this.previous_component?.link_component, "select_component")}
            <br></br>
            {this.getButtonComponent(this, "DELETE YOURSELF NOW", "self_delete")}
        </div>
    )
  }
}

export class ProcProgramComponent extends ProgramComponent {
  using_data?;

  constructor(props) {
    super(props)
  }

  updateProgramData(){
    super.updateProgramData()

    let component : ProcProgramComponent = this.props.component as ProcProgramComponent
    this.using_data = component?.using_data;
  }

  getObjectContent(){
    return (
        <div>
            <br></br>
            ID COMPONENT: {this.id_component}
            <br></br>
            DESCRIPTION: {this.description}
            <br></br>
            LINK: {this.getButtonComponent(this, "Select: " + this.link_component, "select_component")}
            <br></br>
            SET_FIRST_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_first_component")}
            <br></br>
            SET_TARGET_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_target_component")}
            <br></br>
            INSERT_NEXT_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "insert_next_component")}
            <br></br>
            LINK Next Component: {this.getButtonComponent(this.next_component, "Select: " + this.next_component?.link_component, "select_component")}
            <br></br>
            LINK Previous Component: {this.getButtonComponent(this.previous_component, "Select: " + this.previous_component?.link_component, "select_component")}
            <br></br>
            {this.getButtonComponent(this, "DELETE YOURSELF NOW", "self_delete")}
        </div>
    )
  }
}

export class ProcForCycleProgramComponent extends ProcProgramComponent {
  using_data?;
  cycle_component?;

  constructor(props) {
    super(props)
  }

  updateProgramData(){
    super.updateProgramData()

    let component : ProcForCycleProgramComponent = this.props.component as ProcForCycleProgramComponent
    this.cycle_component = component?.cycle_component;
  }

  getChildComponents(){
    let listComponents = []
    listComponents.push(this.cycle_component)
    return listComponents
  }

  getObjectContent(){
    return (
        <div>
            <br></br>
            ID COMPONENT: {this.id_component}
            <br></br>
            DESCRIPTION: {this.description}
            <br></br>
            LINK: {this.getButtonComponent(this, "Select: " + this.link_component, "select_component")}
            <br></br>
            SET_CYCLE_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_cycle_component")}
            <br></br>
            SET_FIRST_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_first_component")}
            <br></br>
            SET_TARGET_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "set_target_component")}
            <br></br>
            INSERT_NEXT_COMPONENT: {this.getButtonComponent(this, "Set: " + this.link_component, "insert_next_component")}
            <br></br>
            LINK Next Component: {this.getButtonComponent(this.next_component, "Select: " + this.next_component?.link_component, "select_component")}
            <br></br>
            LINK Previous Component: {this.getButtonComponent(this.previous_component, "Select: " + this.previous_component?.link_component, "select_component")}
            <br></br>
            {this.getButtonComponent(this, "DELETE YOURSELF NOW", "self_delete")}
        </div>
    )
  }
}


export const ProgramComponentTypesMap = {
  "pipe_system_awaiter" : AwaiterProgramComponent,
  "pipe_system_default" : ProgramComponent,
  "pipe_system_data" : DataProgramComponent,
  "pipe_system_checker" : CheckerProgramComponent,
  "pipe_system_proc_for_cycle" : ProcForCycleProgramComponent,
  "pipe_system_proc" : ProcProgramComponent,
  "pipe_system_data_string" : DataStringProgramComponent,
  "pipe_system_data_number" : DataNumberProgramComponent,
  "pipe_system_data_ref" : DataProgramComponent,
}

export const GetTypeProgramComponent = (id_component) =>{
  const TypeComponent = ProgramComponentTypesMap[id_component] || ProgramComponent
  return TypeComponent;
}

