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

import { HttpFile } from '../http/http';

export class BlockSubset {
    'slot': number;
    'epoch': number;
    'height': number;
    /**
    * [0-9a-fA-F]{64}
    */
    'hash': string;
    'era': number;

    static readonly discriminator: string | undefined = undefined;

    static readonly attributeTypeMap: Array<{name: string, baseName: string, type: string, format: string}> = [
        {
            "name": "slot",
            "baseName": "slot",
            "type": "number",
            "format": "double"
        },
        {
            "name": "epoch",
            "baseName": "epoch",
            "type": "number",
            "format": "double"
        },
        {
            "name": "height",
            "baseName": "height",
            "type": "number",
            "format": "double"
        },
        {
            "name": "hash",
            "baseName": "hash",
            "type": "string",
            "format": ""
        },
        {
            "name": "era",
            "baseName": "era",
            "type": "number",
            "format": "double"
        }    ];

    static getAttributeTypeMap() {
        return BlockSubset.attributeTypeMap;
    }

    public constructor() {
    }
}

