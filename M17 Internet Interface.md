---
subtitle: Draft Specification
author: M17 Project Contributors
---

# M17 Internet Interface

## Introduction

Digital modes are commonly networked together through linked repeaters using IP networking.
For commercial protocols like DMR, this is meant for linking metropolitan and state networks
together and allows for easy interoperability between radio users. Amateur Radio uses this
capability for creating global communications networks for all imaginable purposes, and makes
‘working the world’ with an HT possible.

M17 is designed with this use in mind, and has native IP framing to support it.
In competing radio protocols, a repeater or some other RF to IP bridge is required for linking,
leading to the use of hot-spots (tiny simplex RF bridges).

## M17 Data Packets

All M17 Data Packets have a 4 character MAGIC field beginning with the characters `M17`. For forward compatibility, reflector implementers may choose to forward all packets with MAGIC beginning with those three characters. Clients should use the MAGIC value to recognize packets they understand and ignore those don't. This allows implementors to experiment with new packet types. For now there is no mechanism to avoid collisions in new MAGIC values. Therefore, implementors should announce to the community their intent to experiment with a new packet type/MAGIC value. If the experiment is successful, they should request a change to this specification to standardize the new packet type.

In all cases, data in these packets are big endian, consistent with other IP protocols. Packet components are not padded to any specific word size and are arranged sequentially.

Relaying packets over an IP network is the preferred method of connecting M17 users together. This provide a one-to-many connection where one transmitting node on an IP network is sending data to many other receiving nodes on that same network. It is possible to build relay stations that can handle either Stream or Packet Mode data, or both. These relay appliances can have a number of different channels and they can also be interlinked so that very large groups of hams can share information.

