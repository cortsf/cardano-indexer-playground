export * from './Address';
export * from './AddressUsedRequest';
export * from './AddressUsedRequestAllOf';
export * from './AddressUsedResponse';
export * from './AfterBlockPagination';
export * from './BlockInfo';
export * from './BlockInfoAllOf';
export * from './BlockLatestRequest';
export * from './BlockLatestResponse';
export * from './BlockSubset';
export * from './BlockTxPair';
export * from './Cip25Response';
export * from './Credential';
export * from './CredentialAddressRequest';
export * from './CredentialAddressRequestAllOf';
export * from './CredentialAddressResponse';
export * from './CredentialAddressResponseAllOf';
export * from './ErrorShape';
export * from './PageInfo';
export * from './PageInfoPageInfo';
export * from './Pagination';
export * from './PolicyIdAssetMapType';
export * from './TransactionHistoryRequest';
export * from './TransactionHistoryRequestAllOf';
export * from './TransactionHistoryResponse';
export * from './TransactionInfo';
export * from './TransactionOutputRequest';
export * from './TransactionOutputResponse';
export * from './TxAndBlockInfo';
export * from './UntilBlockPagination';
export * from './UtxoAndBlockInfo';
export * from './UtxoPointer';

import { Address } from './Address';
import { AddressUsedRequest } from './AddressUsedRequest';
import { AddressUsedRequestAllOf } from './AddressUsedRequestAllOf';
import { AddressUsedResponse } from './AddressUsedResponse';
import { AfterBlockPagination } from './AfterBlockPagination';
import { BlockInfo } from './BlockInfo';
import { BlockInfoAllOf } from './BlockInfoAllOf';
import { BlockLatestRequest } from './BlockLatestRequest';
import { BlockLatestResponse } from './BlockLatestResponse';
import { BlockSubset } from './BlockSubset';
import { BlockTxPair } from './BlockTxPair';
import { Cip25Response } from './Cip25Response';
import { Credential } from './Credential';
import { CredentialAddressRequest } from './CredentialAddressRequest';
import { CredentialAddressRequestAllOf } from './CredentialAddressRequestAllOf';
import { CredentialAddressResponse } from './CredentialAddressResponse';
import { CredentialAddressResponseAllOf } from './CredentialAddressResponseAllOf';
import { ErrorShape } from './ErrorShape';
import { PageInfo } from './PageInfo';
import { PageInfoPageInfo } from './PageInfoPageInfo';
import { Pagination } from './Pagination';
import { PolicyIdAssetMapType } from './PolicyIdAssetMapType';
import { TransactionHistoryRequest } from './TransactionHistoryRequest';
import { TransactionHistoryRequestAllOf } from './TransactionHistoryRequestAllOf';
import { TransactionHistoryResponse } from './TransactionHistoryResponse';
import { TransactionInfo } from './TransactionInfo';
import { TransactionOutputRequest } from './TransactionOutputRequest';
import { TransactionOutputResponse } from './TransactionOutputResponse';
import { TxAndBlockInfo } from './TxAndBlockInfo';
import { UntilBlockPagination } from './UntilBlockPagination';
import { UtxoAndBlockInfo } from './UtxoAndBlockInfo';
import { UtxoPointer } from './UtxoPointer';

/* tslint:disable:no-unused-variable */
let primitives = [
                    "string",
                    "boolean",
                    "double",
                    "integer",
                    "long",
                    "float",
                    "number",
                    "any"
                 ];

const supportedMediaTypes: { [mediaType: string]: number } = {
  "application/json": Infinity,
  "application/octet-stream": 0,
  "application/x-www-form-urlencoded": 0
}


let enumsMap: Set<string> = new Set<string>([
]);

let typeMap: {[index: string]: any} = {
    "Address": Address,
    "AddressUsedRequest": AddressUsedRequest,
    "AddressUsedRequestAllOf": AddressUsedRequestAllOf,
    "AddressUsedResponse": AddressUsedResponse,
    "AfterBlockPagination": AfterBlockPagination,
    "BlockInfo": BlockInfo,
    "BlockInfoAllOf": BlockInfoAllOf,
    "BlockLatestRequest": BlockLatestRequest,
    "BlockLatestResponse": BlockLatestResponse,
    "BlockSubset": BlockSubset,
    "BlockTxPair": BlockTxPair,
    "Cip25Response": Cip25Response,
    "Credential": Credential,
    "CredentialAddressRequest": CredentialAddressRequest,
    "CredentialAddressRequestAllOf": CredentialAddressRequestAllOf,
    "CredentialAddressResponse": CredentialAddressResponse,
    "CredentialAddressResponseAllOf": CredentialAddressResponseAllOf,
    "ErrorShape": ErrorShape,
    "PageInfo": PageInfo,
    "PageInfoPageInfo": PageInfoPageInfo,
    "Pagination": Pagination,
    "PolicyIdAssetMapType": PolicyIdAssetMapType,
    "TransactionHistoryRequest": TransactionHistoryRequest,
    "TransactionHistoryRequestAllOf": TransactionHistoryRequestAllOf,
    "TransactionHistoryResponse": TransactionHistoryResponse,
    "TransactionInfo": TransactionInfo,
    "TransactionOutputRequest": TransactionOutputRequest,
    "TransactionOutputResponse": TransactionOutputResponse,
    "TxAndBlockInfo": TxAndBlockInfo,
    "UntilBlockPagination": UntilBlockPagination,
    "UtxoAndBlockInfo": UtxoAndBlockInfo,
    "UtxoPointer": UtxoPointer,
}

