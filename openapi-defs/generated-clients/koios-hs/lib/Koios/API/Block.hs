{-
   Koios API

   Koios is best described as a Decentralized and Elastic RESTful query layer for exploring data on Cardano blockchain to consume within applications/wallets/explorers/etc.  > Note: While we've done sufficient ground work - we're still going through testing/learning/adapting phase based on feedback. Feel free to give it a go, but just remember it is not yet finalized for production consumption and will be refreshed weekly (Saturday 8am UTC).  # Problems solved by Koios - As the size of blockchain grows rapidly, we're looking at increasingly expensive resources and maintenance costs (financially as well as time-wise) to maintain a scalable solution that will automatically failover and have health-checks, ensuring most synched versions are returned. With Koios, anyone is free to either add their backend instance to the cluster, or use the query layer without running a node or cardano-db-sync instance themselves. There will be health-checks for each endpoint to ensure that connections do not go to a dud backend with stale information. - Moreover, folks who do put in tremendous amount of efforts to go through discovery phrase - are often ending up with local solutions, that may not be consistent across the board (e.g. Live Stake queries across existing explorers). Since all the queries used by/for Koios layer is on GitHub, anyone can contribute or leverage the query knowledge base, and help each other out while doing so. An additional endpoint added will only be load balanced between the servers that pass the health-check for the endpoint. - It is almost impossible to fetch some live data (for example, Live Stake against a pool) due to the cost of computation and amount of data on chain. For  such queries, many folks are already using different cache methods, or capturing ledger information from node. Wouldn't it be nice to have these crunched data that take quite a few minutes to run be shared and available to be able to pick a relatively recent execution across the nodes? This will be available out of the box as part of Koios API. - There is also a worry when going through updates about feasibility/breaking changes/etc. that can become a bottleneck for providers. Since Koios participants automatically receive failover support, they reduce impact of any subset of clusters going through update process. - The lightweight query layers currently present are unfortunately closed source, centralised, and create a single point of failure. With Koios, our aim is to give enough flexibility to all the participants to select their backend, or pick from any of the available ones instead. - Bad human errors causing an outage? The bandwidth for Koios becomes better with more participation, but just in case there is not enough participation - we will ensure that at least 4 trusted Koios instances across the globe will be around for the initial year, allowing for enough time for adoption to build up gradually. - Flexibility to participate at different levels. A consumer of these services can participate with a complete independent instance (optionally extend existing ones), by running only certain parts (e.g. submit-api or PostgREST only), or simply consuming the API without running anything locally.  # Architecture  ## How does Koios work?  ![High-Level architecture overview](/koios-design.png)  We will go bottom to top (from builder's eyes to run through the above) briefly:  - *Instance(s)* : These are essentially [PostgREST](https://postgrest.org/en/latest/) instances with the REST service attached to Postgres DB populated using [cardano-db-sync](https://cardano-community.github.io/guild-operators/Build/dbsync/). Every consumer who is providing their own instance will be expected to serve at least a PostgREST instance, as this is what allows us to string instances together after health-checks. If using guild-operator setup instructions, these will be provisioned for you by setup scripts. - *Health-check Services* : These are lightweight [HAProxy](http://www.haproxy.org) instances that will be gatekeepers for individual endpoints, handling health-checks, sample data verification, etc. A builder _may_ opt-in to run this monitoring service, and add their instance to GitHub repository. Again, setting up HAProxy will be part of setup scripts on guild-operator's repo for those interested. - *DNS Routing* : These will be the entry points from monitoring layer to trusted instances that will route to health-check proxy services. We will be using at least two DNS servers ourselves to not have single point of failure, but that does not limit users to elect any of the other server endpoints instead, since the API works right from the PostgREST layer itself.  # API Usage  The endpoints served by Koios can be browsed from the left side bar of this site. You will find that almost each endpoint has an example that you can `Try` and will help you get an example in shell using cURL. For public queries, you do not need to register yourself - you can simply use them as per the examples provided on individual endpoints. But in addition, the [PostgREST API](https://postgrest.org/en/stable/api.html) used underneath provides a handful of features that can be quite handy for you to improve your queries to directly grab very specific information pertinent to your calls, reducing data you download and process.  ## Vertical Filtering  Instead of returning entire row, you can elect which rows you would like to fetch from the endpoint by using the `select` parameter with corresponding columns separated by commas. See example below (first is complete information for tip, while second command gives us 3 columns we are interested in):<br><br>  ``` bash curl \"https://api.koios.rest/api/v0/tip\"  # [{\"hash\":\"4d44c8a453e677f933c3df42ebcf2fe45987c41268b9cfc9b42ae305e8c3d99a\",\"epoch\":317,\"abs_slot\":51700871,\"epoch_slot\":120071,\"block_height\":6806994,\"block_time\":1643267162}]  curl \"https://api.koios.rest/api/v0/blocks?select=epoch,epoch_slot,block_height\"  # [{\"epoch\":317,\"epoch_slot\":120071,\"block_height\":6806994}] ```  ## Horizontal Filtering  You can filter the returned output based on specific conditions using operators against a column within returned result. Consider an example where you would want to query blocks minted in first 3 minutes of epoch 250 (i.e. epoch_slot was less than 180). To do so your query would look like below:<br><br> ``` bash curl \"https://api.koios.rest/api/v0/blocks?epoch=eq.250&epoch_slot=lt.180\"  # [{\"hash\":\"8fad2808ac6b37064a0fa69f6fe065807703d5235a57442647bbcdba1c02faf8\",\"epoch\":250,\"abs_slot\":22636942,\"epoch_slot\":142,\"block_height\":5385757,\"block_time\":1614203233,\"tx_count\":65,\"vrf_key\":\"vrf_vk14y9pjprzlsjvjt66mv5u7w7292sxp3kn4ewhss45ayjga5vurgaqhqknuu\",\"pool\":null,\"op_cert_counter\":2}, #  {\"hash\":\"9d33b02badaedc0dedd0d59f3e0411e5fb4ac94217fb5ee86719e8463c570e16\",\"epoch\":250,\"abs_slot\":22636800,\"epoch_slot\":0,\"block_height\":5385756,\"block_time\":1614203091,\"tx_count\":10,\"vrf_key\":\"vrf_vk1dkfsejw3h2k7tnguwrauqfwnxa7wj3nkp3yw2yw3400c4nlkluwqzwvka6\",\"pool\":null,\"op_cert_counter\":2}] ```  Here, we made use of `eq.` operator to denote a filter of \"value equal to\" against `epoch` column. Similarly, we added a filter using `lt.` operator to denote a filter of \"values lower than\" against `epoch_slot` column. You can find a complete list of operators supported in PostgREST documentation (commonly used ones extracted below):  |Abbreviation|In PostgreSQL|Meaning                                    | |------------|-------------|-------------------------------------------| |eq          |`=`          |equals                                     | |gt          |`>`          |greater than                               | |gte         |`>=`         |greater than or equal                      | |lt          |`<`          |less than                                  | |lte         |`<=`         |less than or equal                         | |neq         |`<>` or `!=` |not equal                                  | |like        |`LIKE`       |LIKE operator (use * in place of %)        | |in          |`IN`         |one of a list of values, e.g. `?a=in.(\"hi,there\",\"yes,you\")`| |is          |`IS`         |checking for exact equality (null,true,false,unknown)| |cs          |`@>`         |contains e.g. `?tags=cs.{example, new}`    | |cd          |`<@`         |contained in e.g. `?values=cd.{1,2,3}`     | |not         |`NOT`        |negates another operator                   | |or          |`OR`         |logical `OR` operator                      | |and         |`AND`        |logical `AND` operator                     |  ## Pagination (offset/limit)  When you query any endpoint in PostgREST, the number of observations returned will be limited to a maximum of 1000 rows (set via `max-rows` config option in the `grest.conf` file. This - however - is a result of a paginated call, wherein the [ up to ] 1000 records you see without any parameters is the first page. If you want to see the next 1000 results, you can always append `offset=1000` to view the next set of results. But what if 1000 is too high for your use-case and you want smaller page? Well, you can specify a smaller limit using parameter `limit`, which will see shortly in an example below. The obvious question at this point that would cross your mind is - how do I know if I need to offset and what range I am querying? This is where headers come in to your aid.    The default headers returned by PostgREST will include a `Content-Range` field giving a range of observations returned. For large tables, this range could include a wildcard `*` as it is expensive to query exact count of observations from endpoint. But if you would like to get an estimate count without overloading servers, PostgREST can utilise Postgres's own maintenance thread results (which maintain stats for each table) to provide you a count, by specifying a header `\"Profile: count=estimated\"`.    Sounds confusing? Let's see this in practice, to hopefully make it easier. Consider a simple case where I want query `blocks` endpoint for `block_height` column and focus on `content-range` header to monitor the rows we discussed above.<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=block_height\" -I | grep -i content-range  # content-range: 0-999/*  ```  As we can see above, the number of observations returned was 1000 (range being 0-999), but the total size was not queried to avoid wait times. Now, let's modify this default behaviour to query rows beyond the first 999, but this time - also add another clause to limit results by 500. We can do this using `offset=1000` and `limit=500` as below:<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=block_height&offset=1000&limit=500\" -I | grep -i content-range  # content-range: 1000-1499/*  ```  There is also another method to achieve the above, instead of adding parameters to the URL itself, you can specify a `Range` header as below to achieve something similar:<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=block_height\" -H \"Range: 1000-1499\" -I | grep -i content-range  # content-range: 1000-1499/*  ```  The above methods for pagination are very useful to keep your queries light as well as process the output in smaller pages, making better use of your resources and respecting server timeouts for response times.  ## Ordering  You can set a sorting order for returned queries against specific column(s). Consider example where you want to check `epoch` and `epoch_slot` for the first 5 blocks created by a particular pool, i.e. you can set order to ascending based on block_height column and add horizontal filter for that pool ID as below:<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?pool=eq.pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc&order=block_height.asc&limit=5\"  # [{\"hash\":\"610b4c7bbebeeb212bd002885048cc33154ba29f39919d62a3d96de05d315706\",\"epoch\":236,\"abs_slot\":16594295,\"epoch_slot\":5495,\"block_height\":5086774,\"block_time\":1608160586,\"tx_count\":1,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"d93d1db5275329ab695d30c06a35124038d8d9af64fc2b0aa082b8aa43da4164\",\"epoch\":236,\"abs_slot\":16597729,\"epoch_slot\":8929,\"block_height\":5086944,\"block_time\":1608164020,\"tx_count\":7,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"dc9496eae64294b46f07eb20499ae6dae4d81fdc67c63c354397db91bda1ee55\",\"epoch\":236,\"abs_slot\":16598058,\"epoch_slot\":9258,\"block_height\":5086962,\"block_time\":1608164349,\"tx_count\":1,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"6ebc7b734c513bc19290d96ca573a09cac9503c5a349dd9892b9ab43f917f9bd\",\"epoch\":236,\"abs_slot\":16601491,\"epoch_slot\":12691,\"block_height\":5087097,\"block_time\":1608167782,\"tx_count\":0,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"2eac97548829fc312858bc56a40f7ce3bf9b0ca27ee8530283ccebb3963de1c0\",\"epoch\":236,\"abs_slot\":16602308,\"epoch_slot\":13508,\"block_height\":5087136,\"block_time\":1608168599,\"tx_count\":1,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}] ```  ## Response Formats  You can get the results from the PostgREST endpoints in CSV or JSON formats. The default response format will always be JSON, but if you'd like to switch, you can do so by specifying header `'Accept: text/csv'` or `'Accept: application/json'`. Below is an example of JSON/CSV output making use of above to print first in JSON (default), and then override response format to CSV.<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=epoch,epoch_slot,block_time&limit=3\"  # [{\"epoch\":318,\"epoch_slot\":27867,\"block_time\":1643606958}, # {\"epoch\":318,\"epoch_slot\":27841,\"block_time\":1643606932}, # {\"epoch\":318,\"epoch_slot\":27839,\"block_time\":1643606930}]  curl -s \"https://api.koios.rest/api/v0/blocks?select=epoch,epoch_slot,block_time&limit=3\" -H \"Accept: text/csv\"  # epoch,epoch_slot,block_time # 318,28491,1643607582 # 318,28479,1643607570 # 318,28406,1643607497  ```  ## Limits  While use of Koios is completely free and there are no registration requirements to the usage, the monitoring layer will only restrict spam requests that can potentially cause high amount of load to backends. The emphasis is on using list of objects first, and then [bulk where available] query specific objects to drill down where possible - which forms higher performance results to consumer as well as instance provider. Some basic protection against patterns that could cause unexpected resource spikes are protected as per below:    - Burst Limit: A single IP can query an endpoint up to 100 times within 10 seconds (that's about 8.64 million requests within a day). The sleep time if a limit is crossed is minimal (60 seconds) for that IP - during which, the monitoring layer will return HTTP Status `429 - Too many requests`.     - Pagination/Limits: Any query results fetched will be paginated by 1000 records (you can reduce limit and or control pagination offsets on URL itself, see API > Pagination section for more details).   - Query timeout: If a query from server takes more than 30 seconds, it will return a HTTP Status of `504 - Gateway timeout`. This is because we would want to ensure you're using the queries optimally, and more often than not - it would indicate that particular endpoint is not optimised (or the network connectivity is not optimal between servers).  Yet, there may be cases where the above restrictions may need exceptions (for example, an explorer or a wallet might need more connections than above - going beyond the Burst Limit). For such cases, it is best to approach the team and we can work towards a solution.   # Community projects  A big thank you to the following projects who are already starting to use Koios from early days:  ## CLI    - [Koios CLI in GoLang](https://github.com/cardano-community/koios-cli)  ## Libraries    - [.Net SDK](https://github.com/CardanoSharp/cardanosharp-koios)   - [Go Client](https://github.com/cardano-community/koios-go-client)   - [Java Client](https://github.com/cardano-community/koios-java-client)  ## Community Projects/Tools    - [Building On Cardano](https://buildingoncardano.com)   - [CardaStat](cardastat.info)   - [CNFT.IO](https://cnft.io)   - [CNTools](https://cardano-community.github.io/guild-operators/Scripts/cntools/)   - [Dandelion](https://dandelion.link)   - [Eternl](https://eternl.io/)   - [PoolPeek](https://poolpeek.com)  # FAQ  ### Is there a price attached to using services? For most of the queries, there are no charges. But there are DDoS protection and strict timeout rules (see API Usage) that may prevent heavy consumers from using this *remotely* (for which, there should be an interaction to ensure the usage is proportional to sizing and traffic expected).  ### Who are the folks behind Koios? It will be increasing list of community builders. But for initial think-tank and efforts, the work done is primarily by [guild-operators](https://cardano-community.github.io/guild-operators) who are a well-recognised team of members behind Cardano tools like CNTools, gLiveView, topologyUpdater, etc. We also run a parallel a short (60-min) epoch blockchain, viz, guild used by many for experiments.  ### I am only interested in collaborating on queries, where can I find the code and how to collaborate? All the Postgres codebase against db-sync instance is available on guild-operator's github repo [here](https://github.com/cardano-community/guild-operators/tree/alpha/files/grest/rpc). Feel free to raise an issue/PR to discuss anything related to those queries.  ### I am not sure how to set up an instance. Is there an easy start guide? Yes, there is a setup script (expect you to read carefully the help section) and instructions [here](https://cardano-community.github.io/guild-operators/Build/grest/). Should you need any assistance, feel free to hop in to the [discussion group](https://t.me/joinchat/+zE4Lce_QUepiY2U1).  ### Too much reading, I want to discuss in person There are bi-weekly calls held that anyone is free to join - or you can drop in to the [telegram group](https://t.me/+zE4Lce_QUepiY2U1) and start a discussion from there. 

   OpenAPI Version: 3.0.2
   Koios API API version: 1.0.6
   Generated by OpenAPI Generator (https://openapi-generator.tech)
-}

{-|
Module : Koios.API.Block
-}

{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MonoLocalBinds #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-name-shadowing -fno-warn-unused-binds -fno-warn-unused-imports #-}

module Koios.API.Block where

import Koios.Core
import Koios.MimeTypes
import Koios.Model as M

import qualified Data.Aeson as A
import qualified Data.ByteString as B
import qualified Data.ByteString.Lazy as BL
import qualified Data.Data as P (Typeable, TypeRep, typeOf, typeRep)
import qualified Data.Foldable as P
import qualified Data.Map as Map
import qualified Data.Maybe as P
import qualified Data.Proxy as P (Proxy(..))
import qualified Data.Set as Set
import qualified Data.String as P
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Encoding as TL
import qualified Data.Time as TI
import qualified Network.HTTP.Client.MultipartFormData as NH
import qualified Network.HTTP.Media as ME
import qualified Network.HTTP.Types as NH
import qualified Web.FormUrlEncoded as WH
import qualified Web.HttpApiData as WH

import Data.Text (Text)
import GHC.Base ((<|>))

import Prelude ((==),(/=),($), (.),(<$>),(<*>),(>>=),Maybe(..),Bool(..),Char,Double,FilePath,Float,Int,Integer,String,fmap,undefined,mempty,maybe,pure,Monad,Applicative,Functor)
import qualified Prelude as P

-- * Operations


-- ** Block

-- *** blockInfoPost

-- | @POST \/block_info@
-- 
-- Block Information
-- 
-- Get detailed information about a specific block
-- 
blockInfoPost
  :: (Consumes BlockInfoPost MimeJSON)
  => KoiosRequest BlockInfoPost MimeJSON [BlockInfoInner] MimeJSON
blockInfoPost =
  _mkRequest "POST" ["/block_info"]

data BlockInfoPost 
instance HasBodyParam BlockInfoPost BlockInfoPostRequest 

-- | @application/json@
instance Consumes BlockInfoPost MimeJSON

-- | @application/json@
instance Produces BlockInfoPost MimeJSON


-- *** blockTxsPost

-- | @POST \/block_txs@
-- 
-- Block Transactions
-- 
-- Get a list of all transactions included in provided blocks
-- 
blockTxsPost
  :: (Consumes BlockTxsPost MimeJSON)
  => KoiosRequest BlockTxsPost MimeJSON [BlockTxsInner] MimeJSON
blockTxsPost =
  _mkRequest "POST" ["/block_txs"]

data BlockTxsPost 
instance HasBodyParam BlockTxsPost BlockInfoPostRequest 

-- | @application/json@
instance Consumes BlockTxsPost MimeJSON

-- | @application/json@
instance Produces BlockTxsPost MimeJSON


-- *** blocksGet

-- | @GET \/blocks@
-- 
-- Block List
-- 
-- Get summarised details about all blocks (paginated - latest first)
-- 
blocksGet
  :: KoiosRequest BlocksGet MimeNoContent [BlocksInner] MimeJSON
blocksGet =
  _mkRequest "GET" ["/blocks"]

data BlocksGet  
-- | @application/json@
instance Produces BlocksGet MimeJSON

