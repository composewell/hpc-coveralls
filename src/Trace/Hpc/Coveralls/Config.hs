module Trace.Hpc.Coveralls.Config where

import Trace.Hpc.Coveralls.Types (CoverageMode)

data TestSuites
    = All
    | TestSuites ![String]
    deriving (Eq, Show)

maybeToTestSuites :: Maybe [String] -> TestSuites
maybeToTestSuites Nothing   = All
maybeToTestSuites (Just xs) = TestSuites xs

data Config = Config {
    excludedDirs :: ![FilePath],
    coverageMode :: !CoverageMode,
    cabalFile    :: !(Maybe FilePath),
    serviceName  :: !(Maybe String),
    repoToken    :: !(Maybe String),
    testSuites   :: !TestSuites
    } deriving (Eq, Show)
