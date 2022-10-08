# KoiosApi.PoolApi

All URIs are relative to *https://api.koios.rest/api/v0*

Method | HTTP request | Description
------------- | ------------- | -------------
[**poolBlocksGet**](PoolApi.md#poolBlocksGet) | **GET** /pool_blocks | Pool Blocks
[**poolDelegatorsGet**](PoolApi.md#poolDelegatorsGet) | **GET** /pool_delegators | Pool Delegators List
[**poolHistoryGet**](PoolApi.md#poolHistoryGet) | **GET** /pool_history | Pool Stake, Block and Reward History
[**poolInfoPost**](PoolApi.md#poolInfoPost) | **POST** /pool_info | Pool Information
[**poolListGet**](PoolApi.md#poolListGet) | **GET** /pool_list | Pool List
[**poolMetadataPost**](PoolApi.md#poolMetadataPost) | **POST** /pool_metadata | Pool Metadata
[**poolRelaysGet**](PoolApi.md#poolRelaysGet) | **GET** /pool_relays | Pool Relays
[**poolUpdatesGet**](PoolApi.md#poolUpdatesGet) | **GET** /pool_updates | Pool Updates (History)



## poolBlocksGet

> [Object] poolBlocksGet(poolBech32, opts)

Pool Blocks

Return information about blocks minted by a given pool in current epoch (or _epoch_no if provided)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.PoolApi();
let poolBech32 = pool102llj7e7a0mmxssjvjkv2d6lppuh6cz6q9xwc3tsksn0jqwz9eh; // String | Pool ID in bech32 format
let opts = {
  'epochNo': 185 // String | Epoch Number to fetch details for
};
apiInstance.poolBlocksGet(poolBech32, opts, (error, data, response) => {
  if (error) {
    console.error(error);
  } else {
    console.log('API called successfully. Returned data: ' + data);
  }
});
```

### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **poolBech32** | **String**| Pool ID in bech32 format | 
 **epochNo** | **String**| Epoch Number to fetch details for | [optional] 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## poolDelegatorsGet

> [Object] poolDelegatorsGet(poolBech32, opts)

Pool Delegators List

Return information about delegators by a given pool and optional epoch (current if omitted)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.PoolApi();
let poolBech32 = pool102llj7e7a0mmxssjvjkv2d6lppuh6cz6q9xwc3tsksn0jqwz9eh; // String | Pool ID in bech32 format
let opts = {
  'epochNo': 185 // String | Epoch Number to fetch details for
};
apiInstance.poolDelegatorsGet(poolBech32, opts, (error, data, response) => {
  if (error) {
    console.error(error);
  } else {
    console.log('API called successfully. Returned data: ' + data);
  }
});
```

### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **poolBech32** | **String**| Pool ID in bech32 format | 
 **epochNo** | **String**| Epoch Number to fetch details for | [optional] 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## poolHistoryGet

> [Object] poolHistoryGet(poolBech32, opts)

Pool Stake, Block and Reward History

Return information about pool stake, block and reward history in a given epoch _epoch_no (or all epochs that pool existed for, in descending order if no _epoch_no was provided)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.PoolApi();
let poolBech32 = pool102llj7e7a0mmxssjvjkv2d6lppuh6cz6q9xwc3tsksn0jqwz9eh; // String | Pool ID in bech32 format
let opts = {
  'epochNo': 185 // String | Epoch Number to fetch details for
};
apiInstance.poolHistoryGet(poolBech32, opts, (error, data, response) => {
  if (error) {
    console.error(error);
  } else {
    console.log('API called successfully. Returned data: ' + data);
  }
});
```

### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **poolBech32** | **String**| Pool ID in bech32 format | 
 **epochNo** | **String**| Epoch Number to fetch details for | [optional] 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## poolInfoPost

> [Object] poolInfoPost(opts)

Pool Information

Current pool statuses and details for a specified list of pool ids

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.PoolApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.poolInfoPost(opts, (error, data, response) => {
  if (error) {
    console.error(error);
  } else {
    console.log('API called successfully. Returned data: ' + data);
  }
});
```

### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **UNKNOWN_BASE_TYPE** | [**UNKNOWN_BASE_TYPE**](UNKNOWN_BASE_TYPE.md)|  | [optional] 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json


## poolListGet

> [Object] poolListGet()

Pool List

A list of all currently registered/retiring (not retired) pools

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.PoolApi();
apiInstance.poolListGet((error, data, response) => {
  if (error) {
    console.error(error);
  } else {
    console.log('API called successfully. Returned data: ' + data);
  }
});
```

### Parameters

This endpoint does not need any parameter.

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## poolMetadataPost

> [Object] poolMetadataPost(opts)

Pool Metadata

Metadata (on &amp; off-chain) for all currently registered/retiring (not retired) pools

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.PoolApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.poolMetadataPost(opts, (error, data, response) => {
  if (error) {
    console.error(error);
  } else {
    console.log('API called successfully. Returned data: ' + data);
  }
});
```

### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **UNKNOWN_BASE_TYPE** | [**UNKNOWN_BASE_TYPE**](UNKNOWN_BASE_TYPE.md)|  | [optional] 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json


## poolRelaysGet

> [Object] poolRelaysGet()

Pool Relays

A list of registered relays for all currently registered/retiring (not retired) pools

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.PoolApi();
apiInstance.poolRelaysGet((error, data, response) => {
  if (error) {
    console.error(error);
  } else {
    console.log('API called successfully. Returned data: ' + data);
  }
});
```

### Parameters

This endpoint does not need any parameter.

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## poolUpdatesGet

> [Object] poolUpdatesGet(opts)

Pool Updates (History)

Return all pool updates for all pools or only updates for specific pool if specified

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.PoolApi();
let opts = {
  'poolBech32': pool102llj7e7a0mmxssjvjkv2d6lppuh6cz6q9xwc3tsksn0jqwz9eh // String | Pool ID in bech32 format (optional)
};
apiInstance.poolUpdatesGet(opts, (error, data, response) => {
  if (error) {
    console.error(error);
  } else {
    console.log('API called successfully. Returned data: ' + data);
  }
});
```

### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **poolBech32** | **String**| Pool ID in bech32 format (optional) | [optional] 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

