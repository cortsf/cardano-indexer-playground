# KoiosApi.EpochApi

All URIs are relative to *https://api.koios.rest/api/v0*

Method | HTTP request | Description
------------- | ------------- | -------------
[**epochInfoGet**](EpochApi.md#epochInfoGet) | **GET** /epoch_info | Epoch Information
[**epochParamsGet**](EpochApi.md#epochParamsGet) | **GET** /epoch_params | Epoch&#39;s Protocol Parameters



## epochInfoGet

> [Object] epochInfoGet(opts)

Epoch Information

Get the epoch information, all epochs if no epoch specified

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.EpochApi();
let opts = {
  'epochNo': 185 // String | Epoch Number to fetch details for
};
apiInstance.epochInfoGet(opts, (error, data, response) => {
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


## epochParamsGet

> [Object] epochParamsGet(opts)

Epoch&#39;s Protocol Parameters

Get the protocol parameters for specific epoch, returns information about all epochs if no epoch specified

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.EpochApi();
let opts = {
  'epochNo': 185 // String | Epoch Number to fetch details for
};
apiInstance.epochParamsGet(opts, (error, data, response) => {
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

