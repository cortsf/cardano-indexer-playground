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

import { PageInfoPageInfo } from './PageInfoPageInfo';
import { HttpFile } from '../http/http';

export class PageInfo {
    'pageInfo': PageInfoPageInfo;

    static readonly discriminator: string | undefined = undefined;

    static readonly attributeTypeMap: Array<{name: string, baseName: string, type: string, format: string}> = [
        {
            "name": "pageInfo",
            "baseName": "pageInfo",
            "type": "PageInfoPageInfo",
            "format": ""
        }    ];

    static getAttributeTypeMap() {
        return PageInfo.attributeTypeMap;
    }

    public constructor() {
    }
}

