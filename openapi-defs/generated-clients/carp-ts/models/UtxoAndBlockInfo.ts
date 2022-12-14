/**
 * carp
 * API for the Postgres database generated by Carp
 *
 * OpenAPI spec version: 1.0.0
 * 
 *
 * NOTE: This class is auto generated by OpenAPI Generator (https://openapi-generator.tech).
 * https://openapi-generator.tech
 * Do not edit the class manually.
 */

import { BlockInfo } from './BlockInfo';
import { UtxoPointer } from './UtxoPointer';
import { HttpFile } from '../http/http';

export class UtxoAndBlockInfo {
    'utxo': UtxoPointer & any;
    'block': BlockInfo;

    static readonly discriminator: string | undefined = undefined;

    static readonly attributeTypeMap: Array<{name: string, baseName: string, type: string, format: string}> = [
        {
            "name": "utxo",
            "baseName": "utxo",
            "type": "UtxoPointer & any",
            "format": ""
        },
        {
            "name": "block",
            "baseName": "block",
            "type": "BlockInfo",
            "format": ""
        }    ];

    static getAttributeTypeMap() {
        return UtxoAndBlockInfo.attributeTypeMap;
    }

    public constructor() {
    }
}

