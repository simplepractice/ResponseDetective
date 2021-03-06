//
// RDTHTMLBodyDeserializer.m
//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

#import <libxml/HTMLTree.h>
#import "RDTHTMLBodyDeserializer.h"

@implementation RDTHTMLBodyDeserializer

- (nullable NSString *)deserializeBody:(nonnull NSData *)body {
	NSString *string = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
	const char *memory = string.UTF8String;
	htmlDocPtr document = htmlReadMemory(memory, ((int)(strlen(memory))), NULL, NULL, HTML_PARSE_NOBLANKS);
	xmlChar *buffer = NULL;
	int bufferLength = 0;
	htmlDocDumpMemoryFormat(document, &buffer, &bufferLength, 1);
	NSString *result = [[NSString alloc] initWithBytes:buffer length:bufferLength encoding:NSUTF8StringEncoding];
	xmlFree(buffer);
	return [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
