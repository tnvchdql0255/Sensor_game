package com.example.sensor_game

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.stream.Stream

class MainActivity: FlutterActivity() {
    private val EVENT_CHANNEL_NAME = "com.sensorIO.sensor"
    private val METHOD_CHANNEL_NAME = "com.sensorIO.method"
    private lateinit var sensorManager: SensorManager
    private var methodChannel:MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var sensorStreamHandler:StreamHandler? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel!!.setMethodCallHandler { call, result ->
            if(call.method == "callPressureSensor"){
                setupChannels(this, flutterEngine.dartExecutor.binaryMessenger, Sensor.TYPE_PRESSURE)
                result.success(1)
            }
            if(call.method == "callTemperatureSensor"){
                setupChannels(this, flutterEngine.dartExecutor.binaryMessenger, Sensor.TYPE_AMBIENT_TEMPERATURE)
                result.success(1)
            }
            if(call.method == "callAccelerometerSensor"){

            }
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
