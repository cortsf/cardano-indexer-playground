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

import { UtxoPointer } from './UtxoPointer';
import { HttpFile } from '../http/http';

export class TransactionOutputRequest {
    'utxoPointers': Array<UtxoPointer>;

    static readonly discriminator: string | undefined = undefined;

    static readonly attributeTypeMap: Array<{name: string, baseName: string, type: string, format: string}> = [
        {
            "name": "utxoPointers",
            "baseName": "utxoPointers",
            "type": "Array<UtxoPointer>",
            "format": ""
        }    ];

    static getAttributeTypeMap() {
        return TransactionOutputRequest.attributeTypeMap;
    }

    public constructor() {
    }
}
