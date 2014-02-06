//
//  TCPPacket.m
//  Minecraft Server
//
//  Created by Victor Brekenfeld on 05.01.14.
//  Copyright (c) 2014 Victor Brekenfeld. All rights reserved.
//

#import "TCPPacket.h"
#import <objc/runtime.h>
#import "TCPClientPacket.h"
#import "TCPServerPacket.h"
#import <string.h>

@implementation TCPPacket

+ (void)setup {
    if (self == [TCPPacket class]) {
        
        int numClasses;
        Class * classes = NULL;
        
        classes = NULL;
        numClasses = objc_getClassList(NULL, 0);
        
        if (numClasses > 0 )
        {
            classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            
            for (int i = 0; i<numClasses; i++) {
                Class class = classes[i];
                while (class != nil) {
                    if (strcmp(class_getName(class_getSuperclass(class)), "TCPPacket") == 0) {
                        [classes[i] methodForSelector:@selector(setup)](classes[i], @selector(setup));
                        break;
                    } else {
                        class = class_getSuperclass(class);
                    }
                }
            }
            
            free(classes);
        }
        
    }
}

- (instancetype)initWithData:(OFDataArray *)data {
    return [super init];
}

+ (int)state {
    return 3; //most packets belong to the 'Play' state
}

+ (uint64_t)packetId {
    @throw [OFException exception]; //WithName:@"Raw TCPPacket call" reason:[NSString stringWithFormat:@"PacketID must be overriden and called via subclass %@", [self class]] userInfo:nil];
}

- (OFString *)description {
    return [OFString stringWithFormat:(OFConstantString *)@"%@:\n %@", [super description], [TCPPacket autoDescribe:self classType:[self class]]];
}

// Finds all properties of an object, and prints each one out as part of a string describing the class.
+ (OFString *) autoDescribe:(id)instance classType:(Class)classType
{
    unsigned int count;
    objc_property_t *propList = class_copyPropertyList(classType, &count);
    OFMutableString *propPrint = [OFMutableString string];
    
    for ( int i = 0; i < count; i++ )
    {
        objc_property_t property = propList[i];
        
        const char *propName = property_getName(property);
        OFString *propNameString =[OFString stringWithCString:propName encoding:OF_STRING_ENCODING_ASCII];
        
        if(propName)
        {
            @try {
                SEL sel = sel_registerName(propName);
                
                const char *attr = property_getAttributes(property);
                switch (attr[1]) {
                    case '@':
                        [propPrint appendString:[OFString stringWithFormat:(OFConstantString *)@"\t%@ = '%@'\n", propNameString, objc_msgSend(instance, sel)]];
                        break;
                    case 'i':
                        [propPrint appendString:[OFString stringWithFormat:(OFConstantString *)@"\t%@ = '%i'\n", propNameString, objc_msgSend(instance, sel)]];
                        break;
                    case 'c':
                        [propPrint appendString:[OFString stringWithFormat:(OFConstantString *)@"\t%@ = '%02x'\n", propNameString, objc_msgSend(instance, sel)]];
                        break;
                    case 'l':
                        [propPrint appendString:[OFString stringWithFormat:(OFConstantString *)@"\t%@ = '%li'\n", propNameString, objc_msgSend(instance, sel)]];
                        break;
                    case 's':
                        [propPrint appendString:[OFString stringWithFormat:(OFConstantString *)@"\t%@ = '%i'\n", propNameString, objc_msgSend(instance, sel)]];
                        break;
                    case 'f':
                        [propPrint appendString:[OFString stringWithFormat:(OFConstantString *)@"\t%@ = '%f'\n", propNameString, objc_msgSend(instance, sel)]];
                        break;
                    case 'd':
                        [propPrint appendString:[OFString stringWithFormat:(OFConstantString *)@"\t%@ = '%f'\n", propNameString, objc_msgSend(instance, sel)]];
                        break;
                    default:
                        [propPrint appendString:[OFString stringWithFormat:(OFConstantString *)@"\t%@ = 'Not printable'\n", propNameString]];
                        break;
                }
            }
            @catch (OFException *exception) {
                [propPrint appendString:[OFString stringWithFormat:(OFConstantString *)@"\t%@ = 'Not printable'\n", propNameString]];
            }
        }
    }
    free(propList);
    
    
    // Now see if we need to map any superclasses as well.
    Class superClass = class_getSuperclass( classType );
    if ( superClass != nil && ! [superClass isEqual:[OFObject class]] )
    {
        OFString *superString = [self autoDescribe:instance classType:superClass];
        [propPrint appendString:superString];
    }
    
    return propPrint;
}

@end