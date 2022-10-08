import { ResponseContext, RequestContext, HttpFile } from '../http/http';
import * as models from '../models/all';
import { Configuration} from '../configuration'
import { Observable, of, from } from '../rxjsStub';
import {mergeMap, map} from  '../rxjsStub';
import { Address } from '../models/Address';
import { AddressUsedRequest } from '../models/AddressUsedRequest';
import { AddressUsedRequestAllOf } from '../models/AddressUsedRequestAllOf';
import { AddressUsedResponse } from '../models/AddressUsedResponse';
import { AfterBlockPagination } from '../models/AfterBlockPagination';
import { BlockInfo } from '../models/BlockInfo';
import { BlockInfoAllOf } from '../models/BlockInfoAllOf';
import { BlockLatestRequest } from '../models/BlockLatestRequest';
import { BlockLatestResponse } from '../models/BlockLatestResponse';
import { BlockSubset } from '../models/BlockSubset';
import { BlockTxPair } from '../models/BlockTxPair';
import { Cip25Response } from '../models/Cip25Response';
import { Credential } from '../models/Credential';
import { CredentialAddressRequest } from '../models/CredentialAddressRequest';
import { CredentialAddressRequestAllOf } from '../models/CredentialAddressRequestAllOf';
import { CredentialAddressResponse } from '../models/CredentialAddressResponse';
import { CredentialAddressResponseAllOf } from '../models/CredentialAddressResponseAllOf';
import { ErrorShape } from '../models/ErrorShape';
import { PageInfo } from '../models/PageInfo';
import { PageInfoPageInfo } from '../models/PageInfoPageInfo';
import { Pagination } from '../models/Pagination';
import { PolicyIdAssetMapType } from '../models/PolicyIdAssetMapType';
import { TransactionHistoryRequest } from '../models/TransactionHistoryRequest';
import { TransactionHistoryRequestAllOf } from '../models/TransactionHistoryRequestAllOf';
import { TransactionHistoryResponse } from '../models/TransactionHistoryResponse';
import { TransactionInfo } from '../models/TransactionInfo';
import { TransactionOutputRequest } from '../models/TransactionOutputRequest';
import { TransactionOutputResponse } from '../models/TransactionOutputResponse';
import { TxAndBlockInfo } from '../models/TxAndBlockInfo';
import { UntilBlockPagination } from '../models/UntilBlockPagination';
import { UtxoAndBlockInfo } from '../models/UtxoAndBlockInfo';
import { UtxoPointer } from '../models/UtxoPointer';

import { DefaultApiRequestFactory, DefaultApiResponseProcessor} from "../apis/DefaultApi";
export class ObservableDefaultApi {
    private requestFactory: DefaultApiRequestFactory;
    private responseProcessor: DefaultApiResponseProcessor;
    private configuration: Configuration;

    public constructor(
        configuration: Configuration,
        requestFactory?: DefaultApiRequestFactory,
        responseProcessor?: DefaultApiResponseProcessor
    ) {
        this.configuration = configuration;
        this.requestFactory = requestFactory || new DefaultApiRequestFactory(configuration);
        this.responseProcessor = responseProcessor || new DefaultApiResponseProcessor();
    }

