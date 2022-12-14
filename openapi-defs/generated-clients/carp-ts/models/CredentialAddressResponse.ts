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

import { CredentialAddressResponseAllOf } from './CredentialAddressResponseAllOf';
import { PageInfo } from './PageInfo';
import { PageInfoPageInfo } from './PageInfoPageInfo';
import { HttpFile } from '../http/http';

export class CredentialAddressResponse {
    'addresses': Array<string>;
    'pageInfo': PageInfoPageInfo;

    static readonly discriminator: string | undefined = undefined;

    static readonly attributeTypeMap: Array<{name: string, baseName: string, type: string, format: string}> = [
        {
            "name": "addresses",
            "baseName": "addresses",
            "type": "Array<string>",
            "format": ""
        },
        {
            "name": "pageInfo",
            "baseName": "pageInfo",
            "type": "PageInfoPageInfo",
            "format": ""
        }    ];

    static getAttributeTypeMap() {
        return CredentialAddressResponse.attributeTypeMap;
    }

    public constructor() {
    }
}

