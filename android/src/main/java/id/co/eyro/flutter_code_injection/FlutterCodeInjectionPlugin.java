package id.co.eyro.flutter_code_injection;

import androidx.annotation.NonNull;

import java.util.ArrayList;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterCodeInjectionPlugin */
public class FlutterCodeInjectionPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter.eyro.co.id/flutter_code_injection");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if ("getWhiteListLibraries".equals(call.method)) {
      // TODO: return all used libraries
      result.success(new ArrayList<String>());
      return;
    }

    if ("checkWhiteListLibraries".equals(call.method)) {
      // TODO: check for existing libraries with whitelisted libraries from arguments
      result.success(true);
      return;
    }

    if ("checkDynamicLibrary".equals(call.method)) {
      // TODO: check if dynamic library inserted
      result.success(null);
      return;
    }

    result.notImplemented();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
