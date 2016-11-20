module Main where
import Text.Pandoc.JSON
import System.Process
import Data.IORef
import qualified Data.Map as M


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
  cache <- readIORef cr
  svg <- case lookupCache (mt, math) cache of
               Just s  -> return s
               Nothing -> do
                 svg' <- readProcess "tex2svg"
                    (["--inline" | mt == InlineMath] ++ [math]) ""
                 modifyIORef cr (addToCache (mt, math) svg')
                 return svg'
  return $ RawInline (Format "html") $
    "<span class=\"math " ++
    (if mt == InlineMath then "inline" else "display") ++ "\">" ++
    svg ++ "</span>"
tex2svg _ il = return il

