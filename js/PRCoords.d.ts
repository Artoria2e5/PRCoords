// Type definitions for PRCoords
// Project: PRCoords

export as namespace PRCoords

export interface PRCoord {
	lat: number
	lon: number
}
export type PRCoordOp = (c: PRCoord, checkChina?: boolean) => PRCoord

export function distance(a: PRCoord, b: PRCoord): number

// We do not use the PRCO type to make it a bit more transparent on the IDE
export function gcj_wgs(c: PRCoord, checkChina?: boolean): PRCoord
export function wgs_gcj(c: PRCoord, checkChina?: boolean): PRCoord
export function wgs_gcj_bored(c: PRCoord, checkChina?: boolean): PRCoord
export function gcj_bd(c: PRCoord, __dummy__?: boolean): PRCoord
export function bd_gcj(c: PRCoord, __dummy__?: boolean): PRCoord
export function bd_gcj_bored(c: PRCoord, __dummy__?: boolean): PRCoord
export function wgs_bd(c: PRCoord, checkChina?: boolean): PRCoord
export function bd_wgs(c: PRCoord, checkChina?: boolean): PRCoord
export function bd_wgs_bored(c: PRCoord, checkChina?: boolean): PRCoord
export function __bored__(fwd: PRCoordOp, rev: PRCoordOp): PRCoordOp
