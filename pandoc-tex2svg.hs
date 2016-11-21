{-# LANGUAGE ScopedTypeVariables #-}

module Main where
import Text.Pandoc.JSON
import Control.Monad (when)
import System.Exit
import System.Process
import Data.IORef
import qualified Data.Map as M
import System.Directory (findExecutable)
import System.IO (stderr, hPutStrLn)

newtype Cache = Cache (M.Map (MathType, String) String)

lookupCache :: (MathType, String) -> Cache -> Maybe String
lookupCache s (Cache c) = M.lookup s c

addToCache :: (MathType, String) -> String -> Cache -> Cache
addToCache s v (Cache c) = Cache $ M.insert s v c

main :: IO ()
main = do
  cache <- newIORef (Cache M.empty)
  toJSONFilter (tex2svg cache)

tex2svg :: IORef Cache -> Inline -> IO Inline
tex2svg cr (Math mt math) = do
  mbfp <- findExecutable "tex2svg"
  when (mbfp == Nothing) $ do
    hPutStrLn stderr $ "The tex2svg program was not found in the path.\n" ++
        "Install MathJax-node (https://github.com/mathjax/MathJax-node)\n" ++
        "and ensure that tex2svg is in your path."
    exitWith $ ExitFailure 1
  cache <- readIORef cr
  svg <- case lookupCache (mt, math) cache of
               Just s  -> return s
               Nothing -> do
                 svg' <- readProcess "tex2svg"
                    (["--inline" | mt == InlineMath] ++ [math]) ""
                 modifyIORef cr (addToCache (mt, math) svg')
                 return svg'
  if null svg -- indicates an error -- tex2svg doesn't return error status
     then do
       hPutStrLn stderr $ "Could not convert: " ++ math
       return $ Math mt math
     else return $ RawInline (Format "html") $
               "<span class=\"math " ++
               (if mt == InlineMath then "inline" else "display") ++ "\">" ++
               svg ++ "</span>"
tex2svg _ il = return il

