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

export class BlockLatestRequest {
    /**
    * Note: an offset of -1 is treated the same as an offset of +1  It's usually best to avoid pagination on the latest block as in Cardano, small rollbacks of 1~2 block are very frequent and expected (read Ouroboros for why) That means that using this block for pagination will often lead to your pagination being invalidated by a rollback To avoid this, you can pass an `offset` from the tip for more stable pagination
    */
    'offset': number;

    static readonly discriminator: string | undefined = undefined;

    static readonly attributeTypeMap: Array<{name: string, baseName: string, type: string, format: string}> = [
        {
            "name": "offset",
            "baseName": "offset",
            "type": "number",
            "format": "double"
        }    ];

    static getAttributeTypeMap() {
        return BlockLatestRequest.attributeTypeMap;
    }

    public constructor() {
    }
}

