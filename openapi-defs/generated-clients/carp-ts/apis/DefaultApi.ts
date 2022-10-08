// TODO: better import syntax?
import {BaseAPIRequestFactory, RequiredError} from './baseapi';
import {Configuration} from '../configuration';
import {RequestContext, HttpMethod, ResponseContext, HttpFile} from '../http/http';
import {ObjectSerializer} from '../models/ObjectSerializer';
import {ApiException} from './exception';
import {canConsumeForm, isCodeInRange} from '../util';
import {SecurityAuthentication} from '../auth/auth';


import { AddressUsedRequest } from '../models/AddressUsedRequest';
import { AddressUsedResponse } from '../models/AddressUsedResponse';
import { BlockLatestRequest } from '../models/BlockLatestRequest';
import { BlockLatestResponse } from '../models/BlockLatestResponse';
import { Cip25Response } from '../models/Cip25Response';
import { CredentialAddressRequest } from '../models/CredentialAddressRequest';
import { CredentialAddressResponse } from '../models/CredentialAddressResponse';
import { ErrorShape } from '../models/ErrorShape';
import { PolicyIdAssetMapType } from '../models/PolicyIdAssetMapType';
import { TransactionHistoryRequest } from '../models/TransactionHistoryRequest';
import { TransactionHistoryResponse } from '../models/TransactionHistoryResponse';
import { TransactionOutputRequest } from '../models/TransactionOutputRequest';
import { TransactionOutputResponse } from '../models/TransactionOutputResponse';

/**
 * no description
 */
export class DefaultApiRequestFactory extends BaseAPIRequestFactory {

    /**
     * Ordered lexicographically (order is not maintained)  Warning: the pagination on this endpoint is NOT whether or not an address was used during this block interval, but rather whether or not the address was first used within this interval.  Note: this endpoint only returns addresses that are in a block. Use another tool to see mempool information
     * @param addressUsedRequest 
     */
    public async addressUsed(addressUsedRequest: AddressUsedRequest, _options?: Configuration): Promise<RequestContext> {
        let _config = _options || this.configuration;

        // verify required parameter 'addressUsedRequest' is not null or undefined
        if (addressUsedRequest === null || addressUsedRequest === undefined) {
            throw new RequiredError("DefaultApi", "addressUsed", "addressUsedRequest");
        }


        // Path Params
        const localVarPath = '/address/used';

        // Make Request Context
        const requestContext = _config.baseServer.makeRequestContext(localVarPath, HttpMethod.POST);
        requestContext.setHeaderParam("Accept", "application/json, */*;q=0.8")


        // Body Params
        const contentType = ObjectSerializer.getPreferredMediaType([
            "application/json"
        ]);
        requestContext.setHeaderParam("Content-Type", contentType);
        const serializedBody = ObjectSerializer.stringify(
            ObjectSerializer.serialize(addressUsedRequest, "AddressUsedRequest", ""),
            contentType
        );
        requestContext.setBody(serializedBody);

        
        const defaultAuth: SecurityAuthentication | undefined = _options?.authMethods?.default || this.configuration?.authMethods?.default
        if (defaultAuth?.applySecurityAuthentication) {
            await defaultAuth?.applySecurityAuthentication(requestContext);
        }

        return requestContext;
    }

    /**
     * Ordered by the first time the address was seen on-chain  Note: this endpoint only returns addresses that are in a block. Use another tool to see mempool information
     * @param credentialAddressRequest 
     */
    public async addressesForCredential(credentialAddressRequest: CredentialAddressRequest, _options?: Configuration): Promise<RequestContext> {
        let _config = _options || this.configuration;

        // verify required parameter 'credentialAddressRequest' is not null or undefined
        if (credentialAddressRequest === null || credentialAddressRequest === undefined) {
            throw new RequiredError("DefaultApi", "addressesForCredential", "credentialAddressRequest");
        }


        // Path Params
        const localVarPath = '/credential/address';

        // Make Request Context
        const requestContext = _config.baseServer.makeRequestContext(localVarPath, HttpMethod.POST);
        requestContext.setHeaderParam("Accept", "application/json, */*;q=0.8")


        // Body Params
        const contentType = ObjectSerializer.getPreferredMediaType([
            "application/json"
        ]);
        requestContext.setHeaderParam("Content-Type", contentType);
        const serializedBody = ObjectSerializer.stringify(
            ObjectSerializer.serialize(credentialAddressRequest, "CredentialAddressRequest", ""),
            contentType
        );
        requestContext.setBody(serializedBody);

        
        const defaultAuth: SecurityAuthentication | undefined = _options?.authMethods?.default || this.configuration?.authMethods?.default
        if (defaultAuth?.applySecurityAuthentication) {
            await defaultAuth?.applySecurityAuthentication(requestContext);
        }

        return requestContext;
    }

