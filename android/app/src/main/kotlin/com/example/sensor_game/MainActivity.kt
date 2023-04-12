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
    private val PRESSURE_CHANNEL_NAME = "com.sensorIO.sensor"
    private lateinit var sensorManager: SensorManager
    private var pressureChannel: EventChannel? = null
    private var pressureStreamHandler:StreamHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupChannels(this, flutterEngine.dartExecutor.binaryMessenger)
    }
    private fun setupChannels(context: Context, messenger: BinaryMessenger){
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        pressureChannel = EventChannel(messenger, PRESSURE_CHANNEL_NAME)
        pressureStreamHandler = StreamHandler(sensorManager!!, Sensor.TYPE_PRESSURE)
        pressureChannel!!.setStreamHandler(pressureStreamHandler)

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