Section references in the packet descriptions in this section refer to [M17 Part I - Air interface](https://spec.m17project.org/).

### Stream Mode Packets

The stream mode encoding combines the LSF with the payload to produce an all-in-one 54 byte packet. Within a stream, the LSF data will be identical within superframes. This allows late joiners to open a packet stream upon the receipt of any packet. A superframe takes 6 packets for a total of 326 bytes.

| Field          | Size     | Description              |
|:---------------|:---------|:-------------------------|
| MAGIC          | 4 bytes  | Magic bytes 0x4d313720 (“M17 ”)
| StreamID (SID) | 2 bytes  | Random bits, changed for each PTT or stream, but consistent from frame to frame within a stream
| LSD            | 28 bytes | The Link Setup Data (DST, SRC, TYPE, META field) as defined in section *2.5.1 Link Setup Data*  of the [Air Interface specification](https://spec.m17project.org/)
| FN             |  2 bytes | 2 byte (16 bit) frame number, exactly as would be transmitted as an RF stream frame, including the last frame indicator at (FN & 0x8000)
| Payload        | 16 bytes | 16 bytes (128 bits) of Stream data, exactly as would be transmitted in the STREAM portion of an RF stream frame as defined in section *2.8 Stream Mode*  of the [Air Interface specification](https://spec.m17project.org/)
| CRC16          | 2 bytes  | CRC for the entire packet, as defined in section *2.6 CRC* of the [Air Interface specification](https://spec.m17project.org/)

### Packet Mode IP Packet

| Field          | Size     | Description              |
|:---------------|:---------|:-------------------------|
| MAGIC          | 4 bytes  | Magic bytes 0x4d313750 (“M17P”)
| LSF            | 30 bytes | The Link Setup Frame (DST, SRC, TYPE, META field, CRC) as defined in section 2.5.2
| Payload        | variable | The payload includes a type specifier, the user data, and a CRC, as described in section *3.3.2 Packet Data* of the [Air Interface specification](https://spec.m17project.org/)

The Payload CRC is computed from the type specifier and the user data. The size of a payload
must be at least 4, but no more than 825 bytes. Payload includes a one (to four) byte type
specifier, user data and a two byte CRC. Packet integrity is validated by the MAGIC value, the
LSF CRC and the Payload CRC.

## Packet used for Reflectors

Existing UDP relay systems, also called “reflectors”, use a few different types of control packets which are used to connect and disconnect and do other functions. These control packets are identified by their magic:

* `CONN` and `LSTN` - Connect to a reflector
* `ACKN` - acknowledge connection
* `NACK` - refuse a connection
* `PING` - keep-alive for the connection from a reflector to any connection
* `PONG` - keep-alive response from the client to the reflector
* `DISC` - Disconnect (client->reflector or reflector->client)

These control packets are described below.

### Connection Packets, `CONN` and `LSTN`

There are three different connection packets.

#### 1. An 11-byte `CONN` packet is sent from a regular client to a reflector:

A regular client can receive and transmit data to a reflector.

| Bytes | Purpose
|:------|:---------------------|
| 0..3  | Magic - ASCII “CONN”
| 4..9  | 6-byte ‘From’ callsign encoded as per Address Encoding
| 10    | Module to connect to - single ASCII byte A-Z

#### 2. An 11-byte `LSTN` packet is sent from a listen-only client to a reflector:

| Bytes | Purpose
|-------|----------------------
| 0..3  | Magic - ASCII “LSTN”
| 4..9  | 6-byte ‘From’ callsign encoded as per Address Encoding
| 10    | Module to connect to - single ASCII byte A-Z

#### 3. A 37-byte `CONN` packet is sent from a reflector to another reflector:

| Bytes | Purpose
|-------|----------------------
| 0..3  | Magic - ASCII “CONN”
| 4..9  | 6-byte ‘From’ reflector designation encoded as per Address Encoding
| 10..36 | List of modules to interlink, A-Z, padded with NULL bytes.

For all three forms of initiating a connection, the target reflector will reply with either an `ACKN` on successful linking, or `NACK` on failure.

### Acknowledging a connection request

There are two `ACKN` packets.

#### 1. A 4-byte packet is sent from a reflector to a normal, or listen-only client:

| Bytes | Purpose
|:------|:---------------------|
| 0..3  | Magic - ASCII “ACKN”

#### 2. A 37-byte packet is sent from a reflector to another reflector:

| Bytes | Purpose
|-------|----------------------
| 0..3  | Magic - ASCII “ACKN”
| 4..9  | 6-byte ‘From’ reflector designation encoded as per Address Encoding
| 10..36 | List of Module that are interlinked, A-Z, padded with NULL bytes.

Once the acknowledgement is received, the connection is established.

### Refusing a connection request

A 4-byte `NACK` is used for refusing a connection request.

| Bytes | Purpose
|:------|:---------------------|
| 0..3  | Magic - ASCII “NACK”

`NACK` packets can be sent from a reflector to the requesting node for several reasons:
- The request specifies a module that doesn't exist.
- The request has been blocked by the GateKeeper.
- In the case of a reflector interlink request, the target can send a `NACK` if the request is not identically configured on its side.

### Keep-alive packets

Keep-alive packets should be sent every 3 seconds and serve two purposes:

1. Inform a target that this node is still alive.
2. Keeps a UDP connection open on the target's firewall.

If a keep-alive has not been received for at least 30 seconds, it should be assumed that the node is dead and should be disconnected.

#### A 10-byte `PING` packet is only sent by a reflector to either an interlinked reflector, or to a client:

| Bytes | Purpose
|:------|:---------------------|
| 0..3  | Magic - ASCII “PING”
| 4..9  | 6-byte ‘From’ callsign encoded as per Address Encoding

#### A 10-byte `PONG` packet is sent from a regular or listen-only client to a reflector:

| Bytes | Purpose
|:------|:---------------------|
| 0..3  | Magic - ASCII “PONG”
| 4..9  | 6-byte ‘From’ callsign encoded as per Address Encoding

Any packet received from a connected client will reset that client's time-out timer, so `PONG` packets don't have to be sent during a transmission to the reflector.

For a while now, through *mrefd* release version 1.1.2 there has been a bug that will effectively allow `PING` packets to act as a `PONG` packet and will reset a client's timeout timer. This form of keep-alive is deprecated and will no longer work in a future release of *mrefd*.

Note that the reflector-reflector interconnect, sometimes called *peer linking*, is symmetric in design and execution. The connection must be specified on both ends identically, both ends initiate a `CONN` and make an appropriate response with `ACKN` or `NANK`, and both reflectors use `PING` as keep-alive packets.

### Disconnecting from an established connection

#### A 10-byte `DISC` packet is send by a node to initiate a disconnect from a target:

| Bytes | Purpose
|:------|:---------------------|
| 0..3  | Magic - ASCII “DISC”
| 4..9  | 6-byte ‘From’ callsign encoded as per Address Encoding

This can be initiated by any node when it is shutting down. 

If the request is from a reflector, the receiving node can assume the sending reflector is going down for maintenance and it can, after an appropriate time, try to reconnect.

However it is also possible that the disconnection was initiated because a defined interlink to a reflector was removed.

If the request is from a client, it might also be because the user controlling the client no longer wants the connection. The reflector will acknowledge the request by sending a simple 4-byte `DISC` acknowledgement packet and then remove the client from the client list.

| Bytes | Purpose
|-------|----------------------
| 0..3  | Magic - ASCII “DISC”

The 10-byte `DISC` initiates the disconnect, while the 4-byte `DISC` acknowledges that the disconnect is completed. A well designed client initiates a disconnect and waits for acknowledgement, if acknowledgement was not received and the client continues receiving `PING` packets, then it can assume it's disconnect packet was not delivered. That is possible for any UDP packet, so it can keep sending disconnect initiation packets until a 4-byte `DISC` is received.

### Stream and packet mode data passed between relectors

#### Legacy *vs* non-legacy reflectors and their differences

Be aware that there are two different kinds of reflectors:

1. Legacy reflector are all *urfd* reflectors as well as any *mrefd* reflector with a version number less than 1.0.0. Legacy reflectors **do not** forward any packet mode data.
2. Any *mrefd* reflector with a version number greater or equal to 1.0.0, will forward both stream data and packet data from any client on any particular node to all nodes connected to that same module, except if the data is packet mode data and if that node is an interlinked, legacy reflector.

Importantly, legacy reflectors will only forward stream data if the destination in the packet is addressed to the module to which it is linked. For example, the destination address must decode to `M17-XYZ m` or `URFXYZ  m`, where `m` is an appropriate module letter, A-Z. In both cases, please note that these destinations fill the maximum width of an M17 callsign, there are two spaces before the module in the *urfd* address! Further, legacy reflectors will readdress the destination address to be the encoded callsign of the client receiving the data. Whenever a reflector modifies a packet, any CRCs affected by that modification will be recalculated.

In general, non-legacy reflectors will forward any packet data without modification. However if the destination field looks like a legacy type destination, it will be changed to the BROADCAST address, 0xffffff, and the CRC will be recalculated upon forwarding.

#### Enforcing the "one hop" policy by appending a byte

Also be aware that both *urfd* and *mrefd* enforce a "one hop policy" for any incoming packet from a regular client. Fundamentally that means that any packet received from an interlinked reflector will not be forwarded to any other reflector. Therefore any number of reflectors that share a channel must be interlinked to all reflectors in that same group. That's the only way any client can hear every other client on that interlinked module.

To help assign whether an incoming packet was from a connected client or an interlinked reflector, an addition byte was added at the end of the stream packet. so if an incoming packet was 55 bytes, the last byte was stripped off and that packet was only forwarded to regular or listen-only clients. It didn't matter what was in that appended byte, but it is always set to a non-zero value. Since the actual packet was not modified, the CRC is not modified.

Non-legacy *mrefd* reflectors do the same thing. Regardless of whether the data is stream data or packet data, packets sent to another reflector have an addition byte appended at the end. Stream data becomes 55 bytes, while n-byte packet data become n+1 bytes long when sent between reflectors. But this time the added byte is the module of the client that originated the data. This helps the reflector route the data to the correct clients because with non-legacy reflectors, anything can be in the destination address.
