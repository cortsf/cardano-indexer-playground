import { ResponseContext, RequestContext, HttpFile } from '../http/http';
import * as models from '../models/all';
import { Configuration} from '../configuration'

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
import { ObservableDefaultApi } from './ObservableAPI';

import { DefaultApiRequestFactory, DefaultApiResponseProcessor} from "../apis/DefaultApi";
export class PromiseDefaultApi {
    private api: ObservableDefaultApi

    public constructor(
        configuration: Configuration,
        requestFactory?: DefaultApiRequestFactory,
        responseProcessor?: DefaultApiResponseProcessor
    ) {
        this.api = new ObservableDefaultApi(configuration, requestFactory, responseProcessor);
    }

    /**
     * Ordered lexicographically (order is not maintained)  Warning: the pagination on this endpoint is NOT whether or not an address was used during this block interval, but rather whether or not the address was first used within this interval.  Note: this endpoint only returns addresses that are in a block. Use another tool to see mempool information
     * @param addressUsedRequest 
     */
    public addressUsed(addressUsedRequest: AddressUsedRequest, _options?: Configuration): Promise<AddressUsedResponse> {
        const result = this.api.addressUsed(addressUsedRequest, _options);
        return result.toPromise();
    }

    /**
     * Ordered by the first time the address was seen on-chain  Note: this endpoint only returns addresses that are in a block. Use another tool to see mempool information
     * @param credentialAddressRequest 
     */
    public addressesForCredential(credentialAddressRequest: CredentialAddressRequest, _options?: Configuration): Promise<CredentialAddressResponse> {
        const result = this.api.addressesForCredential(credentialAddressRequest, _options);
        return result.toPromise();
    }

    /**
     * Get the latest block. Useful for checking synchronization process and pagination
     * @param blockLatestRequest 
     */
    public blockLatest(blockLatestRequest: BlockLatestRequest, _options?: Configuration): Promise<BlockLatestResponse> {
        const result = this.api.blockLatest(blockLatestRequest, _options);
        return result.toPromise();
    }

    /**
     * Gets the CIP25 metadata for given <policy, asset_name> pairs  Note: policy IDs and asset names MUST be in hex strings. Do not use UTF8 asset names.  Note: This endpoint returns the NFT metadata as a CBOR object and NOT JSON. You may expect a JSON object, but actually Cardano has no concept of on-chain JSON. In fact, on-chain JSON is not even possible! Instead, Cardano stores metadata as CBOR which can then be converted to JSON The conversion of CBOR to JSON is project-dependent, and so Carp instead returns the raw cbor It's up to you to choose how you want to do the JSON conversion. The common case is handled inside the Carp client library.
     * @param policyIdAssetMapType 
     */
    public metadataNft(policyIdAssetMapType: PolicyIdAssetMapType, _options?: Configuration): Promise<Cip25Response> {
        const result = this.api.metadataNft(policyIdAssetMapType, _options);
        return result.toPromise();
    }

    /**
     * Ordered by `<block.height, transaction.tx_index>`  Note: this endpoint only returns txs that are in a block. Use another tool to see mempool for txs not in a block
     * @param transactionHistoryRequest 
     */
    public transactionHistory(transactionHistoryRequest: TransactionHistoryRequest, _options?: Configuration): Promise<TransactionHistoryResponse> {
        const result = this.api.transactionHistory(transactionHistoryRequest, _options);
        return result.toPromise();
    }

    /**
     * Get the outputs for given `<tx hash, output index>` pairs.  This endpoint will return both used AND unused outputs  Note: this endpoint only returns txs that are in a block. Use another tool to see mempool for txs not in a block
     * @param transactionOutputRequest 
     */
    public transactionOutput(transactionOutputRequest: TransactionOutputRequest, _options?: Configuration): Promise<TransactionOutputResponse> {
        const result = this.api.transactionOutput(transactionOutputRequest, _options);
        return result.toPromise();
    }


}