export class ObjectSerializer {
    public static findCorrectType(data: any, expectedType: string) {
        if (data == undefined) {
            return expectedType;
        } else if (primitives.indexOf(expectedType.toLowerCase()) !== -1) {
            return expectedType;
        } else if (expectedType === "Date") {
            return expectedType;
        } else {
            if (enumsMap.has(expectedType)) {
                return expectedType;
            }

            if (!typeMap[expectedType]) {
                return expectedType; // w/e we don't know the type
            }

            // Check the discriminator
            let discriminatorProperty = typeMap[expectedType].discriminator;
            if (discriminatorProperty == null) {
                return expectedType; // the type does not have a discriminator. use it.
            } else {
                if (data[discriminatorProperty]) {
                    var discriminatorType = data[discriminatorProperty];
                    if(typeMap[discriminatorType]){
                        return discriminatorType; // use the type given in the discriminator
                    } else {
                        return expectedType; // discriminator did not map to a type
                    }
                } else {
                    return expectedType; // discriminator was not present (or an empty string)
                }
            }
        }
    }

    public static serialize(data: any, type: string, format: string) {
        if (data == undefined) {
            return data;
        } else if (primitives.indexOf(type.toLowerCase()) !== -1) {
            return data;
        } else if (type.lastIndexOf("Array<", 0) === 0) { // string.startsWith pre es6
            let subType: string = type.replace("Array<", ""); // Array<Type> => Type>
            subType = subType.substring(0, subType.length - 1); // Type> => Type
            let transformedData: any[] = [];
            for (let index in data) {
                let date = data[index];
                transformedData.push(ObjectSerializer.serialize(date, subType, format));
            }
            return transformedData;
        } else if (type === "Date") {
            if (format == "date") {
                let month = data.getMonth()+1
                month = month < 10 ? "0" + month.toString() : month.toString()
                let day = data.getDate();
                day = day < 10 ? "0" + day.toString() : day.toString();

                return data.getFullYear() + "-" + month + "-" + day;
            } else {
                return data.toISOString();
            }
        } else {
            if (enumsMap.has(type)) {
                return data;
            }
            if (!typeMap[type]) { // in case we dont know the type
                return data;
            }

            // Get the actual type of this object
            type = this.findCorrectType(data, type);

            // get the map for the correct type.
            let attributeTypes = typeMap[type].getAttributeTypeMap();
            let instance: {[index: string]: any} = {};
            for (let index in attributeTypes) {
                let attributeType = attributeTypes[index];
                instance[attributeType.baseName] = ObjectSerializer.serialize(data[attributeType.name], attributeType.type, attributeType.format);
            }
            return instance;
        }
    }

    public static deserialize(data: any, type: string, format: string) {
        // polymorphism may change the actual type.
        type = ObjectSerializer.findCorrectType(data, type);
        if (data == undefined) {
            return data;
        } else if (primitives.indexOf(type.toLowerCase()) !== -1) {
            return data;
        } else if (type.lastIndexOf("Array<", 0) === 0) { // string.startsWith pre es6
            let subType: string = type.replace("Array<", ""); // Array<Type> => Type>
            subType = subType.substring(0, subType.length - 1); // Type> => Type
            let transformedData: any[] = [];
            for (let index in data) {
                let date = data[index];
                transformedData.push(ObjectSerializer.deserialize(date, subType, format));
            }
            return transformedData;
        } else if (type === "Date") {
            return new Date(data);
        } else {
            if (enumsMap.has(type)) {// is Enum
                return data;
            }

            if (!typeMap[type]) { // dont know the type
                return data;
            }
            let instance = new typeMap[type]();
            let attributeTypes = typeMap[type].getAttributeTypeMap();
            for (let index in attributeTypes) {
                let attributeType = attributeTypes[index];
                instance[attributeType.name] = ObjectSerializer.deserialize(data[attributeType.baseName], attributeType.type, attributeType.format);
            }
            return instance;
        }
    }


    /**
     * Normalize media type
     *
     * We currently do not handle any media types attributes, i.e. anything
     * after a semicolon. All content is assumed to be UTF-8 compatible.
     */
    public static normalizeMediaType(mediaType: string | undefined): string | undefined {
        if (mediaType === undefined) {
            return undefined;
        }
        return mediaType.split(";")[0].trim().toLowerCase();
    }

    /**
     * From a list of possible media types, choose the one we can handle best.
     *
     * The order of the given media types does not have any impact on the choice
     * made.
     */
    public static getPreferredMediaType(mediaTypes: Array<string>): string {
        /** According to OAS 3 we should default to json */
        if (!mediaTypes) {
            return "application/json";
        }

        const normalMediaTypes = mediaTypes.map(this.normalizeMediaType);
        let selectedMediaType: string | undefined = undefined;
        let selectedRank: number = -Infinity;
        for (const mediaType of normalMediaTypes) {
            if (supportedMediaTypes[mediaType!] > selectedRank) {
                selectedMediaType = mediaType;
                selectedRank = supportedMediaTypes[mediaType!];
            }
        }

        if (selectedMediaType === undefined) {
            throw new Error("None of the given media types are supported: " + mediaTypes.join(", "));
        }

        return selectedMediaType!;
    }

    /**
     * Convert data to a string according the given media type
     */
    public static stringify(data: any, mediaType: string): string {
        if (mediaType === "application/json") {
            return JSON.stringify(data);
        }

        throw new Error("The mediaType " + mediaType + " is not supported by ObjectSerializer.stringify.");
    }

    /**
     * Parse data from a string according to the given media type
     */
    public static parse(rawData: string, mediaType: string | undefined) {
        if (mediaType === undefined) {
            throw new Error("Cannot parse content. No Content-Type defined.");
        }

        if (mediaType === "application/json") {
            return JSON.parse(rawData);
        }

        throw new Error("The mediaType " + mediaType + " is not supported by ObjectSerializer.parse.");
    }
}
