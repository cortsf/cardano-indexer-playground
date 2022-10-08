{-
   Koios API

   Koios is best described as a Decentralized and Elastic RESTful query layer for exploring data on Cardano blockchain to consume within applications/wallets/explorers/etc.  > Note: While we've done sufficient ground work - we're still going through testing/learning/adapting phase based on feedback. Feel free to give it a go, but just remember it is not yet finalized for production consumption and will be refreshed weekly (Saturday 8am UTC).  # Problems solved by Koios - As the size of blockchain grows rapidly, we're looking at increasingly expensive resources and maintenance costs (financially as well as time-wise) to maintain a scalable solution that will automatically failover and have health-checks, ensuring most synched versions are returned. With Koios, anyone is free to either add their backend instance to the cluster, or use the query layer without running a node or cardano-db-sync instance themselves. There will be health-checks for each endpoint to ensure that connections do not go to a dud backend with stale information. - Moreover, folks who do put in tremendous amount of efforts to go through discovery phrase - are often ending up with local solutions, that may not be consistent across the board (e.g. Live Stake queries across existing explorers). Since all the queries used by/for Koios layer is on GitHub, anyone can contribute or leverage the query knowledge base, and help each other out while doing so. An additional endpoint added will only be load balanced between the servers that pass the health-check for the endpoint. - It is almost impossible to fetch some live data (for example, Live Stake against a pool) due to the cost of computation and amount of data on chain. For  such queries, many folks are already using different cache methods, or capturing ledger information from node. Wouldn't it be nice to have these crunched data that take quite a few minutes to run be shared and available to be able to pick a relatively recent execution across the nodes? This will be available out of the box as part of Koios API. - There is also a worry when going through updates about feasibility/breaking changes/etc. that can become a bottleneck for providers. Since Koios participants automatically receive failover support, they reduce impact of any subset of clusters going through update process. - The lightweight query layers currently present are unfortunately closed source, centralised, and create a single point of failure. With Koios, our aim is to give enough flexibility to all the participants to select their backend, or pick from any of the available ones instead. - Bad human errors causing an outage? The bandwidth for Koios becomes better with more participation, but just in case there is not enough participation - we will ensure that at least 4 trusted Koios instances across the globe will be around for the initial year, allowing for enough time for adoption to build up gradually. - Flexibility to participate at different levels. A consumer of these services can participate with a complete independent instance (optionally extend existing ones), by running only certain parts (e.g. submit-api or PostgREST only), or simply consuming the API without running anything locally.  # Architecture  ## How does Koios work?  ![High-Level architecture overview](/koios-design.png)  We will go bottom to top (from builder's eyes to run through the above) briefly:  - *Instance(s)* : These are essentially [PostgREST](https://postgrest.org/en/latest/) instances with the REST service attached to Postgres DB populated using [cardano-db-sync](https://cardano-community.github.io/guild-operators/Build/dbsync/). Every consumer who is providing their own instance will be expected to serve at least a PostgREST instance, as this is what allows us to string instances together after health-checks. If using guild-operator setup instructions, these will be provisioned for you by setup scripts. - *Health-check Services* : These are lightweight [HAProxy](http://www.haproxy.org) instances that will be gatekeepers for individual endpoints, handling health-checks, sample data verification, etc. A builder _may_ opt-in to run this monitoring service, and add their instance to GitHub repository. Again, setting up HAProxy will be part of setup scripts on guild-operator's repo for those interested. - *DNS Routing* : These will be the entry points from monitoring layer to trusted instances that will route to health-check proxy services. We will be using at least two DNS servers ourselves to not have single point of failure, but that does not limit users to elect any of the other server endpoints instead, since the API works right from the PostgREST layer itself.  # API Usage  The endpoints served by Koios can be browsed from the left side bar of this site. You will find that almost each endpoint has an example that you can `Try` and will help you get an example in shell using cURL. For public queries, you do not need to register yourself - you can simply use them as per the examples provided on individual endpoints. But in addition, the [PostgREST API](https://postgrest.org/en/stable/api.html) used underneath provides a handful of features that can be quite handy for you to improve your queries to directly grab very specific information pertinent to your calls, reducing data you download and process.  ## Vertical Filtering  Instead of returning entire row, you can elect which rows you would like to fetch from the endpoint by using the `select` parameter with corresponding columns separated by commas. See example below (first is complete information for tip, while second command gives us 3 columns we are interested in):<br><br>  ``` bash curl \"https://api.koios.rest/api/v0/tip\"  # [{\"hash\":\"4d44c8a453e677f933c3df42ebcf2fe45987c41268b9cfc9b42ae305e8c3d99a\",\"epoch\":317,\"abs_slot\":51700871,\"epoch_slot\":120071,\"block_height\":6806994,\"block_time\":1643267162}]  curl \"https://api.koios.rest/api/v0/blocks?select=epoch,epoch_slot,block_height\"  # [{\"epoch\":317,\"epoch_slot\":120071,\"block_height\":6806994}] ```  ## Horizontal Filtering  You can filter the returned output based on specific conditions using operators against a column within returned result. Consider an example where you would want to query blocks minted in first 3 minutes of epoch 250 (i.e. epoch_slot was less than 180). To do so your query would look like below:<br><br> ``` bash curl \"https://api.koios.rest/api/v0/blocks?epoch=eq.250&epoch_slot=lt.180\"  # [{\"hash\":\"8fad2808ac6b37064a0fa69f6fe065807703d5235a57442647bbcdba1c02faf8\",\"epoch\":250,\"abs_slot\":22636942,\"epoch_slot\":142,\"block_height\":5385757,\"block_time\":1614203233,\"tx_count\":65,\"vrf_key\":\"vrf_vk14y9pjprzlsjvjt66mv5u7w7292sxp3kn4ewhss45ayjga5vurgaqhqknuu\",\"pool\":null,\"op_cert_counter\":2}, #  {\"hash\":\"9d33b02badaedc0dedd0d59f3e0411e5fb4ac94217fb5ee86719e8463c570e16\",\"epoch\":250,\"abs_slot\":22636800,\"epoch_slot\":0,\"block_height\":5385756,\"block_time\":1614203091,\"tx_count\":10,\"vrf_key\":\"vrf_vk1dkfsejw3h2k7tnguwrauqfwnxa7wj3nkp3yw2yw3400c4nlkluwqzwvka6\",\"pool\":null,\"op_cert_counter\":2}] ```  Here, we made use of `eq.` operator to denote a filter of \"value equal to\" against `epoch` column. Similarly, we added a filter using `lt.` operator to denote a filter of \"values lower than\" against `epoch_slot` column. You can find a complete list of operators supported in PostgREST documentation (commonly used ones extracted below):  |Abbreviation|In PostgreSQL|Meaning                                    | |------------|-------------|-------------------------------------------| |eq          |`=`          |equals                                     | |gt          |`>`          |greater than                               | |gte         |`>=`         |greater than or equal                      | |lt          |`<`          |less than                                  | |lte         |`<=`         |less than or equal                         | |neq         |`<>` or `!=` |not equal                                  | |like        |`LIKE`       |LIKE operator (use * in place of %)        | |in          |`IN`         |one of a list of values, e.g. `?a=in.(\"hi,there\",\"yes,you\")`| |is          |`IS`         |checking for exact equality (null,true,false,unknown)| |cs          |`@>`         |contains e.g. `?tags=cs.{example, new}`    | |cd          |`<@`         |contained in e.g. `?values=cd.{1,2,3}`     | |not         |`NOT`        |negates another operator                   | |or          |`OR`         |logical `OR` operator                      | |and         |`AND`        |logical `AND` operator                     |  ## Pagination (offset/limit)  When you query any endpoint in PostgREST, the number of observations returned will be limited to a maximum of 1000 rows (set via `max-rows` config option in the `grest.conf` file. This - however - is a result of a paginated call, wherein the [ up to ] 1000 records you see without any parameters is the first page. If you want to see the next 1000 results, you can always append `offset=1000` to view the next set of results. But what if 1000 is too high for your use-case and you want smaller page? Well, you can specify a smaller limit using parameter `limit`, which will see shortly in an example below. The obvious question at this point that would cross your mind is - how do I know if I need to offset and what range I am querying? This is where headers come in to your aid.    The default headers returned by PostgREST will include a `Content-Range` field giving a range of observations returned. For large tables, this range could include a wildcard `*` as it is expensive to query exact count of observations from endpoint. But if you would like to get an estimate count without overloading servers, PostgREST can utilise Postgres's own maintenance thread results (which maintain stats for each table) to provide you a count, by specifying a header `\"Profile: count=estimated\"`.    Sounds confusing? Let's see this in practice, to hopefully make it easier. Consider a simple case where I want query `blocks` endpoint for `block_height` column and focus on `content-range` header to monitor the rows we discussed above.<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=block_height\" -I | grep -i content-range  # content-range: 0-999/*  ```  As we can see above, the number of observations returned was 1000 (range being 0-999), but the total size was not queried to avoid wait times. Now, let's modify this default behaviour to query rows beyond the first 999, but this time - also add another clause to limit results by 500. We can do this using `offset=1000` and `limit=500` as below:<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=block_height&offset=1000&limit=500\" -I | grep -i content-range  # content-range: 1000-1499/*  ```  There is also another method to achieve the above, instead of adding parameters to the URL itself, you can specify a `Range` header as below to achieve something similar:<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=block_height\" -H \"Range: 1000-1499\" -I | grep -i content-range  # content-range: 1000-1499/*  ```  The above methods for pagination are very useful to keep your queries light as well as process the output in smaller pages, making better use of your resources and respecting server timeouts for response times.  ## Ordering  You can set a sorting order for returned queries against specific column(s). Consider example where you want to check `epoch` and `epoch_slot` for the first 5 blocks created by a particular pool, i.e. you can set order to ascending based on block_height column and add horizontal filter for that pool ID as below:<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?pool=eq.pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc&order=block_height.asc&limit=5\"  # [{\"hash\":\"610b4c7bbebeeb212bd002885048cc33154ba29f39919d62a3d96de05d315706\",\"epoch\":236,\"abs_slot\":16594295,\"epoch_slot\":5495,\"block_height\":5086774,\"block_time\":1608160586,\"tx_count\":1,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"d93d1db5275329ab695d30c06a35124038d8d9af64fc2b0aa082b8aa43da4164\",\"epoch\":236,\"abs_slot\":16597729,\"epoch_slot\":8929,\"block_height\":5086944,\"block_time\":1608164020,\"tx_count\":7,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"dc9496eae64294b46f07eb20499ae6dae4d81fdc67c63c354397db91bda1ee55\",\"epoch\":236,\"abs_slot\":16598058,\"epoch_slot\":9258,\"block_height\":5086962,\"block_time\":1608164349,\"tx_count\":1,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"6ebc7b734c513bc19290d96ca573a09cac9503c5a349dd9892b9ab43f917f9bd\",\"epoch\":236,\"abs_slot\":16601491,\"epoch_slot\":12691,\"block_height\":5087097,\"block_time\":1608167782,\"tx_count\":0,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}, # {\"hash\":\"2eac97548829fc312858bc56a40f7ce3bf9b0ca27ee8530283ccebb3963de1c0\",\"epoch\":236,\"abs_slot\":16602308,\"epoch_slot\":13508,\"block_height\":5087136,\"block_time\":1608168599,\"tx_count\":1,\"vrf_key\":\"vrf_vk18x0e7dx8j37gdxftnn8ru6jcxs7n6acdazc4ykeda2ygjwg9a7ls7ns699\",\"pool\":\"pool155efqn9xpcf73pphkk88cmlkdwx4ulkg606tne970qswczg3asc\",\"op_cert_counter\":1}] ```  ## Response Formats  You can get the results from the PostgREST endpoints in CSV or JSON formats. The default response format will always be JSON, but if you'd like to switch, you can do so by specifying header `'Accept: text/csv'` or `'Accept: application/json'`. Below is an example of JSON/CSV output making use of above to print first in JSON (default), and then override response format to CSV.<br><br>  ``` bash curl -s \"https://api.koios.rest/api/v0/blocks?select=epoch,epoch_slot,block_time&limit=3\"  # [{\"epoch\":318,\"epoch_slot\":27867,\"block_time\":1643606958}, # {\"epoch\":318,\"epoch_slot\":27841,\"block_time\":1643606932}, # {\"epoch\":318,\"epoch_slot\":27839,\"block_time\":1643606930}]  curl -s \"https://api.koios.rest/api/v0/blocks?select=epoch,epoch_slot,block_time&limit=3\" -H \"Accept: text/csv\"  # epoch,epoch_slot,block_time # 318,28491,1643607582 # 318,28479,1643607570 # 318,28406,1643607497  ```  ## Limits  While use of Koios is completely free and there are no registration requirements to the usage, the monitoring layer will only restrict spam requests that can potentially cause high amount of load to backends. The emphasis is on using list of objects first, and then [bulk where available] query specific objects to drill down where possible - which forms higher performance results to consumer as well as instance provider. Some basic protection against patterns that could cause unexpected resource spikes are protected as per below:    - Burst Limit: A single IP can query an endpoint up to 100 times within 10 seconds (that's about 8.64 million requests within a day). The sleep time if a limit is crossed is minimal (60 seconds) for that IP - during which, the monitoring layer will return HTTP Status `429 - Too many requests`.     - Pagination/Limits: Any query results fetched will be paginated by 1000 records (you can reduce limit and or control pagination offsets on URL itself, see API > Pagination section for more details).   - Query timeout: If a query from server takes more than 30 seconds, it will return a HTTP Status of `504 - Gateway timeout`. This is because we would want to ensure you're using the queries optimally, and more often than not - it would indicate that particular endpoint is not optimised (or the network connectivity is not optimal between servers).  Yet, there may be cases where the above restrictions may need exceptions (for example, an explorer or a wallet might need more connections than above - going beyond the Burst Limit). For such cases, it is best to approach the team and we can work towards a solution.   # Community projects  A big thank you to the following projects who are already starting to use Koios from early days:  ## CLI    - [Koios CLI in GoLang](https://github.com/cardano-community/koios-cli)  ## Libraries    - [.Net SDK](https://github.com/CardanoSharp/cardanosharp-koios)   - [Go Client](https://github.com/cardano-community/koios-go-client)   - [Java Client](https://github.com/cardano-community/koios-java-client)  ## Community Projects/Tools    - [Building On Cardano](https://buildingoncardano.com)   - [CardaStat](cardastat.info)   - [CNFT.IO](https://cnft.io)   - [CNTools](https://cardano-community.github.io/guild-operators/Scripts/cntools/)   - [Dandelion](https://dandelion.link)   - [Eternl](https://eternl.io/)   - [PoolPeek](https://poolpeek.com)  # FAQ  ### Is there a price attached to using services? For most of the queries, there are no charges. But there are DDoS protection and strict timeout rules (see API Usage) that may prevent heavy consumers from using this *remotely* (for which, there should be an interaction to ensure the usage is proportional to sizing and traffic expected).  ### Who are the folks behind Koios? It will be increasing list of community builders. But for initial think-tank and efforts, the work done is primarily by [guild-operators](https://cardano-community.github.io/guild-operators) who are a well-recognised team of members behind Cardano tools like CNTools, gLiveView, topologyUpdater, etc. We also run a parallel a short (60-min) epoch blockchain, viz, guild used by many for experiments.  ### I am only interested in collaborating on queries, where can I find the code and how to collaborate? All the Postgres codebase against db-sync instance is available on guild-operator's github repo [here](https://github.com/cardano-community/guild-operators/tree/alpha/files/grest/rpc). Feel free to raise an issue/PR to discuss anything related to those queries.  ### I am not sure how to set up an instance. Is there an easy start guide? Yes, there is a setup script (expect you to read carefully the help section) and instructions [here](https://cardano-community.github.io/guild-operators/Build/grest/). Should you need any assistance, feel free to hop in to the [discussion group](https://t.me/joinchat/+zE4Lce_QUepiY2U1).  ### Too much reading, I want to discuss in person There are bi-weekly calls held that anyone is free to join - or you can drop in to the [telegram group](https://t.me/+zE4Lce_QUepiY2U1) and start a discussion from there. 

   OpenAPI Version: 3.0.2
   Koios API API version: 1.0.6
   Generated by OpenAPI Generator (https://openapi-generator.tech)
-}

{-|
Module : Koios.Model
-}

{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -fno-warn-unused-matches -fno-warn-unused-binds -fno-warn-unused-imports #-}

module Koios.Model where

import Koios.Core
import Koios.MimeTypes

import Data.Aeson ((.:),(.:!),(.:?),(.=))

import qualified Control.Arrow as P (left)
import qualified Data.Aeson as A
import qualified Data.ByteString as B
import qualified Data.ByteString.Base64 as B64
import qualified Data.ByteString.Char8 as BC
import qualified Data.ByteString.Lazy as BL
import qualified Data.Data as P (Typeable, TypeRep, typeOf, typeRep)
import qualified Data.Foldable as P
import qualified Data.HashMap.Lazy as HM
import qualified Data.Map as Map
import qualified Data.Maybe as P
import qualified Data.Set as Set
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.Time as TI
import qualified Lens.Micro as L
import qualified Web.FormUrlEncoded as WH
import qualified Web.HttpApiData as WH

import Control.Applicative ((<|>))
import Control.Applicative (Alternative)
import Data.Function ((&))
import Data.Monoid ((<>))
import Data.Text (Text)
import Prelude (($),(/=),(.),(<$>),(<*>),(>>=),(=<<),Maybe(..),Bool(..),Char,Double,FilePath,Float,Int,Integer,String,fmap,undefined,mempty,maybe,pure,Monad,Applicative,Functor)

import qualified Prelude as P



-- * Parameter newtypes


-- ** AssetName
newtype AssetName = AssetName { unAssetName :: Text } deriving (P.Eq, P.Show)

-- ** AssetPolicy
newtype AssetPolicy = AssetPolicy { unAssetPolicy :: Text } deriving (P.Eq, P.Show)

-- ** Body
newtype Body = Body { unBody :: FilePath } deriving (P.Eq, P.Show, A.ToJSON)

-- ** EpochNo
newtype EpochNo = EpochNo { unEpochNo :: Text } deriving (P.Eq, P.Show)

-- ** PoolBech32
newtype PoolBech32 = PoolBech32 { unPoolBech32 :: Text } deriving (P.Eq, P.Show)

-- ** ScriptHash
newtype ScriptHash = ScriptHash { unScriptHash :: Text } deriving (P.Eq, P.Show)

-- * Models


-- ** AccountAddressesInner
-- | AccountAddressesInner
data AccountAddressesInner = AccountAddressesInner
  { accountAddressesInnerStakeAddress :: !(Maybe StakeAddress) -- ^ "stake_address"
  , accountAddressesInnerAddresses :: !(Maybe [PaymentAddress]) -- ^ "addresses"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AccountAddressesInner
instance A.FromJSON AccountAddressesInner where
  parseJSON = A.withObject "AccountAddressesInner" $ \o ->
    AccountAddressesInner
      <$> (o .:? "stake_address")
      <*> (o .:? "addresses")

-- | ToJSON AccountAddressesInner
instance A.ToJSON AccountAddressesInner where
  toJSON AccountAddressesInner {..} =
   _omitNulls
      [ "stake_address" .= accountAddressesInnerStakeAddress
      , "addresses" .= accountAddressesInnerAddresses
      ]


-- | Construct a value of type 'AccountAddressesInner' (by applying it's required fields, if any)
mkAccountAddressesInner
  :: AccountAddressesInner
mkAccountAddressesInner =
  AccountAddressesInner
  { accountAddressesInnerStakeAddress = Nothing
  , accountAddressesInnerAddresses = Nothing
  }

-- ** AccountAssetsInner
-- | AccountAssetsInner
data AccountAssetsInner = AccountAssetsInner
  { accountAssetsInnerStakeAddress :: !(Maybe StakeAddress) -- ^ "stake_address"
  , accountAssetsInnerAssets :: !(Maybe [AccountAssetsInnerAssetsInner]) -- ^ "assets"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AccountAssetsInner
instance A.FromJSON AccountAssetsInner where
  parseJSON = A.withObject "AccountAssetsInner" $ \o ->
    AccountAssetsInner
      <$> (o .:? "stake_address")
      <*> (o .:? "assets")

-- | ToJSON AccountAssetsInner
instance A.ToJSON AccountAssetsInner where
  toJSON AccountAssetsInner {..} =
   _omitNulls
      [ "stake_address" .= accountAssetsInnerStakeAddress
      , "assets" .= accountAssetsInnerAssets
      ]


-- | Construct a value of type 'AccountAssetsInner' (by applying it's required fields, if any)
mkAccountAssetsInner
  :: AccountAssetsInner
mkAccountAssetsInner =
  AccountAssetsInner
  { accountAssetsInnerStakeAddress = Nothing
  , accountAssetsInnerAssets = Nothing
  }

-- ** AccountAssetsInnerAssetsInner
-- | AccountAssetsInnerAssetsInner
data AccountAssetsInnerAssetsInner = AccountAssetsInnerAssetsInner
  { accountAssetsInnerAssetsInnerPolicyId :: !(Maybe PolicyId) -- ^ "policy_id"
  , accountAssetsInnerAssetsInnerAssets :: !(Maybe [AccountAssetsInnerAssetsInnerAssetsInner]) -- ^ "assets"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AccountAssetsInnerAssetsInner
instance A.FromJSON AccountAssetsInnerAssetsInner where
  parseJSON = A.withObject "AccountAssetsInnerAssetsInner" $ \o ->
    AccountAssetsInnerAssetsInner
      <$> (o .:? "policy_id")
      <*> (o .:? "assets")

-- | ToJSON AccountAssetsInnerAssetsInner
instance A.ToJSON AccountAssetsInnerAssetsInner where
  toJSON AccountAssetsInnerAssetsInner {..} =
   _omitNulls
      [ "policy_id" .= accountAssetsInnerAssetsInnerPolicyId
      , "assets" .= accountAssetsInnerAssetsInnerAssets
      ]


-- | Construct a value of type 'AccountAssetsInnerAssetsInner' (by applying it's required fields, if any)
mkAccountAssetsInnerAssetsInner
  :: AccountAssetsInnerAssetsInner
mkAccountAssetsInnerAssetsInner =
  AccountAssetsInnerAssetsInner
  { accountAssetsInnerAssetsInnerPolicyId = Nothing
  , accountAssetsInnerAssetsInnerAssets = Nothing
  }

-- ** AccountAssetsInnerAssetsInnerAssetsInner
-- | AccountAssetsInnerAssetsInnerAssetsInner
data AccountAssetsInnerAssetsInnerAssetsInner = AccountAssetsInnerAssetsInnerAssetsInner
  { accountAssetsInnerAssetsInnerAssetsInnerAssetName :: !(Maybe AssetNameAscii) -- ^ "asset_name"
  , accountAssetsInnerAssetsInnerAssetsInnerAssetPolicy :: !(Maybe PolicyId) -- ^ "asset_policy"
  , accountAssetsInnerAssetsInnerAssetsInnerBalance :: !(Maybe Text) -- ^ "balance" - Asset quantity owned by account
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AccountAssetsInnerAssetsInnerAssetsInner
instance A.FromJSON AccountAssetsInnerAssetsInnerAssetsInner where
  parseJSON = A.withObject "AccountAssetsInnerAssetsInnerAssetsInner" $ \o ->
    AccountAssetsInnerAssetsInnerAssetsInner
      <$> (o .:? "asset_name")
      <*> (o .:? "asset_policy")
      <*> (o .:? "balance")

-- | ToJSON AccountAssetsInnerAssetsInnerAssetsInner
instance A.ToJSON AccountAssetsInnerAssetsInnerAssetsInner where
  toJSON AccountAssetsInnerAssetsInnerAssetsInner {..} =
   _omitNulls
      [ "asset_name" .= accountAssetsInnerAssetsInnerAssetsInnerAssetName
      , "asset_policy" .= accountAssetsInnerAssetsInnerAssetsInnerAssetPolicy
      , "balance" .= accountAssetsInnerAssetsInnerAssetsInnerBalance
      ]


-- | Construct a value of type 'AccountAssetsInnerAssetsInnerAssetsInner' (by applying it's required fields, if any)
mkAccountAssetsInnerAssetsInnerAssetsInner
  :: AccountAssetsInnerAssetsInnerAssetsInner
mkAccountAssetsInnerAssetsInnerAssetsInner =
  AccountAssetsInnerAssetsInnerAssetsInner
  { accountAssetsInnerAssetsInnerAssetsInnerAssetName = Nothing
  , accountAssetsInnerAssetsInnerAssetsInnerAssetPolicy = Nothing
  , accountAssetsInnerAssetsInnerAssetsInnerBalance = Nothing
  }

-- ** AccountHistoryInner
-- | AccountHistoryInner
data AccountHistoryInner = AccountHistoryInner
  { accountHistoryInnerStakeAddress :: !(Maybe Text) -- ^ "stake_address" - Cardano staking address (reward account) in bech32 format
  , accountHistoryInnerHistory :: !(Maybe [AccountHistoryInnerHistoryInner]) -- ^ "history"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AccountHistoryInner
instance A.FromJSON AccountHistoryInner where
  parseJSON = A.withObject "AccountHistoryInner" $ \o ->
    AccountHistoryInner
      <$> (o .:? "stake_address")
      <*> (o .:? "history")

-- | ToJSON AccountHistoryInner
instance A.ToJSON AccountHistoryInner where
  toJSON AccountHistoryInner {..} =
   _omitNulls
      [ "stake_address" .= accountHistoryInnerStakeAddress
      , "history" .= accountHistoryInnerHistory
      ]


-- | Construct a value of type 'AccountHistoryInner' (by applying it's required fields, if any)
mkAccountHistoryInner
  :: AccountHistoryInner
mkAccountHistoryInner =
  AccountHistoryInner
  { accountHistoryInnerStakeAddress = Nothing
  , accountHistoryInnerHistory = Nothing
  }

-- ** AccountHistoryInnerHistoryInner
-- | AccountHistoryInnerHistoryInner
data AccountHistoryInnerHistoryInner = AccountHistoryInnerHistoryInner
  { accountHistoryInnerHistoryInnerPoolId :: !(Maybe Text) -- ^ "pool_id" - Bech32 representation of pool ID
  , accountHistoryInnerHistoryInnerEpochNo :: !(Maybe Int) -- ^ "epoch_no" - Epoch number
  , accountHistoryInnerHistoryInnerActiveStake :: !(Maybe Text) -- ^ "active_stake" - Active stake amount (in lovelaces)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AccountHistoryInnerHistoryInner
instance A.FromJSON AccountHistoryInnerHistoryInner where
  parseJSON = A.withObject "AccountHistoryInnerHistoryInner" $ \o ->
    AccountHistoryInnerHistoryInner
      <$> (o .:? "pool_id")
      <*> (o .:? "epoch_no")
      <*> (o .:? "active_stake")

-- | ToJSON AccountHistoryInnerHistoryInner
instance A.ToJSON AccountHistoryInnerHistoryInner where
  toJSON AccountHistoryInnerHistoryInner {..} =
   _omitNulls
      [ "pool_id" .= accountHistoryInnerHistoryInnerPoolId
      , "epoch_no" .= accountHistoryInnerHistoryInnerEpochNo
      , "active_stake" .= accountHistoryInnerHistoryInnerActiveStake
      ]


-- | Construct a value of type 'AccountHistoryInnerHistoryInner' (by applying it's required fields, if any)
mkAccountHistoryInnerHistoryInner
  :: AccountHistoryInnerHistoryInner
mkAccountHistoryInnerHistoryInner =
  AccountHistoryInnerHistoryInner
  { accountHistoryInnerHistoryInnerPoolId = Nothing
  , accountHistoryInnerHistoryInnerEpochNo = Nothing
  , accountHistoryInnerHistoryInnerActiveStake = Nothing
  }

-- ** AccountInfoInner
-- | AccountInfoInner
data AccountInfoInner = AccountInfoInner
  { accountInfoInnerStakeAddress :: !(Maybe StakeAddress) -- ^ "stake_address"
  , accountInfoInnerStatus :: !(Maybe E'Status) -- ^ "status" - Stake address status
  , accountInfoInnerDelegatedPool :: !(Maybe PoolIdBech32) -- ^ "delegated_pool"
  , accountInfoInnerTotalBalance :: !(Maybe Text) -- ^ "total_balance" - Total balance of the account including UTxO, rewards and MIRs (in lovelace)
  , accountInfoInnerUtxo :: !(Maybe Text) -- ^ "utxo" - Total UTxO balance of the account
  , accountInfoInnerRewards :: !(Maybe Text) -- ^ "rewards" - Total rewards earned by the account
  , accountInfoInnerWithdrawals :: !(Maybe Text) -- ^ "withdrawals" - Total rewards withdrawn by the account
  , accountInfoInnerRewardsAvailable :: !(Maybe Text) -- ^ "rewards_available" - Total rewards available for withdawal
  , accountInfoInnerReserves :: !(Maybe Text) -- ^ "reserves" - Total reserves MIR value of the account
  , accountInfoInnerTreasury :: !(Maybe Text) -- ^ "treasury" - Total treasury MIR value of the account
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AccountInfoInner
instance A.FromJSON AccountInfoInner where
  parseJSON = A.withObject "AccountInfoInner" $ \o ->
    AccountInfoInner
      <$> (o .:? "stake_address")
      <*> (o .:? "status")
      <*> (o .:? "delegated_pool")
      <*> (o .:? "total_balance")
      <*> (o .:? "utxo")
      <*> (o .:? "rewards")
      <*> (o .:? "withdrawals")
      <*> (o .:? "rewards_available")
      <*> (o .:? "reserves")
      <*> (o .:? "treasury")

-- | ToJSON AccountInfoInner
instance A.ToJSON AccountInfoInner where
  toJSON AccountInfoInner {..} =
   _omitNulls
      [ "stake_address" .= accountInfoInnerStakeAddress
      , "status" .= accountInfoInnerStatus
      , "delegated_pool" .= accountInfoInnerDelegatedPool
      , "total_balance" .= accountInfoInnerTotalBalance
      , "utxo" .= accountInfoInnerUtxo
      , "rewards" .= accountInfoInnerRewards
      , "withdrawals" .= accountInfoInnerWithdrawals
      , "rewards_available" .= accountInfoInnerRewardsAvailable
      , "reserves" .= accountInfoInnerReserves
      , "treasury" .= accountInfoInnerTreasury
      ]


-- | Construct a value of type 'AccountInfoInner' (by applying it's required fields, if any)
mkAccountInfoInner
  :: AccountInfoInner
mkAccountInfoInner =
  AccountInfoInner
  { accountInfoInnerStakeAddress = Nothing
  , accountInfoInnerStatus = Nothing
  , accountInfoInnerDelegatedPool = Nothing
  , accountInfoInnerTotalBalance = Nothing
  , accountInfoInnerUtxo = Nothing
  , accountInfoInnerRewards = Nothing
  , accountInfoInnerWithdrawals = Nothing
  , accountInfoInnerRewardsAvailable = Nothing
  , accountInfoInnerReserves = Nothing
  , accountInfoInnerTreasury = Nothing
  }

-- ** AccountInfoPostRequest
-- | AccountInfoPostRequest
data AccountInfoPostRequest = AccountInfoPostRequest
  { accountInfoPostRequestStakeAddresses :: !([Text]) -- ^ /Required/ "_stake_addresses" - Array of Cardano stake address(es) in bech32 format
  , accountInfoPostRequestEpochNo :: !(Maybe Int) -- ^ "_epoch_no" - Only fetch information for a specific epoch
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AccountInfoPostRequest
instance A.FromJSON AccountInfoPostRequest where
  parseJSON = A.withObject "AccountInfoPostRequest" $ \o ->
    AccountInfoPostRequest
      <$> (o .:  "_stake_addresses")
      <*> (o .:? "_epoch_no")

-- | ToJSON AccountInfoPostRequest
instance A.ToJSON AccountInfoPostRequest where
  toJSON AccountInfoPostRequest {..} =
   _omitNulls
      [ "_stake_addresses" .= accountInfoPostRequestStakeAddresses
      , "_epoch_no" .= accountInfoPostRequestEpochNo
      ]


-- | Construct a value of type 'AccountInfoPostRequest' (by applying it's required fields, if any)
mkAccountInfoPostRequest
  :: [Text] -- ^ 'accountInfoPostRequestStakeAddresses': Array of Cardano stake address(es) in bech32 format
  -> AccountInfoPostRequest
mkAccountInfoPostRequest accountInfoPostRequestStakeAddresses =
  AccountInfoPostRequest
  { accountInfoPostRequestStakeAddresses
  , accountInfoPostRequestEpochNo = Nothing
  }

-- ** AccountListInner
-- | AccountListInner
data AccountListInner = AccountListInner
  { accountListInnerId :: !(Maybe StakeAddress) -- ^ "id"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AccountListInner
instance A.FromJSON AccountListInner where
  parseJSON = A.withObject "AccountListInner" $ \o ->
    AccountListInner
      <$> (o .:? "id")

-- | ToJSON AccountListInner
instance A.ToJSON AccountListInner where
  toJSON AccountListInner {..} =
   _omitNulls
      [ "id" .= accountListInnerId
      ]


-- | Construct a value of type 'AccountListInner' (by applying it's required fields, if any)
mkAccountListInner
  :: AccountListInner
mkAccountListInner =
  AccountListInner
  { accountListInnerId = Nothing
  }

-- ** AccountRewardsInner
-- | AccountRewardsInner
data AccountRewardsInner = AccountRewardsInner
  { accountRewardsInnerStakeAddress :: !(Maybe StakeAddress) -- ^ "stake_address"
  , accountRewardsInnerRewards :: !(Maybe [AccountRewardsInnerRewardsInner]) -- ^ "rewards"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AccountRewardsInner
instance A.FromJSON AccountRewardsInner where
  parseJSON = A.withObject "AccountRewardsInner" $ \o ->
    AccountRewardsInner
      <$> (o .:? "stake_address")
      <*> (o .:? "rewards")

-- | ToJSON AccountRewardsInner
instance A.ToJSON AccountRewardsInner where
  toJSON AccountRewardsInner {..} =
   _omitNulls
      [ "stake_address" .= accountRewardsInnerStakeAddress
      , "rewards" .= accountRewardsInnerRewards
      ]


-- | Construct a value of type 'AccountRewardsInner' (by applying it's required fields, if any)
mkAccountRewardsInner
  :: AccountRewardsInner
mkAccountRewardsInner =
  AccountRewardsInner
  { accountRewardsInnerStakeAddress = Nothing
  , accountRewardsInnerRewards = Nothing
  }

-- ** AccountRewardsInnerRewardsInner
-- | AccountRewardsInnerRewardsInner
data AccountRewardsInnerRewardsInner = AccountRewardsInnerRewardsInner
  { accountRewardsInnerRewardsInnerEarnedEpoch :: !(Maybe EpochNo) -- ^ "earned_epoch"
  , accountRewardsInnerRewardsInnerSpendableEpoch :: !(Maybe EpochNo) -- ^ "spendable_epoch"
  , accountRewardsInnerRewardsInnerAmount :: !(Maybe Text) -- ^ "amount" - Amount of rewards earned (in lovelace)
  , accountRewardsInnerRewardsInnerType :: !(Maybe E'Type) -- ^ "type" - The source of the rewards
  , accountRewardsInnerRewardsInnerPoolId :: !(Maybe PoolIdBech32) -- ^ "pool_id"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AccountRewardsInnerRewardsInner
instance A.FromJSON AccountRewardsInnerRewardsInner where
  parseJSON = A.withObject "AccountRewardsInnerRewardsInner" $ \o ->
    AccountRewardsInnerRewardsInner
      <$> (o .:? "earned_epoch")
      <*> (o .:? "spendable_epoch")
      <*> (o .:? "amount")
      <*> (o .:? "type")
      <*> (o .:? "pool_id")

-- | ToJSON AccountRewardsInnerRewardsInner
instance A.ToJSON AccountRewardsInnerRewardsInner where
  toJSON AccountRewardsInnerRewardsInner {..} =
   _omitNulls
      [ "earned_epoch" .= accountRewardsInnerRewardsInnerEarnedEpoch
      , "spendable_epoch" .= accountRewardsInnerRewardsInnerSpendableEpoch
      , "amount" .= accountRewardsInnerRewardsInnerAmount
      , "type" .= accountRewardsInnerRewardsInnerType
      , "pool_id" .= accountRewardsInnerRewardsInnerPoolId
      ]


-- | Construct a value of type 'AccountRewardsInnerRewardsInner' (by applying it's required fields, if any)
mkAccountRewardsInnerRewardsInner
  :: AccountRewardsInnerRewardsInner
mkAccountRewardsInnerRewardsInner =
  AccountRewardsInnerRewardsInner
  { accountRewardsInnerRewardsInnerEarnedEpoch = Nothing
  , accountRewardsInnerRewardsInnerSpendableEpoch = Nothing
  , accountRewardsInnerRewardsInnerAmount = Nothing
  , accountRewardsInnerRewardsInnerType = Nothing
  , accountRewardsInnerRewardsInnerPoolId = Nothing
  }

-- ** AccountUpdatesInner
-- | AccountUpdatesInner
data AccountUpdatesInner = AccountUpdatesInner
  { accountUpdatesInnerStakeAddress :: !(Maybe StakeAddress) -- ^ "stake_address"
  , accountUpdatesInnerUpdates :: !(Maybe [AccountUpdatesInnerUpdatesInner]) -- ^ "updates"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AccountUpdatesInner
instance A.FromJSON AccountUpdatesInner where
  parseJSON = A.withObject "AccountUpdatesInner" $ \o ->
    AccountUpdatesInner
      <$> (o .:? "stake_address")
      <*> (o .:? "updates")

-- | ToJSON AccountUpdatesInner
instance A.ToJSON AccountUpdatesInner where
  toJSON AccountUpdatesInner {..} =
   _omitNulls
      [ "stake_address" .= accountUpdatesInnerStakeAddress
      , "updates" .= accountUpdatesInnerUpdates
      ]


-- | Construct a value of type 'AccountUpdatesInner' (by applying it's required fields, if any)
mkAccountUpdatesInner
  :: AccountUpdatesInner
mkAccountUpdatesInner =
  AccountUpdatesInner
  { accountUpdatesInnerStakeAddress = Nothing
  , accountUpdatesInnerUpdates = Nothing
  }

-- ** AccountUpdatesInnerUpdatesInner
-- | AccountUpdatesInnerUpdatesInner
data AccountUpdatesInnerUpdatesInner = AccountUpdatesInnerUpdatesInner
  { accountUpdatesInnerUpdatesInnerActionType :: !(Maybe E'ActionType) -- ^ "action_type" - Type of certificate submitted
  , accountUpdatesInnerUpdatesInnerTxHash :: !(Maybe TxHash) -- ^ "tx_hash"
  , accountUpdatesInnerUpdatesInnerEpochNo :: !(Maybe EpochNo) -- ^ "epoch_no"
  , accountUpdatesInnerUpdatesInnerEpochSlot :: !(Maybe EpochSlot) -- ^ "epoch_slot"
  , accountUpdatesInnerUpdatesInnerAbsoluteSlot :: !(Maybe AbsSlot) -- ^ "absolute_slot"
  , accountUpdatesInnerUpdatesInnerBlockTime :: !(Maybe BlockTime) -- ^ "block_time"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AccountUpdatesInnerUpdatesInner
instance A.FromJSON AccountUpdatesInnerUpdatesInner where
  parseJSON = A.withObject "AccountUpdatesInnerUpdatesInner" $ \o ->
    AccountUpdatesInnerUpdatesInner
      <$> (o .:? "action_type")
      <*> (o .:? "tx_hash")
      <*> (o .:? "epoch_no")
      <*> (o .:? "epoch_slot")
      <*> (o .:? "absolute_slot")
      <*> (o .:? "block_time")

-- | ToJSON AccountUpdatesInnerUpdatesInner
instance A.ToJSON AccountUpdatesInnerUpdatesInner where
  toJSON AccountUpdatesInnerUpdatesInner {..} =
   _omitNulls
      [ "action_type" .= accountUpdatesInnerUpdatesInnerActionType
      , "tx_hash" .= accountUpdatesInnerUpdatesInnerTxHash
      , "epoch_no" .= accountUpdatesInnerUpdatesInnerEpochNo
      , "epoch_slot" .= accountUpdatesInnerUpdatesInnerEpochSlot
      , "absolute_slot" .= accountUpdatesInnerUpdatesInnerAbsoluteSlot
      , "block_time" .= accountUpdatesInnerUpdatesInnerBlockTime
      ]


-- | Construct a value of type 'AccountUpdatesInnerUpdatesInner' (by applying it's required fields, if any)
mkAccountUpdatesInnerUpdatesInner
  :: AccountUpdatesInnerUpdatesInner
mkAccountUpdatesInnerUpdatesInner =
  AccountUpdatesInnerUpdatesInner
  { accountUpdatesInnerUpdatesInnerActionType = Nothing
  , accountUpdatesInnerUpdatesInnerTxHash = Nothing
  , accountUpdatesInnerUpdatesInnerEpochNo = Nothing
  , accountUpdatesInnerUpdatesInnerEpochSlot = Nothing
  , accountUpdatesInnerUpdatesInnerAbsoluteSlot = Nothing
  , accountUpdatesInnerUpdatesInnerBlockTime = Nothing
  }

-- ** AddressAssetsInner
-- | AddressAssetsInner
data AddressAssetsInner = AddressAssetsInner
  { addressAssetsInnerAddress :: !(Maybe PaymentAddress) -- ^ "address"
  , addressAssetsInnerAssets :: !(Maybe [AssetListInner]) -- ^ "assets" - Array of policy IDs and asset names
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AddressAssetsInner
instance A.FromJSON AddressAssetsInner where
  parseJSON = A.withObject "AddressAssetsInner" $ \o ->
    AddressAssetsInner
      <$> (o .:? "address")
      <*> (o .:? "assets")

-- | ToJSON AddressAssetsInner
instance A.ToJSON AddressAssetsInner where
  toJSON AddressAssetsInner {..} =
   _omitNulls
      [ "address" .= addressAssetsInnerAddress
      , "assets" .= addressAssetsInnerAssets
      ]


-- | Construct a value of type 'AddressAssetsInner' (by applying it's required fields, if any)
mkAddressAssetsInner
  :: AddressAssetsInner
mkAddressAssetsInner =
  AddressAssetsInner
  { addressAssetsInnerAddress = Nothing
  , addressAssetsInnerAssets = Nothing
  }

-- ** AddressInfoInner
-- | AddressInfoInner
data AddressInfoInner = AddressInfoInner
  { addressInfoInnerAddress :: !(Maybe PaymentAddress) -- ^ "address"
  , addressInfoInnerBalance :: !(Maybe Text) -- ^ "balance" - Sum of all UTxO values beloning to address
  , addressInfoInnerStakeAddress :: !(Maybe StakeAddress) -- ^ "stake_address"
  , addressInfoInnerScriptAddress :: !(Maybe Bool) -- ^ "script_address" - Signifies whether the address is a script address
  , addressInfoInnerUtxoSet :: !(Maybe [AddressInfoInnerUtxoSetInner]) -- ^ "utxo_set"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AddressInfoInner
instance A.FromJSON AddressInfoInner where
  parseJSON = A.withObject "AddressInfoInner" $ \o ->
    AddressInfoInner
      <$> (o .:? "address")
      <*> (o .:? "balance")
      <*> (o .:? "stake_address")
      <*> (o .:? "script_address")
      <*> (o .:? "utxo_set")

-- | ToJSON AddressInfoInner
instance A.ToJSON AddressInfoInner where
  toJSON AddressInfoInner {..} =
   _omitNulls
      [ "address" .= addressInfoInnerAddress
      , "balance" .= addressInfoInnerBalance
      , "stake_address" .= addressInfoInnerStakeAddress
      , "script_address" .= addressInfoInnerScriptAddress
      , "utxo_set" .= addressInfoInnerUtxoSet
      ]


-- | Construct a value of type 'AddressInfoInner' (by applying it's required fields, if any)
mkAddressInfoInner
  :: AddressInfoInner
mkAddressInfoInner =
  AddressInfoInner
  { addressInfoInnerAddress = Nothing
  , addressInfoInnerBalance = Nothing
  , addressInfoInnerStakeAddress = Nothing
  , addressInfoInnerScriptAddress = Nothing
  , addressInfoInnerUtxoSet = Nothing
  }

-- ** AddressInfoInnerUtxoSetInner
-- | AddressInfoInnerUtxoSetInner
data AddressInfoInnerUtxoSetInner = AddressInfoInnerUtxoSetInner
  { addressInfoInnerUtxoSetInnerTxHash :: !(Maybe TxHash) -- ^ "tx_hash"
  , addressInfoInnerUtxoSetInnerTxIndex :: !(Maybe TxIndex) -- ^ "tx_index"
  , addressInfoInnerUtxoSetInnerBlockHeight :: !(Maybe BlockHeight) -- ^ "block_height"
  , addressInfoInnerUtxoSetInnerBlockTime :: !(Maybe BlockTime) -- ^ "block_time"
  , addressInfoInnerUtxoSetInnerValue :: !(Maybe Value) -- ^ "value"
  , addressInfoInnerUtxoSetInnerDatumHash :: !(Maybe DatumHash) -- ^ "datum_hash"
  , addressInfoInnerUtxoSetInnerInlineDatum :: !(Maybe InlineDatum) -- ^ "inline_datum"
  , addressInfoInnerUtxoSetInnerReferenceScript :: !(Maybe ReferenceScript) -- ^ "reference_script"
  , addressInfoInnerUtxoSetInnerAssetList :: !(Maybe [AssetListInner]) -- ^ "asset_list" - Array of policy IDs and asset names
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AddressInfoInnerUtxoSetInner
instance A.FromJSON AddressInfoInnerUtxoSetInner where
  parseJSON = A.withObject "AddressInfoInnerUtxoSetInner" $ \o ->
    AddressInfoInnerUtxoSetInner
      <$> (o .:? "tx_hash")
      <*> (o .:? "tx_index")
      <*> (o .:? "block_height")
      <*> (o .:? "block_time")
      <*> (o .:? "value")
      <*> (o .:? "datum_hash")
      <*> (o .:? "inline_datum")
      <*> (o .:? "reference_script")
      <*> (o .:? "asset_list")

-- | ToJSON AddressInfoInnerUtxoSetInner
instance A.ToJSON AddressInfoInnerUtxoSetInner where
  toJSON AddressInfoInnerUtxoSetInner {..} =
   _omitNulls
      [ "tx_hash" .= addressInfoInnerUtxoSetInnerTxHash
      , "tx_index" .= addressInfoInnerUtxoSetInnerTxIndex
      , "block_height" .= addressInfoInnerUtxoSetInnerBlockHeight
      , "block_time" .= addressInfoInnerUtxoSetInnerBlockTime
      , "value" .= addressInfoInnerUtxoSetInnerValue
      , "datum_hash" .= addressInfoInnerUtxoSetInnerDatumHash
      , "inline_datum" .= addressInfoInnerUtxoSetInnerInlineDatum
      , "reference_script" .= addressInfoInnerUtxoSetInnerReferenceScript
      , "asset_list" .= addressInfoInnerUtxoSetInnerAssetList
      ]


-- | Construct a value of type 'AddressInfoInnerUtxoSetInner' (by applying it's required fields, if any)
mkAddressInfoInnerUtxoSetInner
  :: AddressInfoInnerUtxoSetInner
mkAddressInfoInnerUtxoSetInner =
  AddressInfoInnerUtxoSetInner
  { addressInfoInnerUtxoSetInnerTxHash = Nothing
  , addressInfoInnerUtxoSetInnerTxIndex = Nothing
  , addressInfoInnerUtxoSetInnerBlockHeight = Nothing
  , addressInfoInnerUtxoSetInnerBlockTime = Nothing
  , addressInfoInnerUtxoSetInnerValue = Nothing
  , addressInfoInnerUtxoSetInnerDatumHash = Nothing
  , addressInfoInnerUtxoSetInnerInlineDatum = Nothing
  , addressInfoInnerUtxoSetInnerReferenceScript = Nothing
  , addressInfoInnerUtxoSetInnerAssetList = Nothing
  }

-- ** AddressInfoPostRequest
-- | AddressInfoPostRequest
data AddressInfoPostRequest = AddressInfoPostRequest
  { addressInfoPostRequestAddresses :: !([Text]) -- ^ /Required/ "_addresses" - Array of Cardano payment address(es) in bech32 format
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AddressInfoPostRequest
instance A.FromJSON AddressInfoPostRequest where
  parseJSON = A.withObject "AddressInfoPostRequest" $ \o ->
    AddressInfoPostRequest
      <$> (o .:  "_addresses")

-- | ToJSON AddressInfoPostRequest
instance A.ToJSON AddressInfoPostRequest where
  toJSON AddressInfoPostRequest {..} =
   _omitNulls
      [ "_addresses" .= addressInfoPostRequestAddresses
      ]


-- | Construct a value of type 'AddressInfoPostRequest' (by applying it's required fields, if any)
mkAddressInfoPostRequest
  :: [Text] -- ^ 'addressInfoPostRequestAddresses': Array of Cardano payment address(es) in bech32 format
  -> AddressInfoPostRequest
mkAddressInfoPostRequest addressInfoPostRequestAddresses =
  AddressInfoPostRequest
  { addressInfoPostRequestAddresses
  }

-- ** AddressTxsInner
-- | AddressTxsInner
data AddressTxsInner = AddressTxsInner
  { addressTxsInnerTxHash :: !(Maybe TxHash) -- ^ "tx_hash"
  , addressTxsInnerEpochNo :: !(Maybe EpochNo) -- ^ "epoch_no"
  , addressTxsInnerBlockHeight :: !(Maybe BlockHeight) -- ^ "block_height"
  , addressTxsInnerBlockTime :: !(Maybe BlockTime) -- ^ "block_time"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AddressTxsInner
instance A.FromJSON AddressTxsInner where
  parseJSON = A.withObject "AddressTxsInner" $ \o ->
    AddressTxsInner
      <$> (o .:? "tx_hash")
      <*> (o .:? "epoch_no")
      <*> (o .:? "block_height")
      <*> (o .:? "block_time")

-- | ToJSON AddressTxsInner
instance A.ToJSON AddressTxsInner where
  toJSON AddressTxsInner {..} =
   _omitNulls
      [ "tx_hash" .= addressTxsInnerTxHash
      , "epoch_no" .= addressTxsInnerEpochNo
      , "block_height" .= addressTxsInnerBlockHeight
      , "block_time" .= addressTxsInnerBlockTime
      ]


-- | Construct a value of type 'AddressTxsInner' (by applying it's required fields, if any)
mkAddressTxsInner
  :: AddressTxsInner
mkAddressTxsInner =
  AddressTxsInner
  { addressTxsInnerTxHash = Nothing
  , addressTxsInnerEpochNo = Nothing
  , addressTxsInnerBlockHeight = Nothing
  , addressTxsInnerBlockTime = Nothing
  }

-- ** AddressTxsPostRequest
-- | AddressTxsPostRequest
data AddressTxsPostRequest = AddressTxsPostRequest
  { addressTxsPostRequestAddresses :: !([Text]) -- ^ /Required/ "_addresses" - Array of Cardano payment address(es) in bech32 format
  , addressTxsPostRequestAfterBlockHeight :: !(Maybe Int) -- ^ "_after_block_height" - Only fetch information after specific block height
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AddressTxsPostRequest
instance A.FromJSON AddressTxsPostRequest where
  parseJSON = A.withObject "AddressTxsPostRequest" $ \o ->
    AddressTxsPostRequest
      <$> (o .:  "_addresses")
      <*> (o .:? "_after_block_height")

-- | ToJSON AddressTxsPostRequest
instance A.ToJSON AddressTxsPostRequest where
  toJSON AddressTxsPostRequest {..} =
   _omitNulls
      [ "_addresses" .= addressTxsPostRequestAddresses
      , "_after_block_height" .= addressTxsPostRequestAfterBlockHeight
      ]


-- | Construct a value of type 'AddressTxsPostRequest' (by applying it's required fields, if any)
mkAddressTxsPostRequest
  :: [Text] -- ^ 'addressTxsPostRequestAddresses': Array of Cardano payment address(es) in bech32 format
  -> AddressTxsPostRequest
mkAddressTxsPostRequest addressTxsPostRequestAddresses =
  AddressTxsPostRequest
  { addressTxsPostRequestAddresses
  , addressTxsPostRequestAfterBlockHeight = Nothing
  }

-- ** AssetAddressListInner
-- | AssetAddressListInner
data AssetAddressListInner = AssetAddressListInner
  { assetAddressListInnerPaymentAddress :: !(Maybe Text) -- ^ "payment_address" - A Cardano payment/base address (bech32 encoded) for transaction&#39;s input UTxO
  , assetAddressListInnerQuantity :: !(Maybe Text) -- ^ "quantity" - Asset balance on the payment address
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AssetAddressListInner
instance A.FromJSON AssetAddressListInner where
  parseJSON = A.withObject "AssetAddressListInner" $ \o ->
    AssetAddressListInner
      <$> (o .:? "payment_address")
      <*> (o .:? "quantity")

-- | ToJSON AssetAddressListInner
instance A.ToJSON AssetAddressListInner where
  toJSON AssetAddressListInner {..} =
   _omitNulls
      [ "payment_address" .= assetAddressListInnerPaymentAddress
      , "quantity" .= assetAddressListInnerQuantity
      ]


-- | Construct a value of type 'AssetAddressListInner' (by applying it's required fields, if any)
mkAssetAddressListInner
  :: AssetAddressListInner
mkAssetAddressListInner =
  AssetAddressListInner
  { assetAddressListInnerPaymentAddress = Nothing
  , assetAddressListInnerQuantity = Nothing
  }

-- ** AssetHistoryInner
-- | AssetHistoryInner
data AssetHistoryInner = AssetHistoryInner
  { assetHistoryInnerPolicyId :: !(Maybe PolicyId) -- ^ "policy_id"
  , assetHistoryInnerAssetName :: !(Maybe AssetName) -- ^ "asset_name"
  , assetHistoryInnerMintingTxs :: !(Maybe [AssetHistoryInnerMintingTxsInner]) -- ^ "minting_txs" - Array of all mint/burn transactions for an asset
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AssetHistoryInner
instance A.FromJSON AssetHistoryInner where
  parseJSON = A.withObject "AssetHistoryInner" $ \o ->
    AssetHistoryInner
      <$> (o .:? "policy_id")
      <*> (o .:? "asset_name")
      <*> (o .:? "minting_txs")

-- | ToJSON AssetHistoryInner
instance A.ToJSON AssetHistoryInner where
  toJSON AssetHistoryInner {..} =
   _omitNulls
      [ "policy_id" .= assetHistoryInnerPolicyId
      , "asset_name" .= assetHistoryInnerAssetName
      , "minting_txs" .= assetHistoryInnerMintingTxs
      ]


-- | Construct a value of type 'AssetHistoryInner' (by applying it's required fields, if any)
mkAssetHistoryInner
  :: AssetHistoryInner
mkAssetHistoryInner =
  AssetHistoryInner
  { assetHistoryInnerPolicyId = Nothing
  , assetHistoryInnerAssetName = Nothing
  , assetHistoryInnerMintingTxs = Nothing
  }

-- ** AssetHistoryInnerMintingTxsInner
-- | AssetHistoryInnerMintingTxsInner
data AssetHistoryInnerMintingTxsInner = AssetHistoryInnerMintingTxsInner
  { assetHistoryInnerMintingTxsInnerTxHash :: !(Maybe Text) -- ^ "tx_hash" - Hash of minting/burning transaction
  , assetHistoryInnerMintingTxsInnerBlockTime :: !(Maybe BlockTime) -- ^ "block_time"
  , assetHistoryInnerMintingTxsInnerQuantity :: !(Maybe Text) -- ^ "quantity" - Quantity minted/burned (negative numbers indicate burn transactions)
  , assetHistoryInnerMintingTxsInnerMetadata :: !(Maybe MintingTxMetadata) -- ^ "metadata"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AssetHistoryInnerMintingTxsInner
instance A.FromJSON AssetHistoryInnerMintingTxsInner where
  parseJSON = A.withObject "AssetHistoryInnerMintingTxsInner" $ \o ->
    AssetHistoryInnerMintingTxsInner
      <$> (o .:? "tx_hash")
      <*> (o .:? "block_time")
      <*> (o .:? "quantity")
      <*> (o .:? "metadata")

-- | ToJSON AssetHistoryInnerMintingTxsInner
instance A.ToJSON AssetHistoryInnerMintingTxsInner where
  toJSON AssetHistoryInnerMintingTxsInner {..} =
   _omitNulls
      [ "tx_hash" .= assetHistoryInnerMintingTxsInnerTxHash
      , "block_time" .= assetHistoryInnerMintingTxsInnerBlockTime
      , "quantity" .= assetHistoryInnerMintingTxsInnerQuantity
      , "metadata" .= assetHistoryInnerMintingTxsInnerMetadata
      ]


-- | Construct a value of type 'AssetHistoryInnerMintingTxsInner' (by applying it's required fields, if any)
mkAssetHistoryInnerMintingTxsInner
  :: AssetHistoryInnerMintingTxsInner
mkAssetHistoryInnerMintingTxsInner =
  AssetHistoryInnerMintingTxsInner
  { assetHistoryInnerMintingTxsInnerTxHash = Nothing
  , assetHistoryInnerMintingTxsInnerBlockTime = Nothing
  , assetHistoryInnerMintingTxsInnerQuantity = Nothing
  , assetHistoryInnerMintingTxsInnerMetadata = Nothing
  }

-- ** AssetInfoInner
-- | AssetInfoInner
data AssetInfoInner = AssetInfoInner
  { assetInfoInnerPolicyId :: !(Maybe Text) -- ^ "policy_id" - Asset Policy ID (hex)
  , assetInfoInnerAssetName :: !(Maybe Text) -- ^ "asset_name" - Asset Name (hex)
  , assetInfoInnerAssetNameAscii :: !(Maybe Text) -- ^ "asset_name_ascii" - Asset Name (ASCII)
  , assetInfoInnerFingerprint :: !(Maybe Text) -- ^ "fingerprint" - The CIP14 fingerprint of the asset
  , assetInfoInnerMintingTxHash :: !(Maybe Text) -- ^ "minting_tx_hash" - Hash of the first mint transaction
  , assetInfoInnerMintCnt :: !(Maybe Int) -- ^ "mint_cnt" - Count of total mint transactions
  , assetInfoInnerBurnCnt :: !(Maybe Int) -- ^ "burn_cnt" - Count of total burn transactions
  , assetInfoInnerMintingTxMetadata :: !(Maybe [AssetInfoInnerMintingTxMetadataInner]) -- ^ "minting_tx_metadata"
  , assetInfoInnerTokenRegistryMetadata :: !(Maybe AssetInfoInnerTokenRegistryMetadata) -- ^ "token_registry_metadata"
  , assetInfoInnerTotalSupply :: !(Maybe Text) -- ^ "total_supply"
  , assetInfoInnerCreationTime :: !(Maybe Int) -- ^ "creation_time" - UNIX timestamp of the first asset mint
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AssetInfoInner
instance A.FromJSON AssetInfoInner where
  parseJSON = A.withObject "AssetInfoInner" $ \o ->
    AssetInfoInner
      <$> (o .:? "policy_id")
      <*> (o .:? "asset_name")
      <*> (o .:? "asset_name_ascii")
      <*> (o .:? "fingerprint")
      <*> (o .:? "minting_tx_hash")
      <*> (o .:? "mint_cnt")
      <*> (o .:? "burn_cnt")
      <*> (o .:? "minting_tx_metadata")
      <*> (o .:? "token_registry_metadata")
      <*> (o .:? "total_supply")
      <*> (o .:? "creation_time")

-- | ToJSON AssetInfoInner
instance A.ToJSON AssetInfoInner where
  toJSON AssetInfoInner {..} =
   _omitNulls
      [ "policy_id" .= assetInfoInnerPolicyId
      , "asset_name" .= assetInfoInnerAssetName
      , "asset_name_ascii" .= assetInfoInnerAssetNameAscii
      , "fingerprint" .= assetInfoInnerFingerprint
      , "minting_tx_hash" .= assetInfoInnerMintingTxHash
      , "mint_cnt" .= assetInfoInnerMintCnt
      , "burn_cnt" .= assetInfoInnerBurnCnt
      , "minting_tx_metadata" .= assetInfoInnerMintingTxMetadata
      , "token_registry_metadata" .= assetInfoInnerTokenRegistryMetadata
      , "total_supply" .= assetInfoInnerTotalSupply
      , "creation_time" .= assetInfoInnerCreationTime
      ]


-- | Construct a value of type 'AssetInfoInner' (by applying it's required fields, if any)
mkAssetInfoInner
  :: AssetInfoInner
mkAssetInfoInner =
  AssetInfoInner
  { assetInfoInnerPolicyId = Nothing
  , assetInfoInnerAssetName = Nothing
  , assetInfoInnerAssetNameAscii = Nothing
  , assetInfoInnerFingerprint = Nothing
  , assetInfoInnerMintingTxHash = Nothing
  , assetInfoInnerMintCnt = Nothing
  , assetInfoInnerBurnCnt = Nothing
  , assetInfoInnerMintingTxMetadata = Nothing
  , assetInfoInnerTokenRegistryMetadata = Nothing
  , assetInfoInnerTotalSupply = Nothing
  , assetInfoInnerCreationTime = Nothing
  }

-- ** AssetInfoInnerMintingTxMetadataInner
-- | AssetInfoInnerMintingTxMetadataInner
data AssetInfoInnerMintingTxMetadataInner = AssetInfoInnerMintingTxMetadataInner
  { assetInfoInnerMintingTxMetadataInnerKey :: !(Maybe Text) -- ^ "key" - The metadata key
  , assetInfoInnerMintingTxMetadataInnerJson :: !(Maybe A.Value) -- ^ "json" - The minting Tx JSON payload if it can be decoded as JSON
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AssetInfoInnerMintingTxMetadataInner
instance A.FromJSON AssetInfoInnerMintingTxMetadataInner where
  parseJSON = A.withObject "AssetInfoInnerMintingTxMetadataInner" $ \o ->
    AssetInfoInnerMintingTxMetadataInner
      <$> (o .:? "key")
      <*> (o .:? "json")

-- | ToJSON AssetInfoInnerMintingTxMetadataInner
instance A.ToJSON AssetInfoInnerMintingTxMetadataInner where
  toJSON AssetInfoInnerMintingTxMetadataInner {..} =
   _omitNulls
      [ "key" .= assetInfoInnerMintingTxMetadataInnerKey
      , "json" .= assetInfoInnerMintingTxMetadataInnerJson
      ]


-- | Construct a value of type 'AssetInfoInnerMintingTxMetadataInner' (by applying it's required fields, if any)
mkAssetInfoInnerMintingTxMetadataInner
  :: AssetInfoInnerMintingTxMetadataInner
mkAssetInfoInnerMintingTxMetadataInner =
  AssetInfoInnerMintingTxMetadataInner
  { assetInfoInnerMintingTxMetadataInnerKey = Nothing
  , assetInfoInnerMintingTxMetadataInnerJson = Nothing
  }

-- ** AssetInfoInnerTokenRegistryMetadata
-- | AssetInfoInnerTokenRegistryMetadata
-- Asset metadata registered on the Cardano Token Registry
data AssetInfoInnerTokenRegistryMetadata = AssetInfoInnerTokenRegistryMetadata
  { assetInfoInnerTokenRegistryMetadataName :: !(Maybe Text) -- ^ "name"
  , assetInfoInnerTokenRegistryMetadataDescription :: !(Maybe Text) -- ^ "description"
  , assetInfoInnerTokenRegistryMetadataTicker :: !(Maybe Text) -- ^ "ticker"
  , assetInfoInnerTokenRegistryMetadataUrl :: !(Maybe Text) -- ^ "url"
  , assetInfoInnerTokenRegistryMetadataLogo :: !(Maybe Text) -- ^ "logo" - A PNG image file as a byte string
  , assetInfoInnerTokenRegistryMetadataDecimals :: !(Maybe Int) -- ^ "decimals"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AssetInfoInnerTokenRegistryMetadata
instance A.FromJSON AssetInfoInnerTokenRegistryMetadata where
  parseJSON = A.withObject "AssetInfoInnerTokenRegistryMetadata" $ \o ->
    AssetInfoInnerTokenRegistryMetadata
      <$> (o .:? "name")
      <*> (o .:? "description")
      <*> (o .:? "ticker")
      <*> (o .:? "url")
      <*> (o .:? "logo")
      <*> (o .:? "decimals")

-- | ToJSON AssetInfoInnerTokenRegistryMetadata
instance A.ToJSON AssetInfoInnerTokenRegistryMetadata where
  toJSON AssetInfoInnerTokenRegistryMetadata {..} =
   _omitNulls
      [ "name" .= assetInfoInnerTokenRegistryMetadataName
      , "description" .= assetInfoInnerTokenRegistryMetadataDescription
      , "ticker" .= assetInfoInnerTokenRegistryMetadataTicker
      , "url" .= assetInfoInnerTokenRegistryMetadataUrl
      , "logo" .= assetInfoInnerTokenRegistryMetadataLogo
      , "decimals" .= assetInfoInnerTokenRegistryMetadataDecimals
      ]


-- | Construct a value of type 'AssetInfoInnerTokenRegistryMetadata' (by applying it's required fields, if any)
mkAssetInfoInnerTokenRegistryMetadata
  :: AssetInfoInnerTokenRegistryMetadata
mkAssetInfoInnerTokenRegistryMetadata =
  AssetInfoInnerTokenRegistryMetadata
  { assetInfoInnerTokenRegistryMetadataName = Nothing
  , assetInfoInnerTokenRegistryMetadataDescription = Nothing
  , assetInfoInnerTokenRegistryMetadataTicker = Nothing
  , assetInfoInnerTokenRegistryMetadataUrl = Nothing
  , assetInfoInnerTokenRegistryMetadataLogo = Nothing
  , assetInfoInnerTokenRegistryMetadataDecimals = Nothing
  }

-- ** AssetListInner
-- | AssetListInner
data AssetListInner = AssetListInner
  { assetListInnerPolicyId :: !(Maybe PolicyId) -- ^ "policy_id"
  , assetListInnerAssetNames :: !(Maybe AssetListInnerAssetNames) -- ^ "asset_names"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AssetListInner
instance A.FromJSON AssetListInner where
  parseJSON = A.withObject "AssetListInner" $ \o ->
    AssetListInner
      <$> (o .:? "policy_id")
      <*> (o .:? "asset_names")

-- | ToJSON AssetListInner
instance A.ToJSON AssetListInner where
  toJSON AssetListInner {..} =
   _omitNulls
      [ "policy_id" .= assetListInnerPolicyId
      , "asset_names" .= assetListInnerAssetNames
      ]


-- | Construct a value of type 'AssetListInner' (by applying it's required fields, if any)
mkAssetListInner
  :: AssetListInner
mkAssetListInner =
  AssetListInner
  { assetListInnerPolicyId = Nothing
  , assetListInnerAssetNames = Nothing
  }

-- ** AssetListInnerAssetNames
-- | AssetListInnerAssetNames
data AssetListInnerAssetNames = AssetListInnerAssetNames
  { assetListInnerAssetNamesHex :: !(Maybe [Text]) -- ^ "hex" - Asset Name (hex)
  , assetListInnerAssetNamesAscii :: !(Maybe [Text]) -- ^ "ascii" - Asset Name (ASCII)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AssetListInnerAssetNames
instance A.FromJSON AssetListInnerAssetNames where
  parseJSON = A.withObject "AssetListInnerAssetNames" $ \o ->
    AssetListInnerAssetNames
      <$> (o .:? "hex")
      <*> (o .:? "ascii")

-- | ToJSON AssetListInnerAssetNames
instance A.ToJSON AssetListInnerAssetNames where
  toJSON AssetListInnerAssetNames {..} =
   _omitNulls
      [ "hex" .= assetListInnerAssetNamesHex
      , "ascii" .= assetListInnerAssetNamesAscii
      ]


-- | Construct a value of type 'AssetListInnerAssetNames' (by applying it's required fields, if any)
mkAssetListInnerAssetNames
  :: AssetListInnerAssetNames
mkAssetListInnerAssetNames =
  AssetListInnerAssetNames
  { assetListInnerAssetNamesHex = Nothing
  , assetListInnerAssetNamesAscii = Nothing
  }

-- ** AssetPolicyInfoInner
-- | AssetPolicyInfoInner
data AssetPolicyInfoInner = AssetPolicyInfoInner
  { assetPolicyInfoInnerAssetName :: !(Maybe AssetName) -- ^ "asset_name"
  , assetPolicyInfoInnerAssetNameAscii :: !(Maybe AssetNameAscii) -- ^ "asset_name_ascii"
  , assetPolicyInfoInnerFingerprint :: !(Maybe Fingerprint) -- ^ "fingerprint"
  , assetPolicyInfoInnerMintingTxMetadata :: !(Maybe MintingTxMetadata) -- ^ "minting_tx_metadata"
  , assetPolicyInfoInnerTokenRegistryMetadata :: !(Maybe TokenRegistryMetadata) -- ^ "token_registry_metadata"
  , assetPolicyInfoInnerTotalSupply :: !(Maybe Text) -- ^ "total_supply"
  , assetPolicyInfoInnerCreationTime :: !(Maybe CreationTime) -- ^ "creation_time"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AssetPolicyInfoInner
instance A.FromJSON AssetPolicyInfoInner where
  parseJSON = A.withObject "AssetPolicyInfoInner" $ \o ->
    AssetPolicyInfoInner
      <$> (o .:? "asset_name")
      <*> (o .:? "asset_name_ascii")
      <*> (o .:? "fingerprint")
      <*> (o .:? "minting_tx_metadata")
      <*> (o .:? "token_registry_metadata")
      <*> (o .:? "total_supply")
      <*> (o .:? "creation_time")

-- | ToJSON AssetPolicyInfoInner
instance A.ToJSON AssetPolicyInfoInner where
  toJSON AssetPolicyInfoInner {..} =
   _omitNulls
      [ "asset_name" .= assetPolicyInfoInnerAssetName
      , "asset_name_ascii" .= assetPolicyInfoInnerAssetNameAscii
      , "fingerprint" .= assetPolicyInfoInnerFingerprint
      , "minting_tx_metadata" .= assetPolicyInfoInnerMintingTxMetadata
      , "token_registry_metadata" .= assetPolicyInfoInnerTokenRegistryMetadata
      , "total_supply" .= assetPolicyInfoInnerTotalSupply
      , "creation_time" .= assetPolicyInfoInnerCreationTime
      ]


-- | Construct a value of type 'AssetPolicyInfoInner' (by applying it's required fields, if any)
mkAssetPolicyInfoInner
  :: AssetPolicyInfoInner
mkAssetPolicyInfoInner =
  AssetPolicyInfoInner
  { assetPolicyInfoInnerAssetName = Nothing
  , assetPolicyInfoInnerAssetNameAscii = Nothing
  , assetPolicyInfoInnerFingerprint = Nothing
  , assetPolicyInfoInnerMintingTxMetadata = Nothing
  , assetPolicyInfoInnerTokenRegistryMetadata = Nothing
  , assetPolicyInfoInnerTotalSupply = Nothing
  , assetPolicyInfoInnerCreationTime = Nothing
  }

-- ** AssetSummaryInner
-- | AssetSummaryInner
data AssetSummaryInner = AssetSummaryInner
  { assetSummaryInnerPolicyId :: !(Maybe PolicyId) -- ^ "policy_id"
  , assetSummaryInnerAssetName :: !(Maybe AssetName) -- ^ "asset_name"
  , assetSummaryInnerTotalTransactions :: !(Maybe Int) -- ^ "total_transactions" - Total number of transactions including the given asset
  , assetSummaryInnerStakedWallets :: !(Maybe Int) -- ^ "staked_wallets" - Total number of registered wallets holding the given asset
  , assetSummaryInnerUnstakedAddresses :: !(Maybe Int) -- ^ "unstaked_addresses" - Total number of payment addresses (not belonging to registered wallets) holding the given asset
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AssetSummaryInner
instance A.FromJSON AssetSummaryInner where
  parseJSON = A.withObject "AssetSummaryInner" $ \o ->
    AssetSummaryInner
      <$> (o .:? "policy_id")
      <*> (o .:? "asset_name")
      <*> (o .:? "total_transactions")
      <*> (o .:? "staked_wallets")
      <*> (o .:? "unstaked_addresses")

-- | ToJSON AssetSummaryInner
instance A.ToJSON AssetSummaryInner where
  toJSON AssetSummaryInner {..} =
   _omitNulls
      [ "policy_id" .= assetSummaryInnerPolicyId
      , "asset_name" .= assetSummaryInnerAssetName
      , "total_transactions" .= assetSummaryInnerTotalTransactions
      , "staked_wallets" .= assetSummaryInnerStakedWallets
      , "unstaked_addresses" .= assetSummaryInnerUnstakedAddresses
      ]


-- | Construct a value of type 'AssetSummaryInner' (by applying it's required fields, if any)
mkAssetSummaryInner
  :: AssetSummaryInner
mkAssetSummaryInner =
  AssetSummaryInner
  { assetSummaryInnerPolicyId = Nothing
  , assetSummaryInnerAssetName = Nothing
  , assetSummaryInnerTotalTransactions = Nothing
  , assetSummaryInnerStakedWallets = Nothing
  , assetSummaryInnerUnstakedAddresses = Nothing
  }

-- ** AssetTxsInner
-- | AssetTxsInner
data AssetTxsInner = AssetTxsInner
  { assetTxsInnerTxHash :: !(Maybe TxHash) -- ^ "tx_hash"
  , assetTxsInnerEpochNo :: !(Maybe EpochNo) -- ^ "epoch_no"
  , assetTxsInnerBlockHeight :: !(Maybe BlockHeight) -- ^ "block_height"
  , assetTxsInnerBlockTime :: !(Maybe BlockTime) -- ^ "block_time"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON AssetTxsInner
instance A.FromJSON AssetTxsInner where
  parseJSON = A.withObject "AssetTxsInner" $ \o ->
    AssetTxsInner
      <$> (o .:? "tx_hash")
      <*> (o .:? "epoch_no")
      <*> (o .:? "block_height")
      <*> (o .:? "block_time")

-- | ToJSON AssetTxsInner
instance A.ToJSON AssetTxsInner where
  toJSON AssetTxsInner {..} =
   _omitNulls
      [ "tx_hash" .= assetTxsInnerTxHash
      , "epoch_no" .= assetTxsInnerEpochNo
      , "block_height" .= assetTxsInnerBlockHeight
      , "block_time" .= assetTxsInnerBlockTime
      ]


-- | Construct a value of type 'AssetTxsInner' (by applying it's required fields, if any)
mkAssetTxsInner
  :: AssetTxsInner
mkAssetTxsInner =
  AssetTxsInner
  { assetTxsInnerTxHash = Nothing
  , assetTxsInnerEpochNo = Nothing
  , assetTxsInnerBlockHeight = Nothing
  , assetTxsInnerBlockTime = Nothing
  }

-- ** BlockInfoInner
-- | BlockInfoInner
data BlockInfoInner = BlockInfoInner
  { blockInfoInnerHash :: !(Maybe Hash) -- ^ "hash"
  , blockInfoInnerEpochNo :: !(Maybe EpochNo) -- ^ "epoch_no"
  , blockInfoInnerAbsSlot :: !(Maybe AbsSlot) -- ^ "abs_slot"
  , blockInfoInnerEpochSlot :: !(Maybe EpochSlot) -- ^ "epoch_slot"
  , blockInfoInnerBlockHeight :: !(Maybe BlockHeight) -- ^ "block_height"
  , blockInfoInnerBlockSize :: !(Maybe BlockSize) -- ^ "block_size"
  , blockInfoInnerBlockTime :: !(Maybe BlockTime) -- ^ "block_time"
  , blockInfoInnerTxCount :: !(Maybe TxCount) -- ^ "tx_count"
  , blockInfoInnerVrfKey :: !(Maybe VrfKey) -- ^ "vrf_key"
  , blockInfoInnerOpCert :: !(Maybe Text) -- ^ "op_cert" - Hash of the block producers&#39; operational certificate
  , blockInfoInnerOpCertCounter :: !(Maybe OpCertCounter) -- ^ "op_cert_counter"
  , blockInfoInnerPool :: !(Maybe Pool) -- ^ "pool"
  , blockInfoInnerProtoMajor :: !(Maybe ProtocolMajor) -- ^ "proto_major"
  , blockInfoInnerProtoMinor :: !(Maybe ProtocolMinor) -- ^ "proto_minor"
  , blockInfoInnerTotalOutput :: !(Maybe Text) -- ^ "total_output" - Total output of the block (in lovelace)
  , blockInfoInnerTotalFees :: !(Maybe Text) -- ^ "total_fees" - Total fees of the block (in lovelace)
  , blockInfoInnerNumConfirmations :: !(Maybe Int) -- ^ "num_confirmations" - Number of confirmations for the block
  , blockInfoInnerParentHash :: !(Maybe Text) -- ^ "parent_hash" - Hash of the parent of this block
  , blockInfoInnerChildHash :: !(Maybe Text) -- ^ "child_hash" - Hash of the child of this block (if present)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON BlockInfoInner
instance A.FromJSON BlockInfoInner where
  parseJSON = A.withObject "BlockInfoInner" $ \o ->
    BlockInfoInner
      <$> (o .:? "hash")
      <*> (o .:? "epoch_no")
      <*> (o .:? "abs_slot")
      <*> (o .:? "epoch_slot")
      <*> (o .:? "block_height")
      <*> (o .:? "block_size")
      <*> (o .:? "block_time")
      <*> (o .:? "tx_count")
      <*> (o .:? "vrf_key")
      <*> (o .:? "op_cert")
      <*> (o .:? "op_cert_counter")
      <*> (o .:? "pool")
      <*> (o .:? "proto_major")
      <*> (o .:? "proto_minor")
      <*> (o .:? "total_output")
      <*> (o .:? "total_fees")
      <*> (o .:? "num_confirmations")
      <*> (o .:? "parent_hash")
      <*> (o .:? "child_hash")

-- | ToJSON BlockInfoInner
instance A.ToJSON BlockInfoInner where
  toJSON BlockInfoInner {..} =
   _omitNulls
      [ "hash" .= blockInfoInnerHash
      , "epoch_no" .= blockInfoInnerEpochNo
      , "abs_slot" .= blockInfoInnerAbsSlot
      , "epoch_slot" .= blockInfoInnerEpochSlot
      , "block_height" .= blockInfoInnerBlockHeight
      , "block_size" .= blockInfoInnerBlockSize
      , "block_time" .= blockInfoInnerBlockTime
      , "tx_count" .= blockInfoInnerTxCount
      , "vrf_key" .= blockInfoInnerVrfKey
      , "op_cert" .= blockInfoInnerOpCert
      , "op_cert_counter" .= blockInfoInnerOpCertCounter
      , "pool" .= blockInfoInnerPool
      , "proto_major" .= blockInfoInnerProtoMajor
      , "proto_minor" .= blockInfoInnerProtoMinor
      , "total_output" .= blockInfoInnerTotalOutput
      , "total_fees" .= blockInfoInnerTotalFees
      , "num_confirmations" .= blockInfoInnerNumConfirmations
      , "parent_hash" .= blockInfoInnerParentHash
      , "child_hash" .= blockInfoInnerChildHash
      ]


-- | Construct a value of type 'BlockInfoInner' (by applying it's required fields, if any)
mkBlockInfoInner
  :: BlockInfoInner
mkBlockInfoInner =
  BlockInfoInner
  { blockInfoInnerHash = Nothing
  , blockInfoInnerEpochNo = Nothing
  , blockInfoInnerAbsSlot = Nothing
  , blockInfoInnerEpochSlot = Nothing
  , blockInfoInnerBlockHeight = Nothing
  , blockInfoInnerBlockSize = Nothing
  , blockInfoInnerBlockTime = Nothing
  , blockInfoInnerTxCount = Nothing
  , blockInfoInnerVrfKey = Nothing
  , blockInfoInnerOpCert = Nothing
  , blockInfoInnerOpCertCounter = Nothing
  , blockInfoInnerPool = Nothing
  , blockInfoInnerProtoMajor = Nothing
  , blockInfoInnerProtoMinor = Nothing
  , blockInfoInnerTotalOutput = Nothing
  , blockInfoInnerTotalFees = Nothing
  , blockInfoInnerNumConfirmations = Nothing
  , blockInfoInnerParentHash = Nothing
  , blockInfoInnerChildHash = Nothing
  }

-- ** BlockInfoPostRequest
-- | BlockInfoPostRequest
data BlockInfoPostRequest = BlockInfoPostRequest
  { blockInfoPostRequestBlockHashes :: !([Hash]) -- ^ /Required/ "_block_hashes"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON BlockInfoPostRequest
instance A.FromJSON BlockInfoPostRequest where
  parseJSON = A.withObject "BlockInfoPostRequest" $ \o ->
    BlockInfoPostRequest
      <$> (o .:  "_block_hashes")

-- | ToJSON BlockInfoPostRequest
instance A.ToJSON BlockInfoPostRequest where
  toJSON BlockInfoPostRequest {..} =
   _omitNulls
      [ "_block_hashes" .= blockInfoPostRequestBlockHashes
      ]


-- | Construct a value of type 'BlockInfoPostRequest' (by applying it's required fields, if any)
mkBlockInfoPostRequest
  :: [Hash] -- ^ 'blockInfoPostRequestBlockHashes' 
  -> BlockInfoPostRequest
mkBlockInfoPostRequest blockInfoPostRequestBlockHashes =
  BlockInfoPostRequest
  { blockInfoPostRequestBlockHashes
  }

-- ** BlockTxsInner
-- | BlockTxsInner
data BlockTxsInner = BlockTxsInner
  { blockTxsInnerBlockHash :: !(Maybe Hash) -- ^ "block_hash"
  , blockTxsInnerTxHashes :: !(Maybe [TxHash]) -- ^ "tx_hashes"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON BlockTxsInner
instance A.FromJSON BlockTxsInner where
  parseJSON = A.withObject "BlockTxsInner" $ \o ->
    BlockTxsInner
      <$> (o .:? "block_hash")
      <*> (o .:? "tx_hashes")

-- | ToJSON BlockTxsInner
instance A.ToJSON BlockTxsInner where
  toJSON BlockTxsInner {..} =
   _omitNulls
      [ "block_hash" .= blockTxsInnerBlockHash
      , "tx_hashes" .= blockTxsInnerTxHashes
      ]


-- | Construct a value of type 'BlockTxsInner' (by applying it's required fields, if any)
mkBlockTxsInner
  :: BlockTxsInner
mkBlockTxsInner =
  BlockTxsInner
  { blockTxsInnerBlockHash = Nothing
  , blockTxsInnerTxHashes = Nothing
  }

-- ** BlocksInner
-- | BlocksInner
data BlocksInner = BlocksInner
  { blocksInnerHash :: !(Maybe Text) -- ^ "hash" - Hash of the block
  , blocksInnerEpochNo :: !(Maybe Int) -- ^ "epoch_no" - Epoch number of the block
  , blocksInnerAbsSlot :: !(Maybe Int) -- ^ "abs_slot" - Absolute slot number of the block
  , blocksInnerEpochSlot :: !(Maybe Int) -- ^ "epoch_slot" - Slot number of the block in epoch
  , blocksInnerBlockHeight :: !(Maybe Int) -- ^ "block_height" - Block height
  , blocksInnerBlockSize :: !(Maybe Int) -- ^ "block_size" - Block size in bytes
  , blocksInnerBlockTime :: !(Maybe Int) -- ^ "block_time" - UNIX timestamp of the block
  , blocksInnerTxCount :: !(Maybe Int) -- ^ "tx_count" - Number of transactions in the block
  , blocksInnerVrfKey :: !(Maybe Text) -- ^ "vrf_key" - VRF key of the block producer
  , blocksInnerPool :: !(Maybe Text) -- ^ "pool" - Pool ID in bech32 format (null for pre-Shelley blocks)
  , blocksInnerOpCertCounter :: !(Maybe Int) -- ^ "op_cert_counter" - Counter value of the operational certificate used to create this block
  , blocksInnerProtoMajor :: !(Maybe ProtocolMajor) -- ^ "proto_major"
  , blocksInnerProtoMinor :: !(Maybe ProtocolMinor) -- ^ "proto_minor"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON BlocksInner
instance A.FromJSON BlocksInner where
  parseJSON = A.withObject "BlocksInner" $ \o ->
    BlocksInner
      <$> (o .:? "hash")
      <*> (o .:? "epoch_no")
      <*> (o .:? "abs_slot")
      <*> (o .:? "epoch_slot")
      <*> (o .:? "block_height")
      <*> (o .:? "block_size")
      <*> (o .:? "block_time")
      <*> (o .:? "tx_count")
      <*> (o .:? "vrf_key")
      <*> (o .:? "pool")
      <*> (o .:? "op_cert_counter")
      <*> (o .:? "proto_major")
      <*> (o .:? "proto_minor")

-- | ToJSON BlocksInner
instance A.ToJSON BlocksInner where
  toJSON BlocksInner {..} =
   _omitNulls
      [ "hash" .= blocksInnerHash
      , "epoch_no" .= blocksInnerEpochNo
      , "abs_slot" .= blocksInnerAbsSlot
      , "epoch_slot" .= blocksInnerEpochSlot
      , "block_height" .= blocksInnerBlockHeight
      , "block_size" .= blocksInnerBlockSize
      , "block_time" .= blocksInnerBlockTime
      , "tx_count" .= blocksInnerTxCount
      , "vrf_key" .= blocksInnerVrfKey
      , "pool" .= blocksInnerPool
      , "op_cert_counter" .= blocksInnerOpCertCounter
      , "proto_major" .= blocksInnerProtoMajor
      , "proto_minor" .= blocksInnerProtoMinor
      ]


-- | Construct a value of type 'BlocksInner' (by applying it's required fields, if any)
mkBlocksInner
  :: BlocksInner
mkBlocksInner =
  BlocksInner
  { blocksInnerHash = Nothing
  , blocksInnerEpochNo = Nothing
  , blocksInnerAbsSlot = Nothing
  , blocksInnerEpochSlot = Nothing
  , blocksInnerBlockHeight = Nothing
  , blocksInnerBlockSize = Nothing
  , blocksInnerBlockTime = Nothing
  , blocksInnerTxCount = Nothing
  , blocksInnerVrfKey = Nothing
  , blocksInnerPool = Nothing
  , blocksInnerOpCertCounter = Nothing
  , blocksInnerProtoMajor = Nothing
  , blocksInnerProtoMinor = Nothing
  }

-- ** CredentialTxsPostRequest
-- | CredentialTxsPostRequest
data CredentialTxsPostRequest = CredentialTxsPostRequest
  { credentialTxsPostRequestPaymentCredentials :: !([Text]) -- ^ /Required/ "_payment_credentials" - Array of Cardano payment credential(s) in hex format
  , credentialTxsPostRequestAfterBlockHeight :: !(Maybe Int) -- ^ "_after_block_height" - Only fetch information after specific block height
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON CredentialTxsPostRequest
instance A.FromJSON CredentialTxsPostRequest where
  parseJSON = A.withObject "CredentialTxsPostRequest" $ \o ->
    CredentialTxsPostRequest
      <$> (o .:  "_payment_credentials")
      <*> (o .:? "_after_block_height")

-- | ToJSON CredentialTxsPostRequest
instance A.ToJSON CredentialTxsPostRequest where
  toJSON CredentialTxsPostRequest {..} =
   _omitNulls
      [ "_payment_credentials" .= credentialTxsPostRequestPaymentCredentials
      , "_after_block_height" .= credentialTxsPostRequestAfterBlockHeight
      ]


-- | Construct a value of type 'CredentialTxsPostRequest' (by applying it's required fields, if any)
mkCredentialTxsPostRequest
  :: [Text] -- ^ 'credentialTxsPostRequestPaymentCredentials': Array of Cardano payment credential(s) in hex format
  -> CredentialTxsPostRequest
mkCredentialTxsPostRequest credentialTxsPostRequestPaymentCredentials =
  CredentialTxsPostRequest
  { credentialTxsPostRequestPaymentCredentials
  , credentialTxsPostRequestAfterBlockHeight = Nothing
  }

-- ** EpochInfoInner
-- | EpochInfoInner
data EpochInfoInner = EpochInfoInner
  { epochInfoInnerEpochNo :: !(Maybe Int) -- ^ "epoch_no" - Epoch number
  , epochInfoInnerOutSum :: !(Maybe Text) -- ^ "out_sum" - Total output value across all transactions in epoch
  , epochInfoInnerFees :: !(Maybe Text) -- ^ "fees" - Total fees incurred by transactions in epoch
  , epochInfoInnerTxCount :: !(Maybe Int) -- ^ "tx_count" - Number of transactions submitted in epoch
  , epochInfoInnerBlkCount :: !(Maybe Int) -- ^ "blk_count" - Number of blocks created in epoch
  , epochInfoInnerStartTime :: !(Maybe Int) -- ^ "start_time" - UNIX timestamp of the epoch start
  , epochInfoInnerEndTime :: !(Maybe Int) -- ^ "end_time" - UNIX timestamp of the epoch end
  , epochInfoInnerFirstBlockTime :: !(Maybe Int) -- ^ "first_block_time" - UNIX timestamp of the epoch&#39;s first block
  , epochInfoInnerLastBlockTime :: !(Maybe Int) -- ^ "last_block_time" - UNIX timestamp of the epoch&#39;s last block
  , epochInfoInnerActiveStake :: !(Maybe Text) -- ^ "active_stake" - Total active stake in epoch stake snapshot (null for pre-Shelley epochs)
  , epochInfoInnerTotalRewards :: !(Maybe Text) -- ^ "total_rewards" - Total rewards earned in epoch (null for pre-Shelley epochs)
  , epochInfoInnerAvgBlkReward :: !(Maybe Text) -- ^ "avg_blk_reward" - Average block reward for epoch (null for pre-Shelley epochs)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON EpochInfoInner
instance A.FromJSON EpochInfoInner where
  parseJSON = A.withObject "EpochInfoInner" $ \o ->
    EpochInfoInner
      <$> (o .:? "epoch_no")
      <*> (o .:? "out_sum")
      <*> (o .:? "fees")
      <*> (o .:? "tx_count")
      <*> (o .:? "blk_count")
      <*> (o .:? "start_time")
      <*> (o .:? "end_time")
      <*> (o .:? "first_block_time")
      <*> (o .:? "last_block_time")
      <*> (o .:? "active_stake")
      <*> (o .:? "total_rewards")
      <*> (o .:? "avg_blk_reward")

-- | ToJSON EpochInfoInner
instance A.ToJSON EpochInfoInner where
  toJSON EpochInfoInner {..} =
   _omitNulls
      [ "epoch_no" .= epochInfoInnerEpochNo
      , "out_sum" .= epochInfoInnerOutSum
      , "fees" .= epochInfoInnerFees
      , "tx_count" .= epochInfoInnerTxCount
      , "blk_count" .= epochInfoInnerBlkCount
      , "start_time" .= epochInfoInnerStartTime
      , "end_time" .= epochInfoInnerEndTime
      , "first_block_time" .= epochInfoInnerFirstBlockTime
      , "last_block_time" .= epochInfoInnerLastBlockTime
      , "active_stake" .= epochInfoInnerActiveStake
      , "total_rewards" .= epochInfoInnerTotalRewards
      , "avg_blk_reward" .= epochInfoInnerAvgBlkReward
      ]


-- | Construct a value of type 'EpochInfoInner' (by applying it's required fields, if any)
mkEpochInfoInner
  :: EpochInfoInner
mkEpochInfoInner =
  EpochInfoInner
  { epochInfoInnerEpochNo = Nothing
  , epochInfoInnerOutSum = Nothing
  , epochInfoInnerFees = Nothing
  , epochInfoInnerTxCount = Nothing
  , epochInfoInnerBlkCount = Nothing
  , epochInfoInnerStartTime = Nothing
  , epochInfoInnerEndTime = Nothing
  , epochInfoInnerFirstBlockTime = Nothing
  , epochInfoInnerLastBlockTime = Nothing
  , epochInfoInnerActiveStake = Nothing
  , epochInfoInnerTotalRewards = Nothing
  , epochInfoInnerAvgBlkReward = Nothing
  }

-- ** EpochParamsInner
-- | EpochParamsInner
data EpochParamsInner = EpochParamsInner
  { epochParamsInnerEpochNo :: !(Maybe Int) -- ^ "epoch_no" - Epoch number
  , epochParamsInnerMinFeeA :: !(Maybe Int) -- ^ "min_fee_a" - The &#39;a&#39; parameter to calculate the minimum transaction fee
  , epochParamsInnerMinFeeB :: !(Maybe Int) -- ^ "min_fee_b" - The &#39;b&#39; parameter to calculate the minimum transaction fee
  , epochParamsInnerMaxBlockSize :: !(Maybe Int) -- ^ "max_block_size" - The maximum block size (in bytes)
  , epochParamsInnerMaxTxSize :: !(Maybe Int) -- ^ "max_tx_size" - The maximum transaction size (in bytes)
  , epochParamsInnerMaxBhSize :: !(Maybe Int) -- ^ "max_bh_size" - The maximum block header size (in bytes)
  , epochParamsInnerKeyDeposit :: !(Maybe Text) -- ^ "key_deposit" - The amount (in lovelace) required for a deposit to register a stake address
  , epochParamsInnerPoolDeposit :: !(Maybe Text) -- ^ "pool_deposit" - The amount (in lovelace) required for a deposit to register a stake pool
  , epochParamsInnerMaxEpoch :: !(Maybe Int) -- ^ "max_epoch" - The maximum number of epochs in the future that a pool retirement is allowed to be scheduled for
  , epochParamsInnerOptimalPoolCount :: !(Maybe Int) -- ^ "optimal_pool_count" - The optimal number of stake pools
  , epochParamsInnerInfluence :: !(Maybe Double) -- ^ "influence" - The pledge influence on pool rewards
  , epochParamsInnerMonetaryExpandRate :: !(Maybe Double) -- ^ "monetary_expand_rate" - The monetary expansion rate
  , epochParamsInnerTreasuryGrowthRate :: !(Maybe Double) -- ^ "treasury_growth_rate" - The treasury growth rate
  , epochParamsInnerDecentralisation :: !(Maybe Double) -- ^ "decentralisation" - The decentralisation parameter (1 fully centralised, 0 fully decentralised)
  , epochParamsInnerExtraEntropy :: !(Maybe Text) -- ^ "extra_entropy" - The hash of 32-byte string of extra random-ness added into the protocol&#39;s entropy pool
  , epochParamsInnerProtocolMajor :: !(Maybe Int) -- ^ "protocol_major" - The protocol major version
  , epochParamsInnerProtocolMinor :: !(Maybe Int) -- ^ "protocol_minor" - The protocol minor version
  , epochParamsInnerMinUtxoValue :: !(Maybe Text) -- ^ "min_utxo_value" - The minimum value of a UTxO entry
  , epochParamsInnerMinPoolCost :: !(Maybe Text) -- ^ "min_pool_cost" - The minimum pool cost
  , epochParamsInnerNonce :: !(Maybe Text) -- ^ "nonce" - The nonce value for this epoch
  , epochParamsInnerBlockHash :: !(Maybe Text) -- ^ "block_hash" - The hash of the first block where these parameters are valid
  , epochParamsInnerCostModels :: !(Maybe Text) -- ^ "cost_models" - The per language cost models
  , epochParamsInnerPriceMem :: !(Maybe Double) -- ^ "price_mem" - The per word cost of script memory usage
  , epochParamsInnerPriceStep :: !(Maybe Double) -- ^ "price_step" - The cost of script execution step usage
  , epochParamsInnerMaxTxExMem :: !(Maybe Double) -- ^ "max_tx_ex_mem" - The maximum number of execution memory allowed to be used in a single transaction
  , epochParamsInnerMaxTxExSteps :: !(Maybe Double) -- ^ "max_tx_ex_steps" - The maximum number of execution steps allowed to be used in a single transaction
  , epochParamsInnerMaxBlockExMem :: !(Maybe Double) -- ^ "max_block_ex_mem" - The maximum number of execution memory allowed to be used in a single block
  , epochParamsInnerMaxBlockExSteps :: !(Maybe Double) -- ^ "max_block_ex_steps" - The maximum number of execution steps allowed to be used in a single block
  , epochParamsInnerMaxValSize :: !(Maybe Double) -- ^ "max_val_size" - The maximum Val size
  , epochParamsInnerCollateralPercent :: !(Maybe Int) -- ^ "collateral_percent" - The percentage of the tx fee which must be provided as collateral when including non-native scripts
  , epochParamsInnerMaxCollateralInputs :: !(Maybe Int) -- ^ "max_collateral_inputs" - The maximum number of collateral inputs allowed in a transaction
  , epochParamsInnerCoinsPerUtxoSize :: !(Maybe Text) -- ^ "coins_per_utxo_size" - The cost per UTxO size
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON EpochParamsInner
instance A.FromJSON EpochParamsInner where
  parseJSON = A.withObject "EpochParamsInner" $ \o ->
    EpochParamsInner
      <$> (o .:? "epoch_no")
      <*> (o .:? "min_fee_a")
      <*> (o .:? "min_fee_b")
      <*> (o .:? "max_block_size")
      <*> (o .:? "max_tx_size")
      <*> (o .:? "max_bh_size")
      <*> (o .:? "key_deposit")
      <*> (o .:? "pool_deposit")
      <*> (o .:? "max_epoch")
      <*> (o .:? "optimal_pool_count")
      <*> (o .:? "influence")
      <*> (o .:? "monetary_expand_rate")
      <*> (o .:? "treasury_growth_rate")
      <*> (o .:? "decentralisation")
      <*> (o .:? "extra_entropy")
      <*> (o .:? "protocol_major")
      <*> (o .:? "protocol_minor")
      <*> (o .:? "min_utxo_value")
      <*> (o .:? "min_pool_cost")
      <*> (o .:? "nonce")
      <*> (o .:? "block_hash")
      <*> (o .:? "cost_models")
      <*> (o .:? "price_mem")
      <*> (o .:? "price_step")
      <*> (o .:? "max_tx_ex_mem")
      <*> (o .:? "max_tx_ex_steps")
      <*> (o .:? "max_block_ex_mem")
      <*> (o .:? "max_block_ex_steps")
      <*> (o .:? "max_val_size")
      <*> (o .:? "collateral_percent")
      <*> (o .:? "max_collateral_inputs")
      <*> (o .:? "coins_per_utxo_size")

-- | ToJSON EpochParamsInner
instance A.ToJSON EpochParamsInner where
  toJSON EpochParamsInner {..} =
   _omitNulls
      [ "epoch_no" .= epochParamsInnerEpochNo
      , "min_fee_a" .= epochParamsInnerMinFeeA
      , "min_fee_b" .= epochParamsInnerMinFeeB
      , "max_block_size" .= epochParamsInnerMaxBlockSize
      , "max_tx_size" .= epochParamsInnerMaxTxSize
      , "max_bh_size" .= epochParamsInnerMaxBhSize
      , "key_deposit" .= epochParamsInnerKeyDeposit
      , "pool_deposit" .= epochParamsInnerPoolDeposit
      , "max_epoch" .= epochParamsInnerMaxEpoch
      , "optimal_pool_count" .= epochParamsInnerOptimalPoolCount
      , "influence" .= epochParamsInnerInfluence
      , "monetary_expand_rate" .= epochParamsInnerMonetaryExpandRate
      , "treasury_growth_rate" .= epochParamsInnerTreasuryGrowthRate
      , "decentralisation" .= epochParamsInnerDecentralisation
      , "extra_entropy" .= epochParamsInnerExtraEntropy
      , "protocol_major" .= epochParamsInnerProtocolMajor
      , "protocol_minor" .= epochParamsInnerProtocolMinor
      , "min_utxo_value" .= epochParamsInnerMinUtxoValue
      , "min_pool_cost" .= epochParamsInnerMinPoolCost
      , "nonce" .= epochParamsInnerNonce
      , "block_hash" .= epochParamsInnerBlockHash
      , "cost_models" .= epochParamsInnerCostModels
      , "price_mem" .= epochParamsInnerPriceMem
      , "price_step" .= epochParamsInnerPriceStep
      , "max_tx_ex_mem" .= epochParamsInnerMaxTxExMem
      , "max_tx_ex_steps" .= epochParamsInnerMaxTxExSteps
      , "max_block_ex_mem" .= epochParamsInnerMaxBlockExMem
      , "max_block_ex_steps" .= epochParamsInnerMaxBlockExSteps
      , "max_val_size" .= epochParamsInnerMaxValSize
      , "collateral_percent" .= epochParamsInnerCollateralPercent
      , "max_collateral_inputs" .= epochParamsInnerMaxCollateralInputs
      , "coins_per_utxo_size" .= epochParamsInnerCoinsPerUtxoSize
      ]


-- | Construct a value of type 'EpochParamsInner' (by applying it's required fields, if any)
mkEpochParamsInner
  :: EpochParamsInner
mkEpochParamsInner =
  EpochParamsInner
  { epochParamsInnerEpochNo = Nothing
  , epochParamsInnerMinFeeA = Nothing
  , epochParamsInnerMinFeeB = Nothing
  , epochParamsInnerMaxBlockSize = Nothing
  , epochParamsInnerMaxTxSize = Nothing
  , epochParamsInnerMaxBhSize = Nothing
  , epochParamsInnerKeyDeposit = Nothing
  , epochParamsInnerPoolDeposit = Nothing
  , epochParamsInnerMaxEpoch = Nothing
  , epochParamsInnerOptimalPoolCount = Nothing
  , epochParamsInnerInfluence = Nothing
  , epochParamsInnerMonetaryExpandRate = Nothing
  , epochParamsInnerTreasuryGrowthRate = Nothing
  , epochParamsInnerDecentralisation = Nothing
  , epochParamsInnerExtraEntropy = Nothing
  , epochParamsInnerProtocolMajor = Nothing
  , epochParamsInnerProtocolMinor = Nothing
  , epochParamsInnerMinUtxoValue = Nothing
  , epochParamsInnerMinPoolCost = Nothing
  , epochParamsInnerNonce = Nothing
  , epochParamsInnerBlockHash = Nothing
  , epochParamsInnerCostModels = Nothing
  , epochParamsInnerPriceMem = Nothing
  , epochParamsInnerPriceStep = Nothing
  , epochParamsInnerMaxTxExMem = Nothing
  , epochParamsInnerMaxTxExSteps = Nothing
  , epochParamsInnerMaxBlockExMem = Nothing
  , epochParamsInnerMaxBlockExSteps = Nothing
  , epochParamsInnerMaxValSize = Nothing
  , epochParamsInnerCollateralPercent = Nothing
  , epochParamsInnerMaxCollateralInputs = Nothing
  , epochParamsInnerCoinsPerUtxoSize = Nothing
  }

-- ** GenesisInner
-- | GenesisInner
data GenesisInner = GenesisInner
  { genesisInnerNetworkmagic :: !(Maybe Text) -- ^ "networkmagic" - Unique network identifier for chain
  , genesisInnerNetworkid :: !(Maybe Text) -- ^ "networkid" - Network ID used at various CLI identification to distinguish between Mainnet and other networks
  , genesisInnerEpochlength :: !(Maybe Text) -- ^ "epochlength" - Number of slots in an epoch
  , genesisInnerSlotlength :: !(Maybe Text) -- ^ "slotlength" - Duration of a single slot (in seconds)
  , genesisInnerMaxlovelacesupply :: !(Maybe Text) -- ^ "maxlovelacesupply" - Maximum smallest units (lovelaces) supply for the blockchain
  , genesisInnerSystemstart :: !(Maybe Int) -- ^ "systemstart" - UNIX timestamp of the first block (genesis) on chain
  , genesisInnerActiveslotcoeff :: !(Maybe Text) -- ^ "activeslotcoeff" - Active Slot Co-Efficient (f) - determines the _probability_ of number of slots in epoch that are expected to have blocks (so mainnet, this would be: 432000 * 0.05 &#x3D; 21600 estimated blocks)
  , genesisInnerSlotsperkesperiod :: !(Maybe Text) -- ^ "slotsperkesperiod" - Number of slots that represent a single KES period (a unit used for validation of KES key evolutions)
  , genesisInnerMaxkesrevolutions :: !(Maybe Text) -- ^ "maxkesrevolutions" - Number of KES key evolutions that will automatically occur before a KES (hot) key is expired. This parameter is for security of a pool, in case an operator had access to his hot(online) machine compromised
  , genesisInnerSecurityparam :: !(Maybe Text) -- ^ "securityparam" - A unit (k) used to divide epochs to determine stability window (used in security checks like ensuring atleast 1 block was created in 3*k/f period, or to finalize next epoch&#39;s nonce at 4*k/f slots before end of epoch)
  , genesisInnerUpdatequorum :: !(Maybe Text) -- ^ "updatequorum" - Number of BFT members that need to approve (via vote) a Protocol Update Proposal
  , genesisInnerAlonzogenesis :: !(Maybe Text) -- ^ "alonzogenesis" - A JSON dump of Alonzo Genesis
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON GenesisInner
instance A.FromJSON GenesisInner where
  parseJSON = A.withObject "GenesisInner" $ \o ->
    GenesisInner
      <$> (o .:? "networkmagic")
      <*> (o .:? "networkid")
      <*> (o .:? "epochlength")
      <*> (o .:? "slotlength")
      <*> (o .:? "maxlovelacesupply")
      <*> (o .:? "systemstart")
      <*> (o .:? "activeslotcoeff")
      <*> (o .:? "slotsperkesperiod")
      <*> (o .:? "maxkesrevolutions")
      <*> (o .:? "securityparam")
      <*> (o .:? "updatequorum")
      <*> (o .:? "alonzogenesis")

-- | ToJSON GenesisInner
instance A.ToJSON GenesisInner where
  toJSON GenesisInner {..} =
   _omitNulls
      [ "networkmagic" .= genesisInnerNetworkmagic
      , "networkid" .= genesisInnerNetworkid
      , "epochlength" .= genesisInnerEpochlength
      , "slotlength" .= genesisInnerSlotlength
      , "maxlovelacesupply" .= genesisInnerMaxlovelacesupply
      , "systemstart" .= genesisInnerSystemstart
      , "activeslotcoeff" .= genesisInnerActiveslotcoeff
      , "slotsperkesperiod" .= genesisInnerSlotsperkesperiod
      , "maxkesrevolutions" .= genesisInnerMaxkesrevolutions
      , "securityparam" .= genesisInnerSecurityparam
      , "updatequorum" .= genesisInnerUpdatequorum
      , "alonzogenesis" .= genesisInnerAlonzogenesis
      ]


-- | Construct a value of type 'GenesisInner' (by applying it's required fields, if any)
mkGenesisInner
  :: GenesisInner
mkGenesisInner =
  GenesisInner
  { genesisInnerNetworkmagic = Nothing
  , genesisInnerNetworkid = Nothing
  , genesisInnerEpochlength = Nothing
  , genesisInnerSlotlength = Nothing
  , genesisInnerMaxlovelacesupply = Nothing
  , genesisInnerSystemstart = Nothing
  , genesisInnerActiveslotcoeff = Nothing
  , genesisInnerSlotsperkesperiod = Nothing
  , genesisInnerMaxkesrevolutions = Nothing
  , genesisInnerSecurityparam = Nothing
  , genesisInnerUpdatequorum = Nothing
  , genesisInnerAlonzogenesis = Nothing
  }

-- ** NativeScriptListInner
-- | NativeScriptListInner
data NativeScriptListInner = NativeScriptListInner
  { nativeScriptListInnerScriptHash :: !(Maybe ScriptHash) -- ^ "script_hash"
  , nativeScriptListInnerCreationTxHash :: !(Maybe CreationTxHash) -- ^ "creation_tx_hash"
  , nativeScriptListInnerType :: !(Maybe E'Type2) -- ^ "type" - Type of the script
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON NativeScriptListInner
instance A.FromJSON NativeScriptListInner where
  parseJSON = A.withObject "NativeScriptListInner" $ \o ->
    NativeScriptListInner
      <$> (o .:? "script_hash")
      <*> (o .:? "creation_tx_hash")
      <*> (o .:? "type")

-- | ToJSON NativeScriptListInner
instance A.ToJSON NativeScriptListInner where
  toJSON NativeScriptListInner {..} =
   _omitNulls
      [ "script_hash" .= nativeScriptListInnerScriptHash
      , "creation_tx_hash" .= nativeScriptListInnerCreationTxHash
      , "type" .= nativeScriptListInnerType
      ]


-- | Construct a value of type 'NativeScriptListInner' (by applying it's required fields, if any)
mkNativeScriptListInner
  :: NativeScriptListInner
mkNativeScriptListInner =
  NativeScriptListInner
  { nativeScriptListInnerScriptHash = Nothing
  , nativeScriptListInnerCreationTxHash = Nothing
  , nativeScriptListInnerType = Nothing
  }

-- ** PlutusScriptListInner
-- | PlutusScriptListInner
data PlutusScriptListInner = PlutusScriptListInner
  { plutusScriptListInnerScriptHash :: !(Maybe Text) -- ^ "script_hash" - Hash of a script
  , plutusScriptListInnerCreationTxHash :: !(Maybe Text) -- ^ "creation_tx_hash" - Hash of the script creation transaction
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON PlutusScriptListInner
instance A.FromJSON PlutusScriptListInner where
  parseJSON = A.withObject "PlutusScriptListInner" $ \o ->
    PlutusScriptListInner
      <$> (o .:? "script_hash")
      <*> (o .:? "creation_tx_hash")

-- | ToJSON PlutusScriptListInner
instance A.ToJSON PlutusScriptListInner where
  toJSON PlutusScriptListInner {..} =
   _omitNulls
      [ "script_hash" .= plutusScriptListInnerScriptHash
      , "creation_tx_hash" .= plutusScriptListInnerCreationTxHash
      ]


-- | Construct a value of type 'PlutusScriptListInner' (by applying it's required fields, if any)
mkPlutusScriptListInner
  :: PlutusScriptListInner
mkPlutusScriptListInner =
  PlutusScriptListInner
  { plutusScriptListInnerScriptHash = Nothing
  , plutusScriptListInnerCreationTxHash = Nothing
  }

-- ** PoolBlocksInner
-- | PoolBlocksInner
data PoolBlocksInner = PoolBlocksInner
  { poolBlocksInnerEpochNo :: !(Maybe EpochNo) -- ^ "epoch_no"
  , poolBlocksInnerEpochSlot :: !(Maybe EpochSlot) -- ^ "epoch_slot"
  , poolBlocksInnerAbsSlot :: !(Maybe AbsSlot) -- ^ "abs_slot"
  , poolBlocksInnerBlockHeight :: !(Maybe BlockHeight) -- ^ "block_height"
  , poolBlocksInnerBlockHash :: !(Maybe Hash) -- ^ "block_hash"
  , poolBlocksInnerBlockTime :: !(Maybe BlockTime) -- ^ "block_time"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON PoolBlocksInner
instance A.FromJSON PoolBlocksInner where
  parseJSON = A.withObject "PoolBlocksInner" $ \o ->
    PoolBlocksInner
      <$> (o .:? "epoch_no")
      <*> (o .:? "epoch_slot")
      <*> (o .:? "abs_slot")
      <*> (o .:? "block_height")
      <*> (o .:? "block_hash")
      <*> (o .:? "block_time")

-- | ToJSON PoolBlocksInner
instance A.ToJSON PoolBlocksInner where
  toJSON PoolBlocksInner {..} =
   _omitNulls
      [ "epoch_no" .= poolBlocksInnerEpochNo
      , "epoch_slot" .= poolBlocksInnerEpochSlot
      , "abs_slot" .= poolBlocksInnerAbsSlot
      , "block_height" .= poolBlocksInnerBlockHeight
      , "block_hash" .= poolBlocksInnerBlockHash
      , "block_time" .= poolBlocksInnerBlockTime
      ]


-- | Construct a value of type 'PoolBlocksInner' (by applying it's required fields, if any)
mkPoolBlocksInner
  :: PoolBlocksInner
mkPoolBlocksInner =
  PoolBlocksInner
  { poolBlocksInnerEpochNo = Nothing
  , poolBlocksInnerEpochSlot = Nothing
  , poolBlocksInnerAbsSlot = Nothing
  , poolBlocksInnerBlockHeight = Nothing
  , poolBlocksInnerBlockHash = Nothing
  , poolBlocksInnerBlockTime = Nothing
  }

-- ** PoolDelegatorsInner
-- | PoolDelegatorsInner
data PoolDelegatorsInner = PoolDelegatorsInner
  { poolDelegatorsInnerStakeAddress :: !(Maybe StakeAddress) -- ^ "stake_address"
  , poolDelegatorsInnerAmount :: !(Maybe Text) -- ^ "amount" - Current delegator live stake (in lovelace)
  , poolDelegatorsInnerActiveEpochNo :: !(Maybe Int) -- ^ "active_epoch_no" - Epoch number in which the delegation becomes active
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON PoolDelegatorsInner
instance A.FromJSON PoolDelegatorsInner where
  parseJSON = A.withObject "PoolDelegatorsInner" $ \o ->
    PoolDelegatorsInner
      <$> (o .:? "stake_address")
      <*> (o .:? "amount")
      <*> (o .:? "active_epoch_no")

-- | ToJSON PoolDelegatorsInner
instance A.ToJSON PoolDelegatorsInner where
  toJSON PoolDelegatorsInner {..} =
   _omitNulls
      [ "stake_address" .= poolDelegatorsInnerStakeAddress
      , "amount" .= poolDelegatorsInnerAmount
      , "active_epoch_no" .= poolDelegatorsInnerActiveEpochNo
      ]


-- | Construct a value of type 'PoolDelegatorsInner' (by applying it's required fields, if any)
mkPoolDelegatorsInner
  :: PoolDelegatorsInner
mkPoolDelegatorsInner =
  PoolDelegatorsInner
  { poolDelegatorsInnerStakeAddress = Nothing
  , poolDelegatorsInnerAmount = Nothing
  , poolDelegatorsInnerActiveEpochNo = Nothing
  }

-- ** PoolHistoryInfoInner
-- | PoolHistoryInfoInner
data PoolHistoryInfoInner = PoolHistoryInfoInner
  { poolHistoryInfoInnerEpochNo :: !(Maybe Int) -- ^ "epoch_no" - Epoch for which the pool history data is shown
  , poolHistoryInfoInnerActiveStake :: !(Maybe Text) -- ^ "active_stake" - Amount of delegated stake to this pool at the time of epoch snapshot (in lovelaces)
  , poolHistoryInfoInnerActiveStakePct :: !(Maybe Double) -- ^ "active_stake_pct" - Active stake for the pool, expressed as a percentage of total active stake on network
  , poolHistoryInfoInnerSaturationPct :: !(Maybe Double) -- ^ "saturation_pct" - Saturation percentage of a pool at the time of snapshot (2 decimals)
  , poolHistoryInfoInnerBlockCnt :: !(Maybe Int) -- ^ "block_cnt" - Number of blocks pool created in that epoch
  , poolHistoryInfoInnerDelegatorCnt :: !(Maybe Int) -- ^ "delegator_cnt" - Number of delegators to the pool for that epoch snapshot
  , poolHistoryInfoInnerMargin :: !(Maybe Double) -- ^ "margin" - Margin (decimal format)
  , poolHistoryInfoInnerFixedCost :: !(Maybe Text) -- ^ "fixed_cost" - Pool fixed cost per epoch (in lovelaces)
  , poolHistoryInfoInnerPoolFees :: !(Maybe Text) -- ^ "pool_fees" - Total amount of fees earned by pool owners in that epoch (in lovelaces)
  , poolHistoryInfoInnerDelegRewards :: !(Maybe Text) -- ^ "deleg_rewards" - Total amount of rewards earned by delegators in that epoch (in lovelaces)
  , poolHistoryInfoInnerEpochRos :: !(Maybe Double) -- ^ "epoch_ros" - Annualized ROS (return on staking) for delegators for this epoch
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON PoolHistoryInfoInner
instance A.FromJSON PoolHistoryInfoInner where
  parseJSON = A.withObject "PoolHistoryInfoInner" $ \o ->
    PoolHistoryInfoInner
      <$> (o .:? "epoch_no")
      <*> (o .:? "active_stake")
      <*> (o .:? "active_stake_pct")
      <*> (o .:? "saturation_pct")
      <*> (o .:? "block_cnt")
      <*> (o .:? "delegator_cnt")
      <*> (o .:? "margin")
      <*> (o .:? "fixed_cost")
      <*> (o .:? "pool_fees")
      <*> (o .:? "deleg_rewards")
      <*> (o .:? "epoch_ros")

-- | ToJSON PoolHistoryInfoInner
instance A.ToJSON PoolHistoryInfoInner where
  toJSON PoolHistoryInfoInner {..} =
   _omitNulls
      [ "epoch_no" .= poolHistoryInfoInnerEpochNo
      , "active_stake" .= poolHistoryInfoInnerActiveStake
      , "active_stake_pct" .= poolHistoryInfoInnerActiveStakePct
      , "saturation_pct" .= poolHistoryInfoInnerSaturationPct
      , "block_cnt" .= poolHistoryInfoInnerBlockCnt
      , "delegator_cnt" .= poolHistoryInfoInnerDelegatorCnt
      , "margin" .= poolHistoryInfoInnerMargin
      , "fixed_cost" .= poolHistoryInfoInnerFixedCost
      , "pool_fees" .= poolHistoryInfoInnerPoolFees
      , "deleg_rewards" .= poolHistoryInfoInnerDelegRewards
      , "epoch_ros" .= poolHistoryInfoInnerEpochRos
      ]


-- | Construct a value of type 'PoolHistoryInfoInner' (by applying it's required fields, if any)
mkPoolHistoryInfoInner
  :: PoolHistoryInfoInner
mkPoolHistoryInfoInner =
  PoolHistoryInfoInner
  { poolHistoryInfoInnerEpochNo = Nothing
  , poolHistoryInfoInnerActiveStake = Nothing
  , poolHistoryInfoInnerActiveStakePct = Nothing
  , poolHistoryInfoInnerSaturationPct = Nothing
  , poolHistoryInfoInnerBlockCnt = Nothing
  , poolHistoryInfoInnerDelegatorCnt = Nothing
  , poolHistoryInfoInnerMargin = Nothing
  , poolHistoryInfoInnerFixedCost = Nothing
  , poolHistoryInfoInnerPoolFees = Nothing
  , poolHistoryInfoInnerDelegRewards = Nothing
  , poolHistoryInfoInnerEpochRos = Nothing
  }

-- ** PoolInfoInner
-- | PoolInfoInner
data PoolInfoInner = PoolInfoInner
  { poolInfoInnerPoolIdBech32 :: !(Maybe Text) -- ^ "pool_id_bech32" - Pool ID (bech32 format)
  , poolInfoInnerPoolIdHex :: !(Maybe Text) -- ^ "pool_id_hex" - Pool ID (Hex format)
  , poolInfoInnerActiveEpochNo :: !(Maybe ActiveEpochNo) -- ^ "active_epoch_no"
  , poolInfoInnerVrfKeyHash :: !(Maybe Text) -- ^ "vrf_key_hash" - Pool VRF key hash
  , poolInfoInnerMargin :: !(Maybe Double) -- ^ "margin" - Margin (decimal format)
  , poolInfoInnerFixedCost :: !(Maybe Text) -- ^ "fixed_cost" - Pool fixed cost per epoch
  , poolInfoInnerPledge :: !(Maybe Text) -- ^ "pledge" - Pool pledge in lovelace
  , poolInfoInnerRewardAddr :: !(Maybe Text) -- ^ "reward_addr" - Pool reward address
  , poolInfoInnerOwners :: !(Maybe [Text]) -- ^ "owners"
  , poolInfoInnerRelays :: !(Maybe [PoolInfoInnerRelaysInner]) -- ^ "relays"
  , poolInfoInnerMetaUrl :: !(Maybe Text) -- ^ "meta_url" - Pool metadata URL
  , poolInfoInnerMetaHash :: !(Maybe Text) -- ^ "meta_hash" - Pool metadata hash
  , poolInfoInnerMetaJson :: !(Maybe PoolInfoInnerMetaJson) -- ^ "meta_json"
  , poolInfoInnerPoolStatus :: !(Maybe E'PoolStatus) -- ^ "pool_status" - Pool status
  , poolInfoInnerRetiringEpoch :: !(Maybe Int) -- ^ "retiring_epoch" - Announced retiring epoch (nullable)
  , poolInfoInnerOpCert :: !(Maybe Text) -- ^ "op_cert" - Pool latest operational certificate hash
  , poolInfoInnerOpCertCounter :: !(Maybe Int) -- ^ "op_cert_counter" - Pool latest operational certificate counter value
  , poolInfoInnerActiveStake :: !(Maybe Text) -- ^ "active_stake" - Pool active stake (will be null post epoch transition until dbsync calculation is complete)
  , poolInfoInnerSigma :: !(Maybe Double) -- ^ "sigma" - Pool relative active stake share
  , poolInfoInnerBlockCount :: !(Maybe Int) -- ^ "block_count" - Total pool blocks on chain
  , poolInfoInnerLivePledge :: !(Maybe Text) -- ^ "live_pledge" - Summary of account balance for all pool owner&#39;s
  , poolInfoInnerLiveStake :: !(Maybe Text) -- ^ "live_stake" - Pool live stake
  , poolInfoInnerLiveDelegators :: !(Maybe Int) -- ^ "live_delegators" - Pool live delegator count
  , poolInfoInnerLiveSaturation :: !(Maybe Double) -- ^ "live_saturation" - Pool live saturation (decimal format)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON PoolInfoInner
instance A.FromJSON PoolInfoInner where
  parseJSON = A.withObject "PoolInfoInner" $ \o ->
    PoolInfoInner
      <$> (o .:? "pool_id_bech32")
      <*> (o .:? "pool_id_hex")
      <*> (o .:? "active_epoch_no")
      <*> (o .:? "vrf_key_hash")
      <*> (o .:? "margin")
      <*> (o .:? "fixed_cost")
      <*> (o .:? "pledge")
      <*> (o .:? "reward_addr")
      <*> (o .:? "owners")
      <*> (o .:? "relays")
      <*> (o .:? "meta_url")
      <*> (o .:? "meta_hash")
      <*> (o .:? "meta_json")
      <*> (o .:? "pool_status")
      <*> (o .:? "retiring_epoch")
      <*> (o .:? "op_cert")
      <*> (o .:? "op_cert_counter")
      <*> (o .:? "active_stake")
      <*> (o .:? "sigma")
      <*> (o .:? "block_count")
      <*> (o .:? "live_pledge")
      <*> (o .:? "live_stake")
      <*> (o .:? "live_delegators")
      <*> (o .:? "live_saturation")

-- | ToJSON PoolInfoInner
instance A.ToJSON PoolInfoInner where
  toJSON PoolInfoInner {..} =
   _omitNulls
      [ "pool_id_bech32" .= poolInfoInnerPoolIdBech32
      , "pool_id_hex" .= poolInfoInnerPoolIdHex
      , "active_epoch_no" .= poolInfoInnerActiveEpochNo
      , "vrf_key_hash" .= poolInfoInnerVrfKeyHash
      , "margin" .= poolInfoInnerMargin
      , "fixed_cost" .= poolInfoInnerFixedCost
      , "pledge" .= poolInfoInnerPledge
      , "reward_addr" .= poolInfoInnerRewardAddr
      , "owners" .= poolInfoInnerOwners
      , "relays" .= poolInfoInnerRelays
      , "meta_url" .= poolInfoInnerMetaUrl
      , "meta_hash" .= poolInfoInnerMetaHash
      , "meta_json" .= poolInfoInnerMetaJson
      , "pool_status" .= poolInfoInnerPoolStatus
      , "retiring_epoch" .= poolInfoInnerRetiringEpoch
      , "op_cert" .= poolInfoInnerOpCert
      , "op_cert_counter" .= poolInfoInnerOpCertCounter
      , "active_stake" .= poolInfoInnerActiveStake
      , "sigma" .= poolInfoInnerSigma
      , "block_count" .= poolInfoInnerBlockCount
      , "live_pledge" .= poolInfoInnerLivePledge
      , "live_stake" .= poolInfoInnerLiveStake
      , "live_delegators" .= poolInfoInnerLiveDelegators
      , "live_saturation" .= poolInfoInnerLiveSaturation
      ]


-- | Construct a value of type 'PoolInfoInner' (by applying it's required fields, if any)
mkPoolInfoInner
  :: PoolInfoInner
mkPoolInfoInner =
  PoolInfoInner
  { poolInfoInnerPoolIdBech32 = Nothing
  , poolInfoInnerPoolIdHex = Nothing
  , poolInfoInnerActiveEpochNo = Nothing
  , poolInfoInnerVrfKeyHash = Nothing
  , poolInfoInnerMargin = Nothing
  , poolInfoInnerFixedCost = Nothing
  , poolInfoInnerPledge = Nothing
  , poolInfoInnerRewardAddr = Nothing
  , poolInfoInnerOwners = Nothing
  , poolInfoInnerRelays = Nothing
  , poolInfoInnerMetaUrl = Nothing
  , poolInfoInnerMetaHash = Nothing
  , poolInfoInnerMetaJson = Nothing
  , poolInfoInnerPoolStatus = Nothing
  , poolInfoInnerRetiringEpoch = Nothing
  , poolInfoInnerOpCert = Nothing
  , poolInfoInnerOpCertCounter = Nothing
  , poolInfoInnerActiveStake = Nothing
  , poolInfoInnerSigma = Nothing
  , poolInfoInnerBlockCount = Nothing
  , poolInfoInnerLivePledge = Nothing
  , poolInfoInnerLiveStake = Nothing
  , poolInfoInnerLiveDelegators = Nothing
  , poolInfoInnerLiveSaturation = Nothing
  }

-- ** PoolInfoInnerMetaJson
-- | PoolInfoInnerMetaJson
data PoolInfoInnerMetaJson = PoolInfoInnerMetaJson
  { poolInfoInnerMetaJsonName :: !(Maybe Text) -- ^ "name" - Pool name
  , poolInfoInnerMetaJsonTicker :: !(Maybe Text) -- ^ "ticker" - Pool ticker
  , poolInfoInnerMetaJsonHomepage :: !(Maybe Text) -- ^ "homepage" - Pool homepage URL
  , poolInfoInnerMetaJsonDescription :: !(Maybe Text) -- ^ "description" - Pool description
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON PoolInfoInnerMetaJson
instance A.FromJSON PoolInfoInnerMetaJson where
  parseJSON = A.withObject "PoolInfoInnerMetaJson" $ \o ->
    PoolInfoInnerMetaJson
      <$> (o .:? "name")
      <*> (o .:? "ticker")
      <*> (o .:? "homepage")
      <*> (o .:? "description")

-- | ToJSON PoolInfoInnerMetaJson
instance A.ToJSON PoolInfoInnerMetaJson where
  toJSON PoolInfoInnerMetaJson {..} =
   _omitNulls
      [ "name" .= poolInfoInnerMetaJsonName
      , "ticker" .= poolInfoInnerMetaJsonTicker
      , "homepage" .= poolInfoInnerMetaJsonHomepage
      , "description" .= poolInfoInnerMetaJsonDescription
      ]


-- | Construct a value of type 'PoolInfoInnerMetaJson' (by applying it's required fields, if any)
mkPoolInfoInnerMetaJson
  :: PoolInfoInnerMetaJson
mkPoolInfoInnerMetaJson =
  PoolInfoInnerMetaJson
  { poolInfoInnerMetaJsonName = Nothing
  , poolInfoInnerMetaJsonTicker = Nothing
  , poolInfoInnerMetaJsonHomepage = Nothing
  , poolInfoInnerMetaJsonDescription = Nothing
  }

-- ** PoolInfoInnerRelaysInner
-- | PoolInfoInnerRelaysInner
data PoolInfoInnerRelaysInner = PoolInfoInnerRelaysInner
  { poolInfoInnerRelaysInnerDns :: !(Maybe Text) -- ^ "dns" - DNS name of the relay (nullable)
  , poolInfoInnerRelaysInnerSrv :: !(Maybe Text) -- ^ "srv" - DNS service name of the relay (nullable)
  , poolInfoInnerRelaysInnerIpv4 :: !(Maybe Text) -- ^ "ipv4" - IPv4 address of the relay (nullable)
  , poolInfoInnerRelaysInnerIpv6 :: !(Maybe Text) -- ^ "ipv6" - IPv6 address of the relay (nullable)
  , poolInfoInnerRelaysInnerPort :: !(Maybe Double) -- ^ "port" - Port number of the relay (nullable)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON PoolInfoInnerRelaysInner
instance A.FromJSON PoolInfoInnerRelaysInner where
  parseJSON = A.withObject "PoolInfoInnerRelaysInner" $ \o ->
    PoolInfoInnerRelaysInner
      <$> (o .:? "dns")
      <*> (o .:? "srv")
      <*> (o .:? "ipv4")
      <*> (o .:? "ipv6")
      <*> (o .:? "port")

-- | ToJSON PoolInfoInnerRelaysInner
instance A.ToJSON PoolInfoInnerRelaysInner where
  toJSON PoolInfoInnerRelaysInner {..} =
   _omitNulls
      [ "dns" .= poolInfoInnerRelaysInnerDns
      , "srv" .= poolInfoInnerRelaysInnerSrv
      , "ipv4" .= poolInfoInnerRelaysInnerIpv4
      , "ipv6" .= poolInfoInnerRelaysInnerIpv6
      , "port" .= poolInfoInnerRelaysInnerPort
      ]


-- | Construct a value of type 'PoolInfoInnerRelaysInner' (by applying it's required fields, if any)
mkPoolInfoInnerRelaysInner
  :: PoolInfoInnerRelaysInner
mkPoolInfoInnerRelaysInner =
  PoolInfoInnerRelaysInner
  { poolInfoInnerRelaysInnerDns = Nothing
  , poolInfoInnerRelaysInnerSrv = Nothing
  , poolInfoInnerRelaysInnerIpv4 = Nothing
  , poolInfoInnerRelaysInnerIpv6 = Nothing
  , poolInfoInnerRelaysInnerPort = Nothing
  }

-- ** PoolInfoPostRequest
-- | PoolInfoPostRequest
data PoolInfoPostRequest = PoolInfoPostRequest
  { poolInfoPostRequestPoolBech32Ids :: !([Text]) -- ^ /Required/ "_pool_bech32_ids" - Array of Cardano pool IDs (bech32 format)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON PoolInfoPostRequest
instance A.FromJSON PoolInfoPostRequest where
  parseJSON = A.withObject "PoolInfoPostRequest" $ \o ->
    PoolInfoPostRequest
      <$> (o .:  "_pool_bech32_ids")

-- | ToJSON PoolInfoPostRequest
instance A.ToJSON PoolInfoPostRequest where
  toJSON PoolInfoPostRequest {..} =
   _omitNulls
      [ "_pool_bech32_ids" .= poolInfoPostRequestPoolBech32Ids
      ]


-- | Construct a value of type 'PoolInfoPostRequest' (by applying it's required fields, if any)
mkPoolInfoPostRequest
  :: [Text] -- ^ 'poolInfoPostRequestPoolBech32Ids': Array of Cardano pool IDs (bech32 format)
  -> PoolInfoPostRequest
mkPoolInfoPostRequest poolInfoPostRequestPoolBech32Ids =
  PoolInfoPostRequest
  { poolInfoPostRequestPoolBech32Ids
  }

-- ** PoolListInner
-- | PoolListInner
data PoolListInner = PoolListInner
  { poolListInnerPoolIdBech32 :: !(Maybe Text) -- ^ "pool_id_bech32" - Bech32 representation of pool ID
  , poolListInnerTicker :: !(Maybe Text) -- ^ "ticker" - Pool ticker
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON PoolListInner
instance A.FromJSON PoolListInner where
  parseJSON = A.withObject "PoolListInner" $ \o ->
    PoolListInner
      <$> (o .:? "pool_id_bech32")
      <*> (o .:? "ticker")

-- | ToJSON PoolListInner
instance A.ToJSON PoolListInner where
  toJSON PoolListInner {..} =
   _omitNulls
      [ "pool_id_bech32" .= poolListInnerPoolIdBech32
      , "ticker" .= poolListInnerTicker
      ]


-- | Construct a value of type 'PoolListInner' (by applying it's required fields, if any)
mkPoolListInner
  :: PoolListInner
mkPoolListInner =
  PoolListInner
  { poolListInnerPoolIdBech32 = Nothing
  , poolListInnerTicker = Nothing
  }

-- ** PoolMetadataInner
-- | PoolMetadataInner
data PoolMetadataInner = PoolMetadataInner
  { poolMetadataInnerPoolIdBech32 :: !(Maybe PoolIdBech32) -- ^ "pool_id_bech32"
  , poolMetadataInnerMetaUrl :: !(Maybe MetaUrl) -- ^ "meta_url"
  , poolMetadataInnerMetaHash :: !(Maybe MetaHash) -- ^ "meta_hash"
  , poolMetadataInnerMetaJson :: !(Maybe MetaJson) -- ^ "meta_json"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON PoolMetadataInner
instance A.FromJSON PoolMetadataInner where
  parseJSON = A.withObject "PoolMetadataInner" $ \o ->
    PoolMetadataInner
      <$> (o .:? "pool_id_bech32")
      <*> (o .:? "meta_url")
      <*> (o .:? "meta_hash")
      <*> (o .:? "meta_json")

-- | ToJSON PoolMetadataInner
instance A.ToJSON PoolMetadataInner where
  toJSON PoolMetadataInner {..} =
   _omitNulls
      [ "pool_id_bech32" .= poolMetadataInnerPoolIdBech32
      , "meta_url" .= poolMetadataInnerMetaUrl
      , "meta_hash" .= poolMetadataInnerMetaHash
      , "meta_json" .= poolMetadataInnerMetaJson
      ]


-- | Construct a value of type 'PoolMetadataInner' (by applying it's required fields, if any)
mkPoolMetadataInner
  :: PoolMetadataInner
mkPoolMetadataInner =
  PoolMetadataInner
  { poolMetadataInnerPoolIdBech32 = Nothing
  , poolMetadataInnerMetaUrl = Nothing
  , poolMetadataInnerMetaHash = Nothing
  , poolMetadataInnerMetaJson = Nothing
  }

-- ** PoolMetadataPostRequest
-- | PoolMetadataPostRequest
data PoolMetadataPostRequest = PoolMetadataPostRequest
  { poolMetadataPostRequestPoolBech32Ids :: !(Maybe [Text]) -- ^ "_pool_bech32_ids" - Array of Cardano pool IDs (bech32 format)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON PoolMetadataPostRequest
instance A.FromJSON PoolMetadataPostRequest where
  parseJSON = A.withObject "PoolMetadataPostRequest" $ \o ->
    PoolMetadataPostRequest
      <$> (o .:? "_pool_bech32_ids")

-- | ToJSON PoolMetadataPostRequest
instance A.ToJSON PoolMetadataPostRequest where
  toJSON PoolMetadataPostRequest {..} =
   _omitNulls
      [ "_pool_bech32_ids" .= poolMetadataPostRequestPoolBech32Ids
      ]


-- | Construct a value of type 'PoolMetadataPostRequest' (by applying it's required fields, if any)
mkPoolMetadataPostRequest
  :: PoolMetadataPostRequest
mkPoolMetadataPostRequest =
  PoolMetadataPostRequest
  { poolMetadataPostRequestPoolBech32Ids = Nothing
  }

-- ** PoolRelaysInner
-- | PoolRelaysInner
data PoolRelaysInner = PoolRelaysInner
  { poolRelaysInnerPoolIdBech32 :: !(Maybe PoolIdBech32) -- ^ "pool_id_bech32"
  , poolRelaysInnerRelays :: !(Maybe Relays) -- ^ "relays"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON PoolRelaysInner
instance A.FromJSON PoolRelaysInner where
  parseJSON = A.withObject "PoolRelaysInner" $ \o ->
    PoolRelaysInner
      <$> (o .:? "pool_id_bech32")
      <*> (o .:? "relays")

-- | ToJSON PoolRelaysInner
instance A.ToJSON PoolRelaysInner where
  toJSON PoolRelaysInner {..} =
   _omitNulls
      [ "pool_id_bech32" .= poolRelaysInnerPoolIdBech32
      , "relays" .= poolRelaysInnerRelays
      ]


-- | Construct a value of type 'PoolRelaysInner' (by applying it's required fields, if any)
mkPoolRelaysInner
  :: PoolRelaysInner
mkPoolRelaysInner =
  PoolRelaysInner
  { poolRelaysInnerPoolIdBech32 = Nothing
  , poolRelaysInnerRelays = Nothing
  }

-- ** PoolUpdatesInner
-- | PoolUpdatesInner
data PoolUpdatesInner = PoolUpdatesInner
  { poolUpdatesInnerTxHash :: !(Maybe TxHash) -- ^ "tx_hash"
  , poolUpdatesInnerBlockTime :: !(Maybe BlockTime) -- ^ "block_time"
  , poolUpdatesInnerPoolIdBech32 :: !(Maybe PoolIdBech32) -- ^ "pool_id_bech32"
  , poolUpdatesInnerPoolIdHex :: !(Maybe PoolIdHex) -- ^ "pool_id_hex"
  , poolUpdatesInnerActiveEpochNo :: !(Maybe Int) -- ^ "active_epoch_no" - Epoch number in which the update becomes active
  , poolUpdatesInnerVrfKeyHash :: !(Maybe VrfKeyHash) -- ^ "vrf_key_hash"
  , poolUpdatesInnerMargin :: !(Maybe Margin) -- ^ "margin"
  , poolUpdatesInnerFixedCost :: !(Maybe FixedCost) -- ^ "fixed_cost"
  , poolUpdatesInnerPledge :: !(Maybe Pledge) -- ^ "pledge"
  , poolUpdatesInnerRewardAddr :: !(Maybe RewardAddr) -- ^ "reward_addr"
  , poolUpdatesInnerOwners :: !(Maybe Owners) -- ^ "owners"
  , poolUpdatesInnerRelays :: !(Maybe Relays) -- ^ "relays"
  , poolUpdatesInnerMetaUrl :: !(Maybe MetaUrl) -- ^ "meta_url"
  , poolUpdatesInnerMetaHash :: !(Maybe MetaHash) -- ^ "meta_hash"
  , poolUpdatesInnerPoolStatus :: !(Maybe PoolStatus) -- ^ "pool_status"
  , poolUpdatesInnerRetiringEpoch :: !(Maybe RetiringEpoch) -- ^ "retiring_epoch"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON PoolUpdatesInner
instance A.FromJSON PoolUpdatesInner where
  parseJSON = A.withObject "PoolUpdatesInner" $ \o ->
    PoolUpdatesInner
      <$> (o .:? "tx_hash")
      <*> (o .:? "block_time")
      <*> (o .:? "pool_id_bech32")
      <*> (o .:? "pool_id_hex")
      <*> (o .:? "active_epoch_no")
      <*> (o .:? "vrf_key_hash")
      <*> (o .:? "margin")
      <*> (o .:? "fixed_cost")
      <*> (o .:? "pledge")
      <*> (o .:? "reward_addr")
      <*> (o .:? "owners")
      <*> (o .:? "relays")
      <*> (o .:? "meta_url")
      <*> (o .:? "meta_hash")
      <*> (o .:? "pool_status")
      <*> (o .:? "retiring_epoch")

-- | ToJSON PoolUpdatesInner
instance A.ToJSON PoolUpdatesInner where
  toJSON PoolUpdatesInner {..} =
   _omitNulls
      [ "tx_hash" .= poolUpdatesInnerTxHash
      , "block_time" .= poolUpdatesInnerBlockTime
      , "pool_id_bech32" .= poolUpdatesInnerPoolIdBech32
      , "pool_id_hex" .= poolUpdatesInnerPoolIdHex
      , "active_epoch_no" .= poolUpdatesInnerActiveEpochNo
      , "vrf_key_hash" .= poolUpdatesInnerVrfKeyHash
      , "margin" .= poolUpdatesInnerMargin
      , "fixed_cost" .= poolUpdatesInnerFixedCost
      , "pledge" .= poolUpdatesInnerPledge
      , "reward_addr" .= poolUpdatesInnerRewardAddr
      , "owners" .= poolUpdatesInnerOwners
      , "relays" .= poolUpdatesInnerRelays
      , "meta_url" .= poolUpdatesInnerMetaUrl
      , "meta_hash" .= poolUpdatesInnerMetaHash
      , "pool_status" .= poolUpdatesInnerPoolStatus
      , "retiring_epoch" .= poolUpdatesInnerRetiringEpoch
      ]


-- | Construct a value of type 'PoolUpdatesInner' (by applying it's required fields, if any)
mkPoolUpdatesInner
  :: PoolUpdatesInner
mkPoolUpdatesInner =
  PoolUpdatesInner
  { poolUpdatesInnerTxHash = Nothing
  , poolUpdatesInnerBlockTime = Nothing
  , poolUpdatesInnerPoolIdBech32 = Nothing
  , poolUpdatesInnerPoolIdHex = Nothing
  , poolUpdatesInnerActiveEpochNo = Nothing
  , poolUpdatesInnerVrfKeyHash = Nothing
  , poolUpdatesInnerMargin = Nothing
  , poolUpdatesInnerFixedCost = Nothing
  , poolUpdatesInnerPledge = Nothing
  , poolUpdatesInnerRewardAddr = Nothing
  , poolUpdatesInnerOwners = Nothing
  , poolUpdatesInnerRelays = Nothing
  , poolUpdatesInnerMetaUrl = Nothing
  , poolUpdatesInnerMetaHash = Nothing
  , poolUpdatesInnerPoolStatus = Nothing
  , poolUpdatesInnerRetiringEpoch = Nothing
  }

-- ** ScriptRedeemersInner
-- | ScriptRedeemersInner
data ScriptRedeemersInner = ScriptRedeemersInner
  { scriptRedeemersInnerScriptHash :: !(Maybe Text) -- ^ "script_hash" - Hash of Transaction for which details are being shown
  , scriptRedeemersInnerRedeemers :: !(Maybe [ScriptRedeemersInnerRedeemersInner]) -- ^ "redeemers"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON ScriptRedeemersInner
instance A.FromJSON ScriptRedeemersInner where
  parseJSON = A.withObject "ScriptRedeemersInner" $ \o ->
    ScriptRedeemersInner
      <$> (o .:? "script_hash")
      <*> (o .:? "redeemers")

-- | ToJSON ScriptRedeemersInner
instance A.ToJSON ScriptRedeemersInner where
  toJSON ScriptRedeemersInner {..} =
   _omitNulls
      [ "script_hash" .= scriptRedeemersInnerScriptHash
      , "redeemers" .= scriptRedeemersInnerRedeemers
      ]


-- | Construct a value of type 'ScriptRedeemersInner' (by applying it's required fields, if any)
mkScriptRedeemersInner
  :: ScriptRedeemersInner
mkScriptRedeemersInner =
  ScriptRedeemersInner
  { scriptRedeemersInnerScriptHash = Nothing
  , scriptRedeemersInnerRedeemers = Nothing
  }

-- ** ScriptRedeemersInnerRedeemersInner
-- | ScriptRedeemersInnerRedeemersInner
data ScriptRedeemersInnerRedeemersInner = ScriptRedeemersInnerRedeemersInner
  { scriptRedeemersInnerRedeemersInnerTxHash :: !(Maybe Text) -- ^ "tx_hash" - Hash of Transaction containing the redeemer
  , scriptRedeemersInnerRedeemersInnerTxIndex :: !(Maybe Int) -- ^ "tx_index" - The index of the redeemer pointer in the transaction
  , scriptRedeemersInnerRedeemersInnerUnitMem :: !(Maybe (Map.Map String ScriptRedeemersInnerRedeemersInnerUnitMemValue)) -- ^ "unit_mem" - The budget in Memory to run a script
  , scriptRedeemersInnerRedeemersInnerUnitSteps :: !(Maybe (Map.Map String ScriptRedeemersInnerRedeemersInnerUnitMemValue)) -- ^ "unit_steps" - The budget in Cpu steps to run a script
  , scriptRedeemersInnerRedeemersInnerFee :: !(Maybe Text) -- ^ "fee" - The budget in fees to run a script - the fees depend on the ExUnits and the current prices
  , scriptRedeemersInnerRedeemersInnerPurpose :: !(Maybe E'Purpose) -- ^ "purpose" - What kind of validation this redeemer is used for
  , scriptRedeemersInnerRedeemersInnerDatumHash :: !(Maybe Text) -- ^ "datum_hash" - The Hash of the Plutus Data
  , scriptRedeemersInnerRedeemersInnerDatumValue :: !(Maybe A.Value) -- ^ "datum_value" - The actual data in json format
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON ScriptRedeemersInnerRedeemersInner
instance A.FromJSON ScriptRedeemersInnerRedeemersInner where
  parseJSON = A.withObject "ScriptRedeemersInnerRedeemersInner" $ \o ->
    ScriptRedeemersInnerRedeemersInner
      <$> (o .:? "tx_hash")
      <*> (o .:? "tx_index")
      <*> (o .:? "unit_mem")
      <*> (o .:? "unit_steps")
      <*> (o .:? "fee")
      <*> (o .:? "purpose")
      <*> (o .:? "datum_hash")
      <*> (o .:? "datum_value")

-- | ToJSON ScriptRedeemersInnerRedeemersInner
instance A.ToJSON ScriptRedeemersInnerRedeemersInner where
  toJSON ScriptRedeemersInnerRedeemersInner {..} =
   _omitNulls
      [ "tx_hash" .= scriptRedeemersInnerRedeemersInnerTxHash
      , "tx_index" .= scriptRedeemersInnerRedeemersInnerTxIndex
      , "unit_mem" .= scriptRedeemersInnerRedeemersInnerUnitMem
      , "unit_steps" .= scriptRedeemersInnerRedeemersInnerUnitSteps
      , "fee" .= scriptRedeemersInnerRedeemersInnerFee
      , "purpose" .= scriptRedeemersInnerRedeemersInnerPurpose
      , "datum_hash" .= scriptRedeemersInnerRedeemersInnerDatumHash
      , "datum_value" .= scriptRedeemersInnerRedeemersInnerDatumValue
      ]


-- | Construct a value of type 'ScriptRedeemersInnerRedeemersInner' (by applying it's required fields, if any)
mkScriptRedeemersInnerRedeemersInner
  :: ScriptRedeemersInnerRedeemersInner
mkScriptRedeemersInnerRedeemersInner =
  ScriptRedeemersInnerRedeemersInner
  { scriptRedeemersInnerRedeemersInnerTxHash = Nothing
  , scriptRedeemersInnerRedeemersInnerTxIndex = Nothing
  , scriptRedeemersInnerRedeemersInnerUnitMem = Nothing
  , scriptRedeemersInnerRedeemersInnerUnitSteps = Nothing
  , scriptRedeemersInnerRedeemersInnerFee = Nothing
  , scriptRedeemersInnerRedeemersInnerPurpose = Nothing
  , scriptRedeemersInnerRedeemersInnerDatumHash = Nothing
  , scriptRedeemersInnerRedeemersInnerDatumValue = Nothing
  }

-- ** ScriptRedeemersInnerRedeemersInnerUnitMemValue
-- | ScriptRedeemersInnerRedeemersInnerUnitMemValue
data ScriptRedeemersInnerRedeemersInnerUnitMemValue = ScriptRedeemersInnerRedeemersInnerUnitMemValue
  { 
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON ScriptRedeemersInnerRedeemersInnerUnitMemValue
instance A.FromJSON ScriptRedeemersInnerRedeemersInnerUnitMemValue where
  parseJSON = A.withObject "ScriptRedeemersInnerRedeemersInnerUnitMemValue" $ \o ->
    pure ScriptRedeemersInnerRedeemersInnerUnitMemValue
      

-- | ToJSON ScriptRedeemersInnerRedeemersInnerUnitMemValue
instance A.ToJSON ScriptRedeemersInnerRedeemersInnerUnitMemValue where
  toJSON ScriptRedeemersInnerRedeemersInnerUnitMemValue  =
   _omitNulls
      [ 
      ]


-- | Construct a value of type 'ScriptRedeemersInnerRedeemersInnerUnitMemValue' (by applying it's required fields, if any)
mkScriptRedeemersInnerRedeemersInnerUnitMemValue
  :: ScriptRedeemersInnerRedeemersInnerUnitMemValue
mkScriptRedeemersInnerRedeemersInnerUnitMemValue =
  ScriptRedeemersInnerRedeemersInnerUnitMemValue
  { 
  }

-- ** TipInner
-- | TipInner
data TipInner = TipInner
  { tipInnerHash :: !(Maybe Hash) -- ^ "hash"
  , tipInnerEpochNo :: !(Maybe EpochNo) -- ^ "epoch_no"
  , tipInnerAbsSlot :: !(Maybe AbsSlot) -- ^ "abs_slot"
  , tipInnerEpochSlot :: !(Maybe EpochSlot) -- ^ "epoch_slot"
  , tipInnerBlockNo :: !(Maybe BlockHeight) -- ^ "block_no"
  , tipInnerBlockTime :: !(Maybe BlockTime) -- ^ "block_time"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TipInner
instance A.FromJSON TipInner where
  parseJSON = A.withObject "TipInner" $ \o ->
    TipInner
      <$> (o .:? "hash")
      <*> (o .:? "epoch_no")
      <*> (o .:? "abs_slot")
      <*> (o .:? "epoch_slot")
      <*> (o .:? "block_no")
      <*> (o .:? "block_time")

-- | ToJSON TipInner
instance A.ToJSON TipInner where
  toJSON TipInner {..} =
   _omitNulls
      [ "hash" .= tipInnerHash
      , "epoch_no" .= tipInnerEpochNo
      , "abs_slot" .= tipInnerAbsSlot
      , "epoch_slot" .= tipInnerEpochSlot
      , "block_no" .= tipInnerBlockNo
      , "block_time" .= tipInnerBlockTime
      ]


-- | Construct a value of type 'TipInner' (by applying it's required fields, if any)
mkTipInner
  :: TipInner
mkTipInner =
  TipInner
  { tipInnerHash = Nothing
  , tipInnerEpochNo = Nothing
  , tipInnerAbsSlot = Nothing
  , tipInnerEpochSlot = Nothing
  , tipInnerBlockNo = Nothing
  , tipInnerBlockTime = Nothing
  }

-- ** TotalsInner
-- | TotalsInner
data TotalsInner = TotalsInner
  { totalsInnerEpochNo :: !(Maybe Int) -- ^ "epoch_no" - Epoch number
  , totalsInnerCirculation :: !(Maybe Text) -- ^ "circulation" - Circulating UTxOs for given epoch (in lovelaces)
  , totalsInnerTreasury :: !(Maybe Text) -- ^ "treasury" - Funds in treasury for given epoch (in lovelaces)
  , totalsInnerReward :: !(Maybe Text) -- ^ "reward" - Rewards accumulated as of given epoch (in lovelaces)
  , totalsInnerSupply :: !(Maybe Text) -- ^ "supply" - Total Active Supply (sum of treasury funds, rewards, UTxOs, deposits and fees) for given epoch (in lovelaces)
  , totalsInnerReserves :: !(Maybe Text) -- ^ "reserves" - Total Reserves yet to be unlocked on chain
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TotalsInner
instance A.FromJSON TotalsInner where
  parseJSON = A.withObject "TotalsInner" $ \o ->
    TotalsInner
      <$> (o .:? "epoch_no")
      <*> (o .:? "circulation")
      <*> (o .:? "treasury")
      <*> (o .:? "reward")
      <*> (o .:? "supply")
      <*> (o .:? "reserves")

-- | ToJSON TotalsInner
instance A.ToJSON TotalsInner where
  toJSON TotalsInner {..} =
   _omitNulls
      [ "epoch_no" .= totalsInnerEpochNo
      , "circulation" .= totalsInnerCirculation
      , "treasury" .= totalsInnerTreasury
      , "reward" .= totalsInnerReward
      , "supply" .= totalsInnerSupply
      , "reserves" .= totalsInnerReserves
      ]


-- | Construct a value of type 'TotalsInner' (by applying it's required fields, if any)
mkTotalsInner
  :: TotalsInner
mkTotalsInner =
  TotalsInner
  { totalsInnerEpochNo = Nothing
  , totalsInnerCirculation = Nothing
  , totalsInnerTreasury = Nothing
  , totalsInnerReward = Nothing
  , totalsInnerSupply = Nothing
  , totalsInnerReserves = Nothing
  }

-- ** TxInfoInner
-- | TxInfoInner
data TxInfoInner = TxInfoInner
  { txInfoInnerTxHash :: !(Maybe Text) -- ^ "tx_hash" - Hash identifier of the transaction
  , txInfoInnerBlockHash :: !(Maybe Hash) -- ^ "block_hash"
  , txInfoInnerBlockHeight :: !(Maybe BlockHeight) -- ^ "block_height"
  , txInfoInnerEpochNo :: !(Maybe EpochNo) -- ^ "epoch_no"
  , txInfoInnerEpochSlot :: !(Maybe EpochSlot) -- ^ "epoch_slot"
  , txInfoInnerAbsoluteSlot :: !(Maybe AbsSlot) -- ^ "absolute_slot"
  , txInfoInnerTxTimestamp :: !(Maybe Int) -- ^ "tx_timestamp" - UNIX timestamp of the transaction
  , txInfoInnerTxBlockIndex :: !(Maybe Int) -- ^ "tx_block_index" - Index of transaction within block
  , txInfoInnerTxSize :: !(Maybe Int) -- ^ "tx_size" - Size in bytes of transaction
  , txInfoInnerTotalOutput :: !(Maybe Text) -- ^ "total_output" - Total sum of all transaction outputs (in lovelaces)
  , txInfoInnerFee :: !(Maybe Text) -- ^ "fee" - Total Transaction fee (in lovelaces)
  , txInfoInnerDeposit :: !(Maybe Text) -- ^ "deposit" - Total Deposits included in transaction (for example, if it is registering a pool/key)
  , txInfoInnerInvalidBefore :: !(Maybe Int) -- ^ "invalid_before" - Slot before which transaction cannot be validated (if supplied, else null)
  , txInfoInnerInvalidAfter :: !(Maybe Int) -- ^ "invalid_after" - Slot after which transaction cannot be validated
  , txInfoInnerCollateralInputs :: !(Maybe Outputs) -- ^ "collateral_inputs"
  , txInfoInnerCollateralOutput :: !(Maybe Items) -- ^ "collateral_output"
  , txInfoInnerReferenceInputs :: !(Maybe Outputs) -- ^ "reference_inputs"
  , txInfoInnerInputs :: !(Maybe Outputs) -- ^ "inputs"
  , txInfoInnerOutputs :: !(Maybe [TxInfoInnerOutputsInner]) -- ^ "outputs" - An array of UTxO outputs created by the transaction
  , txInfoInnerWithdrawals :: !(Maybe [TxInfoInnerWithdrawalsInner]) -- ^ "withdrawals" - Array of withdrawals with-in a transaction
  , txInfoInnerAssetsMinted :: !(Maybe [TxInfoInnerAssetsMintedInner]) -- ^ "assets_minted" - Array of minted assets with-in a transaction
  , txInfoInnerMetadata :: !(Maybe [TxInfoInnerMetadataInner]) -- ^ "metadata" - Metadata present with-in a transaction (if any)
  , txInfoInnerCertificates :: !(Maybe [TxInfoInnerCertificatesInner]) -- ^ "certificates" - Certificates present with-in a transaction (if any)
  , txInfoInnerNativeScripts :: !(Maybe [TxInfoInnerNativeScriptsInner]) -- ^ "native_scripts" - Native scripts present in a transaction (if any)
  , txInfoInnerPlutusContracts :: !(Maybe [TxInfoInnerPlutusContractsInner]) -- ^ "plutus_contracts" - Plutus contracts present in transaction (if any)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInner
instance A.FromJSON TxInfoInner where
  parseJSON = A.withObject "TxInfoInner" $ \o ->
    TxInfoInner
      <$> (o .:? "tx_hash")
      <*> (o .:? "block_hash")
      <*> (o .:? "block_height")
      <*> (o .:? "epoch_no")
      <*> (o .:? "epoch_slot")
      <*> (o .:? "absolute_slot")
      <*> (o .:? "tx_timestamp")
      <*> (o .:? "tx_block_index")
      <*> (o .:? "tx_size")
      <*> (o .:? "total_output")
      <*> (o .:? "fee")
      <*> (o .:? "deposit")
      <*> (o .:? "invalid_before")
      <*> (o .:? "invalid_after")
      <*> (o .:? "collateral_inputs")
      <*> (o .:? "collateral_output")
      <*> (o .:? "reference_inputs")
      <*> (o .:? "inputs")
      <*> (o .:? "outputs")
      <*> (o .:? "withdrawals")
      <*> (o .:? "assets_minted")
      <*> (o .:? "metadata")
      <*> (o .:? "certificates")
      <*> (o .:? "native_scripts")
      <*> (o .:? "plutus_contracts")

-- | ToJSON TxInfoInner
instance A.ToJSON TxInfoInner where
  toJSON TxInfoInner {..} =
   _omitNulls
      [ "tx_hash" .= txInfoInnerTxHash
      , "block_hash" .= txInfoInnerBlockHash
      , "block_height" .= txInfoInnerBlockHeight
      , "epoch_no" .= txInfoInnerEpochNo
      , "epoch_slot" .= txInfoInnerEpochSlot
      , "absolute_slot" .= txInfoInnerAbsoluteSlot
      , "tx_timestamp" .= txInfoInnerTxTimestamp
      , "tx_block_index" .= txInfoInnerTxBlockIndex
      , "tx_size" .= txInfoInnerTxSize
      , "total_output" .= txInfoInnerTotalOutput
      , "fee" .= txInfoInnerFee
      , "deposit" .= txInfoInnerDeposit
      , "invalid_before" .= txInfoInnerInvalidBefore
      , "invalid_after" .= txInfoInnerInvalidAfter
      , "collateral_inputs" .= txInfoInnerCollateralInputs
      , "collateral_output" .= txInfoInnerCollateralOutput
      , "reference_inputs" .= txInfoInnerReferenceInputs
      , "inputs" .= txInfoInnerInputs
      , "outputs" .= txInfoInnerOutputs
      , "withdrawals" .= txInfoInnerWithdrawals
      , "assets_minted" .= txInfoInnerAssetsMinted
      , "metadata" .= txInfoInnerMetadata
      , "certificates" .= txInfoInnerCertificates
      , "native_scripts" .= txInfoInnerNativeScripts
      , "plutus_contracts" .= txInfoInnerPlutusContracts
      ]


-- | Construct a value of type 'TxInfoInner' (by applying it's required fields, if any)
mkTxInfoInner
  :: TxInfoInner
mkTxInfoInner =
  TxInfoInner
  { txInfoInnerTxHash = Nothing
  , txInfoInnerBlockHash = Nothing
  , txInfoInnerBlockHeight = Nothing
  , txInfoInnerEpochNo = Nothing
  , txInfoInnerEpochSlot = Nothing
  , txInfoInnerAbsoluteSlot = Nothing
  , txInfoInnerTxTimestamp = Nothing
  , txInfoInnerTxBlockIndex = Nothing
  , txInfoInnerTxSize = Nothing
  , txInfoInnerTotalOutput = Nothing
  , txInfoInnerFee = Nothing
  , txInfoInnerDeposit = Nothing
  , txInfoInnerInvalidBefore = Nothing
  , txInfoInnerInvalidAfter = Nothing
  , txInfoInnerCollateralInputs = Nothing
  , txInfoInnerCollateralOutput = Nothing
  , txInfoInnerReferenceInputs = Nothing
  , txInfoInnerInputs = Nothing
  , txInfoInnerOutputs = Nothing
  , txInfoInnerWithdrawals = Nothing
  , txInfoInnerAssetsMinted = Nothing
  , txInfoInnerMetadata = Nothing
  , txInfoInnerCertificates = Nothing
  , txInfoInnerNativeScripts = Nothing
  , txInfoInnerPlutusContracts = Nothing
  }

-- ** TxInfoInnerAssetsMintedInner
-- | TxInfoInnerAssetsMintedInner
data TxInfoInnerAssetsMintedInner = TxInfoInnerAssetsMintedInner
  { txInfoInnerAssetsMintedInnerPolicyId :: !(Maybe PolicyId) -- ^ "policy_id"
  , txInfoInnerAssetsMintedInnerAssetName :: !(Maybe AssetName) -- ^ "asset_name"
  , txInfoInnerAssetsMintedInnerQuantity :: !(Maybe Text) -- ^ "quantity" - Sum of minted assets (negative on burn)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerAssetsMintedInner
instance A.FromJSON TxInfoInnerAssetsMintedInner where
  parseJSON = A.withObject "TxInfoInnerAssetsMintedInner" $ \o ->
    TxInfoInnerAssetsMintedInner
      <$> (o .:? "policy_id")
      <*> (o .:? "asset_name")
      <*> (o .:? "quantity")

-- | ToJSON TxInfoInnerAssetsMintedInner
instance A.ToJSON TxInfoInnerAssetsMintedInner where
  toJSON TxInfoInnerAssetsMintedInner {..} =
   _omitNulls
      [ "policy_id" .= txInfoInnerAssetsMintedInnerPolicyId
      , "asset_name" .= txInfoInnerAssetsMintedInnerAssetName
      , "quantity" .= txInfoInnerAssetsMintedInnerQuantity
      ]


-- | Construct a value of type 'TxInfoInnerAssetsMintedInner' (by applying it's required fields, if any)
mkTxInfoInnerAssetsMintedInner
  :: TxInfoInnerAssetsMintedInner
mkTxInfoInnerAssetsMintedInner =
  TxInfoInnerAssetsMintedInner
  { txInfoInnerAssetsMintedInnerPolicyId = Nothing
  , txInfoInnerAssetsMintedInnerAssetName = Nothing
  , txInfoInnerAssetsMintedInnerQuantity = Nothing
  }

-- ** TxInfoInnerCertificatesInner
-- | TxInfoInnerCertificatesInner
data TxInfoInnerCertificatesInner = TxInfoInnerCertificatesInner
  { txInfoInnerCertificatesInnerIndex :: !(Maybe Int) -- ^ "index" - Certificate index
  , txInfoInnerCertificatesInnerType :: !(Maybe Text) -- ^ "type" - Type of certificate (could be delegation, stake_registration, stake_deregistraion, pool_update, pool_retire, param_proposal, reserve_MIR, treasury_MIR)
  , txInfoInnerCertificatesInnerInfo :: !(Maybe A.Value) -- ^ "info" - A JSON array containing information from the certificate
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerCertificatesInner
instance A.FromJSON TxInfoInnerCertificatesInner where
  parseJSON = A.withObject "TxInfoInnerCertificatesInner" $ \o ->
    TxInfoInnerCertificatesInner
      <$> (o .:? "index")
      <*> (o .:? "type")
      <*> (o .:? "info")

-- | ToJSON TxInfoInnerCertificatesInner
instance A.ToJSON TxInfoInnerCertificatesInner where
  toJSON TxInfoInnerCertificatesInner {..} =
   _omitNulls
      [ "index" .= txInfoInnerCertificatesInnerIndex
      , "type" .= txInfoInnerCertificatesInnerType
      , "info" .= txInfoInnerCertificatesInnerInfo
      ]


-- | Construct a value of type 'TxInfoInnerCertificatesInner' (by applying it's required fields, if any)
mkTxInfoInnerCertificatesInner
  :: TxInfoInnerCertificatesInner
mkTxInfoInnerCertificatesInner =
  TxInfoInnerCertificatesInner
  { txInfoInnerCertificatesInnerIndex = Nothing
  , txInfoInnerCertificatesInnerType = Nothing
  , txInfoInnerCertificatesInnerInfo = Nothing
  }

-- ** TxInfoInnerMetadataInner
-- | TxInfoInnerMetadataInner
data TxInfoInnerMetadataInner = TxInfoInnerMetadataInner
  { txInfoInnerMetadataInnerKey :: !(Maybe Text) -- ^ "key" - Metadata key (index)
  , txInfoInnerMetadataInnerJson :: !(Maybe Metadata) -- ^ "json"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerMetadataInner
instance A.FromJSON TxInfoInnerMetadataInner where
  parseJSON = A.withObject "TxInfoInnerMetadataInner" $ \o ->
    TxInfoInnerMetadataInner
      <$> (o .:? "key")
      <*> (o .:? "json")

-- | ToJSON TxInfoInnerMetadataInner
instance A.ToJSON TxInfoInnerMetadataInner where
  toJSON TxInfoInnerMetadataInner {..} =
   _omitNulls
      [ "key" .= txInfoInnerMetadataInnerKey
      , "json" .= txInfoInnerMetadataInnerJson
      ]


-- | Construct a value of type 'TxInfoInnerMetadataInner' (by applying it's required fields, if any)
mkTxInfoInnerMetadataInner
  :: TxInfoInnerMetadataInner
mkTxInfoInnerMetadataInner =
  TxInfoInnerMetadataInner
  { txInfoInnerMetadataInnerKey = Nothing
  , txInfoInnerMetadataInnerJson = Nothing
  }

-- ** TxInfoInnerNativeScriptsInner
-- | TxInfoInnerNativeScriptsInner
data TxInfoInnerNativeScriptsInner = TxInfoInnerNativeScriptsInner
  { txInfoInnerNativeScriptsInnerScriptHash :: !(Maybe ScriptHash) -- ^ "script_hash"
  , txInfoInnerNativeScriptsInnerScriptJson :: !(Maybe A.Value) -- ^ "script_json" - JSON representation of the timelock script (null for other script types)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerNativeScriptsInner
instance A.FromJSON TxInfoInnerNativeScriptsInner where
  parseJSON = A.withObject "TxInfoInnerNativeScriptsInner" $ \o ->
    TxInfoInnerNativeScriptsInner
      <$> (o .:? "script_hash")
      <*> (o .:? "script_json")

-- | ToJSON TxInfoInnerNativeScriptsInner
instance A.ToJSON TxInfoInnerNativeScriptsInner where
  toJSON TxInfoInnerNativeScriptsInner {..} =
   _omitNulls
      [ "script_hash" .= txInfoInnerNativeScriptsInnerScriptHash
      , "script_json" .= txInfoInnerNativeScriptsInnerScriptJson
      ]


-- | Construct a value of type 'TxInfoInnerNativeScriptsInner' (by applying it's required fields, if any)
mkTxInfoInnerNativeScriptsInner
  :: TxInfoInnerNativeScriptsInner
mkTxInfoInnerNativeScriptsInner =
  TxInfoInnerNativeScriptsInner
  { txInfoInnerNativeScriptsInnerScriptHash = Nothing
  , txInfoInnerNativeScriptsInnerScriptJson = Nothing
  }

-- ** TxInfoInnerOutputsInner
-- | TxInfoInnerOutputsInner
data TxInfoInnerOutputsInner = TxInfoInnerOutputsInner
  { txInfoInnerOutputsInnerPaymentAddr :: !(Maybe TxInfoInnerOutputsInnerPaymentAddr) -- ^ "payment_addr"
  , txInfoInnerOutputsInnerStakeAddr :: !(Maybe StakeAddress) -- ^ "stake_addr"
  , txInfoInnerOutputsInnerTxHash :: !(Maybe Text) -- ^ "tx_hash" - Hash of transaction for UTxO
  , txInfoInnerOutputsInnerTxIndex :: !(Maybe Int) -- ^ "tx_index" - Index of UTxO in the transaction
  , txInfoInnerOutputsInnerValue :: !(Maybe Text) -- ^ "value" - Total sum of ADA on the UTxO
  , txInfoInnerOutputsInnerDatumHash :: !(Maybe Text) -- ^ "datum_hash" - Hash of datum (if any) connected to UTxO
  , txInfoInnerOutputsInnerInlineDatum :: !(Maybe TxInfoInnerOutputsInnerInlineDatum) -- ^ "inline_datum"
  , txInfoInnerOutputsInnerReferenceScript :: !(Maybe TxInfoInnerOutputsInnerReferenceScript) -- ^ "reference_script"
  , txInfoInnerOutputsInnerAssetList :: !(Maybe [TxInfoInnerOutputsInnerAssetListInner]) -- ^ "asset_list" - An array of assets on the UTxO
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerOutputsInner
instance A.FromJSON TxInfoInnerOutputsInner where
  parseJSON = A.withObject "TxInfoInnerOutputsInner" $ \o ->
    TxInfoInnerOutputsInner
      <$> (o .:? "payment_addr")
      <*> (o .:? "stake_addr")
      <*> (o .:? "tx_hash")
      <*> (o .:? "tx_index")
      <*> (o .:? "value")
      <*> (o .:? "datum_hash")
      <*> (o .:? "inline_datum")
      <*> (o .:? "reference_script")
      <*> (o .:? "asset_list")

-- | ToJSON TxInfoInnerOutputsInner
instance A.ToJSON TxInfoInnerOutputsInner where
  toJSON TxInfoInnerOutputsInner {..} =
   _omitNulls
      [ "payment_addr" .= txInfoInnerOutputsInnerPaymentAddr
      , "stake_addr" .= txInfoInnerOutputsInnerStakeAddr
      , "tx_hash" .= txInfoInnerOutputsInnerTxHash
      , "tx_index" .= txInfoInnerOutputsInnerTxIndex
      , "value" .= txInfoInnerOutputsInnerValue
      , "datum_hash" .= txInfoInnerOutputsInnerDatumHash
      , "inline_datum" .= txInfoInnerOutputsInnerInlineDatum
      , "reference_script" .= txInfoInnerOutputsInnerReferenceScript
      , "asset_list" .= txInfoInnerOutputsInnerAssetList
      ]


-- | Construct a value of type 'TxInfoInnerOutputsInner' (by applying it's required fields, if any)
mkTxInfoInnerOutputsInner
  :: TxInfoInnerOutputsInner
mkTxInfoInnerOutputsInner =
  TxInfoInnerOutputsInner
  { txInfoInnerOutputsInnerPaymentAddr = Nothing
  , txInfoInnerOutputsInnerStakeAddr = Nothing
  , txInfoInnerOutputsInnerTxHash = Nothing
  , txInfoInnerOutputsInnerTxIndex = Nothing
  , txInfoInnerOutputsInnerValue = Nothing
  , txInfoInnerOutputsInnerDatumHash = Nothing
  , txInfoInnerOutputsInnerInlineDatum = Nothing
  , txInfoInnerOutputsInnerReferenceScript = Nothing
  , txInfoInnerOutputsInnerAssetList = Nothing
  }

-- ** TxInfoInnerOutputsInnerAssetListInner
-- | TxInfoInnerOutputsInnerAssetListInner
data TxInfoInnerOutputsInnerAssetListInner = TxInfoInnerOutputsInnerAssetListInner
  { txInfoInnerOutputsInnerAssetListInnerPolicyId :: !(Maybe PolicyId) -- ^ "policy_id"
  , txInfoInnerOutputsInnerAssetListInnerAssetName :: !(Maybe AssetName) -- ^ "asset_name"
  , txInfoInnerOutputsInnerAssetListInnerQuantity :: !(Maybe Text) -- ^ "quantity" - Quantity of assets on the UTxO
  , txInfoInnerOutputsInnerAssetListInnerFingerprint :: !(Maybe Fingerprint) -- ^ "fingerprint"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerOutputsInnerAssetListInner
instance A.FromJSON TxInfoInnerOutputsInnerAssetListInner where
  parseJSON = A.withObject "TxInfoInnerOutputsInnerAssetListInner" $ \o ->
    TxInfoInnerOutputsInnerAssetListInner
      <$> (o .:? "policy_id")
      <*> (o .:? "asset_name")
      <*> (o .:? "quantity")
      <*> (o .:? "fingerprint")

-- | ToJSON TxInfoInnerOutputsInnerAssetListInner
instance A.ToJSON TxInfoInnerOutputsInnerAssetListInner where
  toJSON TxInfoInnerOutputsInnerAssetListInner {..} =
   _omitNulls
      [ "policy_id" .= txInfoInnerOutputsInnerAssetListInnerPolicyId
      , "asset_name" .= txInfoInnerOutputsInnerAssetListInnerAssetName
      , "quantity" .= txInfoInnerOutputsInnerAssetListInnerQuantity
      , "fingerprint" .= txInfoInnerOutputsInnerAssetListInnerFingerprint
      ]


-- | Construct a value of type 'TxInfoInnerOutputsInnerAssetListInner' (by applying it's required fields, if any)
mkTxInfoInnerOutputsInnerAssetListInner
  :: TxInfoInnerOutputsInnerAssetListInner
mkTxInfoInnerOutputsInnerAssetListInner =
  TxInfoInnerOutputsInnerAssetListInner
  { txInfoInnerOutputsInnerAssetListInnerPolicyId = Nothing
  , txInfoInnerOutputsInnerAssetListInnerAssetName = Nothing
  , txInfoInnerOutputsInnerAssetListInnerQuantity = Nothing
  , txInfoInnerOutputsInnerAssetListInnerFingerprint = Nothing
  }

-- ** TxInfoInnerOutputsInnerInlineDatum
-- | TxInfoInnerOutputsInnerInlineDatum
-- Allows datums to be attached to UTxO (CIP-32)
data TxInfoInnerOutputsInnerInlineDatum = TxInfoInnerOutputsInnerInlineDatum
  { txInfoInnerOutputsInnerInlineDatumBytes :: !(Maybe Text) -- ^ "bytes" - Datum (hex)
  , txInfoInnerOutputsInnerInlineDatumValue :: !(Maybe A.Value) -- ^ "value" - Value (json)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerOutputsInnerInlineDatum
instance A.FromJSON TxInfoInnerOutputsInnerInlineDatum where
  parseJSON = A.withObject "TxInfoInnerOutputsInnerInlineDatum" $ \o ->
    TxInfoInnerOutputsInnerInlineDatum
      <$> (o .:? "bytes")
      <*> (o .:? "value")

-- | ToJSON TxInfoInnerOutputsInnerInlineDatum
instance A.ToJSON TxInfoInnerOutputsInnerInlineDatum where
  toJSON TxInfoInnerOutputsInnerInlineDatum {..} =
   _omitNulls
      [ "bytes" .= txInfoInnerOutputsInnerInlineDatumBytes
      , "value" .= txInfoInnerOutputsInnerInlineDatumValue
      ]


-- | Construct a value of type 'TxInfoInnerOutputsInnerInlineDatum' (by applying it's required fields, if any)
mkTxInfoInnerOutputsInnerInlineDatum
  :: TxInfoInnerOutputsInnerInlineDatum
mkTxInfoInnerOutputsInnerInlineDatum =
  TxInfoInnerOutputsInnerInlineDatum
  { txInfoInnerOutputsInnerInlineDatumBytes = Nothing
  , txInfoInnerOutputsInnerInlineDatumValue = Nothing
  }

-- ** TxInfoInnerOutputsInnerPaymentAddr
-- | TxInfoInnerOutputsInnerPaymentAddr
data TxInfoInnerOutputsInnerPaymentAddr = TxInfoInnerOutputsInnerPaymentAddr
  { txInfoInnerOutputsInnerPaymentAddrBech32 :: !(Maybe Text) -- ^ "bech32" - A Cardano payment/base address (bech32 encoded) where funds were sent or change to be returned
  , txInfoInnerOutputsInnerPaymentAddrCred :: !(Maybe Text) -- ^ "cred" - Payment credential
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerOutputsInnerPaymentAddr
instance A.FromJSON TxInfoInnerOutputsInnerPaymentAddr where
  parseJSON = A.withObject "TxInfoInnerOutputsInnerPaymentAddr" $ \o ->
    TxInfoInnerOutputsInnerPaymentAddr
      <$> (o .:? "bech32")
      <*> (o .:? "cred")

-- | ToJSON TxInfoInnerOutputsInnerPaymentAddr
instance A.ToJSON TxInfoInnerOutputsInnerPaymentAddr where
  toJSON TxInfoInnerOutputsInnerPaymentAddr {..} =
   _omitNulls
      [ "bech32" .= txInfoInnerOutputsInnerPaymentAddrBech32
      , "cred" .= txInfoInnerOutputsInnerPaymentAddrCred
      ]


-- | Construct a value of type 'TxInfoInnerOutputsInnerPaymentAddr' (by applying it's required fields, if any)
mkTxInfoInnerOutputsInnerPaymentAddr
  :: TxInfoInnerOutputsInnerPaymentAddr
mkTxInfoInnerOutputsInnerPaymentAddr =
  TxInfoInnerOutputsInnerPaymentAddr
  { txInfoInnerOutputsInnerPaymentAddrBech32 = Nothing
  , txInfoInnerOutputsInnerPaymentAddrCred = Nothing
  }

-- ** TxInfoInnerOutputsInnerReferenceScript
-- | TxInfoInnerOutputsInnerReferenceScript
-- Allow reference scripts to be used to satisfy script requirements during validation, rather than requiring the spending transaction to do so. (CIP-33)
data TxInfoInnerOutputsInnerReferenceScript = TxInfoInnerOutputsInnerReferenceScript
  { txInfoInnerOutputsInnerReferenceScriptHash :: !(Maybe Text) -- ^ "hash" - Hash of referenced script
  , txInfoInnerOutputsInnerReferenceScriptSize :: !(Maybe Int) -- ^ "size" - Size in bytes
  , txInfoInnerOutputsInnerReferenceScriptType :: !(Maybe Text) -- ^ "type" - Type of script
  , txInfoInnerOutputsInnerReferenceScriptBytes :: !(Maybe Text) -- ^ "bytes" - Script bytes (hex)
  , txInfoInnerOutputsInnerReferenceScriptValue :: !(Maybe A.Value) -- ^ "value" - Value (json)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerOutputsInnerReferenceScript
instance A.FromJSON TxInfoInnerOutputsInnerReferenceScript where
  parseJSON = A.withObject "TxInfoInnerOutputsInnerReferenceScript" $ \o ->
    TxInfoInnerOutputsInnerReferenceScript
      <$> (o .:? "hash")
      <*> (o .:? "size")
      <*> (o .:? "type")
      <*> (o .:? "bytes")
      <*> (o .:? "value")

-- | ToJSON TxInfoInnerOutputsInnerReferenceScript
instance A.ToJSON TxInfoInnerOutputsInnerReferenceScript where
  toJSON TxInfoInnerOutputsInnerReferenceScript {..} =
   _omitNulls
      [ "hash" .= txInfoInnerOutputsInnerReferenceScriptHash
      , "size" .= txInfoInnerOutputsInnerReferenceScriptSize
      , "type" .= txInfoInnerOutputsInnerReferenceScriptType
      , "bytes" .= txInfoInnerOutputsInnerReferenceScriptBytes
      , "value" .= txInfoInnerOutputsInnerReferenceScriptValue
      ]


-- | Construct a value of type 'TxInfoInnerOutputsInnerReferenceScript' (by applying it's required fields, if any)
mkTxInfoInnerOutputsInnerReferenceScript
  :: TxInfoInnerOutputsInnerReferenceScript
mkTxInfoInnerOutputsInnerReferenceScript =
  TxInfoInnerOutputsInnerReferenceScript
  { txInfoInnerOutputsInnerReferenceScriptHash = Nothing
  , txInfoInnerOutputsInnerReferenceScriptSize = Nothing
  , txInfoInnerOutputsInnerReferenceScriptType = Nothing
  , txInfoInnerOutputsInnerReferenceScriptBytes = Nothing
  , txInfoInnerOutputsInnerReferenceScriptValue = Nothing
  }

-- ** TxInfoInnerPlutusContractsInner
-- | TxInfoInnerPlutusContractsInner
data TxInfoInnerPlutusContractsInner = TxInfoInnerPlutusContractsInner
  { txInfoInnerPlutusContractsInnerAddress :: !(Maybe Text) -- ^ "address" - Plutus script address
  , txInfoInnerPlutusContractsInnerScriptHash :: !(Maybe ScriptHash) -- ^ "script_hash"
  , txInfoInnerPlutusContractsInnerBytecode :: !(Maybe Text) -- ^ "bytecode" - CBOR-encoded Plutus script data
  , txInfoInnerPlutusContractsInnerSize :: !(Maybe Int) -- ^ "size" - The size of the CBOR serialised script (in bytes)
  , txInfoInnerPlutusContractsInnerValidContract :: !(Maybe Bool) -- ^ "valid_contract" - True if the contract is valid or there is no contract
  , txInfoInnerPlutusContractsInnerInput :: !(Maybe TxInfoInnerPlutusContractsInnerInput) -- ^ "input"
  , txInfoInnerPlutusContractsInnerOutput :: !(Maybe TxInfoInnerPlutusContractsInnerInputRedeemerDatum) -- ^ "output"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerPlutusContractsInner
instance A.FromJSON TxInfoInnerPlutusContractsInner where
  parseJSON = A.withObject "TxInfoInnerPlutusContractsInner" $ \o ->
    TxInfoInnerPlutusContractsInner
      <$> (o .:? "address")
      <*> (o .:? "script_hash")
      <*> (o .:? "bytecode")
      <*> (o .:? "size")
      <*> (o .:? "valid_contract")
      <*> (o .:? "input")
      <*> (o .:? "output")

-- | ToJSON TxInfoInnerPlutusContractsInner
instance A.ToJSON TxInfoInnerPlutusContractsInner where
  toJSON TxInfoInnerPlutusContractsInner {..} =
   _omitNulls
      [ "address" .= txInfoInnerPlutusContractsInnerAddress
      , "script_hash" .= txInfoInnerPlutusContractsInnerScriptHash
      , "bytecode" .= txInfoInnerPlutusContractsInnerBytecode
      , "size" .= txInfoInnerPlutusContractsInnerSize
      , "valid_contract" .= txInfoInnerPlutusContractsInnerValidContract
      , "input" .= txInfoInnerPlutusContractsInnerInput
      , "output" .= txInfoInnerPlutusContractsInnerOutput
      ]


-- | Construct a value of type 'TxInfoInnerPlutusContractsInner' (by applying it's required fields, if any)
mkTxInfoInnerPlutusContractsInner
  :: TxInfoInnerPlutusContractsInner
mkTxInfoInnerPlutusContractsInner =
  TxInfoInnerPlutusContractsInner
  { txInfoInnerPlutusContractsInnerAddress = Nothing
  , txInfoInnerPlutusContractsInnerScriptHash = Nothing
  , txInfoInnerPlutusContractsInnerBytecode = Nothing
  , txInfoInnerPlutusContractsInnerSize = Nothing
  , txInfoInnerPlutusContractsInnerValidContract = Nothing
  , txInfoInnerPlutusContractsInnerInput = Nothing
  , txInfoInnerPlutusContractsInnerOutput = Nothing
  }

-- ** TxInfoInnerPlutusContractsInnerInput
-- | TxInfoInnerPlutusContractsInnerInput
data TxInfoInnerPlutusContractsInnerInput = TxInfoInnerPlutusContractsInnerInput
  { txInfoInnerPlutusContractsInnerInputRedeemer :: !(Maybe TxInfoInnerPlutusContractsInnerInputRedeemer) -- ^ "redeemer"
  , txInfoInnerPlutusContractsInnerInputDatum :: !(Maybe TxInfoInnerPlutusContractsInnerInputRedeemerDatum) -- ^ "datum"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerPlutusContractsInnerInput
instance A.FromJSON TxInfoInnerPlutusContractsInnerInput where
  parseJSON = A.withObject "TxInfoInnerPlutusContractsInnerInput" $ \o ->
    TxInfoInnerPlutusContractsInnerInput
      <$> (o .:? "redeemer")
      <*> (o .:? "datum")

-- | ToJSON TxInfoInnerPlutusContractsInnerInput
instance A.ToJSON TxInfoInnerPlutusContractsInnerInput where
  toJSON TxInfoInnerPlutusContractsInnerInput {..} =
   _omitNulls
      [ "redeemer" .= txInfoInnerPlutusContractsInnerInputRedeemer
      , "datum" .= txInfoInnerPlutusContractsInnerInputDatum
      ]


-- | Construct a value of type 'TxInfoInnerPlutusContractsInnerInput' (by applying it's required fields, if any)
mkTxInfoInnerPlutusContractsInnerInput
  :: TxInfoInnerPlutusContractsInnerInput
mkTxInfoInnerPlutusContractsInnerInput =
  TxInfoInnerPlutusContractsInnerInput
  { txInfoInnerPlutusContractsInnerInputRedeemer = Nothing
  , txInfoInnerPlutusContractsInnerInputDatum = Nothing
  }

-- ** TxInfoInnerPlutusContractsInnerInputRedeemer
-- | TxInfoInnerPlutusContractsInnerInputRedeemer
data TxInfoInnerPlutusContractsInnerInputRedeemer = TxInfoInnerPlutusContractsInnerInputRedeemer
  { txInfoInnerPlutusContractsInnerInputRedeemerPurpose :: !(Maybe Purpose) -- ^ "purpose"
  , txInfoInnerPlutusContractsInnerInputRedeemerFee :: !(Maybe Fee) -- ^ "fee"
  , txInfoInnerPlutusContractsInnerInputRedeemerUnit :: !(Maybe TxInfoInnerPlutusContractsInnerInputRedeemerUnit) -- ^ "unit"
  , txInfoInnerPlutusContractsInnerInputRedeemerDatum :: !(Maybe TxInfoInnerPlutusContractsInnerInputRedeemerDatum) -- ^ "datum"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerPlutusContractsInnerInputRedeemer
instance A.FromJSON TxInfoInnerPlutusContractsInnerInputRedeemer where
  parseJSON = A.withObject "TxInfoInnerPlutusContractsInnerInputRedeemer" $ \o ->
    TxInfoInnerPlutusContractsInnerInputRedeemer
      <$> (o .:? "purpose")
      <*> (o .:? "fee")
      <*> (o .:? "unit")
      <*> (o .:? "datum")

-- | ToJSON TxInfoInnerPlutusContractsInnerInputRedeemer
instance A.ToJSON TxInfoInnerPlutusContractsInnerInputRedeemer where
  toJSON TxInfoInnerPlutusContractsInnerInputRedeemer {..} =
   _omitNulls
      [ "purpose" .= txInfoInnerPlutusContractsInnerInputRedeemerPurpose
      , "fee" .= txInfoInnerPlutusContractsInnerInputRedeemerFee
      , "unit" .= txInfoInnerPlutusContractsInnerInputRedeemerUnit
      , "datum" .= txInfoInnerPlutusContractsInnerInputRedeemerDatum
      ]


-- | Construct a value of type 'TxInfoInnerPlutusContractsInnerInputRedeemer' (by applying it's required fields, if any)
mkTxInfoInnerPlutusContractsInnerInputRedeemer
  :: TxInfoInnerPlutusContractsInnerInputRedeemer
mkTxInfoInnerPlutusContractsInnerInputRedeemer =
  TxInfoInnerPlutusContractsInnerInputRedeemer
  { txInfoInnerPlutusContractsInnerInputRedeemerPurpose = Nothing
  , txInfoInnerPlutusContractsInnerInputRedeemerFee = Nothing
  , txInfoInnerPlutusContractsInnerInputRedeemerUnit = Nothing
  , txInfoInnerPlutusContractsInnerInputRedeemerDatum = Nothing
  }

-- ** TxInfoInnerPlutusContractsInnerInputRedeemerDatum
-- | TxInfoInnerPlutusContractsInnerInputRedeemerDatum
data TxInfoInnerPlutusContractsInnerInputRedeemerDatum = TxInfoInnerPlutusContractsInnerInputRedeemerDatum
  { txInfoInnerPlutusContractsInnerInputRedeemerDatumHash :: !(Maybe DatumHash) -- ^ "hash"
  , txInfoInnerPlutusContractsInnerInputRedeemerDatumValue :: !(Maybe DatumValue) -- ^ "value"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerPlutusContractsInnerInputRedeemerDatum
instance A.FromJSON TxInfoInnerPlutusContractsInnerInputRedeemerDatum where
  parseJSON = A.withObject "TxInfoInnerPlutusContractsInnerInputRedeemerDatum" $ \o ->
    TxInfoInnerPlutusContractsInnerInputRedeemerDatum
      <$> (o .:? "hash")
      <*> (o .:? "value")

-- | ToJSON TxInfoInnerPlutusContractsInnerInputRedeemerDatum
instance A.ToJSON TxInfoInnerPlutusContractsInnerInputRedeemerDatum where
  toJSON TxInfoInnerPlutusContractsInnerInputRedeemerDatum {..} =
   _omitNulls
      [ "hash" .= txInfoInnerPlutusContractsInnerInputRedeemerDatumHash
      , "value" .= txInfoInnerPlutusContractsInnerInputRedeemerDatumValue
      ]


-- | Construct a value of type 'TxInfoInnerPlutusContractsInnerInputRedeemerDatum' (by applying it's required fields, if any)
mkTxInfoInnerPlutusContractsInnerInputRedeemerDatum
  :: TxInfoInnerPlutusContractsInnerInputRedeemerDatum
mkTxInfoInnerPlutusContractsInnerInputRedeemerDatum =
  TxInfoInnerPlutusContractsInnerInputRedeemerDatum
  { txInfoInnerPlutusContractsInnerInputRedeemerDatumHash = Nothing
  , txInfoInnerPlutusContractsInnerInputRedeemerDatumValue = Nothing
  }

-- ** TxInfoInnerPlutusContractsInnerInputRedeemerUnit
-- | TxInfoInnerPlutusContractsInnerInputRedeemerUnit
data TxInfoInnerPlutusContractsInnerInputRedeemerUnit = TxInfoInnerPlutusContractsInnerInputRedeemerUnit
  { txInfoInnerPlutusContractsInnerInputRedeemerUnitSteps :: !(Maybe UnitSteps) -- ^ "steps"
  , txInfoInnerPlutusContractsInnerInputRedeemerUnitMem :: !(Maybe UnitMem) -- ^ "mem"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerPlutusContractsInnerInputRedeemerUnit
instance A.FromJSON TxInfoInnerPlutusContractsInnerInputRedeemerUnit where
  parseJSON = A.withObject "TxInfoInnerPlutusContractsInnerInputRedeemerUnit" $ \o ->
    TxInfoInnerPlutusContractsInnerInputRedeemerUnit
      <$> (o .:? "steps")
      <*> (o .:? "mem")

-- | ToJSON TxInfoInnerPlutusContractsInnerInputRedeemerUnit
instance A.ToJSON TxInfoInnerPlutusContractsInnerInputRedeemerUnit where
  toJSON TxInfoInnerPlutusContractsInnerInputRedeemerUnit {..} =
   _omitNulls
      [ "steps" .= txInfoInnerPlutusContractsInnerInputRedeemerUnitSteps
      , "mem" .= txInfoInnerPlutusContractsInnerInputRedeemerUnitMem
      ]


-- | Construct a value of type 'TxInfoInnerPlutusContractsInnerInputRedeemerUnit' (by applying it's required fields, if any)
mkTxInfoInnerPlutusContractsInnerInputRedeemerUnit
  :: TxInfoInnerPlutusContractsInnerInputRedeemerUnit
mkTxInfoInnerPlutusContractsInnerInputRedeemerUnit =
  TxInfoInnerPlutusContractsInnerInputRedeemerUnit
  { txInfoInnerPlutusContractsInnerInputRedeemerUnitSteps = Nothing
  , txInfoInnerPlutusContractsInnerInputRedeemerUnitMem = Nothing
  }

-- ** TxInfoInnerWithdrawalsInner
-- | TxInfoInnerWithdrawalsInner
data TxInfoInnerWithdrawalsInner = TxInfoInnerWithdrawalsInner
  { txInfoInnerWithdrawalsInnerAmount :: !(Maybe Text) -- ^ "amount" - Withdrawal amount (in lovelaces)
  , txInfoInnerWithdrawalsInnerStakeAddr :: !(Maybe TxInfoInnerWithdrawalsInnerStakeAddr) -- ^ "stake_addr"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerWithdrawalsInner
instance A.FromJSON TxInfoInnerWithdrawalsInner where
  parseJSON = A.withObject "TxInfoInnerWithdrawalsInner" $ \o ->
    TxInfoInnerWithdrawalsInner
      <$> (o .:? "amount")
      <*> (o .:? "stake_addr")

-- | ToJSON TxInfoInnerWithdrawalsInner
instance A.ToJSON TxInfoInnerWithdrawalsInner where
  toJSON TxInfoInnerWithdrawalsInner {..} =
   _omitNulls
      [ "amount" .= txInfoInnerWithdrawalsInnerAmount
      , "stake_addr" .= txInfoInnerWithdrawalsInnerStakeAddr
      ]


-- | Construct a value of type 'TxInfoInnerWithdrawalsInner' (by applying it's required fields, if any)
mkTxInfoInnerWithdrawalsInner
  :: TxInfoInnerWithdrawalsInner
mkTxInfoInnerWithdrawalsInner =
  TxInfoInnerWithdrawalsInner
  { txInfoInnerWithdrawalsInnerAmount = Nothing
  , txInfoInnerWithdrawalsInnerStakeAddr = Nothing
  }

-- ** TxInfoInnerWithdrawalsInnerStakeAddr
-- | TxInfoInnerWithdrawalsInnerStakeAddr
data TxInfoInnerWithdrawalsInnerStakeAddr = TxInfoInnerWithdrawalsInnerStakeAddr
  { txInfoInnerWithdrawalsInnerStakeAddrBech32 :: !(Maybe Text) -- ^ "bech32" - A Cardano staking address (reward account, bech32 encoded)
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoInnerWithdrawalsInnerStakeAddr
instance A.FromJSON TxInfoInnerWithdrawalsInnerStakeAddr where
  parseJSON = A.withObject "TxInfoInnerWithdrawalsInnerStakeAddr" $ \o ->
    TxInfoInnerWithdrawalsInnerStakeAddr
      <$> (o .:? "bech32")

-- | ToJSON TxInfoInnerWithdrawalsInnerStakeAddr
instance A.ToJSON TxInfoInnerWithdrawalsInnerStakeAddr where
  toJSON TxInfoInnerWithdrawalsInnerStakeAddr {..} =
   _omitNulls
      [ "bech32" .= txInfoInnerWithdrawalsInnerStakeAddrBech32
      ]


-- | Construct a value of type 'TxInfoInnerWithdrawalsInnerStakeAddr' (by applying it's required fields, if any)
mkTxInfoInnerWithdrawalsInnerStakeAddr
  :: TxInfoInnerWithdrawalsInnerStakeAddr
mkTxInfoInnerWithdrawalsInnerStakeAddr =
  TxInfoInnerWithdrawalsInnerStakeAddr
  { txInfoInnerWithdrawalsInnerStakeAddrBech32 = Nothing
  }

-- ** TxInfoPostRequest
-- | TxInfoPostRequest
data TxInfoPostRequest = TxInfoPostRequest
  { txInfoPostRequestTxHashes :: !([Text]) -- ^ /Required/ "_tx_hashes" - Array of Cardano Transaction hashes
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxInfoPostRequest
instance A.FromJSON TxInfoPostRequest where
  parseJSON = A.withObject "TxInfoPostRequest" $ \o ->
    TxInfoPostRequest
      <$> (o .:  "_tx_hashes")

-- | ToJSON TxInfoPostRequest
instance A.ToJSON TxInfoPostRequest where
  toJSON TxInfoPostRequest {..} =
   _omitNulls
      [ "_tx_hashes" .= txInfoPostRequestTxHashes
      ]


-- | Construct a value of type 'TxInfoPostRequest' (by applying it's required fields, if any)
mkTxInfoPostRequest
  :: [Text] -- ^ 'txInfoPostRequestTxHashes': Array of Cardano Transaction hashes
  -> TxInfoPostRequest
mkTxInfoPostRequest txInfoPostRequestTxHashes =
  TxInfoPostRequest
  { txInfoPostRequestTxHashes
  }

-- ** TxMetadataInner
-- | TxMetadataInner
data TxMetadataInner = TxMetadataInner
  { txMetadataInnerTxHash :: !(Maybe TxHash) -- ^ "tx_hash"
  , txMetadataInnerMetadata :: !(Maybe A.Value) -- ^ "metadata" - A JSON array containing details about metadata within transaction
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxMetadataInner
instance A.FromJSON TxMetadataInner where
  parseJSON = A.withObject "TxMetadataInner" $ \o ->
    TxMetadataInner
      <$> (o .:? "tx_hash")
      <*> (o .:? "metadata")

-- | ToJSON TxMetadataInner
instance A.ToJSON TxMetadataInner where
  toJSON TxMetadataInner {..} =
   _omitNulls
      [ "tx_hash" .= txMetadataInnerTxHash
      , "metadata" .= txMetadataInnerMetadata
      ]


-- | Construct a value of type 'TxMetadataInner' (by applying it's required fields, if any)
mkTxMetadataInner
  :: TxMetadataInner
mkTxMetadataInner =
  TxMetadataInner
  { txMetadataInnerTxHash = Nothing
  , txMetadataInnerMetadata = Nothing
  }

-- ** TxMetalabelsInner
-- | TxMetalabelsInner
data TxMetalabelsInner = TxMetalabelsInner
  { txMetalabelsInnerKey :: !(Maybe Text) -- ^ "key" - A distinct known metalabel
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxMetalabelsInner
instance A.FromJSON TxMetalabelsInner where
  parseJSON = A.withObject "TxMetalabelsInner" $ \o ->
    TxMetalabelsInner
      <$> (o .:? "key")

-- | ToJSON TxMetalabelsInner
instance A.ToJSON TxMetalabelsInner where
  toJSON TxMetalabelsInner {..} =
   _omitNulls
      [ "key" .= txMetalabelsInnerKey
      ]


-- | Construct a value of type 'TxMetalabelsInner' (by applying it's required fields, if any)
mkTxMetalabelsInner
  :: TxMetalabelsInner
mkTxMetalabelsInner =
  TxMetalabelsInner
  { txMetalabelsInnerKey = Nothing
  }

-- ** TxStatusInner
-- | TxStatusInner
data TxStatusInner = TxStatusInner
  { txStatusInnerTxHash :: !(Maybe TxHash) -- ^ "tx_hash"
  , txStatusInnerNumConfirmations :: !(Maybe Int) -- ^ "num_confirmations" - Number of block confirmations
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxStatusInner
instance A.FromJSON TxStatusInner where
  parseJSON = A.withObject "TxStatusInner" $ \o ->
    TxStatusInner
      <$> (o .:? "tx_hash")
      <*> (o .:? "num_confirmations")

-- | ToJSON TxStatusInner
instance A.ToJSON TxStatusInner where
  toJSON TxStatusInner {..} =
   _omitNulls
      [ "tx_hash" .= txStatusInnerTxHash
      , "num_confirmations" .= txStatusInnerNumConfirmations
      ]


-- | Construct a value of type 'TxStatusInner' (by applying it's required fields, if any)
mkTxStatusInner
  :: TxStatusInner
mkTxStatusInner =
  TxStatusInner
  { txStatusInnerTxHash = Nothing
  , txStatusInnerNumConfirmations = Nothing
  }

-- ** TxUtxosInner
-- | TxUtxosInner
data TxUtxosInner = TxUtxosInner
  { txUtxosInnerTxHash :: !(Maybe TxHash) -- ^ "tx_hash"
  , txUtxosInnerInputs :: !(Maybe Inputs) -- ^ "inputs"
  , txUtxosInnerOutputs :: !(Maybe Outputs) -- ^ "outputs"
  } deriving (P.Show, P.Eq, P.Typeable)

-- | FromJSON TxUtxosInner
instance A.FromJSON TxUtxosInner where
  parseJSON = A.withObject "TxUtxosInner" $ \o ->
    TxUtxosInner
      <$> (o .:? "tx_hash")
      <*> (o .:? "inputs")
      <*> (o .:? "outputs")

-- | ToJSON TxUtxosInner
instance A.ToJSON TxUtxosInner where
  toJSON TxUtxosInner {..} =
   _omitNulls
      [ "tx_hash" .= txUtxosInnerTxHash
      , "inputs" .= txUtxosInnerInputs
      , "outputs" .= txUtxosInnerOutputs
      ]


-- | Construct a value of type 'TxUtxosInner' (by applying it's required fields, if any)
mkTxUtxosInner
  :: TxUtxosInner
mkTxUtxosInner =
  TxUtxosInner
  { txUtxosInnerTxHash = Nothing
  , txUtxosInnerInputs = Nothing
  , txUtxosInnerOutputs = Nothing
  }


-- * Enums


-- ** E'ActionType

-- | Enum of 'Text' .
-- Type of certificate submitted
data E'ActionType
  = E'ActionType'Registration -- ^ @"registration"@
  | E'ActionType'Delegation -- ^ @"delegation"@
  | E'ActionType'Withdrawal -- ^ @"withdrawal"@
  | E'ActionType'Deregistration -- ^ @"deregistration"@
  deriving (P.Show, P.Eq, P.Typeable, P.Ord, P.Bounded, P.Enum)

instance A.ToJSON E'ActionType where toJSON = A.toJSON . fromE'ActionType
instance A.FromJSON E'ActionType where parseJSON o = P.either P.fail (pure . P.id) . toE'ActionType =<< A.parseJSON o
instance WH.ToHttpApiData E'ActionType where toQueryParam = WH.toQueryParam . fromE'ActionType
instance WH.FromHttpApiData E'ActionType where parseQueryParam o = WH.parseQueryParam o >>= P.left T.pack . toE'ActionType
instance MimeRender MimeMultipartFormData E'ActionType where mimeRender _ = mimeRenderDefaultMultipartFormData

-- | unwrap 'E'ActionType' enum
fromE'ActionType :: E'ActionType -> Text
fromE'ActionType = \case
  E'ActionType'Registration -> "registration"
  E'ActionType'Delegation -> "delegation"
  E'ActionType'Withdrawal -> "withdrawal"
  E'ActionType'Deregistration -> "deregistration"

-- | parse 'E'ActionType' enum
toE'ActionType :: Text -> P.Either String E'ActionType
toE'ActionType = \case
  "registration" -> P.Right E'ActionType'Registration
  "delegation" -> P.Right E'ActionType'Delegation
  "withdrawal" -> P.Right E'ActionType'Withdrawal
  "deregistration" -> P.Right E'ActionType'Deregistration
  s -> P.Left $ "toE'ActionType: enum parse failure: " P.++ P.show s


-- ** E'PoolStatus

-- | Enum of 'Text' .
-- Pool status
data E'PoolStatus
  = E'PoolStatus'Registered -- ^ @"registered"@
  | E'PoolStatus'Retiring -- ^ @"retiring"@
  | E'PoolStatus'Retired -- ^ @"retired"@
  deriving (P.Show, P.Eq, P.Typeable, P.Ord, P.Bounded, P.Enum)

instance A.ToJSON E'PoolStatus where toJSON = A.toJSON . fromE'PoolStatus
instance A.FromJSON E'PoolStatus where parseJSON o = P.either P.fail (pure . P.id) . toE'PoolStatus =<< A.parseJSON o
instance WH.ToHttpApiData E'PoolStatus where toQueryParam = WH.toQueryParam . fromE'PoolStatus
instance WH.FromHttpApiData E'PoolStatus where parseQueryParam o = WH.parseQueryParam o >>= P.left T.pack . toE'PoolStatus
instance MimeRender MimeMultipartFormData E'PoolStatus where mimeRender _ = mimeRenderDefaultMultipartFormData

-- | unwrap 'E'PoolStatus' enum
fromE'PoolStatus :: E'PoolStatus -> Text
fromE'PoolStatus = \case
  E'PoolStatus'Registered -> "registered"
  E'PoolStatus'Retiring -> "retiring"
  E'PoolStatus'Retired -> "retired"

-- | parse 'E'PoolStatus' enum
toE'PoolStatus :: Text -> P.Either String E'PoolStatus
toE'PoolStatus = \case
  "registered" -> P.Right E'PoolStatus'Registered
  "retiring" -> P.Right E'PoolStatus'Retiring
  "retired" -> P.Right E'PoolStatus'Retired
  s -> P.Left $ "toE'PoolStatus: enum parse failure: " P.++ P.show s


-- ** E'Purpose

-- | Enum of 'Text' .
-- What kind of validation this redeemer is used for
data E'Purpose
  = E'Purpose'Spend -- ^ @"spend"@
  | E'Purpose'Mint -- ^ @"mint"@
  | E'Purpose'Cert -- ^ @"cert"@
  | E'Purpose'Reward -- ^ @"reward"@
  deriving (P.Show, P.Eq, P.Typeable, P.Ord, P.Bounded, P.Enum)

instance A.ToJSON E'Purpose where toJSON = A.toJSON . fromE'Purpose
instance A.FromJSON E'Purpose where parseJSON o = P.either P.fail (pure . P.id) . toE'Purpose =<< A.parseJSON o
instance WH.ToHttpApiData E'Purpose where toQueryParam = WH.toQueryParam . fromE'Purpose
instance WH.FromHttpApiData E'Purpose where parseQueryParam o = WH.parseQueryParam o >>= P.left T.pack . toE'Purpose
instance MimeRender MimeMultipartFormData E'Purpose where mimeRender _ = mimeRenderDefaultMultipartFormData

-- | unwrap 'E'Purpose' enum
fromE'Purpose :: E'Purpose -> Text
fromE'Purpose = \case
  E'Purpose'Spend -> "spend"
  E'Purpose'Mint -> "mint"
  E'Purpose'Cert -> "cert"
  E'Purpose'Reward -> "reward"

-- | parse 'E'Purpose' enum
toE'Purpose :: Text -> P.Either String E'Purpose
toE'Purpose = \case
  "spend" -> P.Right E'Purpose'Spend
  "mint" -> P.Right E'Purpose'Mint
  "cert" -> P.Right E'Purpose'Cert
  "reward" -> P.Right E'Purpose'Reward
  s -> P.Left $ "toE'Purpose: enum parse failure: " P.++ P.show s


-- ** E'Status

-- | Enum of 'Text' .
-- Stake address status
data E'Status
  = E'Status'Registered -- ^ @"registered"@
  | E'Status'Not_registered -- ^ @"not registered"@
  deriving (P.Show, P.Eq, P.Typeable, P.Ord, P.Bounded, P.Enum)

instance A.ToJSON E'Status where toJSON = A.toJSON . fromE'Status
instance A.FromJSON E'Status where parseJSON o = P.either P.fail (pure . P.id) . toE'Status =<< A.parseJSON o
instance WH.ToHttpApiData E'Status where toQueryParam = WH.toQueryParam . fromE'Status
instance WH.FromHttpApiData E'Status where parseQueryParam o = WH.parseQueryParam o >>= P.left T.pack . toE'Status
instance MimeRender MimeMultipartFormData E'Status where mimeRender _ = mimeRenderDefaultMultipartFormData

-- | unwrap 'E'Status' enum
fromE'Status :: E'Status -> Text
fromE'Status = \case
  E'Status'Registered -> "registered"
  E'Status'Not_registered -> "not registered"

-- | parse 'E'Status' enum
toE'Status :: Text -> P.Either String E'Status
toE'Status = \case
  "registered" -> P.Right E'Status'Registered
  "not registered" -> P.Right E'Status'Not_registered
  s -> P.Left $ "toE'Status: enum parse failure: " P.++ P.show s


-- ** E'Type

-- | Enum of 'Text' .
-- The source of the rewards
data E'Type
  = E'Type'Member -- ^ @"member"@
  | E'Type'Leader -- ^ @"leader"@
  | E'Type'Treasury -- ^ @"treasury"@
  | E'Type'Reserves -- ^ @"reserves"@
  deriving (P.Show, P.Eq, P.Typeable, P.Ord, P.Bounded, P.Enum)

instance A.ToJSON E'Type where toJSON = A.toJSON . fromE'Type
instance A.FromJSON E'Type where parseJSON o = P.either P.fail (pure . P.id) . toE'Type =<< A.parseJSON o
instance WH.ToHttpApiData E'Type where toQueryParam = WH.toQueryParam . fromE'Type
instance WH.FromHttpApiData E'Type where parseQueryParam o = WH.parseQueryParam o >>= P.left T.pack . toE'Type
instance MimeRender MimeMultipartFormData E'Type where mimeRender _ = mimeRenderDefaultMultipartFormData

-- | unwrap 'E'Type' enum
fromE'Type :: E'Type -> Text
fromE'Type = \case
  E'Type'Member -> "member"
  E'Type'Leader -> "leader"
  E'Type'Treasury -> "treasury"
  E'Type'Reserves -> "reserves"

-- | parse 'E'Type' enum
toE'Type :: Text -> P.Either String E'Type
toE'Type = \case
  "member" -> P.Right E'Type'Member
  "leader" -> P.Right E'Type'Leader
  "treasury" -> P.Right E'Type'Treasury
  "reserves" -> P.Right E'Type'Reserves
  s -> P.Left $ "toE'Type: enum parse failure: " P.++ P.show s


-- ** E'Type2

-- | Enum of 'Text' .
-- Type of the script
data E'Type2
  = E'Type2'Timelock -- ^ @"timelock"@
  | E'Type2'Multisig -- ^ @"multisig"@
  deriving (P.Show, P.Eq, P.Typeable, P.Ord, P.Bounded, P.Enum)

instance A.ToJSON E'Type2 where toJSON = A.toJSON . fromE'Type2
instance A.FromJSON E'Type2 where parseJSON o = P.either P.fail (pure . P.id) . toE'Type2 =<< A.parseJSON o
instance WH.ToHttpApiData E'Type2 where toQueryParam = WH.toQueryParam . fromE'Type2
instance WH.FromHttpApiData E'Type2 where parseQueryParam o = WH.parseQueryParam o >>= P.left T.pack . toE'Type2
instance MimeRender MimeMultipartFormData E'Type2 where mimeRender _ = mimeRenderDefaultMultipartFormData

-- | unwrap 'E'Type2' enum
fromE'Type2 :: E'Type2 -> Text
fromE'Type2 = \case
  E'Type2'Timelock -> "timelock"
  E'Type2'Multisig -> "multisig"

-- | parse 'E'Type2' enum
toE'Type2 :: Text -> P.Either String E'Type2
toE'Type2 = \case
  "timelock" -> P.Right E'Type2'Timelock
  "multisig" -> P.Right E'Type2'Multisig
  s -> P.Left $ "toE'Type2: enum parse failure: " P.++ P.show s



