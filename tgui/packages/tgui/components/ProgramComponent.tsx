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
import { LabeledList } from './LabeledList';

export class ProcessProgrammComponent extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const TypeComponent = GetTypeProgramComponent(this.props.component?.id_component)
    return (
        <TypeComponent act={this.props.act} selected_component={this.props.selected_component} component = {this.props.component} thisEditProgram = {this.props.thisEditProgram}/>
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
  content_blocks;
  props;

  constructor(props) {
    super(props)
    this.refProgram = null;
    this.props = props;

    this.updateProgramData()
    this.initContentBlocks(this.props);

    if(this.props.getObj != null){
      this.props.getObj(this)
    }
  }

  initContentBlocks(props){
    this.content_blocks = []

    this.content_blocks.push(
      this.getMainComponentContent()
    )

    if(props.thisEditProgram){
      this.content_blocks.push(
        this.getProgramActions()
      )
    } else {
      this.content_blocks.push(
        this.getSavedComponentsActions()
      );
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

  getMainComponentContent(){
    return (
      <Box>
        <LabeledList>
          <LabeledList.Item label="ID компоненты">
            {this.id_component}
          </LabeledList.Item>
          <LabeledList.Item label="Описание">
            {this.description}
          </LabeledList.Item>
        </LabeledList>
      </Box>
    )
  }

  getProgramActions(){
    return (
      <Box mt={3} border={"solid red"}>
        <LabeledList>
          <LabeledList.Item label="Ссылочное обозначение компоненты">
            {this.link_component}
          </LabeledList.Item>
          <LabeledList.Item label="Следующий компонент">
            {this.next_component?.link_component}
          </LabeledList.Item>
          <LabeledList.Item label="Предыдущий компонент">
            {this.previous_component?.link_component}
          </LabeledList.Item>
          <LabeledList.Item label="Вставить следующий компонент" buttons = {[this.getButtonComponent(this, "X", "insert_next_component")]}>
          </LabeledList.Item>
          <LabeledList.Item labelColor={"red"} label="Удаление компоненты из процесса" buttons = {[this.getButtonComponent(this, "X", "self_delete")]}>
          </LabeledList.Item>
        </LabeledList>
      </Box>
    )
  }

  getSavedComponentsActions(){
    return (
      <Box>
        <LabeledList>
          <LabeledList.Item label="Инициализировать новую программу" buttons = {[this.getButtonComponent(this, "X", "set_first_component")]}>
            {"Это действие из этой компоненты сделает новую программу"}
          </LabeledList.Item>
          <LabeledList.Item label="Сделать таргетом" buttons = {[this.getButtonComponent(this, "X", "set_target_component")]}>
            {"Использовать этот компонент при следующем действии"}
          </LabeledList.Item>
        </LabeledList>
      </Box>
    )
  }

  getObjectContent(){
    return(
      <Box>
        {this.content_blocks.map((element, i) => (
          <div>{element}</div>
        ))}
      </Box>
    )
  }

  getRenderObject(){
    let backgroundColor = "#202020"
    if(this.props.selected_component?.link_component == this.link_component){
      backgroundColor = "#228B22"
    }

    if(this.deleted){
      backgroundColor = "#CB2C31"
    }

    return (
      <div>
        <Section width={40} fitted={false} getObj = {this.setRef} fill={false} grow={0} backgroundColor={backgroundColor} m={5}>
          <Box maxWidth={40}>
            {this.deleted == true ? "Компоненты не существует" : this.getObjectContent()}
          </Box>
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
              }} component={element} selected_component={this.props.selected_component} getObj={this.setChildComponentRef} thisEditProgram = {this.props.thisEditProgram}/>
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
        }} parent = {this} selected_component={this.props.selected_component} component = {this.next_component} thisEditProgram = {this.props.thisEditProgram}/>
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
    let listComponents = [];
    listComponents.push(this.checker_component);
    listComponents.push(this.waiting_component);
    listComponents.push(this.timeout_component);
    return listComponents;
  }

  initContentBlocks(props: any): void {
    super.initContentBlocks(props);
    if(props.thisEditProgram){
      this.content_blocks.push(
        this.getAwaiterComponentsActions()
      )
    };
  }

  getAwaiterComponentsActions(){

      return (
        <Box>
          <LabeledList>
            <LabeledList.Item label="Ожидающая компонента">
              {this.waiting_component?.link_component}
            </LabeledList.Item>
            <LabeledList.Item label="Таймаут компонента">
              {this.timeout_component?.link_component}
            </LabeledList.Item>
            <LabeledList.Item label="Проверяющая компонента">
              {this.checker_component?.link_component}
            </LabeledList.Item>
            <LabeledList.Item label="Изменить ожидающий компонент" buttons = {[this.getButtonComponent(this, "X", "change_waiting_component")]}>
              {"Это действие из этой компоненты, поставит целевой компонент в ожидающий. Он будет помещен в цепь при выполнении программы если из ПРОВЕРЯЮЩЕЙ компоненты будет послан нужный СИГНАЛ"}
            </LabeledList.Item>
            <LabeledList.Item label="Изменить таймаут компонент" buttons = {[this.getButtonComponent(this, "X", "change_timeout_component")]}>
              {"Это действие из этой компоненты, поставит целевой компонент в таймаут. Он будет помещен в цепь при выполнении программы если условие для ОЖИДАЮЩЕЙ компоненты не будет выполнено и программа закончит работу (то есть в конец)"}
            </LabeledList.Item>
            <LabeledList.Item label="Изменить проверяющую компоненту" buttons = {[this.getButtonComponent(this, "X", "change_checker_component")]}>
              {"Это действие из этой компоненты, поставит целевой компонент в проверяющую. Проверяющая компонента делает свое действие после каждого выполнения последующих компонент, пока AWAITER активен и пока цепь продолжается"}
            </LabeledList.Item>
          </LabeledList>
        </Box>
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

  initContentBlocks(props: any): void {
    super.initContentBlocks(props);
    this.content_blocks.push(
      this.getDataInfo()
    );
    if(props.thisEditProgram){
      this.content_blocks.push(
        this.getProgramDataActions()
      );
    };
  }

  getProgramDataActions(){
    return null;
  }

  getDataInfo(){
    return (
      <Box>
        <LabeledList>
          <LabeledList.Item label="Информация">
            {this.data}
          </LabeledList.Item>
          <LabeledList.Item label="ID информации">
            {this.id_data}
          </LabeledList.Item>
        </LabeledList>
      </Box>
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

  getProgramDataActions(){
    return (
      <Box>
        <LabeledList>
          <LabeledList.Item label="Изменить информацию">
            {this.getTextBoxComponent(this, "", "set_data")}
          </LabeledList.Item>
        </LabeledList>
      </Box>
    )
  }
}

export class DataNumberProgramComponent extends DataProgramComponent {
  min_value;
  max_value;

  constructor(props) {
    super(props)
  }

  updateProgramData(){
    super.updateProgramData()

    let component : DataNumberProgramComponent = this.props.component as DataNumberProgramComponent
    this.data = component?.data;
    this.id_data = component?.id_data;
    this.min_value = component?.min_value;
    this.max_value = component?.max_value;
  }

  getNumberBoxComponent(element : ProgramComponent, text, action){
    if(element == null){
      return "None"
    }
    return (
    <NumberInput minValue = {this.min_value} maxValue = {this.max_value} value={this.data} onChange={(e, value) => this.props.act(action, {
      link_component: element?.link_component,
      data_change: value
    })}>
      {text}
    </NumberInput>
    )
  }

  getProgramDataActions(){
    return (
      <Box>
        <LabeledList>
          <LabeledList.Item label="Изменить информацию">
            {this.getNumberBoxComponent(this, "", "set_data")}
          </LabeledList.Item>
        </LabeledList>
      </Box>
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

  initContentBlocks(props: any): void {
    super.initContentBlocks(props);
    if(props.thisEditProgram){
      this.content_blocks.push(
        this.getCheckerProgramActions()
      )
    }
  }

  getCheckerProgramActions(){
    return (
      <Box>
        <LabeledList>
            <LabeledList.Item label="Успешная компонента">
              {this.success_component?.link_component}
            </LabeledList.Item>
            <LabeledList.Item label="Провальная компонента">
              {this.fail_component?.link_component}
            </LabeledList.Item>
            <LabeledList.Item label="Изменить успешную компоненту" buttons = {[this.getButtonComponent(this, "X", "change_success_component")]}>
              {"Это действие из этой компоненты, поставит целевой компонент в успешный. Он будет помещен в цепь при выполнении программы если из проверка внутри этой компоненты будет УСПЕШНОЙ"}
            </LabeledList.Item>
            <LabeledList.Item label="Изменить провальную компоненту" buttons = {[this.getButtonComponent(this, "X", "change_fail_component")]}>
            {"Это действие из этой компоненты, поставит целевой компонент в успешный. Он будет помещен в цепь при выполнении программы если из проверка внутри этой компоненты будет ПРОВАЛЬНОЙ"}
            </LabeledList.Item>
          </LabeledList>
      </Box>
    );
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
}

export class ProcForCycleProgramComponent extends ProcProgramComponent {
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

  initContentBlocks(props: any): void {
    super.initContentBlocks(props);
    if(props.thisEditProgram){
      this.content_blocks.push(
        this.getProgramActionsForCycle()
      )
    }
  }

  getProgramActionsForCycle() {
    return (
      <Box>
        <LabeledList>
          <LabeledList.Item label="Цикличная компонента">
            {this.cycle_component?.link_component}
          </LabeledList.Item>
          <LabeledList.Item label="Изменить цикличную компоненту" buttons = {[this.getButtonComponent(this, "X", "set_cycle_component")]}>
            {"Это действие из этой компоненты, поставит целевой компонент в цикличную. Она будет помещаться в цепь при выполнении программы когда начнется выполнение этой компоненты и ее копии будут помещаться туда определенное количество раз"}
          </LabeledList.Item>
        </LabeledList>
      </Box>
    )
  }
}

export class ProcInjectAfterNextComponentProgramComponent extends ProcProgramComponent {
  inject_component?;

  constructor(props) {
    super(props)
  }

  updateProgramData(){
    super.updateProgramData()

    let component : ProcInjectAfterNextComponentProgramComponent = this.props.component as ProcInjectAfterNextComponentProgramComponent
    this.inject_component = component?.inject_component;
  }

  getChildComponents(){
    let listComponents = []
    listComponents.push(this.inject_component)
    return listComponents
  }

  initContentBlocks(props: any): void {
    super.initContentBlocks(props);
    if(props.thisEditProgram){
      this.content_blocks.push(
        this.getProgramActionsForCycle()
      )
    }
  }

  getProgramActionsForCycle() {
    return (
      <Box>
        <LabeledList>
          <LabeledList.Item label="Внедряемая компонента">
            {this.inject_component?.link_component}
          </LabeledList.Item>
          <LabeledList.Item label="Изменить внедряемую компоненту" buttons = {[this.getButtonComponent(this, "X", "set_inject_component")]}>
            {"Это действие из этой компоненты, поставит целевой компонент во внедряемую. Она будет помещаться в цепь после следующей, при отсутствии следующей компоненты ничего происходить не будет"}
          </LabeledList.Item>
        </LabeledList>
      </Box>
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
  "pipe_system_proc_inject_after_next_component" : ProcInjectAfterNextComponentProgramComponent,
}

export const GetTypeProgramComponent = (id_component) =>{
  const TypeComponent = ProgramComponentTypesMap[id_component] || ProgramComponent
  return TypeComponent;
}

