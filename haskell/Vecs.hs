--- | Dumps the eight-column test vector layout for py/checkvecs.py.
--- Input lat, input lon, then wgs_gcj, gcj_bd and wgs_bd of the input.
module Main (main) where

import Data.List (intercalate)
import Data.Maybe (mapMaybe)
import PRCoords
import System.Environment (getArgs)
import System.IO (BufferMode (LineBuffering), hSetBuffering, stdout)

parsePoint :: String -> Maybe PCoords
parsePoint line = case words line of
    (a:b:_) -> case (reads a, reads b) of
                 ([(la, "")], [(lo, "")]) -> Just (PCoords la lo)
                 _ -> Nothing
    _ -> Nothing

emit :: PCoords -> String
emit (PCoords la lo) =
    intercalate "\t" (map show [la, lo, lat wg, lon wg, lat gb, lon gb, lat wb, lon wb])
  where
    p = PCoords la lo
    wg = wgsGcj p
    gb = gcjBd p
    wb = wgsBd p

main :: IO ()
main = do
    hSetBuffering stdout LineBuffering
    args <- getArgs
    content <- case args of
                 (f:_) -> readFile f
                 _ -> getContents
    mapM_ (putStrLn . emit) (mapMaybe parsePoint (lines content))
