# KoiosApi.ScriptApi

All URIs are relative to *https://api.koios.rest/api/v0*

Method | HTTP request | Description
------------- | ------------- | -------------
[**nativeScriptListGet**](ScriptApi.md#nativeScriptListGet) | **GET** /native_script_list | Native Script List
[**plutusScriptListGet**](ScriptApi.md#plutusScriptListGet) | **GET** /plutus_script_list | Plutus Script List
[**scriptRedeemersGet**](ScriptApi.md#scriptRedeemersGet) | **GET** /script_redeemers | Script Redeemers



## nativeScriptListGet

> [Object] nativeScriptListGet()

Native Script List

List of all existing native script hashes along with their creation transaction hashes

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.ScriptApi();
apiInstance.nativeScriptListGet((error, data, response) => {
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


## plutusScriptListGet

> [Object] plutusScriptListGet()

Plutus Script List

List of all existing Plutus script hashes along with their creation transaction hashes

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.ScriptApi();
apiInstance.plutusScriptListGet((error, data, response) => {
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


## scriptRedeemersGet

> [Object] scriptRedeemersGet(scriptHash)

Script Redeemers

List of all redeemers for a given script hash

### Example

```javascript
import KoiosApi from 'koios_api';

let apiInstance = new KoiosApi.ScriptApi();
let scriptHash = 9a3910acc1e1d49a25eb5798d987739a63f65eb48a78462ffae21e6f; // String | Script hash in hexadecimal format (hex)
apiInstance.scriptRedeemersGet(scriptHash, (error, data, response) => {
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
 **scriptHash** | **String**| Script hash in hexadecimal format (hex) | 

### Return type

**[Object]**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

