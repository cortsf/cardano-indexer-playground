# KoiosApi.AccountApi

All URIs are relative to *https://api.koios.rest/api/v0*

Method | HTTP request | Description
------------- | ------------- | -------------
[**accountAddressesPost**](AccountApi.md#accountAddressesPost) | **POST** /account_addresses | Account Addresses
[**accountAssetsPost**](AccountApi.md#accountAssetsPost) | **POST** /account_assets | Account Assets
[**accountHistoryPost**](AccountApi.md#accountHistoryPost) | **POST** /account_history | Account History
[**accountInfoPost**](AccountApi.md#accountInfoPost) | **POST** /account_info | Account Information
[**accountListGet**](AccountApi.md#accountListGet) | **GET** /account_list | Account List
[**accountRewardsPost**](AccountApi.md#accountRewardsPost) | **POST** /account_rewards | Account Rewards
[**accountUpdatesPost**](AccountApi.md#accountUpdatesPost) | **POST** /account_updates | Account Updates



## accountAddressesPost

> [Object] accountAddressesPost(opts)

Account Addresses

Get all addresses associated with given staking accounts

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AccountApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.accountAddressesPost(opts, (error, data, response) => {
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


## accountAssetsPost

> [Object] accountAssetsPost(opts)

Account Assets

Get the native asset balance of given accounts

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AccountApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.accountAssetsPost(opts, (error, data, response) => {
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


## accountHistoryPost

> [Object] accountHistoryPost(opts)

Account History

Get the staking history of given stake addresses (accounts)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AccountApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.accountHistoryPost(opts, (error, data, response) => {
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


## accountInfoPost

> [Object] accountInfoPost(opts)

Account Information

Get the account information for given stake addresses (accounts)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AccountApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.accountInfoPost(opts, (error, data, response) => {
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


## accountListGet

> [Object] accountListGet()

Account List

Get a list of all accounts

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AccountApi();
apiInstance.accountListGet((error, data, response) => {
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


## accountRewardsPost

> [Object] accountRewardsPost(opts)

Account Rewards

Get the full rewards history (including MIR) for given stake addresses (accounts)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AccountApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.accountRewardsPost(opts, (error, data, response) => {
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


## accountUpdatesPost

> [Object] accountUpdatesPost(opts)

Account Updates

Get the account updates (registration, deregistration, delegation and withdrawals) for given stake addresses (accounts)

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.AccountApi();
let opts = {
  'UNKNOWN_BASE_TYPE': {key: null} // UNKNOWN_BASE_TYPE | 
};
apiInstance.accountUpdatesPost(opts, (error, data, response) => {
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

