package com.dmlv.fcp;

import android.os.Bundle;
import android.util.Log;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterFragmentActivity {
    private static final String CHANNEL = "com.example.androidauto";
    private FlutterEngine flutterEngine;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Asegúrate de que el FlutterEngine no sea nulo
        if (getFlutterEngine() != null) {
            new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                    .setMethodCallHandler((call, result) -> {
                        if (call.method.equals("initializeAuto")) {
                            initializeAndroidAuto();
                            result.success(null);
                        } else if (call.method.equals("sendCommand")) {
                            String command = call.argument("command");
                            sendCommandToBluetoothDevice(command);
                            result.success(null);
                        } else {
                            result.notImplemented();
                        }
                    });
        } else {
            Log.e("MainActivity", "FlutterEngine no está inicializado.");
        }
    }

    private void initializeAndroidAuto() {
        Log.d("MainActivity", "Android Auto inicializado");
    }

    private void sendCommandToBluetoothDevice(String command) {
        Log.d("MainActivity", "Comando recibido desde Flutter: " + command);
    }
}
