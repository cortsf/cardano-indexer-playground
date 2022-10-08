{-# LANGUAGE CPP #-}
{-# OPTIONS_GHC -fno-warn-unused-imports -fno-warn-unused-matches #-}

module Instances where

import Koios.Model
import Koios.Core

import qualified Data.Aeson as A
import qualified Data.ByteString.Lazy as BL
import qualified Data.HashMap.Strict as HM
import qualified Data.Set as Set
import qualified Data.Text as T
import qualified Data.Time as TI
import qualified Data.Vector as V
import Data.String (fromString)

import Control.Monad
import Data.Char (isSpace)
import Data.List (sort)
import Test.QuickCheck

import ApproxEq

instance Arbitrary T.Text where
  arbitrary = T.pack <$> arbitrary

instance Arbitrary TI.Day where
  arbitrary = TI.ModifiedJulianDay . (2000 +) <$> arbitrary
  shrink = (TI.ModifiedJulianDay <$>) . shrink . TI.toModifiedJulianDay

instance Arbitrary TI.UTCTime where
  arbitrary =
    TI.UTCTime <$> arbitrary <*> (TI.secondsToDiffTime <$> choose (0, 86401))

instance Arbitrary BL.ByteString where
    arbitrary = BL.pack <$> arbitrary
    shrink xs = BL.pack <$> shrink (BL.unpack xs)

instance Arbitrary ByteArray where
    arbitrary = ByteArray <$> arbitrary
    shrink (ByteArray xs) = ByteArray <$> shrink xs

instance Arbitrary Binary where
    arbitrary = Binary <$> arbitrary
    shrink (Binary xs) = Binary <$> shrink xs

instance Arbitrary DateTime where
    arbitrary = DateTime <$> arbitrary
    shrink (DateTime xs) = DateTime <$> shrink xs

instance Arbitrary Date where
    arbitrary = Date <$> arbitrary
    shrink (Date xs) = Date <$> shrink xs

#if MIN_VERSION_aeson(2,0,0)
#else
-- | A naive Arbitrary instance for A.Value:
instance Arbitrary A.Value where
  arbitrary = arbitraryValue
#endif

arbitraryValue :: Gen A.Value
arbitraryValue =
  frequency [(3, simpleTypes), (1, arrayTypes), (1, objectTypes)]
    where
      simpleTypes :: Gen A.Value
      simpleTypes =
        frequency
          [ (1, return A.Null)
          , (2, liftM A.Bool (arbitrary :: Gen Bool))
          , (2, liftM (A.Number . fromIntegral) (arbitrary :: Gen Int))
          , (2, liftM (A.String . T.pack) (arbitrary :: Gen String))
          ]
      mapF (k, v) = (fromString k, v)
      simpleAndArrays = frequency [(1, sized sizedArray), (4, simpleTypes)]
      arrayTypes = sized sizedArray
      objectTypes = sized sizedObject
      sizedArray n = liftM (A.Array . V.fromList) $ replicateM n simpleTypes
      sizedObject n =
        liftM (A.object . map mapF) $
        replicateM n $ (,) <$> (arbitrary :: Gen String) <*> simpleAndArrays

-- | Checks if a given list has no duplicates in _O(n log n)_.
hasNoDups
  :: (Ord a)
  => [a] -> Bool
hasNoDups = go Set.empty
  where
    go _ [] = True
    go s (x:xs)
      | s' <- Set.insert x s
      , Set.size s' > Set.size s = go s' xs
      | otherwise = False

instance ApproxEq TI.Day where
  (=~) = (==)

arbitraryReduced :: Arbitrary a => Int -> Gen a
arbitraryReduced n = resize (n `div` 2) arbitrary

arbitraryReducedMaybe :: Arbitrary a => Int -> Gen (Maybe a)
arbitraryReducedMaybe 0 = elements [Nothing]
arbitraryReducedMaybe n = arbitraryReduced n

arbitraryReducedMaybeValue :: Int -> Gen (Maybe A.Value)
arbitraryReducedMaybeValue 0 = elements [Nothing]
arbitraryReducedMaybeValue n = do
  generated <- arbitraryReduced n
  if generated == Just A.Null
    then return Nothing
    else return generated

-- * Models

instance Arbitrary AccountAddressesInner where
  arbitrary = sized genAccountAddressesInner

genAccountAddressesInner :: Int -> Gen AccountAddressesInner
genAccountAddressesInner n =
  AccountAddressesInner
    <$> arbitraryReducedMaybe n -- accountAddressesInnerStakeAddress :: Maybe StakeAddress
    <*> arbitraryReducedMaybe n -- accountAddressesInnerAddresses :: Maybe [PaymentAddress]
  
instance Arbitrary AccountAssetsInner where
  arbitrary = sized genAccountAssetsInner

genAccountAssetsInner :: Int -> Gen AccountAssetsInner
genAccountAssetsInner n =
  AccountAssetsInner
    <$> arbitraryReducedMaybe n -- accountAssetsInnerStakeAddress :: Maybe StakeAddress
    <*> arbitraryReducedMaybe n -- accountAssetsInnerAssets :: Maybe [AccountAssetsInnerAssetsInner]
  
instance Arbitrary AccountAssetsInnerAssetsInner where
  arbitrary = sized genAccountAssetsInnerAssetsInner

genAccountAssetsInnerAssetsInner :: Int -> Gen AccountAssetsInnerAssetsInner
genAccountAssetsInnerAssetsInner n =
  AccountAssetsInnerAssetsInner
    <$> arbitraryReducedMaybe n -- accountAssetsInnerAssetsInnerPolicyId :: Maybe PolicyId
    <*> arbitraryReducedMaybe n -- accountAssetsInnerAssetsInnerAssets :: Maybe [AccountAssetsInnerAssetsInnerAssetsInner]
  
instance Arbitrary AccountAssetsInnerAssetsInnerAssetsInner where
  arbitrary = sized genAccountAssetsInnerAssetsInnerAssetsInner

genAccountAssetsInnerAssetsInnerAssetsInner :: Int -> Gen AccountAssetsInnerAssetsInnerAssetsInner
genAccountAssetsInnerAssetsInnerAssetsInner n =
  AccountAssetsInnerAssetsInnerAssetsInner
    <$> arbitraryReducedMaybe n -- accountAssetsInnerAssetsInnerAssetsInnerAssetName :: Maybe AssetNameAscii
    <*> arbitraryReducedMaybe n -- accountAssetsInnerAssetsInnerAssetsInnerAssetPolicy :: Maybe PolicyId
    <*> arbitraryReducedMaybe n -- accountAssetsInnerAssetsInnerAssetsInnerBalance :: Maybe Text
  
instance Arbitrary AccountHistoryInner where
  arbitrary = sized genAccountHistoryInner

genAccountHistoryInner :: Int -> Gen AccountHistoryInner
genAccountHistoryInner n =
  AccountHistoryInner
    <$> arbitraryReducedMaybe n -- accountHistoryInnerStakeAddress :: Maybe Text
    <*> arbitraryReducedMaybe n -- accountHistoryInnerHistory :: Maybe [AccountHistoryInnerHistoryInner]
  
instance Arbitrary AccountHistoryInnerHistoryInner where
  arbitrary = sized genAccountHistoryInnerHistoryInner

genAccountHistoryInnerHistoryInner :: Int -> Gen AccountHistoryInnerHistoryInner
genAccountHistoryInnerHistoryInner n =
  AccountHistoryInnerHistoryInner
    <$> arbitraryReducedMaybe n -- accountHistoryInnerHistoryInnerPoolId :: Maybe Text
    <*> arbitraryReducedMaybe n -- accountHistoryInnerHistoryInnerEpochNo :: Maybe Int
    <*> arbitraryReducedMaybe n -- accountHistoryInnerHistoryInnerActiveStake :: Maybe Text
  
instance Arbitrary AccountInfoInner where
  arbitrary = sized genAccountInfoInner

genAccountInfoInner :: Int -> Gen AccountInfoInner
genAccountInfoInner n =
  AccountInfoInner
    <$> arbitraryReducedMaybe n -- accountInfoInnerStakeAddress :: Maybe StakeAddress
    <*> arbitraryReducedMaybe n -- accountInfoInnerStatus :: Maybe E'Status
    <*> arbitraryReducedMaybe n -- accountInfoInnerDelegatedPool :: Maybe PoolIdBech32
    <*> arbitraryReducedMaybe n -- accountInfoInnerTotalBalance :: Maybe Text
    <*> arbitraryReducedMaybe n -- accountInfoInnerUtxo :: Maybe Text
    <*> arbitraryReducedMaybe n -- accountInfoInnerRewards :: Maybe Text
    <*> arbitraryReducedMaybe n -- accountInfoInnerWithdrawals :: Maybe Text
    <*> arbitraryReducedMaybe n -- accountInfoInnerRewardsAvailable :: Maybe Text
    <*> arbitraryReducedMaybe n -- accountInfoInnerReserves :: Maybe Text
    <*> arbitraryReducedMaybe n -- accountInfoInnerTreasury :: Maybe Text
  
instance Arbitrary AccountInfoPostRequest where
  arbitrary = sized genAccountInfoPostRequest

genAccountInfoPostRequest :: Int -> Gen AccountInfoPostRequest
genAccountInfoPostRequest n =
  AccountInfoPostRequest
    <$> arbitrary -- accountInfoPostRequestStakeAddresses :: [Text]
    <*> arbitraryReducedMaybe n -- accountInfoPostRequestEpochNo :: Maybe Int
  
instance Arbitrary AccountListInner where
  arbitrary = sized genAccountListInner

genAccountListInner :: Int -> Gen AccountListInner
genAccountListInner n =
  AccountListInner
    <$> arbitraryReducedMaybe n -- accountListInnerId :: Maybe StakeAddress
  
instance Arbitrary AccountRewardsInner where
  arbitrary = sized genAccountRewardsInner

genAccountRewardsInner :: Int -> Gen AccountRewardsInner
genAccountRewardsInner n =
  AccountRewardsInner
    <$> arbitraryReducedMaybe n -- accountRewardsInnerStakeAddress :: Maybe StakeAddress
    <*> arbitraryReducedMaybe n -- accountRewardsInnerRewards :: Maybe [AccountRewardsInnerRewardsInner]
  
instance Arbitrary AccountRewardsInnerRewardsInner where
  arbitrary = sized genAccountRewardsInnerRewardsInner

genAccountRewardsInnerRewardsInner :: Int -> Gen AccountRewardsInnerRewardsInner
genAccountRewardsInnerRewardsInner n =
  AccountRewardsInnerRewardsInner
    <$> arbitraryReducedMaybe n -- accountRewardsInnerRewardsInnerEarnedEpoch :: Maybe EpochNo
    <*> arbitraryReducedMaybe n -- accountRewardsInnerRewardsInnerSpendableEpoch :: Maybe EpochNo
    <*> arbitraryReducedMaybe n -- accountRewardsInnerRewardsInnerAmount :: Maybe Text
    <*> arbitraryReducedMaybe n -- accountRewardsInnerRewardsInnerType :: Maybe E'Type
    <*> arbitraryReducedMaybe n -- accountRewardsInnerRewardsInnerPoolId :: Maybe PoolIdBech32
  
instance Arbitrary AccountUpdatesInner where
  arbitrary = sized genAccountUpdatesInner

genAccountUpdatesInner :: Int -> Gen AccountUpdatesInner
genAccountUpdatesInner n =
  AccountUpdatesInner
    <$> arbitraryReducedMaybe n -- accountUpdatesInnerStakeAddress :: Maybe StakeAddress
    <*> arbitraryReducedMaybe n -- accountUpdatesInnerUpdates :: Maybe [AccountUpdatesInnerUpdatesInner]
  
instance Arbitrary AccountUpdatesInnerUpdatesInner where
  arbitrary = sized genAccountUpdatesInnerUpdatesInner

genAccountUpdatesInnerUpdatesInner :: Int -> Gen AccountUpdatesInnerUpdatesInner
genAccountUpdatesInnerUpdatesInner n =
  AccountUpdatesInnerUpdatesInner
    <$> arbitraryReducedMaybe n -- accountUpdatesInnerUpdatesInnerActionType :: Maybe E'ActionType
    <*> arbitraryReducedMaybe n -- accountUpdatesInnerUpdatesInnerTxHash :: Maybe TxHash
    <*> arbitraryReducedMaybe n -- accountUpdatesInnerUpdatesInnerEpochNo :: Maybe EpochNo
    <*> arbitraryReducedMaybe n -- accountUpdatesInnerUpdatesInnerEpochSlot :: Maybe EpochSlot
    <*> arbitraryReducedMaybe n -- accountUpdatesInnerUpdatesInnerAbsoluteSlot :: Maybe AbsSlot
    <*> arbitraryReducedMaybe n -- accountUpdatesInnerUpdatesInnerBlockTime :: Maybe BlockTime
  
instance Arbitrary AddressAssetsInner where
  arbitrary = sized genAddressAssetsInner

genAddressAssetsInner :: Int -> Gen AddressAssetsInner
genAddressAssetsInner n =
  AddressAssetsInner
    <$> arbitraryReducedMaybe n -- addressAssetsInnerAddress :: Maybe PaymentAddress
    <*> arbitraryReducedMaybe n -- addressAssetsInnerAssets :: Maybe [AssetListInner]
  
instance Arbitrary AddressInfoInner where
  arbitrary = sized genAddressInfoInner

genAddressInfoInner :: Int -> Gen AddressInfoInner
genAddressInfoInner n =
  AddressInfoInner
    <$> arbitraryReducedMaybe n -- addressInfoInnerAddress :: Maybe PaymentAddress
    <*> arbitraryReducedMaybe n -- addressInfoInnerBalance :: Maybe Text
    <*> arbitraryReducedMaybe n -- addressInfoInnerStakeAddress :: Maybe StakeAddress
    <*> arbitraryReducedMaybe n -- addressInfoInnerScriptAddress :: Maybe Bool
    <*> arbitraryReducedMaybe n -- addressInfoInnerUtxoSet :: Maybe [AddressInfoInnerUtxoSetInner]
  
instance Arbitrary AddressInfoInnerUtxoSetInner where
  arbitrary = sized genAddressInfoInnerUtxoSetInner

genAddressInfoInnerUtxoSetInner :: Int -> Gen AddressInfoInnerUtxoSetInner
genAddressInfoInnerUtxoSetInner n =
  AddressInfoInnerUtxoSetInner
    <$> arbitraryReducedMaybe n -- addressInfoInnerUtxoSetInnerTxHash :: Maybe TxHash
    <*> arbitraryReducedMaybe n -- addressInfoInnerUtxoSetInnerTxIndex :: Maybe TxIndex
    <*> arbitraryReducedMaybe n -- addressInfoInnerUtxoSetInnerBlockHeight :: Maybe BlockHeight
    <*> arbitraryReducedMaybe n -- addressInfoInnerUtxoSetInnerBlockTime :: Maybe BlockTime
    <*> arbitraryReducedMaybe n -- addressInfoInnerUtxoSetInnerValue :: Maybe Value
    <*> arbitraryReducedMaybe n -- addressInfoInnerUtxoSetInnerDatumHash :: Maybe DatumHash
    <*> arbitraryReducedMaybe n -- addressInfoInnerUtxoSetInnerInlineDatum :: Maybe InlineDatum
    <*> arbitraryReducedMaybe n -- addressInfoInnerUtxoSetInnerReferenceScript :: Maybe ReferenceScript
    <*> arbitraryReducedMaybe n -- addressInfoInnerUtxoSetInnerAssetList :: Maybe [AssetListInner]
  
instance Arbitrary AddressInfoPostRequest where
  arbitrary = sized genAddressInfoPostRequest

genAddressInfoPostRequest :: Int -> Gen AddressInfoPostRequest
genAddressInfoPostRequest n =
  AddressInfoPostRequest
    <$> arbitrary -- addressInfoPostRequestAddresses :: [Text]
  
instance Arbitrary AddressTxsInner where
  arbitrary = sized genAddressTxsInner

genAddressTxsInner :: Int -> Gen AddressTxsInner
genAddressTxsInner n =
  AddressTxsInner
    <$> arbitraryReducedMaybe n -- addressTxsInnerTxHash :: Maybe TxHash
    <*> arbitraryReducedMaybe n -- addressTxsInnerEpochNo :: Maybe EpochNo
    <*> arbitraryReducedMaybe n -- addressTxsInnerBlockHeight :: Maybe BlockHeight
    <*> arbitraryReducedMaybe n -- addressTxsInnerBlockTime :: Maybe BlockTime
  
instance Arbitrary AddressTxsPostRequest where
  arbitrary = sized genAddressTxsPostRequest

genAddressTxsPostRequest :: Int -> Gen AddressTxsPostRequest
genAddressTxsPostRequest n =
  AddressTxsPostRequest
    <$> arbitrary -- addressTxsPostRequestAddresses :: [Text]
    <*> arbitraryReducedMaybe n -- addressTxsPostRequestAfterBlockHeight :: Maybe Int
  
instance Arbitrary AssetAddressListInner where
  arbitrary = sized genAssetAddressListInner

genAssetAddressListInner :: Int -> Gen AssetAddressListInner
genAssetAddressListInner n =
  AssetAddressListInner
    <$> arbitraryReducedMaybe n -- assetAddressListInnerPaymentAddress :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetAddressListInnerQuantity :: Maybe Text
  
instance Arbitrary AssetHistoryInner where
  arbitrary = sized genAssetHistoryInner

genAssetHistoryInner :: Int -> Gen AssetHistoryInner
genAssetHistoryInner n =
  AssetHistoryInner
    <$> arbitraryReducedMaybe n -- assetHistoryInnerPolicyId :: Maybe PolicyId
    <*> arbitraryReducedMaybe n -- assetHistoryInnerAssetName :: Maybe AssetName
    <*> arbitraryReducedMaybe n -- assetHistoryInnerMintingTxs :: Maybe [AssetHistoryInnerMintingTxsInner]
  
instance Arbitrary AssetHistoryInnerMintingTxsInner where
  arbitrary = sized genAssetHistoryInnerMintingTxsInner

genAssetHistoryInnerMintingTxsInner :: Int -> Gen AssetHistoryInnerMintingTxsInner
genAssetHistoryInnerMintingTxsInner n =
  AssetHistoryInnerMintingTxsInner
    <$> arbitraryReducedMaybe n -- assetHistoryInnerMintingTxsInnerTxHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetHistoryInnerMintingTxsInnerBlockTime :: Maybe BlockTime
    <*> arbitraryReducedMaybe n -- assetHistoryInnerMintingTxsInnerQuantity :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetHistoryInnerMintingTxsInnerMetadata :: Maybe MintingTxMetadata
  
instance Arbitrary AssetInfoInner where
  arbitrary = sized genAssetInfoInner

genAssetInfoInner :: Int -> Gen AssetInfoInner
genAssetInfoInner n =
  AssetInfoInner
    <$> arbitraryReducedMaybe n -- assetInfoInnerPolicyId :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetInfoInnerAssetName :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetInfoInnerAssetNameAscii :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetInfoInnerFingerprint :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetInfoInnerMintingTxHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetInfoInnerMintCnt :: Maybe Int
    <*> arbitraryReducedMaybe n -- assetInfoInnerBurnCnt :: Maybe Int
    <*> arbitraryReducedMaybe n -- assetInfoInnerMintingTxMetadata :: Maybe [AssetInfoInnerMintingTxMetadataInner]
    <*> arbitraryReducedMaybe n -- assetInfoInnerTokenRegistryMetadata :: Maybe AssetInfoInnerTokenRegistryMetadata
    <*> arbitraryReducedMaybe n -- assetInfoInnerTotalSupply :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetInfoInnerCreationTime :: Maybe Int
  
instance Arbitrary AssetInfoInnerMintingTxMetadataInner where
  arbitrary = sized genAssetInfoInnerMintingTxMetadataInner

genAssetInfoInnerMintingTxMetadataInner :: Int -> Gen AssetInfoInnerMintingTxMetadataInner
genAssetInfoInnerMintingTxMetadataInner n =
  AssetInfoInnerMintingTxMetadataInner
    <$> arbitraryReducedMaybe n -- assetInfoInnerMintingTxMetadataInnerKey :: Maybe Text
    <*> arbitraryReducedMaybeValue n -- assetInfoInnerMintingTxMetadataInnerJson :: Maybe A.Value
  
instance Arbitrary AssetInfoInnerTokenRegistryMetadata where
  arbitrary = sized genAssetInfoInnerTokenRegistryMetadata

genAssetInfoInnerTokenRegistryMetadata :: Int -> Gen AssetInfoInnerTokenRegistryMetadata
genAssetInfoInnerTokenRegistryMetadata n =
  AssetInfoInnerTokenRegistryMetadata
    <$> arbitraryReducedMaybe n -- assetInfoInnerTokenRegistryMetadataName :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetInfoInnerTokenRegistryMetadataDescription :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetInfoInnerTokenRegistryMetadataTicker :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetInfoInnerTokenRegistryMetadataUrl :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetInfoInnerTokenRegistryMetadataLogo :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetInfoInnerTokenRegistryMetadataDecimals :: Maybe Int
  
instance Arbitrary AssetListInner where
  arbitrary = sized genAssetListInner

genAssetListInner :: Int -> Gen AssetListInner
genAssetListInner n =
  AssetListInner
    <$> arbitraryReducedMaybe n -- assetListInnerPolicyId :: Maybe PolicyId
    <*> arbitraryReducedMaybe n -- assetListInnerAssetNames :: Maybe AssetListInnerAssetNames
  
instance Arbitrary AssetListInnerAssetNames where
  arbitrary = sized genAssetListInnerAssetNames

genAssetListInnerAssetNames :: Int -> Gen AssetListInnerAssetNames
genAssetListInnerAssetNames n =
  AssetListInnerAssetNames
    <$> arbitraryReducedMaybe n -- assetListInnerAssetNamesHex :: Maybe [Text]
    <*> arbitraryReducedMaybe n -- assetListInnerAssetNamesAscii :: Maybe [Text]
  
instance Arbitrary AssetPolicyInfoInner where
  arbitrary = sized genAssetPolicyInfoInner

genAssetPolicyInfoInner :: Int -> Gen AssetPolicyInfoInner
genAssetPolicyInfoInner n =
  AssetPolicyInfoInner
    <$> arbitraryReducedMaybe n -- assetPolicyInfoInnerAssetName :: Maybe AssetName
    <*> arbitraryReducedMaybe n -- assetPolicyInfoInnerAssetNameAscii :: Maybe AssetNameAscii
    <*> arbitraryReducedMaybe n -- assetPolicyInfoInnerFingerprint :: Maybe Fingerprint
    <*> arbitraryReducedMaybe n -- assetPolicyInfoInnerMintingTxMetadata :: Maybe MintingTxMetadata
    <*> arbitraryReducedMaybe n -- assetPolicyInfoInnerTokenRegistryMetadata :: Maybe TokenRegistryMetadata
    <*> arbitraryReducedMaybe n -- assetPolicyInfoInnerTotalSupply :: Maybe Text
    <*> arbitraryReducedMaybe n -- assetPolicyInfoInnerCreationTime :: Maybe CreationTime
  
instance Arbitrary AssetSummaryInner where
  arbitrary = sized genAssetSummaryInner

genAssetSummaryInner :: Int -> Gen AssetSummaryInner
genAssetSummaryInner n =
  AssetSummaryInner
    <$> arbitraryReducedMaybe n -- assetSummaryInnerPolicyId :: Maybe PolicyId
    <*> arbitraryReducedMaybe n -- assetSummaryInnerAssetName :: Maybe AssetName
    <*> arbitraryReducedMaybe n -- assetSummaryInnerTotalTransactions :: Maybe Int
    <*> arbitraryReducedMaybe n -- assetSummaryInnerStakedWallets :: Maybe Int
    <*> arbitraryReducedMaybe n -- assetSummaryInnerUnstakedAddresses :: Maybe Int
  
instance Arbitrary AssetTxsInner where
  arbitrary = sized genAssetTxsInner

genAssetTxsInner :: Int -> Gen AssetTxsInner
genAssetTxsInner n =
  AssetTxsInner
    <$> arbitraryReducedMaybe n -- assetTxsInnerTxHash :: Maybe TxHash
    <*> arbitraryReducedMaybe n -- assetTxsInnerEpochNo :: Maybe EpochNo
    <*> arbitraryReducedMaybe n -- assetTxsInnerBlockHeight :: Maybe BlockHeight
    <*> arbitraryReducedMaybe n -- assetTxsInnerBlockTime :: Maybe BlockTime
  
instance Arbitrary BlockInfoInner where
  arbitrary = sized genBlockInfoInner

genBlockInfoInner :: Int -> Gen BlockInfoInner
genBlockInfoInner n =
  BlockInfoInner
    <$> arbitraryReducedMaybe n -- blockInfoInnerHash :: Maybe Hash
    <*> arbitraryReducedMaybe n -- blockInfoInnerEpochNo :: Maybe EpochNo
    <*> arbitraryReducedMaybe n -- blockInfoInnerAbsSlot :: Maybe AbsSlot
    <*> arbitraryReducedMaybe n -- blockInfoInnerEpochSlot :: Maybe EpochSlot
    <*> arbitraryReducedMaybe n -- blockInfoInnerBlockHeight :: Maybe BlockHeight
    <*> arbitraryReducedMaybe n -- blockInfoInnerBlockSize :: Maybe BlockSize
    <*> arbitraryReducedMaybe n -- blockInfoInnerBlockTime :: Maybe BlockTime
    <*> arbitraryReducedMaybe n -- blockInfoInnerTxCount :: Maybe TxCount
    <*> arbitraryReducedMaybe n -- blockInfoInnerVrfKey :: Maybe VrfKey
    <*> arbitraryReducedMaybe n -- blockInfoInnerOpCert :: Maybe Text
    <*> arbitraryReducedMaybe n -- blockInfoInnerOpCertCounter :: Maybe OpCertCounter
    <*> arbitraryReducedMaybe n -- blockInfoInnerPool :: Maybe Pool
    <*> arbitraryReducedMaybe n -- blockInfoInnerProtoMajor :: Maybe ProtocolMajor
    <*> arbitraryReducedMaybe n -- blockInfoInnerProtoMinor :: Maybe ProtocolMinor
    <*> arbitraryReducedMaybe n -- blockInfoInnerTotalOutput :: Maybe Text
    <*> arbitraryReducedMaybe n -- blockInfoInnerTotalFees :: Maybe Text
    <*> arbitraryReducedMaybe n -- blockInfoInnerNumConfirmations :: Maybe Int
    <*> arbitraryReducedMaybe n -- blockInfoInnerParentHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- blockInfoInnerChildHash :: Maybe Text
  
instance Arbitrary BlockInfoPostRequest where
  arbitrary = sized genBlockInfoPostRequest

genBlockInfoPostRequest :: Int -> Gen BlockInfoPostRequest
genBlockInfoPostRequest n =
  BlockInfoPostRequest
    <$> arbitraryReduced n -- blockInfoPostRequestBlockHashes :: [Hash]
  
instance Arbitrary BlockTxsInner where
  arbitrary = sized genBlockTxsInner

genBlockTxsInner :: Int -> Gen BlockTxsInner
genBlockTxsInner n =
  BlockTxsInner
    <$> arbitraryReducedMaybe n -- blockTxsInnerBlockHash :: Maybe Hash
    <*> arbitraryReducedMaybe n -- blockTxsInnerTxHashes :: Maybe [TxHash]
  
instance Arbitrary BlocksInner where
  arbitrary = sized genBlocksInner

genBlocksInner :: Int -> Gen BlocksInner
genBlocksInner n =
  BlocksInner
    <$> arbitraryReducedMaybe n -- blocksInnerHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- blocksInnerEpochNo :: Maybe Int
    <*> arbitraryReducedMaybe n -- blocksInnerAbsSlot :: Maybe Int
    <*> arbitraryReducedMaybe n -- blocksInnerEpochSlot :: Maybe Int
    <*> arbitraryReducedMaybe n -- blocksInnerBlockHeight :: Maybe Int
    <*> arbitraryReducedMaybe n -- blocksInnerBlockSize :: Maybe Int
    <*> arbitraryReducedMaybe n -- blocksInnerBlockTime :: Maybe Int
    <*> arbitraryReducedMaybe n -- blocksInnerTxCount :: Maybe Int
    <*> arbitraryReducedMaybe n -- blocksInnerVrfKey :: Maybe Text
    <*> arbitraryReducedMaybe n -- blocksInnerPool :: Maybe Text
    <*> arbitraryReducedMaybe n -- blocksInnerOpCertCounter :: Maybe Int
    <*> arbitraryReducedMaybe n -- blocksInnerProtoMajor :: Maybe ProtocolMajor
    <*> arbitraryReducedMaybe n -- blocksInnerProtoMinor :: Maybe ProtocolMinor
  
instance Arbitrary CredentialTxsPostRequest where
  arbitrary = sized genCredentialTxsPostRequest

genCredentialTxsPostRequest :: Int -> Gen CredentialTxsPostRequest
genCredentialTxsPostRequest n =
  CredentialTxsPostRequest
    <$> arbitrary -- credentialTxsPostRequestPaymentCredentials :: [Text]
    <*> arbitraryReducedMaybe n -- credentialTxsPostRequestAfterBlockHeight :: Maybe Int
  
instance Arbitrary EpochInfoInner where
  arbitrary = sized genEpochInfoInner

genEpochInfoInner :: Int -> Gen EpochInfoInner
genEpochInfoInner n =
  EpochInfoInner
    <$> arbitraryReducedMaybe n -- epochInfoInnerEpochNo :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochInfoInnerOutSum :: Maybe Text
    <*> arbitraryReducedMaybe n -- epochInfoInnerFees :: Maybe Text
    <*> arbitraryReducedMaybe n -- epochInfoInnerTxCount :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochInfoInnerBlkCount :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochInfoInnerStartTime :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochInfoInnerEndTime :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochInfoInnerFirstBlockTime :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochInfoInnerLastBlockTime :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochInfoInnerActiveStake :: Maybe Text
    <*> arbitraryReducedMaybe n -- epochInfoInnerTotalRewards :: Maybe Text
    <*> arbitraryReducedMaybe n -- epochInfoInnerAvgBlkReward :: Maybe Text
  
instance Arbitrary EpochParamsInner where
  arbitrary = sized genEpochParamsInner

genEpochParamsInner :: Int -> Gen EpochParamsInner
genEpochParamsInner n =
  EpochParamsInner
    <$> arbitraryReducedMaybe n -- epochParamsInnerEpochNo :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochParamsInnerMinFeeA :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochParamsInnerMinFeeB :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochParamsInnerMaxBlockSize :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochParamsInnerMaxTxSize :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochParamsInnerMaxBhSize :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochParamsInnerKeyDeposit :: Maybe Text
    <*> arbitraryReducedMaybe n -- epochParamsInnerPoolDeposit :: Maybe Text
    <*> arbitraryReducedMaybe n -- epochParamsInnerMaxEpoch :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochParamsInnerOptimalPoolCount :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochParamsInnerInfluence :: Maybe Double
    <*> arbitraryReducedMaybe n -- epochParamsInnerMonetaryExpandRate :: Maybe Double
    <*> arbitraryReducedMaybe n -- epochParamsInnerTreasuryGrowthRate :: Maybe Double
    <*> arbitraryReducedMaybe n -- epochParamsInnerDecentralisation :: Maybe Double
    <*> arbitraryReducedMaybe n -- epochParamsInnerExtraEntropy :: Maybe Text
    <*> arbitraryReducedMaybe n -- epochParamsInnerProtocolMajor :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochParamsInnerProtocolMinor :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochParamsInnerMinUtxoValue :: Maybe Text
    <*> arbitraryReducedMaybe n -- epochParamsInnerMinPoolCost :: Maybe Text
    <*> arbitraryReducedMaybe n -- epochParamsInnerNonce :: Maybe Text
    <*> arbitraryReducedMaybe n -- epochParamsInnerBlockHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- epochParamsInnerCostModels :: Maybe Text
    <*> arbitraryReducedMaybe n -- epochParamsInnerPriceMem :: Maybe Double
    <*> arbitraryReducedMaybe n -- epochParamsInnerPriceStep :: Maybe Double
    <*> arbitraryReducedMaybe n -- epochParamsInnerMaxTxExMem :: Maybe Double
    <*> arbitraryReducedMaybe n -- epochParamsInnerMaxTxExSteps :: Maybe Double
    <*> arbitraryReducedMaybe n -- epochParamsInnerMaxBlockExMem :: Maybe Double
    <*> arbitraryReducedMaybe n -- epochParamsInnerMaxBlockExSteps :: Maybe Double
    <*> arbitraryReducedMaybe n -- epochParamsInnerMaxValSize :: Maybe Double
    <*> arbitraryReducedMaybe n -- epochParamsInnerCollateralPercent :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochParamsInnerMaxCollateralInputs :: Maybe Int
    <*> arbitraryReducedMaybe n -- epochParamsInnerCoinsPerUtxoSize :: Maybe Text
  
instance Arbitrary GenesisInner where
  arbitrary = sized genGenesisInner

genGenesisInner :: Int -> Gen GenesisInner
genGenesisInner n =
  GenesisInner
    <$> arbitraryReducedMaybe n -- genesisInnerNetworkmagic :: Maybe Text
    <*> arbitraryReducedMaybe n -- genesisInnerNetworkid :: Maybe Text
    <*> arbitraryReducedMaybe n -- genesisInnerEpochlength :: Maybe Text
    <*> arbitraryReducedMaybe n -- genesisInnerSlotlength :: Maybe Text
    <*> arbitraryReducedMaybe n -- genesisInnerMaxlovelacesupply :: Maybe Text
    <*> arbitraryReducedMaybe n -- genesisInnerSystemstart :: Maybe Int
    <*> arbitraryReducedMaybe n -- genesisInnerActiveslotcoeff :: Maybe Text
    <*> arbitraryReducedMaybe n -- genesisInnerSlotsperkesperiod :: Maybe Text
    <*> arbitraryReducedMaybe n -- genesisInnerMaxkesrevolutions :: Maybe Text
    <*> arbitraryReducedMaybe n -- genesisInnerSecurityparam :: Maybe Text
    <*> arbitraryReducedMaybe n -- genesisInnerUpdatequorum :: Maybe Text
    <*> arbitraryReducedMaybe n -- genesisInnerAlonzogenesis :: Maybe Text
  
instance Arbitrary NativeScriptListInner where
  arbitrary = sized genNativeScriptListInner

genNativeScriptListInner :: Int -> Gen NativeScriptListInner
genNativeScriptListInner n =
  NativeScriptListInner
    <$> arbitraryReducedMaybe n -- nativeScriptListInnerScriptHash :: Maybe ScriptHash
    <*> arbitraryReducedMaybe n -- nativeScriptListInnerCreationTxHash :: Maybe CreationTxHash
    <*> arbitraryReducedMaybe n -- nativeScriptListInnerType :: Maybe E'Type2
  
instance Arbitrary PlutusScriptListInner where
  arbitrary = sized genPlutusScriptListInner

genPlutusScriptListInner :: Int -> Gen PlutusScriptListInner
genPlutusScriptListInner n =
  PlutusScriptListInner
    <$> arbitraryReducedMaybe n -- plutusScriptListInnerScriptHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- plutusScriptListInnerCreationTxHash :: Maybe Text
  
instance Arbitrary PoolBlocksInner where
  arbitrary = sized genPoolBlocksInner

genPoolBlocksInner :: Int -> Gen PoolBlocksInner
genPoolBlocksInner n =
  PoolBlocksInner
    <$> arbitraryReducedMaybe n -- poolBlocksInnerEpochNo :: Maybe EpochNo
    <*> arbitraryReducedMaybe n -- poolBlocksInnerEpochSlot :: Maybe EpochSlot
    <*> arbitraryReducedMaybe n -- poolBlocksInnerAbsSlot :: Maybe AbsSlot
    <*> arbitraryReducedMaybe n -- poolBlocksInnerBlockHeight :: Maybe BlockHeight
    <*> arbitraryReducedMaybe n -- poolBlocksInnerBlockHash :: Maybe Hash
    <*> arbitraryReducedMaybe n -- poolBlocksInnerBlockTime :: Maybe BlockTime
  
instance Arbitrary PoolDelegatorsInner where
  arbitrary = sized genPoolDelegatorsInner

genPoolDelegatorsInner :: Int -> Gen PoolDelegatorsInner
genPoolDelegatorsInner n =
  PoolDelegatorsInner
    <$> arbitraryReducedMaybe n -- poolDelegatorsInnerStakeAddress :: Maybe StakeAddress
    <*> arbitraryReducedMaybe n -- poolDelegatorsInnerAmount :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolDelegatorsInnerActiveEpochNo :: Maybe Int
  
instance Arbitrary PoolHistoryInfoInner where
  arbitrary = sized genPoolHistoryInfoInner

genPoolHistoryInfoInner :: Int -> Gen PoolHistoryInfoInner
genPoolHistoryInfoInner n =
  PoolHistoryInfoInner
    <$> arbitraryReducedMaybe n -- poolHistoryInfoInnerEpochNo :: Maybe Int
    <*> arbitraryReducedMaybe n -- poolHistoryInfoInnerActiveStake :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolHistoryInfoInnerActiveStakePct :: Maybe Double
    <*> arbitraryReducedMaybe n -- poolHistoryInfoInnerSaturationPct :: Maybe Double
    <*> arbitraryReducedMaybe n -- poolHistoryInfoInnerBlockCnt :: Maybe Int
    <*> arbitraryReducedMaybe n -- poolHistoryInfoInnerDelegatorCnt :: Maybe Int
    <*> arbitraryReducedMaybe n -- poolHistoryInfoInnerMargin :: Maybe Double
    <*> arbitraryReducedMaybe n -- poolHistoryInfoInnerFixedCost :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolHistoryInfoInnerPoolFees :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolHistoryInfoInnerDelegRewards :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolHistoryInfoInnerEpochRos :: Maybe Double
  
instance Arbitrary PoolInfoInner where
  arbitrary = sized genPoolInfoInner

genPoolInfoInner :: Int -> Gen PoolInfoInner
genPoolInfoInner n =
  PoolInfoInner
    <$> arbitraryReducedMaybe n -- poolInfoInnerPoolIdBech32 :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerPoolIdHex :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerActiveEpochNo :: Maybe ActiveEpochNo
    <*> arbitraryReducedMaybe n -- poolInfoInnerVrfKeyHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerMargin :: Maybe Double
    <*> arbitraryReducedMaybe n -- poolInfoInnerFixedCost :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerPledge :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerRewardAddr :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerOwners :: Maybe [Text]
    <*> arbitraryReducedMaybe n -- poolInfoInnerRelays :: Maybe [PoolInfoInnerRelaysInner]
    <*> arbitraryReducedMaybe n -- poolInfoInnerMetaUrl :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerMetaHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerMetaJson :: Maybe PoolInfoInnerMetaJson
    <*> arbitraryReducedMaybe n -- poolInfoInnerPoolStatus :: Maybe E'PoolStatus
    <*> arbitraryReducedMaybe n -- poolInfoInnerRetiringEpoch :: Maybe Int
    <*> arbitraryReducedMaybe n -- poolInfoInnerOpCert :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerOpCertCounter :: Maybe Int
    <*> arbitraryReducedMaybe n -- poolInfoInnerActiveStake :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerSigma :: Maybe Double
    <*> arbitraryReducedMaybe n -- poolInfoInnerBlockCount :: Maybe Int
    <*> arbitraryReducedMaybe n -- poolInfoInnerLivePledge :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerLiveStake :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerLiveDelegators :: Maybe Int
    <*> arbitraryReducedMaybe n -- poolInfoInnerLiveSaturation :: Maybe Double
  
instance Arbitrary PoolInfoInnerMetaJson where
  arbitrary = sized genPoolInfoInnerMetaJson

genPoolInfoInnerMetaJson :: Int -> Gen PoolInfoInnerMetaJson
genPoolInfoInnerMetaJson n =
  PoolInfoInnerMetaJson
    <$> arbitraryReducedMaybe n -- poolInfoInnerMetaJsonName :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerMetaJsonTicker :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerMetaJsonHomepage :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerMetaJsonDescription :: Maybe Text
  
instance Arbitrary PoolInfoInnerRelaysInner where
  arbitrary = sized genPoolInfoInnerRelaysInner

genPoolInfoInnerRelaysInner :: Int -> Gen PoolInfoInnerRelaysInner
genPoolInfoInnerRelaysInner n =
  PoolInfoInnerRelaysInner
    <$> arbitraryReducedMaybe n -- poolInfoInnerRelaysInnerDns :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerRelaysInnerSrv :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerRelaysInnerIpv4 :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerRelaysInnerIpv6 :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolInfoInnerRelaysInnerPort :: Maybe Double
  
instance Arbitrary PoolInfoPostRequest where
  arbitrary = sized genPoolInfoPostRequest

genPoolInfoPostRequest :: Int -> Gen PoolInfoPostRequest
genPoolInfoPostRequest n =
  PoolInfoPostRequest
    <$> arbitrary -- poolInfoPostRequestPoolBech32Ids :: [Text]
  
instance Arbitrary PoolListInner where
  arbitrary = sized genPoolListInner

genPoolListInner :: Int -> Gen PoolListInner
genPoolListInner n =
  PoolListInner
    <$> arbitraryReducedMaybe n -- poolListInnerPoolIdBech32 :: Maybe Text
    <*> arbitraryReducedMaybe n -- poolListInnerTicker :: Maybe Text
  
instance Arbitrary PoolMetadataInner where
  arbitrary = sized genPoolMetadataInner

genPoolMetadataInner :: Int -> Gen PoolMetadataInner
genPoolMetadataInner n =
  PoolMetadataInner
    <$> arbitraryReducedMaybe n -- poolMetadataInnerPoolIdBech32 :: Maybe PoolIdBech32
    <*> arbitraryReducedMaybe n -- poolMetadataInnerMetaUrl :: Maybe MetaUrl
    <*> arbitraryReducedMaybe n -- poolMetadataInnerMetaHash :: Maybe MetaHash
    <*> arbitraryReducedMaybe n -- poolMetadataInnerMetaJson :: Maybe MetaJson
  
instance Arbitrary PoolMetadataPostRequest where
  arbitrary = sized genPoolMetadataPostRequest

genPoolMetadataPostRequest :: Int -> Gen PoolMetadataPostRequest
genPoolMetadataPostRequest n =
  PoolMetadataPostRequest
    <$> arbitraryReducedMaybe n -- poolMetadataPostRequestPoolBech32Ids :: Maybe [Text]
  
instance Arbitrary PoolRelaysInner where
  arbitrary = sized genPoolRelaysInner

genPoolRelaysInner :: Int -> Gen PoolRelaysInner
genPoolRelaysInner n =
  PoolRelaysInner
    <$> arbitraryReducedMaybe n -- poolRelaysInnerPoolIdBech32 :: Maybe PoolIdBech32
    <*> arbitraryReducedMaybe n -- poolRelaysInnerRelays :: Maybe Relays
  
instance Arbitrary PoolUpdatesInner where
  arbitrary = sized genPoolUpdatesInner

genPoolUpdatesInner :: Int -> Gen PoolUpdatesInner
genPoolUpdatesInner n =
  PoolUpdatesInner
    <$> arbitraryReducedMaybe n -- poolUpdatesInnerTxHash :: Maybe TxHash
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerBlockTime :: Maybe BlockTime
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerPoolIdBech32 :: Maybe PoolIdBech32
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerPoolIdHex :: Maybe PoolIdHex
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerActiveEpochNo :: Maybe Int
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerVrfKeyHash :: Maybe VrfKeyHash
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerMargin :: Maybe Margin
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerFixedCost :: Maybe FixedCost
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerPledge :: Maybe Pledge
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerRewardAddr :: Maybe RewardAddr
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerOwners :: Maybe Owners
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerRelays :: Maybe Relays
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerMetaUrl :: Maybe MetaUrl
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerMetaHash :: Maybe MetaHash
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerPoolStatus :: Maybe PoolStatus
    <*> arbitraryReducedMaybe n -- poolUpdatesInnerRetiringEpoch :: Maybe RetiringEpoch
  
instance Arbitrary ScriptRedeemersInner where
  arbitrary = sized genScriptRedeemersInner

genScriptRedeemersInner :: Int -> Gen ScriptRedeemersInner
genScriptRedeemersInner n =
  ScriptRedeemersInner
    <$> arbitraryReducedMaybe n -- scriptRedeemersInnerScriptHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- scriptRedeemersInnerRedeemers :: Maybe [ScriptRedeemersInnerRedeemersInner]
  
instance Arbitrary ScriptRedeemersInnerRedeemersInner where
  arbitrary = sized genScriptRedeemersInnerRedeemersInner

genScriptRedeemersInnerRedeemersInner :: Int -> Gen ScriptRedeemersInnerRedeemersInner
genScriptRedeemersInnerRedeemersInner n =
  ScriptRedeemersInnerRedeemersInner
    <$> arbitraryReducedMaybe n -- scriptRedeemersInnerRedeemersInnerTxHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- scriptRedeemersInnerRedeemersInnerTxIndex :: Maybe Int
    <*> arbitraryReducedMaybe n -- scriptRedeemersInnerRedeemersInnerUnitMem :: Maybe (Map.Map String ScriptRedeemersInnerRedeemersInnerUnitMemValue)
    <*> arbitraryReducedMaybe n -- scriptRedeemersInnerRedeemersInnerUnitSteps :: Maybe (Map.Map String ScriptRedeemersInnerRedeemersInnerUnitMemValue)
    <*> arbitraryReducedMaybe n -- scriptRedeemersInnerRedeemersInnerFee :: Maybe Text
    <*> arbitraryReducedMaybe n -- scriptRedeemersInnerRedeemersInnerPurpose :: Maybe E'Purpose
    <*> arbitraryReducedMaybe n -- scriptRedeemersInnerRedeemersInnerDatumHash :: Maybe Text
    <*> arbitraryReducedMaybeValue n -- scriptRedeemersInnerRedeemersInnerDatumValue :: Maybe A.Value
  
instance Arbitrary ScriptRedeemersInnerRedeemersInnerUnitMemValue where
  arbitrary = sized genScriptRedeemersInnerRedeemersInnerUnitMemValue

genScriptRedeemersInnerRedeemersInnerUnitMemValue :: Int -> Gen ScriptRedeemersInnerRedeemersInnerUnitMemValue
genScriptRedeemersInnerRedeemersInnerUnitMemValue n =
  
  pure ScriptRedeemersInnerRedeemersInnerUnitMemValue
   
instance Arbitrary TipInner where
  arbitrary = sized genTipInner

genTipInner :: Int -> Gen TipInner
genTipInner n =
  TipInner
    <$> arbitraryReducedMaybe n -- tipInnerHash :: Maybe Hash
    <*> arbitraryReducedMaybe n -- tipInnerEpochNo :: Maybe EpochNo
    <*> arbitraryReducedMaybe n -- tipInnerAbsSlot :: Maybe AbsSlot
    <*> arbitraryReducedMaybe n -- tipInnerEpochSlot :: Maybe EpochSlot
    <*> arbitraryReducedMaybe n -- tipInnerBlockNo :: Maybe BlockHeight
    <*> arbitraryReducedMaybe n -- tipInnerBlockTime :: Maybe BlockTime
  
instance Arbitrary TotalsInner where
  arbitrary = sized genTotalsInner

genTotalsInner :: Int -> Gen TotalsInner
genTotalsInner n =
  TotalsInner
    <$> arbitraryReducedMaybe n -- totalsInnerEpochNo :: Maybe Int
    <*> arbitraryReducedMaybe n -- totalsInnerCirculation :: Maybe Text
    <*> arbitraryReducedMaybe n -- totalsInnerTreasury :: Maybe Text
    <*> arbitraryReducedMaybe n -- totalsInnerReward :: Maybe Text
    <*> arbitraryReducedMaybe n -- totalsInnerSupply :: Maybe Text
    <*> arbitraryReducedMaybe n -- totalsInnerReserves :: Maybe Text
  
instance Arbitrary TxInfoInner where
  arbitrary = sized genTxInfoInner

genTxInfoInner :: Int -> Gen TxInfoInner
genTxInfoInner n =
  TxInfoInner
    <$> arbitraryReducedMaybe n -- txInfoInnerTxHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerBlockHash :: Maybe Hash
    <*> arbitraryReducedMaybe n -- txInfoInnerBlockHeight :: Maybe BlockHeight
    <*> arbitraryReducedMaybe n -- txInfoInnerEpochNo :: Maybe EpochNo
    <*> arbitraryReducedMaybe n -- txInfoInnerEpochSlot :: Maybe EpochSlot
    <*> arbitraryReducedMaybe n -- txInfoInnerAbsoluteSlot :: Maybe AbsSlot
    <*> arbitraryReducedMaybe n -- txInfoInnerTxTimestamp :: Maybe Int
    <*> arbitraryReducedMaybe n -- txInfoInnerTxBlockIndex :: Maybe Int
    <*> arbitraryReducedMaybe n -- txInfoInnerTxSize :: Maybe Int
    <*> arbitraryReducedMaybe n -- txInfoInnerTotalOutput :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerFee :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerDeposit :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerInvalidBefore :: Maybe Int
    <*> arbitraryReducedMaybe n -- txInfoInnerInvalidAfter :: Maybe Int
    <*> arbitraryReducedMaybe n -- txInfoInnerCollateralInputs :: Maybe Outputs
    <*> arbitraryReducedMaybe n -- txInfoInnerCollateralOutput :: Maybe Items
    <*> arbitraryReducedMaybe n -- txInfoInnerReferenceInputs :: Maybe Outputs
    <*> arbitraryReducedMaybe n -- txInfoInnerInputs :: Maybe Outputs
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputs :: Maybe [TxInfoInnerOutputsInner]
    <*> arbitraryReducedMaybe n -- txInfoInnerWithdrawals :: Maybe [TxInfoInnerWithdrawalsInner]
    <*> arbitraryReducedMaybe n -- txInfoInnerAssetsMinted :: Maybe [TxInfoInnerAssetsMintedInner]
    <*> arbitraryReducedMaybe n -- txInfoInnerMetadata :: Maybe [TxInfoInnerMetadataInner]
    <*> arbitraryReducedMaybe n -- txInfoInnerCertificates :: Maybe [TxInfoInnerCertificatesInner]
    <*> arbitraryReducedMaybe n -- txInfoInnerNativeScripts :: Maybe [TxInfoInnerNativeScriptsInner]
    <*> arbitraryReducedMaybe n -- txInfoInnerPlutusContracts :: Maybe [TxInfoInnerPlutusContractsInner]
  
instance Arbitrary TxInfoInnerAssetsMintedInner where
  arbitrary = sized genTxInfoInnerAssetsMintedInner

genTxInfoInnerAssetsMintedInner :: Int -> Gen TxInfoInnerAssetsMintedInner
genTxInfoInnerAssetsMintedInner n =
  TxInfoInnerAssetsMintedInner
    <$> arbitraryReducedMaybe n -- txInfoInnerAssetsMintedInnerPolicyId :: Maybe PolicyId
    <*> arbitraryReducedMaybe n -- txInfoInnerAssetsMintedInnerAssetName :: Maybe AssetName
    <*> arbitraryReducedMaybe n -- txInfoInnerAssetsMintedInnerQuantity :: Maybe Text
  
instance Arbitrary TxInfoInnerCertificatesInner where
  arbitrary = sized genTxInfoInnerCertificatesInner

genTxInfoInnerCertificatesInner :: Int -> Gen TxInfoInnerCertificatesInner
genTxInfoInnerCertificatesInner n =
  TxInfoInnerCertificatesInner
    <$> arbitraryReducedMaybe n -- txInfoInnerCertificatesInnerIndex :: Maybe Int
    <*> arbitraryReducedMaybe n -- txInfoInnerCertificatesInnerType :: Maybe Text
    <*> arbitraryReducedMaybeValue n -- txInfoInnerCertificatesInnerInfo :: Maybe A.Value
  
instance Arbitrary TxInfoInnerMetadataInner where
  arbitrary = sized genTxInfoInnerMetadataInner

genTxInfoInnerMetadataInner :: Int -> Gen TxInfoInnerMetadataInner
genTxInfoInnerMetadataInner n =
  TxInfoInnerMetadataInner
    <$> arbitraryReducedMaybe n -- txInfoInnerMetadataInnerKey :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerMetadataInnerJson :: Maybe Metadata
  
instance Arbitrary TxInfoInnerNativeScriptsInner where
  arbitrary = sized genTxInfoInnerNativeScriptsInner

genTxInfoInnerNativeScriptsInner :: Int -> Gen TxInfoInnerNativeScriptsInner
genTxInfoInnerNativeScriptsInner n =
  TxInfoInnerNativeScriptsInner
    <$> arbitraryReducedMaybe n -- txInfoInnerNativeScriptsInnerScriptHash :: Maybe ScriptHash
    <*> arbitraryReducedMaybeValue n -- txInfoInnerNativeScriptsInnerScriptJson :: Maybe A.Value
  
instance Arbitrary TxInfoInnerOutputsInner where
  arbitrary = sized genTxInfoInnerOutputsInner

genTxInfoInnerOutputsInner :: Int -> Gen TxInfoInnerOutputsInner
genTxInfoInnerOutputsInner n =
  TxInfoInnerOutputsInner
    <$> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerPaymentAddr :: Maybe TxInfoInnerOutputsInnerPaymentAddr
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerStakeAddr :: Maybe StakeAddress
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerTxHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerTxIndex :: Maybe Int
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerValue :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerDatumHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerInlineDatum :: Maybe TxInfoInnerOutputsInnerInlineDatum
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerReferenceScript :: Maybe TxInfoInnerOutputsInnerReferenceScript
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerAssetList :: Maybe [TxInfoInnerOutputsInnerAssetListInner]
  
instance Arbitrary TxInfoInnerOutputsInnerAssetListInner where
  arbitrary = sized genTxInfoInnerOutputsInnerAssetListInner

genTxInfoInnerOutputsInnerAssetListInner :: Int -> Gen TxInfoInnerOutputsInnerAssetListInner
genTxInfoInnerOutputsInnerAssetListInner n =
  TxInfoInnerOutputsInnerAssetListInner
    <$> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerAssetListInnerPolicyId :: Maybe PolicyId
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerAssetListInnerAssetName :: Maybe AssetName
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerAssetListInnerQuantity :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerAssetListInnerFingerprint :: Maybe Fingerprint
  
instance Arbitrary TxInfoInnerOutputsInnerInlineDatum where
  arbitrary = sized genTxInfoInnerOutputsInnerInlineDatum

genTxInfoInnerOutputsInnerInlineDatum :: Int -> Gen TxInfoInnerOutputsInnerInlineDatum
genTxInfoInnerOutputsInnerInlineDatum n =
  TxInfoInnerOutputsInnerInlineDatum
    <$> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerInlineDatumBytes :: Maybe Text
    <*> arbitraryReducedMaybeValue n -- txInfoInnerOutputsInnerInlineDatumValue :: Maybe A.Value
  
instance Arbitrary TxInfoInnerOutputsInnerPaymentAddr where
  arbitrary = sized genTxInfoInnerOutputsInnerPaymentAddr

genTxInfoInnerOutputsInnerPaymentAddr :: Int -> Gen TxInfoInnerOutputsInnerPaymentAddr
genTxInfoInnerOutputsInnerPaymentAddr n =
  TxInfoInnerOutputsInnerPaymentAddr
    <$> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerPaymentAddrBech32 :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerPaymentAddrCred :: Maybe Text
  
instance Arbitrary TxInfoInnerOutputsInnerReferenceScript where
  arbitrary = sized genTxInfoInnerOutputsInnerReferenceScript

genTxInfoInnerOutputsInnerReferenceScript :: Int -> Gen TxInfoInnerOutputsInnerReferenceScript
genTxInfoInnerOutputsInnerReferenceScript n =
  TxInfoInnerOutputsInnerReferenceScript
    <$> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerReferenceScriptHash :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerReferenceScriptSize :: Maybe Int
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerReferenceScriptType :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerOutputsInnerReferenceScriptBytes :: Maybe Text
    <*> arbitraryReducedMaybeValue n -- txInfoInnerOutputsInnerReferenceScriptValue :: Maybe A.Value
  
instance Arbitrary TxInfoInnerPlutusContractsInner where
  arbitrary = sized genTxInfoInnerPlutusContractsInner

genTxInfoInnerPlutusContractsInner :: Int -> Gen TxInfoInnerPlutusContractsInner
genTxInfoInnerPlutusContractsInner n =
  TxInfoInnerPlutusContractsInner
    <$> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerAddress :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerScriptHash :: Maybe ScriptHash
    <*> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerBytecode :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerSize :: Maybe Int
    <*> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerValidContract :: Maybe Bool
    <*> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerInput :: Maybe TxInfoInnerPlutusContractsInnerInput
    <*> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerOutput :: Maybe TxInfoInnerPlutusContractsInnerInputRedeemerDatum
  
instance Arbitrary TxInfoInnerPlutusContractsInnerInput where
  arbitrary = sized genTxInfoInnerPlutusContractsInnerInput

genTxInfoInnerPlutusContractsInnerInput :: Int -> Gen TxInfoInnerPlutusContractsInnerInput
genTxInfoInnerPlutusContractsInnerInput n =
  TxInfoInnerPlutusContractsInnerInput
    <$> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerInputRedeemer :: Maybe TxInfoInnerPlutusContractsInnerInputRedeemer
    <*> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerInputDatum :: Maybe TxInfoInnerPlutusContractsInnerInputRedeemerDatum
  
instance Arbitrary TxInfoInnerPlutusContractsInnerInputRedeemer where
  arbitrary = sized genTxInfoInnerPlutusContractsInnerInputRedeemer

genTxInfoInnerPlutusContractsInnerInputRedeemer :: Int -> Gen TxInfoInnerPlutusContractsInnerInputRedeemer
genTxInfoInnerPlutusContractsInnerInputRedeemer n =
  TxInfoInnerPlutusContractsInnerInputRedeemer
    <$> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerInputRedeemerPurpose :: Maybe Purpose
    <*> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerInputRedeemerFee :: Maybe Fee
    <*> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerInputRedeemerUnit :: Maybe TxInfoInnerPlutusContractsInnerInputRedeemerUnit
    <*> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerInputRedeemerDatum :: Maybe TxInfoInnerPlutusContractsInnerInputRedeemerDatum
  
instance Arbitrary TxInfoInnerPlutusContractsInnerInputRedeemerDatum where
  arbitrary = sized genTxInfoInnerPlutusContractsInnerInputRedeemerDatum

genTxInfoInnerPlutusContractsInnerInputRedeemerDatum :: Int -> Gen TxInfoInnerPlutusContractsInnerInputRedeemerDatum
genTxInfoInnerPlutusContractsInnerInputRedeemerDatum n =
  TxInfoInnerPlutusContractsInnerInputRedeemerDatum
    <$> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerInputRedeemerDatumHash :: Maybe DatumHash
    <*> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerInputRedeemerDatumValue :: Maybe DatumValue
  
instance Arbitrary TxInfoInnerPlutusContractsInnerInputRedeemerUnit where
  arbitrary = sized genTxInfoInnerPlutusContractsInnerInputRedeemerUnit

genTxInfoInnerPlutusContractsInnerInputRedeemerUnit :: Int -> Gen TxInfoInnerPlutusContractsInnerInputRedeemerUnit
genTxInfoInnerPlutusContractsInnerInputRedeemerUnit n =
  TxInfoInnerPlutusContractsInnerInputRedeemerUnit
    <$> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerInputRedeemerUnitSteps :: Maybe UnitSteps
    <*> arbitraryReducedMaybe n -- txInfoInnerPlutusContractsInnerInputRedeemerUnitMem :: Maybe UnitMem
  
instance Arbitrary TxInfoInnerWithdrawalsInner where
  arbitrary = sized genTxInfoInnerWithdrawalsInner

genTxInfoInnerWithdrawalsInner :: Int -> Gen TxInfoInnerWithdrawalsInner
genTxInfoInnerWithdrawalsInner n =
  TxInfoInnerWithdrawalsInner
    <$> arbitraryReducedMaybe n -- txInfoInnerWithdrawalsInnerAmount :: Maybe Text
    <*> arbitraryReducedMaybe n -- txInfoInnerWithdrawalsInnerStakeAddr :: Maybe TxInfoInnerWithdrawalsInnerStakeAddr
  
instance Arbitrary TxInfoInnerWithdrawalsInnerStakeAddr where
  arbitrary = sized genTxInfoInnerWithdrawalsInnerStakeAddr

genTxInfoInnerWithdrawalsInnerStakeAddr :: Int -> Gen TxInfoInnerWithdrawalsInnerStakeAddr
genTxInfoInnerWithdrawalsInnerStakeAddr n =
  TxInfoInnerWithdrawalsInnerStakeAddr
    <$> arbitraryReducedMaybe n -- txInfoInnerWithdrawalsInnerStakeAddrBech32 :: Maybe Text
  
instance Arbitrary TxInfoPostRequest where
  arbitrary = sized genTxInfoPostRequest

genTxInfoPostRequest :: Int -> Gen TxInfoPostRequest
genTxInfoPostRequest n =
  TxInfoPostRequest
    <$> arbitrary -- txInfoPostRequestTxHashes :: [Text]
  
instance Arbitrary TxMetadataInner where
  arbitrary = sized genTxMetadataInner

genTxMetadataInner :: Int -> Gen TxMetadataInner
genTxMetadataInner n =
  TxMetadataInner
    <$> arbitraryReducedMaybe n -- txMetadataInnerTxHash :: Maybe TxHash
    <*> arbitraryReducedMaybeValue n -- txMetadataInnerMetadata :: Maybe A.Value
  
instance Arbitrary TxMetalabelsInner where
  arbitrary = sized genTxMetalabelsInner

genTxMetalabelsInner :: Int -> Gen TxMetalabelsInner
genTxMetalabelsInner n =
  TxMetalabelsInner
    <$> arbitraryReducedMaybe n -- txMetalabelsInnerKey :: Maybe Text
  
instance Arbitrary TxStatusInner where
  arbitrary = sized genTxStatusInner

genTxStatusInner :: Int -> Gen TxStatusInner
genTxStatusInner n =
  TxStatusInner
    <$> arbitraryReducedMaybe n -- txStatusInnerTxHash :: Maybe TxHash
    <*> arbitraryReducedMaybe n -- txStatusInnerNumConfirmations :: Maybe Int
  
instance Arbitrary TxUtxosInner where
  arbitrary = sized genTxUtxosInner

genTxUtxosInner :: Int -> Gen TxUtxosInner
genTxUtxosInner n =
  TxUtxosInner
    <$> arbitraryReducedMaybe n -- txUtxosInnerTxHash :: Maybe TxHash
    <*> arbitraryReducedMaybe n -- txUtxosInnerInputs :: Maybe Inputs
    <*> arbitraryReducedMaybe n -- txUtxosInnerOutputs :: Maybe Outputs
  



instance Arbitrary E'ActionType where
  arbitrary = arbitraryBoundedEnum

instance Arbitrary E'PoolStatus where
  arbitrary = arbitraryBoundedEnum

instance Arbitrary E'Purpose where
  arbitrary = arbitraryBoundedEnum

instance Arbitrary E'Status where
  arbitrary = arbitraryBoundedEnum

instance Arbitrary E'Type where
  arbitrary = arbitraryBoundedEnum

instance Arbitrary E'Type2 where
  arbitrary = arbitraryBoundedEnum

