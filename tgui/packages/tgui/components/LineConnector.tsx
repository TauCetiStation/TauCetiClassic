/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Section } from './Section';
import { Component, findDOMNode, createRef, InfernoNode, RefObject } from 'inferno';
import { addScrollableNode, removeScrollableNode } from '../events';
import { Box, BoxProps, unit } from './Box';
import { useState, useEffect } from 'common/react';

export const PositionTypes = {
	Center: 'center',
	LeftTop: 'left-top',
  LeftCenter: 'left-center',
  LeftBottom: 'left-bottom',
  TopCenter: 'top-center',
  BottomCenter: "bottom-center",
  RightTop: 'right-top',
  RightCenter: 'right-center',
  RightBottom: 'right-bottom',
}

export class LineConnector extends Component {
  refLine : RefObject<HTMLDivElement>;
  state;
  props;

  constructor(props){
    super(props)
    this.state = {
      x : 0,
      y : 0,
      x1 : 0,
      y1 : 0,
      width1 : 0,
      height1 : 0,
      pos1 : "center",
      x2 : 0,
      y2 : 0,
      width2 : 0,
      height2 : 0,
      pos2 : "center",
      setRef: false
    }
    this.props = props

    this.useEffect()

    if (this.props.getObj) {
      this.props.getObj(this);
    }
  }

  useEffect(){
    const handleScroll = () => {
      this.componentDidUpdate()
    };

    // Добавляем обработчик события скроллинга при монтировании компонента
    window.addEventListener('scroll', handleScroll);

    // Удаление обработчика события при размонтировании компонента
    return () => {
      window.removeEventListener('scroll', handleScroll);
    };
  }

  updatePosition(){
    if (this.refLine == null) {
      return
    }

    let rectLine = this.refLine.getBoundingClientRect();
    this.state.x = rectLine.left
    this.state.y = rectLine.top
  }

  componentDidUpdate(){
    this.updatePosition()
    this.updateLineData()
  }

  componentDidMount() {
    this.updatePosition()
    this.updateLineData()
  }

  getCoordinatesPoint(x, y, width, height, pos){
    let x1 = x - this.state.x
    let y1 = y - this.state.y

    switch (pos) {
      case PositionTypes.Center:
        x1 += width/2
        y1 += height/2
        break;
      case PositionTypes.LeftTop:
        break;
      case PositionTypes.LeftCenter:
        y1 += height/2
        break;
      case PositionTypes.LeftBottom:
        y1 += height
        break;
      case PositionTypes.TopCenter:
        x1 += width/2
        break;
      case PositionTypes.BottomCenter:
        x1 += width/2
        y1 += height
        break;
      case PositionTypes.RightTop:
        x1 += width
        break;
      case PositionTypes.RightCenter:
        x1 += width
        y1 += height/2
        break;
      case PositionTypes.RightBottom:
        x1 += width
        y1 += height
      default:
        return {
          x : 0,
          y : 0
        };
    }

    return {
      x : x1,
      y : y1
    }
  }

  updateLineData(){

    let point1 = this.getCoordinatesPoint(this.props.x1, this.props.y1, this.props.width1, this.props.height1, this.props.pos1 );

    let point2 = this.getCoordinatesPoint(this.props.x2, this.props.y2, this.props.width2, this.props.height2, this.props.pos2 );

    if(isNaN(point1.x) || isNaN(point1.y) || isNaN(point2.x) || isNaN(point2.y)){
      return
    }

    this.state.x1 = point1.x
    this.state.y1 = point1.y
    this.state.x2 = point2.x
    this.state.y2 = point2.y
    this.state.color = this.props.color ?? "red"
    this.state.stroke_width = this.props.stroke_width ?? 3
  }

  setRef = (element) => {
    this.refLine = element;

    // Проверяем, если функция обратного вызова getRef была предоставлена через пропсы
    if (this.props.getRef) {
      this.state.setRef = this.props.getRef(element);
    }

    if(this.props.updateLine){
      this.props.updateLine(this.updateLineData)
    }
  }

  render() {
    this.updatePosition()
    this.updateLineData()
    let d = 'M ' + this.state.x1 + ' ' + this.state.y1 + " L " + this.state.x2 + ' ' + this.state.y2
    return (
      <svg width = "0" height = "0" ref={this.setRef} padding={0} position="absolute">
        <path
          d={d}
          stroke-width={this.state.stroke_width}
          stroke={this.state.color}
          fill="transparent"
        />
      </svg>
    );
  }
}
