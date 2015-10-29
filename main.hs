import           Control.Monad
import           Data.Monoid
import           Data.Bits
import           Data.ByteString as B
import           Data.Word
import           Data.Monoid
import           Foreign.C.Types (CSize)
import qualified Foreign.Concurrent as FC
import           Foreign.ForeignPtr
import           Foreign.Ptr
import           MMAP
import           Network.Socket hiding (recv, send)
import           Network.Socket.ByteString (recv, send)
import           System.Environment
import           System.Posix.Files
import           System.Posix.SharedMem
import           System.Posix.Types
import           Text.Printf

blockSize = 1024 * 1024

getWord32HostOrder :: B.ByteString -> Word32
getWord32HostOrder bs = b3 .|. b2 .|. b1 .|. b0 where
  b3 = fromIntegral (B.head bs)
  b2 = fromIntegral (B.head $ B.drop 1 bs) `shiftL` 8
  b1 = fromIntegral (B.head $ B.drop 2 bs) `shiftL` 16
  b0 = fromIntegral (B.head $ B.drop 3 bs) `shiftL` 24

-- Based on the SharedMemory library code:
-- https://hackage.haskell.org/package/shared-memory-0.1.0.0.
openSharedMemoryReadOnly :: String -> CSize -> ShmOpenFlags -> FileMode -> IO (ForeignPtr (), Fd)
openSharedMemoryReadOnly shmemPath size openFlags openFileMode = do
  fd <- shmOpen shmemPath openFlags openFileMode
  ptr <- mmap nullPtr
         size
         (protRead)
         (mkMmapFlags mapShared mempty)
         fd
         0
  fptr <- FC.newForeignPtr ptr (munmap ptr size)
  return (fptr, fd)

main = do
  (arg : _) <- getArgs
  progName  <- getProgName
  if arg == "--help"
    then do
      printf "Usage: %s PUNIX_FILE_PATH SHM_PATH BLOCKS\n" progName
    else do
      [punixPath, shmPath, shmBlocks] <- getArgs
      sock <- socket AF_UNIX Stream 0
      connect sock $ SockAddrUnix punixPath
      (shmPtr, shmFd) <- openSharedMemoryReadOnly shmPath ((read shmBlocks) * blockSize) (ShmOpenFlags False False False False) 0000
      forever $ do
        offset <- recv sock 4
        printf "Echoing: %u\n" $ getWord32HostOrder offset
        send sock offset
