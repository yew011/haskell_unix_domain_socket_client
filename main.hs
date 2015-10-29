import           Control.Monad
import           Network.Socket hiding (recv, send)
import           Network.Socket.ByteString (recv, send)
import           System.Environment
import           Text.Printf

main = do
  (arg : _) <- getArgs
  progName  <- getProgName
  if arg == "--help" then do
    printf "Usage: %s PUNIX_FILE_PATH\n" progName
  else do
    sock <- socket AF_UNIX Stream 0
    connect sock $ SockAddrUnix arg
    forever $ do
      offset <- recv sock 4
      send sock offset