    /**
     * Ordered lexicographically (order is not maintained)  Warning: the pagination on this endpoint is NOT whether or not an address was used during this block interval, but rather whether or not the address was first used within this interval.  Note: this endpoint only returns addresses that are in a block. Use another tool to see mempool information
     * @param addressUsedRequest 
     */
    public addressUsed(addressUsedRequest: AddressUsedRequest, _options?: Configuration): Observable<AddressUsedResponse> {
        const requestContextPromise = this.requestFactory.addressUsed(addressUsedRequest, _options);

        // build promise chain
        let middlewarePreObservable = from<RequestContext>(requestContextPromise);
        for (let middleware of this.configuration.middleware) {
            middlewarePreObservable = middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => middleware.pre(ctx)));
        }

        return middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => this.configuration.httpApi.send(ctx))).
            pipe(mergeMap((response: ResponseContext) => {
                let middlewarePostObservable = of(response);
                for (let middleware of this.configuration.middleware) {
                    middlewarePostObservable = middlewarePostObservable.pipe(mergeMap((rsp: ResponseContext) => middleware.post(rsp)));
                }
                return middlewarePostObservable.pipe(map((rsp: ResponseContext) => this.responseProcessor.addressUsed(rsp)));
            }));
    }

    /**
     * Ordered by the first time the address was seen on-chain  Note: this endpoint only returns addresses that are in a block. Use another tool to see mempool information
     * @param credentialAddressRequest 
     */
    public addressesForCredential(credentialAddressRequest: CredentialAddressRequest, _options?: Configuration): Observable<CredentialAddressResponse> {
        const requestContextPromise = this.requestFactory.addressesForCredential(credentialAddressRequest, _options);

        // build promise chain
        let middlewarePreObservable = from<RequestContext>(requestContextPromise);
        for (let middleware of this.configuration.middleware) {
            middlewarePreObservable = middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => middleware.pre(ctx)));
        }

        return middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => this.configuration.httpApi.send(ctx))).
            pipe(mergeMap((response: ResponseContext) => {
                let middlewarePostObservable = of(response);
                for (let middleware of this.configuration.middleware) {
                    middlewarePostObservable = middlewarePostObservable.pipe(mergeMap((rsp: ResponseContext) => middleware.post(rsp)));
                }
                return middlewarePostObservable.pipe(map((rsp: ResponseContext) => this.responseProcessor.addressesForCredential(rsp)));
            }));
    }

    /**
     * Get the latest block. Useful for checking synchronization process and pagination
     * @param blockLatestRequest 
     */
    public blockLatest(blockLatestRequest: BlockLatestRequest, _options?: Configuration): Observable<BlockLatestResponse> {
        const requestContextPromise = this.requestFactory.blockLatest(blockLatestRequest, _options);

        // build promise chain
        let middlewarePreObservable = from<RequestContext>(requestContextPromise);
        for (let middleware of this.configuration.middleware) {
            middlewarePreObservable = middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => middleware.pre(ctx)));
        }

        return middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => this.configuration.httpApi.send(ctx))).
            pipe(mergeMap((response: ResponseContext) => {
                let middlewarePostObservable = of(response);
                for (let middleware of this.configuration.middleware) {
                    middlewarePostObservable = middlewarePostObservable.pipe(mergeMap((rsp: ResponseContext) => middleware.post(rsp)));
                }
                return middlewarePostObservable.pipe(map((rsp: ResponseContext) => this.responseProcessor.blockLatest(rsp)));
            }));
    }

    /**
     * Gets the CIP25 metadata for given <policy, asset_name> pairs  Note: policy IDs and asset names MUST be in hex strings. Do not use UTF8 asset names.  Note: This endpoint returns the NFT metadata as a CBOR object and NOT JSON. You may expect a JSON object, but actually Cardano has no concept of on-chain JSON. In fact, on-chain JSON is not even possible! Instead, Cardano stores metadata as CBOR which can then be converted to JSON The conversion of CBOR to JSON is project-dependent, and so Carp instead returns the raw cbor It's up to you to choose how you want to do the JSON conversion. The common case is handled inside the Carp client library.
     * @param policyIdAssetMapType 
     */
    public metadataNft(policyIdAssetMapType: PolicyIdAssetMapType, _options?: Configuration): Observable<Cip25Response> {
        const requestContextPromise = this.requestFactory.metadataNft(policyIdAssetMapType, _options);

        // build promise chain
        let middlewarePreObservable = from<RequestContext>(requestContextPromise);
        for (let middleware of this.configuration.middleware) {
            middlewarePreObservable = middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => middleware.pre(ctx)));
        }

        return middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => this.configuration.httpApi.send(ctx))).
            pipe(mergeMap((response: ResponseContext) => {
                let middlewarePostObservable = of(response);
                for (let middleware of this.configuration.middleware) {
                    middlewarePostObservable = middlewarePostObservable.pipe(mergeMap((rsp: ResponseContext) => middleware.post(rsp)));
                }
                return middlewarePostObservable.pipe(map((rsp: ResponseContext) => this.responseProcessor.metadataNft(rsp)));
            }));
    }

    /**
     * Ordered by `<block.height, transaction.tx_index>`  Note: this endpoint only returns txs that are in a block. Use another tool to see mempool for txs not in a block
     * @param transactionHistoryRequest 
     */
    public transactionHistory(transactionHistoryRequest: TransactionHistoryRequest, _options?: Configuration): Observable<TransactionHistoryResponse> {
        const requestContextPromise = this.requestFactory.transactionHistory(transactionHistoryRequest, _options);

        // build promise chain
        let middlewarePreObservable = from<RequestContext>(requestContextPromise);
        for (let middleware of this.configuration.middleware) {
            middlewarePreObservable = middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => middleware.pre(ctx)));
        }

        return middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => this.configuration.httpApi.send(ctx))).
            pipe(mergeMap((response: ResponseContext) => {
                let middlewarePostObservable = of(response);
                for (let middleware of this.configuration.middleware) {
                    middlewarePostObservable = middlewarePostObservable.pipe(mergeMap((rsp: ResponseContext) => middleware.post(rsp)));
                }
                return middlewarePostObservable.pipe(map((rsp: ResponseContext) => this.responseProcessor.transactionHistory(rsp)));
            }));
    }

    /**
     * Get the outputs for given `<tx hash, output index>` pairs.  This endpoint will return both used AND unused outputs  Note: this endpoint only returns txs that are in a block. Use another tool to see mempool for txs not in a block
     * @param transactionOutputRequest 
     */
    public transactionOutput(transactionOutputRequest: TransactionOutputRequest, _options?: Configuration): Observable<TransactionOutputResponse> {
        const requestContextPromise = this.requestFactory.transactionOutput(transactionOutputRequest, _options);

        // build promise chain
        let middlewarePreObservable = from<RequestContext>(requestContextPromise);
        for (let middleware of this.configuration.middleware) {
            middlewarePreObservable = middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => middleware.pre(ctx)));
        }

        return middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => this.configuration.httpApi.send(ctx))).
            pipe(mergeMap((response: ResponseContext) => {
                let middlewarePostObservable = of(response);
                for (let middleware of this.configuration.middleware) {
                    middlewarePostObservable = middlewarePostObservable.pipe(mergeMap((rsp: ResponseContext) => middleware.post(rsp)));
                }
                return middlewarePostObservable.pipe(map((rsp: ResponseContext) => this.responseProcessor.transactionOutput(rsp)));
            }));
    }

}
