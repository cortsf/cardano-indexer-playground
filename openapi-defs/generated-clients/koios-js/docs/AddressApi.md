# KoiosApi.AddressApi

All URIs are relative to *https://api.koios.rest/api/v0*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addressAssetsPost**](AddressApi.md#addressAssetsPost) | **POST** /address_assets | Address Assets
[**addressInfoPost**](AddressApi.md#addressInfoPost) | **POST** /address_info | Address Information
[**addressTxsPost**](AddressApi.md#addressTxsPost) | **POST** /address_txs | Address Transactions
[**credentialTxsPost**](AddressApi.md#credentialTxsPost) | **POST** /credential_txs | Transactions from payment credentials



## addressAssetsPost

> [Object] addressAssetsPost(opts)

Address Assets

Get the list of all the assets (policy, name and quantity) for given addresses

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AddressApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.addressAssetsPost(opts, (error, data, response) => {
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


## addressInfoPost

> [Object] addressInfoPost(opts)

Address Information

Get address info - balance, associated stake address (if any) and UTxO set for given addresses

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AddressApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.addressInfoPost(opts, (error, data, response) => {
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


## addressTxsPost

> [Object] addressTxsPost(opts)

Address Transactions

Get the transaction hash list of input address array, optionally filtering after specified block height (inclusive)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AddressApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.addressTxsPost(opts, (error, data, response) => {
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


## credentialTxsPost

> [Object] credentialTxsPost(opts)

Transactions from payment credentials

Get the transaction hash list of input payment credential array, optionally filtering after specified block height (inclusive)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AddressApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.credentialTxsPost(opts, (error, data, response) => {
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

