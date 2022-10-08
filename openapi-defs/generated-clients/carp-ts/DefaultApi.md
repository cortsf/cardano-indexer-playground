# .DefaultApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addressUsed**](DefaultApi.md#addressUsed) | **POST** /address/used | 
[**addressesForCredential**](DefaultApi.md#addressesForCredential) | **POST** /credential/address | 
[**blockLatest**](DefaultApi.md#blockLatest) | **POST** /block/latest | 
[**metadataNft**](DefaultApi.md#metadataNft) | **POST** /metadata/nft | 
[**transactionHistory**](DefaultApi.md#transactionHistory) | **POST** /transaction/history | 
[**transactionOutput**](DefaultApi.md#transactionOutput) | **POST** /transaction/output | 


# **addressUsed**
> AddressUsedResponse addressUsed(addressUsedRequest)

Ordered lexicographically (order is not maintained)  Warning: the pagination on this endpoint is NOT whether or not an address was used during this block interval, but rather whether or not the address was first used within this interval.  Note: this endpoint only returns addresses that are in a block. Use another tool to see mempool information

### Example


```typescript
import {  } from '';
import * as fs from 'fs';

const configuration = .createConfiguration();
const apiInstance = new .DefaultApi(configuration);

let body:.DefaultApiAddressUsedRequest = {
  // AddressUsedRequest
  addressUsedRequest: null,
};

apiInstance.addressUsed(body).then((data:any) => {
  console.log('API called successfully. Returned data: ' + data);
}).catch((error:any) => console.error(error));
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **addressUsedRequest** | **AddressUsedRequest**|  |


### Return type

**AddressUsedResponse**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** |  |  -  |
**400** |  |  -  |
**409** |  |  -  |
**422** |  |  -  |

[[Back to top]](#) [[Back to API list]](README.md#documentation-for-api-endpoints) [[Back to Model list]](README.md#documentation-for-models) [[Back to README]](README.md)

# **addressesForCredential**
> CredentialAddressResponse addressesForCredential(credentialAddressRequest)

Ordered by the first time the address was seen on-chain  Note: this endpoint only returns addresses that are in a block. Use another tool to see mempool information

### Example


```typescript
import {  } from '';
import * as fs from 'fs';

const configuration = .createConfiguration();
const apiInstance = new .DefaultApi(configuration);

let body:.DefaultApiAddressesForCredentialRequest = {
  // CredentialAddressRequest
  credentialAddressRequest: null,
};

apiInstance.addressesForCredential(body).then((data:any) => {
  console.log('API called successfully. Returned data: ' + data);
}).catch((error:any) => console.error(error));
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **credentialAddressRequest** | **CredentialAddressRequest**|  |


### Return type

**CredentialAddressResponse**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** |  |  -  |
**400** |  |  -  |
**422** |  |  -  |

[[Back to top]](#) [[Back to API list]](README.md#documentation-for-api-endpoints) [[Back to Model list]](README.md#documentation-for-models) [[Back to README]](README.md)

# **blockLatest**
> BlockLatestResponse blockLatest(blockLatestRequest)

Get the latest block. Useful for checking synchronization process and pagination

### Example


```typescript
import {  } from '';
import * as fs from 'fs';

const configuration = .createConfiguration();
const apiInstance = new .DefaultApi(configuration);

let body:.DefaultApiBlockLatestRequest = {
  // BlockLatestRequest
  blockLatestRequest: {
    offset: 3.14,
  },
};

apiInstance.blockLatest(body).then((data:any) => {
  console.log('API called successfully. Returned data: ' + data);
}).catch((error:any) => console.error(error));
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **blockLatestRequest** | **BlockLatestRequest**|  |


### Return type

**BlockLatestResponse**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** |  |  -  |
**400** |  |  -  |
**409** |  |  -  |

[[Back to top]](#) [[Back to API list]](README.md#documentation-for-api-endpoints) [[Back to Model list]](README.md#documentation-for-models) [[Back to README]](README.md)

# **metadataNft**
> Cip25Response metadataNft(policyIdAssetMapType)

Gets the CIP25 metadata for given <policy, asset_name> pairs  Note: policy IDs and asset names MUST be in hex strings. Do not use UTF8 asset names.  Note: This endpoint returns the NFT metadata as a CBOR object and NOT JSON. You may expect a JSON object, but actually Cardano has no concept of on-chain JSON. In fact, on-chain JSON is not even possible! Instead, Cardano stores metadata as CBOR which can then be converted to JSON The conversion of CBOR to JSON is project-dependent, and so Carp instead returns the raw cbor It's up to you to choose how you want to do the JSON conversion. The common case is handled inside the Carp client library.

### Example


```typescript
import {  } from '';
import * as fs from 'fs';

const configuration = .createConfiguration();
const apiInstance = new .DefaultApi(configuration);

let body:.DefaultApiMetadataNftRequest = {
  // PolicyIdAssetMapType
  policyIdAssetMapType: {
    assets: {
      "key": [
        "42657272794e617679",
      ],
    },
  },
};

apiInstance.metadataNft(body).then((data:any) => {
  console.log('API called successfully. Returned data: ' + data);
}).catch((error:any) => console.error(error));
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **policyIdAssetMapType** | **PolicyIdAssetMapType**|  |


### Return type

**Cip25Response**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** |  |  -  |
**400** |  |  -  |
**422** |  |  -  |

[[Back to top]](#) [[Back to API list]](README.md#documentation-for-api-endpoints) [[Back to Model list]](README.md#documentation-for-models) [[Back to README]](README.md)

# **transactionHistory**
> TransactionHistoryResponse transactionHistory(transactionHistoryRequest)

Ordered by `<block.height, transaction.tx_index>`  Note: this endpoint only returns txs that are in a block. Use another tool to see mempool for txs not in a block

### Example


```typescript
import {  } from '';
import * as fs from 'fs';

const configuration = .createConfiguration();
const apiInstance = new .DefaultApi(configuration);

let body:.DefaultApiTransactionHistoryRequest = {
  // TransactionHistoryRequest
  transactionHistoryRequest: null,
};

apiInstance.transactionHistory(body).then((data:any) => {
  console.log('API called successfully. Returned data: ' + data);
}).catch((error:any) => console.error(error));
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **transactionHistoryRequest** | **TransactionHistoryRequest**|  |


### Return type

**TransactionHistoryResponse**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** |  |  -  |
**400** |  |  -  |
**409** |  |  -  |
**422** |  |  -  |

[[Back to top]](#) [[Back to API list]](README.md#documentation-for-api-endpoints) [[Back to Model list]](README.md#documentation-for-models) [[Back to README]](README.md)

# **transactionOutput**
> TransactionOutputResponse transactionOutput(transactionOutputRequest)

Get the outputs for given `<tx hash, output index>` pairs.  This endpoint will return both used AND unused outputs  Note: this endpoint only returns txs that are in a block. Use another tool to see mempool for txs not in a block

### Example


```typescript
import {  } from '';
import * as fs from 'fs';

const configuration = .createConfiguration();
const apiInstance = new .DefaultApi(configuration);

let body:.DefaultApiTransactionOutputRequest = {
  // TransactionOutputRequest
  transactionOutputRequest: {
    utxoPointers: [
      {
        index: 3.14,
        txHash: "011b86557367525891331b4bb985545120efc335b606d6a1c0d5a35fb330f421",
      },
    ],
  },
};

apiInstance.transactionOutput(body).then((data:any) => {
  console.log('API called successfully. Returned data: ' + data);
}).catch((error:any) => console.error(error));
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **transactionOutputRequest** | **TransactionOutputRequest**|  |


### Return type

**TransactionOutputResponse**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** |  |  -  |
**400** |  |  -  |
**422** |  |  -  |

[[Back to top]](#) [[Back to API list]](README.md#documentation-for-api-endpoints) [[Back to Model list]](README.md#documentation-for-models) [[Back to README]](README.md)


