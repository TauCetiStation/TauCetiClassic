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

export class ProcessProgrammComponent extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const TypeComponent = GetTypeProgramComponent(this.props.component?.id_component)
    return (
      <Flex direction="column">
        <TypeComponent act={this.props.act} selected_component={this.props.selected_component} component = {this.props.component}/>
      </Flex>
    )
  }
}

export class ProgramComponent extends Component {
  next_component?: ProgramComponent;
  previous_component?: ProgramComponent;
  id_component?: string;
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
            {this.deleted == true ? "Компонент не существует" : this.getObjectContent()}
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
            TIMEOUT: {this.getButtonComponent(this.timeout_component, "Select: " + this.timeout_component?.link_component, "select_component")}
            <br></br>
            CHECKER: {this.getButtonComponent(this.checker_component, "Select: " + this.checker_component?.link_component, "select_component")}
            <br></br>
            SIGNALS: {this.signals_list?.map((element) => {
              {element}
            })}
            <br></br>
            ID COMPONENT: {this.id_component}
            <br></br>
            LINK: {this.getButtonComponent(this, "Select: " + this.link_component, "select_component")}
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
  value?;
  id_data?;

  constructor(props) {
    super(props)
  }

  updateProgramData(){
    super.updateProgramData()

    let component : DataProgramComponent = this.props.component as DataProgramComponent
    this.value = component?.value;
    this.id_data = component?.id_data;
  }

  getObjectContent(){
    return (
        <div>
            ID_DATA: {this.id_data}
            <br></br>
            VALUE: {this.value}
            <br></br>
            ID COMPONENT: {this.id_component}
            <br></br>
            LINK: {this.getButtonComponent(this, "Select: " + this.link_component, "select_component")}
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
  "awaiter" : AwaiterProgramComponent,
  "DEFAULT" : ProgramComponent,
  "DATA" : DataProgramComponent
}

export const GetTypeProgramComponent = (id_component) =>{
  const TypeComponent = ProgramComponentTypesMap[id_component] || ProgramComponent
  return TypeComponent;
}

