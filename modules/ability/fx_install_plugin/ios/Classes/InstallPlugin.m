#import "InstallPlugin.h"
#import <fx_install_plugin/fx_install_plugin-Swift.h>

@implementation InstallPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftInstallPlugin registerWithRegistrar:registrar];
}
@end
