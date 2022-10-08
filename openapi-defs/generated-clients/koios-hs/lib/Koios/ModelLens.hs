{-
   Koios API

   Koios is best described as a Decentralized and Elastic RESTful query layer for exploring data on Cardano blockchain to consume within applications/wallets/explorers/etc.  > Note: While we've done sufficient ground work - we're still going through testing/learning/adapting phase based on feedback. Feel free to give it a go, but just remember it is not yet finalized for production consumption and will be refreshed weekly (Saturday 8am UTC).  # Problems solved by Koios - As the size of blockchain grows rapidly, we're looking at increasingly expensive resources and maintenance costs (financially as well as time-wise) to maintain a scalable solution that will automatically failover and have health-checks, ensuring most synched versions are returned. With Koios, anyone is free to either add their backend instance to the cluster, or use the query layer without running a node or cardano-db-sync instance themselves. There will be health-checks for each endpoint to ensure that connections do not go to a dud backend with stale information. - Moreover, folks who do put in tremendous amount of efforts to go through discovery phrase - are often ending up with local solutions, that may not be consistent across the board (e.g. Live Stake queries across existing explorers). Since all the queries used by/for Koios layer is on GitHub, anyone can contribute or leverage the query knowledge base, and help each other out while doing so. An additional endpoint added will only be load balanced between the servers that pass the health-check for the endpoint. - It is almost impossible to fetch some live data (for example, Live Stake against a pool) due to the cost of computation and amount of data on chain. For  such queries, many folks are already using different cache methods, or capturing ledger information from node. Wouldn't it be nice to have these crunched data that take quite a few minutes to run be shared and available to be able to pick a relatively recent execution across the nodes? This will be available out of the box as part of Koios API. - There is also a worry when going through updates about feasibility/breaking changes/etc. that can become a bottleneck for providers. Since Koios participants automatically receive failover support, they reduce impact of any subset of clusters going through update process. - The lightweight query layers currently present are unfortunately closed source, centralised, and create a single point of failure. With Koios, our aim is to give enough flexibility to all the participants to select their backend, or pick from any of the available ones instead. - Bad human errors causing an outage? The bandwidth for Koios becomes better with more participation, but just in case there is not enough participation - we will ensure that at least 4 trusted Koios instances across the globe will be around for the initial year, allowing for enough time for adoption to build up gradually. - Flexibility to participate at different levels. A consumer of these services can participate with a complete independent instance (optionally extend existing ones), by running only certain parts (e.g. submit-api or PostgREST only), or simply consuming the API without running anything locally.  # Architecture  ## How does Koios work?  ![High-Level architecture overview](/koios-design.png)  We will go bottom to top (from builder's eyes to run through the above) briefly:  - *Instance(s)* : These are essentially [PostgREST](https://postgrest.org/en/latest/) instances with the REST service attached to Postgres DB populated using [cardano-db-sync](https://cardano-community.github.io/guild-operators/Build/dbsync/). Every consumer who is providing their own instance will be expected to serve at least a PostgREST instance, as this is what allows us to string instances together after health-checks. If using guild-operator setup instructions, these will be provisioned for you by setup scripts. - *Health-check Services* : These are lightweight [HAProxy](http://www.haproxy.org) instances that will be gatekeepers for individual endpoints, handling health-checks, sample data verification, etc. A builder _may_ opt-in to run this monitoring service, and add their instance to GitHub repository. Again, setting up HAProxy will be part of setup scripts on guild-operator's repo for those interested. - *DNS Routing* : These will be the entry points from monitoring layer to trusted instances that will route to health-check proxy services. We will be using at least two DNS servers ourselves to not have single point of failure, but that does not limit users to elect any of the other server endpoints instead, since the API works right from the PostgREST layer itself.  # API Usage  The endpoints served by Koios can be browsed from the left side bar of this site. You will find that almost each endpoint has an example that you can `Try` and will help you get an example in shell using cURL. For public queries, you do not need to register yourself - you can simply use them as per the examples provided on individual endpoints. But in addition, the [PostgREST API](https://postgrest.org/en/stable/api.html) used underneath provides a handful of features that can be quite handy for you to improve your queries to directly grab very specific information pertinent to your calls, reducing data you download and process.  ## Vertical Filtering  Instead of returning entire row, you can elect which rows you would like to fetch from the endpoint by using the `select` parameter with corresponding columns separated by commas. See example below (first is complete information for tip, while second command gives us 3 columns we are interested in):<br><br>  ``` bash curl \"https://api.koios.rest/api/v0/tip\"  # [{\"hash\":\"4d44c8a453e677f933c3df42ebcf2fe45987c41268b9cfc9b42ae305e8c3d99a\",\"epoch\":317,\"abs_slot\":51700871,\"epoch_slot\":120071,\"block_height\":6806994,\"block_time\":1643267162}]  curl \"https://api.koios.rest/api/v0/blocks?select=epoch,epoch_slot,block_height\"  # [{\"epoch\":317,\"epoch_slot\":120071,\"block_height\":6806994}] ```  ## Horizontal Filtering  You can filter the returned output based on specific conditions using operators against a column within returned result. Consider an example where you would want to query blocks minted in first 3 minutes of epoch 250 (i.e. epoch_slot was less than 180). To do so your query would look like below:<br><br> ``` bash curl \"https://api.koios.rest/api/v0/blocks?epoch=eq.250&epoch_slot=lt.180\"  # [{\"hash\":\"8fad2808ac6b37064a0fa69f6fe065807703d5235a57442647bbcdba1c02faf8\",\"epoch\":250,\"abs_slot\":22636942,\"epoch_slot\":142,\"block_height\":5385757,\"block_time\":1614203233,\"tx_count\":65,\"vrf_key\":\"vrf_vk14y9pjprzlsjvjt66mv5u7w7292sxp3kn4ewhss45ayjga5vurgaqhqknuu\",\"pool\":null,\"op_cert_counter\":2}, #  {\"hash\":\"9d33b02badaedc0dedd0d59f3e0411e5fb4ac94217fb5ee86719e8463c570e16\",\"epoch\":250,\"abs_slot\":22636800,\"epoch_slot\":0,\"block_height\":5385756,\"block_time\":1614203091,\"tx_count\":10,\"vrf_key\":\"vrf_vk1dkfsejw3h2k7tnguwrauqfwnxa7wj3nkp3yw2yw3400c4nlkluwqzwvka6\",\"pool\":null,\"op_cert_counter\":2}] ```  Here, we made use of `eq.` operator to denote a filter of \"value equal to\" against `epoch` column. Similarly, we added a filter using `lt.` operator to denote a filter of \"values lower than\" against `epoch_slot` column. You can find a complete list of operators supported in PostgREST documentation (commonly used ones extracted below):  |Abbreviation|In PostgreSQL|Meaning                                    | |------------|-------------|-------------------------------------------| |eq          |`=`          |equals                                     | |gt          |`>`          |greater than                               | |gte         |`>=`         |greater than or equal                      | |lt          |`<`          |less than                                  | |lte         |`<=`         |less than or equal                         | |neq         |`<>` or `!=` |not equal                                  | |like        |`LIKE`       |LIKE operator (use * in place of %)        | |in          |`IN`         |one of a list of values, e.g. `?a=in.(\"hi,there\",\"yes,you\")`| |is          |`IS`         |checking for exact equality (null,true,false,unknown)| |cs          |`@>`         |contains e.g. `?tags=cs.{example, new}`    | |cd          |`<@`         |contained in e.g. `?values=cd.{1,2,3}`     | |not         |`NOT`        |negates another operator                   | |or          |`OR`         |logical `OR` operator                      | |and         |`AND`        |logical `AND` operator                     |  ## Pagination (offset/limit)  When you query any endpoint in PostgREST, the number of observations returned will be limited to a maximum of 1000 rows (set via `max-rows` config option in the `grest.conf` file. This - however - is a result of a paginated call, wherein the [ up to ] 1000 records you see without any parameters is the first page. If you want to see the next 1000 results, you can always append `offset=1000` to view the next set of results. But what if 1000 is too high for your use-case and you want smaller page? Well, you can specify a smaller limit using parameter `limit`, which will see shortly in an example below. The obvious question at this point that would cross your mind is - how do I know if I need to offset and what range I am querying? This is where headers come in to your aid.    The default headers returned by PostgREST will include a `Content-Range` field giving a range of observations returned. For large tables, this range could include a wildcard `*` as it is expensive to query exact count of observations from endpoint. But if you would like to get an estimate count without overloading servers, PostgREST can utilise Postgres's own maintenance thread results (which maintain stats for each table) to provide you a count, by specifying a header `\"Profile: count=estimated\"`.    Sounds confusing? Let's see this in practice, to hopefully make it easier. Consider a simple case where I want query `blocks` endpoint for `block_height` column and focus on `content-range` header to monitor the rows we discussed above.<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=block_height\" -I | grep -i content-range  # content-range: 0-999/*  ```  As we can see above, the number of observations returned was 1000 (range being 0-999), but the total size was not queried to avoid wait times. Now, let's modify this default behaviour to query rows beyond the first 999, but this time - also add another clause to limit results by 500. We can do this using `offset=1000` and `limit=500` as below:<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=block_height&offset=1000&limit=500\" -I | grep -i content-range  # content-range: 1000-1499/*  ```  There is also another method to achieve the above, instead of adding parameters to the URL itself, you can specify a `Range` header as below to achieve something similar:<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=block_height\" -H \"Range: 1000-1499\" -I | grep -i content-range  # content-range: 1000-1499/*  ```  The above methods for pagination are very useful to keep your queries light as well as process the output in smaller pages, making better use of your resources and respecting server timeouts for response times.  ## Ordering  You can set a sorting order for returned queries against specific column(s). Consider example where you want to check `epoch` and `epoch_slot` for the first 5 blocks created by a particular pool, i.e. you can set order to ascending based on block_height column and add horizontal filter for that pool ID as below:<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?pool=eq.pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc&order=block_height.asc&limit=5\"  # [{\"hash\":\"610b4c7bbebeeb212bd002885048cc33154ba29f39919d62a3d96de05d315706\",\"epoch\":236,\"abs_slot\":16594295,\"epoch_slot\":5495,\"block_height\":5086774,\"block_time\":1608160586,\"tx_count\":1,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"d93d1db5275329ab695d30c06a35124038d8d9af64fc2b0aa082b8aa43da4164\",\"epoch\":236,\"abs_slot\":16597729,\"epoch_slot\":8929,\"block_height\":5086944,\"block_time\":1608164020,\"tx_count\":7,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"dc9496eae64294b46f07eb20499ae6dae4d81fdc67c63c354397db91bda1ee55\",\"epoch\":236,\"abs_slot\":16598058,\"epoch_slot\":9258,\"block_height\":5086962,\"block_time\":1608164349,\"tx_count\":1,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"6ebc7b734c513bc19290d96ca573a09cac9503c5a349dd9892b9ab43f917f9bd\",\"epoch\":236,\"abs_slot\":16601491,\"epoch_slot\":12691,\"block_height\":5087097,\"block_time\":1608167782,\"tx_count\":0,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"2eac97548829fc312858bc56a40f7ce3bf9b0ca27ee8530283ccebb3963de1c0\",\"epoch\":236,\"abs_slot\":16602308,\"epoch_slot\":13508,\"block_height\":5087136,\"block_time\":1608168599,\"tx_count\":1,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}] ```  ## Response Formats  You can get the results from the PostgREST endpoints in CSV or JSON formats. The default response format will always be JSON, but if you'd like to switch, you can do so by specifying header `'Accept: text/csv'` or `'Accept: application/json'`. Below is an example of JSON/CSV output making use of above to print first in JSON (default), and then override response format to CSV.<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=epoch,epoch_slot,block_time&limit=3\"  # [{\"epoch\":318,\"epoch_slot\":27867,\"block_time\":1643606958}, # {\"epoch\":318,\"epoch_slot\":27841,\"block_time\":1643606932}, # {\"epoch\":318,\"epoch_slot\":27839,\"block_time\":1643606930}]  curl -s \"https://api.koios.rest/api/v0/blocks?select=epoch,epoch_slot,block_time&limit=3\" -H \"Accept: text/csv\"  # epoch,epoch_slot,block_time # 318,28491,1643607582 # 318,28479,1643607570 # 318,28406,1643607497  ```  ## Limits  While use of Koios is completely free and there are no registration requirements to the usage, the monitoring layer will only restrict spam requests that can potentially cause high amount of load to backends. The emphasis is on using list of objects first, and then [bulk where available] query specific objects to drill down where possible - which forms higher performance results to consumer as well as instance provider. Some basic protection against patterns that could cause unexpected resource spikes are protected as per below:    - Burst Limit: A single IP can query an endpoint up to 100 times within 10 seconds (that's about 8.64 million requests within a day). The sleep time if a limit is crossed is minimal (60 seconds) for that IP - during which, the monitoring layer will return HTTP Status `429 - Too many requests`.     - Pagination/Limits: Any query results fetched will be paginated by 1000 records (you can reduce limit and or control pagination offsets on URL itself, see API > Pagination section for more details).   - Query timeout: If a query from server takes more than 30 seconds, it will return a HTTP Status of `504 - Gateway timeout`. This is because we would want to ensure you're using the queries optimally, and more often than not - it would indicate that particular endpoint is not optimised (or the network connectivity is not optimal between servers).  Yet, there may be cases where the above restrictions may need exceptions (for example, an explorer or a wallet might need more connections than above - going beyond the Burst Limit). For such cases, it is best to approach the team and we can work towards a solution.   # Community projects  A big thank you to the following projects who are already starting to use Koios from early days:  ## CLI    - [Koios CLI in GoLang](https://github.com/cardano-community/koios-cli)  ## Libraries    - [.Net SDK](https://github.com/CardanoSharp/cardanosharp-koios)   - [Go Client](https://github.com/cardano-community/koios-go-client)   - [Java Client](https://github.com/cardano-community/koios-java-client)  ## Community Projects/Tools    - [Building On Cardano](https://buildingoncardano.com)   - [CardaStat](cardastat.info)   - [CNFT.IO](https://cnft.io)   - [CNTools](https://cardano-community.github.io/guild-operators/Scripts/cntools/)   - [Dandelion](https://dandelion.link)   - [Eternl](https://eternl.io/)   - [PoolPeek](https://poolpeek.com)  # FAQ  ### Is there a price attached to using services? For most of the queries, there are no charges. But there are DDoS protection and strict timeout rules (see API Usage) that may prevent heavy consumers from using this *remotely* (for which, there should be an interaction to ensure the usage is proportional to sizing and traffic expected).  ### Who are the folks behind Koios? It will be increasing list of community builders. But for initial think-tank and efforts, the work done is primarily by [guild-operators](https://cardano-community.github.io/guild-operators) who are a well-recognised team of members behind Cardano tools like CNTools, gLiveView, topologyUpdater, etc. We also run a parallel a short (60-min) epoch blockchain, viz, guild used by many for experiments.  ### I am only interested in collaborating on queries, where can I find the code and how to collaborate? All the Postgres codebase against db-sync instance is available on guild-operator's github repo [here](https://github.com/cardano-community/guild-operators/tree/alpha/files/grest/rpc). Feel free to raise an issue/PR to discuss anything related to those queries.  ### I am not sure how to set up an instance. Is there an easy start guide? Yes, there is a setup script (expect you to read carefully the help section) and instructions [here](https://cardano-community.github.io/guild-operators/Build/grest/). Should you need any assistance, feel free to hop in to the [discussion group](https://t.me/joinchat/+zE4Lce_QUepiY2U1).  ### Too much reading, I want to discuss in person There are bi-weekly calls held that anyone is free to join - or you can drop in to the [telegram group](https://t.me/+zE4Lce_QUepiY2U1) and start a discussion from there. 

   OpenAPI Version: 3.0.2
   Koios API API version: 1.0.6
   Generated by OpenAPI Generator (https://openapi-generator.tech)
-}

{-|
Module : Koios.Lens
-}

{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# OPTIONS_GHC -fno-warn-name-shadowing -fno-warn-unused-matches -fno-warn-unused-binds -fno-warn-unused-imports #-}

module Koios.ModelLens where

import qualified Data.Aeson as A
import qualified Data.ByteString.Lazy as BL
import qualified Data.Data as P (Data, Typeable)
import qualified Data.Map as Map
import qualified Data.Set as Set
import qualified Data.Time as TI

import Data.Text (Text)

import Prelude (($), (.),(<$>),(<*>),(=<<),Maybe(..),Bool(..),Char,Double,FilePath,Float,Int,Integer,String,fmap,undefined,mempty,maybe,pure,Monad,Applicative,Functor)
import qualified Prelude as P

import Koios.Model
import Koios.Core


-- * AccountAddressesInner

-- | 'accountAddressesInnerStakeAddress' Lens
accountAddressesInnerStakeAddressL :: Lens_' AccountAddressesInner (Maybe StakeAddress)
accountAddressesInnerStakeAddressL f AccountAddressesInner{..} = (\accountAddressesInnerStakeAddress -> AccountAddressesInner { accountAddressesInnerStakeAddress, ..} ) <$> f accountAddressesInnerStakeAddress
{-# INLINE accountAddressesInnerStakeAddressL #-}

-- | 'accountAddressesInnerAddresses' Lens
accountAddressesInnerAddressesL :: Lens_' AccountAddressesInner (Maybe [PaymentAddress])
accountAddressesInnerAddressesL f AccountAddressesInner{..} = (\accountAddressesInnerAddresses -> AccountAddressesInner { accountAddressesInnerAddresses, ..} ) <$> f accountAddressesInnerAddresses
{-# INLINE accountAddressesInnerAddressesL #-}



-- * AccountAssetsInner

-- | 'accountAssetsInnerStakeAddress' Lens
accountAssetsInnerStakeAddressL :: Lens_' AccountAssetsInner (Maybe StakeAddress)
accountAssetsInnerStakeAddressL f AccountAssetsInner{..} = (\accountAssetsInnerStakeAddress -> AccountAssetsInner { accountAssetsInnerStakeAddress, ..} ) <$> f accountAssetsInnerStakeAddress
{-# INLINE accountAssetsInnerStakeAddressL #-}

-- | 'accountAssetsInnerAssets' Lens
accountAssetsInnerAssetsL :: Lens_' AccountAssetsInner (Maybe [AccountAssetsInnerAssetsInner])
accountAssetsInnerAssetsL f AccountAssetsInner{..} = (\accountAssetsInnerAssets -> AccountAssetsInner { accountAssetsInnerAssets, ..} ) <$> f accountAssetsInnerAssets
{-# INLINE accountAssetsInnerAssetsL #-}



-- * AccountAssetsInnerAssetsInner

-- | 'accountAssetsInnerAssetsInnerPolicyId' Lens
accountAssetsInnerAssetsInnerPolicyIdL :: Lens_' AccountAssetsInnerAssetsInner (Maybe PolicyId)
accountAssetsInnerAssetsInnerPolicyIdL f AccountAssetsInnerAssetsInner{..} = (\accountAssetsInnerAssetsInnerPolicyId -> AccountAssetsInnerAssetsInner { accountAssetsInnerAssetsInnerPolicyId, ..} ) <$> f accountAssetsInnerAssetsInnerPolicyId
{-# INLINE accountAssetsInnerAssetsInnerPolicyIdL #-}

-- | 'accountAssetsInnerAssetsInnerAssets' Lens
accountAssetsInnerAssetsInnerAssetsL :: Lens_' AccountAssetsInnerAssetsInner (Maybe [AccountAssetsInnerAssetsInnerAssetsInner])
accountAssetsInnerAssetsInnerAssetsL f AccountAssetsInnerAssetsInner{..} = (\accountAssetsInnerAssetsInnerAssets -> AccountAssetsInnerAssetsInner { accountAssetsInnerAssetsInnerAssets, ..} ) <$> f accountAssetsInnerAssetsInnerAssets
{-# INLINE accountAssetsInnerAssetsInnerAssetsL #-}



-- * AccountAssetsInnerAssetsInnerAssetsInner

-- | 'accountAssetsInnerAssetsInnerAssetsInnerAssetName' Lens
accountAssetsInnerAssetsInnerAssetsInnerAssetNameL :: Lens_' AccountAssetsInnerAssetsInnerAssetsInner (Maybe AssetNameAscii)
accountAssetsInnerAssetsInnerAssetsInnerAssetNameL f AccountAssetsInnerAssetsInnerAssetsInner{..} = (\accountAssetsInnerAssetsInnerAssetsInnerAssetName -> AccountAssetsInnerAssetsInnerAssetsInner { accountAssetsInnerAssetsInnerAssetsInnerAssetName, ..} ) <$> f accountAssetsInnerAssetsInnerAssetsInnerAssetName
{-# INLINE accountAssetsInnerAssetsInnerAssetsInnerAssetNameL #-}

-- | 'accountAssetsInnerAssetsInnerAssetsInnerAssetPolicy' Lens
accountAssetsInnerAssetsInnerAssetsInnerAssetPolicyL :: Lens_' AccountAssetsInnerAssetsInnerAssetsInner (Maybe PolicyId)
accountAssetsInnerAssetsInnerAssetsInnerAssetPolicyL f AccountAssetsInnerAssetsInnerAssetsInner{..} = (\accountAssetsInnerAssetsInnerAssetsInnerAssetPolicy -> AccountAssetsInnerAssetsInnerAssetsInner { accountAssetsInnerAssetsInnerAssetsInnerAssetPolicy, ..} ) <$> f accountAssetsInnerAssetsInnerAssetsInnerAssetPolicy
{-# INLINE accountAssetsInnerAssetsInnerAssetsInnerAssetPolicyL #-}

-- | 'accountAssetsInnerAssetsInnerAssetsInnerBalance' Lens
accountAssetsInnerAssetsInnerAssetsInnerBalanceL :: Lens_' AccountAssetsInnerAssetsInnerAssetsInner (Maybe Text)
accountAssetsInnerAssetsInnerAssetsInnerBalanceL f AccountAssetsInnerAssetsInnerAssetsInner{..} = (\accountAssetsInnerAssetsInnerAssetsInnerBalance -> AccountAssetsInnerAssetsInnerAssetsInner { accountAssetsInnerAssetsInnerAssetsInnerBalance, ..} ) <$> f accountAssetsInnerAssetsInnerAssetsInnerBalance
{-# INLINE accountAssetsInnerAssetsInnerAssetsInnerBalanceL #-}



-- * AccountHistoryInner

-- | 'accountHistoryInnerStakeAddress' Lens
accountHistoryInnerStakeAddressL :: Lens_' AccountHistoryInner (Maybe Text)
accountHistoryInnerStakeAddressL f AccountHistoryInner{..} = (\accountHistoryInnerStakeAddress -> AccountHistoryInner { accountHistoryInnerStakeAddress, ..} ) <$> f accountHistoryInnerStakeAddress
{-# INLINE accountHistoryInnerStakeAddressL #-}

-- | 'accountHistoryInnerHistory' Lens
accountHistoryInnerHistoryL :: Lens_' AccountHistoryInner (Maybe [AccountHistoryInnerHistoryInner])
accountHistoryInnerHistoryL f AccountHistoryInner{..} = (\accountHistoryInnerHistory -> AccountHistoryInner { accountHistoryInnerHistory, ..} ) <$> f accountHistoryInnerHistory
{-# INLINE accountHistoryInnerHistoryL #-}



-- * AccountHistoryInnerHistoryInner

-- | 'accountHistoryInnerHistoryInnerPoolId' Lens
accountHistoryInnerHistoryInnerPoolIdL :: Lens_' AccountHistoryInnerHistoryInner (Maybe Text)
accountHistoryInnerHistoryInnerPoolIdL f AccountHistoryInnerHistoryInner{..} = (\accountHistoryInnerHistoryInnerPoolId -> AccountHistoryInnerHistoryInner { accountHistoryInnerHistoryInnerPoolId, ..} ) <$> f accountHistoryInnerHistoryInnerPoolId
{-# INLINE accountHistoryInnerHistoryInnerPoolIdL #-}

-- | 'accountHistoryInnerHistoryInnerEpochNo' Lens
accountHistoryInnerHistoryInnerEpochNoL :: Lens_' AccountHistoryInnerHistoryInner (Maybe Int)
accountHistoryInnerHistoryInnerEpochNoL f AccountHistoryInnerHistoryInner{..} = (\accountHistoryInnerHistoryInnerEpochNo -> AccountHistoryInnerHistoryInner { accountHistoryInnerHistoryInnerEpochNo, ..} ) <$> f accountHistoryInnerHistoryInnerEpochNo
{-# INLINE accountHistoryInnerHistoryInnerEpochNoL #-}

-- | 'accountHistoryInnerHistoryInnerActiveStake' Lens
accountHistoryInnerHistoryInnerActiveStakeL :: Lens_' AccountHistoryInnerHistoryInner (Maybe Text)
accountHistoryInnerHistoryInnerActiveStakeL f AccountHistoryInnerHistoryInner{..} = (\accountHistoryInnerHistoryInnerActiveStake -> AccountHistoryInnerHistoryInner { accountHistoryInnerHistoryInnerActiveStake, ..} ) <$> f accountHistoryInnerHistoryInnerActiveStake
{-# INLINE accountHistoryInnerHistoryInnerActiveStakeL #-}



-- * AccountInfoInner

-- | 'accountInfoInnerStakeAddress' Lens
accountInfoInnerStakeAddressL :: Lens_' AccountInfoInner (Maybe StakeAddress)
accountInfoInnerStakeAddressL f AccountInfoInner{..} = (\accountInfoInnerStakeAddress -> AccountInfoInner { accountInfoInnerStakeAddress, ..} ) <$> f accountInfoInnerStakeAddress
{-# INLINE accountInfoInnerStakeAddressL #-}

-- | 'accountInfoInnerStatus' Lens
accountInfoInnerStatusL :: Lens_' AccountInfoInner (Maybe E'Status)
accountInfoInnerStatusL f AccountInfoInner{..} = (\accountInfoInnerStatus -> AccountInfoInner { accountInfoInnerStatus, ..} ) <$> f accountInfoInnerStatus
{-# INLINE accountInfoInnerStatusL #-}

-- | 'accountInfoInnerDelegatedPool' Lens
accountInfoInnerDelegatedPoolL :: Lens_' AccountInfoInner (Maybe PoolIdBech32)
accountInfoInnerDelegatedPoolL f AccountInfoInner{..} = (\accountInfoInnerDelegatedPool -> AccountInfoInner { accountInfoInnerDelegatedPool, ..} ) <$> f accountInfoInnerDelegatedPool
{-# INLINE accountInfoInnerDelegatedPoolL #-}

-- | 'accountInfoInnerTotalBalance' Lens
accountInfoInnerTotalBalanceL :: Lens_' AccountInfoInner (Maybe Text)
accountInfoInnerTotalBalanceL f AccountInfoInner{..} = (\accountInfoInnerTotalBalance -> AccountInfoInner { accountInfoInnerTotalBalance, ..} ) <$> f accountInfoInnerTotalBalance
{-# INLINE accountInfoInnerTotalBalanceL #-}

-- | 'accountInfoInnerUtxo' Lens
accountInfoInnerUtxoL :: Lens_' AccountInfoInner (Maybe Text)
accountInfoInnerUtxoL f AccountInfoInner{..} = (\accountInfoInnerUtxo -> AccountInfoInner { accountInfoInnerUtxo, ..} ) <$> f accountInfoInnerUtxo
{-# INLINE accountInfoInnerUtxoL #-}

-- | 'accountInfoInnerRewards' Lens
accountInfoInnerRewardsL :: Lens_' AccountInfoInner (Maybe Text)
accountInfoInnerRewardsL f AccountInfoInner{..} = (\accountInfoInnerRewards -> AccountInfoInner { accountInfoInnerRewards, ..} ) <$> f accountInfoInnerRewards
{-# INLINE accountInfoInnerRewardsL #-}

-- | 'accountInfoInnerWithdrawals' Lens
accountInfoInnerWithdrawalsL :: Lens_' AccountInfoInner (Maybe Text)
accountInfoInnerWithdrawalsL f AccountInfoInner{..} = (\accountInfoInnerWithdrawals -> AccountInfoInner { accountInfoInnerWithdrawals, ..} ) <$> f accountInfoInnerWithdrawals
{-# INLINE accountInfoInnerWithdrawalsL #-}

-- | 'accountInfoInnerRewardsAvailable' Lens
accountInfoInnerRewardsAvailableL :: Lens_' AccountInfoInner (Maybe Text)
accountInfoInnerRewardsAvailableL f AccountInfoInner{..} = (\accountInfoInnerRewardsAvailable -> AccountInfoInner { accountInfoInnerRewardsAvailable, ..} ) <$> f accountInfoInnerRewardsAvailable
{-# INLINE accountInfoInnerRewardsAvailableL #-}

-- | 'accountInfoInnerReserves' Lens
accountInfoInnerReservesL :: Lens_' AccountInfoInner (Maybe Text)
accountInfoInnerReservesL f AccountInfoInner{..} = (\accountInfoInnerReserves -> AccountInfoInner { accountInfoInnerReserves, ..} ) <$> f accountInfoInnerReserves
{-# INLINE accountInfoInnerReservesL #-}

-- | 'accountInfoInnerTreasury' Lens
accountInfoInnerTreasuryL :: Lens_' AccountInfoInner (Maybe Text)
accountInfoInnerTreasuryL f AccountInfoInner{..} = (\accountInfoInnerTreasury -> AccountInfoInner { accountInfoInnerTreasury, ..} ) <$> f accountInfoInnerTreasury
{-# INLINE accountInfoInnerTreasuryL #-}



-- * AccountInfoPostRequest

-- | 'accountInfoPostRequestStakeAddresses' Lens
accountInfoPostRequestStakeAddressesL :: Lens_' AccountInfoPostRequest ([Text])
accountInfoPostRequestStakeAddressesL f AccountInfoPostRequest{..} = (\accountInfoPostRequestStakeAddresses -> AccountInfoPostRequest { accountInfoPostRequestStakeAddresses, ..} ) <$> f accountInfoPostRequestStakeAddresses
{-# INLINE accountInfoPostRequestStakeAddressesL #-}

-- | 'accountInfoPostRequestEpochNo' Lens
accountInfoPostRequestEpochNoL :: Lens_' AccountInfoPostRequest (Maybe Int)
accountInfoPostRequestEpochNoL f AccountInfoPostRequest{..} = (\accountInfoPostRequestEpochNo -> AccountInfoPostRequest { accountInfoPostRequestEpochNo, ..} ) <$> f accountInfoPostRequestEpochNo
{-# INLINE accountInfoPostRequestEpochNoL #-}



-- * AccountListInner

-- | 'accountListInnerId' Lens
accountListInnerIdL :: Lens_' AccountListInner (Maybe StakeAddress)
accountListInnerIdL f AccountListInner{..} = (\accountListInnerId -> AccountListInner { accountListInnerId, ..} ) <$> f accountListInnerId
{-# INLINE accountListInnerIdL #-}



-- * AccountRewardsInner

-- | 'accountRewardsInnerStakeAddress' Lens
accountRewardsInnerStakeAddressL :: Lens_' AccountRewardsInner (Maybe StakeAddress)
accountRewardsInnerStakeAddressL f AccountRewardsInner{..} = (\accountRewardsInnerStakeAddress -> AccountRewardsInner { accountRewardsInnerStakeAddress, ..} ) <$> f accountRewardsInnerStakeAddress
{-# INLINE accountRewardsInnerStakeAddressL #-}

-- | 'accountRewardsInnerRewards' Lens
accountRewardsInnerRewardsL :: Lens_' AccountRewardsInner (Maybe [AccountRewardsInnerRewardsInner])
accountRewardsInnerRewardsL f AccountRewardsInner{..} = (\accountRewardsInnerRewards -> AccountRewardsInner { accountRewardsInnerRewards, ..} ) <$> f accountRewardsInnerRewards
{-# INLINE accountRewardsInnerRewardsL #-}



-- * AccountRewardsInnerRewardsInner

-- | 'accountRewardsInnerRewardsInnerEarnedEpoch' Lens
accountRewardsInnerRewardsInnerEarnedEpochL :: Lens_' AccountRewardsInnerRewardsInner (Maybe EpochNo)
accountRewardsInnerRewardsInnerEarnedEpochL f AccountRewardsInnerRewardsInner{..} = (\accountRewardsInnerRewardsInnerEarnedEpoch -> AccountRewardsInnerRewardsInner { accountRewardsInnerRewardsInnerEarnedEpoch, ..} ) <$> f accountRewardsInnerRewardsInnerEarnedEpoch
{-# INLINE accountRewardsInnerRewardsInnerEarnedEpochL #-}

-- | 'accountRewardsInnerRewardsInnerSpendableEpoch' Lens
accountRewardsInnerRewardsInnerSpendableEpochL :: Lens_' AccountRewardsInnerRewardsInner (Maybe EpochNo)
accountRewardsInnerRewardsInnerSpendableEpochL f AccountRewardsInnerRewardsInner{..} = (\accountRewardsInnerRewardsInnerSpendableEpoch -> AccountRewardsInnerRewardsInner { accountRewardsInnerRewardsInnerSpendableEpoch, ..} ) <$> f accountRewardsInnerRewardsInnerSpendableEpoch
{-# INLINE accountRewardsInnerRewardsInnerSpendableEpochL #-}

-- | 'accountRewardsInnerRewardsInnerAmount' Lens
accountRewardsInnerRewardsInnerAmountL :: Lens_' AccountRewardsInnerRewardsInner (Maybe Text)
accountRewardsInnerRewardsInnerAmountL f AccountRewardsInnerRewardsInner{..} = (\accountRewardsInnerRewardsInnerAmount -> AccountRewardsInnerRewardsInner { accountRewardsInnerRewardsInnerAmount, ..} ) <$> f accountRewardsInnerRewardsInnerAmount
{-# INLINE accountRewardsInnerRewardsInnerAmountL #-}

-- | 'accountRewardsInnerRewardsInnerType' Lens
accountRewardsInnerRewardsInnerTypeL :: Lens_' AccountRewardsInnerRewardsInner (Maybe E'Type)
accountRewardsInnerRewardsInnerTypeL f AccountRewardsInnerRewardsInner{..} = (\accountRewardsInnerRewardsInnerType -> AccountRewardsInnerRewardsInner { accountRewardsInnerRewardsInnerType, ..} ) <$> f accountRewardsInnerRewardsInnerType
{-# INLINE accountRewardsInnerRewardsInnerTypeL #-}

-- | 'accountRewardsInnerRewardsInnerPoolId' Lens
accountRewardsInnerRewardsInnerPoolIdL :: Lens_' AccountRewardsInnerRewardsInner (Maybe PoolIdBech32)
accountRewardsInnerRewardsInnerPoolIdL f AccountRewardsInnerRewardsInner{..} = (\accountRewardsInnerRewardsInnerPoolId -> AccountRewardsInnerRewardsInner { accountRewardsInnerRewardsInnerPoolId, ..} ) <$> f accountRewardsInnerRewardsInnerPoolId
{-# INLINE accountRewardsInnerRewardsInnerPoolIdL #-}



-- * AccountUpdatesInner

-- | 'accountUpdatesInnerStakeAddress' Lens
accountUpdatesInnerStakeAddressL :: Lens_' AccountUpdatesInner (Maybe StakeAddress)
accountUpdatesInnerStakeAddressL f AccountUpdatesInner{..} = (\accountUpdatesInnerStakeAddress -> AccountUpdatesInner { accountUpdatesInnerStakeAddress, ..} ) <$> f accountUpdatesInnerStakeAddress
{-# INLINE accountUpdatesInnerStakeAddressL #-}

-- | 'accountUpdatesInnerUpdates' Lens
accountUpdatesInnerUpdatesL :: Lens_' AccountUpdatesInner (Maybe [AccountUpdatesInnerUpdatesInner])
accountUpdatesInnerUpdatesL f AccountUpdatesInner{..} = (\accountUpdatesInnerUpdates -> AccountUpdatesInner { accountUpdatesInnerUpdates, ..} ) <$> f accountUpdatesInnerUpdates
{-# INLINE accountUpdatesInnerUpdatesL #-}



-- * AccountUpdatesInnerUpdatesInner

-- | 'accountUpdatesInnerUpdatesInnerActionType' Lens
accountUpdatesInnerUpdatesInnerActionTypeL :: Lens_' AccountUpdatesInnerUpdatesInner (Maybe E'ActionType)
accountUpdatesInnerUpdatesInnerActionTypeL f AccountUpdatesInnerUpdatesInner{..} = (\accountUpdatesInnerUpdatesInnerActionType -> AccountUpdatesInnerUpdatesInner { accountUpdatesInnerUpdatesInnerActionType, ..} ) <$> f accountUpdatesInnerUpdatesInnerActionType
{-# INLINE accountUpdatesInnerUpdatesInnerActionTypeL #-}

-- | 'accountUpdatesInnerUpdatesInnerTxHash' Lens
accountUpdatesInnerUpdatesInnerTxHashL :: Lens_' AccountUpdatesInnerUpdatesInner (Maybe TxHash)
accountUpdatesInnerUpdatesInnerTxHashL f AccountUpdatesInnerUpdatesInner{..} = (\accountUpdatesInnerUpdatesInnerTxHash -> AccountUpdatesInnerUpdatesInner { accountUpdatesInnerUpdatesInnerTxHash, ..} ) <$> f accountUpdatesInnerUpdatesInnerTxHash
{-# INLINE accountUpdatesInnerUpdatesInnerTxHashL #-}

-- | 'accountUpdatesInnerUpdatesInnerEpochNo' Lens
accountUpdatesInnerUpdatesInnerEpochNoL :: Lens_' AccountUpdatesInnerUpdatesInner (Maybe EpochNo)
accountUpdatesInnerUpdatesInnerEpochNoL f AccountUpdatesInnerUpdatesInner{..} = (\accountUpdatesInnerUpdatesInnerEpochNo -> AccountUpdatesInnerUpdatesInner { accountUpdatesInnerUpdatesInnerEpochNo, ..} ) <$> f accountUpdatesInnerUpdatesInnerEpochNo
{-# INLINE accountUpdatesInnerUpdatesInnerEpochNoL #-}

-- | 'accountUpdatesInnerUpdatesInnerEpochSlot' Lens
accountUpdatesInnerUpdatesInnerEpochSlotL :: Lens_' AccountUpdatesInnerUpdatesInner (Maybe EpochSlot)
accountUpdatesInnerUpdatesInnerEpochSlotL f AccountUpdatesInnerUpdatesInner{..} = (\accountUpdatesInnerUpdatesInnerEpochSlot -> AccountUpdatesInnerUpdatesInner { accountUpdatesInnerUpdatesInnerEpochSlot, ..} ) <$> f accountUpdatesInnerUpdatesInnerEpochSlot
{-# INLINE accountUpdatesInnerUpdatesInnerEpochSlotL #-}

-- | 'accountUpdatesInnerUpdatesInnerAbsoluteSlot' Lens
accountUpdatesInnerUpdatesInnerAbsoluteSlotL :: Lens_' AccountUpdatesInnerUpdatesInner (Maybe AbsSlot)
accountUpdatesInnerUpdatesInnerAbsoluteSlotL f AccountUpdatesInnerUpdatesInner{..} = (\accountUpdatesInnerUpdatesInnerAbsoluteSlot -> AccountUpdatesInnerUpdatesInner { accountUpdatesInnerUpdatesInnerAbsoluteSlot, ..} ) <$> f accountUpdatesInnerUpdatesInnerAbsoluteSlot
{-# INLINE accountUpdatesInnerUpdatesInnerAbsoluteSlotL #-}

-- | 'accountUpdatesInnerUpdatesInnerBlockTime' Lens
accountUpdatesInnerUpdatesInnerBlockTimeL :: Lens_' AccountUpdatesInnerUpdatesInner (Maybe BlockTime)
accountUpdatesInnerUpdatesInnerBlockTimeL f AccountUpdatesInnerUpdatesInner{..} = (\accountUpdatesInnerUpdatesInnerBlockTime -> AccountUpdatesInnerUpdatesInner { accountUpdatesInnerUpdatesInnerBlockTime, ..} ) <$> f accountUpdatesInnerUpdatesInnerBlockTime
{-# INLINE accountUpdatesInnerUpdatesInnerBlockTimeL #-}



-- * AddressAssetsInner

-- | 'addressAssetsInnerAddress' Lens
addressAssetsInnerAddressL :: Lens_' AddressAssetsInner (Maybe PaymentAddress)
addressAssetsInnerAddressL f AddressAssetsInner{..} = (\addressAssetsInnerAddress -> AddressAssetsInner { addressAssetsInnerAddress, ..} ) <$> f addressAssetsInnerAddress
{-# INLINE addressAssetsInnerAddressL #-}

-- | 'addressAssetsInnerAssets' Lens
addressAssetsInnerAssetsL :: Lens_' AddressAssetsInner (Maybe [AssetListInner])
addressAssetsInnerAssetsL f AddressAssetsInner{..} = (\addressAssetsInnerAssets -> AddressAssetsInner { addressAssetsInnerAssets, ..} ) <$> f addressAssetsInnerAssets
{-# INLINE addressAssetsInnerAssetsL #-}



-- * AddressInfoInner

-- | 'addressInfoInnerAddress' Lens
addressInfoInnerAddressL :: Lens_' AddressInfoInner (Maybe PaymentAddress)
addressInfoInnerAddressL f AddressInfoInner{..} = (\addressInfoInnerAddress -> AddressInfoInner { addressInfoInnerAddress, ..} ) <$> f addressInfoInnerAddress
{-# INLINE addressInfoInnerAddressL #-}

-- | 'addressInfoInnerBalance' Lens
addressInfoInnerBalanceL :: Lens_' AddressInfoInner (Maybe Text)
addressInfoInnerBalanceL f AddressInfoInner{..} = (\addressInfoInnerBalance -> AddressInfoInner { addressInfoInnerBalance, ..} ) <$> f addressInfoInnerBalance
{-# INLINE addressInfoInnerBalanceL #-}

-- | 'addressInfoInnerStakeAddress' Lens
addressInfoInnerStakeAddressL :: Lens_' AddressInfoInner (Maybe StakeAddress)
addressInfoInnerStakeAddressL f AddressInfoInner{..} = (\addressInfoInnerStakeAddress -> AddressInfoInner { addressInfoInnerStakeAddress, ..} ) <$> f addressInfoInnerStakeAddress
{-# INLINE addressInfoInnerStakeAddressL #-}

-- | 'addressInfoInnerScriptAddress' Lens
addressInfoInnerScriptAddressL :: Lens_' AddressInfoInner (Maybe Bool)
addressInfoInnerScriptAddressL f AddressInfoInner{..} = (\addressInfoInnerScriptAddress -> AddressInfoInner { addressInfoInnerScriptAddress, ..} ) <$> f addressInfoInnerScriptAddress
{-# INLINE addressInfoInnerScriptAddressL #-}

-- | 'addressInfoInnerUtxoSet' Lens
addressInfoInnerUtxoSetL :: Lens_' AddressInfoInner (Maybe [AddressInfoInnerUtxoSetInner])
addressInfoInnerUtxoSetL f AddressInfoInner{..} = (\addressInfoInnerUtxoSet -> AddressInfoInner { addressInfoInnerUtxoSet, ..} ) <$> f addressInfoInnerUtxoSet
{-# INLINE addressInfoInnerUtxoSetL #-}



-- * AddressInfoInnerUtxoSetInner

-- | 'addressInfoInnerUtxoSetInnerTxHash' Lens
addressInfoInnerUtxoSetInnerTxHashL :: Lens_' AddressInfoInnerUtxoSetInner (Maybe TxHash)
addressInfoInnerUtxoSetInnerTxHashL f AddressInfoInnerUtxoSetInner{..} = (\addressInfoInnerUtxoSetInnerTxHash -> AddressInfoInnerUtxoSetInner { addressInfoInnerUtxoSetInnerTxHash, ..} ) <$> f addressInfoInnerUtxoSetInnerTxHash
{-# INLINE addressInfoInnerUtxoSetInnerTxHashL #-}

-- | 'addressInfoInnerUtxoSetInnerTxIndex' Lens
addressInfoInnerUtxoSetInnerTxIndexL :: Lens_' AddressInfoInnerUtxoSetInner (Maybe TxIndex)
addressInfoInnerUtxoSetInnerTxIndexL f AddressInfoInnerUtxoSetInner{..} = (\addressInfoInnerUtxoSetInnerTxIndex -> AddressInfoInnerUtxoSetInner { addressInfoInnerUtxoSetInnerTxIndex, ..} ) <$> f addressInfoInnerUtxoSetInnerTxIndex
{-# INLINE addressInfoInnerUtxoSetInnerTxIndexL #-}

-- | 'addressInfoInnerUtxoSetInnerBlockHeight' Lens
addressInfoInnerUtxoSetInnerBlockHeightL :: Lens_' AddressInfoInnerUtxoSetInner (Maybe BlockHeight)
addressInfoInnerUtxoSetInnerBlockHeightL f AddressInfoInnerUtxoSetInner{..} = (\addressInfoInnerUtxoSetInnerBlockHeight -> AddressInfoInnerUtxoSetInner { addressInfoInnerUtxoSetInnerBlockHeight, ..} ) <$> f addressInfoInnerUtxoSetInnerBlockHeight
{-# INLINE addressInfoInnerUtxoSetInnerBlockHeightL #-}

-- | 'addressInfoInnerUtxoSetInnerBlockTime' Lens
addressInfoInnerUtxoSetInnerBlockTimeL :: Lens_' AddressInfoInnerUtxoSetInner (Maybe BlockTime)
addressInfoInnerUtxoSetInnerBlockTimeL f AddressInfoInnerUtxoSetInner{..} = (\addressInfoInnerUtxoSetInnerBlockTime -> AddressInfoInnerUtxoSetInner { addressInfoInnerUtxoSetInnerBlockTime, ..} ) <$> f addressInfoInnerUtxoSetInnerBlockTime
{-# INLINE addressInfoInnerUtxoSetInnerBlockTimeL #-}

-- | 'addressInfoInnerUtxoSetInnerValue' Lens
addressInfoInnerUtxoSetInnerValueL :: Lens_' AddressInfoInnerUtxoSetInner (Maybe Value)
addressInfoInnerUtxoSetInnerValueL f AddressInfoInnerUtxoSetInner{..} = (\addressInfoInnerUtxoSetInnerValue -> AddressInfoInnerUtxoSetInner { addressInfoInnerUtxoSetInnerValue, ..} ) <$> f addressInfoInnerUtxoSetInnerValue
{-# INLINE addressInfoInnerUtxoSetInnerValueL #-}

-- | 'addressInfoInnerUtxoSetInnerDatumHash' Lens
addressInfoInnerUtxoSetInnerDatumHashL :: Lens_' AddressInfoInnerUtxoSetInner (Maybe DatumHash)
addressInfoInnerUtxoSetInnerDatumHashL f AddressInfoInnerUtxoSetInner{..} = (\addressInfoInnerUtxoSetInnerDatumHash -> AddressInfoInnerUtxoSetInner { addressInfoInnerUtxoSetInnerDatumHash, ..} ) <$> f addressInfoInnerUtxoSetInnerDatumHash
{-# INLINE addressInfoInnerUtxoSetInnerDatumHashL #-}

-- | 'addressInfoInnerUtxoSetInnerInlineDatum' Lens
addressInfoInnerUtxoSetInnerInlineDatumL :: Lens_' AddressInfoInnerUtxoSetInner (Maybe InlineDatum)
addressInfoInnerUtxoSetInnerInlineDatumL f AddressInfoInnerUtxoSetInner{..} = (\addressInfoInnerUtxoSetInnerInlineDatum -> AddressInfoInnerUtxoSetInner { addressInfoInnerUtxoSetInnerInlineDatum, ..} ) <$> f addressInfoInnerUtxoSetInnerInlineDatum
{-# INLINE addressInfoInnerUtxoSetInnerInlineDatumL #-}

-- | 'addressInfoInnerUtxoSetInnerReferenceScript' Lens
addressInfoInnerUtxoSetInnerReferenceScriptL :: Lens_' AddressInfoInnerUtxoSetInner (Maybe ReferenceScript)
addressInfoInnerUtxoSetInnerReferenceScriptL f AddressInfoInnerUtxoSetInner{..} = (\addressInfoInnerUtxoSetInnerReferenceScript -> AddressInfoInnerUtxoSetInner { addressInfoInnerUtxoSetInnerReferenceScript, ..} ) <$> f addressInfoInnerUtxoSetInnerReferenceScript
{-# INLINE addressInfoInnerUtxoSetInnerReferenceScriptL #-}

-- | 'addressInfoInnerUtxoSetInnerAssetList' Lens
addressInfoInnerUtxoSetInnerAssetListL :: Lens_' AddressInfoInnerUtxoSetInner (Maybe [AssetListInner])
addressInfoInnerUtxoSetInnerAssetListL f AddressInfoInnerUtxoSetInner{..} = (\addressInfoInnerUtxoSetInnerAssetList -> AddressInfoInnerUtxoSetInner { addressInfoInnerUtxoSetInnerAssetList, ..} ) <$> f addressInfoInnerUtxoSetInnerAssetList
{-# INLINE addressInfoInnerUtxoSetInnerAssetListL #-}



-- * AddressInfoPostRequest

-- | 'addressInfoPostRequestAddresses' Lens
addressInfoPostRequestAddressesL :: Lens_' AddressInfoPostRequest ([Text])
addressInfoPostRequestAddressesL f AddressInfoPostRequest{..} = (\addressInfoPostRequestAddresses -> AddressInfoPostRequest { addressInfoPostRequestAddresses, ..} ) <$> f addressInfoPostRequestAddresses
{-# INLINE addressInfoPostRequestAddressesL #-}



-- * AddressTxsInner

-- | 'addressTxsInnerTxHash' Lens
addressTxsInnerTxHashL :: Lens_' AddressTxsInner (Maybe TxHash)
addressTxsInnerTxHashL f AddressTxsInner{..} = (\addressTxsInnerTxHash -> AddressTxsInner { addressTxsInnerTxHash, ..} ) <$> f addressTxsInnerTxHash
{-# INLINE addressTxsInnerTxHashL #-}

-- | 'addressTxsInnerEpochNo' Lens
addressTxsInnerEpochNoL :: Lens_' AddressTxsInner (Maybe EpochNo)
addressTxsInnerEpochNoL f AddressTxsInner{..} = (\addressTxsInnerEpochNo -> AddressTxsInner { addressTxsInnerEpochNo, ..} ) <$> f addressTxsInnerEpochNo
{-# INLINE addressTxsInnerEpochNoL #-}

-- | 'addressTxsInnerBlockHeight' Lens
addressTxsInnerBlockHeightL :: Lens_' AddressTxsInner (Maybe BlockHeight)
addressTxsInnerBlockHeightL f AddressTxsInner{..} = (\addressTxsInnerBlockHeight -> AddressTxsInner { addressTxsInnerBlockHeight, ..} ) <$> f addressTxsInnerBlockHeight
{-# INLINE addressTxsInnerBlockHeightL #-}

-- | 'addressTxsInnerBlockTime' Lens
addressTxsInnerBlockTimeL :: Lens_' AddressTxsInner (Maybe BlockTime)
addressTxsInnerBlockTimeL f AddressTxsInner{..} = (\addressTxsInnerBlockTime -> AddressTxsInner { addressTxsInnerBlockTime, ..} ) <$> f addressTxsInnerBlockTime
{-# INLINE addressTxsInnerBlockTimeL #-}



-- * AddressTxsPostRequest

-- | 'addressTxsPostRequestAddresses' Lens
addressTxsPostRequestAddressesL :: Lens_' AddressTxsPostRequest ([Text])
addressTxsPostRequestAddressesL f AddressTxsPostRequest{..} = (\addressTxsPostRequestAddresses -> AddressTxsPostRequest { addressTxsPostRequestAddresses, ..} ) <$> f addressTxsPostRequestAddresses
{-# INLINE addressTxsPostRequestAddressesL #-}

-- | 'addressTxsPostRequestAfterBlockHeight' Lens
addressTxsPostRequestAfterBlockHeightL :: Lens_' AddressTxsPostRequest (Maybe Int)
addressTxsPostRequestAfterBlockHeightL f AddressTxsPostRequest{..} = (\addressTxsPostRequestAfterBlockHeight -> AddressTxsPostRequest { addressTxsPostRequestAfterBlockHeight, ..} ) <$> f addressTxsPostRequestAfterBlockHeight
{-# INLINE addressTxsPostRequestAfterBlockHeightL #-}



-- * AssetAddressListInner

-- | 'assetAddressListInnerPaymentAddress' Lens
assetAddressListInnerPaymentAddressL :: Lens_' AssetAddressListInner (Maybe Text)
assetAddressListInnerPaymentAddressL f AssetAddressListInner{..} = (\assetAddressListInnerPaymentAddress -> AssetAddressListInner { assetAddressListInnerPaymentAddress, ..} ) <$> f assetAddressListInnerPaymentAddress
{-# INLINE assetAddressListInnerPaymentAddressL #-}

-- | 'assetAddressListInnerQuantity' Lens
assetAddressListInnerQuantityL :: Lens_' AssetAddressListInner (Maybe Text)
assetAddressListInnerQuantityL f AssetAddressListInner{..} = (\assetAddressListInnerQuantity -> AssetAddressListInner { assetAddressListInnerQuantity, ..} ) <$> f assetAddressListInnerQuantity
{-# INLINE assetAddressListInnerQuantityL #-}



-- * AssetHistoryInner

-- | 'assetHistoryInnerPolicyId' Lens
assetHistoryInnerPolicyIdL :: Lens_' AssetHistoryInner (Maybe PolicyId)
assetHistoryInnerPolicyIdL f AssetHistoryInner{..} = (\assetHistoryInnerPolicyId -> AssetHistoryInner { assetHistoryInnerPolicyId, ..} ) <$> f assetHistoryInnerPolicyId
{-# INLINE assetHistoryInnerPolicyIdL #-}

-- | 'assetHistoryInnerAssetName' Lens
assetHistoryInnerAssetNameL :: Lens_' AssetHistoryInner (Maybe AssetName)
assetHistoryInnerAssetNameL f AssetHistoryInner{..} = (\assetHistoryInnerAssetName -> AssetHistoryInner { assetHistoryInnerAssetName, ..} ) <$> f assetHistoryInnerAssetName
{-# INLINE assetHistoryInnerAssetNameL #-}

-- | 'assetHistoryInnerMintingTxs' Lens
assetHistoryInnerMintingTxsL :: Lens_' AssetHistoryInner (Maybe [AssetHistoryInnerMintingTxsInner])
assetHistoryInnerMintingTxsL f AssetHistoryInner{..} = (\assetHistoryInnerMintingTxs -> AssetHistoryInner { assetHistoryInnerMintingTxs, ..} ) <$> f assetHistoryInnerMintingTxs
{-# INLINE assetHistoryInnerMintingTxsL #-}



-- * AssetHistoryInnerMintingTxsInner

-- | 'assetHistoryInnerMintingTxsInnerTxHash' Lens
assetHistoryInnerMintingTxsInnerTxHashL :: Lens_' AssetHistoryInnerMintingTxsInner (Maybe Text)
assetHistoryInnerMintingTxsInnerTxHashL f AssetHistoryInnerMintingTxsInner{..} = (\assetHistoryInnerMintingTxsInnerTxHash -> AssetHistoryInnerMintingTxsInner { assetHistoryInnerMintingTxsInnerTxHash, ..} ) <$> f assetHistoryInnerMintingTxsInnerTxHash
{-# INLINE assetHistoryInnerMintingTxsInnerTxHashL #-}

-- | 'assetHistoryInnerMintingTxsInnerBlockTime' Lens
assetHistoryInnerMintingTxsInnerBlockTimeL :: Lens_' AssetHistoryInnerMintingTxsInner (Maybe BlockTime)
assetHistoryInnerMintingTxsInnerBlockTimeL f AssetHistoryInnerMintingTxsInner{..} = (\assetHistoryInnerMintingTxsInnerBlockTime -> AssetHistoryInnerMintingTxsInner { assetHistoryInnerMintingTxsInnerBlockTime, ..} ) <$> f assetHistoryInnerMintingTxsInnerBlockTime
{-# INLINE assetHistoryInnerMintingTxsInnerBlockTimeL #-}

-- | 'assetHistoryInnerMintingTxsInnerQuantity' Lens
assetHistoryInnerMintingTxsInnerQuantityL :: Lens_' AssetHistoryInnerMintingTxsInner (Maybe Text)
assetHistoryInnerMintingTxsInnerQuantityL f AssetHistoryInnerMintingTxsInner{..} = (\assetHistoryInnerMintingTxsInnerQuantity -> AssetHistoryInnerMintingTxsInner { assetHistoryInnerMintingTxsInnerQuantity, ..} ) <$> f assetHistoryInnerMintingTxsInnerQuantity
{-# INLINE assetHistoryInnerMintingTxsInnerQuantityL #-}

-- | 'assetHistoryInnerMintingTxsInnerMetadata' Lens
assetHistoryInnerMintingTxsInnerMetadataL :: Lens_' AssetHistoryInnerMintingTxsInner (Maybe MintingTxMetadata)
assetHistoryInnerMintingTxsInnerMetadataL f AssetHistoryInnerMintingTxsInner{..} = (\assetHistoryInnerMintingTxsInnerMetadata -> AssetHistoryInnerMintingTxsInner { assetHistoryInnerMintingTxsInnerMetadata, ..} ) <$> f assetHistoryInnerMintingTxsInnerMetadata
{-# INLINE assetHistoryInnerMintingTxsInnerMetadataL #-}



-- * AssetInfoInner

-- | 'assetInfoInnerPolicyId' Lens
assetInfoInnerPolicyIdL :: Lens_' AssetInfoInner (Maybe Text)
assetInfoInnerPolicyIdL f AssetInfoInner{..} = (\assetInfoInnerPolicyId -> AssetInfoInner { assetInfoInnerPolicyId, ..} ) <$> f assetInfoInnerPolicyId
{-# INLINE assetInfoInnerPolicyIdL #-}

-- | 'assetInfoInnerAssetName' Lens
assetInfoInnerAssetNameL :: Lens_' AssetInfoInner (Maybe Text)
assetInfoInnerAssetNameL f AssetInfoInner{..} = (\assetInfoInnerAssetName -> AssetInfoInner { assetInfoInnerAssetName, ..} ) <$> f assetInfoInnerAssetName
{-# INLINE assetInfoInnerAssetNameL #-}

-- | 'assetInfoInnerAssetNameAscii' Lens
assetInfoInnerAssetNameAsciiL :: Lens_' AssetInfoInner (Maybe Text)
assetInfoInnerAssetNameAsciiL f AssetInfoInner{..} = (\assetInfoInnerAssetNameAscii -> AssetInfoInner { assetInfoInnerAssetNameAscii, ..} ) <$> f assetInfoInnerAssetNameAscii
{-# INLINE assetInfoInnerAssetNameAsciiL #-}

-- | 'assetInfoInnerFingerprint' Lens
assetInfoInnerFingerprintL :: Lens_' AssetInfoInner (Maybe Text)
assetInfoInnerFingerprintL f AssetInfoInner{..} = (\assetInfoInnerFingerprint -> AssetInfoInner { assetInfoInnerFingerprint, ..} ) <$> f assetInfoInnerFingerprint
{-# INLINE assetInfoInnerFingerprintL #-}

-- | 'assetInfoInnerMintingTxHash' Lens
assetInfoInnerMintingTxHashL :: Lens_' AssetInfoInner (Maybe Text)
assetInfoInnerMintingTxHashL f AssetInfoInner{..} = (\assetInfoInnerMintingTxHash -> AssetInfoInner { assetInfoInnerMintingTxHash, ..} ) <$> f assetInfoInnerMintingTxHash
{-# INLINE assetInfoInnerMintingTxHashL #-}

-- | 'assetInfoInnerMintCnt' Lens
assetInfoInnerMintCntL :: Lens_' AssetInfoInner (Maybe Int)
assetInfoInnerMintCntL f AssetInfoInner{..} = (\assetInfoInnerMintCnt -> AssetInfoInner { assetInfoInnerMintCnt, ..} ) <$> f assetInfoInnerMintCnt
{-# INLINE assetInfoInnerMintCntL #-}

-- | 'assetInfoInnerBurnCnt' Lens
assetInfoInnerBurnCntL :: Lens_' AssetInfoInner (Maybe Int)
assetInfoInnerBurnCntL f AssetInfoInner{..} = (\assetInfoInnerBurnCnt -> AssetInfoInner { assetInfoInnerBurnCnt, ..} ) <$> f assetInfoInnerBurnCnt
{-# INLINE assetInfoInnerBurnCntL #-}

-- | 'assetInfoInnerMintingTxMetadata' Lens
assetInfoInnerMintingTxMetadataL :: Lens_' AssetInfoInner (Maybe [AssetInfoInnerMintingTxMetadataInner])
assetInfoInnerMintingTxMetadataL f AssetInfoInner{..} = (\assetInfoInnerMintingTxMetadata -> AssetInfoInner { assetInfoInnerMintingTxMetadata, ..} ) <$> f assetInfoInnerMintingTxMetadata
{-# INLINE assetInfoInnerMintingTxMetadataL #-}

-- | 'assetInfoInnerTokenRegistryMetadata' Lens
assetInfoInnerTokenRegistryMetadataL :: Lens_' AssetInfoInner (Maybe AssetInfoInnerTokenRegistryMetadata)
assetInfoInnerTokenRegistryMetadataL f AssetInfoInner{..} = (\assetInfoInnerTokenRegistryMetadata -> AssetInfoInner { assetInfoInnerTokenRegistryMetadata, ..} ) <$> f assetInfoInnerTokenRegistryMetadata
{-# INLINE assetInfoInnerTokenRegistryMetadataL #-}

-- | 'assetInfoInnerTotalSupply' Lens
assetInfoInnerTotalSupplyL :: Lens_' AssetInfoInner (Maybe Text)
assetInfoInnerTotalSupplyL f AssetInfoInner{..} = (\assetInfoInnerTotalSupply -> AssetInfoInner { assetInfoInnerTotalSupply, ..} ) <$> f assetInfoInnerTotalSupply
{-# INLINE assetInfoInnerTotalSupplyL #-}

-- | 'assetInfoInnerCreationTime' Lens
assetInfoInnerCreationTimeL :: Lens_' AssetInfoInner (Maybe Int)
assetInfoInnerCreationTimeL f AssetInfoInner{..} = (\assetInfoInnerCreationTime -> AssetInfoInner { assetInfoInnerCreationTime, ..} ) <$> f assetInfoInnerCreationTime
{-# INLINE assetInfoInnerCreationTimeL #-}



-- * AssetInfoInnerMintingTxMetadataInner

-- | 'assetInfoInnerMintingTxMetadataInnerKey' Lens
assetInfoInnerMintingTxMetadataInnerKeyL :: Lens_' AssetInfoInnerMintingTxMetadataInner (Maybe Text)
assetInfoInnerMintingTxMetadataInnerKeyL f AssetInfoInnerMintingTxMetadataInner{..} = (\assetInfoInnerMintingTxMetadataInnerKey -> AssetInfoInnerMintingTxMetadataInner { assetInfoInnerMintingTxMetadataInnerKey, ..} ) <$> f assetInfoInnerMintingTxMetadataInnerKey
{-# INLINE assetInfoInnerMintingTxMetadataInnerKeyL #-}

-- | 'assetInfoInnerMintingTxMetadataInnerJson' Lens
assetInfoInnerMintingTxMetadataInnerJsonL :: Lens_' AssetInfoInnerMintingTxMetadataInner (Maybe A.Value)
assetInfoInnerMintingTxMetadataInnerJsonL f AssetInfoInnerMintingTxMetadataInner{..} = (\assetInfoInnerMintingTxMetadataInnerJson -> AssetInfoInnerMintingTxMetadataInner { assetInfoInnerMintingTxMetadataInnerJson, ..} ) <$> f assetInfoInnerMintingTxMetadataInnerJson
{-# INLINE assetInfoInnerMintingTxMetadataInnerJsonL #-}



-- * AssetInfoInnerTokenRegistryMetadata

-- | 'assetInfoInnerTokenRegistryMetadataName' Lens
assetInfoInnerTokenRegistryMetadataNameL :: Lens_' AssetInfoInnerTokenRegistryMetadata (Maybe Text)
assetInfoInnerTokenRegistryMetadataNameL f AssetInfoInnerTokenRegistryMetadata{..} = (\assetInfoInnerTokenRegistryMetadataName -> AssetInfoInnerTokenRegistryMetadata { assetInfoInnerTokenRegistryMetadataName, ..} ) <$> f assetInfoInnerTokenRegistryMetadataName
{-# INLINE assetInfoInnerTokenRegistryMetadataNameL #-}

-- | 'assetInfoInnerTokenRegistryMetadataDescription' Lens
assetInfoInnerTokenRegistryMetadataDescriptionL :: Lens_' AssetInfoInnerTokenRegistryMetadata (Maybe Text)
assetInfoInnerTokenRegistryMetadataDescriptionL f AssetInfoInnerTokenRegistryMetadata{..} = (\assetInfoInnerTokenRegistryMetadataDescription -> AssetInfoInnerTokenRegistryMetadata { assetInfoInnerTokenRegistryMetadataDescription, ..} ) <$> f assetInfoInnerTokenRegistryMetadataDescription
{-# INLINE assetInfoInnerTokenRegistryMetadataDescriptionL #-}

-- | 'assetInfoInnerTokenRegistryMetadataTicker' Lens
assetInfoInnerTokenRegistryMetadataTickerL :: Lens_' AssetInfoInnerTokenRegistryMetadata (Maybe Text)
assetInfoInnerTokenRegistryMetadataTickerL f AssetInfoInnerTokenRegistryMetadata{..} = (\assetInfoInnerTokenRegistryMetadataTicker -> AssetInfoInnerTokenRegistryMetadata { assetInfoInnerTokenRegistryMetadataTicker, ..} ) <$> f assetInfoInnerTokenRegistryMetadataTicker
{-# INLINE assetInfoInnerTokenRegistryMetadataTickerL #-}

-- | 'assetInfoInnerTokenRegistryMetadataUrl' Lens
assetInfoInnerTokenRegistryMetadataUrlL :: Lens_' AssetInfoInnerTokenRegistryMetadata (Maybe Text)
assetInfoInnerTokenRegistryMetadataUrlL f AssetInfoInnerTokenRegistryMetadata{..} = (\assetInfoInnerTokenRegistryMetadataUrl -> AssetInfoInnerTokenRegistryMetadata { assetInfoInnerTokenRegistryMetadataUrl, ..} ) <$> f assetInfoInnerTokenRegistryMetadataUrl
{-# INLINE assetInfoInnerTokenRegistryMetadataUrlL #-}

-- | 'assetInfoInnerTokenRegistryMetadataLogo' Lens
assetInfoInnerTokenRegistryMetadataLogoL :: Lens_' AssetInfoInnerTokenRegistryMetadata (Maybe Text)
assetInfoInnerTokenRegistryMetadataLogoL f AssetInfoInnerTokenRegistryMetadata{..} = (\assetInfoInnerTokenRegistryMetadataLogo -> AssetInfoInnerTokenRegistryMetadata { assetInfoInnerTokenRegistryMetadataLogo, ..} ) <$> f assetInfoInnerTokenRegistryMetadataLogo
{-# INLINE assetInfoInnerTokenRegistryMetadataLogoL #-}

-- | 'assetInfoInnerTokenRegistryMetadataDecimals' Lens
assetInfoInnerTokenRegistryMetadataDecimalsL :: Lens_' AssetInfoInnerTokenRegistryMetadata (Maybe Int)
assetInfoInnerTokenRegistryMetadataDecimalsL f AssetInfoInnerTokenRegistryMetadata{..} = (\assetInfoInnerTokenRegistryMetadataDecimals -> AssetInfoInnerTokenRegistryMetadata { assetInfoInnerTokenRegistryMetadataDecimals, ..} ) <$> f assetInfoInnerTokenRegistryMetadataDecimals
{-# INLINE assetInfoInnerTokenRegistryMetadataDecimalsL #-}



-- * AssetListInner

-- | 'assetListInnerPolicyId' Lens
assetListInnerPolicyIdL :: Lens_' AssetListInner (Maybe PolicyId)
assetListInnerPolicyIdL f AssetListInner{..} = (\assetListInnerPolicyId -> AssetListInner { assetListInnerPolicyId, ..} ) <$> f assetListInnerPolicyId
{-# INLINE assetListInnerPolicyIdL #-}

-- | 'assetListInnerAssetNames' Lens
assetListInnerAssetNamesL :: Lens_' AssetListInner (Maybe AssetListInnerAssetNames)
assetListInnerAssetNamesL f AssetListInner{..} = (\assetListInnerAssetNames -> AssetListInner { assetListInnerAssetNames, ..} ) <$> f assetListInnerAssetNames
{-# INLINE assetListInnerAssetNamesL #-}



-- * AssetListInnerAssetNames

-- | 'assetListInnerAssetNamesHex' Lens
assetListInnerAssetNamesHexL :: Lens_' AssetListInnerAssetNames (Maybe [Text])
assetListInnerAssetNamesHexL f AssetListInnerAssetNames{..} = (\assetListInnerAssetNamesHex -> AssetListInnerAssetNames { assetListInnerAssetNamesHex, ..} ) <$> f assetListInnerAssetNamesHex
{-# INLINE assetListInnerAssetNamesHexL #-}

-- | 'assetListInnerAssetNamesAscii' Lens
assetListInnerAssetNamesAsciiL :: Lens_' AssetListInnerAssetNames (Maybe [Text])
assetListInnerAssetNamesAsciiL f AssetListInnerAssetNames{..} = (\assetListInnerAssetNamesAscii -> AssetListInnerAssetNames { assetListInnerAssetNamesAscii, ..} ) <$> f assetListInnerAssetNamesAscii
{-# INLINE assetListInnerAssetNamesAsciiL #-}



-- * AssetPolicyInfoInner

-- | 'assetPolicyInfoInnerAssetName' Lens
assetPolicyInfoInnerAssetNameL :: Lens_' AssetPolicyInfoInner (Maybe AssetName)
assetPolicyInfoInnerAssetNameL f AssetPolicyInfoInner{..} = (\assetPolicyInfoInnerAssetName -> AssetPolicyInfoInner { assetPolicyInfoInnerAssetName, ..} ) <$> f assetPolicyInfoInnerAssetName
{-# INLINE assetPolicyInfoInnerAssetNameL #-}

-- | 'assetPolicyInfoInnerAssetNameAscii' Lens
assetPolicyInfoInnerAssetNameAsciiL :: Lens_' AssetPolicyInfoInner (Maybe AssetNameAscii)
assetPolicyInfoInnerAssetNameAsciiL f AssetPolicyInfoInner{..} = (\assetPolicyInfoInnerAssetNameAscii -> AssetPolicyInfoInner { assetPolicyInfoInnerAssetNameAscii, ..} ) <$> f assetPolicyInfoInnerAssetNameAscii
{-# INLINE assetPolicyInfoInnerAssetNameAsciiL #-}

-- | 'assetPolicyInfoInnerFingerprint' Lens
assetPolicyInfoInnerFingerprintL :: Lens_' AssetPolicyInfoInner (Maybe Fingerprint)
assetPolicyInfoInnerFingerprintL f AssetPolicyInfoInner{..} = (\assetPolicyInfoInnerFingerprint -> AssetPolicyInfoInner { assetPolicyInfoInnerFingerprint, ..} ) <$> f assetPolicyInfoInnerFingerprint
{-# INLINE assetPolicyInfoInnerFingerprintL #-}

-- | 'assetPolicyInfoInnerMintingTxMetadata' Lens
assetPolicyInfoInnerMintingTxMetadataL :: Lens_' AssetPolicyInfoInner (Maybe MintingTxMetadata)
assetPolicyInfoInnerMintingTxMetadataL f AssetPolicyInfoInner{..} = (\assetPolicyInfoInnerMintingTxMetadata -> AssetPolicyInfoInner { assetPolicyInfoInnerMintingTxMetadata, ..} ) <$> f assetPolicyInfoInnerMintingTxMetadata
{-# INLINE assetPolicyInfoInnerMintingTxMetadataL #-}

-- | 'assetPolicyInfoInnerTokenRegistryMetadata' Lens
assetPolicyInfoInnerTokenRegistryMetadataL :: Lens_' AssetPolicyInfoInner (Maybe TokenRegistryMetadata)
assetPolicyInfoInnerTokenRegistryMetadataL f AssetPolicyInfoInner{..} = (\assetPolicyInfoInnerTokenRegistryMetadata -> AssetPolicyInfoInner { assetPolicyInfoInnerTokenRegistryMetadata, ..} ) <$> f assetPolicyInfoInnerTokenRegistryMetadata
{-# INLINE assetPolicyInfoInnerTokenRegistryMetadataL #-}

-- | 'assetPolicyInfoInnerTotalSupply' Lens
assetPolicyInfoInnerTotalSupplyL :: Lens_' AssetPolicyInfoInner (Maybe Text)
assetPolicyInfoInnerTotalSupplyL f AssetPolicyInfoInner{..} = (\assetPolicyInfoInnerTotalSupply -> AssetPolicyInfoInner { assetPolicyInfoInnerTotalSupply, ..} ) <$> f assetPolicyInfoInnerTotalSupply
{-# INLINE assetPolicyInfoInnerTotalSupplyL #-}

-- | 'assetPolicyInfoInnerCreationTime' Lens
assetPolicyInfoInnerCreationTimeL :: Lens_' AssetPolicyInfoInner (Maybe CreationTime)
assetPolicyInfoInnerCreationTimeL f AssetPolicyInfoInner{..} = (\assetPolicyInfoInnerCreationTime -> AssetPolicyInfoInner { assetPolicyInfoInnerCreationTime, ..} ) <$> f assetPolicyInfoInnerCreationTime
{-# INLINE assetPolicyInfoInnerCreationTimeL #-}



-- * AssetSummaryInner

-- | 'assetSummaryInnerPolicyId' Lens
assetSummaryInnerPolicyIdL :: Lens_' AssetSummaryInner (Maybe PolicyId)
assetSummaryInnerPolicyIdL f AssetSummaryInner{..} = (\assetSummaryInnerPolicyId -> AssetSummaryInner { assetSummaryInnerPolicyId, ..} ) <$> f assetSummaryInnerPolicyId
{-# INLINE assetSummaryInnerPolicyIdL #-}

-- | 'assetSummaryInnerAssetName' Lens
assetSummaryInnerAssetNameL :: Lens_' AssetSummaryInner (Maybe AssetName)
assetSummaryInnerAssetNameL f AssetSummaryInner{..} = (\assetSummaryInnerAssetName -> AssetSummaryInner { assetSummaryInnerAssetName, ..} ) <$> f assetSummaryInnerAssetName
{-# INLINE assetSummaryInnerAssetNameL #-}

-- | 'assetSummaryInnerTotalTransactions' Lens
assetSummaryInnerTotalTransactionsL :: Lens_' AssetSummaryInner (Maybe Int)
assetSummaryInnerTotalTransactionsL f AssetSummaryInner{..} = (\assetSummaryInnerTotalTransactions -> AssetSummaryInner { assetSummaryInnerTotalTransactions, ..} ) <$> f assetSummaryInnerTotalTransactions
{-# INLINE assetSummaryInnerTotalTransactionsL #-}

-- | 'assetSummaryInnerStakedWallets' Lens
assetSummaryInnerStakedWalletsL :: Lens_' AssetSummaryInner (Maybe Int)
assetSummaryInnerStakedWalletsL f AssetSummaryInner{..} = (\assetSummaryInnerStakedWallets -> AssetSummaryInner { assetSummaryInnerStakedWallets, ..} ) <$> f assetSummaryInnerStakedWallets
{-# INLINE assetSummaryInnerStakedWalletsL #-}

-- | 'assetSummaryInnerUnstakedAddresses' Lens
assetSummaryInnerUnstakedAddressesL :: Lens_' AssetSummaryInner (Maybe Int)
assetSummaryInnerUnstakedAddressesL f AssetSummaryInner{..} = (\assetSummaryInnerUnstakedAddresses -> AssetSummaryInner { assetSummaryInnerUnstakedAddresses, ..} ) <$> f assetSummaryInnerUnstakedAddresses
{-# INLINE assetSummaryInnerUnstakedAddressesL #-}



-- * AssetTxsInner

-- | 'assetTxsInnerTxHash' Lens
assetTxsInnerTxHashL :: Lens_' AssetTxsInner (Maybe TxHash)
assetTxsInnerTxHashL f AssetTxsInner{..} = (\assetTxsInnerTxHash -> AssetTxsInner { assetTxsInnerTxHash, ..} ) <$> f assetTxsInnerTxHash
{-# INLINE assetTxsInnerTxHashL #-}

-- | 'assetTxsInnerEpochNo' Lens
assetTxsInnerEpochNoL :: Lens_' AssetTxsInner (Maybe EpochNo)
assetTxsInnerEpochNoL f AssetTxsInner{..} = (\assetTxsInnerEpochNo -> AssetTxsInner { assetTxsInnerEpochNo, ..} ) <$> f assetTxsInnerEpochNo
{-# INLINE assetTxsInnerEpochNoL #-}

-- | 'assetTxsInnerBlockHeight' Lens
assetTxsInnerBlockHeightL :: Lens_' AssetTxsInner (Maybe BlockHeight)
assetTxsInnerBlockHeightL f AssetTxsInner{..} = (\assetTxsInnerBlockHeight -> AssetTxsInner { assetTxsInnerBlockHeight, ..} ) <$> f assetTxsInnerBlockHeight
{-# INLINE assetTxsInnerBlockHeightL #-}

-- | 'assetTxsInnerBlockTime' Lens
assetTxsInnerBlockTimeL :: Lens_' AssetTxsInner (Maybe BlockTime)
assetTxsInnerBlockTimeL f AssetTxsInner{..} = (\assetTxsInnerBlockTime -> AssetTxsInner { assetTxsInnerBlockTime, ..} ) <$> f assetTxsInnerBlockTime
{-# INLINE assetTxsInnerBlockTimeL #-}



-- * BlockInfoInner

-- | 'blockInfoInnerHash' Lens
blockInfoInnerHashL :: Lens_' BlockInfoInner (Maybe Hash)
blockInfoInnerHashL f BlockInfoInner{..} = (\blockInfoInnerHash -> BlockInfoInner { blockInfoInnerHash, ..} ) <$> f blockInfoInnerHash
{-# INLINE blockInfoInnerHashL #-}

-- | 'blockInfoInnerEpochNo' Lens
blockInfoInnerEpochNoL :: Lens_' BlockInfoInner (Maybe EpochNo)
blockInfoInnerEpochNoL f BlockInfoInner{..} = (\blockInfoInnerEpochNo -> BlockInfoInner { blockInfoInnerEpochNo, ..} ) <$> f blockInfoInnerEpochNo
{-# INLINE blockInfoInnerEpochNoL #-}

-- | 'blockInfoInnerAbsSlot' Lens
blockInfoInnerAbsSlotL :: Lens_' BlockInfoInner (Maybe AbsSlot)
blockInfoInnerAbsSlotL f BlockInfoInner{..} = (\blockInfoInnerAbsSlot -> BlockInfoInner { blockInfoInnerAbsSlot, ..} ) <$> f blockInfoInnerAbsSlot
{-# INLINE blockInfoInnerAbsSlotL #-}

-- | 'blockInfoInnerEpochSlot' Lens
blockInfoInnerEpochSlotL :: Lens_' BlockInfoInner (Maybe EpochSlot)
blockInfoInnerEpochSlotL f BlockInfoInner{..} = (\blockInfoInnerEpochSlot -> BlockInfoInner { blockInfoInnerEpochSlot, ..} ) <$> f blockInfoInnerEpochSlot
{-# INLINE blockInfoInnerEpochSlotL #-}

-- | 'blockInfoInnerBlockHeight' Lens
blockInfoInnerBlockHeightL :: Lens_' BlockInfoInner (Maybe BlockHeight)
blockInfoInnerBlockHeightL f BlockInfoInner{..} = (\blockInfoInnerBlockHeight -> BlockInfoInner { blockInfoInnerBlockHeight, ..} ) <$> f blockInfoInnerBlockHeight
{-# INLINE blockInfoInnerBlockHeightL #-}

-- | 'blockInfoInnerBlockSize' Lens
blockInfoInnerBlockSizeL :: Lens_' BlockInfoInner (Maybe BlockSize)
blockInfoInnerBlockSizeL f BlockInfoInner{..} = (\blockInfoInnerBlockSize -> BlockInfoInner { blockInfoInnerBlockSize, ..} ) <$> f blockInfoInnerBlockSize
{-# INLINE blockInfoInnerBlockSizeL #-}

-- | 'blockInfoInnerBlockTime' Lens
blockInfoInnerBlockTimeL :: Lens_' BlockInfoInner (Maybe BlockTime)
blockInfoInnerBlockTimeL f BlockInfoInner{..} = (\blockInfoInnerBlockTime -> BlockInfoInner { blockInfoInnerBlockTime, ..} ) <$> f blockInfoInnerBlockTime
{-# INLINE blockInfoInnerBlockTimeL #-}

-- | 'blockInfoInnerTxCount' Lens
blockInfoInnerTxCountL :: Lens_' BlockInfoInner (Maybe TxCount)
blockInfoInnerTxCountL f BlockInfoInner{..} = (\blockInfoInnerTxCount -> BlockInfoInner { blockInfoInnerTxCount, ..} ) <$> f blockInfoInnerTxCount
{-# INLINE blockInfoInnerTxCountL #-}

-- | 'blockInfoInnerVrfKey' Lens
blockInfoInnerVrfKeyL :: Lens_' BlockInfoInner (Maybe VrfKey)
blockInfoInnerVrfKeyL f BlockInfoInner{..} = (\blockInfoInnerVrfKey -> BlockInfoInner { blockInfoInnerVrfKey, ..} ) <$> f blockInfoInnerVrfKey
{-# INLINE blockInfoInnerVrfKeyL #-}

-- | 'blockInfoInnerOpCert' Lens
blockInfoInnerOpCertL :: Lens_' BlockInfoInner (Maybe Text)
blockInfoInnerOpCertL f BlockInfoInner{..} = (\blockInfoInnerOpCert -> BlockInfoInner { blockInfoInnerOpCert, ..} ) <$> f blockInfoInnerOpCert
{-# INLINE blockInfoInnerOpCertL #-}

-- | 'blockInfoInnerOpCertCounter' Lens
blockInfoInnerOpCertCounterL :: Lens_' BlockInfoInner (Maybe OpCertCounter)
blockInfoInnerOpCertCounterL f BlockInfoInner{..} = (\blockInfoInnerOpCertCounter -> BlockInfoInner { blockInfoInnerOpCertCounter, ..} ) <$> f blockInfoInnerOpCertCounter
{-# INLINE blockInfoInnerOpCertCounterL #-}

-- | 'blockInfoInnerPool' Lens
blockInfoInnerPoolL :: Lens_' BlockInfoInner (Maybe Pool)
blockInfoInnerPoolL f BlockInfoInner{..} = (\blockInfoInnerPool -> BlockInfoInner { blockInfoInnerPool, ..} ) <$> f blockInfoInnerPool
{-# INLINE blockInfoInnerPoolL #-}

-- | 'blockInfoInnerProtoMajor' Lens
blockInfoInnerProtoMajorL :: Lens_' BlockInfoInner (Maybe ProtocolMajor)
blockInfoInnerProtoMajorL f BlockInfoInner{..} = (\blockInfoInnerProtoMajor -> BlockInfoInner { blockInfoInnerProtoMajor, ..} ) <$> f blockInfoInnerProtoMajor
{-# INLINE blockInfoInnerProtoMajorL #-}

-- | 'blockInfoInnerProtoMinor' Lens
blockInfoInnerProtoMinorL :: Lens_' BlockInfoInner (Maybe ProtocolMinor)
blockInfoInnerProtoMinorL f BlockInfoInner{..} = (\blockInfoInnerProtoMinor -> BlockInfoInner { blockInfoInnerProtoMinor, ..} ) <$> f blockInfoInnerProtoMinor
{-# INLINE blockInfoInnerProtoMinorL #-}

-- | 'blockInfoInnerTotalOutput' Lens
blockInfoInnerTotalOutputL :: Lens_' BlockInfoInner (Maybe Text)
blockInfoInnerTotalOutputL f BlockInfoInner{..} = (\blockInfoInnerTotalOutput -> BlockInfoInner { blockInfoInnerTotalOutput, ..} ) <$> f blockInfoInnerTotalOutput
{-# INLINE blockInfoInnerTotalOutputL #-}

-- | 'blockInfoInnerTotalFees' Lens
blockInfoInnerTotalFeesL :: Lens_' BlockInfoInner (Maybe Text)
blockInfoInnerTotalFeesL f BlockInfoInner{..} = (\blockInfoInnerTotalFees -> BlockInfoInner { blockInfoInnerTotalFees, ..} ) <$> f blockInfoInnerTotalFees
{-# INLINE blockInfoInnerTotalFeesL #-}

-- | 'blockInfoInnerNumConfirmations' Lens
blockInfoInnerNumConfirmationsL :: Lens_' BlockInfoInner (Maybe Int)
blockInfoInnerNumConfirmationsL f BlockInfoInner{..} = (\blockInfoInnerNumConfirmations -> BlockInfoInner { blockInfoInnerNumConfirmations, ..} ) <$> f blockInfoInnerNumConfirmations
{-# INLINE blockInfoInnerNumConfirmationsL #-}

-- | 'blockInfoInnerParentHash' Lens
blockInfoInnerParentHashL :: Lens_' BlockInfoInner (Maybe Text)
blockInfoInnerParentHashL f BlockInfoInner{..} = (\blockInfoInnerParentHash -> BlockInfoInner { blockInfoInnerParentHash, ..} ) <$> f blockInfoInnerParentHash
{-# INLINE blockInfoInnerParentHashL #-}

-- | 'blockInfoInnerChildHash' Lens
blockInfoInnerChildHashL :: Lens_' BlockInfoInner (Maybe Text)
blockInfoInnerChildHashL f BlockInfoInner{..} = (\blockInfoInnerChildHash -> BlockInfoInner { blockInfoInnerChildHash, ..} ) <$> f blockInfoInnerChildHash
{-# INLINE blockInfoInnerChildHashL #-}



-- * BlockInfoPostRequest

-- | 'blockInfoPostRequestBlockHashes' Lens
blockInfoPostRequestBlockHashesL :: Lens_' BlockInfoPostRequest ([Hash])
blockInfoPostRequestBlockHashesL f BlockInfoPostRequest{..} = (\blockInfoPostRequestBlockHashes -> BlockInfoPostRequest { blockInfoPostRequestBlockHashes, ..} ) <$> f blockInfoPostRequestBlockHashes
{-# INLINE blockInfoPostRequestBlockHashesL #-}



-- * BlockTxsInner

-- | 'blockTxsInnerBlockHash' Lens
blockTxsInnerBlockHashL :: Lens_' BlockTxsInner (Maybe Hash)
blockTxsInnerBlockHashL f BlockTxsInner{..} = (\blockTxsInnerBlockHash -> BlockTxsInner { blockTxsInnerBlockHash, ..} ) <$> f blockTxsInnerBlockHash
{-# INLINE blockTxsInnerBlockHashL #-}

-- | 'blockTxsInnerTxHashes' Lens
blockTxsInnerTxHashesL :: Lens_' BlockTxsInner (Maybe [TxHash])
blockTxsInnerTxHashesL f BlockTxsInner{..} = (\blockTxsInnerTxHashes -> BlockTxsInner { blockTxsInnerTxHashes, ..} ) <$> f blockTxsInnerTxHashes
{-# INLINE blockTxsInnerTxHashesL #-}



-- * BlocksInner

-- | 'blocksInnerHash' Lens
blocksInnerHashL :: Lens_' BlocksInner (Maybe Text)
blocksInnerHashL f BlocksInner{..} = (\blocksInnerHash -> BlocksInner { blocksInnerHash, ..} ) <$> f blocksInnerHash
{-# INLINE blocksInnerHashL #-}

-- | 'blocksInnerEpochNo' Lens
blocksInnerEpochNoL :: Lens_' BlocksInner (Maybe Int)
blocksInnerEpochNoL f BlocksInner{..} = (\blocksInnerEpochNo -> BlocksInner { blocksInnerEpochNo, ..} ) <$> f blocksInnerEpochNo
{-# INLINE blocksInnerEpochNoL #-}

-- | 'blocksInnerAbsSlot' Lens
blocksInnerAbsSlotL :: Lens_' BlocksInner (Maybe Int)
blocksInnerAbsSlotL f BlocksInner{..} = (\blocksInnerAbsSlot -> BlocksInner { blocksInnerAbsSlot, ..} ) <$> f blocksInnerAbsSlot
{-# INLINE blocksInnerAbsSlotL #-}

-- | 'blocksInnerEpochSlot' Lens
blocksInnerEpochSlotL :: Lens_' BlocksInner (Maybe Int)
blocksInnerEpochSlotL f BlocksInner{..} = (\blocksInnerEpochSlot -> BlocksInner { blocksInnerEpochSlot, ..} ) <$> f blocksInnerEpochSlot
{-# INLINE blocksInnerEpochSlotL #-}

-- | 'blocksInnerBlockHeight' Lens
blocksInnerBlockHeightL :: Lens_' BlocksInner (Maybe Int)
blocksInnerBlockHeightL f BlocksInner{..} = (\blocksInnerBlockHeight -> BlocksInner { blocksInnerBlockHeight, ..} ) <$> f blocksInnerBlockHeight
{-# INLINE blocksInnerBlockHeightL #-}

-- | 'blocksInnerBlockSize' Lens
blocksInnerBlockSizeL :: Lens_' BlocksInner (Maybe Int)
blocksInnerBlockSizeL f BlocksInner{..} = (\blocksInnerBlockSize -> BlocksInner { blocksInnerBlockSize, ..} ) <$> f blocksInnerBlockSize
{-# INLINE blocksInnerBlockSizeL #-}

-- | 'blocksInnerBlockTime' Lens
blocksInnerBlockTimeL :: Lens_' BlocksInner (Maybe Int)
blocksInnerBlockTimeL f BlocksInner{..} = (\blocksInnerBlockTime -> BlocksInner { blocksInnerBlockTime, ..} ) <$> f blocksInnerBlockTime
{-# INLINE blocksInnerBlockTimeL #-}

-- | 'blocksInnerTxCount' Lens
blocksInnerTxCountL :: Lens_' BlocksInner (Maybe Int)
blocksInnerTxCountL f BlocksInner{..} = (\blocksInnerTxCount -> BlocksInner { blocksInnerTxCount, ..} ) <$> f blocksInnerTxCount
{-# INLINE blocksInnerTxCountL #-}

-- | 'blocksInnerVrfKey' Lens
blocksInnerVrfKeyL :: Lens_' BlocksInner (Maybe Text)
blocksInnerVrfKeyL f BlocksInner{..} = (\blocksInnerVrfKey -> BlocksInner { blocksInnerVrfKey, ..} ) <$> f blocksInnerVrfKey
{-# INLINE blocksInnerVrfKeyL #-}

-- | 'blocksInnerPool' Lens
blocksInnerPoolL :: Lens_' BlocksInner (Maybe Text)
blocksInnerPoolL f BlocksInner{..} = (\blocksInnerPool -> BlocksInner { blocksInnerPool, ..} ) <$> f blocksInnerPool
{-# INLINE blocksInnerPoolL #-}

-- | 'blocksInnerOpCertCounter' Lens
blocksInnerOpCertCounterL :: Lens_' BlocksInner (Maybe Int)
blocksInnerOpCertCounterL f BlocksInner{..} = (\blocksInnerOpCertCounter -> BlocksInner { blocksInnerOpCertCounter, ..} ) <$> f blocksInnerOpCertCounter
{-# INLINE blocksInnerOpCertCounterL #-}

-- | 'blocksInnerProtoMajor' Lens
blocksInnerProtoMajorL :: Lens_' BlocksInner (Maybe ProtocolMajor)
blocksInnerProtoMajorL f BlocksInner{..} = (\blocksInnerProtoMajor -> BlocksInner { blocksInnerProtoMajor, ..} ) <$> f blocksInnerProtoMajor
{-# INLINE blocksInnerProtoMajorL #-}

-- | 'blocksInnerProtoMinor' Lens
blocksInnerProtoMinorL :: Lens_' BlocksInner (Maybe ProtocolMinor)
blocksInnerProtoMinorL f BlocksInner{..} = (\blocksInnerProtoMinor -> BlocksInner { blocksInnerProtoMinor, ..} ) <$> f blocksInnerProtoMinor
{-# INLINE blocksInnerProtoMinorL #-}



-- * CredentialTxsPostRequest

-- | 'credentialTxsPostRequestPaymentCredentials' Lens
credentialTxsPostRequestPaymentCredentialsL :: Lens_' CredentialTxsPostRequest ([Text])
credentialTxsPostRequestPaymentCredentialsL f CredentialTxsPostRequest{..} = (\credentialTxsPostRequestPaymentCredentials -> CredentialTxsPostRequest { credentialTxsPostRequestPaymentCredentials, ..} ) <$> f credentialTxsPostRequestPaymentCredentials
{-# INLINE credentialTxsPostRequestPaymentCredentialsL #-}

-- | 'credentialTxsPostRequestAfterBlockHeight' Lens
credentialTxsPostRequestAfterBlockHeightL :: Lens_' CredentialTxsPostRequest (Maybe Int)
credentialTxsPostRequestAfterBlockHeightL f CredentialTxsPostRequest{..} = (\credentialTxsPostRequestAfterBlockHeight -> CredentialTxsPostRequest { credentialTxsPostRequestAfterBlockHeight, ..} ) <$> f credentialTxsPostRequestAfterBlockHeight
{-# INLINE credentialTxsPostRequestAfterBlockHeightL #-}



-- * EpochInfoInner

-- | 'epochInfoInnerEpochNo' Lens
epochInfoInnerEpochNoL :: Lens_' EpochInfoInner (Maybe Int)
epochInfoInnerEpochNoL f EpochInfoInner{..} = (\epochInfoInnerEpochNo -> EpochInfoInner { epochInfoInnerEpochNo, ..} ) <$> f epochInfoInnerEpochNo
{-# INLINE epochInfoInnerEpochNoL #-}

-- | 'epochInfoInnerOutSum' Lens
epochInfoInnerOutSumL :: Lens_' EpochInfoInner (Maybe Text)
epochInfoInnerOutSumL f EpochInfoInner{..} = (\epochInfoInnerOutSum -> EpochInfoInner { epochInfoInnerOutSum, ..} ) <$> f epochInfoInnerOutSum
{-# INLINE epochInfoInnerOutSumL #-}

-- | 'epochInfoInnerFees' Lens
epochInfoInnerFeesL :: Lens_' EpochInfoInner (Maybe Text)
epochInfoInnerFeesL f EpochInfoInner{..} = (\epochInfoInnerFees -> EpochInfoInner { epochInfoInnerFees, ..} ) <$> f epochInfoInnerFees
{-# INLINE epochInfoInnerFeesL #-}

-- | 'epochInfoInnerTxCount' Lens
epochInfoInnerTxCountL :: Lens_' EpochInfoInner (Maybe Int)
epochInfoInnerTxCountL f EpochInfoInner{..} = (\epochInfoInnerTxCount -> EpochInfoInner { epochInfoInnerTxCount, ..} ) <$> f epochInfoInnerTxCount
{-# INLINE epochInfoInnerTxCountL #-}

-- | 'epochInfoInnerBlkCount' Lens
epochInfoInnerBlkCountL :: Lens_' EpochInfoInner (Maybe Int)
epochInfoInnerBlkCountL f EpochInfoInner{..} = (\epochInfoInnerBlkCount -> EpochInfoInner { epochInfoInnerBlkCount, ..} ) <$> f epochInfoInnerBlkCount
{-# INLINE epochInfoInnerBlkCountL #-}

-- | 'epochInfoInnerStartTime' Lens
epochInfoInnerStartTimeL :: Lens_' EpochInfoInner (Maybe Int)
epochInfoInnerStartTimeL f EpochInfoInner{..} = (\epochInfoInnerStartTime -> EpochInfoInner { epochInfoInnerStartTime, ..} ) <$> f epochInfoInnerStartTime
{-# INLINE epochInfoInnerStartTimeL #-}

-- | 'epochInfoInnerEndTime' Lens
epochInfoInnerEndTimeL :: Lens_' EpochInfoInner (Maybe Int)
epochInfoInnerEndTimeL f EpochInfoInner{..} = (\epochInfoInnerEndTime -> EpochInfoInner { epochInfoInnerEndTime, ..} ) <$> f epochInfoInnerEndTime
{-# INLINE epochInfoInnerEndTimeL #-}

-- | 'epochInfoInnerFirstBlockTime' Lens
epochInfoInnerFirstBlockTimeL :: Lens_' EpochInfoInner (Maybe Int)
epochInfoInnerFirstBlockTimeL f EpochInfoInner{..} = (\epochInfoInnerFirstBlockTime -> EpochInfoInner { epochInfoInnerFirstBlockTime, ..} ) <$> f epochInfoInnerFirstBlockTime
{-# INLINE epochInfoInnerFirstBlockTimeL #-}

-- | 'epochInfoInnerLastBlockTime' Lens
epochInfoInnerLastBlockTimeL :: Lens_' EpochInfoInner (Maybe Int)
epochInfoInnerLastBlockTimeL f EpochInfoInner{..} = (\epochInfoInnerLastBlockTime -> EpochInfoInner { epochInfoInnerLastBlockTime, ..} ) <$> f epochInfoInnerLastBlockTime
{-# INLINE epochInfoInnerLastBlockTimeL #-}

-- | 'epochInfoInnerActiveStake' Lens
epochInfoInnerActiveStakeL :: Lens_' EpochInfoInner (Maybe Text)
epochInfoInnerActiveStakeL f EpochInfoInner{..} = (\epochInfoInnerActiveStake -> EpochInfoInner { epochInfoInnerActiveStake, ..} ) <$> f epochInfoInnerActiveStake
{-# INLINE epochInfoInnerActiveStakeL #-}

-- | 'epochInfoInnerTotalRewards' Lens
epochInfoInnerTotalRewardsL :: Lens_' EpochInfoInner (Maybe Text)
epochInfoInnerTotalRewardsL f EpochInfoInner{..} = (\epochInfoInnerTotalRewards -> EpochInfoInner { epochInfoInnerTotalRewards, ..} ) <$> f epochInfoInnerTotalRewards
{-# INLINE epochInfoInnerTotalRewardsL #-}

-- | 'epochInfoInnerAvgBlkReward' Lens
epochInfoInnerAvgBlkRewardL :: Lens_' EpochInfoInner (Maybe Text)
epochInfoInnerAvgBlkRewardL f EpochInfoInner{..} = (\epochInfoInnerAvgBlkReward -> EpochInfoInner { epochInfoInnerAvgBlkReward, ..} ) <$> f epochInfoInnerAvgBlkReward
{-# INLINE epochInfoInnerAvgBlkRewardL #-}



-- * EpochParamsInner

-- | 'epochParamsInnerEpochNo' Lens
epochParamsInnerEpochNoL :: Lens_' EpochParamsInner (Maybe Int)
epochParamsInnerEpochNoL f EpochParamsInner{..} = (\epochParamsInnerEpochNo -> EpochParamsInner { epochParamsInnerEpochNo, ..} ) <$> f epochParamsInnerEpochNo
{-# INLINE epochParamsInnerEpochNoL #-}

-- | 'epochParamsInnerMinFeeA' Lens
epochParamsInnerMinFeeAL :: Lens_' EpochParamsInner (Maybe Int)
epochParamsInnerMinFeeAL f EpochParamsInner{..} = (\epochParamsInnerMinFeeA -> EpochParamsInner { epochParamsInnerMinFeeA, ..} ) <$> f epochParamsInnerMinFeeA
{-# INLINE epochParamsInnerMinFeeAL #-}

-- | 'epochParamsInnerMinFeeB' Lens
epochParamsInnerMinFeeBL :: Lens_' EpochParamsInner (Maybe Int)
epochParamsInnerMinFeeBL f EpochParamsInner{..} = (\epochParamsInnerMinFeeB -> EpochParamsInner { epochParamsInnerMinFeeB, ..} ) <$> f epochParamsInnerMinFeeB
{-# INLINE epochParamsInnerMinFeeBL #-}

-- | 'epochParamsInnerMaxBlockSize' Lens
epochParamsInnerMaxBlockSizeL :: Lens_' EpochParamsInner (Maybe Int)
epochParamsInnerMaxBlockSizeL f EpochParamsInner{..} = (\epochParamsInnerMaxBlockSize -> EpochParamsInner { epochParamsInnerMaxBlockSize, ..} ) <$> f epochParamsInnerMaxBlockSize
{-# INLINE epochParamsInnerMaxBlockSizeL #-}

-- | 'epochParamsInnerMaxTxSize' Lens
epochParamsInnerMaxTxSizeL :: Lens_' EpochParamsInner (Maybe Int)
epochParamsInnerMaxTxSizeL f EpochParamsInner{..} = (\epochParamsInnerMaxTxSize -> EpochParamsInner { epochParamsInnerMaxTxSize, ..} ) <$> f epochParamsInnerMaxTxSize
{-# INLINE epochParamsInnerMaxTxSizeL #-}

-- | 'epochParamsInnerMaxBhSize' Lens
epochParamsInnerMaxBhSizeL :: Lens_' EpochParamsInner (Maybe Int)
epochParamsInnerMaxBhSizeL f EpochParamsInner{..} = (\epochParamsInnerMaxBhSize -> EpochParamsInner { epochParamsInnerMaxBhSize, ..} ) <$> f epochParamsInnerMaxBhSize
{-# INLINE epochParamsInnerMaxBhSizeL #-}

-- | 'epochParamsInnerKeyDeposit' Lens
epochParamsInnerKeyDepositL :: Lens_' EpochParamsInner (Maybe Text)
epochParamsInnerKeyDepositL f EpochParamsInner{..} = (\epochParamsInnerKeyDeposit -> EpochParamsInner { epochParamsInnerKeyDeposit, ..} ) <$> f epochParamsInnerKeyDeposit
{-# INLINE epochParamsInnerKeyDepositL #-}

-- | 'epochParamsInnerPoolDeposit' Lens
epochParamsInnerPoolDepositL :: Lens_' EpochParamsInner (Maybe Text)
epochParamsInnerPoolDepositL f EpochParamsInner{..} = (\epochParamsInnerPoolDeposit -> EpochParamsInner { epochParamsInnerPoolDeposit, ..} ) <$> f epochParamsInnerPoolDeposit
{-# INLINE epochParamsInnerPoolDepositL #-}

-- | 'epochParamsInnerMaxEpoch' Lens
epochParamsInnerMaxEpochL :: Lens_' EpochParamsInner (Maybe Int)
epochParamsInnerMaxEpochL f EpochParamsInner{..} = (\epochParamsInnerMaxEpoch -> EpochParamsInner { epochParamsInnerMaxEpoch, ..} ) <$> f epochParamsInnerMaxEpoch
{-# INLINE epochParamsInnerMaxEpochL #-}

-- | 'epochParamsInnerOptimalPoolCount' Lens
epochParamsInnerOptimalPoolCountL :: Lens_' EpochParamsInner (Maybe Int)
epochParamsInnerOptimalPoolCountL f EpochParamsInner{..} = (\epochParamsInnerOptimalPoolCount -> EpochParamsInner { epochParamsInnerOptimalPoolCount, ..} ) <$> f epochParamsInnerOptimalPoolCount
{-# INLINE epochParamsInnerOptimalPoolCountL #-}

-- | 'epochParamsInnerInfluence' Lens
epochParamsInnerInfluenceL :: Lens_' EpochParamsInner (Maybe Double)
epochParamsInnerInfluenceL f EpochParamsInner{..} = (\epochParamsInnerInfluence -> EpochParamsInner { epochParamsInnerInfluence, ..} ) <$> f epochParamsInnerInfluence
{-# INLINE epochParamsInnerInfluenceL #-}

-- | 'epochParamsInnerMonetaryExpandRate' Lens
epochParamsInnerMonetaryExpandRateL :: Lens_' EpochParamsInner (Maybe Double)
epochParamsInnerMonetaryExpandRateL f EpochParamsInner{..} = (\epochParamsInnerMonetaryExpandRate -> EpochParamsInner { epochParamsInnerMonetaryExpandRate, ..} ) <$> f epochParamsInnerMonetaryExpandRate
{-# INLINE epochParamsInnerMonetaryExpandRateL #-}

-- | 'epochParamsInnerTreasuryGrowthRate' Lens
epochParamsInnerTreasuryGrowthRateL :: Lens_' EpochParamsInner (Maybe Double)
epochParamsInnerTreasuryGrowthRateL f EpochParamsInner{..} = (\epochParamsInnerTreasuryGrowthRate -> EpochParamsInner { epochParamsInnerTreasuryGrowthRate, ..} ) <$> f epochParamsInnerTreasuryGrowthRate
{-# INLINE epochParamsInnerTreasuryGrowthRateL #-}

-- | 'epochParamsInnerDecentralisation' Lens
epochParamsInnerDecentralisationL :: Lens_' EpochParamsInner (Maybe Double)
epochParamsInnerDecentralisationL f EpochParamsInner{..} = (\epochParamsInnerDecentralisation -> EpochParamsInner { epochParamsInnerDecentralisation, ..} ) <$> f epochParamsInnerDecentralisation
{-# INLINE epochParamsInnerDecentralisationL #-}

-- | 'epochParamsInnerExtraEntropy' Lens
epochParamsInnerExtraEntropyL :: Lens_' EpochParamsInner (Maybe Text)
epochParamsInnerExtraEntropyL f EpochParamsInner{..} = (\epochParamsInnerExtraEntropy -> EpochParamsInner { epochParamsInnerExtraEntropy, ..} ) <$> f epochParamsInnerExtraEntropy
{-# INLINE epochParamsInnerExtraEntropyL #-}

-- | 'epochParamsInnerProtocolMajor' Lens
epochParamsInnerProtocolMajorL :: Lens_' EpochParamsInner (Maybe Int)
epochParamsInnerProtocolMajorL f EpochParamsInner{..} = (\epochParamsInnerProtocolMajor -> EpochParamsInner { epochParamsInnerProtocolMajor, ..} ) <$> f epochParamsInnerProtocolMajor
{-# INLINE epochParamsInnerProtocolMajorL #-}

-- | 'epochParamsInnerProtocolMinor' Lens
epochParamsInnerProtocolMinorL :: Lens_' EpochParamsInner (Maybe Int)
epochParamsInnerProtocolMinorL f EpochParamsInner{..} = (\epochParamsInnerProtocolMinor -> EpochParamsInner { epochParamsInnerProtocolMinor, ..} ) <$> f epochParamsInnerProtocolMinor
{-# INLINE epochParamsInnerProtocolMinorL #-}

-- | 'epochParamsInnerMinUtxoValue' Lens
epochParamsInnerMinUtxoValueL :: Lens_' EpochParamsInner (Maybe Text)
epochParamsInnerMinUtxoValueL f EpochParamsInner{..} = (\epochParamsInnerMinUtxoValue -> EpochParamsInner { epochParamsInnerMinUtxoValue, ..} ) <$> f epochParamsInnerMinUtxoValue
{-# INLINE epochParamsInnerMinUtxoValueL #-}

-- | 'epochParamsInnerMinPoolCost' Lens
epochParamsInnerMinPoolCostL :: Lens_' EpochParamsInner (Maybe Text)
epochParamsInnerMinPoolCostL f EpochParamsInner{..} = (\epochParamsInnerMinPoolCost -> EpochParamsInner { epochParamsInnerMinPoolCost, ..} ) <$> f epochParamsInnerMinPoolCost
{-# INLINE epochParamsInnerMinPoolCostL #-}

-- | 'epochParamsInnerNonce' Lens
epochParamsInnerNonceL :: Lens_' EpochParamsInner (Maybe Text)
epochParamsInnerNonceL f EpochParamsInner{..} = (\epochParamsInnerNonce -> EpochParamsInner { epochParamsInnerNonce, ..} ) <$> f epochParamsInnerNonce
{-# INLINE epochParamsInnerNonceL #-}

-- | 'epochParamsInnerBlockHash' Lens
epochParamsInnerBlockHashL :: Lens_' EpochParamsInner (Maybe Text)
epochParamsInnerBlockHashL f EpochParamsInner{..} = (\epochParamsInnerBlockHash -> EpochParamsInner { epochParamsInnerBlockHash, ..} ) <$> f epochParamsInnerBlockHash
{-# INLINE epochParamsInnerBlockHashL #-}

-- | 'epochParamsInnerCostModels' Lens
epochParamsInnerCostModelsL :: Lens_' EpochParamsInner (Maybe Text)
epochParamsInnerCostModelsL f EpochParamsInner{..} = (\epochParamsInnerCostModels -> EpochParamsInner { epochParamsInnerCostModels, ..} ) <$> f epochParamsInnerCostModels
{-# INLINE epochParamsInnerCostModelsL #-}

-- | 'epochParamsInnerPriceMem' Lens
epochParamsInnerPriceMemL :: Lens_' EpochParamsInner (Maybe Double)
epochParamsInnerPriceMemL f EpochParamsInner{..} = (\epochParamsInnerPriceMem -> EpochParamsInner { epochParamsInnerPriceMem, ..} ) <$> f epochParamsInnerPriceMem
{-# INLINE epochParamsInnerPriceMemL #-}

-- | 'epochParamsInnerPriceStep' Lens
epochParamsInnerPriceStepL :: Lens_' EpochParamsInner (Maybe Double)
epochParamsInnerPriceStepL f EpochParamsInner{..} = (\epochParamsInnerPriceStep -> EpochParamsInner { epochParamsInnerPriceStep, ..} ) <$> f epochParamsInnerPriceStep
{-# INLINE epochParamsInnerPriceStepL #-}

-- | 'epochParamsInnerMaxTxExMem' Lens
epochParamsInnerMaxTxExMemL :: Lens_' EpochParamsInner (Maybe Double)
epochParamsInnerMaxTxExMemL f EpochParamsInner{..} = (\epochParamsInnerMaxTxExMem -> EpochParamsInner { epochParamsInnerMaxTxExMem, ..} ) <$> f epochParamsInnerMaxTxExMem
{-# INLINE epochParamsInnerMaxTxExMemL #-}

-- | 'epochParamsInnerMaxTxExSteps' Lens
epochParamsInnerMaxTxExStepsL :: Lens_' EpochParamsInner (Maybe Double)
epochParamsInnerMaxTxExStepsL f EpochParamsInner{..} = (\epochParamsInnerMaxTxExSteps -> EpochParamsInner { epochParamsInnerMaxTxExSteps, ..} ) <$> f epochParamsInnerMaxTxExSteps
{-# INLINE epochParamsInnerMaxTxExStepsL #-}

-- | 'epochParamsInnerMaxBlockExMem' Lens
epochParamsInnerMaxBlockExMemL :: Lens_' EpochParamsInner (Maybe Double)
epochParamsInnerMaxBlockExMemL f EpochParamsInner{..} = (\epochParamsInnerMaxBlockExMem -> EpochParamsInner { epochParamsInnerMaxBlockExMem, ..} ) <$> f epochParamsInnerMaxBlockExMem
{-# INLINE epochParamsInnerMaxBlockExMemL #-}

-- | 'epochParamsInnerMaxBlockExSteps' Lens
epochParamsInnerMaxBlockExStepsL :: Lens_' EpochParamsInner (Maybe Double)
epochParamsInnerMaxBlockExStepsL f EpochParamsInner{..} = (\epochParamsInnerMaxBlockExSteps -> EpochParamsInner { epochParamsInnerMaxBlockExSteps, ..} ) <$> f epochParamsInnerMaxBlockExSteps
{-# INLINE epochParamsInnerMaxBlockExStepsL #-}

-- | 'epochParamsInnerMaxValSize' Lens
epochParamsInnerMaxValSizeL :: Lens_' EpochParamsInner (Maybe Double)
epochParamsInnerMaxValSizeL f EpochParamsInner{..} = (\epochParamsInnerMaxValSize -> EpochParamsInner { epochParamsInnerMaxValSize, ..} ) <$> f epochParamsInnerMaxValSize
{-# INLINE epochParamsInnerMaxValSizeL #-}

-- | 'epochParamsInnerCollateralPercent' Lens
epochParamsInnerCollateralPercentL :: Lens_' EpochParamsInner (Maybe Int)
epochParamsInnerCollateralPercentL f EpochParamsInner{..} = (\epochParamsInnerCollateralPercent -> EpochParamsInner { epochParamsInnerCollateralPercent, ..} ) <$> f epochParamsInnerCollateralPercent
{-# INLINE epochParamsInnerCollateralPercentL #-}

-- | 'epochParamsInnerMaxCollateralInputs' Lens
epochParamsInnerMaxCollateralInputsL :: Lens_' EpochParamsInner (Maybe Int)
epochParamsInnerMaxCollateralInputsL f EpochParamsInner{..} = (\epochParamsInnerMaxCollateralInputs -> EpochParamsInner { epochParamsInnerMaxCollateralInputs, ..} ) <$> f epochParamsInnerMaxCollateralInputs
{-# INLINE epochParamsInnerMaxCollateralInputsL #-}

-- | 'epochParamsInnerCoinsPerUtxoSize' Lens
epochParamsInnerCoinsPerUtxoSizeL :: Lens_' EpochParamsInner (Maybe Text)
epochParamsInnerCoinsPerUtxoSizeL f EpochParamsInner{..} = (\epochParamsInnerCoinsPerUtxoSize -> EpochParamsInner { epochParamsInnerCoinsPerUtxoSize, ..} ) <$> f epochParamsInnerCoinsPerUtxoSize
{-# INLINE epochParamsInnerCoinsPerUtxoSizeL #-}



-- * GenesisInner

-- | 'genesisInnerNetworkmagic' Lens
genesisInnerNetworkmagicL :: Lens_' GenesisInner (Maybe Text)
genesisInnerNetworkmagicL f GenesisInner{..} = (\genesisInnerNetworkmagic -> GenesisInner { genesisInnerNetworkmagic, ..} ) <$> f genesisInnerNetworkmagic
{-# INLINE genesisInnerNetworkmagicL #-}

-- | 'genesisInnerNetworkid' Lens
genesisInnerNetworkidL :: Lens_' GenesisInner (Maybe Text)
genesisInnerNetworkidL f GenesisInner{..} = (\genesisInnerNetworkid -> GenesisInner { genesisInnerNetworkid, ..} ) <$> f genesisInnerNetworkid
{-# INLINE genesisInnerNetworkidL #-}

-- | 'genesisInnerEpochlength' Lens
genesisInnerEpochlengthL :: Lens_' GenesisInner (Maybe Text)
genesisInnerEpochlengthL f GenesisInner{..} = (\genesisInnerEpochlength -> GenesisInner { genesisInnerEpochlength, ..} ) <$> f genesisInnerEpochlength
{-# INLINE genesisInnerEpochlengthL #-}

-- | 'genesisInnerSlotlength' Lens
genesisInnerSlotlengthL :: Lens_' GenesisInner (Maybe Text)
genesisInnerSlotlengthL f GenesisInner{..} = (\genesisInnerSlotlength -> GenesisInner { genesisInnerSlotlength, ..} ) <$> f genesisInnerSlotlength
{-# INLINE genesisInnerSlotlengthL #-}

-- | 'genesisInnerMaxlovelacesupply' Lens
genesisInnerMaxlovelacesupplyL :: Lens_' GenesisInner (Maybe Text)
genesisInnerMaxlovelacesupplyL f GenesisInner{..} = (\genesisInnerMaxlovelacesupply -> GenesisInner { genesisInnerMaxlovelacesupply, ..} ) <$> f genesisInnerMaxlovelacesupply
{-# INLINE genesisInnerMaxlovelacesupplyL #-}

-- | 'genesisInnerSystemstart' Lens
genesisInnerSystemstartL :: Lens_' GenesisInner (Maybe Int)
genesisInnerSystemstartL f GenesisInner{..} = (\genesisInnerSystemstart -> GenesisInner { genesisInnerSystemstart, ..} ) <$> f genesisInnerSystemstart
{-# INLINE genesisInnerSystemstartL #-}

-- | 'genesisInnerActiveslotcoeff' Lens
genesisInnerActiveslotcoeffL :: Lens_' GenesisInner (Maybe Text)
genesisInnerActiveslotcoeffL f GenesisInner{..} = (\genesisInnerActiveslotcoeff -> GenesisInner { genesisInnerActiveslotcoeff, ..} ) <$> f genesisInnerActiveslotcoeff
{-# INLINE genesisInnerActiveslotcoeffL #-}

-- | 'genesisInnerSlotsperkesperiod' Lens
genesisInnerSlotsperkesperiodL :: Lens_' GenesisInner (Maybe Text)
genesisInnerSlotsperkesperiodL f GenesisInner{..} = (\genesisInnerSlotsperkesperiod -> GenesisInner { genesisInnerSlotsperkesperiod, ..} ) <$> f genesisInnerSlotsperkesperiod
{-# INLINE genesisInnerSlotsperkesperiodL #-}

-- | 'genesisInnerMaxkesrevolutions' Lens
genesisInnerMaxkesrevolutionsL :: Lens_' GenesisInner (Maybe Text)
genesisInnerMaxkesrevolutionsL f GenesisInner{..} = (\genesisInnerMaxkesrevolutions -> GenesisInner { genesisInnerMaxkesrevolutions, ..} ) <$> f genesisInnerMaxkesrevolutions
{-# INLINE genesisInnerMaxkesrevolutionsL #-}

-- | 'genesisInnerSecurityparam' Lens
genesisInnerSecurityparamL :: Lens_' GenesisInner (Maybe Text)
genesisInnerSecurityparamL f GenesisInner{..} = (\genesisInnerSecurityparam -> GenesisInner { genesisInnerSecurityparam, ..} ) <$> f genesisInnerSecurityparam
{-# INLINE genesisInnerSecurityparamL #-}

-- | 'genesisInnerUpdatequorum' Lens
genesisInnerUpdatequorumL :: Lens_' GenesisInner (Maybe Text)
genesisInnerUpdatequorumL f GenesisInner{..} = (\genesisInnerUpdatequorum -> GenesisInner { genesisInnerUpdatequorum, ..} ) <$> f genesisInnerUpdatequorum
{-# INLINE genesisInnerUpdatequorumL #-}

-- | 'genesisInnerAlonzogenesis' Lens
genesisInnerAlonzogenesisL :: Lens_' GenesisInner (Maybe Text)
genesisInnerAlonzogenesisL f GenesisInner{..} = (\genesisInnerAlonzogenesis -> GenesisInner { genesisInnerAlonzogenesis, ..} ) <$> f genesisInnerAlonzogenesis
{-# INLINE genesisInnerAlonzogenesisL #-}



-- * NativeScriptListInner

-- | 'nativeScriptListInnerScriptHash' Lens
nativeScriptListInnerScriptHashL :: Lens_' NativeScriptListInner (Maybe ScriptHash)
nativeScriptListInnerScriptHashL f NativeScriptListInner{..} = (\nativeScriptListInnerScriptHash -> NativeScriptListInner { nativeScriptListInnerScriptHash, ..} ) <$> f nativeScriptListInnerScriptHash
{-# INLINE nativeScriptListInnerScriptHashL #-}

-- | 'nativeScriptListInnerCreationTxHash' Lens
nativeScriptListInnerCreationTxHashL :: Lens_' NativeScriptListInner (Maybe CreationTxHash)
nativeScriptListInnerCreationTxHashL f NativeScriptListInner{..} = (\nativeScriptListInnerCreationTxHash -> NativeScriptListInner { nativeScriptListInnerCreationTxHash, ..} ) <$> f nativeScriptListInnerCreationTxHash
{-# INLINE nativeScriptListInnerCreationTxHashL #-}

-- | 'nativeScriptListInnerType' Lens
nativeScriptListInnerTypeL :: Lens_' NativeScriptListInner (Maybe E'Type2)
nativeScriptListInnerTypeL f NativeScriptListInner{..} = (\nativeScriptListInnerType -> NativeScriptListInner { nativeScriptListInnerType, ..} ) <$> f nativeScriptListInnerType
{-# INLINE nativeScriptListInnerTypeL #-}



-- * PlutusScriptListInner

-- | 'plutusScriptListInnerScriptHash' Lens
plutusScriptListInnerScriptHashL :: Lens_' PlutusScriptListInner (Maybe Text)
plutusScriptListInnerScriptHashL f PlutusScriptListInner{..} = (\plutusScriptListInnerScriptHash -> PlutusScriptListInner { plutusScriptListInnerScriptHash, ..} ) <$> f plutusScriptListInnerScriptHash
{-# INLINE plutusScriptListInnerScriptHashL #-}

-- | 'plutusScriptListInnerCreationTxHash' Lens
plutusScriptListInnerCreationTxHashL :: Lens_' PlutusScriptListInner (Maybe Text)
plutusScriptListInnerCreationTxHashL f PlutusScriptListInner{..} = (\plutusScriptListInnerCreationTxHash -> PlutusScriptListInner { plutusScriptListInnerCreationTxHash, ..} ) <$> f plutusScriptListInnerCreationTxHash
{-# INLINE plutusScriptListInnerCreationTxHashL #-}



-- * PoolBlocksInner

-- | 'poolBlocksInnerEpochNo' Lens
poolBlocksInnerEpochNoL :: Lens_' PoolBlocksInner (Maybe EpochNo)
poolBlocksInnerEpochNoL f PoolBlocksInner{..} = (\poolBlocksInnerEpochNo -> PoolBlocksInner { poolBlocksInnerEpochNo, ..} ) <$> f poolBlocksInnerEpochNo
{-# INLINE poolBlocksInnerEpochNoL #-}

-- | 'poolBlocksInnerEpochSlot' Lens
poolBlocksInnerEpochSlotL :: Lens_' PoolBlocksInner (Maybe EpochSlot)
poolBlocksInnerEpochSlotL f PoolBlocksInner{..} = (\poolBlocksInnerEpochSlot -> PoolBlocksInner { poolBlocksInnerEpochSlot, ..} ) <$> f poolBlocksInnerEpochSlot
{-# INLINE poolBlocksInnerEpochSlotL #-}

-- | 'poolBlocksInnerAbsSlot' Lens
poolBlocksInnerAbsSlotL :: Lens_' PoolBlocksInner (Maybe AbsSlot)
poolBlocksInnerAbsSlotL f PoolBlocksInner{..} = (\poolBlocksInnerAbsSlot -> PoolBlocksInner { poolBlocksInnerAbsSlot, ..} ) <$> f poolBlocksInnerAbsSlot
{-# INLINE poolBlocksInnerAbsSlotL #-}

-- | 'poolBlocksInnerBlockHeight' Lens
poolBlocksInnerBlockHeightL :: Lens_' PoolBlocksInner (Maybe BlockHeight)
poolBlocksInnerBlockHeightL f PoolBlocksInner{..} = (\poolBlocksInnerBlockHeight -> PoolBlocksInner { poolBlocksInnerBlockHeight, ..} ) <$> f poolBlocksInnerBlockHeight
{-# INLINE poolBlocksInnerBlockHeightL #-}

-- | 'poolBlocksInnerBlockHash' Lens
poolBlocksInnerBlockHashL :: Lens_' PoolBlocksInner (Maybe Hash)
poolBlocksInnerBlockHashL f PoolBlocksInner{..} = (\poolBlocksInnerBlockHash -> PoolBlocksInner { poolBlocksInnerBlockHash, ..} ) <$> f poolBlocksInnerBlockHash
{-# INLINE poolBlocksInnerBlockHashL #-}

-- | 'poolBlocksInnerBlockTime' Lens
poolBlocksInnerBlockTimeL :: Lens_' PoolBlocksInner (Maybe BlockTime)
poolBlocksInnerBlockTimeL f PoolBlocksInner{..} = (\poolBlocksInnerBlockTime -> PoolBlocksInner { poolBlocksInnerBlockTime, ..} ) <$> f poolBlocksInnerBlockTime
{-# INLINE poolBlocksInnerBlockTimeL #-}



-- * PoolDelegatorsInner

-- | 'poolDelegatorsInnerStakeAddress' Lens
poolDelegatorsInnerStakeAddressL :: Lens_' PoolDelegatorsInner (Maybe StakeAddress)
poolDelegatorsInnerStakeAddressL f PoolDelegatorsInner{..} = (\poolDelegatorsInnerStakeAddress -> PoolDelegatorsInner { poolDelegatorsInnerStakeAddress, ..} ) <$> f poolDelegatorsInnerStakeAddress
{-# INLINE poolDelegatorsInnerStakeAddressL #-}

-- | 'poolDelegatorsInnerAmount' Lens
poolDelegatorsInnerAmountL :: Lens_' PoolDelegatorsInner (Maybe Text)
poolDelegatorsInnerAmountL f PoolDelegatorsInner{..} = (\poolDelegatorsInnerAmount -> PoolDelegatorsInner { poolDelegatorsInnerAmount, ..} ) <$> f poolDelegatorsInnerAmount
{-# INLINE poolDelegatorsInnerAmountL #-}

-- | 'poolDelegatorsInnerActiveEpochNo' Lens
poolDelegatorsInnerActiveEpochNoL :: Lens_' PoolDelegatorsInner (Maybe Int)
poolDelegatorsInnerActiveEpochNoL f PoolDelegatorsInner{..} = (\poolDelegatorsInnerActiveEpochNo -> PoolDelegatorsInner { poolDelegatorsInnerActiveEpochNo, ..} ) <$> f poolDelegatorsInnerActiveEpochNo
{-# INLINE poolDelegatorsInnerActiveEpochNoL #-}



-- * PoolHistoryInfoInner

-- | 'poolHistoryInfoInnerEpochNo' Lens
poolHistoryInfoInnerEpochNoL :: Lens_' PoolHistoryInfoInner (Maybe Int)
poolHistoryInfoInnerEpochNoL f PoolHistoryInfoInner{..} = (\poolHistoryInfoInnerEpochNo -> PoolHistoryInfoInner { poolHistoryInfoInnerEpochNo, ..} ) <$> f poolHistoryInfoInnerEpochNo
{-# INLINE poolHistoryInfoInnerEpochNoL #-}

-- | 'poolHistoryInfoInnerActiveStake' Lens
poolHistoryInfoInnerActiveStakeL :: Lens_' PoolHistoryInfoInner (Maybe Text)
poolHistoryInfoInnerActiveStakeL f PoolHistoryInfoInner{..} = (\poolHistoryInfoInnerActiveStake -> PoolHistoryInfoInner { poolHistoryInfoInnerActiveStake, ..} ) <$> f poolHistoryInfoInnerActiveStake
{-# INLINE poolHistoryInfoInnerActiveStakeL #-}

-- | 'poolHistoryInfoInnerActiveStakePct' Lens
poolHistoryInfoInnerActiveStakePctL :: Lens_' PoolHistoryInfoInner (Maybe Double)
poolHistoryInfoInnerActiveStakePctL f PoolHistoryInfoInner{..} = (\poolHistoryInfoInnerActiveStakePct -> PoolHistoryInfoInner { poolHistoryInfoInnerActiveStakePct, ..} ) <$> f poolHistoryInfoInnerActiveStakePct
{-# INLINE poolHistoryInfoInnerActiveStakePctL #-}

-- | 'poolHistoryInfoInnerSaturationPct' Lens
poolHistoryInfoInnerSaturationPctL :: Lens_' PoolHistoryInfoInner (Maybe Double)
poolHistoryInfoInnerSaturationPctL f PoolHistoryInfoInner{..} = (\poolHistoryInfoInnerSaturationPct -> PoolHistoryInfoInner { poolHistoryInfoInnerSaturationPct, ..} ) <$> f poolHistoryInfoInnerSaturationPct
{-# INLINE poolHistoryInfoInnerSaturationPctL #-}

-- | 'poolHistoryInfoInnerBlockCnt' Lens
poolHistoryInfoInnerBlockCntL :: Lens_' PoolHistoryInfoInner (Maybe Int)
poolHistoryInfoInnerBlockCntL f PoolHistoryInfoInner{..} = (\poolHistoryInfoInnerBlockCnt -> PoolHistoryInfoInner { poolHistoryInfoInnerBlockCnt, ..} ) <$> f poolHistoryInfoInnerBlockCnt
{-# INLINE poolHistoryInfoInnerBlockCntL #-}

-- | 'poolHistoryInfoInnerDelegatorCnt' Lens
poolHistoryInfoInnerDelegatorCntL :: Lens_' PoolHistoryInfoInner (Maybe Int)
poolHistoryInfoInnerDelegatorCntL f PoolHistoryInfoInner{..} = (\poolHistoryInfoInnerDelegatorCnt -> PoolHistoryInfoInner { poolHistoryInfoInnerDelegatorCnt, ..} ) <$> f poolHistoryInfoInnerDelegatorCnt
{-# INLINE poolHistoryInfoInnerDelegatorCntL #-}

-- | 'poolHistoryInfoInnerMargin' Lens
poolHistoryInfoInnerMarginL :: Lens_' PoolHistoryInfoInner (Maybe Double)
poolHistoryInfoInnerMarginL f PoolHistoryInfoInner{..} = (\poolHistoryInfoInnerMargin -> PoolHistoryInfoInner { poolHistoryInfoInnerMargin, ..} ) <$> f poolHistoryInfoInnerMargin
{-# INLINE poolHistoryInfoInnerMarginL #-}

-- | 'poolHistoryInfoInnerFixedCost' Lens
poolHistoryInfoInnerFixedCostL :: Lens_' PoolHistoryInfoInner (Maybe Text)
poolHistoryInfoInnerFixedCostL f PoolHistoryInfoInner{..} = (\poolHistoryInfoInnerFixedCost -> PoolHistoryInfoInner { poolHistoryInfoInnerFixedCost, ..} ) <$> f poolHistoryInfoInnerFixedCost
{-# INLINE poolHistoryInfoInnerFixedCostL #-}

-- | 'poolHistoryInfoInnerPoolFees' Lens
poolHistoryInfoInnerPoolFeesL :: Lens_' PoolHistoryInfoInner (Maybe Text)
poolHistoryInfoInnerPoolFeesL f PoolHistoryInfoInner{..} = (\poolHistoryInfoInnerPoolFees -> PoolHistoryInfoInner { poolHistoryInfoInnerPoolFees, ..} ) <$> f poolHistoryInfoInnerPoolFees
{-# INLINE poolHistoryInfoInnerPoolFeesL #-}

-- | 'poolHistoryInfoInnerDelegRewards' Lens
poolHistoryInfoInnerDelegRewardsL :: Lens_' PoolHistoryInfoInner (Maybe Text)
poolHistoryInfoInnerDelegRewardsL f PoolHistoryInfoInner{..} = (\poolHistoryInfoInnerDelegRewards -> PoolHistoryInfoInner { poolHistoryInfoInnerDelegRewards, ..} ) <$> f poolHistoryInfoInnerDelegRewards
{-# INLINE poolHistoryInfoInnerDelegRewardsL #-}

-- | 'poolHistoryInfoInnerEpochRos' Lens
poolHistoryInfoInnerEpochRosL :: Lens_' PoolHistoryInfoInner (Maybe Double)
poolHistoryInfoInnerEpochRosL f PoolHistoryInfoInner{..} = (\poolHistoryInfoInnerEpochRos -> PoolHistoryInfoInner { poolHistoryInfoInnerEpochRos, ..} ) <$> f poolHistoryInfoInnerEpochRos
{-# INLINE poolHistoryInfoInnerEpochRosL #-}



-- * PoolInfoInner

-- | 'poolInfoInnerPoolIdBech32' Lens
poolInfoInnerPoolIdBech32L :: Lens_' PoolInfoInner (Maybe Text)
poolInfoInnerPoolIdBech32L f PoolInfoInner{..} = (\poolInfoInnerPoolIdBech32 -> PoolInfoInner { poolInfoInnerPoolIdBech32, ..} ) <$> f poolInfoInnerPoolIdBech32
{-# INLINE poolInfoInnerPoolIdBech32L #-}

-- | 'poolInfoInnerPoolIdHex' Lens
poolInfoInnerPoolIdHexL :: Lens_' PoolInfoInner (Maybe Text)
poolInfoInnerPoolIdHexL f PoolInfoInner{..} = (\poolInfoInnerPoolIdHex -> PoolInfoInner { poolInfoInnerPoolIdHex, ..} ) <$> f poolInfoInnerPoolIdHex
{-# INLINE poolInfoInnerPoolIdHexL #-}

-- | 'poolInfoInnerActiveEpochNo' Lens
poolInfoInnerActiveEpochNoL :: Lens_' PoolInfoInner (Maybe ActiveEpochNo)
poolInfoInnerActiveEpochNoL f PoolInfoInner{..} = (\poolInfoInnerActiveEpochNo -> PoolInfoInner { poolInfoInnerActiveEpochNo, ..} ) <$> f poolInfoInnerActiveEpochNo
{-# INLINE poolInfoInnerActiveEpochNoL #-}

-- | 'poolInfoInnerVrfKeyHash' Lens
poolInfoInnerVrfKeyHashL :: Lens_' PoolInfoInner (Maybe Text)
poolInfoInnerVrfKeyHashL f PoolInfoInner{..} = (\poolInfoInnerVrfKeyHash -> PoolInfoInner { poolInfoInnerVrfKeyHash, ..} ) <$> f poolInfoInnerVrfKeyHash
{-# INLINE poolInfoInnerVrfKeyHashL #-}

-- | 'poolInfoInnerMargin' Lens
poolInfoInnerMarginL :: Lens_' PoolInfoInner (Maybe Double)
poolInfoInnerMarginL f PoolInfoInner{..} = (\poolInfoInnerMargin -> PoolInfoInner { poolInfoInnerMargin, ..} ) <$> f poolInfoInnerMargin
{-# INLINE poolInfoInnerMarginL #-}

-- | 'poolInfoInnerFixedCost' Lens
poolInfoInnerFixedCostL :: Lens_' PoolInfoInner (Maybe Text)
poolInfoInnerFixedCostL f PoolInfoInner{..} = (\poolInfoInnerFixedCost -> PoolInfoInner { poolInfoInnerFixedCost, ..} ) <$> f poolInfoInnerFixedCost
{-# INLINE poolInfoInnerFixedCostL #-}

-- | 'poolInfoInnerPledge' Lens
poolInfoInnerPledgeL :: Lens_' PoolInfoInner (Maybe Text)
poolInfoInnerPledgeL f PoolInfoInner{..} = (\poolInfoInnerPledge -> PoolInfoInner { poolInfoInnerPledge, ..} ) <$> f poolInfoInnerPledge
{-# INLINE poolInfoInnerPledgeL #-}

-- | 'poolInfoInnerRewardAddr' Lens
poolInfoInnerRewardAddrL :: Lens_' PoolInfoInner (Maybe Text)
poolInfoInnerRewardAddrL f PoolInfoInner{..} = (\poolInfoInnerRewardAddr -> PoolInfoInner { poolInfoInnerRewardAddr, ..} ) <$> f poolInfoInnerRewardAddr
{-# INLINE poolInfoInnerRewardAddrL #-}

-- | 'poolInfoInnerOwners' Lens
poolInfoInnerOwnersL :: Lens_' PoolInfoInner (Maybe [Text])
poolInfoInnerOwnersL f PoolInfoInner{..} = (\poolInfoInnerOwners -> PoolInfoInner { poolInfoInnerOwners, ..} ) <$> f poolInfoInnerOwners
{-# INLINE poolInfoInnerOwnersL #-}

-- | 'poolInfoInnerRelays' Lens
poolInfoInnerRelaysL :: Lens_' PoolInfoInner (Maybe [PoolInfoInnerRelaysInner])
poolInfoInnerRelaysL f PoolInfoInner{..} = (\poolInfoInnerRelays -> PoolInfoInner { poolInfoInnerRelays, ..} ) <$> f poolInfoInnerRelays
{-# INLINE poolInfoInnerRelaysL #-}

-- | 'poolInfoInnerMetaUrl' Lens
poolInfoInnerMetaUrlL :: Lens_' PoolInfoInner (Maybe Text)
poolInfoInnerMetaUrlL f PoolInfoInner{..} = (\poolInfoInnerMetaUrl -> PoolInfoInner { poolInfoInnerMetaUrl, ..} ) <$> f poolInfoInnerMetaUrl
{-# INLINE poolInfoInnerMetaUrlL #-}

-- | 'poolInfoInnerMetaHash' Lens
poolInfoInnerMetaHashL :: Lens_' PoolInfoInner (Maybe Text)
poolInfoInnerMetaHashL f PoolInfoInner{..} = (\poolInfoInnerMetaHash -> PoolInfoInner { poolInfoInnerMetaHash, ..} ) <$> f poolInfoInnerMetaHash
{-# INLINE poolInfoInnerMetaHashL #-}

-- | 'poolInfoInnerMetaJson' Lens
poolInfoInnerMetaJsonL :: Lens_' PoolInfoInner (Maybe PoolInfoInnerMetaJson)
poolInfoInnerMetaJsonL f PoolInfoInner{..} = (\poolInfoInnerMetaJson -> PoolInfoInner { poolInfoInnerMetaJson, ..} ) <$> f poolInfoInnerMetaJson
{-# INLINE poolInfoInnerMetaJsonL #-}

-- | 'poolInfoInnerPoolStatus' Lens
poolInfoInnerPoolStatusL :: Lens_' PoolInfoInner (Maybe E'PoolStatus)
poolInfoInnerPoolStatusL f PoolInfoInner{..} = (\poolInfoInnerPoolStatus -> PoolInfoInner { poolInfoInnerPoolStatus, ..} ) <$> f poolInfoInnerPoolStatus
{-# INLINE poolInfoInnerPoolStatusL #-}

-- | 'poolInfoInnerRetiringEpoch' Lens
poolInfoInnerRetiringEpochL :: Lens_' PoolInfoInner (Maybe Int)
poolInfoInnerRetiringEpochL f PoolInfoInner{..} = (\poolInfoInnerRetiringEpoch -> PoolInfoInner { poolInfoInnerRetiringEpoch, ..} ) <$> f poolInfoInnerRetiringEpoch
{-# INLINE poolInfoInnerRetiringEpochL #-}

-- | 'poolInfoInnerOpCert' Lens
poolInfoInnerOpCertL :: Lens_' PoolInfoInner (Maybe Text)
poolInfoInnerOpCertL f PoolInfoInner{..} = (\poolInfoInnerOpCert -> PoolInfoInner { poolInfoInnerOpCert, ..} ) <$> f poolInfoInnerOpCert
{-# INLINE poolInfoInnerOpCertL #-}

-- | 'poolInfoInnerOpCertCounter' Lens
poolInfoInnerOpCertCounterL :: Lens_' PoolInfoInner (Maybe Int)
poolInfoInnerOpCertCounterL f PoolInfoInner{..} = (\poolInfoInnerOpCertCounter -> PoolInfoInner { poolInfoInnerOpCertCounter, ..} ) <$> f poolInfoInnerOpCertCounter
{-# INLINE poolInfoInnerOpCertCounterL #-}

-- | 'poolInfoInnerActiveStake' Lens
poolInfoInnerActiveStakeL :: Lens_' PoolInfoInner (Maybe Text)
poolInfoInnerActiveStakeL f PoolInfoInner{..} = (\poolInfoInnerActiveStake -> PoolInfoInner { poolInfoInnerActiveStake, ..} ) <$> f poolInfoInnerActiveStake
{-# INLINE poolInfoInnerActiveStakeL #-}

-- | 'poolInfoInnerSigma' Lens
poolInfoInnerSigmaL :: Lens_' PoolInfoInner (Maybe Double)
poolInfoInnerSigmaL f PoolInfoInner{..} = (\poolInfoInnerSigma -> PoolInfoInner { poolInfoInnerSigma, ..} ) <$> f poolInfoInnerSigma
{-# INLINE poolInfoInnerSigmaL #-}

-- | 'poolInfoInnerBlockCount' Lens
poolInfoInnerBlockCountL :: Lens_' PoolInfoInner (Maybe Int)
poolInfoInnerBlockCountL f PoolInfoInner{..} = (\poolInfoInnerBlockCount -> PoolInfoInner { poolInfoInnerBlockCount, ..} ) <$> f poolInfoInnerBlockCount
{-# INLINE poolInfoInnerBlockCountL #-}

-- | 'poolInfoInnerLivePledge' Lens
poolInfoInnerLivePledgeL :: Lens_' PoolInfoInner (Maybe Text)
poolInfoInnerLivePledgeL f PoolInfoInner{..} = (\poolInfoInnerLivePledge -> PoolInfoInner { poolInfoInnerLivePledge, ..} ) <$> f poolInfoInnerLivePledge
{-# INLINE poolInfoInnerLivePledgeL #-}

-- | 'poolInfoInnerLiveStake' Lens
poolInfoInnerLiveStakeL :: Lens_' PoolInfoInner (Maybe Text)
poolInfoInnerLiveStakeL f PoolInfoInner{..} = (\poolInfoInnerLiveStake -> PoolInfoInner { poolInfoInnerLiveStake, ..} ) <$> f poolInfoInnerLiveStake
{-# INLINE poolInfoInnerLiveStakeL #-}

-- | 'poolInfoInnerLiveDelegators' Lens
poolInfoInnerLiveDelegatorsL :: Lens_' PoolInfoInner (Maybe Int)
poolInfoInnerLiveDelegatorsL f PoolInfoInner{..} = (\poolInfoInnerLiveDelegators -> PoolInfoInner { poolInfoInnerLiveDelegators, ..} ) <$> f poolInfoInnerLiveDelegators
{-# INLINE poolInfoInnerLiveDelegatorsL #-}

-- | 'poolInfoInnerLiveSaturation' Lens
poolInfoInnerLiveSaturationL :: Lens_' PoolInfoInner (Maybe Double)
poolInfoInnerLiveSaturationL f PoolInfoInner{..} = (\poolInfoInnerLiveSaturation -> PoolInfoInner { poolInfoInnerLiveSaturation, ..} ) <$> f poolInfoInnerLiveSaturation
{-# INLINE poolInfoInnerLiveSaturationL #-}



-- * PoolInfoInnerMetaJson

-- | 'poolInfoInnerMetaJsonName' Lens
poolInfoInnerMetaJsonNameL :: Lens_' PoolInfoInnerMetaJson (Maybe Text)
poolInfoInnerMetaJsonNameL f PoolInfoInnerMetaJson{..} = (\poolInfoInnerMetaJsonName -> PoolInfoInnerMetaJson { poolInfoInnerMetaJsonName, ..} ) <$> f poolInfoInnerMetaJsonName
{-# INLINE poolInfoInnerMetaJsonNameL #-}

-- | 'poolInfoInnerMetaJsonTicker' Lens
poolInfoInnerMetaJsonTickerL :: Lens_' PoolInfoInnerMetaJson (Maybe Text)
poolInfoInnerMetaJsonTickerL f PoolInfoInnerMetaJson{..} = (\poolInfoInnerMetaJsonTicker -> PoolInfoInnerMetaJson { poolInfoInnerMetaJsonTicker, ..} ) <$> f poolInfoInnerMetaJsonTicker
{-# INLINE poolInfoInnerMetaJsonTickerL #-}

-- | 'poolInfoInnerMetaJsonHomepage' Lens
poolInfoInnerMetaJsonHomepageL :: Lens_' PoolInfoInnerMetaJson (Maybe Text)
poolInfoInnerMetaJsonHomepageL f PoolInfoInnerMetaJson{..} = (\poolInfoInnerMetaJsonHomepage -> PoolInfoInnerMetaJson { poolInfoInnerMetaJsonHomepage, ..} ) <$> f poolInfoInnerMetaJsonHomepage
{-# INLINE poolInfoInnerMetaJsonHomepageL #-}

-- | 'poolInfoInnerMetaJsonDescription' Lens
poolInfoInnerMetaJsonDescriptionL :: Lens_' PoolInfoInnerMetaJson (Maybe Text)
poolInfoInnerMetaJsonDescriptionL f PoolInfoInnerMetaJson{..} = (\poolInfoInnerMetaJsonDescription -> PoolInfoInnerMetaJson { poolInfoInnerMetaJsonDescription, ..} ) <$> f poolInfoInnerMetaJsonDescription
{-# INLINE poolInfoInnerMetaJsonDescriptionL #-}



-- * PoolInfoInnerRelaysInner

-- | 'poolInfoInnerRelaysInnerDns' Lens
poolInfoInnerRelaysInnerDnsL :: Lens_' PoolInfoInnerRelaysInner (Maybe Text)
poolInfoInnerRelaysInnerDnsL f PoolInfoInnerRelaysInner{..} = (\poolInfoInnerRelaysInnerDns -> PoolInfoInnerRelaysInner { poolInfoInnerRelaysInnerDns, ..} ) <$> f poolInfoInnerRelaysInnerDns
{-# INLINE poolInfoInnerRelaysInnerDnsL #-}

-- | 'poolInfoInnerRelaysInnerSrv' Lens
poolInfoInnerRelaysInnerSrvL :: Lens_' PoolInfoInnerRelaysInner (Maybe Text)
poolInfoInnerRelaysInnerSrvL f PoolInfoInnerRelaysInner{..} = (\poolInfoInnerRelaysInnerSrv -> PoolInfoInnerRelaysInner { poolInfoInnerRelaysInnerSrv, ..} ) <$> f poolInfoInnerRelaysInnerSrv
{-# INLINE poolInfoInnerRelaysInnerSrvL #-}

-- | 'poolInfoInnerRelaysInnerIpv4' Lens
poolInfoInnerRelaysInnerIpv4L :: Lens_' PoolInfoInnerRelaysInner (Maybe Text)
poolInfoInnerRelaysInnerIpv4L f PoolInfoInnerRelaysInner{..} = (\poolInfoInnerRelaysInnerIpv4 -> PoolInfoInnerRelaysInner { poolInfoInnerRelaysInnerIpv4, ..} ) <$> f poolInfoInnerRelaysInnerIpv4
{-# INLINE poolInfoInnerRelaysInnerIpv4L #-}

-- | 'poolInfoInnerRelaysInnerIpv6' Lens
poolInfoInnerRelaysInnerIpv6L :: Lens_' PoolInfoInnerRelaysInner (Maybe Text)
poolInfoInnerRelaysInnerIpv6L f PoolInfoInnerRelaysInner{..} = (\poolInfoInnerRelaysInnerIpv6 -> PoolInfoInnerRelaysInner { poolInfoInnerRelaysInnerIpv6, ..} ) <$> f poolInfoInnerRelaysInnerIpv6
{-# INLINE poolInfoInnerRelaysInnerIpv6L #-}

-- | 'poolInfoInnerRelaysInnerPort' Lens
poolInfoInnerRelaysInnerPortL :: Lens_' PoolInfoInnerRelaysInner (Maybe Double)
poolInfoInnerRelaysInnerPortL f PoolInfoInnerRelaysInner{..} = (\poolInfoInnerRelaysInnerPort -> PoolInfoInnerRelaysInner { poolInfoInnerRelaysInnerPort, ..} ) <$> f poolInfoInnerRelaysInnerPort
{-# INLINE poolInfoInnerRelaysInnerPortL #-}



-- * PoolInfoPostRequest

-- | 'poolInfoPostRequestPoolBech32Ids' Lens
poolInfoPostRequestPoolBech32IdsL :: Lens_' PoolInfoPostRequest ([Text])
poolInfoPostRequestPoolBech32IdsL f PoolInfoPostRequest{..} = (\poolInfoPostRequestPoolBech32Ids -> PoolInfoPostRequest { poolInfoPostRequestPoolBech32Ids, ..} ) <$> f poolInfoPostRequestPoolBech32Ids
{-# INLINE poolInfoPostRequestPoolBech32IdsL #-}



-- * PoolListInner

-- | 'poolListInnerPoolIdBech32' Lens
poolListInnerPoolIdBech32L :: Lens_' PoolListInner (Maybe Text)
poolListInnerPoolIdBech32L f PoolListInner{..} = (\poolListInnerPoolIdBech32 -> PoolListInner { poolListInnerPoolIdBech32, ..} ) <$> f poolListInnerPoolIdBech32
{-# INLINE poolListInnerPoolIdBech32L #-}

-- | 'poolListInnerTicker' Lens
poolListInnerTickerL :: Lens_' PoolListInner (Maybe Text)
poolListInnerTickerL f PoolListInner{..} = (\poolListInnerTicker -> PoolListInner { poolListInnerTicker, ..} ) <$> f poolListInnerTicker
{-# INLINE poolListInnerTickerL #-}



-- * PoolMetadataInner

-- | 'poolMetadataInnerPoolIdBech32' Lens
poolMetadataInnerPoolIdBech32L :: Lens_' PoolMetadataInner (Maybe PoolIdBech32)
poolMetadataInnerPoolIdBech32L f PoolMetadataInner{..} = (\poolMetadataInnerPoolIdBech32 -> PoolMetadataInner { poolMetadataInnerPoolIdBech32, ..} ) <$> f poolMetadataInnerPoolIdBech32
{-# INLINE poolMetadataInnerPoolIdBech32L #-}

-- | 'poolMetadataInnerMetaUrl' Lens
poolMetadataInnerMetaUrlL :: Lens_' PoolMetadataInner (Maybe MetaUrl)
poolMetadataInnerMetaUrlL f PoolMetadataInner{..} = (\poolMetadataInnerMetaUrl -> PoolMetadataInner { poolMetadataInnerMetaUrl, ..} ) <$> f poolMetadataInnerMetaUrl
{-# INLINE poolMetadataInnerMetaUrlL #-}

-- | 'poolMetadataInnerMetaHash' Lens
poolMetadataInnerMetaHashL :: Lens_' PoolMetadataInner (Maybe MetaHash)
poolMetadataInnerMetaHashL f PoolMetadataInner{..} = (\poolMetadataInnerMetaHash -> PoolMetadataInner { poolMetadataInnerMetaHash, ..} ) <$> f poolMetadataInnerMetaHash
{-# INLINE poolMetadataInnerMetaHashL #-}

-- | 'poolMetadataInnerMetaJson' Lens
poolMetadataInnerMetaJsonL :: Lens_' PoolMetadataInner (Maybe MetaJson)
poolMetadataInnerMetaJsonL f PoolMetadataInner{..} = (\poolMetadataInnerMetaJson -> PoolMetadataInner { poolMetadataInnerMetaJson, ..} ) <$> f poolMetadataInnerMetaJson
{-# INLINE poolMetadataInnerMetaJsonL #-}



-- * PoolMetadataPostRequest

-- | 'poolMetadataPostRequestPoolBech32Ids' Lens
poolMetadataPostRequestPoolBech32IdsL :: Lens_' PoolMetadataPostRequest (Maybe [Text])
poolMetadataPostRequestPoolBech32IdsL f PoolMetadataPostRequest{..} = (\poolMetadataPostRequestPoolBech32Ids -> PoolMetadataPostRequest { poolMetadataPostRequestPoolBech32Ids, ..} ) <$> f poolMetadataPostRequestPoolBech32Ids
{-# INLINE poolMetadataPostRequestPoolBech32IdsL #-}



-- * PoolRelaysInner

-- | 'poolRelaysInnerPoolIdBech32' Lens
poolRelaysInnerPoolIdBech32L :: Lens_' PoolRelaysInner (Maybe PoolIdBech32)
poolRelaysInnerPoolIdBech32L f PoolRelaysInner{..} = (\poolRelaysInnerPoolIdBech32 -> PoolRelaysInner { poolRelaysInnerPoolIdBech32, ..} ) <$> f poolRelaysInnerPoolIdBech32
{-# INLINE poolRelaysInnerPoolIdBech32L #-}

-- | 'poolRelaysInnerRelays' Lens
poolRelaysInnerRelaysL :: Lens_' PoolRelaysInner (Maybe Relays)
poolRelaysInnerRelaysL f PoolRelaysInner{..} = (\poolRelaysInnerRelays -> PoolRelaysInner { poolRelaysInnerRelays, ..} ) <$> f poolRelaysInnerRelays
{-# INLINE poolRelaysInnerRelaysL #-}



-- * PoolUpdatesInner

-- | 'poolUpdatesInnerTxHash' Lens
poolUpdatesInnerTxHashL :: Lens_' PoolUpdatesInner (Maybe TxHash)
poolUpdatesInnerTxHashL f PoolUpdatesInner{..} = (\poolUpdatesInnerTxHash -> PoolUpdatesInner { poolUpdatesInnerTxHash, ..} ) <$> f poolUpdatesInnerTxHash
{-# INLINE poolUpdatesInnerTxHashL #-}

-- | 'poolUpdatesInnerBlockTime' Lens
poolUpdatesInnerBlockTimeL :: Lens_' PoolUpdatesInner (Maybe BlockTime)
poolUpdatesInnerBlockTimeL f PoolUpdatesInner{..} = (\poolUpdatesInnerBlockTime -> PoolUpdatesInner { poolUpdatesInnerBlockTime, ..} ) <$> f poolUpdatesInnerBlockTime
{-# INLINE poolUpdatesInnerBlockTimeL #-}

-- | 'poolUpdatesInnerPoolIdBech32' Lens
poolUpdatesInnerPoolIdBech32L :: Lens_' PoolUpdatesInner (Maybe PoolIdBech32)
poolUpdatesInnerPoolIdBech32L f PoolUpdatesInner{..} = (\poolUpdatesInnerPoolIdBech32 -> PoolUpdatesInner { poolUpdatesInnerPoolIdBech32, ..} ) <$> f poolUpdatesInnerPoolIdBech32
{-# INLINE poolUpdatesInnerPoolIdBech32L #-}

-- | 'poolUpdatesInnerPoolIdHex' Lens
poolUpdatesInnerPoolIdHexL :: Lens_' PoolUpdatesInner (Maybe PoolIdHex)
poolUpdatesInnerPoolIdHexL f PoolUpdatesInner{..} = (\poolUpdatesInnerPoolIdHex -> PoolUpdatesInner { poolUpdatesInnerPoolIdHex, ..} ) <$> f poolUpdatesInnerPoolIdHex
{-# INLINE poolUpdatesInnerPoolIdHexL #-}

-- | 'poolUpdatesInnerActiveEpochNo' Lens
poolUpdatesInnerActiveEpochNoL :: Lens_' PoolUpdatesInner (Maybe Int)
poolUpdatesInnerActiveEpochNoL f PoolUpdatesInner{..} = (\poolUpdatesInnerActiveEpochNo -> PoolUpdatesInner { poolUpdatesInnerActiveEpochNo, ..} ) <$> f poolUpdatesInnerActiveEpochNo
{-# INLINE poolUpdatesInnerActiveEpochNoL #-}

-- | 'poolUpdatesInnerVrfKeyHash' Lens
poolUpdatesInnerVrfKeyHashL :: Lens_' PoolUpdatesInner (Maybe VrfKeyHash)
poolUpdatesInnerVrfKeyHashL f PoolUpdatesInner{..} = (\poolUpdatesInnerVrfKeyHash -> PoolUpdatesInner { poolUpdatesInnerVrfKeyHash, ..} ) <$> f poolUpdatesInnerVrfKeyHash
{-# INLINE poolUpdatesInnerVrfKeyHashL #-}

-- | 'poolUpdatesInnerMargin' Lens
poolUpdatesInnerMarginL :: Lens_' PoolUpdatesInner (Maybe Margin)
poolUpdatesInnerMarginL f PoolUpdatesInner{..} = (\poolUpdatesInnerMargin -> PoolUpdatesInner { poolUpdatesInnerMargin, ..} ) <$> f poolUpdatesInnerMargin
{-# INLINE poolUpdatesInnerMarginL #-}

-- | 'poolUpdatesInnerFixedCost' Lens
poolUpdatesInnerFixedCostL :: Lens_' PoolUpdatesInner (Maybe FixedCost)
poolUpdatesInnerFixedCostL f PoolUpdatesInner{..} = (\poolUpdatesInnerFixedCost -> PoolUpdatesInner { poolUpdatesInnerFixedCost, ..} ) <$> f poolUpdatesInnerFixedCost
{-# INLINE poolUpdatesInnerFixedCostL #-}

-- | 'poolUpdatesInnerPledge' Lens
poolUpdatesInnerPledgeL :: Lens_' PoolUpdatesInner (Maybe Pledge)
poolUpdatesInnerPledgeL f PoolUpdatesInner{..} = (\poolUpdatesInnerPledge -> PoolUpdatesInner { poolUpdatesInnerPledge, ..} ) <$> f poolUpdatesInnerPledge
{-# INLINE poolUpdatesInnerPledgeL #-}

-- | 'poolUpdatesInnerRewardAddr' Lens
poolUpdatesInnerRewardAddrL :: Lens_' PoolUpdatesInner (Maybe RewardAddr)
poolUpdatesInnerRewardAddrL f PoolUpdatesInner{..} = (\poolUpdatesInnerRewardAddr -> PoolUpdatesInner { poolUpdatesInnerRewardAddr, ..} ) <$> f poolUpdatesInnerRewardAddr
{-# INLINE poolUpdatesInnerRewardAddrL #-}

-- | 'poolUpdatesInnerOwners' Lens
poolUpdatesInnerOwnersL :: Lens_' PoolUpdatesInner (Maybe Owners)
poolUpdatesInnerOwnersL f PoolUpdatesInner{..} = (\poolUpdatesInnerOwners -> PoolUpdatesInner { poolUpdatesInnerOwners, ..} ) <$> f poolUpdatesInnerOwners
{-# INLINE poolUpdatesInnerOwnersL #-}

-- | 'poolUpdatesInnerRelays' Lens
poolUpdatesInnerRelaysL :: Lens_' PoolUpdatesInner (Maybe Relays)
poolUpdatesInnerRelaysL f PoolUpdatesInner{..} = (\poolUpdatesInnerRelays -> PoolUpdatesInner { poolUpdatesInnerRelays, ..} ) <$> f poolUpdatesInnerRelays
{-# INLINE poolUpdatesInnerRelaysL #-}

-- | 'poolUpdatesInnerMetaUrl' Lens
poolUpdatesInnerMetaUrlL :: Lens_' PoolUpdatesInner (Maybe MetaUrl)
poolUpdatesInnerMetaUrlL f PoolUpdatesInner{..} = (\poolUpdatesInnerMetaUrl -> PoolUpdatesInner { poolUpdatesInnerMetaUrl, ..} ) <$> f poolUpdatesInnerMetaUrl
{-# INLINE poolUpdatesInnerMetaUrlL #-}

-- | 'poolUpdatesInnerMetaHash' Lens
poolUpdatesInnerMetaHashL :: Lens_' PoolUpdatesInner (Maybe MetaHash)
poolUpdatesInnerMetaHashL f PoolUpdatesInner{..} = (\poolUpdatesInnerMetaHash -> PoolUpdatesInner { poolUpdatesInnerMetaHash, ..} ) <$> f poolUpdatesInnerMetaHash
{-# INLINE poolUpdatesInnerMetaHashL #-}

-- | 'poolUpdatesInnerPoolStatus' Lens
poolUpdatesInnerPoolStatusL :: Lens_' PoolUpdatesInner (Maybe PoolStatus)
poolUpdatesInnerPoolStatusL f PoolUpdatesInner{..} = (\poolUpdatesInnerPoolStatus -> PoolUpdatesInner { poolUpdatesInnerPoolStatus, ..} ) <$> f poolUpdatesInnerPoolStatus
{-# INLINE poolUpdatesInnerPoolStatusL #-}

-- | 'poolUpdatesInnerRetiringEpoch' Lens
poolUpdatesInnerRetiringEpochL :: Lens_' PoolUpdatesInner (Maybe RetiringEpoch)
poolUpdatesInnerRetiringEpochL f PoolUpdatesInner{..} = (\poolUpdatesInnerRetiringEpoch -> PoolUpdatesInner { poolUpdatesInnerRetiringEpoch, ..} ) <$> f poolUpdatesInnerRetiringEpoch
{-# INLINE poolUpdatesInnerRetiringEpochL #-}



-- * ScriptRedeemersInner

-- | 'scriptRedeemersInnerScriptHash' Lens
scriptRedeemersInnerScriptHashL :: Lens_' ScriptRedeemersInner (Maybe Text)
scriptRedeemersInnerScriptHashL f ScriptRedeemersInner{..} = (\scriptRedeemersInnerScriptHash -> ScriptRedeemersInner { scriptRedeemersInnerScriptHash, ..} ) <$> f scriptRedeemersInnerScriptHash
{-# INLINE scriptRedeemersInnerScriptHashL #-}

-- | 'scriptRedeemersInnerRedeemers' Lens
scriptRedeemersInnerRedeemersL :: Lens_' ScriptRedeemersInner (Maybe [ScriptRedeemersInnerRedeemersInner])
scriptRedeemersInnerRedeemersL f ScriptRedeemersInner{..} = (\scriptRedeemersInnerRedeemers -> ScriptRedeemersInner { scriptRedeemersInnerRedeemers, ..} ) <$> f scriptRedeemersInnerRedeemers
{-# INLINE scriptRedeemersInnerRedeemersL #-}



-- * ScriptRedeemersInnerRedeemersInner

-- | 'scriptRedeemersInnerRedeemersInnerTxHash' Lens
scriptRedeemersInnerRedeemersInnerTxHashL :: Lens_' ScriptRedeemersInnerRedeemersInner (Maybe Text)
scriptRedeemersInnerRedeemersInnerTxHashL f ScriptRedeemersInnerRedeemersInner{..} = (\scriptRedeemersInnerRedeemersInnerTxHash -> ScriptRedeemersInnerRedeemersInner { scriptRedeemersInnerRedeemersInnerTxHash, ..} ) <$> f scriptRedeemersInnerRedeemersInnerTxHash
{-# INLINE scriptRedeemersInnerRedeemersInnerTxHashL #-}

-- | 'scriptRedeemersInnerRedeemersInnerTxIndex' Lens
scriptRedeemersInnerRedeemersInnerTxIndexL :: Lens_' ScriptRedeemersInnerRedeemersInner (Maybe Int)
scriptRedeemersInnerRedeemersInnerTxIndexL f ScriptRedeemersInnerRedeemersInner{..} = (\scriptRedeemersInnerRedeemersInnerTxIndex -> ScriptRedeemersInnerRedeemersInner { scriptRedeemersInnerRedeemersInnerTxIndex, ..} ) <$> f scriptRedeemersInnerRedeemersInnerTxIndex
{-# INLINE scriptRedeemersInnerRedeemersInnerTxIndexL #-}

-- | 'scriptRedeemersInnerRedeemersInnerUnitMem' Lens
scriptRedeemersInnerRedeemersInnerUnitMemL :: Lens_' ScriptRedeemersInnerRedeemersInner (Maybe (Map.Map String ScriptRedeemersInnerRedeemersInnerUnitMemValue))
scriptRedeemersInnerRedeemersInnerUnitMemL f ScriptRedeemersInnerRedeemersInner{..} = (\scriptRedeemersInnerRedeemersInnerUnitMem -> ScriptRedeemersInnerRedeemersInner { scriptRedeemersInnerRedeemersInnerUnitMem, ..} ) <$> f scriptRedeemersInnerRedeemersInnerUnitMem
{-# INLINE scriptRedeemersInnerRedeemersInnerUnitMemL #-}

-- | 'scriptRedeemersInnerRedeemersInnerUnitSteps' Lens
scriptRedeemersInnerRedeemersInnerUnitStepsL :: Lens_' ScriptRedeemersInnerRedeemersInner (Maybe (Map.Map String ScriptRedeemersInnerRedeemersInnerUnitMemValue))
scriptRedeemersInnerRedeemersInnerUnitStepsL f ScriptRedeemersInnerRedeemersInner{..} = (\scriptRedeemersInnerRedeemersInnerUnitSteps -> ScriptRedeemersInnerRedeemersInner { scriptRedeemersInnerRedeemersInnerUnitSteps, ..} ) <$> f scriptRedeemersInnerRedeemersInnerUnitSteps
{-# INLINE scriptRedeemersInnerRedeemersInnerUnitStepsL #-}

-- | 'scriptRedeemersInnerRedeemersInnerFee' Lens
scriptRedeemersInnerRedeemersInnerFeeL :: Lens_' ScriptRedeemersInnerRedeemersInner (Maybe Text)
scriptRedeemersInnerRedeemersInnerFeeL f ScriptRedeemersInnerRedeemersInner{..} = (\scriptRedeemersInnerRedeemersInnerFee -> ScriptRedeemersInnerRedeemersInner { scriptRedeemersInnerRedeemersInnerFee, ..} ) <$> f scriptRedeemersInnerRedeemersInnerFee
{-# INLINE scriptRedeemersInnerRedeemersInnerFeeL #-}

-- | 'scriptRedeemersInnerRedeemersInnerPurpose' Lens
scriptRedeemersInnerRedeemersInnerPurposeL :: Lens_' ScriptRedeemersInnerRedeemersInner (Maybe E'Purpose)
scriptRedeemersInnerRedeemersInnerPurposeL f ScriptRedeemersInnerRedeemersInner{..} = (\scriptRedeemersInnerRedeemersInnerPurpose -> ScriptRedeemersInnerRedeemersInner { scriptRedeemersInnerRedeemersInnerPurpose, ..} ) <$> f scriptRedeemersInnerRedeemersInnerPurpose
{-# INLINE scriptRedeemersInnerRedeemersInnerPurposeL #-}

-- | 'scriptRedeemersInnerRedeemersInnerDatumHash' Lens
scriptRedeemersInnerRedeemersInnerDatumHashL :: Lens_' ScriptRedeemersInnerRedeemersInner (Maybe Text)
scriptRedeemersInnerRedeemersInnerDatumHashL f ScriptRedeemersInnerRedeemersInner{..} = (\scriptRedeemersInnerRedeemersInnerDatumHash -> ScriptRedeemersInnerRedeemersInner { scriptRedeemersInnerRedeemersInnerDatumHash, ..} ) <$> f scriptRedeemersInnerRedeemersInnerDatumHash
{-# INLINE scriptRedeemersInnerRedeemersInnerDatumHashL #-}

-- | 'scriptRedeemersInnerRedeemersInnerDatumValue' Lens
scriptRedeemersInnerRedeemersInnerDatumValueL :: Lens_' ScriptRedeemersInnerRedeemersInner (Maybe A.Value)
scriptRedeemersInnerRedeemersInnerDatumValueL f ScriptRedeemersInnerRedeemersInner{..} = (\scriptRedeemersInnerRedeemersInnerDatumValue -> ScriptRedeemersInnerRedeemersInner { scriptRedeemersInnerRedeemersInnerDatumValue, ..} ) <$> f scriptRedeemersInnerRedeemersInnerDatumValue
{-# INLINE scriptRedeemersInnerRedeemersInnerDatumValueL #-}



-- * ScriptRedeemersInnerRedeemersInnerUnitMemValue



-- * TipInner

-- | 'tipInnerHash' Lens
tipInnerHashL :: Lens_' TipInner (Maybe Hash)
tipInnerHashL f TipInner{..} = (\tipInnerHash -> TipInner { tipInnerHash, ..} ) <$> f tipInnerHash
{-# INLINE tipInnerHashL #-}

-- | 'tipInnerEpochNo' Lens
tipInnerEpochNoL :: Lens_' TipInner (Maybe EpochNo)
tipInnerEpochNoL f TipInner{..} = (\tipInnerEpochNo -> TipInner { tipInnerEpochNo, ..} ) <$> f tipInnerEpochNo
{-# INLINE tipInnerEpochNoL #-}

-- | 'tipInnerAbsSlot' Lens
tipInnerAbsSlotL :: Lens_' TipInner (Maybe AbsSlot)
tipInnerAbsSlotL f TipInner{..} = (\tipInnerAbsSlot -> TipInner { tipInnerAbsSlot, ..} ) <$> f tipInnerAbsSlot
{-# INLINE tipInnerAbsSlotL #-}

-- | 'tipInnerEpochSlot' Lens
tipInnerEpochSlotL :: Lens_' TipInner (Maybe EpochSlot)
tipInnerEpochSlotL f TipInner{..} = (\tipInnerEpochSlot -> TipInner { tipInnerEpochSlot, ..} ) <$> f tipInnerEpochSlot
{-# INLINE tipInnerEpochSlotL #-}

-- | 'tipInnerBlockNo' Lens
tipInnerBlockNoL :: Lens_' TipInner (Maybe BlockHeight)
tipInnerBlockNoL f TipInner{..} = (\tipInnerBlockNo -> TipInner { tipInnerBlockNo, ..} ) <$> f tipInnerBlockNo
{-# INLINE tipInnerBlockNoL #-}

-- | 'tipInnerBlockTime' Lens
tipInnerBlockTimeL :: Lens_' TipInner (Maybe BlockTime)
tipInnerBlockTimeL f TipInner{..} = (\tipInnerBlockTime -> TipInner { tipInnerBlockTime, ..} ) <$> f tipInnerBlockTime
{-# INLINE tipInnerBlockTimeL #-}



-- * TotalsInner

-- | 'totalsInnerEpochNo' Lens
totalsInnerEpochNoL :: Lens_' TotalsInner (Maybe Int)
totalsInnerEpochNoL f TotalsInner{..} = (\totalsInnerEpochNo -> TotalsInner { totalsInnerEpochNo, ..} ) <$> f totalsInnerEpochNo
{-# INLINE totalsInnerEpochNoL #-}

-- | 'totalsInnerCirculation' Lens
totalsInnerCirculationL :: Lens_' TotalsInner (Maybe Text)
totalsInnerCirculationL f TotalsInner{..} = (\totalsInnerCirculation -> TotalsInner { totalsInnerCirculation, ..} ) <$> f totalsInnerCirculation
{-# INLINE totalsInnerCirculationL #-}

-- | 'totalsInnerTreasury' Lens
totalsInnerTreasuryL :: Lens_' TotalsInner (Maybe Text)
totalsInnerTreasuryL f TotalsInner{..} = (\totalsInnerTreasury -> TotalsInner { totalsInnerTreasury, ..} ) <$> f totalsInnerTreasury
{-# INLINE totalsInnerTreasuryL #-}

-- | 'totalsInnerReward' Lens
totalsInnerRewardL :: Lens_' TotalsInner (Maybe Text)
totalsInnerRewardL f TotalsInner{..} = (\totalsInnerReward -> TotalsInner { totalsInnerReward, ..} ) <$> f totalsInnerReward
{-# INLINE totalsInnerRewardL #-}

-- | 'totalsInnerSupply' Lens
totalsInnerSupplyL :: Lens_' TotalsInner (Maybe Text)
totalsInnerSupplyL f TotalsInner{..} = (\totalsInnerSupply -> TotalsInner { totalsInnerSupply, ..} ) <$> f totalsInnerSupply
{-# INLINE totalsInnerSupplyL #-}

-- | 'totalsInnerReserves' Lens
totalsInnerReservesL :: Lens_' TotalsInner (Maybe Text)
totalsInnerReservesL f TotalsInner{..} = (\totalsInnerReserves -> TotalsInner { totalsInnerReserves, ..} ) <$> f totalsInnerReserves
{-# INLINE totalsInnerReservesL #-}



-- * TxInfoInner

-- | 'txInfoInnerTxHash' Lens
txInfoInnerTxHashL :: Lens_' TxInfoInner (Maybe Text)
txInfoInnerTxHashL f TxInfoInner{..} = (\txInfoInnerTxHash -> TxInfoInner { txInfoInnerTxHash, ..} ) <$> f txInfoInnerTxHash
{-# INLINE txInfoInnerTxHashL #-}

-- | 'txInfoInnerBlockHash' Lens
txInfoInnerBlockHashL :: Lens_' TxInfoInner (Maybe Hash)
txInfoInnerBlockHashL f TxInfoInner{..} = (\txInfoInnerBlockHash -> TxInfoInner { txInfoInnerBlockHash, ..} ) <$> f txInfoInnerBlockHash
{-# INLINE txInfoInnerBlockHashL #-}

-- | 'txInfoInnerBlockHeight' Lens
txInfoInnerBlockHeightL :: Lens_' TxInfoInner (Maybe BlockHeight)
txInfoInnerBlockHeightL f TxInfoInner{..} = (\txInfoInnerBlockHeight -> TxInfoInner { txInfoInnerBlockHeight, ..} ) <$> f txInfoInnerBlockHeight
{-# INLINE txInfoInnerBlockHeightL #-}

-- | 'txInfoInnerEpochNo' Lens
txInfoInnerEpochNoL :: Lens_' TxInfoInner (Maybe EpochNo)
txInfoInnerEpochNoL f TxInfoInner{..} = (\txInfoInnerEpochNo -> TxInfoInner { txInfoInnerEpochNo, ..} ) <$> f txInfoInnerEpochNo
{-# INLINE txInfoInnerEpochNoL #-}

-- | 'txInfoInnerEpochSlot' Lens
txInfoInnerEpochSlotL :: Lens_' TxInfoInner (Maybe EpochSlot)
txInfoInnerEpochSlotL f TxInfoInner{..} = (\txInfoInnerEpochSlot -> TxInfoInner { txInfoInnerEpochSlot, ..} ) <$> f txInfoInnerEpochSlot
{-# INLINE txInfoInnerEpochSlotL #-}

-- | 'txInfoInnerAbsoluteSlot' Lens
txInfoInnerAbsoluteSlotL :: Lens_' TxInfoInner (Maybe AbsSlot)
txInfoInnerAbsoluteSlotL f TxInfoInner{..} = (\txInfoInnerAbsoluteSlot -> TxInfoInner { txInfoInnerAbsoluteSlot, ..} ) <$> f txInfoInnerAbsoluteSlot
{-# INLINE txInfoInnerAbsoluteSlotL #-}

-- | 'txInfoInnerTxTimestamp' Lens
txInfoInnerTxTimestampL :: Lens_' TxInfoInner (Maybe Int)
txInfoInnerTxTimestampL f TxInfoInner{..} = (\txInfoInnerTxTimestamp -> TxInfoInner { txInfoInnerTxTimestamp, ..} ) <$> f txInfoInnerTxTimestamp
{-# INLINE txInfoInnerTxTimestampL #-}

-- | 'txInfoInnerTxBlockIndex' Lens
txInfoInnerTxBlockIndexL :: Lens_' TxInfoInner (Maybe Int)
txInfoInnerTxBlockIndexL f TxInfoInner{..} = (\txInfoInnerTxBlockIndex -> TxInfoInner { txInfoInnerTxBlockIndex, ..} ) <$> f txInfoInnerTxBlockIndex
{-# INLINE txInfoInnerTxBlockIndexL #-}

-- | 'txInfoInnerTxSize' Lens
txInfoInnerTxSizeL :: Lens_' TxInfoInner (Maybe Int)
txInfoInnerTxSizeL f TxInfoInner{..} = (\txInfoInnerTxSize -> TxInfoInner { txInfoInnerTxSize, ..} ) <$> f txInfoInnerTxSize
{-# INLINE txInfoInnerTxSizeL #-}

-- | 'txInfoInnerTotalOutput' Lens
txInfoInnerTotalOutputL :: Lens_' TxInfoInner (Maybe Text)
txInfoInnerTotalOutputL f TxInfoInner{..} = (\txInfoInnerTotalOutput -> TxInfoInner { txInfoInnerTotalOutput, ..} ) <$> f txInfoInnerTotalOutput
{-# INLINE txInfoInnerTotalOutputL #-}

-- | 'txInfoInnerFee' Lens
txInfoInnerFeeL :: Lens_' TxInfoInner (Maybe Text)
txInfoInnerFeeL f TxInfoInner{..} = (\txInfoInnerFee -> TxInfoInner { txInfoInnerFee, ..} ) <$> f txInfoInnerFee
{-# INLINE txInfoInnerFeeL #-}

-- | 'txInfoInnerDeposit' Lens
txInfoInnerDepositL :: Lens_' TxInfoInner (Maybe Text)
txInfoInnerDepositL f TxInfoInner{..} = (\txInfoInnerDeposit -> TxInfoInner { txInfoInnerDeposit, ..} ) <$> f txInfoInnerDeposit
{-# INLINE txInfoInnerDepositL #-}

-- | 'txInfoInnerInvalidBefore' Lens
txInfoInnerInvalidBeforeL :: Lens_' TxInfoInner (Maybe Int)
txInfoInnerInvalidBeforeL f TxInfoInner{..} = (\txInfoInnerInvalidBefore -> TxInfoInner { txInfoInnerInvalidBefore, ..} ) <$> f txInfoInnerInvalidBefore
{-# INLINE txInfoInnerInvalidBeforeL #-}

-- | 'txInfoInnerInvalidAfter' Lens
txInfoInnerInvalidAfterL :: Lens_' TxInfoInner (Maybe Int)
txInfoInnerInvalidAfterL f TxInfoInner{..} = (\txInfoInnerInvalidAfter -> TxInfoInner { txInfoInnerInvalidAfter, ..} ) <$> f txInfoInnerInvalidAfter
{-# INLINE txInfoInnerInvalidAfterL #-}

-- | 'txInfoInnerCollateralInputs' Lens
txInfoInnerCollateralInputsL :: Lens_' TxInfoInner (Maybe Outputs)
txInfoInnerCollateralInputsL f TxInfoInner{..} = (\txInfoInnerCollateralInputs -> TxInfoInner { txInfoInnerCollateralInputs, ..} ) <$> f txInfoInnerCollateralInputs
{-# INLINE txInfoInnerCollateralInputsL #-}

-- | 'txInfoInnerCollateralOutput' Lens
txInfoInnerCollateralOutputL :: Lens_' TxInfoInner (Maybe Items)
txInfoInnerCollateralOutputL f TxInfoInner{..} = (\txInfoInnerCollateralOutput -> TxInfoInner { txInfoInnerCollateralOutput, ..} ) <$> f txInfoInnerCollateralOutput
{-# INLINE txInfoInnerCollateralOutputL #-}

-- | 'txInfoInnerReferenceInputs' Lens
txInfoInnerReferenceInputsL :: Lens_' TxInfoInner (Maybe Outputs)
txInfoInnerReferenceInputsL f TxInfoInner{..} = (\txInfoInnerReferenceInputs -> TxInfoInner { txInfoInnerReferenceInputs, ..} ) <$> f txInfoInnerReferenceInputs
{-# INLINE txInfoInnerReferenceInputsL #-}

-- | 'txInfoInnerInputs' Lens
txInfoInnerInputsL :: Lens_' TxInfoInner (Maybe Outputs)
txInfoInnerInputsL f TxInfoInner{..} = (\txInfoInnerInputs -> TxInfoInner { txInfoInnerInputs, ..} ) <$> f txInfoInnerInputs
{-# INLINE txInfoInnerInputsL #-}

-- | 'txInfoInnerOutputs' Lens
txInfoInnerOutputsL :: Lens_' TxInfoInner (Maybe [TxInfoInnerOutputsInner])
txInfoInnerOutputsL f TxInfoInner{..} = (\txInfoInnerOutputs -> TxInfoInner { txInfoInnerOutputs, ..} ) <$> f txInfoInnerOutputs
{-# INLINE txInfoInnerOutputsL #-}

-- | 'txInfoInnerWithdrawals' Lens
txInfoInnerWithdrawalsL :: Lens_' TxInfoInner (Maybe [TxInfoInnerWithdrawalsInner])
txInfoInnerWithdrawalsL f TxInfoInner{..} = (\txInfoInnerWithdrawals -> TxInfoInner { txInfoInnerWithdrawals, ..} ) <$> f txInfoInnerWithdrawals
{-# INLINE txInfoInnerWithdrawalsL #-}

-- | 'txInfoInnerAssetsMinted' Lens
txInfoInnerAssetsMintedL :: Lens_' TxInfoInner (Maybe [TxInfoInnerAssetsMintedInner])
txInfoInnerAssetsMintedL f TxInfoInner{..} = (\txInfoInnerAssetsMinted -> TxInfoInner { txInfoInnerAssetsMinted, ..} ) <$> f txInfoInnerAssetsMinted
{-# INLINE txInfoInnerAssetsMintedL #-}

-- | 'txInfoInnerMetadata' Lens
txInfoInnerMetadataL :: Lens_' TxInfoInner (Maybe [TxInfoInnerMetadataInner])
txInfoInnerMetadataL f TxInfoInner{..} = (\txInfoInnerMetadata -> TxInfoInner { txInfoInnerMetadata, ..} ) <$> f txInfoInnerMetadata
{-# INLINE txInfoInnerMetadataL #-}

-- | 'txInfoInnerCertificates' Lens
txInfoInnerCertificatesL :: Lens_' TxInfoInner (Maybe [TxInfoInnerCertificatesInner])
txInfoInnerCertificatesL f TxInfoInner{..} = (\txInfoInnerCertificates -> TxInfoInner { txInfoInnerCertificates, ..} ) <$> f txInfoInnerCertificates
{-# INLINE txInfoInnerCertificatesL #-}

-- | 'txInfoInnerNativeScripts' Lens
txInfoInnerNativeScriptsL :: Lens_' TxInfoInner (Maybe [TxInfoInnerNativeScriptsInner])
txInfoInnerNativeScriptsL f TxInfoInner{..} = (\txInfoInnerNativeScripts -> TxInfoInner { txInfoInnerNativeScripts, ..} ) <$> f txInfoInnerNativeScripts
{-# INLINE txInfoInnerNativeScriptsL #-}

-- | 'txInfoInnerPlutusContracts' Lens
txInfoInnerPlutusContractsL :: Lens_' TxInfoInner (Maybe [TxInfoInnerPlutusContractsInner])
txInfoInnerPlutusContractsL f TxInfoInner{..} = (\txInfoInnerPlutusContracts -> TxInfoInner { txInfoInnerPlutusContracts, ..} ) <$> f txInfoInnerPlutusContracts
{-# INLINE txInfoInnerPlutusContractsL #-}



-- * TxInfoInnerAssetsMintedInner

-- | 'txInfoInnerAssetsMintedInnerPolicyId' Lens
txInfoInnerAssetsMintedInnerPolicyIdL :: Lens_' TxInfoInnerAssetsMintedInner (Maybe PolicyId)
txInfoInnerAssetsMintedInnerPolicyIdL f TxInfoInnerAssetsMintedInner{..} = (\txInfoInnerAssetsMintedInnerPolicyId -> TxInfoInnerAssetsMintedInner { txInfoInnerAssetsMintedInnerPolicyId, ..} ) <$> f txInfoInnerAssetsMintedInnerPolicyId
{-# INLINE txInfoInnerAssetsMintedInnerPolicyIdL #-}

-- | 'txInfoInnerAssetsMintedInnerAssetName' Lens
txInfoInnerAssetsMintedInnerAssetNameL :: Lens_' TxInfoInnerAssetsMintedInner (Maybe AssetName)
txInfoInnerAssetsMintedInnerAssetNameL f TxInfoInnerAssetsMintedInner{..} = (\txInfoInnerAssetsMintedInnerAssetName -> TxInfoInnerAssetsMintedInner { txInfoInnerAssetsMintedInnerAssetName, ..} ) <$> f txInfoInnerAssetsMintedInnerAssetName
{-# INLINE txInfoInnerAssetsMintedInnerAssetNameL #-}

-- | 'txInfoInnerAssetsMintedInnerQuantity' Lens
txInfoInnerAssetsMintedInnerQuantityL :: Lens_' TxInfoInnerAssetsMintedInner (Maybe Text)
txInfoInnerAssetsMintedInnerQuantityL f TxInfoInnerAssetsMintedInner{..} = (\txInfoInnerAssetsMintedInnerQuantity -> TxInfoInnerAssetsMintedInner { txInfoInnerAssetsMintedInnerQuantity, ..} ) <$> f txInfoInnerAssetsMintedInnerQuantity
{-# INLINE txInfoInnerAssetsMintedInnerQuantityL #-}



-- * TxInfoInnerCertificatesInner

-- | 'txInfoInnerCertificatesInnerIndex' Lens
txInfoInnerCertificatesInnerIndexL :: Lens_' TxInfoInnerCertificatesInner (Maybe Int)
txInfoInnerCertificatesInnerIndexL f TxInfoInnerCertificatesInner{..} = (\txInfoInnerCertificatesInnerIndex -> TxInfoInnerCertificatesInner { txInfoInnerCertificatesInnerIndex, ..} ) <$> f txInfoInnerCertificatesInnerIndex
{-# INLINE txInfoInnerCertificatesInnerIndexL #-}

-- | 'txInfoInnerCertificatesInnerType' Lens
txInfoInnerCertificatesInnerTypeL :: Lens_' TxInfoInnerCertificatesInner (Maybe Text)
txInfoInnerCertificatesInnerTypeL f TxInfoInnerCertificatesInner{..} = (\txInfoInnerCertificatesInnerType -> TxInfoInnerCertificatesInner { txInfoInnerCertificatesInnerType, ..} ) <$> f txInfoInnerCertificatesInnerType
{-# INLINE txInfoInnerCertificatesInnerTypeL #-}

-- | 'txInfoInnerCertificatesInnerInfo' Lens
txInfoInnerCertificatesInnerInfoL :: Lens_' TxInfoInnerCertificatesInner (Maybe A.Value)
txInfoInnerCertificatesInnerInfoL f TxInfoInnerCertificatesInner{..} = (\txInfoInnerCertificatesInnerInfo -> TxInfoInnerCertificatesInner { txInfoInnerCertificatesInnerInfo, ..} ) <$> f txInfoInnerCertificatesInnerInfo
{-# INLINE txInfoInnerCertificatesInnerInfoL #-}



-- * TxInfoInnerMetadataInner

-- | 'txInfoInnerMetadataInnerKey' Lens
txInfoInnerMetadataInnerKeyL :: Lens_' TxInfoInnerMetadataInner (Maybe Text)
txInfoInnerMetadataInnerKeyL f TxInfoInnerMetadataInner{..} = (\txInfoInnerMetadataInnerKey -> TxInfoInnerMetadataInner { txInfoInnerMetadataInnerKey, ..} ) <$> f txInfoInnerMetadataInnerKey
{-# INLINE txInfoInnerMetadataInnerKeyL #-}

-- | 'txInfoInnerMetadataInnerJson' Lens
txInfoInnerMetadataInnerJsonL :: Lens_' TxInfoInnerMetadataInner (Maybe Metadata)
txInfoInnerMetadataInnerJsonL f TxInfoInnerMetadataInner{..} = (\txInfoInnerMetadataInnerJson -> TxInfoInnerMetadataInner { txInfoInnerMetadataInnerJson, ..} ) <$> f txInfoInnerMetadataInnerJson
{-# INLINE txInfoInnerMetadataInnerJsonL #-}



-- * TxInfoInnerNativeScriptsInner

-- | 'txInfoInnerNativeScriptsInnerScriptHash' Lens
txInfoInnerNativeScriptsInnerScriptHashL :: Lens_' TxInfoInnerNativeScriptsInner (Maybe ScriptHash)
txInfoInnerNativeScriptsInnerScriptHashL f TxInfoInnerNativeScriptsInner{..} = (\txInfoInnerNativeScriptsInnerScriptHash -> TxInfoInnerNativeScriptsInner { txInfoInnerNativeScriptsInnerScriptHash, ..} ) <$> f txInfoInnerNativeScriptsInnerScriptHash
{-# INLINE txInfoInnerNativeScriptsInnerScriptHashL #-}

-- | 'txInfoInnerNativeScriptsInnerScriptJson' Lens
txInfoInnerNativeScriptsInnerScriptJsonL :: Lens_' TxInfoInnerNativeScriptsInner (Maybe A.Value)
txInfoInnerNativeScriptsInnerScriptJsonL f TxInfoInnerNativeScriptsInner{..} = (\txInfoInnerNativeScriptsInnerScriptJson -> TxInfoInnerNativeScriptsInner { txInfoInnerNativeScriptsInnerScriptJson, ..} ) <$> f txInfoInnerNativeScriptsInnerScriptJson
{-# INLINE txInfoInnerNativeScriptsInnerScriptJsonL #-}



-- * TxInfoInnerOutputsInner

-- | 'txInfoInnerOutputsInnerPaymentAddr' Lens
txInfoInnerOutputsInnerPaymentAddrL :: Lens_' TxInfoInnerOutputsInner (Maybe TxInfoInnerOutputsInnerPaymentAddr)
txInfoInnerOutputsInnerPaymentAddrL f TxInfoInnerOutputsInner{..} = (\txInfoInnerOutputsInnerPaymentAddr -> TxInfoInnerOutputsInner { txInfoInnerOutputsInnerPaymentAddr, ..} ) <$> f txInfoInnerOutputsInnerPaymentAddr
{-# INLINE txInfoInnerOutputsInnerPaymentAddrL #-}

-- | 'txInfoInnerOutputsInnerStakeAddr' Lens
txInfoInnerOutputsInnerStakeAddrL :: Lens_' TxInfoInnerOutputsInner (Maybe StakeAddress)
txInfoInnerOutputsInnerStakeAddrL f TxInfoInnerOutputsInner{..} = (\txInfoInnerOutputsInnerStakeAddr -> TxInfoInnerOutputsInner { txInfoInnerOutputsInnerStakeAddr, ..} ) <$> f txInfoInnerOutputsInnerStakeAddr
{-# INLINE txInfoInnerOutputsInnerStakeAddrL #-}

-- | 'txInfoInnerOutputsInnerTxHash' Lens
txInfoInnerOutputsInnerTxHashL :: Lens_' TxInfoInnerOutputsInner (Maybe Text)
txInfoInnerOutputsInnerTxHashL f TxInfoInnerOutputsInner{..} = (\txInfoInnerOutputsInnerTxHash -> TxInfoInnerOutputsInner { txInfoInnerOutputsInnerTxHash, ..} ) <$> f txInfoInnerOutputsInnerTxHash
{-# INLINE txInfoInnerOutputsInnerTxHashL #-}

-- | 'txInfoInnerOutputsInnerTxIndex' Lens
txInfoInnerOutputsInnerTxIndexL :: Lens_' TxInfoInnerOutputsInner (Maybe Int)
txInfoInnerOutputsInnerTxIndexL f TxInfoInnerOutputsInner{..} = (\txInfoInnerOutputsInnerTxIndex -> TxInfoInnerOutputsInner { txInfoInnerOutputsInnerTxIndex, ..} ) <$> f txInfoInnerOutputsInnerTxIndex
{-# INLINE txInfoInnerOutputsInnerTxIndexL #-}

-- | 'txInfoInnerOutputsInnerValue' Lens
txInfoInnerOutputsInnerValueL :: Lens_' TxInfoInnerOutputsInner (Maybe Text)
txInfoInnerOutputsInnerValueL f TxInfoInnerOutputsInner{..} = (\txInfoInnerOutputsInnerValue -> TxInfoInnerOutputsInner { txInfoInnerOutputsInnerValue, ..} ) <$> f txInfoInnerOutputsInnerValue
{-# INLINE txInfoInnerOutputsInnerValueL #-}

-- | 'txInfoInnerOutputsInnerDatumHash' Lens
txInfoInnerOutputsInnerDatumHashL :: Lens_' TxInfoInnerOutputsInner (Maybe Text)
txInfoInnerOutputsInnerDatumHashL f TxInfoInnerOutputsInner{..} = (\txInfoInnerOutputsInnerDatumHash -> TxInfoInnerOutputsInner { txInfoInnerOutputsInnerDatumHash, ..} ) <$> f txInfoInnerOutputsInnerDatumHash
{-# INLINE txInfoInnerOutputsInnerDatumHashL #-}

-- | 'txInfoInnerOutputsInnerInlineDatum' Lens
txInfoInnerOutputsInnerInlineDatumL :: Lens_' TxInfoInnerOutputsInner (Maybe TxInfoInnerOutputsInnerInlineDatum)
txInfoInnerOutputsInnerInlineDatumL f TxInfoInnerOutputsInner{..} = (\txInfoInnerOutputsInnerInlineDatum -> TxInfoInnerOutputsInner { txInfoInnerOutputsInnerInlineDatum, ..} ) <$> f txInfoInnerOutputsInnerInlineDatum
{-# INLINE txInfoInnerOutputsInnerInlineDatumL #-}

-- | 'txInfoInnerOutputsInnerReferenceScript' Lens
txInfoInnerOutputsInnerReferenceScriptL :: Lens_' TxInfoInnerOutputsInner (Maybe TxInfoInnerOutputsInnerReferenceScript)
txInfoInnerOutputsInnerReferenceScriptL f TxInfoInnerOutputsInner{..} = (\txInfoInnerOutputsInnerReferenceScript -> TxInfoInnerOutputsInner { txInfoInnerOutputsInnerReferenceScript, ..} ) <$> f txInfoInnerOutputsInnerReferenceScript
{-# INLINE txInfoInnerOutputsInnerReferenceScriptL #-}

-- | 'txInfoInnerOutputsInnerAssetList' Lens
txInfoInnerOutputsInnerAssetListL :: Lens_' TxInfoInnerOutputsInner (Maybe [TxInfoInnerOutputsInnerAssetListInner])
txInfoInnerOutputsInnerAssetListL f TxInfoInnerOutputsInner{..} = (\txInfoInnerOutputsInnerAssetList -> TxInfoInnerOutputsInner { txInfoInnerOutputsInnerAssetList, ..} ) <$> f txInfoInnerOutputsInnerAssetList
{-# INLINE txInfoInnerOutputsInnerAssetListL #-}



-- * TxInfoInnerOutputsInnerAssetListInner

-- | 'txInfoInnerOutputsInnerAssetListInnerPolicyId' Lens
txInfoInnerOutputsInnerAssetListInnerPolicyIdL :: Lens_' TxInfoInnerOutputsInnerAssetListInner (Maybe PolicyId)
txInfoInnerOutputsInnerAssetListInnerPolicyIdL f TxInfoInnerOutputsInnerAssetListInner{..} = (\txInfoInnerOutputsInnerAssetListInnerPolicyId -> TxInfoInnerOutputsInnerAssetListInner { txInfoInnerOutputsInnerAssetListInnerPolicyId, ..} ) <$> f txInfoInnerOutputsInnerAssetListInnerPolicyId
{-# INLINE txInfoInnerOutputsInnerAssetListInnerPolicyIdL #-}

-- | 'txInfoInnerOutputsInnerAssetListInnerAssetName' Lens
txInfoInnerOutputsInnerAssetListInnerAssetNameL :: Lens_' TxInfoInnerOutputsInnerAssetListInner (Maybe AssetName)
txInfoInnerOutputsInnerAssetListInnerAssetNameL f TxInfoInnerOutputsInnerAssetListInner{..} = (\txInfoInnerOutputsInnerAssetListInnerAssetName -> TxInfoInnerOutputsInnerAssetListInner { txInfoInnerOutputsInnerAssetListInnerAssetName, ..} ) <$> f txInfoInnerOutputsInnerAssetListInnerAssetName
{-# INLINE txInfoInnerOutputsInnerAssetListInnerAssetNameL #-}

-- | 'txInfoInnerOutputsInnerAssetListInnerQuantity' Lens
txInfoInnerOutputsInnerAssetListInnerQuantityL :: Lens_' TxInfoInnerOutputsInnerAssetListInner (Maybe Text)
txInfoInnerOutputsInnerAssetListInnerQuantityL f TxInfoInnerOutputsInnerAssetListInner{..} = (\txInfoInnerOutputsInnerAssetListInnerQuantity -> TxInfoInnerOutputsInnerAssetListInner { txInfoInnerOutputsInnerAssetListInnerQuantity, ..} ) <$> f txInfoInnerOutputsInnerAssetListInnerQuantity
{-# INLINE txInfoInnerOutputsInnerAssetListInnerQuantityL #-}

-- | 'txInfoInnerOutputsInnerAssetListInnerFingerprint' Lens
txInfoInnerOutputsInnerAssetListInnerFingerprintL :: Lens_' TxInfoInnerOutputsInnerAssetListInner (Maybe Fingerprint)
txInfoInnerOutputsInnerAssetListInnerFingerprintL f TxInfoInnerOutputsInnerAssetListInner{..} = (\txInfoInnerOutputsInnerAssetListInnerFingerprint -> TxInfoInnerOutputsInnerAssetListInner { txInfoInnerOutputsInnerAssetListInnerFingerprint, ..} ) <$> f txInfoInnerOutputsInnerAssetListInnerFingerprint
{-# INLINE txInfoInnerOutputsInnerAssetListInnerFingerprintL #-}



-- * TxInfoInnerOutputsInnerInlineDatum

-- | 'txInfoInnerOutputsInnerInlineDatumBytes' Lens
txInfoInnerOutputsInnerInlineDatumBytesL :: Lens_' TxInfoInnerOutputsInnerInlineDatum (Maybe Text)
txInfoInnerOutputsInnerInlineDatumBytesL f TxInfoInnerOutputsInnerInlineDatum{..} = (\txInfoInnerOutputsInnerInlineDatumBytes -> TxInfoInnerOutputsInnerInlineDatum { txInfoInnerOutputsInnerInlineDatumBytes, ..} ) <$> f txInfoInnerOutputsInnerInlineDatumBytes
{-# INLINE txInfoInnerOutputsInnerInlineDatumBytesL #-}

-- | 'txInfoInnerOutputsInnerInlineDatumValue' Lens
txInfoInnerOutputsInnerInlineDatumValueL :: Lens_' TxInfoInnerOutputsInnerInlineDatum (Maybe A.Value)
txInfoInnerOutputsInnerInlineDatumValueL f TxInfoInnerOutputsInnerInlineDatum{..} = (\txInfoInnerOutputsInnerInlineDatumValue -> TxInfoInnerOutputsInnerInlineDatum { txInfoInnerOutputsInnerInlineDatumValue, ..} ) <$> f txInfoInnerOutputsInnerInlineDatumValue
{-# INLINE txInfoInnerOutputsInnerInlineDatumValueL #-}



-- * TxInfoInnerOutputsInnerPaymentAddr

-- | 'txInfoInnerOutputsInnerPaymentAddrBech32' Lens
txInfoInnerOutputsInnerPaymentAddrBech32L :: Lens_' TxInfoInnerOutputsInnerPaymentAddr (Maybe Text)
txInfoInnerOutputsInnerPaymentAddrBech32L f TxInfoInnerOutputsInnerPaymentAddr{..} = (\txInfoInnerOutputsInnerPaymentAddrBech32 -> TxInfoInnerOutputsInnerPaymentAddr { txInfoInnerOutputsInnerPaymentAddrBech32, ..} ) <$> f txInfoInnerOutputsInnerPaymentAddrBech32
{-# INLINE txInfoInnerOutputsInnerPaymentAddrBech32L #-}

-- | 'txInfoInnerOutputsInnerPaymentAddrCred' Lens
txInfoInnerOutputsInnerPaymentAddrCredL :: Lens_' TxInfoInnerOutputsInnerPaymentAddr (Maybe Text)
txInfoInnerOutputsInnerPaymentAddrCredL f TxInfoInnerOutputsInnerPaymentAddr{..} = (\txInfoInnerOutputsInnerPaymentAddrCred -> TxInfoInnerOutputsInnerPaymentAddr { txInfoInnerOutputsInnerPaymentAddrCred, ..} ) <$> f txInfoInnerOutputsInnerPaymentAddrCred
{-# INLINE txInfoInnerOutputsInnerPaymentAddrCredL #-}



-- * TxInfoInnerOutputsInnerReferenceScript

-- | 'txInfoInnerOutputsInnerReferenceScriptHash' Lens
txInfoInnerOutputsInnerReferenceScriptHashL :: Lens_' TxInfoInnerOutputsInnerReferenceScript (Maybe Text)
txInfoInnerOutputsInnerReferenceScriptHashL f TxInfoInnerOutputsInnerReferenceScript{..} = (\txInfoInnerOutputsInnerReferenceScriptHash -> TxInfoInnerOutputsInnerReferenceScript { txInfoInnerOutputsInnerReferenceScriptHash, ..} ) <$> f txInfoInnerOutputsInnerReferenceScriptHash
{-# INLINE txInfoInnerOutputsInnerReferenceScriptHashL #-}

-- | 'txInfoInnerOutputsInnerReferenceScriptSize' Lens
txInfoInnerOutputsInnerReferenceScriptSizeL :: Lens_' TxInfoInnerOutputsInnerReferenceScript (Maybe Int)
txInfoInnerOutputsInnerReferenceScriptSizeL f TxInfoInnerOutputsInnerReferenceScript{..} = (\txInfoInnerOutputsInnerReferenceScriptSize -> TxInfoInnerOutputsInnerReferenceScript { txInfoInnerOutputsInnerReferenceScriptSize, ..} ) <$> f txInfoInnerOutputsInnerReferenceScriptSize
{-# INLINE txInfoInnerOutputsInnerReferenceScriptSizeL #-}

-- | 'txInfoInnerOutputsInnerReferenceScriptType' Lens
txInfoInnerOutputsInnerReferenceScriptTypeL :: Lens_' TxInfoInnerOutputsInnerReferenceScript (Maybe Text)
txInfoInnerOutputsInnerReferenceScriptTypeL f TxInfoInnerOutputsInnerReferenceScript{..} = (\txInfoInnerOutputsInnerReferenceScriptType -> TxInfoInnerOutputsInnerReferenceScript { txInfoInnerOutputsInnerReferenceScriptType, ..} ) <$> f txInfoInnerOutputsInnerReferenceScriptType
{-# INLINE txInfoInnerOutputsInnerReferenceScriptTypeL #-}

-- | 'txInfoInnerOutputsInnerReferenceScriptBytes' Lens
txInfoInnerOutputsInnerReferenceScriptBytesL :: Lens_' TxInfoInnerOutputsInnerReferenceScript (Maybe Text)
txInfoInnerOutputsInnerReferenceScriptBytesL f TxInfoInnerOutputsInnerReferenceScript{..} = (\txInfoInnerOutputsInnerReferenceScriptBytes -> TxInfoInnerOutputsInnerReferenceScript { txInfoInnerOutputsInnerReferenceScriptBytes, ..} ) <$> f txInfoInnerOutputsInnerReferenceScriptBytes
{-# INLINE txInfoInnerOutputsInnerReferenceScriptBytesL #-}

-- | 'txInfoInnerOutputsInnerReferenceScriptValue' Lens
txInfoInnerOutputsInnerReferenceScriptValueL :: Lens_' TxInfoInnerOutputsInnerReferenceScript (Maybe A.Value)
txInfoInnerOutputsInnerReferenceScriptValueL f TxInfoInnerOutputsInnerReferenceScript{..} = (\txInfoInnerOutputsInnerReferenceScriptValue -> TxInfoInnerOutputsInnerReferenceScript { txInfoInnerOutputsInnerReferenceScriptValue, ..} ) <$> f txInfoInnerOutputsInnerReferenceScriptValue
{-# INLINE txInfoInnerOutputsInnerReferenceScriptValueL #-}



-- * TxInfoInnerPlutusContractsInner

-- | 'txInfoInnerPlutusContractsInnerAddress' Lens
txInfoInnerPlutusContractsInnerAddressL :: Lens_' TxInfoInnerPlutusContractsInner (Maybe Text)
txInfoInnerPlutusContractsInnerAddressL f TxInfoInnerPlutusContractsInner{..} = (\txInfoInnerPlutusContractsInnerAddress -> TxInfoInnerPlutusContractsInner { txInfoInnerPlutusContractsInnerAddress, ..} ) <$> f txInfoInnerPlutusContractsInnerAddress
{-# INLINE txInfoInnerPlutusContractsInnerAddressL #-}

-- | 'txInfoInnerPlutusContractsInnerScriptHash' Lens
txInfoInnerPlutusContractsInnerScriptHashL :: Lens_' TxInfoInnerPlutusContractsInner (Maybe ScriptHash)
txInfoInnerPlutusContractsInnerScriptHashL f TxInfoInnerPlutusContractsInner{..} = (\txInfoInnerPlutusContractsInnerScriptHash -> TxInfoInnerPlutusContractsInner { txInfoInnerPlutusContractsInnerScriptHash, ..} ) <$> f txInfoInnerPlutusContractsInnerScriptHash
{-# INLINE txInfoInnerPlutusContractsInnerScriptHashL #-}

-- | 'txInfoInnerPlutusContractsInnerBytecode' Lens
txInfoInnerPlutusContractsInnerBytecodeL :: Lens_' TxInfoInnerPlutusContractsInner (Maybe Text)
txInfoInnerPlutusContractsInnerBytecodeL f TxInfoInnerPlutusContractsInner{..} = (\txInfoInnerPlutusContractsInnerBytecode -> TxInfoInnerPlutusContractsInner { txInfoInnerPlutusContractsInnerBytecode, ..} ) <$> f txInfoInnerPlutusContractsInnerBytecode
{-# INLINE txInfoInnerPlutusContractsInnerBytecodeL #-}

-- | 'txInfoInnerPlutusContractsInnerSize' Lens
txInfoInnerPlutusContractsInnerSizeL :: Lens_' TxInfoInnerPlutusContractsInner (Maybe Int)
txInfoInnerPlutusContractsInnerSizeL f TxInfoInnerPlutusContractsInner{..} = (\txInfoInnerPlutusContractsInnerSize -> TxInfoInnerPlutusContractsInner { txInfoInnerPlutusContractsInnerSize, ..} ) <$> f txInfoInnerPlutusContractsInnerSize
{-# INLINE txInfoInnerPlutusContractsInnerSizeL #-}

-- | 'txInfoInnerPlutusContractsInnerValidContract' Lens
txInfoInnerPlutusContractsInnerValidContractL :: Lens_' TxInfoInnerPlutusContractsInner (Maybe Bool)
txInfoInnerPlutusContractsInnerValidContractL f TxInfoInnerPlutusContractsInner{..} = (\txInfoInnerPlutusContractsInnerValidContract -> TxInfoInnerPlutusContractsInner { txInfoInnerPlutusContractsInnerValidContract, ..} ) <$> f txInfoInnerPlutusContractsInnerValidContract
{-# INLINE txInfoInnerPlutusContractsInnerValidContractL #-}

-- | 'txInfoInnerPlutusContractsInnerInput' Lens
txInfoInnerPlutusContractsInnerInputL :: Lens_' TxInfoInnerPlutusContractsInner (Maybe TxInfoInnerPlutusContractsInnerInput)
txInfoInnerPlutusContractsInnerInputL f TxInfoInnerPlutusContractsInner{..} = (\txInfoInnerPlutusContractsInnerInput -> TxInfoInnerPlutusContractsInner { txInfoInnerPlutusContractsInnerInput, ..} ) <$> f txInfoInnerPlutusContractsInnerInput
{-# INLINE txInfoInnerPlutusContractsInnerInputL #-}

-- | 'txInfoInnerPlutusContractsInnerOutput' Lens
txInfoInnerPlutusContractsInnerOutputL :: Lens_' TxInfoInnerPlutusContractsInner (Maybe TxInfoInnerPlutusContractsInnerInputRedeemerDatum)
txInfoInnerPlutusContractsInnerOutputL f TxInfoInnerPlutusContractsInner{..} = (\txInfoInnerPlutusContractsInnerOutput -> TxInfoInnerPlutusContractsInner { txInfoInnerPlutusContractsInnerOutput, ..} ) <$> f txInfoInnerPlutusContractsInnerOutput
{-# INLINE txInfoInnerPlutusContractsInnerOutputL #-}



-- * TxInfoInnerPlutusContractsInnerInput

-- | 'txInfoInnerPlutusContractsInnerInputRedeemer' Lens
txInfoInnerPlutusContractsInnerInputRedeemerL :: Lens_' TxInfoInnerPlutusContractsInnerInput (Maybe TxInfoInnerPlutusContractsInnerInputRedeemer)
txInfoInnerPlutusContractsInnerInputRedeemerL f TxInfoInnerPlutusContractsInnerInput{..} = (\txInfoInnerPlutusContractsInnerInputRedeemer -> TxInfoInnerPlutusContractsInnerInput { txInfoInnerPlutusContractsInnerInputRedeemer, ..} ) <$> f txInfoInnerPlutusContractsInnerInputRedeemer
{-# INLINE txInfoInnerPlutusContractsInnerInputRedeemerL #-}

-- | 'txInfoInnerPlutusContractsInnerInputDatum' Lens
txInfoInnerPlutusContractsInnerInputDatumL :: Lens_' TxInfoInnerPlutusContractsInnerInput (Maybe TxInfoInnerPlutusContractsInnerInputRedeemerDatum)
txInfoInnerPlutusContractsInnerInputDatumL f TxInfoInnerPlutusContractsInnerInput{..} = (\txInfoInnerPlutusContractsInnerInputDatum -> TxInfoInnerPlutusContractsInnerInput { txInfoInnerPlutusContractsInnerInputDatum, ..} ) <$> f txInfoInnerPlutusContractsInnerInputDatum
{-# INLINE txInfoInnerPlutusContractsInnerInputDatumL #-}



-- * TxInfoInnerPlutusContractsInnerInputRedeemer

-- | 'txInfoInnerPlutusContractsInnerInputRedeemerPurpose' Lens
txInfoInnerPlutusContractsInnerInputRedeemerPurposeL :: Lens_' TxInfoInnerPlutusContractsInnerInputRedeemer (Maybe Purpose)
txInfoInnerPlutusContractsInnerInputRedeemerPurposeL f TxInfoInnerPlutusContractsInnerInputRedeemer{..} = (\txInfoInnerPlutusContractsInnerInputRedeemerPurpose -> TxInfoInnerPlutusContractsInnerInputRedeemer { txInfoInnerPlutusContractsInnerInputRedeemerPurpose, ..} ) <$> f txInfoInnerPlutusContractsInnerInputRedeemerPurpose
{-# INLINE txInfoInnerPlutusContractsInnerInputRedeemerPurposeL #-}

-- | 'txInfoInnerPlutusContractsInnerInputRedeemerFee' Lens
txInfoInnerPlutusContractsInnerInputRedeemerFeeL :: Lens_' TxInfoInnerPlutusContractsInnerInputRedeemer (Maybe Fee)
txInfoInnerPlutusContractsInnerInputRedeemerFeeL f TxInfoInnerPlutusContractsInnerInputRedeemer{..} = (\txInfoInnerPlutusContractsInnerInputRedeemerFee -> TxInfoInnerPlutusContractsInnerInputRedeemer { txInfoInnerPlutusContractsInnerInputRedeemerFee, ..} ) <$> f txInfoInnerPlutusContractsInnerInputRedeemerFee
{-# INLINE txInfoInnerPlutusContractsInnerInputRedeemerFeeL #-}

-- | 'txInfoInnerPlutusContractsInnerInputRedeemerUnit' Lens
txInfoInnerPlutusContractsInnerInputRedeemerUnitL :: Lens_' TxInfoInnerPlutusContractsInnerInputRedeemer (Maybe TxInfoInnerPlutusContractsInnerInputRedeemerUnit)
txInfoInnerPlutusContractsInnerInputRedeemerUnitL f TxInfoInnerPlutusContractsInnerInputRedeemer{..} = (\txInfoInnerPlutusContractsInnerInputRedeemerUnit -> TxInfoInnerPlutusContractsInnerInputRedeemer { txInfoInnerPlutusContractsInnerInputRedeemerUnit, ..} ) <$> f txInfoInnerPlutusContractsInnerInputRedeemerUnit
{-# INLINE txInfoInnerPlutusContractsInnerInputRedeemerUnitL #-}

-- | 'txInfoInnerPlutusContractsInnerInputRedeemerDatum' Lens
txInfoInnerPlutusContractsInnerInputRedeemerDatumL :: Lens_' TxInfoInnerPlutusContractsInnerInputRedeemer (Maybe TxInfoInnerPlutusContractsInnerInputRedeemerDatum)
txInfoInnerPlutusContractsInnerInputRedeemerDatumL f TxInfoInnerPlutusContractsInnerInputRedeemer{..} = (\txInfoInnerPlutusContractsInnerInputRedeemerDatum -> TxInfoInnerPlutusContractsInnerInputRedeemer { txInfoInnerPlutusContractsInnerInputRedeemerDatum, ..} ) <$> f txInfoInnerPlutusContractsInnerInputRedeemerDatum
{-# INLINE txInfoInnerPlutusContractsInnerInputRedeemerDatumL #-}



-- * TxInfoInnerPlutusContractsInnerInputRedeemerDatum

-- | 'txInfoInnerPlutusContractsInnerInputRedeemerDatumHash' Lens
txInfoInnerPlutusContractsInnerInputRedeemerDatumHashL :: Lens_' TxInfoInnerPlutusContractsInnerInputRedeemerDatum (Maybe DatumHash)
txInfoInnerPlutusContractsInnerInputRedeemerDatumHashL f TxInfoInnerPlutusContractsInnerInputRedeemerDatum{..} = (\txInfoInnerPlutusContractsInnerInputRedeemerDatumHash -> TxInfoInnerPlutusContractsInnerInputRedeemerDatum { txInfoInnerPlutusContractsInnerInputRedeemerDatumHash, ..} ) <$> f txInfoInnerPlutusContractsInnerInputRedeemerDatumHash
{-# INLINE txInfoInnerPlutusContractsInnerInputRedeemerDatumHashL #-}

-- | 'txInfoInnerPlutusContractsInnerInputRedeemerDatumValue' Lens
txInfoInnerPlutusContractsInnerInputRedeemerDatumValueL :: Lens_' TxInfoInnerPlutusContractsInnerInputRedeemerDatum (Maybe DatumValue)
txInfoInnerPlutusContractsInnerInputRedeemerDatumValueL f TxInfoInnerPlutusContractsInnerInputRedeemerDatum{..} = (\txInfoInnerPlutusContractsInnerInputRedeemerDatumValue -> TxInfoInnerPlutusContractsInnerInputRedeemerDatum { txInfoInnerPlutusContractsInnerInputRedeemerDatumValue, ..} ) <$> f txInfoInnerPlutusContractsInnerInputRedeemerDatumValue
{-# INLINE txInfoInnerPlutusContractsInnerInputRedeemerDatumValueL #-}



-- * TxInfoInnerPlutusContractsInnerInputRedeemerUnit

-- | 'txInfoInnerPlutusContractsInnerInputRedeemerUnitSteps' Lens
txInfoInnerPlutusContractsInnerInputRedeemerUnitStepsL :: Lens_' TxInfoInnerPlutusContractsInnerInputRedeemerUnit (Maybe UnitSteps)
txInfoInnerPlutusContractsInnerInputRedeemerUnitStepsL f TxInfoInnerPlutusContractsInnerInputRedeemerUnit{..} = (\txInfoInnerPlutusContractsInnerInputRedeemerUnitSteps -> TxInfoInnerPlutusContractsInnerInputRedeemerUnit { txInfoInnerPlutusContractsInnerInputRedeemerUnitSteps, ..} ) <$> f txInfoInnerPlutusContractsInnerInputRedeemerUnitSteps
{-# INLINE txInfoInnerPlutusContractsInnerInputRedeemerUnitStepsL #-}

-- | 'txInfoInnerPlutusContractsInnerInputRedeemerUnitMem' Lens
txInfoInnerPlutusContractsInnerInputRedeemerUnitMemL :: Lens_' TxInfoInnerPlutusContractsInnerInputRedeemerUnit (Maybe UnitMem)
txInfoInnerPlutusContractsInnerInputRedeemerUnitMemL f TxInfoInnerPlutusContractsInnerInputRedeemerUnit{..} = (\txInfoInnerPlutusContractsInnerInputRedeemerUnitMem -> TxInfoInnerPlutusContractsInnerInputRedeemerUnit { txInfoInnerPlutusContractsInnerInputRedeemerUnitMem, ..} ) <$> f txInfoInnerPlutusContractsInnerInputRedeemerUnitMem
{-# INLINE txInfoInnerPlutusContractsInnerInputRedeemerUnitMemL #-}



-- * TxInfoInnerWithdrawalsInner

-- | 'txInfoInnerWithdrawalsInnerAmount' Lens
txInfoInnerWithdrawalsInnerAmountL :: Lens_' TxInfoInnerWithdrawalsInner (Maybe Text)
txInfoInnerWithdrawalsInnerAmountL f TxInfoInnerWithdrawalsInner{..} = (\txInfoInnerWithdrawalsInnerAmount -> TxInfoInnerWithdrawalsInner { txInfoInnerWithdrawalsInnerAmount, ..} ) <$> f txInfoInnerWithdrawalsInnerAmount
{-# INLINE txInfoInnerWithdrawalsInnerAmountL #-}

-- | 'txInfoInnerWithdrawalsInnerStakeAddr' Lens
txInfoInnerWithdrawalsInnerStakeAddrL :: Lens_' TxInfoInnerWithdrawalsInner (Maybe TxInfoInnerWithdrawalsInnerStakeAddr)
txInfoInnerWithdrawalsInnerStakeAddrL f TxInfoInnerWithdrawalsInner{..} = (\txInfoInnerWithdrawalsInnerStakeAddr -> TxInfoInnerWithdrawalsInner { txInfoInnerWithdrawalsInnerStakeAddr, ..} ) <$> f txInfoInnerWithdrawalsInnerStakeAddr
{-# INLINE txInfoInnerWithdrawalsInnerStakeAddrL #-}



-- * TxInfoInnerWithdrawalsInnerStakeAddr

-- | 'txInfoInnerWithdrawalsInnerStakeAddrBech32' Lens
txInfoInnerWithdrawalsInnerStakeAddrBech32L :: Lens_' TxInfoInnerWithdrawalsInnerStakeAddr (Maybe Text)
txInfoInnerWithdrawalsInnerStakeAddrBech32L f TxInfoInnerWithdrawalsInnerStakeAddr{..} = (\txInfoInnerWithdrawalsInnerStakeAddrBech32 -> TxInfoInnerWithdrawalsInnerStakeAddr { txInfoInnerWithdrawalsInnerStakeAddrBech32, ..} ) <$> f txInfoInnerWithdrawalsInnerStakeAddrBech32
{-# INLINE txInfoInnerWithdrawalsInnerStakeAddrBech32L #-}



-- * TxInfoPostRequest

-- | 'txInfoPostRequestTxHashes' Lens
txInfoPostRequestTxHashesL :: Lens_' TxInfoPostRequest ([Text])
txInfoPostRequestTxHashesL f TxInfoPostRequest{..} = (\txInfoPostRequestTxHashes -> TxInfoPostRequest { txInfoPostRequestTxHashes, ..} ) <$> f txInfoPostRequestTxHashes
{-# INLINE txInfoPostRequestTxHashesL #-}



-- * TxMetadataInner

-- | 'txMetadataInnerTxHash' Lens
txMetadataInnerTxHashL :: Lens_' TxMetadataInner (Maybe TxHash)
txMetadataInnerTxHashL f TxMetadataInner{..} = (\txMetadataInnerTxHash -> TxMetadataInner { txMetadataInnerTxHash, ..} ) <$> f txMetadataInnerTxHash
{-# INLINE txMetadataInnerTxHashL #-}

-- | 'txMetadataInnerMetadata' Lens
txMetadataInnerMetadataL :: Lens_' TxMetadataInner (Maybe A.Value)
txMetadataInnerMetadataL f TxMetadataInner{..} = (\txMetadataInnerMetadata -> TxMetadataInner { txMetadataInnerMetadata, ..} ) <$> f txMetadataInnerMetadata
{-# INLINE txMetadataInnerMetadataL #-}



-- * TxMetalabelsInner

-- | 'txMetalabelsInnerKey' Lens
txMetalabelsInnerKeyL :: Lens_' TxMetalabelsInner (Maybe Text)
txMetalabelsInnerKeyL f TxMetalabelsInner{..} = (\txMetalabelsInnerKey -> TxMetalabelsInner { txMetalabelsInnerKey, ..} ) <$> f txMetalabelsInnerKey
{-# INLINE txMetalabelsInnerKeyL #-}



-- * TxStatusInner

-- | 'txStatusInnerTxHash' Lens
txStatusInnerTxHashL :: Lens_' TxStatusInner (Maybe TxHash)
txStatusInnerTxHashL f TxStatusInner{..} = (\txStatusInnerTxHash -> TxStatusInner { txStatusInnerTxHash, ..} ) <$> f txStatusInnerTxHash
{-# INLINE txStatusInnerTxHashL #-}

-- | 'txStatusInnerNumConfirmations' Lens
txStatusInnerNumConfirmationsL :: Lens_' TxStatusInner (Maybe Int)
txStatusInnerNumConfirmationsL f TxStatusInner{..} = (\txStatusInnerNumConfirmations -> TxStatusInner { txStatusInnerNumConfirmations, ..} ) <$> f txStatusInnerNumConfirmations
{-# INLINE txStatusInnerNumConfirmationsL #-}



-- * TxUtxosInner

-- | 'txUtxosInnerTxHash' Lens
txUtxosInnerTxHashL :: Lens_' TxUtxosInner (Maybe TxHash)
txUtxosInnerTxHashL f TxUtxosInner{..} = (\txUtxosInnerTxHash -> TxUtxosInner { txUtxosInnerTxHash, ..} ) <$> f txUtxosInnerTxHash
{-# INLINE txUtxosInnerTxHashL #-}

-- | 'txUtxosInnerInputs' Lens
txUtxosInnerInputsL :: Lens_' TxUtxosInner (Maybe Inputs)
txUtxosInnerInputsL f TxUtxosInner{..} = (\txUtxosInnerInputs -> TxUtxosInner { txUtxosInnerInputs, ..} ) <$> f txUtxosInnerInputs
{-# INLINE txUtxosInnerInputsL #-}

-- | 'txUtxosInnerOutputs' Lens
txUtxosInnerOutputsL :: Lens_' TxUtxosInner (Maybe Outputs)
txUtxosInnerOutputsL f TxUtxosInner{..} = (\txUtxosInnerOutputs -> TxUtxosInner { txUtxosInnerOutputs, ..} ) <$> f txUtxosInnerOutputs
{-# INLINE txUtxosInnerOutputsL #-}


