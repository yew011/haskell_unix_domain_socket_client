# Unix Domain Socket Client in Haskell

Example program which can connect to a unix domain socket, read a
uint32_t intger and echo it back.

This is an experiment toy for testing my memory sharing change to
the **stenographer** project.

# How to Parse PacketV3 Block

## Format

	1MB Block									Memory Address
	=========									==============
												     ||
	+--------------------------------+			     ||
	|                                |			     ||
	|   struct tpacket_block_desc    |			     ||
	|                                |			     ||
	|--------------------------------|			     ||
	|                                |			     ||
	|   struct tpacket3_hdr          |			     ||
	|                                |			     ||
	|--------------------------------|			     ||
	|                                |			     ||
	|   packet                       |			     ||
	|                                |			     ||
	|--------------------------------|			     \/
	|                                |
	|   ...                          |
	|                                |
	|--------------------------------|
	|                                |
	|  struct tpacket3_hdr           |
	|                                |
	|--------------------------------|
	|                                |
	|   packet                       |
	|                                |
	+--------------------------------+

## Useful Fields

* The **"tpacket_block_desc->hdr->num_pkts"** records the number of packet
  in the block.
* The **"tpacket3_hdr->tp_next_offset"** provides the offset from the starting
  address of the **"struct tpacket3_hrd"** to the next one.
* The **"tpacket3_hdr->tp_nsec"** provides the timestamp in nanoseconds (I think).

## Kernel Header File

[if_packet.h](http://lxr.free-electrons.com/source/include/uapi/linux/if_packet.h#L232)

