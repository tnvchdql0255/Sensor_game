package com.example.sensor_game

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.BatteryManager
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.stream.Stream
import kotlin.system.exitProcess

class MainActivity: FlutterActivity() {
    private val EVENT_CHANNEL_NAME = "com.sensorIO.sensor" //이벤트기반 채널통신 주소
    private val METHOD_CHANNEL_NAME = "com.sensorIO.method"// 메소드 인보크 기반 주소

    private lateinit var sensorManager: SensorManager //센서 데이터를 불러오기위해 필요함

    private var methodChannel:MethodChannel? = null //메소드 채널용
    private var eventChannel: EventChannel? = null //이벤트 채널용
    private var sensorStreamHandler:StreamHandler? = null //이벤트기반으로 센서데이터를 방송하기위해 필요함


    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel!!.setMethodCallHandler { call, result ->
            if(call.method == "callPressureSensor"){
                setupChannels(this, flutterEngine.dartExecutor.binaryMessenger, Sensor.TYPE_PRESSURE)
                result.success(1)
            }
            if(call.method == "callTemperatureSensor"){
                var res = getBatteryLevel()
                result.success(res)
            }
            if(call.method == "callAccelerometerSensor"){

            }
        }
    }
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
        return batteryLevel
    }

    @RequiresApi(Build.VERSION_CODES.R)
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        if(newConfig.isNightModeActive){
            println("config changed")
            exitProcess(0)
        }
    }
    private fun setupChannels(context: Context, messenger: BinaryMessenger, SensorType: Int){
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME)
        sensorStreamHandler = StreamHandler(sensorManager!!, SensorType)
        eventChannel!!.setStreamHandler(sensorStreamHandler)

    }

    override fun onDestroy() {
        super.onDestroy()
    }
}

class StreamHandler(private val sensorManager: SensorManager, sensorType: Int,
                    private var interval: Int = SensorManager.SENSOR_DELAY_NORMAL ):EventChannel.StreamHandler, SensorEventListener {
    private val sensor = sensorManager.getDefaultSensor(sensorType)
    private var eventSink:EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if(sensor !=null){
            eventSink = events
            sensorManager.registerListener(this, sensor, interval)
        }
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        eventSink = null
    }

    override fun onSensorChanged(event: SensorEvent?) {
        val sensorValues = event!!.values[0]
        eventSink?.success(sensorValues)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy:Int) {

    }
}
