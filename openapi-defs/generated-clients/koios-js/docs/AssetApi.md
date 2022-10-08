# KoiosApi.AssetApi

All URIs are relative to *https://api.koios.rest/api/v0*

Method | HTTP request | Description
------------- | ------------- | -------------
[**assetAddressListGet**](AssetApi.md#assetAddressListGet) | **GET** /asset_address_list | Asset Address List
[**assetHistoryGet**](AssetApi.md#assetHistoryGet) | **GET** /asset_history | Asset History
[**assetInfoGet**](AssetApi.md#assetInfoGet) | **GET** /asset_info | Asset Information
[**assetListGet**](AssetApi.md#assetListGet) | **GET** /asset_list | Asset List
[**assetPolicyInfoGet**](AssetApi.md#assetPolicyInfoGet) | **GET** /asset_policy_info | Asset Policy Information
[**assetSummaryGet**](AssetApi.md#assetSummaryGet) | **GET** /asset_summary | Asset Summary
[**assetTxsGet**](AssetApi.md#assetTxsGet) | **GET** /asset_txs | Asset Transaction History



## assetAddressListGet

> [Object] assetAddressListGet(assetPolicy, opts)

Asset Address List

Get the list of all addresses holding a given asset

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AssetApi();
let assetPolicy = 000327a9e427a3a3256eb6212ae26b7f53f7969b8e62d37ea9138a7b; // String | Asset Policy ID in hexadecimal format (hex)
let opts = {
  'assetName': 54735465737431 // String | Asset Name in hexadecimal format (hex)
};
apiInstance.assetAddressListGet(assetPolicy, opts, (error, data, response) => {
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
 **assetPolicy** | **String**| Asset Policy ID in hexadecimal format (hex) | 
 **assetName** | **String**| Asset Name in hexadecimal format (hex) | [optional] 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## assetHistoryGet

> [Object] assetHistoryGet(assetPolicy, opts)

Asset History

Get the mint/burn history of an asset

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AssetApi();
let assetPolicy = 000327a9e427a3a3256eb6212ae26b7f53f7969b8e62d37ea9138a7b; // String | Asset Policy ID in hexadecimal format (hex)
let opts = {
  'assetName': 54735465737431 // String | Asset Name in hexadecimal format (hex)
};
apiInstance.assetHistoryGet(assetPolicy, opts, (error, data, response) => {
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
 **assetPolicy** | **String**| Asset Policy ID in hexadecimal format (hex) | 
 **assetName** | **String**| Asset Name in hexadecimal format (hex) | [optional] 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## assetInfoGet

> [Object] assetInfoGet(assetPolicy, opts)

Asset Information

Get the information of an asset including first minting &amp; token registry metadata

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AssetApi();
let assetPolicy = 000327a9e427a3a3256eb6212ae26b7f53f7969b8e62d37ea9138a7b; // String | Asset Policy ID in hexadecimal format (hex)
let opts = {
  'assetName': 54735465737431 // String | Asset Name in hexadecimal format (hex)
};
apiInstance.assetInfoGet(assetPolicy, opts, (error, data, response) => {
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
 **assetPolicy** | **String**| Asset Policy ID in hexadecimal format (hex) | 
 **assetName** | **String**| Asset Name in hexadecimal format (hex) | [optional] 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## assetListGet

> [Object] assetListGet()

Asset List

Get the list of all native assets (paginated)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AssetApi();
apiInstance.assetListGet((error, data, response) => {
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


## assetPolicyInfoGet

> [Object] assetPolicyInfoGet(assetPolicy)

Asset Policy Information

Get the information for all assets under the same policy

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AssetApi();
let assetPolicy = 000327a9e427a3a3256eb6212ae26b7f53f7969b8e62d37ea9138a7b; // String | Asset Policy ID in hexadecimal format (hex)
apiInstance.assetPolicyInfoGet(assetPolicy, (error, data, response) => {
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
 **assetPolicy** | **String**| Asset Policy ID in hexadecimal format (hex) | 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## assetSummaryGet

> [Object] assetSummaryGet(assetPolicy, opts)

Asset Summary

Get the summary of an asset (total transactions exclude minting/total wallets include only wallets with asset balance)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AssetApi();
let assetPolicy = 000327a9e427a3a3256eb6212ae26b7f53f7969b8e62d37ea9138a7b; // String | Asset Policy ID in hexadecimal format (hex)
let opts = {
  'assetName': 54735465737431 // String | Asset Name in hexadecimal format (hex)
};
apiInstance.assetSummaryGet(assetPolicy, opts, (error, data, response) => {
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
 **assetPolicy** | **String**| Asset Policy ID in hexadecimal format (hex) | 
 **assetName** | **String**| Asset Name in hexadecimal format (hex) | [optional] 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## assetTxsGet

> [Object] assetTxsGet(assetPolicy, opts)

Asset Transaction History

Get the list of all asset transaction hashes (newest first)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AssetApi();
let assetPolicy = 000327a9e427a3a3256eb6212ae26b7f53f7969b8e62d37ea9138a7b; // String | Asset Policy ID in hexadecimal format (hex)
let opts = {
  'assetName': 54735465737431 // String | Asset Name in hexadecimal format (hex)
};
apiInstance.assetTxsGet(assetPolicy, opts, (error, data, response) => {
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
 **assetPolicy** | **String**| Asset Policy ID in hexadecimal format (hex) | 
 **assetName** | **String**| Asset Name in hexadecimal format (hex) | [optional] 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

