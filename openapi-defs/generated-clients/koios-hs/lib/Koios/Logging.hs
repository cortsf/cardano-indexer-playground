

{-|
Module : Koios.Logging
Logging functions
-}
{-# LANGUAGE CPP #-}

#ifdef USE_KATIP

module Koios.Logging
  ( module Koios.LoggingKatip
  ) where

import Koios.LoggingKatip

#else

module Koios.Logging
  ( module Koios.LoggingMonadLogger
  ) where

import Koios.LoggingMonadLogger

#endif
