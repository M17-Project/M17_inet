# M17 Internet Interface

Digital modes are commonly networked together through linked repeaters using IP networking.
For commercial protocols like DMR, this is meant for linking metropolitan and state networks
together and allows for easy interoperability between radio users. Amateur Radio uses this
capability for creating global communications networks for all imaginable purposes, and makes
‘working the world’ with an HT possible.

M17 is designed with this use in mind, and has native IP framing to support it.
In competing radio protocols, a repeater or some other RF to IP bridge is required for linking,
leading to the use of hotspots (tiny simplex RF bridges).

## M17 Data Packets

All M17 Data Packets have a 4 character MAGIC field beginning with the characters `M17`. For forward compatibility, reflector implementers may choose to forward all packets with MAGIC beginning with those three characters. Clients should use the MAGIC value to recognize packets they understand and ignore those don't. This allows implementors to experiment with new packet types. For now there is no mechanism to avoid collisions in new MAGIC values. Therefore, implementors should announce to the community their intent to experiment with a new packet type/MAGIC value. If the experiment is successful, they should request a change to this specification to standardize the new packet type.

In all cases, data in these packets are big endian, consistent with other IP protocols. Packet components are not padded to any specific word size and are arranged sequentially.

Section references in the packet descriptions in this section refer to [M17 Part I - Air interface](https://spec.m17project.org/).

### Stream Mode Packets

The stream mode encoding combines the LSF with the payload to produce an all-in-one 54 byte packet. Within a stream, the LSF data will be identical within superframes. This allows late joiners to open a packet stream upon the receipt of any packet. A Superframe takes 6 packets for a total of 326 bytes.

| Field          | Size     | Description              |
|----------------|----------|--------------------------|
| MAGIC          | 4 bytes  | Magic bytes 0x4d313720 (“M17 ”)
| StreamID (SID) | 2 bytes  | Random bits, changed for each PTT or stream, but consistent from frame to frame within a stream
| LSD            | 28 bytes | The Link Setup Data (DST, SRC, TYPE, META field) as defined in section *2.5.1 Link Setup Data*  of the [Air Interface specification](https://spec.m17project.org/)
| FN             | 16 bits  | Frame number, exactly as would be transmitted as an RF stream frame, including the last frame indicator at (FN & 0x8000)
| Payload        | 16 bytes | 16 bytes (128 bits) of Stream data, exactly as would be transmitted in the STREAM portion of an RF stream frame as defined in section *2.8 Stream Mode*  of the [Air Interface specification](https://spec.m17project.org/)
| CRC16          | 2 bytes  | CRC for the entire packet, as defined in section *2.6 CRC* of the [Air Interface specification](https://spec.m17project.org/)

### Packet Mode IP Packet

| Field          | Size     | Description              |
|----------------|----------|--------------------------|
| MAGIC          | 4 bytes  | Magic bytes 0x4d313750 (“M17P”)
| LSF            | 30 bytes | The Link Setup Frame (DST, SRC, TYPE, META field, CRC) as defined in section 2.5.2
| Payload        | variable | The payload includes a type specifier, the user data, and a CRC, as described in section *3.3.2 Packet Data* of the [Air Interface specification](https://spec.m17project.org/)

The Payload CRC is computed from the type specifer and the user data. The size of a payload
must be at least 4, but no more than 825 bytes. Payload includes a one (to four) byte type
specifier, user data and a two byte CRC. Packet integrity is validated by the MAGIC value, the
LSF CRC and the Payload CRC.

## Control Packets

Relaying packets over an IP network is the preferred method of connecting M17 users together. This provide a one-to-many connection where one transmitter is sending data to many other receivers. It is possible to build relay stations that can handle either Stream or Packet Mode data, or both. These relay appliances can have a number of different channels and they can also be interlinked so that very large groups of hams can share information.

Existing relay systems, also called “reflectors”, use a few different types of control packets which are used to connect and disconnect and do other functions. These control packets are identified by their magic:

* `CONN` - Connect to a reflector
* `ACKN` - acknowledge connection
* `NACK` - deny connection
* `PING` - keepalive for the connection from the reflector to the client
* `PONG` - keepalive response from the client to the reflector
* `DISC` - Disconnect (client->reflector or reflector->client)

These control packets are described below.

### CONN
| Bytes | Purpose
|-------|----------------------
| 0..3  | Magic - ASCII “CONN”
| 4..9  | 6-byte ‘From’ callsign encoded as per Address Encoding
| 10    | Module to connect to - single ASCII byte A-Z

A client sends this to a reflector to initiate a connection. The reflector replies with ACKN on
successful linking, or NACK on failure.

### ACKN
| Bytes | Purpose
|-------|----------------------
| 0..3  | Magic - ASCII “ACKN”

### NACK
| Bytes | Purpose
|-------|----------------------
| 0..3  | Magic - ASCII “NACK”

### PING
| Bytes | Purpose
|-------|----------------------
| 0..3  | Magic - ASCII “PING”
| 4..9  | 6-byte ‘From’ callsign encoded as per Address Encoding

### PONG
| Bytes | Purpose
|-------|----------------------
| 0..3  | Magic - ASCII “PONG”
| 4..9  | 6-byte ‘From’ callsign encoded as per Address Encoding

### DISC
| Bytes | Purpose
|-------|----------------------
| 0..3  | Magic - ASCII “DISC”
| 4..9  | 6-byte ‘From’ callsign encoded as per Address Encoding
