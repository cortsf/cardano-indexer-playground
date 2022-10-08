# KoiosApi.NetworkApi

All URIs are relative to *https://api.koios.rest/api/v0*

Method | HTTP request | Description
------------- | ------------- | -------------
[**genesisGet**](NetworkApi.md#genesisGet) | **GET** /genesis | Get Genesis info
[**tipGet**](NetworkApi.md#tipGet) | **GET** /tip | Query Chain Tip
[**totalsGet**](NetworkApi.md#totalsGet) | **GET** /totals | Get historical tokenomic stats



## genesisGet

> [Object] genesisGet()

Get Genesis info

Get the Genesis parameters used to start specific era on chain

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.NetworkApi();
apiInstance.genesisGet((error, data, response) => {
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


## tipGet

> [Object] tipGet()

Query Chain Tip

Get the tip info about the latest block seen by chain

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.NetworkApi();
apiInstance.tipGet((error, data, response) => {
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


## totalsGet

> [Object] totalsGet(opts)

Get historical tokenomic stats

Get the circulating utxo, treasury, rewards, supply and reserves in lovelace for specified epoch, all epochs if empty

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.NetworkApi();
let opts = {
  'epochNo': 185 // String | Epoch Number to fetch details for
};
apiInstance.totalsGet(opts, (error, data, response) => {
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
 **epochNo** | **String**| Epoch Number to fetch details for | [optional] 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