    /**
     * Get the latest block. Useful for checking synchronization process and pagination
     * @param blockLatestRequest 
     */
    public async blockLatest(blockLatestRequest: BlockLatestRequest, _options?: Configuration): Promise<RequestContext> {
        let _config = _options || this.configuration;

        // verify required parameter 'blockLatestRequest' is not null or undefined
        if (blockLatestRequest === null || blockLatestRequest === undefined) {
            throw new RequiredError("DefaultApi", "blockLatest", "blockLatestRequest");
        }


        // Path Params
        const localVarPath = '/block/latest';

        // Make Request Context
        const requestContext = _config.baseServer.makeRequestContext(localVarPath, HttpMethod.POST);
        requestContext.setHeaderParam("Accept", "application/json, */*;q=0.8")


        // Body Params
        const contentType = ObjectSerializer.getPreferredMediaType([
            "application/json"
        ]);
        requestContext.setHeaderParam("Content-Type", contentType);
        const serializedBody = ObjectSerializer.stringify(
            ObjectSerializer.serialize(blockLatestRequest, "BlockLatestRequest", ""),
            contentType
        );
        requestContext.setBody(serializedBody);

        
        const defaultAuth: SecurityAuthentication | undefined = _options?.authMethods?.default || this.configuration?.authMethods?.default
        if (defaultAuth?.applySecurityAuthentication) {
            await defaultAuth?.applySecurityAuthentication(requestContext);
        }

        return requestContext;
    }

    /**
     * Gets the CIP25 metadata for given <policy, asset_name> pairs  Note: policy IDs and asset names MUST be in hex strings. Do not use UTF8 asset names.  Note: This endpoint returns the NFT metadata as a CBOR object and NOT JSON. You may expect a JSON object, but actually Cardano has no concept of on-chain JSON. In fact, on-chain JSON is not even possible! Instead, Cardano stores metadata as CBOR which can then be converted to JSON The conversion of CBOR to JSON is project-dependent, and so Carp instead returns the raw cbor It's up to you to choose how you want to do the JSON conversion. The common case is handled inside the Carp client library.
     * @param policyIdAssetMapType 
     */
    public async metadataNft(policyIdAssetMapType: PolicyIdAssetMapType, _options?: Configuration): Promise<RequestContext> {
        let _config = _options || this.configuration;

        // verify required parameter 'policyIdAssetMapType' is not null or undefined
        if (policyIdAssetMapType === null || policyIdAssetMapType === undefined) {
            throw new RequiredError("DefaultApi", "metadataNft", "policyIdAssetMapType");
        }


        // Path Params
        const localVarPath = '/metadata/nft';

        // Make Request Context
        const requestContext = _config.baseServer.makeRequestContext(localVarPath, HttpMethod.POST);
        requestContext.setHeaderParam("Accept", "application/json, */*;q=0.8")


        // Body Params
        const contentType = ObjectSerializer.getPreferredMediaType([
            "application/json"
        ]);
        requestContext.setHeaderParam("Content-Type", contentType);
        const serializedBody = ObjectSerializer.stringify(
            ObjectSerializer.serialize(policyIdAssetMapType, "PolicyIdAssetMapType", ""),
            contentType
        );
        requestContext.setBody(serializedBody);

        
        const defaultAuth: SecurityAuthentication | undefined = _options?.authMethods?.default || this.configuration?.authMethods?.default
        if (defaultAuth?.applySecurityAuthentication) {
            await defaultAuth?.applySecurityAuthentication(requestContext);
        }

        return requestContext;
    }

    /**
     * Ordered by `<block.height, transaction.tx_index>`  Note: this endpoint only returns txs that are in a block. Use another tool to see mempool for txs not in a block
     * @param transactionHistoryRequest 
     */
    public async transactionHistory(transactionHistoryRequest: TransactionHistoryRequest, _options?: Configuration): Promise<RequestContext> {
        let _config = _options || this.configuration;

        // verify required parameter 'transactionHistoryRequest' is not null or undefined
        if (transactionHistoryRequest === null || transactionHistoryRequest === undefined) {
            throw new RequiredError("DefaultApi", "transactionHistory", "transactionHistoryRequest");
        }


        // Path Params
        const localVarPath = '/transaction/history';

        // Make Request Context
        const requestContext = _config.baseServer.makeRequestContext(localVarPath, HttpMethod.POST);
        requestContext.setHeaderParam("Accept", "application/json, */*;q=0.8")


        // Body Params
        const contentType = ObjectSerializer.getPreferredMediaType([
            "application/json"
        ]);
        requestContext.setHeaderParam("Content-Type", contentType);
        const serializedBody = ObjectSerializer.stringify(
            ObjectSerializer.serialize(transactionHistoryRequest, "TransactionHistoryRequest", ""),
            contentType
        );
        requestContext.setBody(serializedBody);

        
        const defaultAuth: SecurityAuthentication | undefined = _options?.authMethods?.default || this.configuration?.authMethods?.default
        if (defaultAuth?.applySecurityAuthentication) {
            await defaultAuth?.applySecurityAuthentication(requestContext);
        }

        return requestContext;
    }

