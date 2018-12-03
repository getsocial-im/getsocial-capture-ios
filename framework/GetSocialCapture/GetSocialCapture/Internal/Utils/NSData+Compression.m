/*
 *        Copyright 2015-2018 GetSocial B.V.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import "NSData+Compression.h"
#import <compression.h>

@implementation NSData(Compression)

- (NSData*)compress {
    return [self process:YES];
}

- (NSData*)decompress {
    return [self process:NO];
}

/*
 Based on: https://github.com/leemorgan/NSData-LAMCompression
 */
- (NSData *)process:(BOOL)compress {
    
    compression_stream stream;
    compression_status status;
    compression_stream_operation op;
    compression_stream_flags flags;
    compression_algorithm algorithm = COMPRESSION_LZFSE;
    
    if (compress) {
        op = COMPRESSION_STREAM_ENCODE;
        flags = COMPRESSION_STREAM_FINALIZE;
    } else {
        op = COMPRESSION_STREAM_DECODE;
        flags = 0;
    }
    
    status = compression_stream_init(&stream, op, algorithm);
    if (status == COMPRESSION_STATUS_ERROR) {
        // an error occurred
        return nil;
    }
    
    // setup the stream's source
    stream.src_ptr    = self.bytes;
    stream.src_size   = self.length;
    
    // setup the stream's output buffer
    // we use a temporary buffer to store data as it's compressed
    size_t dstBufferSize = 4096;
    uint8_t*dstBuffer    = malloc(dstBufferSize);
    stream.dst_ptr       = dstBuffer;
    stream.dst_size      = dstBufferSize;
    // and we store the output in a mutable data object
    NSMutableData *outputData = [NSMutableData new];
    
    do {
        status = compression_stream_process(&stream, flags);
        
        switch (status) {
            case COMPRESSION_STATUS_OK:
                // Going to call _process at least once more, so prepare for that
                if (stream.dst_size == 0) {
                    // Output buffer full...
                    
                    // Write out to mutableData
                    [outputData appendBytes:dstBuffer length:dstBufferSize];
                    
                    // Re-use dstBuffer
                    stream.dst_ptr = dstBuffer;
                    stream.dst_size = dstBufferSize;
                }
                break;
                
            case COMPRESSION_STATUS_END:
                // We are done, just write out the output buffer if there's anything in it
                if (stream.dst_ptr > dstBuffer) {
                    [outputData appendBytes:dstBuffer length:stream.dst_ptr - dstBuffer];
                }
                break;
                
            case COMPRESSION_STATUS_ERROR:
                return nil;
                
            default:
                break;
        }
    } while (status == COMPRESSION_STATUS_OK);
    
    compression_stream_destroy(&stream);
    free(dstBuffer);
    
    return [outputData copy];
}

@end
