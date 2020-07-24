{-# OPTIONS_GHC -fno-warn-unused-do-bind #-}
{-# LANGUAGE CPP #-}

-- |
-- Module:      Trace.Hpc.Coveralls.Paths
-- Copyright:   (c) 2014-2015 Guillaume Nargeot
-- License:     BSD3
-- Maintainer:  Guillaume Nargeot <guillaume+hackage@nargeot.com>
-- Stability:   experimental
--
-- Paths constants and functions for hpc coverage report output.

module Trace.Hpc.Coveralls.Paths where

import Control.Monad
import Data.Maybe
import Data.Traversable (traverse)
import System.Directory (
    doesDirectoryExist, getDirectoryContents
    )
import System.Directory.Tree (
    AnchoredDirTree(..), dirTree, readDirectoryWith
    )
import System.Info (os, arch)
import Trace.Hpc.Tix

distDir :: FilePath
distDir = "dist-newstyle/"

distribName :: String
distribName | os == "darwin" = arch ++ "-osx"
            | os == "linux" = arch ++ "-linux"
            | os == "mingw32" = arch ++ "-windows"
            | otherwise = arch ++ "-unknown"

hpcDirs :: Maybe String -> [FilePath]
hpcDirs (Just pkgNameVer) = map (distDir ++) [ "build/"
                                             ++ distribName ++ "/"
                                             ++ "ghc-" ++ TOOL_VERSION_ghc ++"/"
                                             ++ pkgNameVer ++ "/"
                                             ++ "/hpc/vanilla/"
                                             , "dist/hpc/vanilla/"
                                             , "hpc/"
                                             ]
hpcDirs _ = []

tixDir :: String -> FilePath
tixDir = (++ "tix/")

mixDir :: String -> FilePath
mixDir = (++ "mix/")

getMixPath :: Maybe String -- ^ target package name-version
           -> String       -- ^ hpc output base directory
           -> String       -- ^ test suite name
           -> TixModule    -- ^ tix module
           -> FilePath     -- ^ mix file path
getMixPath mPkgNameVer hpcDir testSuiteName tix = mixDir hpcDir ++ dirName ++ "/"
    where dirName = case span (/= '/') modName of
              (_, []) -> testSuiteName
              (packageId, _) -> fromMaybe packageId mPkgNameVer
          TixModule modName _ _ _ = tix

getTixPath :: String -> String -> FilePath
getTixPath hpcDir testSuiteName = tixDir hpcDir ++ testSuiteName ++ "/" ++ testSuiteName ++ ".tix"

firstExistingDirectory :: [FilePath] -> IO (Maybe FilePath)
firstExistingDirectory = fmap msum . mapM pathIfExist
    where pathIfExist path = do
              pathExists <- doesDirectoryExist path
              return $ if pathExists then Just path else Nothing

dumpDirectory :: FilePath -> IO ()
dumpDirectory path = do
    directoryExists <- doesDirectoryExist path
    unless directoryExists $ putStrLn ("Couldn't find the directory " ++ path)
    putStrLn ("Dumping " ++ path ++ " directory content:")
    contents <- getDirectoryContents path
    traverse putStrLn contents
    return ()

dumpDirectoryTree :: FilePath -> IO ()
dumpDirectoryTree path = do
    putStrLn ("Dumping " ++ path ++ " directory tree:")
    tree <- readDirectoryWith return path
    traverse putStrLn $ dirTree tree
    return ()
