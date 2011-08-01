#import <CaptainHook/CaptainHook.h>

CHDeclareClass(ClassName);

CHDeclareMethod(0, void, ClassName, someMethod)
{
	CHSuper(0, ClassName, someMethod);
}

CHConstructor
{
	CHLoadLateClass(ClassName);
	CHHook(0, ClassName, someMethod);
}

