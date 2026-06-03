import { describe, expect, it } from 'bun:test';

import {
  getGasColor,
  getGasFromId,
  getGasFromPath,
  getGasLabel,
} from './constants';

describe('gas helper functions', () => {
  it('should get the proper gas label', () => {
    const gasId = 'fractol';
    const gasLabel = getGasLabel(gasId);
    expect(gasLabel).toBe('Fractol');
  });

  it('should get the proper gas label with a fallback', () => {
    const gasId = 'nonexistent';
    const gasLabel = getGasLabel(gasId, 'fallback');

    expect(gasLabel).toBe('fallback');
  });

  it('should return none if no gas and no fallback is found', () => {
    const gasId = 'nonexistent';
    const gasLabel = getGasLabel(gasId);

    expect(gasLabel).toBe('None');
  });

  it('should get the proper gas color', () => {
    const gasId = 'fractol';
    const gasColor = getGasColor(gasId);

    expect(gasColor).toBe('mediumslateblue');
  });

  it('should return a string if no gas is found', () => {
    const gasId = 'nonexistent';
    const gasColor = getGasColor(gasId);

    expect(gasColor).toBe('black');
  });

  it('should return the gas object if found', () => {
    const gasId = 'fractol';
    const gas = getGasFromId(gasId);

    expect(gas).toEqual({
      id: 'fractol',
      path: '/datum/xgm_gas/fractol',
      name: 'Fractol',
      label: 'Fractol',
      color: 'mediumslateblue',
    });
  });

  it('should return undefined if no gas is found', () => {
    const gasId = 'nonexistent';
    const gas = getGasFromId(gasId);

    expect(gas).toBeUndefined();
  });

  it('should return the gas using a path', () => {
    const gasPath = '/datum/xgm_gas/fractol';
    const gas = getGasFromPath(gasPath);

    expect(gas).toEqual({
      id: 'fractol',
      path: '/datum/xgm_gas/fractol',
      name: 'Fractol',
      label: 'Fractol',
      color: 'mediumslateblue',
    });
  });
});
