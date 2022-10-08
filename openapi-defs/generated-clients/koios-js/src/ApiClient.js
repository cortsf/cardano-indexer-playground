/**
 * Koios API
 * Koios is best described as a Decentralized and Elastic RESTful query layer for exploring data on Cardano blockchain to consume within applications/wallets/explorers/etc.  > Note: While we've done sufficient ground work - we're still going through testing/learning/adapting phase based on feedback. Feel free to give it a go, but just remember it is not yet finalized for production consumption and will be refreshed weekly (Saturday 8am UTC).  # Problems solved by Koios - As the size of blockchain grows rapidly, we're looking at increasingly expensive resources and maintenance costs (financially as well as time-wise) to maintain a scalable solution that will automatically failover and have health-checks, ensuring most synched versions are returned. With Koios, anyone is free to either add their backend instance to the cluster, or use the query layer without running a node or cardano-db-sync instance themselves. There will be health-checks for each endpoint to ensure that connections do not go to a dud backend with stale information. - Moreover, folks who do put in tremendous amount of efforts to go through discovery phrase - are often ending up with local solutions, that may not be consistent across the board (e.g. Live Stake queries across existing explorers). Since all the queries used by/for Koios layer is on GitHub, anyone can contribute or leverage the query knowledge base, and help each other out while doing so. An additional endpoint added will only be load balanced between the servers that pass the health-check for the endpoint. - It is almost impossible to fetch some live data (for example, Live Stake against a pool) due to the cost of computation and amount of data on chain. For  such queries, many folks are already using different cache methods, or capturing ledger information from node. Wouldn't it be nice to have these crunched data that take quite a few minutes to run be shared and available to be able to pick a relatively recent execution across the nodes? This will be available out of the box as part of Koios API. - There is also a worry when going through updates about feasibility/breaking changes/etc. that can become a bottleneck for providers. Since Koios participants automatically receive failover support, they reduce impact of any subset of clusters going through update process. - The lightweight query layers currently present are unfortunately closed source, centralised, and create a single point of failure. With Koios, our aim is to give enough flexibility to all the participants to select their backend, or pick from any of the available ones instead. - Bad human errors causing an outage? The bandwidth for Koios becomes better with more participation, but just in case there is not enough participation - we will ensure that at least 4 trusted Koios instances across the globe will be around for the initial year, allowing for enough time for adoption to build up gradually. - Flexibility to participate at different levels. A consumer of these services can participate with a complete independent instance (optionally extend existing ones), by running only certain parts (e.g. submit-api or PostgREST only), or simply consuming the API without running anything locally.  # Architecture  ## How does Koios work?  ![High-Level architecture overview](/koios-design.png)  We will go bottom to top (from builder's eyes to run through the above) briefly:  - *Instance(s)* : These are essentially [PostgREST](https://postgrest.org/en/latest/) instances with the REST service attached to Postgres DB populated using [cardano-db-sync](https://cardano-community.github.io/guild-operators/Build/dbsync/). Every consumer who is providing their own instance will be expected to serve at least a PostgREST instance, as this is what allows us to string instances together after health-checks. If using guild-operator setup instructions, these will be provisioned for you by setup scripts. - *Health-check Services* : These are lightweight [HAProxy](http://www.haproxy.org) instances that will be gatekeepers for individual endpoints, handling health-checks, sample data verification, etc. A builder _may_ opt-in to run this monitoring service, and add their instance to GitHub repository. Again, setting up HAProxy will be part of setup scripts on guild-operator's repo for those interested. - *DNS Routing* : These will be the entry points from monitoring layer to trusted instances that will route to health-check proxy services. We will be using at least two DNS servers ourselves to not have single point of failure, but that does not limit users to elect any of the other server endpoints instead, since the API works right from the PostgREST layer itself.  # API Usage  The endpoints served by Koios can be browsed from the left side bar of this site. You will find that almost each endpoint has an example that you can `Try` and will help you get an example in shell using cURL. For public queries, you do not need to register yourself - you can simply use them as per the examples provided on individual endpoints. But in addition, the [PostgREST API](https://postgrest.org/en/stable/api.html) used underneath provides a handful of features that can be quite handy for you to improve your queries to directly grab very specific information pertinent to your calls, reducing data you download and process.  ## Vertical Filtering  Instead of returning entire row, you can elect which rows you would like to fetch from the endpoint by using the `select` parameter with corresponding columns separated by commas. See example below (first is complete information for tip, while second command gives us 3 columns we are interested in):<br><br>  ``` bash curl \"https://api.koios.rest/api/v0/tip\"  # [{\"hash\":\"4d44c8a453e677f933c3df42ebcf2fe45987c41268b9cfc9b42ae305e8c3d99a\",\"epoch\":317,\"abs_slot\":51700871,\"epoch_slot\":120071,\"block_height\":6806994,\"block_time\":1643267162}]  curl \"https://api.koios.rest/api/v0/blocks?select=epoch,epoch_slot,block_height\"  # [{\"epoch\":317,\"epoch_slot\":120071,\"block_height\":6806994}] ```  ## Horizontal Filtering  You can filter the returned output based on specific conditions using operators against a column within returned result. Consider an example where you would want to query blocks minted in first 3 minutes of epoch 250 (i.e. epoch_slot was less than 180). To do so your query would look like below:<br><br> ``` bash curl \"https://api.koios.rest/api/v0/blocks?epoch=eq.250&epoch_slot=lt.180\"  # [{\"hash\":\"8fad2808ac6b37064a0fa69f6fe065807703d5235a57442647bbcdba1c02faf8\",\"epoch\":250,\"abs_slot\":22636942,\"epoch_slot\":142,\"block_height\":5385757,\"block_time\":1614203233,\"tx_count\":65,\"vrf_key\":\"vrf_vk14y9pjprzlsjvjt66mv5u7w7292sxp3kn4ewhss45ayjga5vurgaqhqknuu\",\"pool\":null,\"op_cert_counter\":2}, #  {\"hash\":\"9d33b02badaedc0dedd0d59f3e0411e5fb4ac94217fb5ee86719e8463c570e16\",\"epoch\":250,\"abs_slot\":22636800,\"epoch_slot\":0,\"block_height\":5385756,\"block_time\":1614203091,\"tx_count\":10,\"vrf_key\":\"vrf_vk1dkfsejw3h2k7tnguwrauqfwnxa7wj3nkp3yw2yw3400c4nlkluwqzwvka6\",\"pool\":null,\"op_cert_counter\":2}] ```  Here, we made use of `eq.` operator to denote a filter of \"value equal to\" against `epoch` column. Similarly, we added a filter using `lt.` operator to denote a filter of \"values lower than\" against `epoch_slot` column. You can find a complete list of operators supported in PostgREST documentation (commonly used ones extracted below):  |Abbreviation|In PostgreSQL|Meaning                                    | |------------|-------------|-------------------------------------------| |eq          |`=`          |equals                                     | |gt          |`>`          |greater than                               | |gte         |`>=`         |greater than or equal                      | |lt          |`<`          |less than                                  | |lte         |`<=`         |less than or equal                         | |neq         |`<>` or `!=` |not equal                                  | |like        |`LIKE`       |LIKE operator (use * in place of %)        | |in          |`IN`         |one of a list of values, e.g. `?a=in.(\"hi,there\",\"yes,you\")`| |is          |`IS`         |checking for exact equality (null,true,false,unknown)| |cs          |`@>`         |contains e.g. `?tags=cs.{example, new}`    | |cd          |`<@`         |contained in e.g. `?values=cd.{1,2,3}`     | |not         |`NOT`        |negates another operator                   | |or          |`OR`         |logical `OR` operator                      | |and         |`AND`        |logical `AND` operator                     |  ## Pagination (offset/limit)  When you query any endpoint in PostgREST, the number of observations returned will be limited to a maximum of 1000 rows (set via `max-rows` config option in the `grest.conf` file. This - however - is a result of a paginated call, wherein the [ up to ] 1000 records you see without any parameters is the first page. If you want to see the next 1000 results, you can always append `offset=1000` to view the next set of results. But what if 1000 is too high for your use-case and you want smaller page? Well, you can specify a smaller limit using parameter `limit`, which will see shortly in an example below. The obvious question at this point that would cross your mind is - how do I know if I need to offset and what range I am querying? This is where headers come in to your aid.    The default headers returned by PostgREST will include a `Content-Range` field giving a range of observations returned. For large tables, this range could include a wildcard `*` as it is expensive to query exact count of observations from endpoint. But if you would like to get an estimate count without overloading servers, PostgREST can utilise Postgres's own maintenance thread results (which maintain stats for each table) to provide you a count, by specifying a header `\"Profile: count=estimated\"`.    Sounds confusing? Let's see this in practice, to hopefully make it easier. Consider a simple case where I want query `blocks` endpoint for `block_height` column and focus on `content-range` header to monitor the rows we discussed above.<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=block_height\" -I | grep -i content-range  # content-range: 0-999/_*  ```  As we can see above, the number of observations returned was 1000 (range being 0-999), but the total size was not queried to avoid wait times. Now, let's modify this default behaviour to query rows beyond the first 999, but this time - also add another clause to limit results by 500. We can do this using `offset=1000` and `limit=500` as below:<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=block_height&offset=1000&limit=500\" -I | grep -i content-range  # content-range: 1000-1499/_*  ```  There is also another method to achieve the above, instead of adding parameters to the URL itself, you can specify a `Range` header as below to achieve something similar:<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=block_height\" -H \"Range: 1000-1499\" -I | grep -i content-range  # content-range: 1000-1499/_*  ```  The above methods for pagination are very useful to keep your queries light as well as process the output in smaller pages, making better use of your resources and respecting server timeouts for response times.  ## Ordering  You can set a sorting order for returned queries against specific column(s). Consider example where you want to check `epoch` and `epoch_slot` for the first 5 blocks created by a particular pool, i.e. you can set order to ascending based on block_height column and add horizontal filter for that pool ID as below:<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?pool=eq.pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc&order=block_height.asc&limit=5\"  # [{\"hash\":\"610b4c7bbebeeb212bd002885048cc33154ba29f39919d62a3d96de05d315706\",\"epoch\":236,\"abs_slot\":16594295,\"epoch_slot\":5495,\"block_height\":5086774,\"block_time\":1608160586,\"tx_count\":1,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"d93d1db5275329ab695d30c06a35124038d8d9af64fc2b0aa082b8aa43da4164\",\"epoch\":236,\"abs_slot\":16597729,\"epoch_slot\":8929,\"block_height\":5086944,\"block_time\":1608164020,\"tx_count\":7,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"dc9496eae64294b46f07eb20499ae6dae4d81fdc67c63c354397db91bda1ee55\",\"epoch\":236,\"abs_slot\":16598058,\"epoch_slot\":9258,\"block_height\":5086962,\"block_time\":1608164349,\"tx_count\":1,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"6ebc7b734c513bc19290d96ca573a09cac9503c5a349dd9892b9ab43f917f9bd\",\"epoch\":236,\"abs_slot\":16601491,\"epoch_slot\":12691,\"block_height\":5087097,\"block_time\":1608167782,\"tx_count\":0,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"2eac97548829fc312858bc56a40f7ce3bf9b0ca27ee8530283ccebb3963de1c0\",\"epoch\":236,\"abs_slot\":16602308,\"epoch_slot\":13508,\"block_height\":5087136,\"block_time\":1608168599,\"tx_count\":1,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}] ```  ## Response Formats  You can get the results from the PostgREST endpoints in CSV or JSON formats. The default response format will always be JSON, but if you'd like to switch, you can do so by specifying header `'Accept: text/csv'` or `'Accept: application/json'`. Below is an example of JSON/CSV output making use of above to print first in JSON (default), and then override response format to CSV.<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=epoch,epoch_slot,block_time&limit=3\"  # [{\"epoch\":318,\"epoch_slot\":27867,\"block_time\":1643606958}, # {\"epoch\":318,\"epoch_slot\":27841,\"block_time\":1643606932}, # {\"epoch\":318,\"epoch_slot\":27839,\"block_time\":1643606930}]  curl -s \"https://api.koios.rest/api/v0/blocks?select=epoch,epoch_slot,block_time&limit=3\" -H \"Accept: text/csv\"  # epoch,epoch_slot,block_time # 318,28491,1643607582 # 318,28479,1643607570 # 318,28406,1643607497  ```  ## Limits  While use of Koios is completely free and there are no registration requirements to the usage, the monitoring layer will only restrict spam requests that can potentially cause high amount of load to backends. The emphasis is on using list of objects first, and then [bulk where available] query specific objects to drill down where possible - which forms higher performance results to consumer as well as instance provider. Some basic protection against patterns that could cause unexpected resource spikes are protected as per below:    - Burst Limit: A single IP can query an endpoint up to 100 times within 10 seconds (that's about 8.64 million requests within a day). The sleep time if a limit is crossed is minimal (60 seconds) for that IP - during which, the monitoring layer will return HTTP Status `429 - Too many requests`.     - Pagination/Limits: Any query results fetched will be paginated by 1000 records (you can reduce limit and or control pagination offsets on URL itself, see API > Pagination section for more details).   - Query timeout: If a query from server takes more than 30 seconds, it will return a HTTP Status of `504 - Gateway timeout`. This is because we would want to ensure you're using the queries optimally, and more often than not - it would indicate that particular endpoint is not optimised (or the network connectivity is not optimal between servers).  Yet, there may be cases where the above restrictions may need exceptions (for example, an explorer or a wallet might need more connections than above - going beyond the Burst Limit). For such cases, it is best to approach the team and we can work towards a solution.   # Community projects  A big thank you to the following projects who are already starting to use Koios from early days:  ## CLI    - [Koios CLI in GoLang](https://github.com/cardano-community/koios-cli)  ## Libraries    - [.Net SDK](https://github.com/CardanoSharp/cardanosharp-koios)   - [Go Client](https://github.com/cardano-community/koios-go-client)   - [Java Client](https://github.com/cardano-community/koios-java-client)  ## Community Projects/Tools    - [Building On Cardano](https://buildingoncardano.com)   - [CardaStat](cardastat.info)   - [CNFT.IO](https://cnft.io)   - [CNTools](https://cardano-community.github.io/guild-operators/Scripts/cntools/)   - [Dandelion](https://dandelion.link)   - [Eternl](https://eternl.io/)   - [PoolPeek](https://poolpeek.com)  # FAQ  ### Is there a price attached to using services? For most of the queries, there are no charges. But there are DDoS protection and strict timeout rules (see API Usage) that may prevent heavy consumers from using this *remotely* (for which, there should be an interaction to ensure the usage is proportional to sizing and traffic expected).  ### Who are the folks behind Koios? It will be increasing list of community builders. But for initial think-tank and efforts, the work done is primarily by [guild-operators](https://cardano-community.github.io/guild-operators) who are a well-recognised team of members behind Cardano tools like CNTools, gLiveView, topologyUpdater, etc. We also run a parallel a short (60-min) epoch blockchain, viz, guild used by many for experiments.  ### I am only interested in collaborating on queries, where can I find the code and how to collaborate? All the Postgres codebase against db-sync instance is available on guild-operator's github repo [here](https://github.com/cardano-community/guild-operators/tree/alpha/files/grest/rpc). Feel free to raise an issue/PR to discuss anything related to those queries.  ### I am not sure how to set up an instance. Is there an easy start guide? Yes, there is a setup script (expect you to read carefully the help section) and instructions [here](https://cardano-community.github.io/guild-operators/Build/grest/). Should you need any assistance, feel free to hop in to the [discussion group](https://t.me/joinchat/+zE4Lce_QUepiY2U1).  ### Too much reading, I want to discuss in person There are bi-weekly calls held that anyone is free to join - or you can drop in to the [telegram group](https://t.me/+zE4Lce_QUepiY2U1) and start a discussion from there. 
 *
 * The version of the OpenAPI document: 1.0.6
 * 
 *
 * NOTE: This class is auto generated by OpenAPI Generator (https://openapi-generator.tech).
 * https://openapi-generator.tech
 * Do not edit the class manually.
 *
 */