    /**
     * Get the outputs for given `<tx hash, output index>` pairs.  This endpoint will return both used AND unused outputs  Note: this endpoint only returns txs that are in a block. Use another tool to see mempool for txs not in a block
     * @param transactionOutputRequest 
     */
    public async transactionOutput(transactionOutputRequest: TransactionOutputRequest, _options?: Configuration): Promise<RequestContext> {
        let _config = _options || this.configuration;

        // verify required parameter 'transactionOutputRequest' is not null or undefined
        if (transactionOutputRequest === null || transactionOutputRequest === undefined) {
            throw new RequiredError("DefaultApi", "transactionOutput", "transactionOutputRequest");
        }


        // Path Params
        const localVarPath = '/transaction/output';

        // Make Request Context
        const requestContext = _config.baseServer.makeRequestContext(localVarPath, HttpMethod.POST);
        requestContext.setHeaderParam("Accept", "application/json, */*;q=0.8")


        // Body Params
        const contentType = ObjectSerializer.getPreferredMediaType([
            "application/json"
        ]);
        requestContext.setHeaderParam("Content-Type", contentType);
        const serializedBody = ObjectSerializer.stringify(
            ObjectSerializer.serialize(transactionOutputRequest, "TransactionOutputRequest", ""),
            contentType
        );
        requestContext.setBody(serializedBody);

        
        const defaultAuth: SecurityAuthentication | undefined = _options?.authMethods?.default || this.configuration?.authMethods?.default
        if (defaultAuth?.applySecurityAuthentication) {
            await defaultAuth?.applySecurityAuthentication(requestContext);
        }

        return requestContext;
    }

}

export class DefaultApiResponseProcessor {

