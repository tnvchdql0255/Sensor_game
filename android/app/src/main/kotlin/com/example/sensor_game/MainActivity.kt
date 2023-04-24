package com.example.sensor_game

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
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

class MainActivity: FlutterActivity() {
    private val EVENT_CHANNEL_NAME = "com.sensorIO.sensor"
    private val METHOD_CHANNEL_NAME = "com.sensorIO.method"
    private lateinit var sensorManager: SensorManager
    private lateinit var batteryManager: BatteryManager
    private var methodChannel:MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var sensorStreamHandler:StreamHandler? = null
    private lateinit var intent: Intent
   //private var batteryStreamHandler:BatteryStreamHandler? =null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel!!.setMethodCallHandler { call, result ->
            if(call.method == "callPressureSensor"){
                setupChannels(this, flutterEngine.dartExecutor.binaryMessenger, Sensor.TYPE_PRESSURE)
                result.success(1)
            }
            if(call.method == "callTemperatureSensor"){
                val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                var temperature = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 1)
                print(temperature)
                result.success(temperature)
            }
            if(call.method == "callAccelerometerSensor"){

            }
            else{
                //result.error("404","404",-1)
            }
        }
    }
    private fun setupChannels(context: Context, messenger: BinaryMessenger, SensorType: Int){
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME)
        sensorStreamHandler = StreamHandler(sensorManager!!, SensorType)
        eventChannel!!.setStreamHandler(sensorStreamHandler)

    }
//    private fun setUpBatteryChannel(context: Context, messenger: BinaryMessenger){
//        eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME)
//        batteryStreamHandler = BatteryStreamHandler(context)
//        eventChannel!!.setStreamHandler(batteryStreamHandler)
//
//    }

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