import superagent from "superagent";
import querystring from "querystring";

/**
* @module ApiClient
* @version 1.0.6
*/

/**
* Manages low level client-server communications, parameter marshalling, etc. There should not be any need for an
* application to use this class directly - the *Api and model classes provide the public API for the service. The
* contents of this file should be regarded as internal but are documented for completeness.
* @alias module:ApiClient
* @class
*/
class ApiClient {
    /**
     * The base URL against which to resolve every API call's (relative) path.
     * Overrides the default value set in spec file if present
     * @param {String} basePath
     */
    constructor(basePath = 'https://api.koios.rest/api/v0') {
        /**
         * The base URL against which to resolve every API call's (relative) path.
         * @type {String}
         * @default https://api.koios.rest/api/v0
         */
        this.basePath = basePath.replace(/\/+$/, '');

        /**
         * The authentication methods to be included for all API calls.
         * @type {Array.<String>}
         */
        this.authentications = {
        }

        /**
         * The default HTTP headers to be included for all API calls.
         * @type {Array.<String>}
         * @default {}
         */
        this.defaultHeaders = {
            'User-Agent': 'OpenAPI-Generator/1.0.6/Javascript'
        };

        /**
         * The default HTTP timeout for all API calls.
         * @type {Number}
         * @default 60000
         */
        this.timeout = 60000;

        /**
         * If set to false an additional timestamp parameter is added to all API GET calls to
         * prevent browser caching
         * @type {Boolean}
         * @default true
         */
        this.cache = true;

        /**
         * If set to true, the client will save the cookies from each server
         * response, and return them in the next request.
         * @default false
         */
        this.enableCookies = false;

        /*
         * Used to save and return cookies in a node.js (non-browser) setting,
         * if this.enableCookies is set to true.
         */
        if (typeof window === 'undefined') {
          this.agent = new superagent.agent();
        }

        /*
         * Allow user to override superagent agent
         */
         this.requestAgent = null;

        /*
         * Allow user to add superagent plugins
         */
        this.plugins = null;

    }

