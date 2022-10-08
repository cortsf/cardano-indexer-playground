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

export class UntilBlockPagination {
    /**
    * block hash - inclusive
    */
    'untilBlock': string;

    static readonly discriminator: string | undefined = undefined;

    static readonly attributeTypeMap: Array<{name: string, baseName: string, type: string, format: string}> = [
        {
            "name": "untilBlock",
            "baseName": "untilBlock",
            "type": "string",
            "format": ""
        }    ];

    static getAttributeTypeMap() {
        return UntilBlockPagination.attributeTypeMap;
    }

    public constructor() {
    }
}
