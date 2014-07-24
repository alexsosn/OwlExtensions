
#import <objc/runtime.h>

static const char * property_getTypeString(prop)
objc_property_t prop;
{
    const char * attrs = property_getAttributes( prop );
    if ( attrs == NULL )
        return ( NULL );
    
    static char buffer[256];
    const char * e = strchr( attrs, ',' );
    if ( e == NULL )
        return ( NULL );
    
    int len = (int)(e - attrs);
    memcpy( buffer, attrs, len );
    buffer[len] = '\0';
    
    return ( buffer );
}

static NSString * NSStringFromTypeString(str)
const char * str;
{
	NSString *propertyType = [NSString stringWithUTF8String:str];
	NSString *prefix = @"T@\"";
	NSString *suffix = @"\"";
	NSRange range = NSMakeRange(prefix.length,
	                            propertyType.length - prefix.length - suffix.length);
	return [propertyType substringWithRange:range];
}

static id tryCastToClass(class, cast, name)
Class class;
id cast;
const char * name;
{
	if ([cast isKindOfClass:class]) {
		return cast;
	}
	NSLog(@"Wrong type of %s. Currently: %@, should be: %@", name, [cast class], class);
	if (class == [NSString class]) {
		if ([cast respondsToSelector:@selector(stringValue)]) {
			id string = [cast valueForKey:@"stringValue"];
			return string;
		}
	} else if (class == [NSNumber class]) {
		if ([cast respondsToSelector:@selector(floatValue)]) {
			return @([cast floatValue]);
		}
	}
	return nil;
}

/* Override setter with type validation logic. */

#define generateSafeSetter(X, x) -(void)set ## X : (id)x { \
		objc_property_t property = class_getProperty([self class], #x); \
		const char * typeStr = (property == NULL) ? NULL : property_getTypeString(property); \
		Class class = NSClassFromString(NSStringFromTypeString(typeStr)); \
		_ ## x = tryCastToClass(class, x, #x); \
}