    /**
    * Returns a string representation for an actual parameter.
    * @param param The actual parameter.
    * @returns {String} The string representation of <code>param</code>.
    */
    paramToString(param) {
        if (param == undefined || param == null) {
            return '';
        }
        if (param instanceof Date) {
            return param.toJSON();
        }
        if (ApiClient.canBeJsonified(param)) {
            return JSON.stringify(param);
        }

        return param.toString();
    }

    /**
    * Returns a boolean indicating if the parameter could be JSON.stringified
    * @param param The actual parameter
    * @returns {Boolean} Flag indicating if <code>param</code> can be JSON.stringified
    */
    static canBeJsonified(str) {
        if (typeof str !== 'string' && typeof str !== 'object') return false;
        try {
            const type = str.toString();
            return type === '[object Object]'
                || type === '[object Array]';
        } catch (err) {
            return false;
        }
    };

   /**
    * Builds full URL by appending the given path to the base URL and replacing path parameter place-holders with parameter values.
    * NOTE: query parameters are not handled here.
    * @param {String} path The path to append to the base URL.
    * @param {Object} pathParams The parameter values to append.
    * @param {String} apiBasePath Base path defined in the path, operation level to override the default one
    * @returns {String} The encoded path with parameter values substituted.
    */
    buildUrl(path, pathParams, apiBasePath) {
        if (!path.match(/^\//)) {
            path = '/' + path;
        }

        var url = this.basePath + path;

        // use API (operation, path) base path if defined
        if (apiBasePath !== null && apiBasePath !== undefined) {
            url = apiBasePath + path;
        }

        url = url.replace(/\{([\w-\.]+)\}/g, (fullMatch, key) => {
            var value;
            if (pathParams.hasOwnProperty(key)) {
                value = this.paramToString(pathParams[key]);
            } else {
                value = fullMatch;
            }

            return encodeURIComponent(value);
        });

        return url;
    }

    /**
    * Checks whether the given content type represents JSON.<br>
    * JSON content type examples:<br>
    * <ul>
    * <li>application/json</li>
    * <li>application/json; charset=UTF8</li>
    * <li>APPLICATION/JSON</li>
    * </ul>
    * @param {String} contentType The MIME content type to check.
    * @returns {Boolean} <code>true</code> if <code>contentType</code> represents JSON, otherwise <code>false</code>.
    */
    isJsonMime(contentType) {
        return Boolean(contentType != null && contentType.match(/^application\/json(;.*)?$/i));
    }

    /**
    * Chooses a content type from the given array, with JSON preferred; i.e. return JSON if included, otherwise return the first.
    * @param {Array.<String>} contentTypes
    * @returns {String} The chosen content type, preferring JSON.
    */
    jsonPreferredMime(contentTypes) {
        for (var i = 0; i < contentTypes.length; i++) {
            if (this.isJsonMime(contentTypes[i])) {
                return contentTypes[i];
            }
        }

        return contentTypes[0];
    }

    /**
    * Checks whether the given parameter value represents file-like content.
    * @param param The parameter to check.
    * @returns {Boolean} <code>true</code> if <code>param</code> represents a file.
    */
    isFileParam(param) {
        // fs.ReadStream in Node.js and Electron (but not in runtime like browserify)
        if (typeof require === 'function') {
            let fs;
            try {
                fs = require('fs');
            } catch (err) {}
            if (fs && fs.ReadStream && param instanceof fs.ReadStream) {
                return true;
            }
        }

        // Buffer in Node.js
        if (typeof Buffer === 'function' && param instanceof Buffer) {
            return true;
        }

        // Blob in browser
        if (typeof Blob === 'function' && param instanceof Blob) {
            return true;
        }

        // File in browser (it seems File object is also instance of Blob, but keep this for safe)
        if (typeof File === 'function' && param instanceof File) {
            return true;
        }

        return false;
    }

    /**
    * Normalizes parameter values:
    * <ul>
    * <li>remove nils</li>
    * <li>keep files and arrays</li>
    * <li>format to string with `paramToString` for other cases</li>
    * </ul>
    * @param {Object.<String, Object>} params The parameters as object properties.
    * @returns {Object.<String, Object>} normalized parameters.
    */
    normalizeParams(params) {
        var newParams = {};
        for (var key in params) {
            if (params.hasOwnProperty(key) && params[key] != undefined && params[key] != null) {
                var value = params[key];
                if (this.isFileParam(value) || Array.isArray(value)) {
                    newParams[key] = value;
                } else {
                    newParams[key] = this.paramToString(value);
                }
            }
        }

        return newParams;
    }

    /**
    * Builds a string representation of an array-type actual parameter, according to the given collection format.
    * @param {Array} param An array parameter.
    * @param {module:ApiClient.CollectionFormatEnum} collectionFormat The array element separator strategy.
    * @returns {String|Array} A string representation of the supplied collection, using the specified delimiter. Returns
    * <code>param</code> as is if <code>collectionFormat</code> is <code>multi</code>.
    */
    buildCollectionParam(param, collectionFormat) {
        if (param == null) {
            return null;
        }
        switch (collectionFormat) {
            case 'csv':
                return param.map(this.paramToString, this).join(',');
            case 'ssv':
                return param.map(this.paramToString, this).join(' ');
            case 'tsv':
                return param.map(this.paramToString, this).join('\t');
            case 'pipes':
                return param.map(this.paramToString, this).join('|');
            case 'multi':
                //return the array directly as SuperAgent will handle it as expected
                return param.map(this.paramToString, this);
            case 'passthrough':
                return param;
            default:
                throw new Error('Unknown collection format: ' + collectionFormat);
        }
    }

    /**
    * Applies authentication headers to the request.
    * @param {Object} request The request object created by a <code>superagent()</code> call.
    * @param {Array.<String>} authNames An array of authentication method names.
    */
    applyAuthToRequest(request, authNames) {
        authNames.forEach((authName) => {
            var auth = this.authentications[authName];
            switch (auth.type) {
                case 'basic':
                    if (auth.username || auth.password) {
                        request.auth(auth.username || '', auth.password || '');
                    }

                    break;
                case 'bearer':
                    if (auth.accessToken) {
                        var localVarBearerToken = typeof auth.accessToken === 'function'
                          ? auth.accessToken()
                          : auth.accessToken
                        request.set({'Authorization': 'Bearer ' + localVarBearerToken});
                    }

                    break;
                case 'apiKey':
                    if (auth.apiKey) {
                        var data = {};
                        if (auth.apiKeyPrefix) {
                            data[auth.name] = auth.apiKeyPrefix + ' ' + auth.apiKey;
                        } else {
                            data[auth.name] = auth.apiKey;
                        }

                        if (auth['in'] === 'header') {
                            request.set(data);
                        } else {
                            request.query(data);
                        }
                    }

                    break;
                case 'oauth2':
                    if (auth.accessToken) {
                        request.set({'Authorization': 'Bearer ' + auth.accessToken});
                    }

                    break;
                default:
                    throw new Error('Unknown authentication type: ' + auth.type);
            }
        });
    }

   /**
    * Deserializes an HTTP response body into a value of the specified type.
    * @param {Object} response A SuperAgent response object.
    * @param {(String|Array.<String>|Object.<String, Object>|Function)} returnType The type to return. Pass a string for simple types
    * or the constructor function for a complex type. Pass an array containing the type name to return an array of that type. To
    * return an object, pass an object with one property whose name is the key type and whose value is the corresponding value type:
    * all properties on <code>data<code> will be converted to this type.
    * @returns A value of the specified type.
    */
    deserialize(response, returnType) {
        if (response == null || returnType == null || response.status == 204) {
            return null;
        }

        // Rely on SuperAgent for parsing response body.
        // See http://visionmedia.github.io/superagent/#parsing-response-bodies
        var data = response.body;
        if (data == null || (typeof data === 'object' && typeof data.length === 'undefined' && !Object.keys(data).length)) {
            // SuperAgent does not always produce a body; use the unparsed response as a fallback
            data = response.text;
        }

        return ApiClient.convertToType(data, returnType);
    }

   /**
    * Callback function to receive the result of the operation.
    * @callback module:ApiClient~callApiCallback
    * @param {String} error Error message, if any.
    * @param data The data returned by the service call.
    * @param {String} response The complete HTTP response.
    */

   /**
    * Invokes the REST service using the supplied settings and parameters.
    * @param {String} path The base URL to invoke.
    * @param {String} httpMethod The HTTP method to use.
    * @param {Object.<String, String>} pathParams A map of path parameters and their values.
    * @param {Object.<String, Object>} queryParams A map of query parameters and their values.
    * @param {Object.<String, Object>} headerParams A map of header parameters and their values.
    * @param {Object.<String, Object>} formParams A map of form parameters and their values.
    * @param {Object} bodyParam The value to pass as the request body.
    * @param {Array.<String>} authNames An array of authentication type names.
    * @param {Array.<String>} contentTypes An array of request MIME types.
    * @param {Array.<String>} accepts An array of acceptable response MIME types.
    * @param {(String|Array|ObjectFunction)} returnType The required type to return; can be a string for simple types or the
    * constructor for a complex type.
    * @param {String} apiBasePath base path defined in the operation/path level to override the default one
    * @param {module:ApiClient~callApiCallback} callback The callback function.
    * @returns {Object} The SuperAgent request object.
    */
    callApi(path, httpMethod, pathParams,
        queryParams, headerParams, formParams, bodyParam, authNames, contentTypes, accepts,
        returnType, apiBasePath, callback) {

        var url = this.buildUrl(path, pathParams, apiBasePath);
        var request = superagent(httpMethod, url);

        if (this.plugins !== null) {
            for (var index in this.plugins) {
                if (this.plugins.hasOwnProperty(index)) {
                    request.use(this.plugins[index])
                }
            }
        }

        // apply authentications
        this.applyAuthToRequest(request, authNames);

        // set query parameters
        if (httpMethod.toUpperCase() === 'GET' && this.cache === false) {
            queryParams['_'] = new Date().getTime();
        }

        request.query(this.normalizeParams(queryParams));

        // set header parameters
        request.set(this.defaultHeaders).set(this.normalizeParams(headerParams));

        // set requestAgent if it is set by user
        if (this.requestAgent) {
          request.agent(this.requestAgent);
        }

        // set request timeout
        request.timeout(this.timeout);

        var contentType = this.jsonPreferredMime(contentTypes);
        if (contentType) {
            // Issue with superagent and multipart/form-data (https://github.com/visionmedia/superagent/issues/746)
            if(contentType != 'multipart/form-data') {
                request.type(contentType);
            }
        }

        if (contentType === 'application/x-www-form-urlencoded') {
            request.send(querystring.stringify(this.normalizeParams(formParams)));
        } else if (contentType == 'multipart/form-data') {
            var _formParams = this.normalizeParams(formParams);
            for (var key in _formParams) {
                if (_formParams.hasOwnProperty(key)) {
                    let _formParamsValue = _formParams[key];
                    if (this.isFileParam(_formParamsValue)) {
                        // file field
                        request.attach(key, _formParamsValue);
                    } else if (Array.isArray(_formParamsValue) && _formParamsValue.length
                        && this.isFileParam(_formParamsValue[0])) {
                        // multiple files
                        _formParamsValue.forEach(file => request.attach(key, file));
                    } else {
                        request.field(key, _formParamsValue);
                    }
                }
            }
        } else if (bodyParam !== null && bodyParam !== undefined) {
            if (!request.header['Content-Type']) {
                request.type('application/json');
            }
            request.send(bodyParam);
        }

        var accept = this.jsonPreferredMime(accepts);
        if (accept) {
            request.accept(accept);
        }

        if (returnType === 'Blob') {
          request.responseType('blob');
        } else if (returnType === 'String') {
          request.responseType('string');
        }

        // Attach previously saved cookies, if enabled
        if (this.enableCookies){
            if (typeof window === 'undefined') {
                this.agent._attachCookies(request);
            }
            else {
                request.withCredentials();
            }
        }

        request.end((error, response) => {
            if (callback) {
                var data = null;
                if (!error) {
                    try {
                        data = this.deserialize(response, returnType);
                        if (this.enableCookies && typeof window === 'undefined'){
                            this.agent._saveCookies(response);
                        }
                    } catch (err) {
                        error = err;
                    }
                }

                callback(error, data, response);
            }
        });

        return request;
    }

    /**
    * Parses an ISO-8601 string representation or epoch representation of a date value.
    * @param {String} str The date value as a string.
    * @returns {Date} The parsed date object.
    */
    static parseDate(str) {
        if (isNaN(str)) {
            return new Date(str.replace(/(\d)(T)(\d)/i, '$1 $3'));
        }
        return new Date(+str);
    }

    /**
    * Converts a value to the specified type.
    * @param {(String|Object)} data The data to convert, as a string or object.
    * @param {(String|Array.<String>|Object.<String, Object>|Function)} type The type to return. Pass a string for simple types
    * or the constructor function for a complex type. Pass an array containing the type name to return an array of that type. To
    * return an object, pass an object with one property whose name is the key type and whose value is the corresponding value type:
    * all properties on <code>data<code> will be converted to this type.
    * @returns An instance of the specified type or null or undefined if data is null or undefined.
    */
    static convertToType(data, type) {
        if (data === null || data === undefined)
            return data

        switch (type) {
            case 'Boolean':
                return Boolean(data);
            case 'Integer':
                return parseInt(data, 10);
            case 'Number':
                return parseFloat(data);
            case 'String':
                return String(data);
            case 'Date':
                return ApiClient.parseDate(String(data));
            case 'Blob':
                return data;
            default:
                if (type === Object) {
                    // generic object, return directly
                    return data;
                } else if (typeof type.constructFromObject === 'function') {
                    // for model type like User and enum class
                    return type.constructFromObject(data);
                } else if (Array.isArray(type)) {
                    // for array type like: ['String']
                    var itemType = type[0];

                    return data.map((item) => {
                        return ApiClient.convertToType(item, itemType);
                    });
                } else if (typeof type === 'object') {
                    // for plain object type like: {'String': 'Integer'}
                    var keyType, valueType;
                    for (var k in type) {
                        if (type.hasOwnProperty(k)) {
                            keyType = k;
                            valueType = type[k];
                            break;
                        }
                    }

                    var result = {};
                    for (var k in data) {
                        if (data.hasOwnProperty(k)) {
                            var key = ApiClient.convertToType(k, keyType);
                            var value = ApiClient.convertToType(data[k], valueType);
                            result[key] = value;
                        }
                    }

                    return result;
                } else {
                    // for unknown type, return the data directly
                    return data;
                }
        }
    }

  /**
    * Gets an array of host settings
    * @returns An array of host settings
    */
    hostSettings() {
        return [
            {
              'url': "https://api.koios.rest/api/v0",
              'description': "No description provided",
            },
            {
              'url': "https://guild.koios.rest/api/v0",
              'description': "No description provided",
            },
            {
              'url': "https://testnet.koios.rest/api/v0",
              'description': "No description provided",
            }
      ];
    }

    getBasePathFromSettings(index, variables={}) {
        var servers = this.hostSettings();

        // check array index out of bound
        if (index < 0 || index >= servers.length) {
            throw new Error("Invalid index " + index + " when selecting the host settings. Must be less than " + servers.length);
        }

        var server = servers[index];
        var url = server['url'];

        // go through variable and assign a value
        for (var variable_name in server['variables']) {
            if (variable_name in variables) {
                let variable = server['variables'][variable_name];
                if ( !('enum_values' in variable) || variable['enum_values'].includes(variables[variable_name]) ) {
                    url = url.replace("{" + variable_name + "}", variables[variable_name]);
                } else {
                    throw new Error("The variable `" + variable_name + "` in the host URL has invalid value " + variables[variable_name] + ". Must be " + server['variables'][variable_name]['enum_values'] + ".");
                }
            } else {
                // use default value
                url = url.replace("{" + variable_name + "}", server['variables'][variable_name]['default_value'])
            }
        }
        return url;
    }

    /**
    * Constructs a new map or array model from REST data.
    * @param data {Object|Array} The REST data.
    * @param obj {Object|Array} The target object or array.
    */
    static constructFromObject(data, obj, itemType) {
        if (Array.isArray(data)) {
            for (var i = 0; i < data.length; i++) {
                if (data.hasOwnProperty(i))
                    obj[i] = ApiClient.convertToType(data[i], itemType);
            }
        } else {
            for (var k in data) {
                if (data.hasOwnProperty(k))
                    obj[k] = ApiClient.convertToType(data[k], itemType);
            }
        }
    };
}

/**
 * Enumeration of collection format separator strategies.
 * @enum {String}
 * @readonly
 */
ApiClient.CollectionFormatEnum = {
    /**
     * Comma-separated values. Value: <code>csv</code>
     * @const
     */
    CSV: ',',

    /**
     * Space-separated values. Value: <code>ssv</code>
     * @const
     */
    SSV: ' ',

    /**
     * Tab-separated values. Value: <code>tsv</code>
     * @const
     */
    TSV: '\t',

    /**
     * Pipe(|)-separated values. Value: <code>pipes</code>
     * @const
     */
    PIPES: '|',

    /**
     * Native array. Value: <code>multi</code>
     * @const
     */
    MULTI: 'multi'
};

/**
* The default API client implementation.
* @type {module:ApiClient}
*/
ApiClient.instance = new ApiClient();
export default ApiClient;
