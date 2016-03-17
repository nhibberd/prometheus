module System.Metrics.Prometheus.GlobalRegistry
       ( GlobalRegistry
       , new
       , registerCounter
       , registerGauge
       , registerHistogram
       , sample
       ) where


import           Control.Concurrent.MVar                    (MVar,
                                                             modifyMVarMasked,
                                                             newMVar, withMVar)
import           Data.Tuple                                 (swap)

import           System.Metrics.Prometheus.Metric.Counter   (Counter)
import           System.Metrics.Prometheus.Metric.Gauge     (Gauge)
import           System.Metrics.Prometheus.Metric.Histogram (Histogram,
                                                             UpperBound)
import           System.Metrics.Prometheus.MetricId         (Labels, Name)
import           System.Metrics.Prometheus.Registry         (Registry (..),
                                                             RegistrySample)
import qualified System.Metrics.Prometheus.Registry         as R


newtype GlobalRegistry = GlobalRegistry { unGlobalRegistry :: MVar Registry }


new :: IO GlobalRegistry
new = GlobalRegistry <$> newMVar R.new


registerCounter :: Name -> Labels -> GlobalRegistry -> IO Counter
registerCounter name labels = flip modifyMVarMasked register . unGlobalRegistry
  where
    register = fmap swap . R.registerCounter name labels


registerGauge :: Name -> Labels -> GlobalRegistry -> IO Gauge
registerGauge name labels = flip modifyMVarMasked register . unGlobalRegistry
  where
    register = fmap swap . R.registerGauge name labels


registerHistogram :: Name -> Labels -> [UpperBound] -> GlobalRegistry -> IO Histogram
registerHistogram name labels buckets = flip modifyMVarMasked register . unGlobalRegistry
  where
    register = fmap swap . R.registerHistogram name labels buckets


sample :: GlobalRegistry -> IO RegistrySample
sample = flip withMVar R.sample . unGlobalRegistry