    /**
     * Unwraps the actual response sent by the server from the response context and deserializes the response content
     * to the expected objects
     *
     * @params response Response returned by the server for a request to addressUsed
     * @throws ApiException if the response code was not in [200, 299]
     */
     public async addressUsed(response: ResponseContext): Promise<AddressUsedResponse > {
        const contentType = ObjectSerializer.normalizeMediaType(response.headers["content-type"]);
        if (isCodeInRange("200", response.httpStatusCode)) {
            const body: AddressUsedResponse = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "AddressUsedResponse", ""
            ) as AddressUsedResponse;
            return body;
        }
        if (isCodeInRange("400", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(400, "", body, response.headers);
        }
        if (isCodeInRange("409", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(409, "", body, response.headers);
        }
        if (isCodeInRange("422", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(422, "", body, response.headers);
        }

        // Work around for missing responses in specification, e.g. for petstore.yaml
        if (response.httpStatusCode >= 200 && response.httpStatusCode <= 299) {
            const body: AddressUsedResponse = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "AddressUsedResponse", ""
            ) as AddressUsedResponse;
            return body;
        }

        throw new ApiException<string | Blob | undefined>(response.httpStatusCode, "Unknown API Status Code!", await response.getBodyAsAny(), response.headers);
    }

    /**
     * Unwraps the actual response sent by the server from the response context and deserializes the response content
     * to the expected objects
     *
     * @params response Response returned by the server for a request to addressesForCredential
     * @throws ApiException if the response code was not in [200, 299]
     */
     public async addressesForCredential(response: ResponseContext): Promise<CredentialAddressResponse > {
        const contentType = ObjectSerializer.normalizeMediaType(response.headers["content-type"]);
        if (isCodeInRange("200", response.httpStatusCode)) {
            const body: CredentialAddressResponse = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "CredentialAddressResponse", ""
            ) as CredentialAddressResponse;
            return body;
        }
        if (isCodeInRange("400", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(400, "", body, response.headers);
        }
        if (isCodeInRange("422", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(422, "", body, response.headers);
        }

        // Work around for missing responses in specification, e.g. for petstore.yaml
        if (response.httpStatusCode >= 200 && response.httpStatusCode <= 299) {
            const body: CredentialAddressResponse = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "CredentialAddressResponse", ""
            ) as CredentialAddressResponse;
            return body;
        }

        throw new ApiException<string | Blob | undefined>(response.httpStatusCode, "Unknown API Status Code!", await response.getBodyAsAny(), response.headers);
    }

    /**
     * Unwraps the actual response sent by the server from the response context and deserializes the response content
     * to the expected objects
     *
     * @params response Response returned by the server for a request to blockLatest
     * @throws ApiException if the response code was not in [200, 299]
     */
     public async blockLatest(response: ResponseContext): Promise<BlockLatestResponse > {
        const contentType = ObjectSerializer.normalizeMediaType(response.headers["content-type"]);
        if (isCodeInRange("200", response.httpStatusCode)) {
            const body: BlockLatestResponse = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "BlockLatestResponse", ""
            ) as BlockLatestResponse;
            return body;
        }
        if (isCodeInRange("400", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(400, "", body, response.headers);
        }
        if (isCodeInRange("409", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(409, "", body, response.headers);
        }

        // Work around for missing responses in specification, e.g. for petstore.yaml
        if (response.httpStatusCode >= 200 && response.httpStatusCode <= 299) {
            const body: BlockLatestResponse = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "BlockLatestResponse", ""
            ) as BlockLatestResponse;
            return body;
        }

        throw new ApiException<string | Blob | undefined>(response.httpStatusCode, "Unknown API Status Code!", await response.getBodyAsAny(), response.headers);
    }

    /**
     * Unwraps the actual response sent by the server from the response context and deserializes the response content
     * to the expected objects
     *
     * @params response Response returned by the server for a request to metadataNft
     * @throws ApiException if the response code was not in [200, 299]
     */
     public async metadataNft(response: ResponseContext): Promise<Cip25Response > {
        const contentType = ObjectSerializer.normalizeMediaType(response.headers["content-type"]);
        if (isCodeInRange("200", response.httpStatusCode)) {
            const body: Cip25Response = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "Cip25Response", ""
            ) as Cip25Response;
            return body;
        }
        if (isCodeInRange("400", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(400, "", body, response.headers);
        }
        if (isCodeInRange("422", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(422, "", body, response.headers);
        }

        // Work around for missing responses in specification, e.g. for petstore.yaml
        if (response.httpStatusCode >= 200 && response.httpStatusCode <= 299) {
            const body: Cip25Response = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "Cip25Response", ""
            ) as Cip25Response;
            return body;
        }

        throw new ApiException<string | Blob | undefined>(response.httpStatusCode, "Unknown API Status Code!", await response.getBodyAsAny(), response.headers);
    }

    /**
     * Unwraps the actual response sent by the server from the response context and deserializes the response content
     * to the expected objects
     *
     * @params response Response returned by the server for a request to transactionHistory
     * @throws ApiException if the response code was not in [200, 299]
     */
     public async transactionHistory(response: ResponseContext): Promise<TransactionHistoryResponse > {
        const contentType = ObjectSerializer.normalizeMediaType(response.headers["content-type"]);
        if (isCodeInRange("200", response.httpStatusCode)) {
            const body: TransactionHistoryResponse = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "TransactionHistoryResponse", ""
            ) as TransactionHistoryResponse;
            return body;
        }
        if (isCodeInRange("400", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(400, "", body, response.headers);
        }
        if (isCodeInRange("409", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(409, "", body, response.headers);
        }
        if (isCodeInRange("422", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(422, "", body, response.headers);
        }

        // Work around for missing responses in specification, e.g. for petstore.yaml
        if (response.httpStatusCode >= 200 && response.httpStatusCode <= 299) {
            const body: TransactionHistoryResponse = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "TransactionHistoryResponse", ""
            ) as TransactionHistoryResponse;
            return body;
        }

        throw new ApiException<string | Blob | undefined>(response.httpStatusCode, "Unknown API Status Code!", await response.getBodyAsAny(), response.headers);
    }

    /**
     * Unwraps the actual response sent by the server from the response context and deserializes the response content
     * to the expected objects
     *
     * @params response Response returned by the server for a request to transactionOutput
     * @throws ApiException if the response code was not in [200, 299]
     */
     public async transactionOutput(response: ResponseContext): Promise<TransactionOutputResponse > {
        const contentType = ObjectSerializer.normalizeMediaType(response.headers["content-type"]);
        if (isCodeInRange("200", response.httpStatusCode)) {
            const body: TransactionOutputResponse = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "TransactionOutputResponse", ""
            ) as TransactionOutputResponse;
            return body;
        }
        if (isCodeInRange("400", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(400, "", body, response.headers);
        }
        if (isCodeInRange("422", response.httpStatusCode)) {
            const body: ErrorShape = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "ErrorShape", ""
            ) as ErrorShape;
            throw new ApiException<ErrorShape>(422, "", body, response.headers);
        }

        // Work around for missing responses in specification, e.g. for petstore.yaml
        if (response.httpStatusCode >= 200 && response.httpStatusCode <= 299) {
            const body: TransactionOutputResponse = ObjectSerializer.deserialize(
                ObjectSerializer.parse(await response.body.text(), contentType),
                "TransactionOutputResponse", ""
            ) as TransactionOutputResponse;
            return body;
        }

        throw new ApiException<string | Blob | undefined>(response.httpStatusCode, "Unknown API Status Code!", await response.getBodyAsAny(), response.headers);
    }

}
