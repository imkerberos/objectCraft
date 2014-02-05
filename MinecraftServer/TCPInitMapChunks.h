//
//  TCPInitMapChunks.h
//  Minecraft Server
//
//  Created by Victor Brekenfeld on 06.01.14.
//  Copyright (c) 2014 Victor Brekenfeld. All rights reserved.
//

#import "TCPServerPacket.h"
@class ChunkColumn;

@interface TCPInitMapChunks : TCPServerPacket {
    OFMutableArray *chunkColumns;
}

@property BOOL skyLightSend;

- (instancetype)initForDimension:(int8_t)dimension;
- (void)addChunkColumn:(ChunkColumn *)chunk;

@end