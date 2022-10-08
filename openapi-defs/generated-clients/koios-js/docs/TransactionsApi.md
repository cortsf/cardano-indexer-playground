# KoiosApi.TransactionsApi

All URIs are relative to *https://api.koios.rest/api/v0*

Method | HTTP request | Description
------------- | ------------- | -------------
[**submittxPost**](TransactionsApi.md#submittxPost) | **POST** /submittx | Submit Transaction
[**txInfoPost**](TransactionsApi.md#txInfoPost) | **POST** /tx_info | Transaction Information
[**txMetadataPost**](TransactionsApi.md#txMetadataPost) | **POST** /tx_metadata | Transaction Metadata
[**txMetalabelsGet**](TransactionsApi.md#txMetalabelsGet) | **GET** /tx_metalabels | Transaction Metadata Labels
[**txStatusPost**](TransactionsApi.md#txStatusPost) | **POST** /tx_status | Transaction Status (Block Confirmations)
[**txUtxosPost**](TransactionsApi.md#txUtxosPost) | **POST** /tx_utxos | Transaction UTxOs



## submittxPost

> String submittxPost(opts)

Submit Transaction

Submit an already serialized transaction to the network.

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.TransactionsApi();
let opts = {
  'body': "/path/to/file" // File | 
};
apiInstance.submittxPost(opts, (error, data, response) => {
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
 **body** | **File**|  | [optional] 

### Return type

**String**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: application/cbor
- **Accept**: application/json


## txInfoPost

> [Object] txInfoPost(opts)

Transaction Information

Get detailed information about transaction(s)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.TransactionsApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.txInfoPost(opts, (error, data, response) => {
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


## txMetadataPost

> [Object] txMetadataPost(opts)

Transaction Metadata

Get metadata information (if any) for given transaction(s)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.TransactionsApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.txMetadataPost(opts, (error, data, response) => {
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


## txMetalabelsGet

> [Object] txMetalabelsGet()

Transaction Metadata Labels

Get a list of all transaction metalabels

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.TransactionsApi();
apiInstance.txMetalabelsGet((error, data, response) => {
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


## txStatusPost

> [Object] txStatusPost(opts)

Transaction Status (Block Confirmations)

Get the number of block confirmations for a given transaction hash list

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.TransactionsApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.txStatusPost(opts, (error, data, response) => {
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


## txUtxosPost

> [Object] txUtxosPost(opts)

Transaction UTxOs

Get UTxO set (inputs/outputs) of transactions.

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.TransactionsApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.txUtxosPost(opts, (error, data, response) => {
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

