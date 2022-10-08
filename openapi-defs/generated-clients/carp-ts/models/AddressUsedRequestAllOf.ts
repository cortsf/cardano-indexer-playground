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

import { Address } from './Address';
import { HttpFile } from '../http/http';

export class AddressUsedRequestAllOf {
    'addresses': Array<Address>;

    static readonly discriminator: string | undefined = undefined;

    static readonly attributeTypeMap: Array<{name: string, baseName: string, type: string, format: string}> = [
        {
            "name": "addresses",
            "baseName": "addresses",
            "type": "Array<Address>",
            "format": ""
        }    ];

    static getAttributeTypeMap() {
        return AddressUsedRequestAllOf.attributeTypeMap;
    }

    public constructor() {
    }
}

